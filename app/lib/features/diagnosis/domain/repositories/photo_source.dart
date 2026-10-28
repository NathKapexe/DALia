import '../entities/plant_photo.dart';

enum PhotoOrigin { camera, gallery }

/// Port to get a photo from the device (camera or gallery / file picker).
abstract class PhotoSource {
  /// Whether this device can take photos with a camera.
  bool get cameraAvailable;

  /// Returns null when the user cancels.
  /// Throws [PhotoSourceException] when the photo cannot be obtained.
  Future<PlantPhoto?> pick(PhotoOrigin origin);
}

class PhotoSourceException implements Exception {
  const PhotoSourceException([this.message = 'No se pudo obtener la foto.']);

  final String message;

  @override
  String toString() => 'PhotoSourceException: $message';
}
