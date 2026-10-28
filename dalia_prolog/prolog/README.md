# Dalia: Prolog (primer paso, independiente de la app)

Una base de conocimiento de tomate escrita en Prolog, con reglas que combinan lo que ve el modelo en la foto y lo que responde el usuario. **No toca `app/` ni `api/`**: es un paso aparte que se prueba solo en SWI-Prolog.

## Archivos
| Archivo | Para qué sirve |
|---|---|
| `hechos_tomate.pl` | Hechos: causas, tratamientos, indicadores. **Generado** desde `tomato.json`. |
| `dalia.pl` | Reglas y consultas. Carga los hechos. |
| `pruebas.pl` | 9 pruebas (plunit) con los mismos escenarios que las del motor en Dart. |
| `generar_hechos.py` | Regenera `hechos_tomate.pl` si cambias el JSON. |

## Cómo usarlo
1. Copia esta carpeta `prolog` dentro de `D:\Dalia` (queda `D:\Dalia\prolog`).
2. Abre una terminal en `D:\Dalia\prolog`.
3. Pruebas: `swipl -g run_tests -t halt pruebas.pl`. Debe terminar con `All 9 tests passed`.
4. Consultas a mano: `swipl dalia.pl` abre el prompt `?-` con todo cargado.

## Consultas de ejemplo
Cada consulta termina en punto. Los resultados de abajo son los que obtuve al ejecutarlas.

**Sin foto, tierra encharcada y hojas marchitas**
```
?- limpiar, reportar(suelo(waterlogged)), reportar(sintoma(wilting)).
?- mostrar_diagnostico.
Nivel de confianza: alto
  0.750  Exceso de riego  (overwatering)
  0.200  Falta de riego  (underwatering)
  0.200  Tizón tardío  (late_blight)

?- tratamiento(overwatering).
```

**Con foto (Septoria 0.89, Bacterial 0.10) y manchas**
```
?- limpiar, ver_en_foto('Tomato___Septoria_leaf_spot', 0.89), ver_en_foto('Tomato___Bacterial_spot', 0.10), reportar(sintoma(spots)).
?- mostrar_diagnostico.
Nivel de confianza: alto
  0.814  Mancha foliar por Septoria  (septoria_leaf_spot)
  0.340  Mancha bacteriana  (bacterial_spot)
  0.280  Mancha anillada (Target spot)  (target_spot)
  0.240  Tizón temprano  (early_blight)
  0.200  Tizón tardío  (late_blight)
```

**Backtracking:** con la variable libre, pulsa `;` para pedir la siguiente respuesta.
```
?- causa_probable(Causa, Puntaje).
```

**setof (sin repetidos):** por qué aparece una causa.
```
?- setof(E, evidencia(overwatering, E), Lista).
Lista = [contexto(sintoma(wilting)), contexto(suelo(waterlogged))].
```

## Qué parte de la clase es cada cosa
| Tema de clase | En Dalia |
|---|---|
| Hechos | `causa/2`, `nombre/2`, `indicador/3`, `paso/3`, `etiqueta_modelo/2` en `hechos_tomate.pl` |
| Reglas (`cabeza :- cuerpo`) | `puntaje/2`, `puntaje_contexto/2`, `causa_probable/2`, `nivel/1`, `evidencia/2` |
| Consultas y variables | `?- causa_probable(Causa, Puntaje).` |
| Conjunciones | cuerpos de las reglas: varias metas separadas por coma |
| Backtracking | `causa_probable/2` con `;`, y `evidencia/2` con dos cláusulas |
| `setof` / `findall` | `setof` en `evidencia`; `findall` en `ranking/1` y en los pesos |
| Corte `!` | `reporta_sintomas/0` (corte verde) y `primeros/3` |

## Notas
- Si las tildes salen raras en la consola, usa la ventana de Prolog que instala SWI-Prolog (`swipl-win`).
- Los hechos se generan desde el JSON, que también lee la app: así hay una sola fuente de verdad. Si cambias el JSON, ejecuta `python generar_hechos.py` en esta carpeta.
- Con empates de puntaje, el orden puede diferir del motor en Dart. Los puntajes sí coinciden.
- Los pesos y umbrales son parámetros de diseño (`parametro/2` en `dalia.pl`), no valores aprendidos.
- Lo verifiqué con SWI-Prolog 9.0.4. Tu versión estable puede ser más nueva; el código usa solo funciones estándar.

## Qué sigue (todavía no hecho)
Conectar este razonamiento con la API para que la app pueda usarlo, dejando el motor de Dart como respaldo. Se hace después, paso a paso, sin tocar lo que ya funciona.
