import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../domain/entities/plant_photo.dart';
import '../../domain/repositories/image_analyzer.dart';
import '../models/finding_model.dart';

abstract class ImageAnalysisRemoteDataSource {
  // 1. Actualizamos la interfaz para recibir los datos del contexto
  Future<List<FindingModel>> analyze(
    PlantPhoto photo, {
    List<String>? sintomas,
    String? suelo,
    String? luz,
  });
}

class HttpImageAnalysisDataSource implements ImageAnalysisRemoteDataSource {
  HttpImageAnalysisDataSource({
    required this.client,
    required String baseUrl,
    this.timeout = const Duration(seconds: 20),
    this.maxBytes = 10 * 1024 * 1024,
  }) : baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

  final http.Client client;
  final String baseUrl;
  final Duration timeout;
  final int maxBytes;

  @override
  Future<List<FindingModel>> analyze(
    PlantPhoto photo, {
    List<String>? sintomas,
    String? suelo,
    String? luz,
  }) async {
    final mediaType = _mediaTypeFor(photo.path);
    final bytes = await _readBytes(photo.path);
    if (bytes.length > maxBytes) {
      throw const InvalidPhotoException('La foto es demasiado grande (máximo 10 MB).');
    }

    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/analyze'))
      ..files.add(http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename: _fileName(photo.path),
        contentType: mediaType,
      ));

    // 2. Inyectamos las respuestas del cuestionario al formulario HTTP
    if (sintomas != null && sintomas.isNotEmpty) {
      request.fields['sintomas'] = sintomas.join(','); // FastAPI lo separa por comas
    }
    if (suelo != null && suelo.isNotEmpty) {
      request.fields['suelo'] = suelo;
    }
    if (luz != null && luz.isNotEmpty) {
      request.fields['luz'] = luz;
    }

    final response = await _send(request);
    return _parse(response);
  }

  MediaType _mediaTypeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    throw const InvalidPhotoException('Formato no admitido. Usa JPEG, PNG o WebP.');
  }

  Future<List<int>> _readBytes(String path) async {
    try {
      return await File(path).readAsBytes();
    } on FileSystemException {
      throw const InvalidPhotoException('No se pudo leer la foto.');
    }
  }

  Future<http.Response> _send(http.MultipartRequest request) async {
    try {
      final streamed = await client.send(request).timeout(timeout);
      return await http.Response.fromStream(streamed).timeout(timeout);
    } on TimeoutException {
      throw const AnalyzerUnavailableException('Tiempo de espera agotado.');
    } on IOException {
      throw const AnalyzerUnavailableException('Sin conexión con el servidor.');
    } on http.ClientException {
      throw const AnalyzerUnavailableException('No se pudo contactar al servidor.');
    }
  }

  List<FindingModel> _parse(http.Response response) {
    final status = response.statusCode;

    if (status == 200) {
      try {
        final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        
        List<FindingModel> resultadosExpertos = [];

        // 1. Extraemos la magia de Prolog (expert_diagnosis)
        if (body.containsKey('expert_diagnosis') && body['expert_diagnosis'] != null) {
          final expertData = body['expert_diagnosis'];
          
          if (expertData is Map) {
            // Si el backend manda un diccionario: {"Arañita roja": 0.9, "Tizón": 0.2}
            expertData.forEach((key, value) {
              resultadosExpertos.add(FindingModel.fromJson({
                'label': key.toString(),
                'confidence': (value as num).toDouble()
              }));
            });
          } else if (expertData is List) {
            // Si el backend manda una lista: [{"label": "Arañita", "confidence": 0.9}]
            resultadosExpertos = (expertData as List<dynamic>)
                .map((item) => FindingModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
        }

        // 2. Si Prolog falla o viene vacío, usamos solo la visión (PyTorch) como respaldo
        if (resultadosExpertos.isEmpty && body.containsKey('findings')) {
          resultadosExpertos = (body['findings'] as List<dynamic>)
              .map((item) => FindingModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }

        // 3. ¡El toque maestro! Ordenamos los resultados de mayor a menor probabilidad
        resultadosExpertos.sort((a, b) => b.confidence.compareTo(a.confidence));

        return resultadosExpertos;

      } on FormatException {
        throw Exception('Respuesta inesperada del servidor (FormatException).');
      } on TypeError {
        throw Exception('Respuesta inesperada del servidor (TypeError).');
      }
    }

    if (status == 400 || status == 413 || status == 415 || status == 422) {
      throw InvalidPhotoException(_detail(response) ?? 'La foto no es válida.');
    }

    throw Exception('El servidor respondió con el código $status.');
  }
  String? _detail(http.Response response) {
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map<String, dynamic> && body['detail'] is String) {
        return body['detail'] as String;
      }
    } on FormatException {
      // Ignorar si no es JSON
    }
    return null;
  }

  String _fileName(String path) => path.split(RegExp(r'[\\/]')).last;
}