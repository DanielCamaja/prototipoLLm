import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';
import 'package:pruebatecnnica/src/datamodel.dart';
import 'package:pruebatecnnica/src/enviroment.dart';
import 'package:pruebatecnnica/src/network.dart';

final dioProvider = Provider<Dio>((ref) {
  final d = Dio(BaseOptions(baseUrl: Enverioment.baseUrl, connectTimeout: Duration(seconds: 10000)));
  d.options.headers.addAll({
    'API-KEY': Enverioment.apiKey,
    'Accept': 'application/json',
  });
  return d;
});

final propiedadesProvider = FutureProvider.autoDispose<List<Propiedad>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('');
  if (res.statusCode != 200) throw Exception('Error ${res.statusCode}');
  final data = res.data;
  if (data is Map && data['success'] == true && data['data'] is List) {
    return (data['data'] as List).map((e) => Propiedad.fromJson(e as Map<String, dynamic>)).toList();
  }
  throw Exception('Formato inesperado');
});

// Interactions stored locally (simple box)
final interactionsProvider = StateNotifierProvider<InteractionsNotifier, List<ChatMessage>>((ref) {
  return InteractionsNotifier();
});

class InteractionsNotifier extends StateNotifier<List<ChatMessage>> {
  final Box _box = Hive.box('interactions');
  InteractionsNotifier() : super([]) {
    _load();
  }

  void _load() {
    final raw = _box.get('messages');
    if (raw != null) {
      final list = (json.decode(raw) as List).map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
      state = list;
    }
  }

  void _save() => _box.put('messages', json.encode(state.map((e) => e.toJson()).toList()));

  void add(ChatMessage msg) {
    state = [...state, msg];
    _save();
  }

  void clear() {
    state = [];
    _save();
  }
}
final catalogProvider = FutureProvider<List<Propiedad>>((ref) async {
  final repo = ref.watch(propiedadRepositoryProvider);
  return repo.obtenerPropiedades();
});
