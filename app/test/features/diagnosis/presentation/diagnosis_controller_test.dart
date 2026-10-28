import 'dart:async';

import 'package:dalia/features/diagnosis/domain/entities/context_answers.dart';
import 'package:dalia/features/diagnosis/domain/entities/diagnosis.dart';
import 'package:dalia/features/diagnosis/domain/entities/plant_photo.dart';
import 'package:dalia/features/diagnosis/domain/entities/visual_finding.dart';
import 'package:dalia/features/diagnosis/domain/repositories/image_analyzer.dart';
import 'package:dalia/features/diagnosis/domain/repositories/photo_source.dart';
import 'package:dalia/features/diagnosis/presentation/state/diagnosis_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

class _GateAnalyzer implements ImageAnalyzer {
  final completer = Completer<List<VisualFinding>>();

  @override
  Future<List<VisualFinding>> analyze(PlantPhoto photo) => completer.future;
}

void main() {
  late FakePhotoSource photoSource;
  late FakeAnalyzer analyzer;
  late DiagnosisController controller;

  setUp(() {
    photoSource = FakePhotoSource();
    analyzer = FakeAnalyzer();
    controller = buildController(photoSource: photoSource, analyzer: analyzer);
  });

  test('choosing a photo stores it and returns true', () async {
    final picked = await controller.choosePhoto(PhotoOrigin.gallery);

    expect(picked, isTrue);
    expect(controller.photo?.path, 'leaf.jpg');
    expect(controller.status, DiagnosisStatus.idle);
  });

  test('cancelling keeps the previous photo and returns false', () async {
    await controller.choosePhoto(PhotoOrigin.gallery);
    photoSource.photo = null;

    final picked = await controller.choosePhoto(PhotoOrigin.gallery);

    expect(picked, isFalse);
    expect(controller.photo?.path, 'leaf.jpg');
  });

  test('a photo source error is exposed as a message', () async {
    photoSource.error = const PhotoSourceException('Sin cámara');

    final picked = await controller.choosePhoto(PhotoOrigin.camera);

    expect(picked, isFalse);
    expect(controller.errorMessage, 'Sin cámara');
    controller.clearError();
    expect(controller.errorMessage, isNull);
  });

  test('answers can be set, toggled and cleared', () {
    controller.setSoil(SoilState.dry);
    controller.setLight(LightLevel.low);
    controller.toggleSymptom(Symptom.spots);
    controller.toggleSymptom(Symptom.wilting);
    controller.toggleSymptom(Symptom.spots);

    expect(controller.answers.soil, SoilState.dry);
    expect(controller.answers.light, LightLevel.low);
    expect(controller.answers.symptoms, {Symptom.wilting});

    controller.setSoil(null);
    expect(controller.answers.soil, isNull);
  });

  test('it notifies listeners when the answers change', () {
    var notifications = 0;
    controller.addListener(() => notifications++);

    controller.setSoil(SoilState.moist);
    controller.toggleSymptom(Symptom.spots);

    expect(notifications, 2);
  });

  test('analyze combines the image and the answers', () async {
    analyzer.findings = const [
      VisualFinding(label: 'Tomato___Late_blight', confidence: 0.8),
    ];
    await controller.choosePhoto(PhotoOrigin.gallery);
    controller.toggleSymptom(Symptom.spots);

    await controller.analyze();

    expect(controller.status, DiagnosisStatus.done);
    expect(controller.diagnosis?.candidates.first.cause.id, 'late_blight');
    expect(controller.diagnosis?.level, ConfidenceLevel.high);
  });

  test('without connection the diagnosis uses only the answers', () async {
    analyzer.error = const AnalyzerUnavailableException();
    await controller.choosePhoto(PhotoOrigin.gallery);
    controller.setSoil(SoilState.waterlogged);

    await controller.analyze();

    expect(controller.status, DiagnosisStatus.done);
    expect(controller.diagnosis?.needsOnlineRefinement, isTrue);
    expect(controller.diagnosis?.candidates.first.cause.id, 'overwatering');
  });

  test('an invalid photo ends in failure with the message', () async {
    analyzer.error = const InvalidPhotoException('Formato no admitido.');
    await controller.choosePhoto(PhotoOrigin.gallery);

    await controller.analyze();

    expect(controller.status, DiagnosisStatus.failure);
    expect(controller.errorMessage, 'Formato no admitido.');
    expect(controller.diagnosis, isNull);
  });

  test('analyze does nothing without a photo', () async {
    await controller.analyze();

    expect(controller.status, DiagnosisStatus.idle);
    expect(analyzer.calls, 0);
  });

  test('a result that arrives after reset is discarded', () async {
    final gate = _GateAnalyzer();
    final gated = buildController(photoSource: photoSource, analyzer: gate);
    await gated.choosePhoto(PhotoOrigin.gallery);

    final pending = gated.analyze();
    gated.reset();
    gate.completer.complete(const []);
    await pending;

    expect(gated.status, DiagnosisStatus.idle);
    expect(gated.diagnosis, isNull);
    expect(gated.photo, isNull);
  });
}
