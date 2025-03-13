import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  final String apiUrl = "https://api.openai.com/v1/chat/completions";
  final String transcriptionUrl = "https://api.openai.com/v1/audio/transcriptions";
  final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  Future<String> queryOpenAI(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "gpt-4", // Use "gpt-3.5-turbo" if you want a cheaper option
          "messages": [
            {"role": "system", "content": "You are a helpful AI assistant."},
            {"role": "user", "content": userMessage},
          ],
          "max_tokens": 200,
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData["choices"][0]["message"]["content"].toString();
      } else {
        return "Error: ${response.statusCode}, ${response.body}";
      }
    } catch (e) {
      return "Failed to connect to OpenAI: $e";
    }
  }

  Future<String> transcribeAudio(String audioFilePath) async {
    try {
      final file = File(audioFilePath);
      final bytes = await file.readAsBytes();
      
      final request = http.MultipartRequest('POST', Uri.parse(transcriptionUrl))
        ..headers['Authorization'] = 'Bearer $apiKey'
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'audio.m4a',
          ),
        )
        ..fields['model'] = 'whisper-1';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['text'];
      } else {
        throw Exception('Failed to transcribe audio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error transcribing audio: $e');
    }
  }
}
