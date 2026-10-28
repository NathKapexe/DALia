from fastapi import FastAPI

from app.application.analyze_image import AnalyzeImage
from app.domain.ports import ImageClassifier
from app.presentation.routes import router


def create_app(classifier: ImageClassifier) -> FastAPI:
    """Build the app around any ImageClassifier (real or fake in tests)."""
    app = FastAPI(title="Dalia API", version="0.1.0")
    app.state.analyze_image = AnalyzeImage(classifier)
    app.state.model_version = classifier.model_version
    app.include_router(router)
    return app
