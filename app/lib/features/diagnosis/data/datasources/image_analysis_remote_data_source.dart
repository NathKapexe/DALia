import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../domain/entities/plant_photo.dart';
import '../../domain/repositories/image_analyzer.dart';
import '../models/finding_model.dart';

abstract class ImageAnalysisRemoteDataSource {
  Future<List<FindingModel>> analyze(PlantPhoto photo);
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
  Future<List<FindingModel>> analyze(PlantPhoto photo) async {
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
        return (body['findings'] as List<dynamic>)
            .map((item) => FindingModel.fromJson(item as Map<String, dynamic>))
            .toList();
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