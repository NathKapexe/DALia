import '../entities/plant_photo.dart';
import '../entities/visual_finding.dart';

/// Port to the image model. The data layer implements it (remote API today,
/// an on-device model in the future).
abstract class ImageAnalyzer {
  /// Throws [AnalyzerUnavailableException] when it cannot run (offline,
  /// timeout, server error): the caller can still diagnose with the context.
  ///
  /// Throws [InvalidPhotoException] when the photo itself is unusable
  /// (unsupported format, too large, unreadable): the user must pick another.
  Future<List<VisualFinding>> analyze(PlantPhoto photo);
}

class AnalyzerUnavailableException implements Exception {
  const AnalyzerUnavailableException([this.message = 'Image analyzer unavailable']);

  final String message;

  @override
  String toString() => 'AnalyzerUnavailableException: $message';
}

class InvalidPhotoException implements Exception {
  const InvalidPhotoException([this.message = 'Invalid photo']);

  final String message;

  @override
  String toString() => 'InvalidPhotoException: $message';
}
