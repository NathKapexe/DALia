# Dalia: capa Data (diagnóstico)

## Qué hace
Implementa los dos puertos del dominio:

| Puerto (domain) | Implementación (data) | Fuente |
|---|---|---|
| `KnowledgeBaseRepository` | `KnowledgeBaseRepositoryImpl` + `AssetKnowledgeDataSource` | `assets/knowledge/tomato.json` |
| `ImageAnalyzer` | `ImageAnalyzerImpl` + `HttpImageAnalysisDataSource` | API de inferencia (`POST /analyze`) |

`diagnosis_module.dart` es la raíz de composición: construye `AnalyzePlantPhoto` con las clases concretas. La capa de presentación solo pedirá ese caso de uso.

## Contrato con la API
- `POST {baseUrl}/analyze`, `multipart/form-data`, campo `photo`.
- El `Content-Type` de la parte se fija según la extensión (`.jpg`/`.jpeg`, `.png`, `.webp`), porque la API rechaza otros tipos con 415.
- Validación previa en el cliente: extensión admitida, archivo legible y máximo 10 MB.

## Traducción de errores
| Situación | Excepción de dominio | Efecto en la app |
|---|---|---|
| Sin conexión, tiempo agotado (20 s), código 5xx, cuerpo inesperado, otro código | `AnalyzerUnavailableException` | El caso de uso sigue solo con el contexto y marca `needsOnlineRefinement` |
| 400, 413, 415, 422; extensión no admitida; archivo ilegible o demasiado grande | `InvalidPhotoException` | El error llega a la interfaz, que debe pedir otra foto |

## Dirección de la API
`kApiBaseUrl` (`lib/core/config/api_config.dart`). Por defecto, `http://10.0.2.2:8000` (emulador de Android). Para otra dirección:
`flutter run --dart-define=DALIA_API_URL=http://192.168.1.50:8000`

## Pendiente para ejecutar la app en Android
- Añadir el permiso `INTERNET` y permitir tráfico HTTP sin cifrar (`android:usesCleartextTraffic="true"`) en `android/app/src/main/AndroidManifest.xml`. Solo para desarrollo: en producción la API debe usar HTTPS.

## Límites
- El historial de diagnósticos, la cola de fotos sin conexión y la sincronización al reconectar todavía no existen.
- No se ha probado contra la API real desde la app, solo con respuestas simuladas (`MockClient`).

## Pruebas
`flutter test`
