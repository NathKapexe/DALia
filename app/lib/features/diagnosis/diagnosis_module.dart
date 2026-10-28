import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import 'data/datasources/image_analysis_remote_data_source.dart';
import 'data/datasources/knowledge_local_data_source.dart';
import 'data/repositories/image_analyzer_impl.dart';
import 'data/repositories/knowledge_base_repository_impl.dart';
import 'domain/usecases/analyze_plant_photo.dart';

/// Composition root of the diagnosis feature: the only place that knows the
/// concrete data-layer classes. The presentation layer asks for the use case.
AnalyzePlantPhoto buildAnalyzePlantPhoto({http.Client? client, String? baseUrl}) {
  return AnalyzePlantPhoto(
    imageAnalyzer: ImageAnalyzerImpl(
      HttpImageAnalysisDataSource(
        client: client ?? http.Client(),
        baseUrl: baseUrl ?? kApiBaseUrl,
      ),
    ),
    knowledgeBase: KnowledgeBaseRepositoryImpl(AssetKnowledgeDataSource()),
  );
}
