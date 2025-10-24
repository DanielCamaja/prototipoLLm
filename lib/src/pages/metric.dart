import 'package:flutter/material.dart';
import 'package:pruebatecnnica/src/datamodel.dart';

class MetricsBar extends StatelessWidget {
  final List<ChatMessage> messages;
  const MetricsBar({required this.messages});
  @override
  Widget build(BuildContext context) {
    final total = messages.length;
    final pending = messages.where((m) => m.role == 'user').length;
    final answered = messages.where((m) => m.role == 'assistant').length;
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text('Total: $total'),
          const SizedBox(width: 12),
          Text('Pendientes: $pending'),
          const SizedBox(width: 12),
          Text('Respondidas: $answered'),
        ],
      ),
    );
  }
}