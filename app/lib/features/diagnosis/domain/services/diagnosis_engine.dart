import '../entities/cause.dart';
import '../entities/context_answers.dart';
import '../entities/diagnosis.dart';
import '../entities/visual_finding.dart';
import 'diagnosis_config.dart';

/// Pure business logic: combines image findings, context answers and the
/// knowledge base into a ranked list of probable causes.
///
/// It has no dependency on Flutter, the network or storage.
///
/// Score per cause:
///  * with image:    imageWeight * imageScore + contextWeight * contextScore
///  * without image: contextScore
///
/// imageScore   = highest confidence among findings whose label is in
///                `cause.modelLabels`.
/// contextScore = matched indicator weights / total indicator weights.
class DiagnosisEngine {
  const DiagnosisEngine([this.config = const DiagnosisConfig()]);

  final DiagnosisConfig config;

  Diagnosis diagnose({
    required List<Cause> causes,
    required List<VisualFinding> findings,
    required ContextAnswers answers,
    required bool imageAvailable,
  }) {
    final signals = answers.signals;
    final userReportedSymptoms = signals.any((s) => s.startsWith('symptom:'));
    final candidates = <CauseCandidate>[];

    for (final cause in causes) {
      final image = imageAvailable ? _imageScore(cause, findings) : 0.0;
      final context = _contextScore(cause, signals);

      var score = imageAvailable
          ? config.imageWeight * image + config.contextWeight * context
          : context;

      if (cause.category == CauseCategory.none && userReportedSymptoms) {
        score *= config.noneDampening;
      }
      if (score < config.minScore) continue;

      candidates.add(CauseCandidate(
        cause: cause,
        score: score,
        evidence: _evidence(cause, findings, signals, imageAvailable),
      ));
    }

    candidates.sort((a, b) => b.score.compareTo(a.score));
    final top = candidates.take(config.maxCandidates).toList();

    return Diagnosis(
      candidates: top,
      level: _level(top),
      usedImage: imageAvailable,
    );
  }

  double _imageScore(Cause cause, List<VisualFinding> findings) {
    var best = 0.0;
    for (final finding in findings) {
      if (cause.modelLabels.contains(finding.label) && finding.confidence > best) {
        best = finding.confidence;
      }
    }
    return best;
  }

  double _contextScore(Cause cause, Set<String> signals) {
    var total = 0.0;
    var matched = 0.0;
    cause.indicators.forEach((signal, weight) {
      total += weight;
      if (signals.contains(signal)) matched += weight;
    });
    return total == 0 ? 0.0 : matched / total;
  }

  List<String> _evidence(
    Cause cause,
    List<VisualFinding> findings,
    Set<String> signals,
    bool imageAvailable,
  ) {
    final evidence = <String>[];
    if (imageAvailable) {
      for (final finding in findings) {
        if (cause.modelLabels.contains(finding.label)) {
          evidence.add('image:${finding.label}');
        }
      }
    }
    for (final signal in cause.indicators.keys) {
      if (signals.contains(signal)) evidence.add('context:$signal');
    }
    return evidence;
  }

  ConfidenceLevel _level(List<CauseCandidate> top) {
    if (top.isEmpty) return ConfidenceLevel.low;
    final best = top.first.score;
    if (best >= config.highThreshold) return ConfidenceLevel.high;
    if (best >= config.mediumThreshold) return ConfidenceLevel.medium;
    return ConfidenceLevel.low;
  }
}
