import os
from pyswip import Prolog

class GeologoAI:
    def __init__(self):
        self.prolog = Prolog()
        
        # --- CORRECCIÓN DE RUTA ---
        # 1. Obtenemos la ruta donde está guardado este archivo 'cerebro.py'
        directorio_actual = os.path.dirname(os.path.abspath(__file__))
        
        # 2. Construimos la ruta completa hacia 'geologia.pl'
        # Importante: Reemplazamos las barras invertidas por barras normales para que Prolog no se confunda
        ruta_archivo = os.path.join(directorio_actual, "geologia.pl")
        
        # En Windows, a veces Prolog necesita las barras diagonales así: /
        ruta_archivo = ruta_archivo.replace("\\", "/")

        print(f"📂 Buscando base de conocimiento en: {ruta_archivo}")

        try:
            self.prolog.consult(ruta_archivo)
            print("✅ Base de conocimiento cargada con éxito.")
        except Exception as e:
            print(f"❌ ERROR: No se pudo cargar el archivo. Verifica que 'geologia.pl' esté en la carpeta.")
            raise e

    def limpiar_hechos(self):
        self.prolog.retractall("tiene_textura(_)")
        self.prolog.retractall("tiene_mineral(_)")
        self.prolog.retractall("indice_color(_)")

    def identificar(self, texturas, minerales, color):
        self.limpiar_hechos()
        
        # Inyectar hechos
        for t in texturas: self.prolog.assertz(f"tiene_textura({t})")
        for m in minerales: self.prolog.assertz(f"tiene_mineral({m})")
        if color: self.prolog.assertz(f"indice_color({color})")
        
        # Consultar
        solutions = list(self.prolog.query("identificar_roca(X)"))
        return [sol['X'] for sol in solutions]