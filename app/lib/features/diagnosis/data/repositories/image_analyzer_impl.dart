import '../../domain/entities/plant_photo.dart';
import '../../domain/entities/visual_finding.dart';
import '../../domain/repositories/image_analyzer.dart';
import '../datasources/image_analysis_remote_data_source.dart';

/// Adapts the remote data source to the domain's [ImageAnalyzer] port.
class ImageAnalyzerImpl implements ImageAnalyzer {
  // Aquí aplicamos la sugerencia de Flutter para inicializar variables
  ImageAnalyzerImpl(this._remote);

  final ImageAnalysisRemoteDataSource _remote;

  @override
  Future<List<VisualFinding>> analyze(
    PlantPhoto photo, {
    List<String>? sintomas,
    String? suelo,
    String? luz,
  }) async {
    // Le pasamos las respuestas a la capa que se comunica con internet
    final findings = await _remote.analyze(
      photo,
      sintomas: sintomas,
      suelo: suelo,
      luz: luz,
    );
    return findings.map((finding) => finding.toEntity()).toList();
  }
}