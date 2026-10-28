import 'package:flutter/material.dart';

import '../../domain/entities/diagnosis.dart';
import '../labels.dart';

/// One probable cause: name, category, relevance bar and, when expanded,
/// explanation, treatment steps, precautions and the evidence behind it.
class CandidateCard extends StatelessWidget {
  const CandidateCard({
    super.key,
    required this.candidate,
    this.initiallyExpanded = false,
  });

  final CauseCandidate candidate;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cause = candidate.cause;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        title: Text(cause.name, style: theme.textTheme.titleMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(categoryLabel(cause.category)),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: candidate.score.clamp(0.0, 1.0).toDouble()),
            ],
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cause.summary),
          const SizedBox(height: 12),
          Text('Qué hacer', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          for (var i = 0; i < cause.treatmentSteps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('${i + 1}. ${cause.treatmentSteps[i]}'),
            ),
          if (cause.precautions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Ten en cuenta', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            for (final precaution in cause.precautions)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $precaution'),
              ),
          ],
          if (candidate.evidence.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Por qué aparece aquí', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            for (final evidence in candidate.evidence)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• ${evidenceLabel(evidence)}'),
              ),
          ],
        ],
      ),
    );
  }
}
