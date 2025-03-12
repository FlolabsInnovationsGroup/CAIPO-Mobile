import 'package:flutter/material.dart';
import '../ai/openai_service.dart'; // AI service for transcription

class TranscriptionScreen extends StatefulWidget {
  final String audioFilePath;

  const TranscriptionScreen({super.key, required this.audioFilePath});

  @override
  TranscriptionScreenState createState() => TranscriptionScreenState();
}

class TranscriptionScreenState extends State<TranscriptionScreen> {
  String _transcription = "Processing...";
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchTranscription();
  }

  Future<void> _fetchTranscription() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      String response = await OpenAIService().transcribeAudio(widget.audioFilePath);
      setState(() {
        _transcription = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _transcription = "Error processing transcription.";
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Transcription")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Transcript:",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _hasError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Failed to transcribe audio.", style: TextStyle(color: Colors.red)),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _fetchTranscription,
                                child: Text("Retry"),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Text(
                            _transcription,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
