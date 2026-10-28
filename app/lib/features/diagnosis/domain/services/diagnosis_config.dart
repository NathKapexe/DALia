/// Tunable parameters of the diagnosis engine.
///
/// They are design parameters, not learned values: adjust them using real
/// evaluation data.
class DiagnosisConfig {
  const DiagnosisConfig({
    this.imageWeight = 0.6,
    this.contextWeight = 0.4,
    this.maxCandidates = 5,
    this.minScore = 0.05,
    this.highThreshold = 0.6,
    this.mediumThreshold = 0.35,
    this.noneDampening = 0.5,
  });

  /// Weight of the image evidence when a photo analysis is available.
  final double imageWeight;

  /// Weight of the context answers when a photo analysis is available.
  final double contextWeight;

  final int maxCandidates;

  /// Candidates below this score are discarded.
  final double minScore;

  /// Top score needed for [ConfidenceLevel.high].
  final double highThreshold;

  /// Top score needed for [ConfidenceLevel.medium].
  final double mediumThreshold;

  /// Multiplier applied to the "no clear symptoms" cause when the user ticked
  /// at least one symptom (the model tends to over-report "healthy").
  final double noneDampening;
}
