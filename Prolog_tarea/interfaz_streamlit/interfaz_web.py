import streamlit as st
from cerebro import GeologoAI

st.set_page_config(page_title="GeoExpert Pro", page_icon="⚒️", layout="centered")

@st.cache_resource
def cargar_cerebro():
    return GeologoAI()

cerebro = cargar_cerebro()

st.title("⚒️ GeoExpert AI")
st.markdown("Sistema experto para clasificación de rocas ígneas.")

# CREACIÓN DE PESTAÑAS
tab1, tab2 = st.tabs(["🔍 MODO CAMPO (Visual)", "🧪 MODO LAB (Streckeisen)"])

# ==========================================
# PESTAÑA 1: MODO CUALITATIVO (Lo que tenías antes)
# ==========================================
with tab1:
    st.header("Identificación Visual")
    st.caption("Usa esto si no tienes porcentajes exactos, solo observación de muestra de mano.")
    
    c1, c2 = st.columns(2)
    with c1:
        textura_v = st.selectbox("Textura", ["Faneritica", "Afanitica", "Vitrea", "Vesicular", "Piroclastica"], key="t_vis")
    with c2:
        color_v = st.selectbox("Índice de Color", ["Leucocratico", "Mesocratico", "Melanocratico", "Ultramafico"], key="c_vis")
        
    minerales_v = st.multiselect("Minerales Visibles", 
        ["Cuarzo", "Feldespato K", "Plagioclasa", "Anfibol", "Piroxeno", "Olivino"], key="m_vis")
        
    if st.button("Identificar (Visual)", type="primary"):
        # Mapeo de nombres bonitos a átomos de Prolog
        min_map = {
            "Cuarzo": "cuarzo", "Feldespato K": "feldespato_k", "Plagioclasa": "plagioclasa",
            "Anfibol": "anfibol", "Piroxeno": "piroxeno", "Olivino": "olivino"
        }
        min_prolog = [min_map[m] for m in minerales_v]
        
        res = cerebro.identificar_visual(textura_v, min_prolog, color_v)
        
        if res:
            st.success(f"Roca probable: **{res[0].upper()}**")
        else:
            st.warning("No coincide con una clasificación estándar.")

# ==========================================
# PESTAÑA 2: MODO CUANTITATIVO (QAPF)
# ==========================================
with tab2:
    st.header("Diagrama QAPF")
    st.caption("Clasificación precisa usando porcentajes modales.")
    
    textura_q = st.selectbox("Textura", ["Faneritica", "Afanitica"], key="t_qap")
    
    c1, c2, c3 = st.columns(3)
    q = c1.number_input("Q (%)", 0, 100, 20)
    a = c2.number_input("A (%)", 0, 100, 20)
    p = c3.number_input("P (%)", 0, 100, 60)
    
    total = q + a + p
    st.progress(min(total/100, 1.0), text=f"Suma: {total}%")
    
    if st.button("Calcular QAPF"):
        if total != 100:
            st.error("La suma debe ser 100%.")
        else:
            res = cerebro.identificar_qapf(textura_q, q, a, p)
            if res:
                st.success(f"Clasificación Streckeisen: **{res[0]}**")
            else:
                # Esto ya no debería pasar con la nueva lógica matemática
                st.error("Error de cálculo en el diagrama.")