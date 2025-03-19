import 'package:flutter/material.dart';
import 'base_dynamic_screen.dart';

class TranscriptionScreen extends BaseDynamicScreen {
  const TranscriptionScreen({
    super.key,
    required super.command,
    super.commandData,
  });

  @override
  TranscriptionScreenState createState() => TranscriptionScreenState();
}

class TranscriptionScreenState
    extends BaseDynamicScreenState<TranscriptionScreen> {
  final bool _isTranscribing = false;
  final String _transcribedText = '';
  bool _hasAudioFile = false;
  Duration _audioPosition = Duration.zero;
  final Duration _audioDuration =
      const Duration(minutes: 2, seconds: 30); // Mock duration

  @override
  void setupBackgroundAnimation() {
    backgroundStartAnimation = ColorTween(
      begin: const Color(0xFF2196F3), // Blue for transcription
      end: const Color(0xFF64B5F6),
    ).animate(backgroundController);

    backgroundEndAnimation = ColorTween(
      begin: const Color(0xFF64B5F6),
      end: const Color(0xFF2196F3),
    ).animate(backgroundController);
  }

  Widget _buildAudioPlayer() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  onPressed: () {
                    // Implement replay 10 seconds
                  },
                ),
                IconButton(
                  icon: Icon(_hasAudioFile ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    setState(() {
                      _hasAudioFile = !_hasAudioFile;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  onPressed: () {
                    // Implement forward 10 seconds
                  },
                ),
              ],
            ),
            Slider(
              value: _audioPosition.inSeconds.toDouble(),
              max: _audioDuration.inSeconds.toDouble(),
              onChanged: (value) {
                setState(() {
                  _audioPosition = Duration(seconds: value.toInt());
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_audioPosition),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  _formatDuration(_audioDuration),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget buildScreenContent(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'Transcription',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_hasAudioFile) ...[
                      _buildAudioPlayer(),
                      const SizedBox(height: 24),
                    ],
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Transcription',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_isTranscribing)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_transcribedText.isEmpty)
                              const Center(
                                child: Text(
                                  'Transcribed text will appear here',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            else
                              Text(_transcribedText),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Implement audio file selection
                          },
                          icon: const Icon(Icons.audio_file),
                          label: const Text('Select Audio'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Implement video file selection
                          },
                          icon: const Icon(Icons.video_file),
                          label: const Text('Select Video'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
