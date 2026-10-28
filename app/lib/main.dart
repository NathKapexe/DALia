import 'package:flutter/material.dart';

import 'app.dart';
import 'features/diagnosis/data/datasources/image_picker_photo_source.dart';
import 'features/diagnosis/diagnosis_module.dart';
import 'features/diagnosis/presentation/state/diagnosis_controller.dart';

/// Composition root of the app: the only place that wires the concrete classes.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = DiagnosisController(
    analyzePlantPhoto: buildAnalyzePlantPhoto(),
    photoSource: ImagePickerPhotoSource(),
  );

  runApp(DaliaApp(controller: controller));
}
