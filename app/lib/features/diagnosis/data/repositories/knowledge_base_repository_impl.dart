import '../../domain/entities/cause.dart';
import '../../domain/repositories/knowledge_base_repository.dart';
import '../datasources/knowledge_local_data_source.dart';

/// Reads the knowledge base once per plant and keeps it in memory.
class KnowledgeBaseRepositoryImpl implements KnowledgeBaseRepository {
  KnowledgeBaseRepositoryImpl(this._dataSource);

  final KnowledgeLocalDataSource _dataSource;
  final Map<String, List<Cause>> _cache = {};

  @override
  Future<List<Cause>> getCauses(String plantId) async {
    final cached = _cache[plantId];
    if (cached != null) return cached;

    final causes = List<Cause>.unmodifiable(await _dataSource.getCauses(plantId));
    _cache[plantId] = causes;
    return causes;
  }
}
