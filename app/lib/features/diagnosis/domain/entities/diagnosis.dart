import 'cause.dart';

enum ConfidenceLevel { low, medium, high }

/// A candidate cause with its relevance score.
///
/// `score` is a relevance value between 0 and 1, NOT a probability.
class CauseCandidate {
  const CauseCandidate({
    required this.cause,
    required this.score,
    this.evidence = const <String>[],
  });

  final Cause cause;
  final double score;

  /// Codes such as `image:Tomato___Late_blight` or `context:symptom:spots`.
  /// The presentation layer turns them into text.
  final List<String> evidence;
}

class Diagnosis {
  const Diagnosis({
    required this.candidates,
    required this.level,
    required this.usedImage,
  });

  /// Sorted from most to least relevant.
  final List<CauseCandidate> candidates;
  final ConfidenceLevel level;

  /// False when the image analyzer was unavailable (no connection).
  final bool usedImage;

  /// When true the app should offer to refine the result once back online.
  bool get needsOnlineRefinement => !usedImage;
}
