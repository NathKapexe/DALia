import 'package:flutter/material.dart';

import '../labels.dart';
import '../state/diagnosis_controller.dart';
import '../widgets/candidate_card.dart';
import '../widgets/info_banner.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.controller});

  final DiagnosisController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final diagnosis = controller.diagnosis;
        if (diagnosis == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Posibles causas')),
            body: const Center(child: Text('Todavía no hay resultado.')),
          );
        }

        final error = controller.status == DiagnosisStatus.failure
            ? controller.errorMessage
            : null;

        return Scaffold(
          appBar: AppBar(title: const Text('Posibles causas')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (diagnosis.needsOnlineRefinement)
                  InfoBanner(
                    icon: Icons.cloud_off,
                    message: 'Sin conexión con el análisis de la foto. Este resultado usa '
                        'solo tus respuestas. Cuando tengas conexión, reintenta para sumar '
                        'lo que ve la foto.',
                    action: FilledButton(
                      onPressed: controller.isAnalyzing ? null : controller.analyze,
                      child: Text(controller.isAnalyzing ? 'Analizando…' : 'Reintentar'),
                    ),
                  ),
                if (error != null)
                  InfoBanner(message: error, icon: Icons.error_outline, isError: true),
                Text(levelMessage(diagnosis.level), style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                if (diagnosis.candidates.isEmpty)
                  const Text(emptyResultMessage)
                else
                  for (var i = 0; i < diagnosis.candidates.length; i++)
                    CandidateCard(
                      candidate: diagnosis.candidates[i],
                      initiallyExpanded: i == 0,
                    ),
                const SizedBox(height: 8),
                Text(disclaimer, style: theme.textTheme.bodySmall),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () {
                    controller.reset();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Nueva consulta'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
