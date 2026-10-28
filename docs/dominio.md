# Dalia: capa Domain (diagnóstico)

## Objetivo
Dada una foto de una planta y 2 o 3 respuestas de contexto, devolver una **lista de causas probables** (enfermedad, plaga, riego, luz, nutrición) con explicación y tratamiento en lenguaje sencillo. Debe funcionar también **sin internet**, con menos precisión.

## Regla de dependencia (Clean Architecture)
`presentation -> domain <- data`. Domain no importa Flutter, red ni almacenamiento. Todo lo externo entra por interfaces (puertos):

| Puerto (domain) | Implementación futura (data) |
|---|---|
| `ImageAnalyzer` | Cliente de la API de inferencia; más adelante, modelo en el dispositivo |
| `KnowledgeBaseRepository` | Lectura de `assets/knowledge/tomato.json` (luego SQLite) |

## Piezas
- **Entidades:** `PlantPhoto`, `VisualFinding`, `ContextAnswers`, `Cause`, `CauseCandidate`, `Diagnosis`.
- **Servicio:** `DiagnosisEngine` (lógica pura) y `DiagnosisConfig` (parámetros ajustables).
- **Caso de uso:** `AnalyzePlantPhoto`.

## Flujo
1. El caso de uso pide las causas a la base de conocimiento.
2. Pide a `ImageAnalyzer` los hallazgos de la foto.
   - Si lanza `AnalyzerUnavailableException` (sin conexión), continúa solo con el contexto y marca el resultado con `needsOnlineRefinement`.
3. `DiagnosisEngine` puntúa cada causa y devuelve las mejores, con un nivel de confianza.

## Puntuación
- **Con imagen:** `0.6 * puntajeImagen + 0.4 * puntajeContexto`.
- **Sin imagen:** `puntajeContexto`.
- `puntajeImagen`: mayor confianza entre los hallazgos cuya etiqueta pertenece a `modelLabels` de la causa.
- `puntajeContexto`: suma de pesos de indicadores coincidentes / suma total de pesos de la causa.
- **Niveles:** alto >= 0.60, medio >= 0.35, bajo en otro caso.
- **Regla "sin síntomas claros":** si el usuario marcó algún síntoma, su puntaje se multiplica por 0.5 (el modelo actual tiende a sobreinformar "healthy").

Consecuencia deliberada: **una foto sola no alcanza el nivel alto** (máximo 0.6 con confianza 1.0). Hacen falta las respuestas de contexto.

## Limitaciones
- Los pesos y umbrales son parámetros de diseño, no valores aprendidos: ajústalos con datos reales.
- La confianza del modelo de imagen **no está calibrada** y el puntaje **no es una probabilidad**.
- Los indicadores mutuamente excluyentes (por ejemplo `soil:dry` y `soil:veryDry`) limitan el puntaje máximo de esa causa.
- La base de conocimiento es un **borrador sin fuentes verificadas**.
- Alcance actual: tomate en maceta, solo hojas.

## Pruebas
`flutter test test/features/diagnosis/domain/diagnosis_engine_test.dart`
