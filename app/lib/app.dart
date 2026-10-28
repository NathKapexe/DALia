import 'package:flutter/material.dart';

import 'features/diagnosis/presentation/pages/home_page.dart';
import 'features/diagnosis/presentation/state/diagnosis_controller.dart';

class DaliaApp extends StatelessWidget {
  const DaliaApp({super.key, required this.controller});

  final DiagnosisController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dalia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: HomePage(controller: controller),
    );
  }
}
