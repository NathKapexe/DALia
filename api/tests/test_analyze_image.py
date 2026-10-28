import pytest

from app.application.analyze_image import AnalyzeImage
from app.domain.entities import Finding
from app.domain.ports import InvalidImageError


class FakeClassifier:
    model_version = "fake"

    def classify(self, image_bytes: bytes) -> list[Finding]:
        return [Finding("B", 0.2), Finding("A", 0.8), Finding("C", 0.5)]


def test_returns_findings_sorted_by_confidence():
    findings = AnalyzeImage(FakeClassifier()).execute(b"not empty")
    assert [f.label for f in findings] == ["A", "C", "B"]


def test_rejects_empty_input():
    with pytest.raises(InvalidImageError):
        AnalyzeImage(FakeClassifier()).execute(b"")
