import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pruebatecnnica/main.dart';
import 'package:pruebatecnnica/src/datamodel.dart';
import 'package:pruebatecnnica/src/pages/metric.dart';
import 'package:pruebatecnnica/src/provider/dataprovider.dart';
import 'package:uuid/uuid.dart';

class ChatPane extends ConsumerStatefulWidget {
  @override
  ConsumerState<ChatPane> createState() => _ChatPaneState();
}

class _ChatPaneState extends ConsumerState<ChatPane> {
  final _controller = TextEditingController();
  bool isDesktop() {
  if (kIsWeb) return true;
  return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}

Future<String> callLLM(List<Map<String, String>> messages) async {
  if (isDesktop()) {
    // Usa proxy Node.js
    final dio = Dio();
    final resp = await dio.post(
      'http://192.168.3.117:3000/chat',
      data: {
        'messages': messages,
        'model': 'gpt-3.5-turbo',
        'temperature': 0.0,
        'max_tokens': 700,
      },
    );
    return resp.data['text'] ?? 'Error: no response';
  } else {
    // Móvil: conexión directa
    final client = await getClient();
    return await client.createChatCompletion(
      messages: messages,
      temperature: 0.0,
      maxTokens: 700,
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(interactionsProvider);
    final notifier = ref.read(interactionsProvider.notifier);
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: false,
            padding: const EdgeInsets.all(8),
            itemCount: messages.length,
            itemBuilder: (context, i) {
              final m = messages[i];
              final isUser = m.role == 'user';
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                alignment: isUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Card(
                    color: isUser ? Colors.blue[50] : Colors.grey[100],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(m.content),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Quick metrics row
        MetricsBar(messages: messages),
        // Input
        SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu pregunta...',
                    ),
                  ),
                ),
              ),
              IconButton(
  icon: const Icon(Icons.send),
  onPressed: () async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final uuid = const Uuid();
    final userMsg = ChatMessage(
      id: uuid.v4(),
      role: 'user',
      content: text,
      createdAt: DateTime.now(),
    );
    notifier.add(userMsg);
    _controller.clear();

    try {
      // Recolectar contexto: toma los últimos mensajes y convertir a formato del API
      final lastSystem = ref
          .read(interactionsProvider)
          .lastWhere(
            (m) => m.role == 'system',
            orElse: () => ChatMessage(
              id: 'none',
              role: 'system',
              content: '',
              createdAt: DateTime.now(),
            ),
          );
      final messagesForApi = <Map<String, String>>[];
      // system prompt para reducir alucinaciones
      messagesForApi.add({
        'role': 'system',
        'content':
            'Eres un asistente experto en bienes raíces. Responde con la información estrictamente soportada por los datos provistos. Si la respuesta no puede inferirse, di "No tengo suficiente información" y solicita aclaraciones. No inventes hechos.',
      });
      if (lastSystem.content.isNotEmpty)
        messagesForApi.add({
          'role': 'system',
          'content': 'Contexto de propiedad:' + lastSystem.content,
        });
      // add mensaje del usuario
      messagesForApi.add({'role': 'user', 'content': text});

      // ✅ Llamada al LLM detectando plataforma
      final resp = await callLLM(messagesForApi);

      final assistant = ChatMessage(
        id: uuid.v4(),
        role: 'assistant',
        content: resp,
        createdAt: DateTime.now(),
      );
      notifier.add(assistant);
    } catch (e) {
      final uuid = const Uuid();
      notifier.add(
        ChatMessage(
          id: uuid.v4(),
          role: 'assistant',
          content: 'Error al contactar LLM: ${e.toString()}',
          createdAt: DateTime.now(),
        ),
      );
    }
  },
),

            ],
          ),
        ),
      ],
    );
  }
}

