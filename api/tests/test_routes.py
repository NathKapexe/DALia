import io

from fastapi.testclient import TestClient
from PIL import Image

from app.domain.entities import Finding
from app.domain.ports import InvalidImageError
from app.factory import create_app
from app.presentation.routes import MAX_UPLOAD_BYTES


class FakeClassifier:
    model_version = "fake"

    def classify(self, image_bytes: bytes) -> list[Finding]:
        return [Finding("B", 0.2), Finding("A", 0.8)]


class RejectingClassifier(FakeClassifier):
    def classify(self, image_bytes: bytes) -> list[Finding]:
        raise InvalidImageError("No se pudo leer la imagen.")


def _png_bytes() -> bytes:
    buffer = io.BytesIO()
    Image.new("RGB", (8, 8), "green").save(buffer, format="PNG")
    return buffer.getvalue()


def _client(classifier=None) -> TestClient:
    return TestClient(create_app(classifier or FakeClassifier()))


def test_health():
    response = _client().get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok", "version": "fake"}


def test_analyze_returns_sorted_findings():
    response = _client().post(
        "/analyze", files={"photo": ("leaf.png", _png_bytes(), "image/png")}
    )
    assert response.status_code == 200
    body = response.json()
    assert body["version"] == "fake"
    assert [f["label"] for f in body["findings"]] == ["A", "B"]


def test_unsupported_content_type_is_415():
    response = _client().post("/analyze", files={"photo": ("a.txt", b"hola", "text/plain")})
    assert response.status_code == 415


def test_oversized_upload_is_413():
    big = b"0" * (MAX_UPLOAD_BYTES + 1)
    response = _client().post("/analyze", files={"photo": ("big.png", big, "image/png")})
    assert response.status_code == 413


def test_unreadable_image_is_400():
    response = _client(RejectingClassifier()).post(
        "/analyze", files={"photo": ("bad.png", b"garbage", "image/png")}
    )
    assert response.status_code == 400


def test_missing_field_is_422():
    response = _client().post("/analyze")
    assert response.status_code == 422
