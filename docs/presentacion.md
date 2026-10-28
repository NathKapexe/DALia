# Dalia: capa Presentation (diagnóstico)

## Flujo de la app
1. **Inicio:** botones "Tomar foto" (solo en celular) y "Elegir una foto".
2. **Preguntas:** vista previa de la foto y tres preguntas (tierra, luz, síntomas). Todas son opcionales.
3. **Resultado:** lista de causas probables, ordenadas, con explicación, pasos, precauciones y por qué aparece cada una. Si no hubo conexión, un aviso y el botón "Reintentar".

## Dependencias entre capas
`presentation -> domain <- data`. La presentación solo conoce el caso de uso `AnalyzePlantPhoto` y el puerto `PhotoSource`. `main.dart` es la raíz de composición: el único lugar que une las clases concretas (`diagnosis_module.dart` y `ImagePickerPhotoSource`).

## Estado
`DiagnosisController` (un `ChangeNotifier`, sin paquetes adicionales). Guarda la foto, las respuestas y el resultado. Descarta un resultado que llega tarde si el usuario ya empezó otra consulta (`_requestId`).

## Puertos y adaptadores nuevos
| Puerto (domain) | Adaptador (data) |
|---|---|
| `PhotoSource` | `ImagePickerPhotoSource` (plugin `image_picker`) |

## Decisiones
- **La puntuación se muestra como barra de relevancia**, no como porcentaje: no es una probabilidad.
- **Mensaje según confianza:** alta, media o baja. Con confianza baja se pide una foto más cercana.
- **Aviso fijo:** "Orientación general: no sustituye a un especialista."
- **Textos en español dentro del código** (`labels.dart`). Si la app necesitara varios idiomas, ahí habría que cambiar.

## Pendiente
- Ejecutarla en Android (permiso de internet y HTTP sin cifrar en desarrollo).
- Historial de consultas, cola de fotos sin conexión y sincronización al reconectar.
- Pruebas manuales con fotos reales; la selección de fotos con `image_picker` no tiene prueba automática.
- Revisar la accesibilidad (lectores de pantalla, tamaños de texto).
