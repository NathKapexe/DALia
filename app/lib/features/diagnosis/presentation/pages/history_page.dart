import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/diagnosis_record.dart';
import '../labels.dart';
import '../state/diagnosis_controller.dart';
import 'result_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key, required this.controller});

  final DiagnosisController controller;

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/${dt.year} • $hour:$min';
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar historial'),
        content: const Text('¿Seguro que deseas eliminar todas las consultas guardadas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Borrar todo'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final records = controller.historyRecords;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Consultas anteriores'),
            actions: [
              if (records.isNotEmpty)
                IconButton(
                  tooltip: 'Vaciar historial',
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: () => _confirmClearAll(context),
                ),
            ],
          ),
          body: SafeArea(
            child: records.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history_toggle_off_rounded,
                            size: 64,
                            color: colors.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aún no tienes consultas guardadas',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cada vez que analices una hoja de tomate, el diagnóstico aparecerá aquí automáticamente.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final record = records[index];
                          return _HistoryItemCard(
                            record: record,
                            formattedDate: _formatDate(record.createdAt),
                            onTap: () {
                              controller.openRecord(record);
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ResultPage(controller: controller),
                                ),
                              );
                            },
                            onDelete: () => controller.deleteHistoryRecord(record.id),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  const _HistoryItemCard({
    required this.record,
    required this.formattedDate,
    required this.onTap,
    required this.onDelete,
  });

  final DiagnosisRecord record;
  final String formattedDate;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final topCandidate = record.diagnosis.candidates.firstOrNull;
    final photoFile = File(record.photoPath);
    final hasPhoto = photoFile.existsSync();

    final percentage = topCandidate != null
        ? '${(topCandidate.score.clamp(0.0, 1.0) * 100).round()}%'
        : '';

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Miniatura de la hoja
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 68,
                  height: 68,
                  child: hasPhoto
                      ? Image.file(photoFile, fit: BoxFit.cover, cacheWidth: 200)
                      : ColoredBox(
                          color: colors.surfaceContainerHighest,
                          child: Icon(Icons.local_florist_outlined, color: colors.outline),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              // Información del diagnóstico principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topCandidate?.cause.name ?? 'Sin resultado claro',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    if (topCandidate != null)
                      Text(
                        '${categoryLabel(topCandidate.cause.category)} • $percentage coincidencia',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Eliminar',
                icon: Icon(Icons.delete_outline_rounded, color: colors.onSurfaceVariant),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}