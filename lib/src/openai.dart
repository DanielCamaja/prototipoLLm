import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pruebatecnnica/src/enviroment.dart';

class OpenAIClient {
  final String openAiKey;
  final Dio _dio = Dio();
  OpenAIClient(this.openAiKey);

  Future<String> createChatCompletion({required List<Map<String, String>> messages, double temperature = 0.0, int maxTokens = 512}) async {
    final body = {
      'model': Enverioment.openAiModel,
      'messages': messages,
      'temperature': temperature,
      'max_tokens': maxTokens,
    };
    final res = await _dio.post(Enverioment.openAiApiUrl,
        options: Options(headers: {'Authorization': 'Bearer $openAiKey', 'Content-Type': 'application/json'}),
        data: json.encode(body));
    if (res.statusCode == 200) {
      final data = res.data;
      // Navegar al formato de respuesta -> choices[0].message.content
      final choice = data['choices'] != null && data['choices'].isNotEmpty ? data['choices'][0] : null;
      final message = choice != null && choice['message'] != null ? choice['message']['content'] as String? : null;
      return message ?? 'No response';
    }
    throw Exception('OpenAI error ${res.statusCode}');
  }
}