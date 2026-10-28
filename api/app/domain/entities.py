from dataclasses import dataclass


@dataclass(frozen=True)
class Finding:
    """One class predicted by the image model.

    `confidence` is a relative signal, NOT a calibrated probability.
    """

    label: str
    confidence: float
