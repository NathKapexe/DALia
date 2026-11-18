import 'dart:convert';
import 'dart:io';

import '../../domain/entities/cause.dart';
import '../../domain/entities/diagnosis.dart';
import '../../domain/entities/diagnosis_record.dart';
import '../../domain/repositories/history_repository.dart';

class LocalHistoryRepository implements HistoryRepository {
  LocalHistoryRepository({Directory? baseDirectory})
      : _baseDir = baseDirectory ?? _resolveDefaultDirectory();

  final Directory _baseDir;

  static Directory _resolveDefaultDirectory() {
    final appData = Platform.environment['APPDATA'] ?? Platform.environment['HOME'];
    if (appData != null && appData.isNotEmpty) {
      return Directory('$appData${Platform.pathSeparator}DALia');
    }
    return Directory('${Directory.systemTemp.path}${Platform.pathSeparator}DALia');
  }

  File get _historyFile =>
      File('${_baseDir.path}${Platform.pathSeparator}history.json');

  Directory get _photosDir =>
      Directory('${_baseDir.path}${Platform.pathSeparator}photos');

  @override
  Future<List<DiagnosisRecord>> getAll() async {
    try {
      if (!await _historyFile.exists()) return [];
      final raw = await _historyFile.readAsString();
      if (raw.trim().isEmpty) return [];

      final list = jsonDecode(raw) as List<dynamic>;
      final records = list
          .map((item) => _recordFromJson(item as Map<String, dynamic>))
          .toList();

      // Más recientes primero
      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return records;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> save(DiagnosisRecord record) async {
    await _baseDir.create(recursive: true);
    await _photosDir.create(recursive: true);

    // Copiamos la foto a una carpeta persistente para que no se pierda
    var savedPhotoPath = record.photoPath;
    final originalFile = File(record.photoPath);
    if (await originalFile.exists()) {
      final ext = record.photoPath.split('.').last;
      final destPath =
          '${_photosDir.path}${Platform.pathSeparator}${record.id}.$ext';
      await originalFile.copy(destPath);
      savedPhotoPath = destPath;
    }

    final persistedRecord = DiagnosisRecord(
      id: record.id,
      createdAt: record.createdAt,
      photoPath: savedPhotoPath,
      diagnosis: record.diagnosis,
    );

    final current = await getAll();
    current.insert(0, persistedRecord);

    // Mantenemos máximo 30 consultas recientes
    final trimmed = current.take(30).toList();
    await _writeAll(trimmed);
  }

  @override
  Future<void> delete(String id) async {
    final current = await getAll();
    final target = current.where((r) => r.id == id).firstOrNull;
    if (target != null) {
      final photoFile = File(target.photoPath);
      if (await photoFile.exists() &&
          photoFile.parent.path == _photosDir.path) {
        await photoFile.delete();
      }
    }
    current.removeWhere((r) => r.id == id);
    await _writeAll(current);
  }

  @override
  Future<void> clear() async {
    if (await _photosDir.exists()) {
      await _photosDir.delete(recursive: true);
    }
    if (await _historyFile.exists()) {
      await _historyFile.delete();
    }
  }

  Future<void> _writeAll(List<DiagnosisRecord> records) async {
    await _baseDir.create(recursive: true);
    final encoded = jsonEncode(records.map(_recordToJson).toList());
    await _historyFile.writeAsString(encoded);
  }

  Map<String, dynamic> _recordToJson(DiagnosisRecord r) => {
        'id': r.id,
        'createdAt': r.createdAt.toIso8601String(),
        'photoPath': r.photoPath,
        'diagnosis': {
          'level': r.diagnosis.level.name,
          'usedImage': r.diagnosis.usedImage,
          'candidates': r.diagnosis.candidates.map(_candidateToJson).toList(),
        },
      };

  Map<String, dynamic> _candidateToJson(CauseCandidate c) => {
        'score': c.score,
        'evidence': c.evidence,
        'cause': {
          'id': c.cause.id,
          'name': c.cause.name,
          'category': c.cause.category.name,
          'summary': c.cause.summary,
          'treatmentSteps': c.cause.treatmentSteps,
          'precautions': c.cause.precautions,
        },
      };

  DiagnosisRecord _recordFromJson(Map<String, dynamic> json) {
    final diagJson = json['diagnosis'] as Map<String, dynamic>;
    final candidatesList = (diagJson['candidates'] as List<dynamic>)
        .map((c) => _candidateFromJson(c as Map<String, dynamic>))
        .toList();

    return DiagnosisRecord(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      photoPath: json['photoPath'] as String,
      diagnosis: Diagnosis(
        candidates: candidatesList,
        level: ConfidenceLevel.values.firstWhere(
          (e) => e.name == diagJson['level'],
          orElse: () => ConfidenceLevel.medium,
        ),
        usedImage: diagJson['usedImage'] as bool? ?? true,
      ),
    );
  }

  CauseCandidate _candidateFromJson(Map<String, dynamic> json) {
    final causeJson = json['cause'] as Map<String, dynamic>;
    return CauseCandidate(
      score: (json['score'] as num).toDouble(),
      evidence: List<String>.from(json['evidence'] as List<dynamic>? ?? []),
      cause: Cause(
        id: causeJson['id'] as String,
        name: causeJson['name'] as String,
        category: CauseCategory.values.firstWhere(
          (e) => e.name == causeJson['category'],
          orElse: () => CauseCategory.disease,
        ),
        summary: causeJson['summary'] as String,
        treatmentSteps:
            List<String>.from(causeJson['treatmentSteps'] as List<dynamic>? ?? []),
        precautions:
            List<String>.from(causeJson['precautions'] as List<dynamic>? ?? []),
      ),
    );
  }
}