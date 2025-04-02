import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'package:intl/intl.dart';

class RecordingSummaryScreen extends StatefulWidget {
  const RecordingSummaryScreen({super.key});

  @override
  RecordingSummaryScreenState createState() => RecordingSummaryScreenState();
}

class RecordingSummaryScreenState extends State<RecordingSummaryScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  String? _recordingPath;
  bool _isRecording = false;
  bool _isPlaying = false;
  String _location = 'Loading location...';
  Duration _recordingDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;
  Timer? _recordingTimer;
  final TextEditingController _titleController = TextEditingController();
  final List<double> _waveformData = [];
  bool _isWaveformDragging = false;
  
  // Expandable section states
  bool _isTopicsExpanded = false;
  bool _isSummaryExpanded = false;
  bool _isActionsExpanded = false;
  bool _isKeyPointsExpanded = false;
  bool _isFullNotesExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _getCurrentLocation();
    _titleController.text = 'Recording ${DateFormat('MM/dd/yyyy').format(DateTime.now())}';
  }

  Future<void> _initializeRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    await _recorder.openRecorder();
    await _player.openPlayer();
    
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 50));
    _player.setSubscriptionDuration(const Duration(milliseconds: 50));
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        setState(() {
          _location = '${place.locality}, ${place.administrativeArea}';
        });
      }
    } catch (e) {
      setState(() {
        _location = 'Location unavailable';
      });
    }
  }

  Future<void> _startRecording() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _recordingPath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
      
      await _recorder.startRecorder(
        toFile: _recordingPath,
        codec: Codec.aacADTS,
      );

      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
        _waveformData.clear();
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });
      });

      _recorder.onProgress!.listen((event) {
        if (event.decibels != null) {
          setState(() {
            _waveformData.add(event.decibels! / 120); // Normalize to 0-1 range
          });
        }
      });
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder.stopRecorder();
      _recordingTimer?.cancel();
      setState(() {
        _isRecording = false;
      });
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _playRecording() async {
    if (_recordingPath == null) return;
    
    try {
      await _player.startPlayer(
        fromURI: _recordingPath,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
            _playbackPosition = Duration.zero;
          });
        },
      );

      setState(() {
        _isPlaying = true;
      });

      _player.onProgress!.listen((event) {
        setState(() {
          _playbackPosition = event.position;
        });
      });
    } catch (e) {
      print('Error playing recording: $e');
    }
  }

  Future<void> _pausePlayback() async {
    try {
      await _player.pausePlayer();
      setState(() {
        _isPlaying = false;
      });
    } catch (e) {
      print('Error pausing playback: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _recordingTimer?.cancel();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E2E) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: isDarkMode ? Colors.white : Colors.black),
            onPressed: () {
              // Implement share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDarkMode),
              const SizedBox(height: 24),
              _buildActionButtons(isDarkMode),
              const SizedBox(height: 24),
              _buildExpandableSections(isDarkMode),
              const SizedBox(height: 24),
              _buildWaveform(isDarkMode),
              const SizedBox(height: 24),
              _buildRecordingControls(isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.layers,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 8),
            Text(
              _location,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Title of your recording',
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.white38 : Colors.black38,
            ),
          ),
        ),
        Text(
          DateFormat('MM/dd/yyyy \'at\' hh:mm a').format(DateTime.now()),
          style: TextStyle(
            color: isDarkMode ? Colors.white54 : Colors.black54,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDarkMode) {
    return Row(
      children: [
        _buildActionButton(
          isDarkMode,
          'View video',
          Icons.videocam,
          () {
            // Implement video view
          },
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          isDarkMode,
          'Transcript',
          Icons.description,
          () {
            // Implement transcript view
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    bool isDarkMode,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSections(bool isDarkMode) {
    return Column(
      children: [
        _buildExpandableSection(
          isDarkMode,
          'Topics',
          'Keywords referring to this event.',
          Icons.topic,
          _isTopicsExpanded,
          (value) => setState(() => _isTopicsExpanded = value),
          TextField(
            decoration: InputDecoration(
              hintText: 'Add topics...',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white38 : Colors.black38,
              ),
              border: InputBorder.none,
            ),
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        _buildExpandableSection(
          isDarkMode,
          'Summary',
          'A short summary of this conversation.',
          Icons.summarize,
          _isSummaryExpanded,
          (value) => setState(() => _isSummaryExpanded = value),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add summary...',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white38 : Colors.black38,
              ),
              border: InputBorder.none,
            ),
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        _buildExpandableSection(
          isDarkMode,
          'Actions',
          'A jobs-to-do action plan.',
          Icons.check_circle_outline,
          _isActionsExpanded,
          (value) => setState(() => _isActionsExpanded = value),
          TextField(
            decoration: InputDecoration(
              hintText: 'Add actions...',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white38 : Colors.black38,
              ),
              border: InputBorder.none,
            ),
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        _buildExpandableSection(
          isDarkMode,
          'Key points',
          'Most important highlights with quotes from the conversation.',
          Icons.star_outline,
          _isKeyPointsExpanded,
          (value) => setState(() => _isKeyPointsExpanded = value),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add key points...',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white38 : Colors.black38,
              ),
              border: InputBorder.none,
            ),
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        _buildExpandableSection(
          isDarkMode,
          'Full notes',
          'Access the full transcript with all other details above.',
          Icons.notes,
          _isFullNotesExpanded,
          (value) => setState(() => _isFullNotesExpanded = value),
          TextField(
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Add notes...',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white38 : Colors.black38,
              ),
              border: InputBorder.none,
            ),
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableSection(
    bool isDarkMode,
    String title,
    String description,
    IconData icon,
    bool isExpanded,
    ValueChanged<bool> onExpansionChanged,
    Widget child,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: isDarkMode ? Colors.white54 : Colors.black54,
            fontSize: 12,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
        onExpansionChanged: onExpansionChanged,
      ),
    );
  }

  Widget _buildWaveform(bool isDarkMode) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          setState(() {
            _isWaveformDragging = true;
          });
        },
        onHorizontalDragUpdate: (details) {
          if (_isWaveformDragging && _waveformData.isNotEmpty) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final double position = details.localPosition.dx.clamp(0, box.size.width);
            final double percent = position / box.size.width;
            if (_isPlaying) {
              _player.seekToPlayer(Duration(
                milliseconds: (_recordingDuration.inMilliseconds * percent).round(),
              ));
            }
          }
        },
        onHorizontalDragEnd: (details) {
          setState(() {
            _isWaveformDragging = false;
          });
        },
        child: CustomPaint(
          painter: WaveformPainter(
            waveformData: _waveformData,
            color: isDarkMode ? Colors.white70 : Colors.black54,
            position: _playbackPosition.inMilliseconds /
                (_recordingDuration.inMilliseconds == 0
                    ? 1
                    : _recordingDuration.inMilliseconds),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingControls(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.videocam,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
          onPressed: () {
            // Implement video recording
          },
        ),
        const SizedBox(width: 24),
        FloatingActionButton(
          onPressed: _isRecording ? _stopRecording : _startRecording,
          backgroundColor: _isRecording ? Colors.red : Theme.of(context).primaryColor,
          child: Icon(_isRecording ? Icons.stop : Icons.mic),
        ),
        const SizedBox(width: 24),
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
          onPressed: _recordingPath == null
              ? null
              : _isPlaying
                  ? _pausePlayback
                  : _playRecording,
        ),
      ],
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color color;
  final double position;

  WaveformPainter({
    required this.waveformData,
    required this.color,
    required this.position,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    if (waveformData.isEmpty) return;

    final width = size.width / waveformData.length;
    final middle = size.height / 2;

    for (var i = 0; i < waveformData.length; i++) {
      final x = i * width;
      final amplitude = waveformData[i] * size.height / 2;
      
      canvas.drawLine(
        Offset(x, middle - amplitude),
        Offset(x, middle + amplitude),
        paint..color = x < size.width * position ? color : color.withOpacity(0.3),
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) =>
      waveformData != oldDelegate.waveformData ||
      color != oldDelegate.color ||
      position != oldDelegate.position;
} 