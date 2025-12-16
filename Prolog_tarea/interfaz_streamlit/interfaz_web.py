import streamlit as st
from cerebro import GeologoAI

st.set_page_config(page_title="Calculadora Streckeisen QAPF", page_icon="🌋")

# Cargar cerebro
@st.cache_resource
def cargar_cerebro():
    return GeologoAI()

cerebro = cargar_cerebro()

st.title("🌋 Clasificación QAPF de Streckeisen")
st.markdown("Identificación cuantitativa de rocas ígneas basada en porcentajes modales.")

# --- 1. SELECCIÓN DE TEXTURA (DEFINE EL TRIÁNGULO) ---
st.subheader("1. Textura y Ambiente")
col_tex1, col_tex2 = st.columns(2)

with col_tex1:
    textura_ui = st.selectbox(
        "Textura de la Roca",
        ["Faneritica (Grano grueso)", "Afanitica (Grano fino)", "Vitrea", "Vesicular", "Piroclastica"]
    )
    # Mapeo simple para enviar a Python
    mapa_tex = {
        "Faneritica (Grano grueso)": "faneritica",
        "Afanitica (Grano fino)": "afanitica",
        "Vitrea": "vitrea",
        "Vesicular": "vesicular",
        "Piroclastica": "piroclastica"
    }
    textura_final = mapa_tex[textura_ui]

with col_tex2:
    if textura_final == "faneritica":
        st.info("Ambiente: **Intrusivo (Plutónico)**. Se usará el diagrama superior.")
    elif textura_final in ["vitrea", "vesicular", "piroclastica"]:
        st.warning("Estas texturas suelen clasificarse directamente, sin conteo QAP.")
    else:
        st.info("Ambiente: **Extrusivo (Volcánico)**. Se usará el diagrama inferior.")

st.divider()

# --- 2. ENTRADA DE PORCENTAJES (SLIDERS) ---
st.subheader("2. Composición Modal (%)")
st.caption("Ajusta los valores. La suma debe ser exactamente 100%.")

col1, col2, col3 = st.columns(3)

with col1:
    q = st.number_input("Cuarzo (Q)", min_value=0, max_value=100, value=20)
with col2:
    a = st.number_input("Feld. Alcalino (A)", min_value=0, max_value=100, value=20)
with col3:
    p = st.number_input("Plagioclasa (P)", min_value=0, max_value=100, value=60)

suma = q + a + p
progreso = suma / 100.0 if suma <= 100 else 1.0

# Barra de progreso visual para ayudar a sumar 100
if suma == 100:
    st.progress(progreso, text=f"Suma Total: {suma}% ✅")
elif suma < 100:
    st.progress(progreso, text=f"Suma Total: {suma}% (Faltan {100-suma}%) ⚠️")
else:
    st.progress(1.0, text=f"Suma Total: {suma}% (Sobran {suma-100}%) 🛑")

# --- 3. BOTÓN DE CÁLCULO ---
st.divider()

if st.button("🔍 Clasificar Roca", type="primary"):
    if suma != 100:
        st.error(f"❌ Los porcentajes deben sumar exactamente 100%. Suma actual: {suma}%")
    else:
        # Llamamos a la nueva función numérica
        resultados = cerebro.identificar_qapf(textura_final, q, a, p)
        
        if resultados:
            st.success(f"### Roca Identificada: {resultados[0].upper().replace('_', ' ')}")
            
            # Datos visuales extra
            st.json({
                "Textura": textura_final,
                "Q": f"{q}%",
                "A": f"{a}%",
                "P": f"{p}%",
                "Resultado": resultados[0]
            })
        else:
            st.warning("⚠️ No se encontró una clasificación exacta en los rangos definidos.")
            st.info("Intenta ajustar ligeramente los valores. Los límites de Streckeisen son estrictos.")