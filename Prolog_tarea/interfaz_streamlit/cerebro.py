import os
import sys
import glob
import ctypes
from pyswip import Prolog

class GeologoAI:
    def __init__(self):
        # --- BLOQUE LINUX (Mismo de antes) ---
        if sys.platform.startswith('linux'):
            paths = glob.glob("/usr/lib/*/libswipl.so*") + \
                    glob.glob("/usr/lib/swi-prolog/lib/*/libswipl.so*")
            if paths:
                ctypes.CDLL(sorted(paths)[-1], mode=ctypes.RTLD_GLOBAL)
        
        self.prolog = Prolog()
        directorio = os.path.dirname(os.path.abspath(__file__))
        ruta = os.path.join(directorio, "geologia.pl").replace("\\", "/")
        self.prolog.consult(ruta)

    # --- MODO LABORATORIO (NUMÉRICO) ---
    def identificar_qapf(self, textura, q, a, p):
        textura_atom = textura.lower().replace(" ", "_")
        query = f"clasificar_qapf({textura_atom}, {q}, {a}, {p}, Roca)"
        try:
            return [sol['Roca'] for sol in self.prolog.query(query)]
        except: return []

    # --- MODO CAMPO (VISUAL) ---
    def identificar_visual(self, textura, minerales, color):
        # Limpiar memoria anterior
        self.prolog.retractall("tiene_textura(_)")
        self.prolog.retractall("tiene_mineral(_)")
        self.prolog.retractall("indice_color(_)")
        
        # Insertar hechos nuevos
        t_atom = textura.lower().replace(" ", "_")
        c_atom = color.lower().replace(" ", "_")
        
        self.prolog.assertz(f"tiene_textura({t_atom})")
        self.prolog.assertz(f"indice_color({c_atom})")
        
        for m in minerales:
            m_atom = m.lower().replace(" ", "_")
            self.prolog.assertz(f"tiene_mineral({m_atom})")
            
        try:
            return [sol['X'] for sol in self.prolog.query("identificar_visual(X)")]
        except: return []