import io

import torch
from PIL import Image, ImageOps, UnidentifiedImageError
from torch import nn
from torchvision import models, transforms

from app.domain.entities import Finding
from app.domain.ports import InvalidImageError

# Images with more pixels than this are rejected before decoding them.
MAX_PIXELS = 50_000_000

_MEAN = [0.485, 0.456, 0.406]
_STD = [0.229, 0.224, 0.225]


class TorchMobileNetClassifier:
    """Adapter: loads a MobileNetV2 checkpoint saved by the Dalia notebook.

    Expected checkpoint: {"state_dict", "class_names", optional "version"}.
    Preprocessing is the same used to evaluate the model in the notebook
    (resize to 224x224, ImageNet normalization), plus EXIF orientation fix,
    because phone photos are often stored rotated.
    """

    def __init__(self, checkpoint_path: str, device: str = "cpu") -> None:
        checkpoint = torch.load(checkpoint_path, map_location=device, weights_only=True)
        self._class_names: list[str] = list(checkpoint["class_names"])
        self.model_version: str = str(checkpoint.get("version", "unknown"))

        net = models.mobilenet_v2(weights=None)
        net.classifier[1] = nn.Linear(net.classifier[1].in_features, len(self._class_names))
        net.load_state_dict(checkpoint["state_dict"])

        self._device = device
        self._net = net.to(device).eval()
        self._transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize(_MEAN, _STD),
        ])

    def classify(self, image_bytes: bytes) -> list[Finding]:
        image = self._decode(image_bytes)
        tensor = self._transform(image).unsqueeze(0).to(self._device)
        with torch.inference_mode():
            probs = torch.softmax(self._net(tensor), dim=1)[0].tolist()
        findings = [Finding(name, p) for name, p in zip(self._class_names, probs)]
        return sorted(findings, key=lambda f: f.confidence, reverse=True)

    @staticmethod
    def _decode(image_bytes: bytes) -> Image.Image:
        try:
            image = Image.open(io.BytesIO(image_bytes))
            if image.width * image.height > MAX_PIXELS:
                raise InvalidImageError("La imagen tiene demasiados píxeles.")
            image.load()
        except InvalidImageError:
            raise
        except (UnidentifiedImageError, OSError, Image.DecompressionBombError) as exc:
            raise InvalidImageError("No se pudo leer la imagen.") from exc
        return ImageOps.exif_transpose(image).convert("RGB")
