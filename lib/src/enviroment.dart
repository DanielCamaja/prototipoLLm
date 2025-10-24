import 'package:dio/dio.dart';

abstract class Enverioment {
  // =========================
static const String baseUrl = 'https://test.controldepropiedades.com/api/propiedades/miraiz';
static const String apiKey = '';
// OpenAI: PARA MVP, puedes guardar tu API-KEY en flutter_secure_storage o preferible en un backend
static const String openAiApiUrl = 'https://api.openai.com/v1/chat/completions';
// modelo de ejemplo (ajusta según acceso):
static const String openAiModel = 'gpt-4o-mini';
}