import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'features/diagnosis/data/datasources/image_picker_photo_source.dart';
import 'features/diagnosis/data/repositories/local_history_repository.dart';
import 'features/diagnosis/diagnosis_module.dart';
import 'features/diagnosis/presentation/state/diagnosis_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = DiagnosisController(
    analyzePlantPhoto: buildAnalyzePlantPhoto(),
    photoSource: ImagePickerPhotoSource(),
    historyRepository: kIsWeb ? null : LocalHistoryRepository(),
  );

  if (!kIsWeb) {
    await controller.loadHistory();
  }

  runApp(DaliaApp(controller: controller));
}