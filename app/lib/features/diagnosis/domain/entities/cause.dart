enum CauseCategory { disease, pest, watering, light, nutrition, none }

/// A possible cause of a plant problem, with its explanation and treatment.
///
/// Instances come from the knowledge base (data layer).
class Cause {
  const Cause({
    required this.id,
    required this.name,
    required this.category,
    required this.summary,
    required this.treatmentSteps,
    this.precautions = const <String>[],
    this.modelLabels = const <String>[],
    this.indicators = const <String, double>{},
  });

  final String id;
  final String name;
  final CauseCategory category;

  /// Plain-language explanation shown to the user.
  final String summary;
  final List<String> treatmentSteps;
  final List<String> precautions;

  /// Image-model classes that point to this cause.
  final List<String> modelLabels;

  /// Context signal -> weight. See `ContextAnswers.signals`.
  final Map<String, double> indicators;
}
