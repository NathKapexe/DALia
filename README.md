# Dalia: paquete de la capa Domain

## Contenido
- `app/lib/features/diagnosis/domain/`: entidades, puertos, motor de diagnóstico y caso de uso.
- `app/test/features/diagnosis/domain/diagnosis_engine_test.dart`: pruebas del motor y del caso de uso.
- `app/assets/knowledge/tomato.json`: base de conocimiento de tomate (BORRADOR).
- `docs/dominio.md`: documentación del diseño.

## Cómo instalarlo
1. Crea el proyecto Flutter (nombre del paquete `dalia`, necesario para los imports):
   `flutter create --project-name dalia app`
2. Copia el contenido de la carpeta `app/` de este paquete dentro de tu `app/` (combinando carpetas) y la carpeta `docs/` junto a ella.
3. Desde `app/`, ejecuta: `flutter test`

El JSON todavía no lo lee nadie: se registrará en `pubspec.yaml` y se cargará en la capa Data (siguiente paso).

## Aviso
Este código no se ha compilado ni ejecutado todavía. Si `flutter test` da errores, pásalos tal cual.
