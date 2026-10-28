import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart' show PlatformException;
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/plant_photo.dart';
import '../../domain/repositories/photo_source.dart';

/// Adapts the `image_picker` plugin to the domain's [PhotoSource] port.
///
/// On desktop (Windows) only the file picker is available, so the camera
/// option is hidden by the UI.
class ImagePickerPhotoSource implements PhotoSource {
  ImagePickerPhotoSource({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  bool get cameraAvailable =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<PlantPhoto?> pick(PhotoOrigin origin) async {
    if (origin == PhotoOrigin.camera && !cameraAvailable) {
      throw const PhotoSourceException('La cámara no está disponible en este dispositivo.');
    }
    try {
      // The model works at 224x224, so a moderate size is plenty and keeps
      // the upload small (the API accepts up to 10 MB).
      final file = await _picker.pickImage(
        source: origin == PhotoOrigin.camera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      return file == null ? null : PlantPhoto(file.path);
    } on PlatformException {
      throw const PhotoSourceException('No se pudo abrir la cámara o la galería.');
    }
  }
}
