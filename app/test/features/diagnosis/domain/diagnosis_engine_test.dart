import 'package:dalia/features/diagnosis/domain/entities/cause.dart';
import 'package:dalia/features/diagnosis/domain/entities/context_answers.dart';
import 'package:dalia/features/diagnosis/domain/entities/diagnosis.dart';
import 'package:dalia/features/diagnosis/domain/entities/plant_photo.dart';
import 'package:dalia/features/diagnosis/domain/entities/visual_finding.dart';
import 'package:dalia/features/diagnosis/domain/repositories/image_analyzer.dart';
import 'package:dalia/features/diagnosis/domain/repositories/knowledge_base_repository.dart';
import 'package:dalia/features/diagnosis/domain/services/diagnosis_engine.dart';
import 'package:dalia/features/diagnosis/domain/usecases/analyze_plant_photo.dart';
import 'package:flutter_test/flutter_test.dart';

const _overwatering = Cause(
  id: 'overwatering',
  name: 'Exceso de riego',
  category: CauseCategory.watering,
  summary: 'x',
  treatmentSteps: ['x'],
  indicators: {
    'soil:waterlogged': 0.5,
    'symptom:wilting': 0.25,
    'symptom:yellowLeaves': 0.25,
  },
);

const _lateBlight = Cause(
  id: 'late_blight',
  name: 'Tizon tardio',
  category: CauseCategory.disease,
  summary: 'x',
  treatmentSteps: ['x'],
  modelLabels: ['Tomato___Late_blight'],
  indicators: {
    'symptom:spots': 0.6,
    'symptom:moldOrPowder': 0.4,
  },
);

const _healthy = Cause(
  id: 'no_clear_symptoms',
  name: 'Sin sintomas claros',
  category: CauseCategory.none,
  summary: 'x',
  treatmentSteps: ['x'],
  modelLabels: ['Tomato___healthy'],
);

const _causes = [_overwatering, _lateBlight, _healthy];

class _FakeKnowledgeBase implements KnowledgeBaseRepository {
  @override
  Future<List<Cause>> getCauses(String plantId) async => _causes;
}

class _OfflineAnalyzer implements ImageAnalyzer {
  @override
  Future<List<VisualFinding>> analyze(PlantPhoto photo) async =>
      throw const AnalyzerUnavailableException();
}

class _FixedAnalyzer implements ImageAnalyzer {
  _FixedAnalyzer(this.findings);

  final List<VisualFinding> findings;

  @override
  Future<List<VisualFinding>> analyze(PlantPhoto photo) async => findings;
}

void main() {
  const engine = DiagnosisEngine();

  group('DiagnosisEngine', () {
    test('without image it ranks by context only', () {
      final diagnosis = engine.diagnose(
        causes: _causes,
        findings: const [],
        answers: const ContextAnswers(
          soil: SoilState.waterlogged,
          symptoms: {Symptom.wilting},
        ),
        imageAvailable: false,
      );

      expect(diagnosis.candidates.first.cause.id, 'overwatering');
      expect(diagnosis.candidates.first.score, closeTo(0.75, 1e-9));
      expect(diagnosis.level, ConfidenceLevel.high);
      expect(diagnosis.usedImage, isFalse);
      expect(diagnosis.needsOnlineRefinement, isTrue);
    });

    test('image plus matching symptoms gives a high score', () {
      final diagnosis = engine.diagnose(
        causes: _causes,
        findings: const [
          VisualFinding(label: 'Tomato___Late_blight', confidence: 0.8),
        ],
        answers: const ContextAnswers(symptoms: {Symptom.spots}),
        imageAvailable: true,
      );

      expect(diagnosis.candidates.first.cause.id, 'late_blight');
      expect(diagnosis.candidates.first.score, closeTo(0.72, 1e-9));
      expect(diagnosis.level, ConfidenceLevel.high);
      expect(diagnosis.candidates.first.evidence,
          contains('image:Tomato___Late_blight'));
    });

    test('a photo alone never reaches the high level', () {
      final diagnosis = engine.diagnose(
        causes: _causes,
        findings: const [
          VisualFinding(label: 'Tomato___Late_blight', confidence: 0.99),
        ],
        answers: const ContextAnswers(),
        imageAvailable: true,
      );

      expect(diagnosis.candidates.first.score, closeTo(0.594, 1e-9));
      expect(diagnosis.level, ConfidenceLevel.medium);
    });

    test('"no clear symptoms" wins when the user reports nothing', () {
      final diagnosis = engine.diagnose(
        causes: _causes,
        findings: const [
          VisualFinding(label: 'Tomato___healthy', confidence: 0.6),
          VisualFinding(label: 'Tomato___Late_blight', confidence: 0.3),
        ],
        answers: const ContextAnswers(),
        imageAvailable: true,
      );

      expect(diagnosis.candidates.first.cause.id, 'no_clear_symptoms');
    });

    test('"no clear symptoms" is dampened when the user ticks a symptom', () {
      final diagnosis = engine.diagnose(
        causes: _causes,
        findings: const [
          VisualFinding(label: 'Tomato___healthy', confidence: 0.6),
          VisualFinding(label: 'Tomato___Late_blight', confidence: 0.3),
        ],
        answers: const ContextAnswers(symptoms: {Symptom.spots}),
        imageAvailable: true,
      );

      expect(diagnosis.candidates.map((c) => c.cause.id).toList(),
          ['late_blight', 'no_clear_symptoms']);
      expect(diagnosis.candidates.first.score, closeTo(0.42, 1e-9));
      expect(diagnosis.candidates.last.score, closeTo(0.18, 1e-9));
      expect(diagnosis.level, ConfidenceLevel.medium);
    });

    test('nothing matches -> empty list and low level', () {
      final diagnosis = engine.diagnose(
        causes: _causes,
        findings: const [],
        answers: const ContextAnswers(),
        imageAvailable: false,
      );

      expect(diagnosis.candidates, isEmpty);
      expect(diagnosis.level, ConfidenceLevel.low);
    });
  });

  group('AnalyzePlantPhoto', () {
    test('degrades to context only when the analyzer is unavailable', () async {
      final useCase = AnalyzePlantPhoto(
        imageAnalyzer: _OfflineAnalyzer(),
        knowledgeBase: _FakeKnowledgeBase(),
      );

      final diagnosis = await useCase(
        plantId: 'tomato',
        photo: const PlantPhoto('photo.jpg'),
        answers: const ContextAnswers(soil: SoilState.waterlogged),
      );

      expect(diagnosis.usedImage, isFalse);
      expect(diagnosis.needsOnlineRefinement, isTrue);
      expect(diagnosis.candidates.first.cause.id, 'overwatering');
    });

    test('uses the image when the analyzer is available', () async {
      final useCase = AnalyzePlantPhoto(
        imageAnalyzer: _FixedAnalyzer(const [
          VisualFinding(label: 'Tomato___Late_blight', confidence: 0.9),
        ]),
        knowledgeBase: _FakeKnowledgeBase(),
      );

      final diagnosis = await useCase(
        plantId: 'tomato',
        photo: const PlantPhoto('photo.jpg'),
        answers: const ContextAnswers(symptoms: {Symptom.spots}),
      );

      expect(diagnosis.usedImage, isTrue);
      expect(diagnosis.needsOnlineRefinement, isFalse);
      expect(diagnosis.candidates.first.cause.id, 'late_blight');
    });
  });
}
