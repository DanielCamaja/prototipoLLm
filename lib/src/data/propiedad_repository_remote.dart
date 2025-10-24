// archivo: propiedad_repository_remote.dart
import 'package:dio/dio.dart';
import 'package:pruebatecnnica/src/datamodel.dart';
import 'package:pruebatecnnica/src/network.dart';

class RemotePropiedadRepository implements PropiedadRepository {
  final Dio dio;

  RemotePropiedadRepository(this.dio);

  @override
  Future<List<Propiedad>> obtenerPropiedades() async {
    final res = await dio.get('');
    if (res.statusCode != 200) throw Exception('Error ${res.statusCode}');
    final data = res.data;
    if (data is Map && data['success'] == true && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => Propiedad.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Formato de respuesta inesperado');
  }
}
