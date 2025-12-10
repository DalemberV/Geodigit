import modal
import os

# 1. Definición de la Imagen
image = (
    modal.Image.debian_slim()
    .apt_install("swi-prolog")
    .pip_install("python-telegram-bot", "pyswip", "fastapi", "uvicorn")
    .add_local_dir(".", remote_path="/root")
)

app = modal.App("geo-expert-bot")

# --- NUEVO: Crear memoria persistente ---
# Esto crea un diccionario en la nube llamado "geo-sessions"
sessions = modal.Dict.from_name("geo-sessions", create_if_missing=True)

# 2. El Webhook
@app.function(
    image=image,
    secrets=[modal.Secret.from_name("telegram-secret")]
)
@modal.fastapi_endpoint(method="POST")
async def telegram_webhook(request: dict):
    from telegram import Update
    from telegram.ext import ApplicationBuilder, CommandHandler, CallbackQueryHandler
    from interfaz_telegram import start, button_handler
    
    token = os.environ["TELEGRAM_TOKEN"]
    
    application = ApplicationBuilder().token(token).build()
    
    application.add_handler(CommandHandler('start', start))
    application.add_handler(CallbackQueryHandler(button_handler))

    await application.initialize()

    try:
        update = Update.de_json(request, application.bot)
        await application.process_update(update)
    except Exception as e:
        print(f"Error procesando update: {e}")
        return {"ok": False, "error": str(e)}

    return {"ok": True}