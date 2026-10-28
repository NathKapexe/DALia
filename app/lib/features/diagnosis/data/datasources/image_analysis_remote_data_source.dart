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

/// Talks to the Dalia inference API (`POST /analyze`, multipart field `photo`).
///
/// Error mapping:
///  * no connection, timeout, 5xx, unexpected body -> [AnalyzerUnavailableException]
///  * 400 / 413 / 415 / 422, unsupported or unreadable file -> [InvalidPhotoException]
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

  /// Same limit the API enforces (10 MB).
  final int maxBytes;

  @override
  Future<List<FindingModel>> analyze(PlantPhoto photo) async {
    final mediaType = _mediaTypeFor(photo.path);
    final bytes = await _readBytes(photo.path);
    if (bytes.length > maxBytes) {
      throw const InvalidPhotoException('La foto es demasiado grande (máximo 10 MB).');
    }

    // The API only accepts image/* content types, so it must be set explicitly.
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
        throw const AnalyzerUnavailableException('Respuesta inesperada del servidor.');
      } on TypeError {
        throw const AnalyzerUnavailableException('Respuesta inesperada del servidor.');
      }
    }

    if (status == 400 || status == 413 || status == 415 || status == 422) {
      throw InvalidPhotoException(_detail(response) ?? 'La foto no es válida.');
    }

    throw AnalyzerUnavailableException('El servidor respondió con el código $status.');
  }

  /// FastAPI sends `detail` as a string for our own errors and as a list for
  /// validation errors (422); only the string form is shown to the user.
  String? _detail(http.Response response) {
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map<String, dynamic> && body['detail'] is String) {
        return body['detail'] as String;
      }
    } on FormatException {
      // Not JSON: fall back to the generic message.
    }
    return null;
  }

  String _fileName(String path) => path.split(RegExp(r'[\\/]')).last;
}
