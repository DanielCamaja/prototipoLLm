// archivo: propiedad_repository_mock.dart
import 'dart:convert';
import 'package:pruebatecnnica/src/datamodel.dart';
import 'package:pruebatecnnica/src/network.dart';

class MockPropiedadRepository implements PropiedadRepository {
  @override
  Future<List<Propiedad>> obtenerPropiedades() async {
    // Puedes mover esto a un archivo JSON separado y cargarlo con rootBundle
    const jsonString = '''
    {
      "success": true,
      "data": [
        {
          "id": 942,
          "propiedad": "A-1",
          "area": 126,
          "tipo": "Lote",
          "clase_tipo": "Esquina",
          "modelo": "120.00",
          "ubicacion": "Manzana A",
          "estado": "disponible",
          "fin_de_obra": "2025-12-01 00:00:00",
          "precio": 190000,
          "precio_sugerido": 223125,
          "proyectos_id": 6,
          "largo": 7,
          "ancho": 18,
          "año": 2025,
          "titulo": "Precioso Lote de 7x16, ubicado en proyecto Legado Cobán",
          "descripcion": "Precioso lote de 126 m2 ubicado en Legado Cobán...",
          "descripcion_corta": "Precioso lote de 126 m2...",
          "caracteristicas": "Calles pavimentadas, Drenajes, Seguridad 24/7",
          "latitud": 14.4236,
          "longitud": -90.4673,
          "proyecto": {
                "id": 6,
                "nombre_proyecto": "Club Del Bosque",
                "direccion": "1234 Test direccion",
                "aprobacion12cuotas": null,
                "tipo": "Lotes",
                "ubicacion": "Jalapa",
                "estado": "Venta",
                "created_at": "2025-02-14T11:31:59.000000Z",
                "updated_at": "2025-02-14T12:12:52.000000Z"
            },
          "imagenes": [
                {
                    "tipo": "logo",
                    "url": "https://test.controldepropiedades.com/storage/proyectos/test-final/logo/wrOnUCTDPC5uTb2yBgSAFVhLV70mCLCzUtbKLXHR.png",
                    "formato": "imagen"
                },
                {
                    "tipo": "masterplan",
                    "url": "https://test.controldepropiedades.com/storage/proyectos/test-final/masterplan/fNfv8jQkyFEgKWtE1JzvCFWGuaIIgyTAkH3Q7hKj.png",
                    "formato": "imagen"
                },
                {
                    "tipo": "ingreso",
                    "url": "https://test.controldepropiedades.com/storage/proyectos/test-final/ingreso/xizx3GNZxWFJdpWgEXPUEO76eYBmagW8mYWZ66jC.jpg",
                    "formato": "imagen"
                },
                {
                    "tipo": "panoramica",
                    "url": "https://test.controldepropiedades.com/storage/proyectos/test-final/panoramica/qJGFzLkJ6ZcYZZnl5xm03hC2AyhvxM0L1CV0Qp45.jpg",
                    "formato": "imagen"
                },
                {
                    "tipo": "promocional1",
                    "url": "https://test.controldepropiedades.com/storage/proyectos/test-final/promocional1/j7NdrFt6JXANSjaEUdPUPzMZO8rVT8fLndfxR1Qo.jpg",
                    "formato": "imagen"
                },
                {
                    "tipo": "promocional2",
                    "url": "https://test.controldepropiedades.com/storage/proyectos/test-final/promocional2/D6NwQHTaYl62KNLphQGIQE0fvZKfVSFVoRipXisi.png",
                    "formato": "imagen"
                },
                {
                    "tipo": "promocional3",
                    "url": "https://test.controldepropiedades.com/storage/proyectos/test-final/promocional3/2E6uWWXl4V66iRsTgo92sTbvN8K3BMq1E3CYoNZC.png",
                    "formato": "imagen"
                }
            ]
        }
      ]
    }
    ''';

    final data = jsonDecode(jsonString);

    if (data['success'] == true && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => Propiedad.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Formato inválido');
  }
}
