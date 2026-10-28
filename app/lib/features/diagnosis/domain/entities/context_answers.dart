/// State of the soil, as reported by the user.
enum SoilState { waterlogged, moist, dry, veryDry }

/// Amount of light the plant receives.
enum LightLevel { fullSun, partial, low }

/// Symptoms the user can tick (several at once).
enum Symptom {
  yellowLeaves,
  dryTips,
  spots,
  wilting,
  moldOrPowder,
  visibleInsects,
  curledOrDeformed,
}

/// Answers to the 2-3 context questions that accompany the photo.
///
/// Every answer is optional: the user may skip any question.
class ContextAnswers {
  const ContextAnswers({
    this.soil,
    this.light,
    this.symptoms = const <Symptom>{},
  });

  final SoilState? soil;
  final LightLevel? light;
  final Set<Symptom> symptoms;

  /// Signals the diagnosis engine matches against each cause's indicators.
  /// Format: `soil:waterlogged`, `light:low`, `symptom:spots`.
  Set<String> get signals => {
        if (soil != null) 'soil:${soil!.name}',
        if (light != null) 'light:${light!.name}',
        for (final s in symptoms) 'symptom:${s.name}',
      };
}
