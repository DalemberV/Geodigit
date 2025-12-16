import modal
import os

# Definición de la Imagen
image = (
    modal.Image.debian_slim()
    .apt_install("swi-prolog")
    .pip_install("python-telegram-bot", "pyswip", "fastapi", "uvicorn")
    .add_local_dir(".", remote_path="/root")
)

app = modal.App("geo-expert-bot")
sessions = modal.Dict.from_name("geo-sessions", create_if_missing=True)

@app.function(image=image, secrets=[modal.Secret.from_name("telegram-secret")])
@modal.fastapi_endpoint(method="POST")
async def telegram_webhook(request: dict):
    from telegram import Update
    from telegram.ext import ApplicationBuilder, CommandHandler, CallbackQueryHandler, MessageHandler, filters
    # Importamos el nuevo handler de mensajes
    from interfaz_telegram import start, button_handler, handle_message
    
    token = os.environ["TELEGRAM_TOKEN"]
    application = ApplicationBuilder().token(token).build()
    
    # Handlers
    application.add_handler(CommandHandler('start', start))
    application.add_handler(CallbackQueryHandler(button_handler))
    
    # --- NUEVO: Escuchar texto que NO sea comando ---
    # Esto activará la función handle_message cuando el usuario escriba números
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    
    await application.initialize()

    try:
        update = Update.de_json(request, application.bot)
        await application.process_update(update)
    except Exception as e:
        print(f"Error: {e}")
        return {"ok": False}

    return {"ok": True}