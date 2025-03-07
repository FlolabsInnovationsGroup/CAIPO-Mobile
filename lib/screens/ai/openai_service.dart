import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  final String apiUrl = "https://api.openai.com/v1/chat/completions";
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
}
