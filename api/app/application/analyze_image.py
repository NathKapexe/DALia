from app.domain.entities import Finding
from app.domain.ports import ImageClassifier, InvalidImageError


class AnalyzeImage:
    """Use case: image bytes -> findings sorted from most to least confident."""

    def __init__(self, classifier: ImageClassifier) -> None:
        self._classifier = classifier

    def execute(self, image_bytes: bytes) -> list[Finding]:
        if not image_bytes:
            raise InvalidImageError("La imagen está vacía.")
        findings = self._classifier.classify(image_bytes)
        return sorted(findings, key=lambda f: f.confidence, reverse=True)
