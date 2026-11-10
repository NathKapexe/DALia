from app.domain.entities import Finding
from app.domain.ports import ImageClassifier, InvalidImageError
from app.infrastructure.prolog_adapter import PrologAdapter


class AnalyzeImage:
    """Use case: image bytes + context -> findings + expert diagnosis from Prolog."""

    def __init__(self, classifier: ImageClassifier, prolog_adapter: PrologAdapter = None) -> None:
        self._classifier = classifier
        # Inyectamos el adaptador de Prolog (si no se pasa uno, crea uno por defecto)
        self._prolog_adapter = prolog_adapter or PrologAdapter()

    def execute(self, image_bytes: bytes, sintomas: list[str] = None, suelo: str = None, luz: str = None) -> dict:
        if not image_bytes:
            raise InvalidImageError("La imagen está vacía.")
        
        # 1. Clasificación visual con PyTorch
        findings = self._classifier.classify(image_bytes)
        sorted_findings = sorted(findings, key=lambda f: f.confidence, reverse=True)
        
        # 2. Convertimos los findings ordenados en formato de tuplas para Prolog
        etiquetas_modelo = [(f.label, f.confidence) for f in sorted_findings]

        # 3. Consultamos al Sistema Experto de Prolog con la imagen y el contexto
        expert_result = self._prolog_adapter.consultar_diagnostico(
            etiquetas_modelo=etiquetas_modelo,
            sintomas=sintomas or [],
            suelo=suelo,
            luz=luz
        )

        # 4. Retornamos un diccionario unificado para la API
        return {
            "findings": sorted_findings,
            "expert_diagnosis": expert_result
        }