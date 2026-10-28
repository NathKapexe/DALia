# Dalia API (prototipo)

Servidor en Python (FastAPI) que carga el modelo entrenado y, dada una foto, devuelve los hallazgos del modelo. La app los combina con las respuestas de contexto en el motor de diagnóstico.

**Estado: prototipo / desarrollo.** No es apto para producción (ver "Limitaciones").

## Estructura (Clean Architecture)
```
api/
├── models/                  aquí va dalia_tomato_v2b.pth
├── app/
│   ├── domain/              Finding, puerto ImageClassifier, InvalidImageError
│   ├── application/         caso de uso AnalyzeImage
│   ├── infrastructure/      TorchMobileNetClassifier (carga el .pth)
│   ├── presentation/        rutas HTTP (FastAPI)
│   ├── factory.py           create_app(classifier)
│   └── main.py              composición: único lugar que conoce las clases concretas
└── tests/
```
Dependencias hacia adentro: presentation -> application -> domain <- infrastructure.

## Puesta en marcha

1. Copia `dalia_tomato_v2b.pth` a `models/`.
2. Abre una terminal dentro de `api/` y comprueba Python (se recomienda 3.11 o 3.12):
   `python --version` (Windows) o `python3 --version` (macOS/Linux).
3. Crea y activa un entorno virtual:
   - Windows (Símbolo del sistema): `python -m venv .venv` y luego `.venv\Scripts\activate`
   - Windows (PowerShell): `.venv\Scripts\Activate.ps1` (si está bloqueado, usa el Símbolo del sistema)
   - macOS/Linux: `python3 -m venv .venv` y luego `source .venv/bin/activate`
4. Instala las dependencias:
   `pip install -r requirements.txt`
5. Instala PyTorch (descarga grande):
   - Windows/Linux (versión CPU): `pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu`
   - macOS: `pip install torch torchvision`
6. Ejecuta las pruebas: `pytest`
7. Arranca el servidor: `uvicorn app.main:app --host 127.0.0.1 --port 8000`
8. Abre http://127.0.0.1:8000/docs, entra a `POST /analyze` -> "Try it out", sube una foto y pulsa "Execute".

## Contrato

### GET /health
`200` -> `{"status": "ok", "version": "v2b"}`

### POST /analyze
- Cuerpo: `multipart/form-data` con el campo `photo` (JPEG, PNG o WebP, máximo 10 MB).
- Respuesta `200`:
```json
{
  "version": "v2b",
  "findings": [
    {"label": "Tomato___Late_blight", "confidence": 0.56},
    {"label": "Tomato___Early_blight", "confidence": 0.18}
  ]
}
```
`findings` trae todas las clases, de mayor a menor. `confidence` no es una probabilidad calibrada.

| Código | Cuándo |
|---|---|
| 200 | Imagen analizada |
| 400 | La imagen no se puede leer o tiene demasiados píxeles |
| 413 | Supera 10 MB |
| 415 | Tipo de archivo no admitido |
| 422 | Falta el campo `photo` |

## Comprobar que da lo mismo que el notebook
Sube a `/analyze` una de tus fotos de prueba y compara con el resultado de la celda 4.4 del notebook (variante "estirar"). Deberían coincidir con pequeñas diferencias de decimales. La API además corrige la orientación EXIF de las fotos de celular, algo que el notebook no hacía.

## Si el celular o el emulador deben llamar a la API
- Emulador de Android: la computadora es `http://10.0.2.2:8000`.
- Celular real en la misma red Wi-Fi: arranca con `--host 0.0.0.0` y usa la IP de tu computadora. Hazlo solo en una red de confianza: la API no tiene autenticación.

## Limitaciones (por qué no es producción)
- Sin autenticación, sin HTTPS y sin límite de peticiones.
- El tamaño máximo se comprueba tras recibir la subida, no antes: en producción hay que limitarlo también en el servidor web o proxy.
- Una sola instancia, sin registro de peticiones ni monitoreo.
- Solo tomate, solo hojas. El modelo no sabe decir "esto no es una hoja".
