import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  RecordingScreenState createState() => RecordingScreenState();
}

class RecordingScreenState extends State<RecordingScreen> {
  FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  bool _isRecording = false;
  String? _audioFilePath;
  File? _videoFile;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _audioPlayer.openPlayer();
  }

  Future<void> _initRecorder() async {
    await _audioRecorder.openRecorder();
  }

  Future<void> _startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _audioRecorder.startRecorder(toFile: path);
    setState(() {
      _isRecording = true;
      _audioFilePath = path;
    });
  }

  Future<void> _stopRecording() async {
    await _audioRecorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _audioRecorder.closeRecorder();
    _audioPlayer.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Record Audio/Video")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Record your voice or video",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Audio Recording Section
            ElevatedButton.icon(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? "Stop Recording" : "Start Audio Recording"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            ),
            if (_audioFilePath != null) ...[
              const SizedBox(height: 10),
              Text("Audio saved: ${_audioFilePath!.split('/').last}"),
              IconButton(
                icon: const Icon(Icons.play_arrow, size: 30),
                onPressed: () {
                  _audioPlayer.startPlayer(fromURI: _audioFilePath);
                },
              ),
            ],
            const SizedBox(height: 30),

            // Video Recording Section
            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.videocam),
              label: const Text("Record Video"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
            if (_videoFile != null) ...[
              const SizedBox(height: 10),
              Text("Video saved: ${_videoFile!.path.split('/').last}"),
              IconButton(
                icon: const Icon(Icons.play_circle_fill, size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlaybackScreen(videoFile: _videoFile!),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Separate Screen for Video Playback
class VideoPlaybackScreen extends StatelessWidget {
  final File videoFile;
  const VideoPlaybackScreen({super.key, required this.videoFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Play Video")),
      body: Center(
        child: Text("Video playback feature to be implemented"),
      ),
    );
  }
}
