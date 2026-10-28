import '../../domain/entities/visual_finding.dart';

/// One class returned by the inference API.
class FindingModel {
  const FindingModel({required this.label, required this.confidence});

  factory FindingModel.fromJson(Map<String, dynamic> json) {
    return FindingModel(
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  final String label;
  final double confidence;

  VisualFinding toEntity() {
    // Clamp guards against tiny floating-point overshoots such as 1.0000001.
    return VisualFinding(
      label: label,
      confidence: confidence.clamp(0.0, 1.0).toDouble(),
    );
  }
}
