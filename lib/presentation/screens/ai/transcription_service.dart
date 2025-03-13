import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  double _progress = 0.0;
  late StreamSubscription<double> _progressSubscription;

  @override
  void initState() {
    super.initState();
    _setupProgressListener();
    _fetchTranscription();
  }

  void _setupProgressListener() {
    _progressSubscription = TranscriptionService().progressStream.listen((progress) {
      setState(() {
        _progress = progress;
      });
    });
  }

  @override
  void dispose() {
    _progressSubscription.cancel();
    super.dispose();
  }

  Future<void> _fetchTranscription() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await TranscriptionService().transcribeAudio(
        audioFilePath: widget.audioFilePath,
      );
      setState(() {
        _transcription = result['transcription'] as String;
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
            if (_isLoading) LinearProgressIndicator(value: _progress),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(value: _progress),
                          const SizedBox(height: 16),
                          Text('${(_progress * 100).toStringAsFixed(1)}%'),
                        ],
                      ),
                    )
                  : _hasError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Failed to transcribe audio.",
                                  style: TextStyle(color: Colors.red)),
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

/// A service for handling audio transcription using AI
class TranscriptionService {
  static final TranscriptionService _instance = TranscriptionService._internal();
  
  // Factory constructor to return the same instance
  factory TranscriptionService() {
    return _instance;
  }
  
  TranscriptionService._internal();
  
  /// Cache for storing transcriptions to avoid re-processing
  final Map<String, Map<String, dynamic>> _transcriptionCache = {};
  
  /// Stream controller for tracking transcription progress
  final StreamController<double> _progressController = StreamController<double>.broadcast();
  
  /// Get the stream of transcription progress (0.0 to 1.0)
  Stream<double> get progressStream => _progressController.stream;
  
  /// Transcribe an audio file
  /// 
  /// Parameters:
  /// - [audioFilePath]: Path to the audio file to transcribe
  /// - [language]: Language code (e.g., 'en-US', 'es', 'fr')
  /// - [useCache]: Whether to use cached results if available
  /// 
  /// Returns a map containing:
  /// - transcription: The full text transcription
  /// - segments: List of segments with timing information
  /// - confidence: Overall confidence score
  /// - language: Detected or specified language
  Future<Map<String, dynamic>> transcribeAudio({
    required String audioFilePath,
    String language = 'en-US',
    bool useCache = true,
  }) async {
    // Check cache first if enabled
    final fileKey = '$audioFilePath:$language';
    if (useCache && _transcriptionCache.containsKey(fileKey)) {
      return _transcriptionCache[fileKey]!;
    }
    
    // In a real implementation, this would connect to an API service
    // For demo purposes, we'll simulate the process
    
    // Simulate processing time
    final file = File(audioFilePath);
    final fileSize = await file.length();
    
    // Large files take longer to process
    final processingTime = Duration(milliseconds: 5000 + (fileSize ~/ 10000));
    final totalSteps = 100;
    
    // Simulate progress updates
    for (int i = 0; i < totalSteps; i++) {
      await Future.delayed(Duration(milliseconds: processingTime.inMilliseconds ~/ totalSteps));
      _progressController.add(i / totalSteps);
    }
    
    // Generate sample transcription data
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Create a simulated response
    final result = await _generateSimulatedTranscription(
      audioFilePath: audioFilePath,
      language: language,
    );
    
    // Cache the result
    _transcriptionCache[fileKey] = result;
    
    // Artificial delay to show 100% progress
    await Future.delayed(const Duration(milliseconds: 200));
    _progressController.add(1.0);
    
    return result;
  }
  
  /// Clear the transcription cache
  Future<void> clearCache() async {
    _transcriptionCache.clear();
    
    // Also clear any cached files
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('transcription_cache_keys');
    
    try {
      final cacheDir = await _getCacheDirectory();
      final cacheFiles = await cacheDir.list().where(
        (entity) => entity is File && entity.path.endsWith('.json')
      ).toList();
      
      for (final file in cacheFiles) {
        if (file is File) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error clearing cache files: $e');
    }
  }
  
  /// Persist the cache to disk
  Future<void> persistCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKeys = _transcriptionCache.keys.toList();
      await prefs.setStringList('transcription_cache_keys', cacheKeys);
      
      final cacheDir = await _getCacheDirectory();
      
      // Save each transcription to a file
      for (final key in cacheKeys) {
        final data = _transcriptionCache[key]!;
        final file = File('${cacheDir.path}/${key.hashCode}.json');
        await file.writeAsString(jsonEncode(data));
      }
    } catch (e) {
      debugPrint('Error persisting cache: $e');
    }
  }
  
  /// Load the cache from disk
  Future<void> loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKeys = prefs.getStringList('transcription_cache_keys') ?? [];
      
      final cacheDir = await _getCacheDirectory();
      
      for (final key in cacheKeys) {
        final file = File('${cacheDir.path}/${key.hashCode}.json');
        if (await file.exists()) {
          final data = jsonDecode(await file.readAsString());
          _transcriptionCache[key] = Map<String, dynamic>.from(data);
        }
      }
    } catch (e) {
      debugPrint('Error loading cache: $e');
    }
  }
  
  /// Get the cache directory
  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/transcription_cache');
    
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    
    return cacheDir;
  }
  
  /// Generate a simulated transcription (for demo purposes)
  Future<Map<String, dynamic>> _generateSimulatedTranscription({
    required String audioFilePath,
    required String language,
  }) async {
    // Get the audio file duration for timing
    final audioDuration = await _getAudioDuration(audioFilePath);
    
    // For demo purposes, we'll generate a fixed transcription
    final text = '''
Hello and welcome to CAIPO. Today I wanted to record some thoughts about the new project we're working on. 

The app interface is coming along nicely, and I think the user experience improvements we've made will really enhance the overall usability. I'd like to focus on implementing the transcription service next, with advanced features like timestamps, speaker identification, and confidence scoring.

We should also consider adding export options for different file formats. Users might want to save transcriptions as text, Word documents, or even subtitles for videos.

Let's schedule a meeting for next Tuesday to review our progress and outline the next steps. I'll send out a calendar invite later today.

That's all for now, thanks for listening.
'''.trim();

    // Split into segments
    final words = text.split(' ');
    final segmentSize = words.length ~/ 6; // Divide into roughly 6 segments
    final List<Map<String, dynamic>> segments = [];
    
    for (int i = 0; i < words.length; i += segmentSize) {
      final end = i + segmentSize < words.length ? i + segmentSize : words.length;
      final segment = words.sublist(i, end).join(' ');
      
      // Generate a random confidence score between 0.75 and 1.0
      final confidence = 0.75 + (0.25 * (i / words.length));
      
      segments.add({
        'text': segment,
        'start': (i / words.length * audioDuration).toInt(),
        'end': (end / words.length * audioDuration).toInt(),
        'confidence': confidence,
      });
    }
    
    return {
      'transcription': text,
      'segments': segments,
      'confidence': 0.92,
      'language': language,
      'audioDuration': audioDuration,
    };
  }
  
  /// Get the duration of an audio file in milliseconds
  Future<int> _getAudioDuration(String filePath) async {
    // In a real implementation, you would use a proper audio plugin
    // For demo purposes, we'll return a fixed duration or estimated from file size
    try {
      final file = File(filePath);
      final fileSize = await file.length();
      
      // Roughly estimate duration based on file size
      // Assuming ~16KB per second for a typical audio file
      final estimatedDuration = (fileSize / 16000).round() * 1000;
      return estimatedDuration.clamp(10000, 120000);
    } catch (e) {
      // Return a default duration if file can't be read
      return 60000; // 1 minute
    }
  }
  
  /// Dispose of resources
  void dispose() {
    _progressController.close();
  }
}
