import 'package:dalia/features/diagnosis/domain/entities/cause.dart';
import 'package:dalia/features/diagnosis/domain/entities/plant_photo.dart';
import 'package:dalia/features/diagnosis/domain/entities/visual_finding.dart';
import 'package:dalia/features/diagnosis/domain/repositories/image_analyzer.dart';
import 'package:dalia/features/diagnosis/domain/repositories/knowledge_base_repository.dart';
import 'package:dalia/features/diagnosis/domain/repositories/photo_source.dart';
import 'package:dalia/features/diagnosis/domain/usecases/analyze_plant_photo.dart';
import 'package:dalia/features/diagnosis/presentation/state/diagnosis_controller.dart';

class FakePhotoSource implements PhotoSource {
  FakePhotoSource({this.photo = const PlantPhoto('leaf.jpg'), this.camera = true, this.error});

  PlantPhoto? photo;
  final bool camera;
  PhotoSourceException? error;

  @override
  bool get cameraAvailable => camera;

  @override
  Future<PlantPhoto?> pick(PhotoOrigin origin) async {
    final failure = error;
    if (failure != null) throw failure;
    return photo;
  }
}

class FakeAnalyzer implements ImageAnalyzer {
  List<VisualFinding> findings = const [];
  Object? error;
  int calls = 0;

  @override
  Future<List<VisualFinding>> analyze(PlantPhoto photo) async {
    calls++;
    final failure = error;
    if (failure != null) throw failure;
    return findings;
  }
}

class FakeKnowledgeBase implements KnowledgeBaseRepository {
  @override
  Future<List<Cause>> getCauses(String plantId) async => const [
        Cause(
          id: 'late_blight',
          name: 'Tizón tardío',
          category: CauseCategory.disease,
          summary: 'Hongo de prueba',
          treatmentSteps: ['Quita las hojas afectadas'],
          precautions: ['Cuidado de prueba'],
          modelLabels: ['Tomato___Late_blight'],
          indicators: {'symptom:spots': 0.6, 'symptom:moldOrPowder': 0.4},
        ),
        Cause(
          id: 'overwatering',
          name: 'Exceso de riego',
          category: CauseCategory.watering,
          summary: 'Riego de prueba',
          treatmentSteps: ['Deja secar la tierra'],
          indicators: {
            'soil:waterlogged': 0.5,
            'symptom:wilting': 0.25,
            'symptom:yellowLeaves': 0.25,
          },
        ),
      ];
}

DiagnosisController buildController({
  required FakePhotoSource photoSource,
  required ImageAnalyzer analyzer,
}) {
  return DiagnosisController(
    analyzePlantPhoto: AnalyzePlantPhoto(
      imageAnalyzer: analyzer,
      knowledgeBase: FakeKnowledgeBase(),
    ),
    photoSource: photoSource,
  );
}
