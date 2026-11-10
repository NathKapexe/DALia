from fastapi import APIRouter, File, HTTPException, Request, UploadFile, Form
from typing import Optional
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
    expert_diagnosis: Optional[dict] = None  # Añadimos esto opcional por si Prolog devuelve el dict


@router.get("/health")
def health(request: Request) -> dict:
    return {"status": "ok", "version": request.app.state.model_version}


@router.post("/analyze", response_model=AnalyzeResponse)
def analyze(
    request: Request,
    photo: UploadFile = File(...),
    sintomas: Optional[str] = Form(None),  # <--- Nuevo: Recibe los síntomas de la app
    suelo: Optional[str] = Form(None),     # <--- Nuevo: Estado de la tierra
    luz: Optional[str] = Form(None)        # <--- Nuevo: Estado de la luz
) -> AnalyzeResponse:
    if photo.content_type not in ALLOWED_CONTENT_TYPES:
        raise HTTPException(status_code=415, detail="Formato no admitido. Usa JPEG, PNG o WebP.")

    data = photo.file.read(MAX_UPLOAD_BYTES + 1)
    if len(data) > MAX_UPLOAD_BYTES:
        raise HTTPException(status_code=413, detail="La imagen supera el tamaño máximo de 10 MB.")

    try:
        # Convertimos los síntomas a lista si el usuario los mandó
        lista_sintomas = [s.strip() for s in sintomas.split(",")] if sintomas else []

        # Invocamos el caso de uso pasándole también el contexto para Prolog
        findings = request.app.state.analyze_image.execute(
            data, 
            sintomas=lista_sintomas, 
            suelo=suelo, 
            luz=luz
        )
    except InvalidImageError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    return AnalyzeResponse(
        version=request.app.state.model_version,
        findings=[FindingOut(label=f.label, confidence=f.confidence) for f in findings],
    )