from pyswip import Prolog
import os

class GeologoAI:
    def __init__(self):
        self.prolog = Prolog()
        # En Modal, los archivos montados van a /root. 
        # Usamos ruta absoluta para evitar problemas.
        ruta_prolog = "/root/geologia.pl"
        
        # Verificación de seguridad
        if not os.path.exists(ruta_prolog):
            print(f"⚠️ ERROR CRÍTICO: No encuentro {ruta_prolog}")
            # Intento fallback por si se corre en local
            if os.path.exists("geologia.pl"):
                ruta_prolog = "geologia.pl"

        try:
            self.prolog.consult(ruta_prolog)
            print(f"✅ Base de conocimientos cargada desde: {ruta_prolog}")
        except Exception as e:
            print(f"❌ Error cargando Prolog: {e}")

    def identificar(self, texturas, minerales, color):
        # 1. Limpiar hechos anteriores de la memoria de Prolog
        list(self.prolog.query("retractall(tiene_textura(_))"))
        list(self.prolog.query("retractall(tiene_mineral(_))"))
        list(self.prolog.query("retractall(indice_color(_))"))

        # 2. Insertar nuevos hechos (assertz)
        for t in texturas:
            self.prolog.assertz(f"tiene_textura({t})")
        
        for m in minerales:
            self.prolog.assertz(f"tiene_mineral({m})")
            
        if color:
            self.prolog.assertz(f"indice_color({color})")

        # 3. Preguntar al oráculo
        try:
            soluciones = list(self.prolog.query("identificar_roca(X)"))
            # Extraer el valor 'X' de cada solución
            rocas = [sol['X'] for sol in soluciones]
            # Eliminar duplicados si los hubiera
            return list(set(rocas))
        except Exception as e:
            print(f"Error en query: {e}")
            return []

#python -m modal deploy bot_modal.py
