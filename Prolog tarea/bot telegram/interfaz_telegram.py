import os
import logging
import modal  # Importamos Modal para usar el Dict
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import ApplicationBuilder, ContextTypes, CommandHandler, CallbackQueryHandler
from cerebro import GeologoAI 

logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)

TOKEN = os.environ.get("TELEGRAM_TOKEN", "TU_TOKEN_LOCAL")

# --- CONEXIÓN A LA MEMORIA DE LA NUBE ---
try:
    # Conectamos al diccionario que creamos en bot_modal.py
    sessions = modal.Dict.from_name("geo-sessions", create_if_missing=True)
except:
    # Fallback por si lo corres en local sin Modal
    sessions = {} 

try:
    geo_bot = GeologoAI()
except Exception as e:
    print(f"⚠️ Advertencia: No se pudo iniciar el cerebro Geológico: {e}")
    geo_bot = None

# --- FUNCIONES AUXILIARES PARA MANEJAR ESTADO ---
def get_session(user_id):
    # Recupera los datos del usuario o crea uno nuevo si no existe
    default = {'textura': [], 'color': None, 'minerales': []}
    if isinstance(sessions, dict): # Modo local
        return sessions.get(user_id, default)
    else: # Modo Modal
        return sessions.get(user_id, default)

def save_session(user_id, data):
    sessions[user_id] = data


# --- HANDLERS ---

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = update.effective_user.id
    
    # Reiniciar sesión en la nube
    save_session(user_id, {'textura': [], 'color': None, 'minerales': []})
    
    keyboard = [
        [InlineKeyboardButton("Fanerítica (Gruesa)", callback_data='tex_faneritica')],
        [InlineKeyboardButton("Afanítica (Fina)", callback_data='tex_afanitica')],
        [InlineKeyboardButton("Vítrea / Vesicular", callback_data='tex_vesicular')],
        [InlineKeyboardButton("Piroclástica", callback_data='tex_piroclastica')]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    
    await update.message.reply_text(
        "⚒️ **GeoExpert Bot** (Nube)\n\nSistema de clasificación QAPF.\nSelecciona la **textura** predominante:", 
        reply_markup=reply_markup, 
        parse_mode='Markdown'
    )

async def button_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()
    data = query.data
    user_id = query.from_user.id
    
    # RECUPERAR ESTADO ACTUAL DE LA NUBE
    current_session = get_session(user_id)
    
    # -- Lógica de Textura --
    if data.startswith("tex_"):
        val = data.replace("tex_", "")
        current_session['textura'] = [val] # Guardamos en variable temporal
        save_session(user_id, current_session) # Escribimos en la nube
        
        keyboard = [
            [InlineKeyboardButton("Claro (Leuco)", callback_data='col_leucocratico')],
            [InlineKeyboardButton("Medio (Meso)", callback_data='col_mesocratico')],
            [InlineKeyboardButton("Oscuro (Melano)", callback_data='col_melanocratico')],
            [InlineKeyboardButton("Verde/Negro (Ultra)", callback_data='col_ultramafico')]
        ]
        await query.edit_message_text(f"Textura: {val}.\n\nSelecciona el **Índice de Color**:", reply_markup=InlineKeyboardMarkup(keyboard), parse_mode='Markdown')

    # -- Lógica de Color --
    elif data.startswith("col_"):
        val = data.replace("col_", "")
        current_session['color'] = val
        save_session(user_id, current_session)
        
        keyboard = [
            [InlineKeyboardButton("➕ Cuarzo", callback_data='min_cuarzo'), InlineKeyboardButton("➕ Feld. K", callback_data='min_feldespato_k')],
            [InlineKeyboardButton("➕ Plagioclasa", callback_data='min_plagioclasa'), InlineKeyboardButton("➕ Anfíbol", callback_data='min_anfibol')],
            [InlineKeyboardButton("➕ Piroxeno", callback_data='min_piroxeno'), InlineKeyboardButton("➕ Olivino", callback_data='min_olivino')],
            [InlineKeyboardButton("✅ TERMINAR", callback_data='DONE')]
        ]
        await query.edit_message_text(f"Color registrado.\n\nAñade **Minerales**:", reply_markup=InlineKeyboardMarkup(keyboard), parse_mode='Markdown')

    # -- Lógica de Minerales --
    elif data.startswith("min_"):
        val = data.replace("min_", "")
        
        # Recuperamos lista, agregamos y guardamos
        lista_minerales = current_session.get('minerales', [])
        if val not in lista_minerales:
            lista_minerales.append(val)
            current_session['minerales'] = lista_minerales
            save_session(user_id, current_session)
        
        keyboard = [
            [InlineKeyboardButton("➕ Cuarzo", callback_data='min_cuarzo'), InlineKeyboardButton("➕ Feld. K", callback_data='min_feldespato_k')],
            [InlineKeyboardButton("➕ Plagioclasa", callback_data='min_plagioclasa'), InlineKeyboardButton("➕ Anfíbol", callback_data='min_anfibol')],
            [InlineKeyboardButton("➕ Piroxeno", callback_data='min_piroxeno'), InlineKeyboardButton("➕ Olivino", callback_data='min_olivino')],
            [InlineKeyboardButton("✅ TERMINAR", callback_data='DONE')]
        ]
        await query.edit_message_text(f"Minerales: {', '.join(lista_minerales)}\n\nAñadido: {val}", reply_markup=InlineKeyboardMarkup(keyboard))

    # -- Resultado Final --
    elif data == "DONE":
        if geo_bot:
            # Leemos todo de la sesión en la nube
            t = current_session.get('textura', [])
            m = current_session.get('minerales', [])
            c = current_session.get('color')
            
            # Debug (Opcional: para ver qué llega en los logs)
            print(f"CONSULTANDO PROLOG CON: Tex={t}, Min={m}, Col={c}")
            
            resultados = geo_bot.identificar(t, m, c)
            
            if resultados:
                await query.edit_message_text(f"✅ **RESULTADO:**\n\nLa muestra es: **{', '.join([r.upper() for r in resultados])}**", parse_mode='Markdown')
            else:
                msg_debug = f"Datos recibidos:\n- T: {t}\n- C: {c}\n- M: {m}"
                await query.edit_message_text(f"⚠️ **Indeterminado:** No coincide con las reglas.\n\n{msg_debug}", parse_mode='Markdown')
        else:
            await query.edit_message_text("❌ Error: El cerebro geológico no está conectado.", parse_mode='Markdown')

if __name__ == '__main__':
    print("🚀 Iniciando Bot en modo LOCAL...")
    app = ApplicationBuilder().token(TOKEN).build()
    app.add_handler(CommandHandler('start', start))
    app.add_handler(CallbackQueryHandler(button_handler))
    app.run_polling()