import io

import pytest

torch = pytest.importorskip("torch")

from PIL import Image  # noqa: E402
from torch import nn  # noqa: E402
from torchvision import models  # noqa: E402

from app.domain.ports import InvalidImageError  # noqa: E402
from app.infrastructure.torch_classifier import TorchMobileNetClassifier  # noqa: E402

CLASSES = ["Tomato___A", "Tomato___B", "Tomato___healthy"]


@pytest.fixture()
def classifier(tmp_path):
    net = models.mobilenet_v2(weights=None)
    net.classifier[1] = nn.Linear(net.classifier[1].in_features, len(CLASSES))
    path = tmp_path / "tiny.pth"
    torch.save({"state_dict": net.state_dict(), "class_names": CLASSES, "version": "test"}, path)
    return TorchMobileNetClassifier(str(path))


def _jpeg_bytes() -> bytes:
    buffer = io.BytesIO()
    Image.new("RGB", (64, 48), (30, 120, 40)).save(buffer, format="JPEG")
    return buffer.getvalue()


def test_classify_returns_one_finding_per_class_sorted(classifier):
    findings = classifier.classify(_jpeg_bytes())
    assert {f.label for f in findings} == set(CLASSES)
    assert [f.confidence for f in findings] == sorted(
        (f.confidence for f in findings), reverse=True
    )
    assert sum(f.confidence for f in findings) == pytest.approx(1.0, abs=1e-4)
    assert classifier.model_version == "test"


def test_garbage_bytes_raise_invalid_image(classifier):
    with pytest.raises(InvalidImageError):
        classifier.classify(b"esto no es una imagen")
