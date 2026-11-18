import 'package:flutter/material.dart';

import '../../domain/entities/diagnosis.dart';
import '../labels.dart';

class CauseDetailPage extends StatelessWidget {
  const CauseDetailPage({super.key, required this.candidate});

  final CauseCandidate candidate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final cause = candidate.cause;
    final percentage = (candidate.score.clamp(0.0, 1.0) * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: Text(cause.name),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con categoría y porcentaje
                Row(
                  children: [
                    Chip(
                      label: Text(categoryLabel(cause.category)),
                      backgroundColor: colors.secondaryContainer,
                      side: BorderSide.none,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$percentage% coincidencia',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Descripción general
                Text(
                  cause.summary,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 24),

                // 1. Razones del porqué
                if (candidate.evidence.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.psychology_outlined,
                    title: '¿Por qué mi planta tiene esto?',
                    color: colors.primary,
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 0,
                    color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final evidence in candidate.evidence)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      size: 18, color: colors.primary),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(evidenceLabel(evidence))),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 2. Soluciones y tratamiento
                if (cause.treatmentSteps.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.healing_rounded,
                    title: 'Cómo solucionarlo',
                    color: colors.primary,
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < cause.treatmentSteps.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              cause.treatmentSteps[i],
                              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                ],

                // 3. Cuidados y recuperación
                if (cause.precautions.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.spa_outlined,
                    title: 'Cuidados para su recuperación',
                    color: colors.tertiary,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.tertiaryContainer.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.tertiary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final precaution in cause.precautions)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.eco_rounded, size: 18, color: colors.tertiary),
                                const SizedBox(width: 10),
                                Expanded(child: Text(precaution)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}