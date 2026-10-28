import 'dart:io';

import 'package:dalia/features/diagnosis/data/datasources/knowledge_local_data_source.dart';
import 'package:dalia/features/diagnosis/data/repositories/knowledge_base_repository_impl.dart';
import 'package:dalia/features/diagnosis/domain/entities/context_answers.dart';
import 'package:dalia/features/diagnosis/domain/entities/diagnosis.dart';
import 'package:dalia/features/diagnosis/domain/entities/plant_photo.dart';
import 'package:dalia/features/diagnosis/domain/entities/visual_finding.dart';
import 'package:dalia/features/diagnosis/domain/repositories/image_analyzer.dart';
import 'package:dalia/features/diagnosis/domain/usecases/analyze_plant_photo.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedAnalyzer implements ImageAnalyzer {
  _FixedAnalyzer(this.findings);

  final List<VisualFinding> findings;

  @override
  Future<List<VisualFinding>> analyze(PlantPhoto photo) async => findings;
}

class _OfflineAnalyzer implements ImageAnalyzer {
  @override
  Future<List<VisualFinding>> analyze(PlantPhoto photo) async =>
      throw const AnalyzerUnavailableException();
}

/// Real domain + real knowledge base (read from disk) + a fake analyzer.
AnalyzePlantPhoto _useCase(ImageAnalyzer analyzer) {
  return AnalyzePlantPhoto(
    imageAnalyzer: analyzer,
    knowledgeBase: KnowledgeBaseRepositoryImpl(
      AssetKnowledgeDataSource(loader: (path) async => File(path).readAsStringSync()),
    ),
  );
}

void main() {
  test('online: image evidence plus a ticked symptom points to Septoria', () async {
    final useCase = _useCase(_FixedAnalyzer(const [
      VisualFinding(label: 'Tomato___Septoria_leaf_spot', confidence: 0.89),
      VisualFinding(label: 'Tomato___Bacterial_spot', confidence: 0.10),
    ]));

    final diagnosis = await useCase(
      plantId: 'tomato',
      photo: const PlantPhoto('leaf.jpg'),
      answers: const ContextAnswers(symptoms: {Symptom.spots}),
    );

    expect(diagnosis.usedImage, isTrue);
    expect(diagnosis.level, ConfidenceLevel.high);
    expect(diagnosis.candidates.first.cause.id, 'septoria_leaf_spot');
    expect(diagnosis.candidates[1].cause.id, 'bacterial_spot');
  });

  test('offline: soggy soil and wilting point to overwatering', () async {
    final useCase = _useCase(_OfflineAnalyzer());

    final diagnosis = await useCase(
      plantId: 'tomato',
      photo: const PlantPhoto('leaf.jpg'),
      answers: const ContextAnswers(
        soil: SoilState.waterlogged,
        symptoms: {Symptom.wilting},
      ),
    );

    expect(diagnosis.usedImage, isFalse);
    expect(diagnosis.needsOnlineRefinement, isTrue);
    expect(diagnosis.candidates.first.cause.id, 'overwatering');
    expect(diagnosis.level, ConfidenceLevel.high);
  });
}
