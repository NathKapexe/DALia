import subprocess
from pathlib import Path

class PrologAdapter:
    def __init__(self):
        # Apunta a la carpeta prolog dentro de tu estructura D:\Dalia
        self.prolog_dir = Path(__file__).resolve().parents[3] / "dalia_prolog" / "prolog"

    def consultar_diagnostico(self, etiquetas_modelo: list, sintomas: list, suelo: str = None, luz: str = None):
        """
        Construye una consulta en Prolog combinando las evidencias del modelo de imagen 
        y las respuestas del usuario, y devuelve el diagnóstico experto.
        """
        # Limpiamos hechos anteriores y cargamos dalia.pl
        comandos_prolog = ["limpiar"]

        # Añadimos hallazgos del modelo de imagen
        for etiqueta, confianza in etiquetas_modelo:
            # Aseguramos formato de átomo en Prolog con comillas simples
            comandos_prolog.append(f"ver_en_foto('{etiqueta}', {confianza})")

        # Añadimos síntomas reportados
        for sintoma in sintomas:
            comandos_prolog.append(f"reportar(sintoma({sintoma}))")

        # Añadimos estado del suelo si existe
        if suelo:
            comandos_prolog.append(f"reportar(suelo({suelo}))")

        # Añadimos estado de la luz si existe
        if luz:
            comandos_prolog.append(f"reportar(luz({luz}))")

        # Consultas finales para extraer el nivel de confianza y el ranking
        # Pedimos el nivel y el ranking formateado
        consulta_str = ", ".join(comandos_prolog) + ", nivel(Nivel), ranking(Mejores), halt."

        # Ejecutamos SWI-Prolog desde la línea de comandos de la máquina
        try:
            resultado = subprocess.run(
                ["swipl", "-s", "dalia.pl", "-g", consulta_str],
                cwd=str(self.prolog_dir),
                capture_output=True,
                text=True,
                encoding="utf-8",
                timeout=5
            )
            return {
                "success": True,
                "output": resultado.stdout,
                "error": resultado.stderr
            }
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }