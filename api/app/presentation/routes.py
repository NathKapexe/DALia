from fastapi import APIRouter, File, HTTPException, Request, UploadFile
from pydantic import BaseModel

from app.domain.ports import InvalidImageError

MAX_UPLOAD_BYTES = 10 * 1024 * 1024
ALLOWED_CONTENT_TYPES = {"image/jpeg", "image/png", "image/webp"}

router = APIRouter()


class FindingOut(BaseModel):
    label: str
    confidence: float


class AnalyzeResponse(BaseModel):
    version: str
    findings: list[FindingOut]


@router.get("/health")
def health(request: Request) -> dict:
    return {"status": "ok", "version": request.app.state.model_version}


@router.post("/analyze", response_model=AnalyzeResponse)
def analyze(request: Request, photo: UploadFile = File(...)) -> AnalyzeResponse:
    if photo.content_type not in ALLOWED_CONTENT_TYPES:
        raise HTTPException(status_code=415, detail="Formato no admitido. Usa JPEG, PNG o WebP.")

    data = photo.file.read(MAX_UPLOAD_BYTES + 1)
    if len(data) > MAX_UPLOAD_BYTES:
        raise HTTPException(status_code=413, detail="La imagen supera el tamaño máximo de 10 MB.")

    try:
        findings = request.app.state.analyze_image.execute(data)
    except InvalidImageError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    return AnalyzeResponse(
        version=request.app.state.model_version,
        findings=[FindingOut(label=f.label, confidence=f.confidence) for f in findings],
    )
