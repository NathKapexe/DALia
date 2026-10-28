import 'package:flutter/foundation.dart';

import '../../domain/entities/context_answers.dart';
import '../../domain/entities/diagnosis.dart';
import '../../domain/entities/plant_photo.dart';
import '../../domain/repositories/image_analyzer.dart';
import '../../domain/repositories/photo_source.dart';
import '../../domain/usecases/analyze_plant_photo.dart';

enum DiagnosisStatus { idle, analyzing, done, failure }

/// Holds the state of one consultation: photo, context answers and result.
///
/// It talks only to the domain (use case and ports), never to the data layer.
class DiagnosisController extends ChangeNotifier {
  DiagnosisController({
    required AnalyzePlantPhoto analyzePlantPhoto,
    required PhotoSource photoSource,
    this.plantId = 'tomato',
  })  : _analyze = analyzePlantPhoto,
        _photoSource = photoSource;

  final AnalyzePlantPhoto _analyze;
  final PhotoSource _photoSource;
  final String plantId;

  DiagnosisStatus _status = DiagnosisStatus.idle;
  PlantPhoto? _photo;
  ContextAnswers _answers = const ContextAnswers();
  Diagnosis? _diagnosis;
  String? _errorMessage;

  // Incremented on every new request or reset, so that an analysis that
  // finishes late (after the user left) is discarded.
  int _requestId = 0;

  DiagnosisStatus get status => _status;
  PlantPhoto? get photo => _photo;
  ContextAnswers get answers => _answers;
  Diagnosis? get diagnosis => _diagnosis;
  String? get errorMessage => _errorMessage;
  bool get isAnalyzing => _status == DiagnosisStatus.analyzing;
  bool get cameraAvailable => _photoSource.cameraAvailable;

  /// Returns true when a NEW photo was selected (false if cancelled or failed).
  Future<bool> choosePhoto(PhotoOrigin origin) async {
    try {
      final photo = await _photoSource.pick(origin);
      if (photo == null) return false;

      _requestId++;
      _photo = photo;
      _answers = const ContextAnswers();
      _diagnosis = null;
      _errorMessage = null;
      _status = DiagnosisStatus.idle;
      notifyListeners();
      return true;
    } on PhotoSourceException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  void setSoil(SoilState? soil) {
    _answers = ContextAnswers(
      soil: soil,
      light: _answers.light,
      symptoms: _answers.symptoms,
    );
    notifyListeners();
  }

  void setLight(LightLevel? light) {
    _answers = ContextAnswers(
      soil: _answers.soil,
      light: light,
      symptoms: _answers.symptoms,
    );
    notifyListeners();
  }

  void toggleSymptom(Symptom symptom) {
    final next = {..._answers.symptoms};
    if (!next.remove(symptom)) next.add(symptom);
    _answers = ContextAnswers(
      soil: _answers.soil,
      light: _answers.light,
      symptoms: next,
    );
    notifyListeners();
  }

  Future<void> analyze() async {
    final photo = _photo;
    if (photo == null || isAnalyzing) return;

    final request = ++_requestId;
    _status = DiagnosisStatus.analyzing;
    _errorMessage = null;
    notifyListeners();

    try {
      final diagnosis = await _analyze(
        plantId: plantId,
        photo: photo,
        answers: _answers,
      );
      if (request != _requestId) return;
      _diagnosis = diagnosis;
      _status = DiagnosisStatus.done;
    } on InvalidPhotoException catch (e) {
      if (request != _requestId) return;
      _errorMessage = e.message;
      _status = DiagnosisStatus.failure;
    } catch (_) {
      if (request != _requestId) return;
      _errorMessage = 'Algo salió mal al analizar la planta. Inténtalo de nuevo.';
      _status = DiagnosisStatus.failure;
    }
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Starts a new consultation.
  void reset() {
    _requestId++;
    _photo = null;
    _answers = const ContextAnswers();
    _diagnosis = null;
    _errorMessage = null;
    _status = DiagnosisStatus.idle;
    notifyListeners();
  }
}
