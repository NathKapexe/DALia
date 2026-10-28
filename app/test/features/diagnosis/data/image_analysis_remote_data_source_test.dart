import 'dart:convert';
import 'dart:io';

import 'package:dalia/features/diagnosis/data/datasources/image_analysis_remote_data_source.dart';
import 'package:dalia/features/diagnosis/domain/entities/plant_photo.dart';
import 'package:dalia/features/diagnosis/domain/repositories/image_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late Directory tmp;
  late File jpg;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('dalia_test');
    jpg = File('${tmp.path}${Platform.pathSeparator}leaf.jpg')
      ..writeAsBytesSync(utf8.encode('fake-image-bytes'));
  });

  tearDown(() => tmp.deleteSync(recursive: true));

  HttpImageAnalysisDataSource build(
    http.Client client, {
    int maxBytes = 1024,
    Duration timeout = const Duration(seconds: 5),
  }) {
    return HttpImageAnalysisDataSource(
      client: client,
      baseUrl: 'http://api.test',
      maxBytes: maxBytes,
      timeout: timeout,
    );
  }

  http.Response jsonResponse(Object body, int status) => http.Response(
        jsonEncode(body),
        status,
        headers: {'content-type': 'application/json'},
      );

  test('sends the photo as multipart and parses the findings', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return jsonResponse({
        'version': 'v2b',
        'findings': [
          {'label': 'Tomato___Late_blight', 'confidence': 0.56},
          {'label': 'Tomato___healthy', 'confidence': 1},
        ],
      }, 200);
    });

    final findings = await build(client).analyze(PlantPhoto(jpg.path));

    expect(captured.method, 'POST');
    expect(captured.url.toString(), 'http://api.test/analyze');
    expect(captured.headers['content-type'], startsWith('multipart/form-data'));
    expect(captured.body, contains('name="photo"'));
    expect(captured.body, contains('filename="leaf.jpg"'));
    expect(captured.body, contains('image/jpeg'));
    expect(findings.first.label, 'Tomato___Late_blight');
    expect(findings.first.confidence, 0.56);
    expect(findings.last.confidence, 1.0);
  });

  test('a 5xx response means the analyzer is unavailable', () async {
    final client = MockClient((_) async => jsonResponse({'detail': 'boom'}, 500));

    await expectLater(
      build(client).analyze(PlantPhoto(jpg.path)),
      throwsA(isA<AnalyzerUnavailableException>()),
    );
  });

  test('a 400 response means the photo is invalid and shows the detail', () async {
    final client = MockClient(
      (_) async => jsonResponse({'detail': 'No se pudo leer la imagen.'}, 400),
    );

    await expectLater(
      build(client).analyze(PlantPhoto(jpg.path)),
      throwsA(isA<InvalidPhotoException>()
          .having((e) => e.message, 'message', 'No se pudo leer la imagen.')),
    );
  });

  test('a 422 response uses the generic message', () async {
    final client = MockClient((_) async => jsonResponse({'detail': []}, 422));

    await expectLater(
      build(client).analyze(PlantPhoto(jpg.path)),
      throwsA(isA<InvalidPhotoException>()
          .having((e) => e.message, 'message', 'La foto no es válida.')),
    );
  });

  test('a socket error means the analyzer is unavailable', () async {
    final client = MockClient((_) async => throw const SocketException('down'));

    await expectLater(
      build(client).analyze(PlantPhoto(jpg.path)),
      throwsA(isA<AnalyzerUnavailableException>()),
    );
  });

  test('a client exception means the analyzer is unavailable', () async {
    final client = MockClient((_) async => throw http.ClientException('down'));

    await expectLater(
      build(client).analyze(PlantPhoto(jpg.path)),
      throwsA(isA<AnalyzerUnavailableException>()),
    );
  });

  test('a slow server times out and is treated as unavailable', () async {
    final client = MockClient((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return jsonResponse({'version': 'v2b', 'findings': []}, 200);
    });

    await expectLater(
      build(client, timeout: const Duration(milliseconds: 50))
          .analyze(PlantPhoto(jpg.path)),
      throwsA(isA<AnalyzerUnavailableException>()),
    );
  });

  test('an unexpected 200 body means the analyzer is unavailable', () async {
    final client = MockClient((_) async => jsonResponse({'oops': true}, 200));

    await expectLater(
      build(client).analyze(PlantPhoto(jpg.path)),
      throwsA(isA<AnalyzerUnavailableException>()),
    );
  });

  test('an unsupported extension is rejected without calling the server', () async {
    var called = false;
    final client = MockClient((_) async {
      called = true;
      return jsonResponse({}, 200);
    });
    final gif = File('${tmp.path}${Platform.pathSeparator}leaf.gif')
      ..writeAsBytesSync([1, 2, 3]);

    await expectLater(
      build(client).analyze(PlantPhoto(gif.path)),
      throwsA(isA<InvalidPhotoException>()),
    );
    expect(called, isFalse);
  });

  test('a photo over the size limit is rejected without calling the server', () async {
    var called = false;
    final client = MockClient((_) async {
      called = true;
      return jsonResponse({}, 200);
    });

    await expectLater(
      build(client, maxBytes: 4).analyze(PlantPhoto(jpg.path)),
      throwsA(isA<InvalidPhotoException>()),
    );
    expect(called, isFalse);
  });

  test('a missing file is an invalid photo', () async {
    final client = MockClient((_) async => jsonResponse({}, 200));
    final missing = '${tmp.path}${Platform.pathSeparator}nope.jpg';

    await expectLater(
      build(client).analyze(PlantPhoto(missing)),
      throwsA(isA<InvalidPhotoException>()),
    );
  });
}
