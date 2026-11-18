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
    final colors = theme.colorScheme;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final answers = controller.answers;
        final error = controller.status == DiagnosisStatus.failure
            ? controller.errorMessage
            : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Cuéntanos más'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PhotoPreview(
                        path: controller.photo?.path,
                        onChangePhoto: controller.isAnalyzing ? null : () => Navigator.of(context).pop(),),
                      const SizedBox(height: 16),
                      if (error != null) ...[
                        InfoBanner(
                          message: error,
                          icon: Icons.error_outline,
                          isError: true,
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        'Estos detalles ayudan a afinar el diagnóstico (puedes omitir los que no sepas):',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 1. Pregunta: Tierra
                      _QuestionCard(
                        icon: Icons.water_drop_outlined,
                        title: '¿Cómo está la tierra?',
                        subtitle: 'Elige una opción',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final soil in SoilState.values)
                              ChoiceChip(
                                label: Text(soilLabel(soil)),
                                selected: answers.soil == soil,
                                onSelected: controller.isAnalyzing
                                    ? null
                                    : (selected) =>
                                        controller.setSoil(selected ? soil : null),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2. Pregunta: Luz
                      _QuestionCard(
                        icon: Icons.wb_sunny_outlined,
                        title: '¿Cuánta luz recibe?',
                        subtitle: 'Elige una opción',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final light in LightLevel.values)
                              ChoiceChip(
                                label: Text(lightLabel(light)),
                                selected: answers.light == light,
                                onSelected: controller.isAnalyzing
                                    ? null
                                    : (selected) =>
                                        controller.setLight(selected ? light : null),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 3. Pregunta: Síntomas
                      _QuestionCard(
                        icon: Icons.eco_outlined,
                        title: '¿Qué síntomas ves?',
                        subtitle: 'Puedes marcar varios',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final symptom in Symptom.values)
                              FilterChip(
                                label: Text(symptomLabel(symptom)),
                                selected: answers.symptoms.contains(symptom),
                                onSelected: controller.isAnalyzing
                                    ? null
                                    : (_) => controller.toggleSymptom(symptom),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Barra inferior fija para mantener el botón siempre accesible
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(
                  top: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.6)),
                ),
              ),
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: controller.isAnalyzing ? null : () => _analyze(context),
                      icon: controller.isAnalyzing
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: colors.onSurfaceVariant,
                              ),
                            )
                          : const Icon(Icons.auto_awesome_rounded),
                      label: Text(
                        controller.isAnalyzing ? 'Analizando planta…' : 'Analizar planta',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: colors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}