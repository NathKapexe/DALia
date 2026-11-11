import '../entities/context_answers.dart';
import '../entities/diagnosis.dart';
import '../entities/plant_photo.dart';
import '../entities/visual_finding.dart';
import '../repositories/image_analyzer.dart';
import '../repositories/knowledge_base_repository.dart';
import '../services/diagnosis_engine.dart';

/// Use case: photo + context answers -> list of probable causes.
///
/// If the image analyzer is unavailable (offline) it degrades gracefully: the
/// engine runs with the context answers only and the result is flagged so the
/// app can offer to refine it once the connection is back.
class AnalyzePlantPhoto {
  AnalyzePlantPhoto({
    required this.imageAnalyzer,
    required this.knowledgeBase,
    DiagnosisEngine? engine,
  }) : engine = engine ?? const DiagnosisEngine();

  final ImageAnalyzer imageAnalyzer;
  final KnowledgeBaseRepository knowledgeBase;
  final DiagnosisEngine engine;

  Future<Diagnosis> call({
    required String plantId,
    required PlantPhoto photo,
    required ContextAnswers answers,
  }) async {
    final causes = await knowledgeBase.getCauses(plantId);

    var findings = const <VisualFinding>[];
    var imageAvailable = true;
    try {
      // Extraemos el texto (.name) de los enums en inglés y los pasamos a la API
      findings = await imageAnalyzer.analyze(
        photo,
        sintomas: answers.symptoms.map((s) => s.name).toList(),
        suelo: answers.soil?.name,
        luz: answers.light?.name,
      );
    } on AnalyzerUnavailableException {
      imageAvailable = false;
    }

    return engine.diagnose(
      causes: causes,
      findings: findings,
      answers: answers,
      imageAvailable: imageAvailable,
    );
  }
}