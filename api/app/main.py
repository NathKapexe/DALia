import os
from pathlib import Path

from app.factory import create_app
from app.infrastructure.torch_classifier import TorchMobileNetClassifier

_DEFAULT_MODEL = Path(__file__).resolve().parent.parent / "models" / "dalia_tomato_v2b.pth"
_model_path = Path(os.environ.get("DALIA_MODEL_PATH", _DEFAULT_MODEL))

if not _model_path.is_file():
    raise SystemExit(
        f"No se encontro el modelo en: {_model_path}\n"
        "Copia dalia_tomato_v2b.pth a la carpeta models/ o define DALIA_MODEL_PATH."
    )

# Composition root: the only place that knows the concrete classes.
app = create_app(TorchMobileNetClassifier(str(_model_path)))
