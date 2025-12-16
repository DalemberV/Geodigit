import os
import sys
import glob
import ctypes
from pyswip import Prolog

class GeologoAI:
    def __init__(self):
        # ... (MANTÉN TU CÓDIGO DE DETECCIÓN DE LINUX AQUÍ IGUAL QUE ANTES) ...
        # ... (Solo copio la parte funcional nueva abajo para ahorrar espacio) ...
        
        # --- BLOQUE LINUX START ---
        if sys.platform.startswith('linux'):
            paths = glob.glob("/usr/lib/*/libswipl.so*") + \
                    glob.glob("/usr/lib/swi-prolog/lib/*/libswipl.so*")
            if paths:
                ctypes.CDLL(sorted(paths)[-1], mode=ctypes.RTLD_GLOBAL)
        # --- BLOQUE LINUX END ---

        self.prolog = Prolog()
        directorio_actual = os.path.dirname(os.path.abspath(__file__))
        ruta_archivo = os.path.join(directorio_actual, "geologia.pl").replace("\\", "/")
        
        self.prolog.consult(ruta_archivo)

    def identificar_qapf(self, textura, q, a, p):
        """
        Consulta Prolog enviando porcentajes numéricos.
        """
        # Convertimos la textura a minúsculas y formato átomo (sin espacios)
        textura_atom = textura.lower().replace(" ", "_")
        
        query = f"identificar_streckeisen({textura_atom}, {q}, {a}, {p}, Roca)"
        
        try:
            solutions = list(self.prolog.query(query))
            # Retornamos una lista limpia de nombres de rocas
            return [sol['Roca'] for sol in solutions]
        except Exception as e:
            print(f"Error QAPF: {e}")
            return []