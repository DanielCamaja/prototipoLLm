
import 'package:pruebatecnnica/src/data/propiedad_repository_mock.dart';
import 'package:pruebatecnnica/src/data/propiedad_repository_remote.dart';
import 'package:pruebatecnnica/src/datamodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pruebatecnnica/src/datamodel.dart';
import 'package:pruebatecnnica/src/enviroment.dart';

abstract class PropiedadRepository {
  Future<List<Propiedad>> obtenerPropiedades();
}

// 🔧 Cambia esto a `false` cuando quieras usar la API real
const useMockData = false;

final dioProvider = Provider<Dio>((ref) {


  final d = Dio(BaseOptions(baseUrl: Enverioment.baseUrl, connectTimeout: Duration(seconds: 10000)));
  d.options.headers.addAll({'x-api-key': Enverioment.apiKey, 'Accept': 'application/json'});
  return d;
});

final propiedadRepositoryProvider = Provider<PropiedadRepository>((ref) {
  if (useMockData) {
    return MockPropiedadRepository();
  } else {
    final dio = ref.watch(dioProvider);
    return RemotePropiedadRepository(dio);
  }
});

final propiedadesProvider = FutureProvider.autoDispose<List<Propiedad>>((ref) async {
  final repo = ref.watch(propiedadRepositoryProvider);
  return repo.obtenerPropiedades();
});
