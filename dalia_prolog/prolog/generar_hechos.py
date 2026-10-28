"""Genera hechos_tomate.pl a partir de app/assets/knowledge/tomato.json.

El JSON es la fuente de verdad (la app lo lee tambien). Si editas causas,
sintomas o tratamientos en el JSON, vuelve a ejecutar este script:

    python generar_hechos.py
"""
import json
import re
from pathlib import Path

AQUI = Path(__file__).resolve().parent
ENTRADA = AQUI.parent / "app" / "assets" / "knowledge" / "tomato.json"
SALIDA = AQUI / "hechos_tomate.pl"

ATOMO_SIMPLE = re.compile(r"^[a-z][A-Za-z0-9_]*$")


def atomo(texto: str) -> str:
    """Devuelve el texto como atomo de Prolog (entre comillas si hace falta)."""
    if ATOMO_SIMPLE.match(texto):
        return texto
    escapado = texto.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escapado}'"


def senal(codigo: str) -> str:
    """'soil:waterlogged' -> suelo(waterlogged), etc."""
    tipo, valor = codigo.split(":", 1)
    funtor = {"soil": "suelo", "light": "luz", "symptom": "sintoma"}[tipo]
    return f"{funtor}({atomo(valor)})"


def main() -> None:
    datos = json.loads(ENTRADA.read_text(encoding="utf-8"))
    lineas = [
        ":- encoding(utf8).",
        "",
        f"% Generado por generar_hechos.py desde tomato.json (version {datos['version']}).",
        "% NO editar a mano: edita el JSON y vuelve a generar este archivo.",
        "",
        ":- discontiguous causa/2, nombre/2, resumen/2, etiqueta_modelo/2,",
        "                 indicador/3, paso/3, precaucion/2.",
        "",
        "% causa(Id, Categoria).            nombre(Id, Texto).      resumen(Id, Texto).",
        "% etiqueta_modelo(Id, Etiqueta).   indicador(Id, Senal, Peso).",
        "% paso(Id, Numero, Texto).         precaucion(Id, Texto).",
        "",
    ]
    for c in datos["causes"]:
        i = atomo(c["id"])
        lineas.append(f"causa({i}, {atomo(c['category'])}).")
        lineas.append(f"nombre({i}, {atomo(c['name'])}).")
        lineas.append(f"resumen({i}, {atomo(c['summary'])}).")
        for etiqueta in c["modelLabels"]:
            lineas.append(f"etiqueta_modelo({i}, {atomo(etiqueta)}).")
        for codigo, peso in c["indicators"].items():
            lineas.append(f"indicador({i}, {senal(codigo)}, {float(peso)!r}).")
        for n, texto in enumerate(c["treatmentSteps"], start=1):
            lineas.append(f"paso({i}, {n}, {atomo(texto)}).")
        for texto in c["precautions"]:
            lineas.append(f"precaucion({i}, {atomo(texto)}).")
        lineas.append("")
    SALIDA.write_text("\n".join(lineas), encoding="utf-8")
    print(f"Escrito {SALIDA.name}: {len(datos['causes'])} causas")


if __name__ == "__main__":
    main()
