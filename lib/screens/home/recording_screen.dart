import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import '../../theme_provider.dart';
import '../../widgets/gradient_scaffold.dart';
import 'package:path/path.dart' as path;

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  RecordingScreenState createState() => RecordingScreenState();
}

class RecordingScreenState extends State<RecordingScreen> with SingleTickerProviderStateMixin {
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isPlaying = false;
  bool _isProcessing = false;
  bool _hasPermission = false;
  
  String? _audioFilePath;
  File? _videoFile;
  
  int _recordingDuration = 0;
  int _playbackPosition = 0;
  int _audioDuration = 0;
  RecordingType _recordingType = RecordingType.audio;
  
  final List<String> _qualities = ['Low', 'Medium', 'High'];
  String _selectedQuality = 'Medium';
  
  List<RecordingFile> _recentRecordings = [];
  
  RecorderController? _recorderController;
  PlayerController? _playerController;
  
  late TabController _tabController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        setState(() => _recordingType = RecordingType.audio);
      } else {
        setState(() => _recordingType = RecordingType.video);
      }
    });
    
    _initRecorders();
    _loadRecentRecordings();
  }

  Future<void> _initRecorders() async {
    try {
      await _checkPermissions();
      await _audioRecorder.openRecorder();
      await _audioPlayer.openPlayer();
      
      _recorderController = RecorderController()
        ..androidEncoder = AndroidEncoder.aac
        ..androidOutputFormat = AndroidOutputFormat.mpeg4
        ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
        ..sampleRate = 44100;
        
      _playerController = PlayerController();
    } catch (e) {
      print('Error initializing recorders: $e');
    }
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.microphone.request();
    setState(() {
      _hasPermission = status == PermissionStatus.granted;
    });
    
    if (!_hasPermission && mounted) {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Microphone Permission Required'),
          content: const Text(
            'This app needs microphone access to record audio. Please grant permission in settings.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recording Help'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem(
                'Audio Recording',
                'Tap the Record button to start recording audio. You can pause and resume at any time.',
                Icons.mic,
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                'Video Recording',
                'Switch to the Video tab and tap the camera button to record a video.',
                Icons.videocam,
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                'Playback',
                'Tap on any recording to play it back. Use the play button on audio recordings.',
                Icons.play_arrow,
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                'Transcription',
                'For audio recordings, use the menu to transcribe speech to text.',
                Icons.text_fields,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('GOT IT'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String description, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 28.0),
          child: Text(description),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return GradientScaffold(
      appBar: AppBar(
        title: const Text(
          "Voice & Video Recorder",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHelpDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "AUDIO"),
            Tab(text: "VIDEO"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAudioRecordingTab(isDarkMode),
          _buildVideoRecordingTab(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildAudioRecordingTab(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Audio visualizer
          _buildAudioVisualizer(isDarkMode),
          
          const SizedBox(height: 16),
          
          // Recording duration
          if (_isRecording)
            Text(
              _formatDuration(_recordingDuration),
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            
          const SizedBox(height: 24),
          
          // Recording controls
          _buildRecordingControls(isDarkMode),
          
          const SizedBox(height: 40),
          
          // Recent recordings
          Expanded(
            child: _buildRecentRecordings(isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoRecordingTab(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Video preview or placeholder
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: _videoFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/video_thumbnail.png',
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videocam_outlined,
                        size: 64,
                        color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tap the button below to start recording',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
          ),
          
          const SizedBox(height: 32),
          
          // Video recording button
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.redAccent,
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.videocam, color: Colors.white, size: 36),
              onPressed: _pickVideo,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Recent video recordings
          Expanded(
            child: _buildRecentRecordings(isDarkMode, audioOnly: false),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioVisualizer(bool isDarkMode) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black26 : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _isRecording
          ? AudioWaveforms(
              size: Size(MediaQuery.of(context).size.width - 40, 180),
              recorderController: _recorderController!,
              waveStyle: WaveStyle(
                waveColor: _isPaused ? Colors.grey : Colors.blueAccent,
                extendWaveform: true,
                showMiddleLine: false,
                spacing: 8.0,
                waveThickness: 4,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
            )
          : Center(
              child: _audioFilePath != null && _isPlaying
                  ? AudioFileWaveforms(
                      size: Size(MediaQuery.of(context).size.width - 40, 180),
                      playerController: _playerController!,
                      enableSeekGesture: true,
                      playerWaveStyle: PlayerWaveStyle(
                        fixedWaveColor: Colors.blueAccent,
                        liveWaveColor: Colors.blueAccent.shade700,
                        showBottom: false,
                        spacing: 8.0,
                        waveCap: StrokeCap.round,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      backgroundColor: Colors.transparent,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mic_none,
                          size: 64,
                          color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _audioFilePath != null 
                              ? 'Ready to play recording' 
                              : 'Tap the microphone button to start',
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }

  Widget _buildRecordingControls(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black26 : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Quality selector
          if (!_isRecording && !_isPlaying)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Quality: '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedQuality,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedQuality = newValue;
                      });
                    }
                  },
                  items: _qualities.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            
          const SizedBox(height: 16),
          
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!_isRecording && _audioFilePath != null)
                _buildControlButton(
                  onPressed: () => _playAudio(_audioFilePath!),
                  icon: _isPlaying ? Icons.stop : Icons.play_arrow,
                  label: _isPlaying ? 'Stop' : 'Play',
                  color: Colors.green,
                ),
                
              if (!_isPlaying)
                _buildControlButton(
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  icon: _isRecording ? Icons.stop : Icons.mic,
                  label: _isRecording ? 'Stop' : 'Record',
                  color: _isRecording ? Colors.red : Colors.blueAccent,
                  isLoading: _isProcessing,
                ),
                
              if (_isRecording)
                _buildControlButton(
                  onPressed: _pauseRecording,
                  icon: _isPaused ? Icons.play_arrow : Icons.pause,
                  label: _isPaused ? 'Resume' : 'Pause',
                  color: Colors.orange,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    bool isLoading = false,
  }) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                )
              : IconButton(
                  icon: Icon(icon, color: Colors.white, size: 32),
                  onPressed: onPressed,
                ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentRecordings(bool isDarkMode, {bool audioOnly = true}) {
    final filteredRecordings = audioOnly
        ? _recentRecordings.where((rec) => rec.isAudio).toList()
        : _recentRecordings.where((rec) => !rec.isAudio).toList();
    
    if (filteredRecordings.isEmpty) {
      return Center(
        child: Text(
          'No recordings yet',
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Text(
            'Recent Recordings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredRecordings.length,
            itemBuilder: (context, index) {
              final recording = filteredRecordings[index];
              return _buildRecordingItem(recording, isDarkMode);
            },
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.closeRecorder();
    _audioPlayer.closePlayer();
    _recorderController?.dispose();
    _playerController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentRecordings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      
      setState(() {
        _recentRecordings = files
            .where((file) => file is File && 
                (file.path.endsWith('.aac') || file.path.endsWith('.mp4')))
            .map((file) => RecordingFile(
                  file: file as File,
                  name: path.basename(file.path),
                  date: file.statSync().modified,
                  isAudio: file.path.endsWith('.aac'),
                ))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      });
    } catch (e) {
      print('Error loading recordings: $e');
    }
  }

  Future<void> _startRecording() async {
    if (!_hasPermission) {
      await _checkPermissions();
      if (!_hasPermission) return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      _audioFilePath = '${directory.path}/recording_$timestamp.aac';

      await _audioRecorder.startRecorder(
        toFile: _audioFilePath,
        codec: Codec.aacADTS,
      );

      await _recorderController?.record();

      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration++;
        });
      });
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      setState(() => _isProcessing = true);
      
      _timer?.cancel();
      await _audioRecorder.stopRecorder();
      await _recorderController?.stop();

      setState(() {
        _isRecording = false;
        _isPaused = false;
        _isProcessing = false;
      });

      await _loadRecentRecordings();
    } catch (e) {
      print('Error stopping recording: $e');
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _pauseRecording() async {
    try {
      if (_isPaused) {
        await _audioRecorder.resumeRecorder();
        await _recorderController?.record();
      } else {
        await _audioRecorder.pauseRecorder();
        await _recorderController?.pause();
      }

      setState(() {
        _isPaused = !_isPaused;
      });
    } catch (e) {
      print('Error pausing/resuming recording: $e');
    }
  }

  Future<void> _playAudio(String filePath) async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stopPlayer();
        await _playerController?.stopAllPlayers();
        setState(() {
          _isPlaying = false;
          _playbackPosition = 0;
        });
      } else {
        await _playerController?.preparePlayer(
          path: filePath,
          shouldExtractWaveform: true,
        );
        
        await _audioPlayer.startPlayer(
          fromURI: filePath,
          whenFinished: () {
            setState(() {
              _isPlaying = false;
              _playbackPosition = 0;
            });
          },
        );
        
        await _playerController?.startPlayer();
        
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 10),
      );

      if (video != null) {
        setState(() {
          _videoFile = File(video.path);
        });
        
        await _loadRecentRecordings();
      }
    } catch (e) {
      print('Error picking video: $e');
    }
  }

  Widget _buildRecordingItem(RecordingFile recording, bool isDarkMode) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          recording.isAudio ? Icons.mic : Icons.videocam,
          color: recording.isAudio ? Colors.blueAccent : Colors.redAccent,
        ),
        title: Text(
          recording.displayName,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          DateFormat('MMM d, y HH:mm').format(recording.date),
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (recording.isAudio)
              IconButton(
                icon: Icon(
                  _isPlaying && _audioFilePath == recording.file.path
                      ? Icons.stop
                      : Icons.play_arrow,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                onPressed: () => _playAudio(recording.file.path),
              ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              onPressed: () async {
                try {
                  await recording.file.delete();
                  await _loadRecentRecordings();
                } catch (e) {
                  print('Error deleting recording: $e');
                }
              },
            ),
          ],
        ),
        onTap: recording.isAudio
            ? () => _playAudio(recording.file.path)
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlaybackScreen(
                      videoFile: recording.file,
                    ),
                  ),
                ),
      ),
    );
  }
}

enum RecordingType {
  audio,
  video,
}

class RecordingFile {
  final File file;
  final String name;
  final DateTime date;
  final bool isAudio;
  
  RecordingFile({
    required this.file,
    required this.name,
    required this.date,
    required this.isAudio,
  });
  
  String get displayName {
    if (name.length > 20) {
      return name.substring(0, 15) + '...' + name.substring(name.length - 5);
    }
    return name;
  }
}

class VideoPlaybackScreen extends StatefulWidget {
  final File videoFile;
  const VideoPlaybackScreen({super.key, required this.videoFile});

  @override
  State<VideoPlaybackScreen> createState() => _VideoPlaybackScreenState();
}

class _VideoPlaybackScreenState extends State<VideoPlaybackScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }
  
  Future<void> _initializePlayer() async {
    try {
      _controller = VideoPlayerController.file(widget.videoFile);
      await _controller!.initialize();
      setState(() => _isInitialized = true);
      await _controller!.play();
    } catch (e) {
      print('Error initializing video player: $e');
    }
  }
  
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return GradientScaffold(
      appBar: AppBar(
        title: const Text(
          "Video Playback",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: _isInitialized && _controller != null
            ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_controller!),
                    _buildVideoControls(),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading video...',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  
  Widget _buildVideoControls() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.black54,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.replay_10, color: Colors.white),
            onPressed: () {
              final position = _controller!.value.position;
              final newPosition = position - const Duration(seconds: 10);
              _controller!.seekTo(newPosition);
            },
          ),
          IconButton(
            icon: Icon(
              _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () {
              setState(() {
                if (_controller!.value.isPlaying) {
                  _controller!.pause();
                } else {
                  _controller!.play();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.forward_10, color: Colors.white),
            onPressed: () {
              final position = _controller!.value.position;
              final newPosition = position + const Duration(seconds: 10);
              _controller!.seekTo(newPosition);
            },
          ),
        ],
      ),
    );
  }
}
