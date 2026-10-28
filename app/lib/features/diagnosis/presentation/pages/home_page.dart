import 'package:flutter/material.dart';

import '../../domain/repositories/photo_source.dart';
import '../state/diagnosis_controller.dart';
import 'questions_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.controller});

  final DiagnosisController controller;

  Future<void> _choose(BuildContext context, PhotoOrigin origin) async {
    final picked = await controller.choosePhoto(origin);
    if (!context.mounted) return;

    final error = controller.errorMessage;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      controller.clearError();
      return;
    }
    if (picked) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => QuestionsPage(controller: controller)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Dalia')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.local_florist, size: 72, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    '¿Qué le pasa a tu planta?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Toma una foto de cerca de una hoja afectada: que la hoja ocupe '
                    'casi toda la imagen y haya buena luz. Por ahora funciona con tomate.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (controller.cameraAvailable) ...[
                    FilledButton.icon(
                      onPressed: () => _choose(context, PhotoOrigin.camera),
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Tomar foto'),
                    ),
                    const SizedBox(height: 12),
                  ],
                  OutlinedButton.icon(
                    onPressed: () => _choose(context, PhotoOrigin.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Elegir una foto'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
