import streamlit as st
from cerebro import GeologoAI

# 1. Configuración de página
st.set_page_config(page_title="Identificador de Rocas Ígneas", layout="centered")

# 2. Instanciamos el Cerebro (Conexión con Prolog)
# Usamos @st.cache_resource para no recargar Prolog en cada clic (optimización)
@st.cache_resource
def cargar_cerebro():
    return GeologoAI()

cerebro = cargar_cerebro()

# 3. Título y Descripción
st.title("⚒️ Clasificación QAPF")
st.markdown("""
Este sistema experto utiliza lógica simbólica (Prolog) basada en los criterios de 
**Streckeisen** para identificar rocas ígneas.
""")

st.divider()

# --- FORMULARIO DE ENTRADA ---

col1, col2 = st.columns(2)

with col1:
    st.subheader("1. Textura")
    # Diccionario: Lo que ve el usuario -> Lo que entiende Prolog
    mapa_texturas = {
        "Grano Grueso (Fanerítica)": "faneritica",
        "Grano Fino (Afanítica)": "afanitica",
        "Vitrea (Obsidiana)": "vitrea",
        "Vesicular (Burbujas)": "vesicular",
        "Pegmatítica (Granos gigantes)": "pegmatitica",
        "Piroclástica (Fragmentos)": "piroclastica"
    }
    opcion_textura = st.radio("Selecciona la textura principal:", list(mapa_texturas.keys()))
    
    # Obtenemos el átomo para Prolog
    textura_prolog = mapa_texturas[opcion_textura]

with col2:
    st.subheader("2. Índice de Color")
    mapa_color = {
        "Claro (Leucocrático 0-35%)": "leucocratico",
        "Medio (Mesocrático 35-65%)": "mesocratico",
        "Oscuro (Melanocrático 65-90%)": "melanocratico",
        "Verde/Negro (Ultramáfico >90%)": "ultramafico"
    }
    opcion_color = st.radio("Selecciona el índice de color:", list(mapa_color.keys()))
    color_prolog = mapa_color[opcion_color]

st.subheader("3. Mineralogía Esencial")
st.info("Selecciona TODOS los minerales que puedas identificar en la muestra de mano.")

mapa_minerales = {
    "Cuarzo": "cuarzo",
    "Feldespato Potásico (K)": "feldespato_k",
    "Plagioclasa": "plagioclasa",
    "Anfíbol / Biotita": "anfibol",
    "Piroxeno": "piroxeno",
    "Olivino": "olivino"
}

seleccion_minerales = st.multiselect("Minerales presentes:", list(mapa_minerales.keys()))

# Convertimos lista de nombres bonitos a lista de átomos Prolog
minerales_prolog = [mapa_minerales[m] for m in seleccion_minerales]

# --- BOTÓN DE EJECUCIÓN ---
if st.button("🔍 Analizar Muestra", type="primary"):
    with st.spinner('Consultando base de conocimiento geológico...'):
        
        # LLAMADA AL CEREBRO
        # Pasamos listas: [textura], [minerales], color
        resultados = cerebro.identificar([textura_prolog], minerales_prolog, color_prolog)
        
        if resultados:
            st.success(f"✅ Identificación Exitosa")
            for roca in resultados:
                st.header(f"Roca: {roca.upper()}")
                
            # Explicación contextual (Opcional)
            if "granito" in resultados:
                st.caption("Nota: Roca intrusiva félsica común en la corteza continental.")
            if "basalto" in resultados:
                st.caption("Nota: Roca extrusiva máfica, común en fondos oceánicos.")
        else:
            st.error("❌ No se encontró una clasificación exacta.")
            st.warning("Prueba verificando si el índice de color coincide con los minerales seleccionados (ej. Olivino + Color Claro es una contradicción).")