class Proyecto {
  final int id;
  final String nombreProyecto;
  final String direccion;
  final String tipo;
  final String ubicacion;

  Proyecto({
    required this.id,
    required this.nombreProyecto,
    required this.direccion,
    required this.tipo,
    required this.ubicacion,
  });

  factory Proyecto.fromJson(Map<String, dynamic> json) => Proyecto(
        id: json['id'] as int,
        nombreProyecto: json['nombre_proyecto'] as String? ?? '',
        direccion: json['direccion'] as String? ?? '',
        tipo: json['tipo'] as String? ?? '',
        ubicacion: json['ubicacion'] as String? ?? '',
      );
}

class Imagen {
  final String tipo;
  final String url;
  final String formato;

  Imagen({required this.tipo, required this.url, required this.formato});

  factory Imagen.fromJson(Map<String, dynamic> json) => Imagen(
        tipo: json['tipo'] as String? ?? '',
        url: json['url'] as String? ?? '',
        formato: json['formato'] as String? ?? '',
      );
}

class Propiedad {
  final int id;
  final String propiedad;
  final double area;
  final String tipo;
  final String claseTipo;
  final String modelo;
  final String ubicacion;
  final String estado;
  final DateTime? finDeObra;
  final double precio;
  final double? precioSugerido;
  final Proyecto? proyecto;
  final List<Imagen> imagenes;
  final double? latitud;
  final double? longitud;
  final String titulo;
  final String descripcion;
  final Map<String, dynamic> raw;

  Propiedad({
    required this.id,
    required this.propiedad,
    required this.area,
    required this.tipo,
    required this.claseTipo,
    required this.modelo,
    required this.ubicacion,
    required this.estado,
    required this.finDeObra,
    required this.precio,
    required this.precioSugerido,
    required this.proyecto,
    required this.imagenes,
    required this.latitud,
    required this.longitud,
    required this.titulo,
    required this.descripcion,
    required this.raw
  });

  factory Propiedad.fromJson(Map<String, dynamic> json) => Propiedad(
        id: json['id'] as int,
        propiedad: json['propiedad'] as String? ?? '',
        area: (json['area'] is num) ? (json['area'] as num).toDouble() : 0.0,
        tipo: json['tipo'] as String? ?? '',
        claseTipo: json['clase_tipo'] as String? ?? '',
        modelo: json['modelo'] as String? ?? '',
        ubicacion: json['ubicacion'] as String? ?? '',
        estado: json['estado'] as String? ?? '',
        finDeObra: json['fin_de_obra'] != null ? DateTime.tryParse(json['fin_de_obra']) : null,
        precio: (json['precio'] is num) ? (json['precio'] as num).toDouble() : 0.0,
        precioSugerido: (json['precio_sugerido'] is num) ? (json['precio_sugerido'] as num).toDouble() : null,
        proyecto: json['proyecto'] != null ? Proyecto.fromJson(json['proyecto']) : null,
        imagenes: (json['imagenes'] as List<dynamic>?)?.map((e) => Imagen.fromJson(e as Map<String, dynamic>)).toList() ?? [],
        latitud: (json['latitud'] is num) ? (json['latitud'] as num).toDouble() : null,
        longitud: (json['longitud'] is num) ? (json['longitud'] as num).toDouble() : null,
        titulo: json['titulo'] as String? ?? '',
        descripcion: json['descripcion'] as String? ?? '',
        raw: json,
      );
}

class ChatMessage {
  final String id;
  final String role; // "user" | "assistant" | "system"
  final String content;
  final DateTime createdAt;
  final String? propiedadId; // opcional: ID de la propiedad relacionada
  ChatMessage({required this.id, required this.role, required this.content, required this.createdAt, this.propiedadId});
  Map<String, dynamic> toJson() => {'id': id, 'role': role, 'content': content, 'createdAt': createdAt.toIso8601String(), 'propiedadId': propiedadId};
  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'],
        role: j['role'],
        content: j['content'],
        createdAt: DateTime.parse(j['createdAt']),
        propiedadId: j['propiedadId'],
      );
}