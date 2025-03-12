import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme_provider.dart';
import '../../widgets/gradient_scaffold.dart';

class TranscriptionScreen extends StatefulWidget {
  final String audioFilePath;
  
  const TranscriptionScreen({Key? key, required this.audioFilePath}) : super(key: key);

  @override
  TranscriptionScreenState createState() => TranscriptionScreenState();
}

class TranscriptionScreenState extends State<TranscriptionScreen> with SingleTickerProviderStateMixin {
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  bool _isPlaying = false;
  bool _isProcessing = false;
  bool _isTranscribed = false;
  bool _isEditing = false;
  double _transcriptionProgress = 0.0;
  String _transcriptionText = '';
  String _originalText = '';
  int _playbackPosition = 0;
  int _audioDuration = 0;
  Timer? _progressTimer;
  Timer? _playbackTimer;
  TextEditingController _textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  
  // Confidence levels for segments (simulated)
  List<Map<String, dynamic>> _segments = [];
  
  // Language options
  String _selectedLanguage = 'English (US)';
  List<String> _languages = [
    'English (US)', 
    'English (UK)', 
    'Spanish', 
    'French', 
    'German',
    'Japanese',
    'Mandarin',
    'Hindi',
    'Arabic'
  ];
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _initAnimations();
    if (widget.audioFilePath.isNotEmpty) {
      _startTranscription();
    }
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _animationController.forward();
  }

  Future<void> _initPlayer() async {
    await _audioPlayer.openPlayer();
    
    if (widget.audioFilePath.isNotEmpty) {
      try {
        await _audioPlayer.startPlayer(
          fromURI: widget.audioFilePath,
          whenFinished: () {
            setState(() {
              _isPlaying = false;
            });
          },
        );
        
        await Future.delayed(const Duration(milliseconds: 200));
        final progress = await _audioPlayer.getProgress();
        _audioDuration = progress['duration']?.inMilliseconds ?? 0;
        
        await _audioPlayer.stopPlayer();
      } catch (e) {
        print('Error initializing player: $e');
      }
    }
  }

  void _startTranscription() {
    setState(() {
      _isProcessing = true;
      _transcriptionProgress = 0.0;
    });
    
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_transcriptionProgress < 1.0) {
        setState(() {
          _transcriptionProgress += 0.01;
        });
      } else {
        timer.cancel();
        _completeTranscription();
      }
    });
  }

  void _completeTranscription() {
    final transcription = '''
    Hello and welcome to CAIPO. Today I wanted to record some thoughts about the new project we're working on. 
    
    The app interface is coming along nicely, and I think the user experience improvements we've made will really enhance the overall usability. I'd like to focus on implementing the transcription service next, with advanced features like timestamps, speaker identification, and confidence scoring.
    
    We should also consider adding export options for different file formats. Users might want to save transcriptions as text, Word documents, or even subtitles for videos.
    
    Let's schedule a meeting for next Tuesday to review our progress and outline the next steps. I'll send out a calendar invite later today.
    
    That's all for now, thanks for listening.
    '''.trim();
    
    final List<Map<String, dynamic>> segments = [];
    final words = transcription.split(' ');
    final segmentSize = words.length ~/ 6;
    
    for (int i = 0; i < words.length; i += segmentSize) {
      final end = i + segmentSize < words.length ? i + segmentSize : words.length;
      final segment = words.sublist(i, end).join(' ');
      
      final confidence = 0.75 + (0.25 * (i / words.length));
      
      segments.add({
        'text': segment,
        'start': (i / words.length * _audioDuration).toInt(),
        'end': (end / words.length * _audioDuration).toInt(),
        'confidence': confidence,
      });
    }
    
    setState(() {
      _isProcessing = false;
      _isTranscribed = true;
      _transcriptionText = transcription;
      _originalText = transcription;
      _segments = segments;
      _textEditingController.text = transcription;
    });
  }

  String _formatDuration(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pausePlayer();
        _playbackTimer?.cancel();
      } else {
        if (_playbackPosition >= _audioDuration) {
          _playbackPosition = 0;
        }
        
        await _audioPlayer.startPlayer(
          fromURI: widget.audioFilePath,
          whenFinished: () {
            setState(() {
              _isPlaying = false;
              _playbackPosition = 0;
            });
            _playbackTimer?.cancel();
          },
        );
        
        _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
          final progress = await _audioPlayer.getProgress();
          final position = progress['position']?.inMilliseconds ?? 0;
          setState(() {
            _playbackPosition = position;
          });
          
          _highlightCurrentSegment(_playbackPosition);
        });
      }
      
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      print('Error toggling playback: $e');
    }
  }

  void _highlightCurrentSegment(int position) {
    for (int i = 0; i < _segments.length; i++) {
      final segment = _segments[i];
      if (position >= segment['start'] && position <= segment['end']) {
        // Could implement scrolling to the current segment here
      }
    }
  }

  void _seekToPosition(int position) async {
    try {
      if (_isPlaying) {
        await _audioPlayer.seekToPlayer(Duration(milliseconds: position));
      }
      setState(() {
        _playbackPosition = position;
      });
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _textEditingController.text = _transcriptionText;
      } else {
        _transcriptionText = _textEditingController.text;
      }
    });
  }

  Future<void> _exportTranscription() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/transcription_$timestamp.txt';
      
      final file = File(filePath);
      await file.writeAsString(_transcriptionText);
      
      Share.shareFiles([filePath], text: 'Transcription');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transcription exported successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print('Error exporting transcription: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting transcription: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _playbackTimer?.cancel();
    _audioPlayer.closePlayer();
    _textEditingController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          'Transcription Service',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isTranscribed) ...[
            IconButton(
              icon: Icon(
                _isEditing ? Icons.save : Icons.edit,
                color: Colors.white,
              ),
              onPressed: _toggleEditMode,
              tooltip: _isEditing ? 'Save' : 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.file_download, color: Colors.white),
              onPressed: _exportTranscription,
              tooltip: 'Export',
            ),
          ],
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildAudioPlayer(isDarkMode, themeProvider),
            
            if (!_isTranscribed && !_isProcessing)
              _buildLanguageSelector(isDarkMode, themeProvider),
            
            Expanded(
              child: _isProcessing
                  ? _buildProcessingIndicator(isDarkMode, themeProvider)
                  : _isTranscribed
                      ? _buildTranscriptionContent(isDarkMode, themeProvider)
                      : _buildEmptyState(isDarkMode, themeProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer(bool isDarkMode, ThemeProvider themeProvider) {
    final fileName = widget.audioFilePath.isNotEmpty 
        ? widget.audioFilePath.split('/').last
        : 'No file selected';
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.9),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeProvider.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.mic,
                  color: themeProvider.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: themeProvider.titleMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _audioDuration > 0 
                          ? 'Duration: ${_formatDuration(_audioDuration)}'
                          : 'Loading duration...',
                      style: themeProvider.bodySmall.copyWith(
                        color: themeProvider.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (_audioDuration > 0)
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: themeProvider.accentColor,
                    size: 36,
                  ),
                  onPressed: _togglePlayback,
                ),
            ],
          ),
          if (_audioDuration > 0) ...[
            const SizedBox(height: 16),
            Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: themeProvider.accentColor,
                    inactiveTrackColor: themeProvider.accentColor.withOpacity(0.2),
                    thumbColor: themeProvider.accentColor,
                    overlayColor: themeProvider.accentColor.withOpacity(0.3),
                  ),
                  child: Slider(
                    value: _playbackPosition.toDouble(),
                    min: 0,
                    max: _audioDuration.toDouble(),
                    onChanged: (value) {
                      _seekToPosition(value.toInt());
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_playbackPosition),
                        style: themeProvider.bodySmall.copyWith(
                          color: themeProvider.secondaryTextColor,
                        ),
                      ),
                      Text(
                        _formatDuration(_audioDuration),
                        style: themeProvider.bodySmall.copyWith(
                          color: themeProvider.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(bool isDarkMode, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.9),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.language,
                color: themeProvider.secondaryIconColor,
              ),
              const SizedBox(width: 12),
              Text(
                'Transcription Language',
                style: themeProvider.titleMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _languages.map((language) {
              final isSelected = _selectedLanguage == language;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLanguage = language;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, 
                    vertical: 8
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? themeProvider.accentColor.withOpacity(isDarkMode ? 0.3 : 0.1)
                        : isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? themeProvider.accentColor 
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    language,
                    style: themeProvider.bodyMedium.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? themeProvider.accentColor
                          : isDarkMode
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingIndicator(bool isDarkMode, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.9),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.accentColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 2 * 3.14159),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value,
                  child: child,
                );
              },
              child: Icon(
                Icons.settings,
                color: themeProvider.accentColor,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Transcribing Audio',
            style: themeProvider.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few moments...',
            style: themeProvider.bodyMedium.copyWith(
              color: themeProvider.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 32),
          LinearProgressIndicator(
            value: _transcriptionProgress,
            backgroundColor: themeProvider.accentColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(themeProvider.accentColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          Text(
            '${(_transcriptionProgress * 100).toInt()}%',
            style: themeProvider.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: themeProvider.accentColor,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'CAIPO is using AI to convert your audio to text',
            style: themeProvider.bodyMedium.copyWith(
              fontStyle: FontStyle.italic,
              color: themeProvider.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionContent(bool isDarkMode, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.9),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.text_fields,
                  color: themeProvider.secondaryIconColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Transcription',
                  style: themeProvider.titleMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: themeProvider.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: themeProvider.accentColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Complete',
                        style: themeProvider.bodySmall.copyWith(
                          color: themeProvider.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isEditing
                ? _buildEditableText(isDarkMode, themeProvider)
                : _buildTranscriptionText(isDarkMode, themeProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.9),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.text_fields,
            size: 64,
            color: themeProvider.secondaryIconColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Ready to Transcribe',
            style: themeProvider.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Click "Start Transcription" below to convert your audio file to text using CAIPO\'s advanced AI.',
            style: themeProvider.bodyMedium.copyWith(
              color: themeProvider.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(
            'Transcription Features:',
            style: themeProvider.titleMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.timer,
            title: 'Timestamps',
            description: 'Navigate to specific points in your audio',
            themeProvider: themeProvider,
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.api,
            title: 'AI-Powered Accuracy',
            description: 'Advanced speech recognition for better results',
            themeProvider: themeProvider,
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.edit,
            title: 'Edit & Export',
            description: 'Modify transcriptions and save them',
            themeProvider: themeProvider,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required ThemeProvider themeProvider,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeProvider.accentColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: themeProvider.accentColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: themeProvider.titleMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: themeProvider.bodySmall.copyWith(
                  color: themeProvider.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableText(bool isDarkMode, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _textEditingController,
        maxLines: null,
        expands: true,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        style: themeProvider.bodyLarge,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: themeProvider.accentColor,
              width: 2,
            ),
          ),
          hintText: 'Edit transcription here...',
          contentPadding: const EdgeInsets.all(16),
          filled: true,
          fillColor: isDarkMode ? Colors.black12 : Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildTranscriptionText(bool isDarkMode, ThemeProvider themeProvider) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _segments.length,
        itemBuilder: (context, index) {
          final segment = _segments[index];
          final isCurrentSegment = _isPlaying && 
              _playbackPosition >= segment['start'] && 
              _playbackPosition <= segment['end'];
          
          final double confidence = segment['confidence'] as double;
          Color confidenceColor;
          if (confidence > 0.9) {
            confidenceColor = Colors.green;
          } else if (confidence > 0.8) {
            confidenceColor = Colors.amber;
          } else {
            confidenceColor = Colors.orange;
          }
          
          return GestureDetector(
            onTap: () {
              _seekToPosition(segment['start']);
              if (!_isPlaying) {
                _togglePlayback();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentSegment
                    ? themeProvider.accentColor.withOpacity(0.1)
                    : isDarkMode
                        ? Colors.black12
                        : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrentSegment
                      ? themeProvider.accentColor
                      : isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                  width: isCurrentSegment ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _formatDuration(segment['start']),
                          style: themeProvider.bodySmall.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: confidenceColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: confidenceColor,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(confidence * 100).toInt()}%',
                              style: themeProvider.bodySmall.copyWith(
                                color: confidenceColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.play_circle_outline,
                          color: themeProvider.secondaryIconColor,
                          size: 16,
                        ),
                        onPressed: () {
                          _seekToPosition(segment['start']);
                          if (!_isPlaying) {
                            _togglePlayback();
                          }
                        },
                        tooltip: 'Play from here',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    segment['text'] as String,
                    style: themeProvider.bodyLarge.copyWith(
                      fontWeight: isCurrentSegment ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 