/// One result produced by the image model, e.g. `Tomato___Late_blight`, 0.56.
///
/// `confidence` is NOT a calibrated probability. Treat it as a relative signal.
class VisualFinding {
  const VisualFinding({required this.label, required this.confidence})
      : assert(confidence >= 0 && confidence <= 1);

  /// Class name exactly as the model reports it.
  final String label;

  /// Value between 0 and 1.
  final double confidence;
}
