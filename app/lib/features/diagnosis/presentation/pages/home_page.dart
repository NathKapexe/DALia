import 'package:flutter/material.dart';

import '../../domain/repositories/photo_source.dart';
import '../state/diagnosis_controller.dart';
import 'questions_page.dart';
import 'history_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.controller});

  final DiagnosisController controller;

  Future<void> _choose(BuildContext context, PhotoOrigin origin) async {
    final picked = await controller.choosePhoto(origin);
    if (!context.mounted) return;

    final error = controller.errorMessage;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(error)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
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
    final colors = theme.colorScheme;

  return Scaffold(
      appBar: AppBar(
        title: const Text('DALia', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Historial de consultas',
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => HistoryPage(controller: controller),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Emblema principal con fondo suave
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_florist_rounded,
                        size: 68,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '¿Qué le pasa a tu planta?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Analiza las hojas de tu cultivo de tomate para detectar plagas o enfermedades al instante.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Caja de consejos rápidos
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, color: colors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tip: Acerca la cámara a una hoja afectada con buena iluminación.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 3. Tarjetas de acción (Cámara y Galería)
                  if (controller.cameraAvailable) ...[
                    _ActionOptionCard(
                      icon: Icons.photo_camera_rounded,
                      title: 'Tomar una foto',
                      subtitle: 'Usa la cámara en tiempo real',
                      isPrimary: true,
                      onTap: () => _choose(context, PhotoOrigin.camera),
                    ),
                    const SizedBox(height: 14),
                  ],
                  _ActionOptionCard(
                    icon: Icons.photo_library_rounded,
                    title: 'Elegir de la galería',
                    subtitle: 'Sube una imagen guardada en tu dispositivo',
                    isPrimary: !controller.cameraAvailable,
                    onTap: () => _choose(context, PhotoOrigin.gallery),
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

class _ActionOptionCard extends StatelessWidget {
  const _ActionOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isPrimary,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: isPrimary ? 2 : 0,
      color: isPrimary ? colors.primary : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPrimary
            ? BorderSide.none
            : BorderSide(color: colors.outlineVariant, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? colors.onPrimary.withValues(alpha: 0.15)
                      : colors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: isPrimary ? colors.onPrimary : colors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPrimary ? colors.onPrimary : colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isPrimary
                            ? colors.onPrimary.withValues(alpha: 0.85)
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isPrimary ? colors.onPrimary : colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
