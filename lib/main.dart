import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pruebatecnnica/src/datamodel.dart';
import 'package:pruebatecnnica/src/network.dart';
import 'package:pruebatecnnica/src/openai.dart';
import 'package:pruebatecnnica/src/pages/chat.dart';
import 'package:pruebatecnnica/src/provider/dataprovider.dart'
    hide propiedadesProvider;
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('interactions');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MVP Propiedades',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ResponsiveHomePage(),
    );
  }
}

class ResponsiveHomePage extends StatefulWidget {
  const ResponsiveHomePage({Key? key}) : super(key: key);

  @override
  State<ResponsiveHomePage> createState() => _ResponsiveHomePageState();
}

class _ResponsiveHomePageState extends State<ResponsiveHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 800;
      if (isMobile) {
        return Scaffold(
          appBar: AppBar(title: const Text('MVP Propiedades')),
          body: _selectedIndex == 0 ? const CatalogPane() : ChatPane(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Catálogo'),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
            ],
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(title: const Text('MVP Propiedades')),
          body: Row(
            children: [
              Expanded(child: const CatalogPane()),
              VerticalDivider(width: 1),
              SizedBox(width: 400, child: ChatPane()),
            ],
          ),
        );
      }
    });
  }
}

bool isDesktop() {
  if (kIsWeb) return true; // web
  return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}


class CatalogPane extends ConsumerWidget {
  const CatalogPane({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);

    return catalog.when(
      data: (props) => ListView.builder(
        itemCount: props.length,
        itemBuilder: (context, index) {
          final p = props[index];
          return GestureDetector(
            onTap: () => _onPropertyTap(context, ref, p),
            child: Card(
              margin: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //el web no funciona por que el servidor no aprueba por los CORS
                  CarouselSlider(
                    options: CarouselOptions(height: 250.0, viewportFraction: 1.0, enlargeCenterPage: true),
                    items: p.imagenes.map((img) => Image.network(img.url, fit: BoxFit.cover, width: double.infinity)).toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${p.titulo} - Q${p.precio}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

Future<String> callLLM(List<Map<String, String>> messages) async {
  if (isDesktop()) {
    // Usa proxy Node.js
    final dio = Dio();
    final resp = await dio.post(
      'http://localhost:3000/chat',
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

  void _onPropertyTap(BuildContext context, WidgetRef ref, Propiedad p) async {
    final prov = ref.read(interactionsProvider.notifier);
    final uuid = const Uuid();

    final sysMsg = ChatMessage(
      id: uuid.v4(),
      role: 'system',
      content: _buildPropertyContext(p),
      createdAt: DateTime.now(),
      propiedadId: p.id.toString(),
    );
    prov.add(sysMsg);

    final starter = ChatMessage(
      id: uuid.v4(),
      role: 'user',
      content: 'Hola, quiero preguntar sobre esta propiedad (la adjunto como contexto).',
      createdAt: DateTime.now(),
      propiedadId: p.id.toString(),
    );
    prov.add(starter);

    // Cambiar a pantalla de chat si es móvil
    if (MediaQuery.of(context).size.width < 800) {
      final parentState = context.findAncestorStateOfType<_ResponsiveHomePageState>();
      parentState?.setState(() => parentState._selectedIndex = 1);
    }

    try {
  final messagesForApi = [
    {'role': 'system', 'content': 'Eres un asistente experto en bienes raíces. Responde solo con información de los datos provistos y no inventes.'},
    {'role': 'system', 'content': sysMsg.content},
    {'role': 'user', 'content': starter.content},
  ];

  final resp = await callLLM(messagesForApi);

  final assistant = ChatMessage(
    id: uuid.v4(),
    role: 'assistant',
    content: resp,
    createdAt: DateTime.now(),
    propiedadId: p.id.toString(),
  );
  prov.add(assistant);
} catch (e) {
  final assistant = ChatMessage(
    id: uuid.v4(),
    role: 'assistant',
    content: 'Error al contactar LLM: ${e.toString()}',
    createdAt: DateTime.now(),
    propiedadId: p.id.toString(),
  );
  prov.add(assistant);
}

  }

  //ayuda para el conecto de chatgpt
  String _buildPropertyContext(Propiedad p) {
    final b = StringBuffer();
    b.writeln('PROPIEDAD: ${p.titulo}');
    b.writeln('DESCRIPCION: ${p.descripcion}');
    b.writeln('PRECIO: ${p.precio}');

    final raw = p.raw;
    if (raw['area'] != null) b.writeln('AREA: ${raw['area']}');
    if (raw['tipo'] != null) b.writeln('TIPO: ${raw['tipo']}');
    if (raw['clase_tipo'] != null)
      b.writeln('CLASE TIPO: ${raw['clase_tipo']}');
    if (raw['largo'] != null && raw['ancho'] != null)
      b.writeln('DIMENSIONES: ${raw['largo']} x ${raw['ancho']}');
    if (raw['caracteristicas'] != null)
      b.writeln('CARACTERISTICAS: ${raw['caracteristicas']}');
    if (raw['descripcion_corta'] != null)
      b.writeln('DESCRIPCION CORTA: ${raw['descripcion_corta']}');
    if (raw['proyecto'] != null) {
      final pjt = raw['proyecto'];
      b.writeln(
        'PROYECTO: ${pjt['nombre_proyecto']}, DIRECCION: ${pjt['direccion']}, UBICACION: ${pjt['ubicacion']}',
      );
    }

    return b.toString();
  }
}

Future<OpenAIClient> getClient() async {
  // Hardcode solo para MVP
  final key =
      '';
  return OpenAIClient(key);
}

