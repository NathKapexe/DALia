import '../entities/cause.dart';

/// Port to the local knowledge base (causes and treatments per plant).
abstract class KnowledgeBaseRepository {
  Future<List<Cause>> getCauses(String plantId);
}
