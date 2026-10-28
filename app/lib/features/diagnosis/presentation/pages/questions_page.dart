import 'package:flutter/material.dart';

import '../../domain/entities/context_answers.dart';
import '../labels.dart';
import '../state/diagnosis_controller.dart';
import '../widgets/info_banner.dart';
import '../widgets/photo_preview.dart';
import 'result_page.dart';

class QuestionsPage extends StatelessWidget {
  const QuestionsPage({super.key, required this.controller});

  final DiagnosisController controller;

  Future<void> _analyze(BuildContext context) async {
    await controller.analyze();
    if (!context.mounted) return;
    if (controller.status == DiagnosisStatus.done) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ResultPage(controller: controller)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final answers = controller.answers;
        final error = controller.status == DiagnosisStatus.failure
            ? controller.errorMessage
            : null;

        return Scaffold(
          appBar: AppBar(title: const Text('Cuéntanos más')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PhotoPreview(path: controller.photo?.path),
                  const SizedBox(height: 16),
                  if (error != null)
                    InfoBanner(message: error, icon: Icons.error_outline, isError: true),
                  Text('¿Cómo está la tierra?', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final soil in SoilState.values)
                        ChoiceChip(
                          label: Text(soilLabel(soil)),
                          selected: answers.soil == soil,
                          onSelected: (selected) =>
                              controller.setSoil(selected ? soil : null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('¿Cuánta luz recibe?', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final light in LightLevel.values)
                        ChoiceChip(
                          label: Text(lightLabel(light)),
                          selected: answers.light == light,
                          onSelected: (selected) =>
                              controller.setLight(selected ? light : null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('¿Qué síntomas ves?', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final symptom in Symptom.values)
                        FilterChip(
                          label: Text(symptomLabel(symptom)),
                          selected: answers.symptoms.contains(symptom),
                          onSelected: (_) => controller.toggleSymptom(symptom),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: controller.isAnalyzing ? null : () => _analyze(context),
                    icon: const Icon(Icons.search),
                    label: Text(controller.isAnalyzing ? 'Analizando…' : 'Analizar'),
                  ),
                  if (controller.isAnalyzing) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
