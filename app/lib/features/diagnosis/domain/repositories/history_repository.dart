import '../entities/diagnosis_record.dart';

abstract class HistoryRepository {
  Future<List<DiagnosisRecord>> getAll();
  Future<void> save(DiagnosisRecord record);
  Future<void> delete(String id);
  Future<void> clear();
}