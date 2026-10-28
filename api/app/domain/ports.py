from typing import Protocol

from app.domain.entities import Finding


class InvalidImageError(Exception):
    """The bytes received are not a usable image."""


class ImageClassifier(Protocol):
    """Port to the image model. Infrastructure implements it."""

    model_version: str

    def classify(self, image_bytes: bytes) -> list[Finding]:
        """Return one Finding per class. Raise InvalidImageError if the image is unusable."""
        ...
