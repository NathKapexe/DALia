import 'diagnosis.dart';

class DiagnosisRecord {
  const DiagnosisRecord({
    required this.id,
    required this.createdAt,
    required this.photoPath,
    required this.diagnosis,
  });

  final String id;
  final DateTime createdAt;
  final String photoPath;
  final Diagnosis diagnosis;
}   