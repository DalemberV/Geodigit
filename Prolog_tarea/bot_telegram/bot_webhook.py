import modal
from modal import Image, Mount, Secret

# 1. Definimos la imagen del sistema (Linux + Prolog + Librerías)
geologia_image = Image.debian_slim() \
    .apt_install("swi-prolog") \
    .pip_install("python-telegram-bot", "pyswip")

app = modal.App("geo-expert-webhook")

# 2. Definimos el Endpoint (La puerta donde Telegram tocará)
@app.function(
    image=geologia_image,
    # Montamos tu archivo local geologia.pl para que esté disponible en la nube
    mounts=[Mount.from_local_dir(".", remote_path="/root")],
    # Guardamos el Token de forma segura (te explico abajo cómo ponerlo)
    secrets=[Secret.from_name("telegram-secret")]
)
@modal.web_endpoint(method="POST")
async def telegram_webhook(data: dict):
    """
    Esta función se despierta CADA VEZ que llega un mensaje.
    Recibe el JSON crudo de Telegram y lo procesa.
    """
    import os
    from telegram import Update
    from telegram.ext import ApplicationBuilder, CommandHandler, CallbackQueryHandler, ContextTypes
    from pyswip import Prolog

    # --- LÓGICA DE PROLOG (Integrada) ---
    # Cargamos Prolog cada vez que se invoca la función (Serverless stateless)
    prolog = Prolog()
    try:
        # En Modal, los archivos montados suelen estar en /root o la ruta definida
        prolog.consult("/root/geologia.pl")
    except:
        print("⚠️ Advertencia: No se cargó geologia.pl, verifica el mount.")

    def identificar_roca_backend(texturas, minerales, color):
        prolog.retractall("tiene_textura(_)")
        prolog.retractall("tiene_mineral(_)")
        prolog.retractall("indice_color(_)")
        for t in texturas: prolog.assertz(f"tiene_textura({t})")
        for m in minerales: prolog.assertz(f"tiene_mineral({m})")
        if color: prolog.assertz(f"indice_color({color})")
        try:
            solutions = list(prolog.query("identificar_roca(X)"))
            return [sol['X'] for sol in solutions]
        except:
            return []

    # --- LÓGICA DEL BOT (Handlers) ---
    # Copiamos aquí tus handlers para asegurar que estén en el contexto de Modal
    # (Nota: Por brevedad, pongo la estructura, asegúrate de copiar tus funciones start/button aquí o importarlas)
    
    async def start(update, context):
        # ... Tu código del start ...
        await update.message.reply_text("Hola desde el Webhook de Modal! (Modo Ahorro)")

    async def button_handler(update, context):
        # ... Tu lógica de botones ...
        pass 

    # --- INICIALIZACIÓN RÁPIDA ---
    # Construimos la app solo para procesar ESTE mensaje específico
    token = os.environ["TELEGRAM_TOKEN"]
    application = ApplicationBuilder().token(token).build()
    
    # Registramos manejadores
    application.add_handler(CommandHandler('start', start))
    # application.add_handler(CallbackQueryHandler(button_handler)) # Descomenta y pon tu función

    # Procesamos la actualización que nos envió Telegram
    update = Update.de_json(data, application.bot)
    await application.process_update(update)

    return {"status": "ok"}