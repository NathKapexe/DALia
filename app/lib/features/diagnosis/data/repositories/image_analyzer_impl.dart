import '../../domain/entities/plant_photo.dart';
import '../../domain/entities/visual_finding.dart';
import '../../domain/repositories/image_analyzer.dart';
import '../datasources/image_analysis_remote_data_source.dart';

/// Adapts the remote data source to the domain's [ImageAnalyzer] port.
class ImageAnalyzerImpl implements ImageAnalyzer {
  ImageAnalyzerImpl(this._remote);

  final ImageAnalysisRemoteDataSource _remote;

  @override
  Future<List<VisualFinding>> analyze(PlantPhoto photo) async {
    final findings = await _remote.analyze(photo);
    return findings.map((finding) => finding.toEntity()).toList();
  }
}
