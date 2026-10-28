import '../../domain/entities/cause.dart';

/// A [Cause] that knows how to build itself from the knowledge-base JSON.
class CauseModel extends Cause {
  const CauseModel({
    required super.id,
    required super.name,
    required super.category,
    required super.summary,
    required super.treatmentSteps,
    required super.precautions,
    required super.modelLabels,
    required super.indicators,
  });

  factory CauseModel.fromJson(Map<String, dynamic> json) {
    return CauseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: _parseCategory(json['category'] as String),
      summary: json['summary'] as String,
      treatmentSteps: _stringList(json['treatmentSteps']),
      precautions: _stringList(json['precautions']),
      modelLabels: _stringList(json['modelLabels']),
      indicators: _indicators(json['indicators']),
    );
  }

  static CauseCategory _parseCategory(String value) {
    return CauseCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => throw FormatException('Unknown cause category: $value'),
    );
  }

  static List<String> _stringList(Object? value) {
    final list = (value as List<dynamic>?) ?? const <dynamic>[];
    return list.map((item) => item as String).toList();
  }

  static Map<String, double> _indicators(Object? value) {
    final map = (value as Map<String, dynamic>?) ?? const <String, dynamic>{};
    return map.map((key, weight) => MapEntry(key, (weight as num).toDouble()));
  }
}
