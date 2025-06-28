import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/server_config.dart';

class ApiService {
  late final ServerConfig serverConfig;

  ApiService({required this.serverConfig});

  Future<String> sendMessage({
    required String model,
    required List<ChatMessage> messages,
    int timeoutSeconds = 300,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${serverConfig.baseUrl}/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "model": model,
              "messages": messages
                  .map(
                    (m) => {
                      "role": m.isUser ? "user" : "assistant",
                      "content": m.text,
                    },
                  )
                  .toList(),
              "stream": false,
            }),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['message']['content'];
      } else {
        throw Exception('${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse('${serverConfig.baseUrl}'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
