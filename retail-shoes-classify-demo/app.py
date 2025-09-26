#!/usr/bin/env python3
"""
👟 DEMO RETAIL - CLASIFICACIÓN AUTOMÁTICA DE ZAPATOS
Aplicación Streamlit que usa Snowflake AISQL CLASSIFY
para categorizar productos de calzado automáticamente
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from snowflake.snowpark.context import get_active_session
import json
from datetime import datetime
from typing import Dict, Any, List, Optional
import base64

# Configuración de la página
st.set_page_config(
    page_title="🛍️ Retail Shoes AI Classifier",
    page_icon="👟",
    layout="wide",
    initial_sidebar_state="expanded"
)

# CSS personalizado para diseño retail
st.markdown("""
<style>
    .main-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 2rem;
        border-radius: 15px;
        margin-bottom: 2rem;
        text-align: center;
        color: white;
        box-shadow: 0 8px 32px rgba(102, 126, 234, 0.3);
    }
    
    .main-header h1 {
        margin: 0;
        font-size: 3rem;
        font-weight: 700;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
    }
    
    .main-header h3 {
        margin: 0.5rem 0 0 0;
        font-size: 1.3rem;
        opacity: 0.9;
    }
    
    .product-card {
        background: white;
        padding: 1.5rem;
        border-radius: 15px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        margin: 1rem 0;
        transition: transform 0.3s;
        border: 1px solid #e9ecef;
    }
    
    .product-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 30px rgba(0,0,0,0.15);
    }
    
    .category-badge {
        display: inline-block;
        padding: 0.5rem 1rem;
        border-radius: 25px;
        font-weight: 600;
        font-size: 0.9rem;
        margin: 0.25rem;
    }
    
    .badge-zapatos {
        background: linear-gradient(45deg, #3498db, #2980b9);
        color: white;
    }
    
    .badge-zapatillas {
        background: linear-gradient(45deg, #e74c3c, #c0392b);
        color: white;
    }
    
    .badge-chanclas {
        background: linear-gradient(45deg, #f39c12, #e67e22);
        color: white;
    }
    
    .confidence-bar {
        background: #f8f9fa;
        border-radius: 10px;
        padding: 0.3rem;
        margin: 0.5rem 0;
    }
    
    .confidence-fill {
        border-radius: 8px;
        height: 20px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-weight: 600;
        font-size: 0.8rem;
    }
    
    .stats-container {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 1.5rem;
        border-radius: 15px;
        color: white;
        margin: 1rem 0;
    }
    
    .filter-section {
        background: #f8f9fa;
        padding: 1.5rem;
        border-radius: 10px;
        margin: 1rem 0;
        border-left: 5px solid #667eea;
    }
    
    .price-tag {
        font-size: 1.5rem;
        font-weight: 700;
        color: #27ae60;
    }
    
    .brand-tag {
        background: #34495e;
        color: white;
        padding: 0.3rem 0.8rem;
        border-radius: 15px;
        font-size: 0.8rem;
        font-weight: 600;
    }
    
    .image-container {
        text-align: center;
        margin: 1rem 0;
    }
    
    .image-container img {
        border-radius: 10px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        max-width: 100%;
        height: auto;
    }
    
    .classification-section {
        background: linear-gradient(135deg, #a8e6cf 0%, #88d8a3 100%);
        padding: 1.5rem;
        border-radius: 10px;
        margin: 1rem 0;
    }
    
    .reclassify-button {
        background: linear-gradient(45deg, #ff6b6b, #ee5a24);
        color: white;
        border: none;
        padding: 0.5rem 1rem;
        border-radius: 20px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s;
    }
    
    .reclassify-button:hover {
        transform: scale(1.05);
        box-shadow: 0 4px 15px rgba(255, 107, 107, 0.4);
    }
</style>
""", unsafe_allow_html=True)

class RetailShoesClassifier:
    """Clase principal para la clasificación de zapatos con AI"""
    
    def __init__(self):
        self.session = get_active_session()
        self.setup_context()
    
    def setup_context(self):
        """Configurar el contexto de Snowflake"""
        try:
            self.session.sql("USE WAREHOUSE RETAIL_AI_WH").collect()
            self.session.sql("USE DATABASE RETAIL_SHOES_DEMO").collect()
            self.session.sql("USE SCHEMA PRODUCTS").collect()
            st.success("✅ Conectado a Snowflake - Base de datos de retail configurada")
        except Exception as e:
            st.error(f"❌ Error configurando contexto: {e}")
    
    def get_all_products(self) -> pd.DataFrame:
        """Obtener todos los productos con clasificación"""
        try:
            query = """
            SELECT 
                product_id,
                product_name,
                brand,
                price_usd,
                description,
                image_url,
                material,
                color,
                size_range,
                gender,
                season,
                style_keywords,
                ai_classification,
                ai_confidence,
                classification_date
            FROM shoes_products 
            ORDER BY created_date DESC
            """
            return self.session.sql(query).to_pandas()
        except Exception as e:
            st.error(f"Error obteniendo productos: {e}")
            return pd.DataFrame()
    
    def get_classification_stats(self) -> pd.DataFrame:
        """Obtener estadísticas de clasificación"""
        try:
            query = """
            SELECT 
                ai_classification,
                COUNT(*) as total_productos,
                ROUND(AVG(ai_confidence), 3) as confianza_promedio,
                ROUND(AVG(price_usd), 2) as precio_promedio,
                MIN(price_usd) as precio_min,
                MAX(price_usd) as precio_max
            FROM shoes_products 
            WHERE ai_classification IS NOT NULL
            GROUP BY ai_classification
            ORDER BY total_productos DESC
            """
            return self.session.sql(query).to_pandas()
        except Exception as e:
            st.error(f"Error obteniendo estadísticas: {e}")
            return pd.DataFrame()
    
    def classify_single_product(self, product_id: str) -> Dict[str, Any]:
        """Clasificar un producto individual"""
        try:
            query = f"""
            UPDATE shoes_products 
            SET 
                ai_classification = classify_shoe_product(description, product_name, style_keywords):class,
                ai_confidence = classify_shoe_product(description, product_name, style_keywords):confidence,
                classification_date = CURRENT_TIMESTAMP()
            WHERE product_id = '{product_id}'
            """
            self.session.sql(query).collect()
            
            # Obtener resultado actualizado
            result_query = f"""
            SELECT ai_classification, ai_confidence 
            FROM shoes_products 
            WHERE product_id = '{product_id}'
            """
            result = self.session.sql(result_query).to_pandas()
            
            if not result.empty:
                return {
                    'success': True,
                    'classification': result.iloc[0]['AI_CLASSIFICATION'],
                    'confidence': result.iloc[0]['AI_CONFIDENCE']
                }
            return {'success': False, 'error': 'No se pudo obtener resultado'}
            
        except Exception as e:
            return {'success': False, 'error': str(e)}
    
    def add_new_product(self, product_data: Dict[str, Any]) -> bool:
        """Agregar un nuevo producto"""
        try:
            # Generar ID único
            product_id = f"ZAP{datetime.now().strftime('%Y%m%d%H%M%S')}"
            
            query = f"""
            INSERT INTO shoes_products (
                product_id, product_name, brand, price_usd, description,
                image_url, material, color, size_range, gender, season, style_keywords
            ) VALUES (
                '{product_id}',
                '{product_data['name']}',
                '{product_data['brand']}',
                {product_data['price']},
                '{product_data['description']}',
                '{product_data['image_url']}',
                '{product_data['material']}',
                '{product_data['color']}',
                '{product_data['size_range']}',
                '{product_data['gender']}',
                '{product_data['season']}',
                '{product_data['keywords']}'
            )
            """
            self.session.sql(query).collect()
            
            # Clasificar automáticamente
            self.classify_single_product(product_id)
            
            return True
        except Exception as e:
            st.error(f"Error agregando producto: {e}")
            return False

def display_product_card(product: pd.Series, classifier: RetailShoesClassifier):
    """Mostrar tarjeta de producto con imagen y clasificación"""
    
    with st.container():
        st.markdown('<div class="product-card">', unsafe_allow_html=True)
        
        col1, col2, col3 = st.columns([1, 2, 1])
        
        with col1:
            # Imagen del producto
            if pd.notna(product['IMAGE_URL']) and product['IMAGE_URL']:
                st.markdown('<div class="image-container">', unsafe_allow_html=True)
                try:
                    st.image(product['IMAGE_URL'], width=200, caption=f"Código: {product['PRODUCT_ID']}")
                except:
                    st.image("https://via.placeholder.com/200x200/cccccc/666666?text=Sin+Imagen", 
                            width=200, caption=f"Código: {product['PRODUCT_ID']}")
                st.markdown('</div>', unsafe_allow_html=True)
        
        with col2:
            # Información del producto
            st.markdown(f"### {product['PRODUCT_NAME']}")
            st.markdown(f'<span class="brand-tag">{product["BRAND"]}</span>', unsafe_allow_html=True)
            st.markdown(f'<div class="price-tag">${product["PRICE_USD"]:.2f}</div>', unsafe_allow_html=True)
            
            st.markdown(f"**Descripción:** {product['DESCRIPTION'][:150]}...")
            
            # Detalles del producto
            col_det1, col_det2 = st.columns(2)
            with col_det1:
                st.markdown(f"**Material:** {product['MATERIAL']}")
                st.markdown(f"**Color:** {product['COLOR']}")
                st.markdown(f"**Género:** {product['GENDER']}")
            with col_det2:
                st.markdown(f"**Tallas:** {product['SIZE_RANGE']}")
                st.markdown(f"**Temporada:** {product['SEASON']}")
        
        with col3:
            # Clasificación AI
            st.markdown('<div class="classification-section">', unsafe_allow_html=True)
            st.markdown("### 🤖 Clasificación AI")
            
            if pd.notna(product['AI_CLASSIFICATION']):
                # Badge de categoría
                category = product['AI_CLASSIFICATION']
                badge_class = f"badge-{category.lower()}"
                st.markdown(f'<div class="category-badge {badge_class}">{category}</div>', 
                           unsafe_allow_html=True)
                
                # Barra de confianza
                confidence = float(product['AI_CONFIDENCE']) if pd.notna(product['AI_CONFIDENCE']) else 0
                confidence_pct = confidence * 100
                
                # Color de la barra según confianza
                if confidence >= 0.8:
                    bar_color = "#27ae60"
                elif confidence >= 0.6:
                    bar_color = "#f39c12"
                else:
                    bar_color = "#e74c3c"
                
                st.markdown(f"""
                <div class="confidence-bar">
                    <div class="confidence-fill" style="width: {confidence_pct}%; background: {bar_color}">
                        {confidence_pct:.1f}%
                    </div>
                </div>
                """, unsafe_allow_html=True)
                
                st.markdown(f"**Fecha:** {product['CLASSIFICATION_DATE']}")
            else:
                st.warning("⚠️ No clasificado")
            
            # Botón para reclasificar
            if st.button(f"🔄 Reclasificar", key=f"reclass_{product['PRODUCT_ID']}"):
                with st.spinner("Clasificando..."):
                    result = classifier.classify_single_product(product['PRODUCT_ID'])
                    if result['success']:
                        st.success(f"✅ Reclasificado como: {result['classification']} ({result['confidence']:.3f})")
                        st.rerun()
                    else:
                        st.error(f"❌ Error: {result['error']}")
            
            st.markdown('</div>', unsafe_allow_html=True)
        
        st.markdown('</div>', unsafe_allow_html=True)
        st.markdown("---")

def create_classification_charts(stats_df: pd.DataFrame):
    """Crear gráficos de análisis de clasificación"""
    
    if stats_df.empty:
        st.warning("No hay datos de clasificación disponibles")
        return
    
    col1, col2 = st.columns(2)
    
    with col1:
        # Gráfico de distribución por categoría
        fig_dist = px.pie(
            stats_df, 
            values='TOTAL_PRODUCTOS', 
            names='AI_CLASSIFICATION',
            title="🍕 Distribución de Productos por Categoría",
            color_discrete_map={
                'ZAPATOS': '#3498db',
                'ZAPATILLAS': '#e74c3c', 
                'CHANCLAS': '#f39c12'
            },
            hole=0.4
        )
        fig_dist.update_traces(textposition='inside', textinfo='percent+label')
        fig_dist.update_layout(height=400)
        st.plotly_chart(fig_dist, use_container_width=True)
    
    with col2:
        # Gráfico de confianza promedio
        fig_conf = px.bar(
            stats_df,
            x='AI_CLASSIFICATION',
            y='CONFIANZA_PROMEDIO',
            title="📊 Confianza Promedio por Categoría",
            color='CONFIANZA_PROMEDIO',
            color_continuous_scale="Viridis",
            text='CONFIANZA_PROMEDIO'
        )
        fig_conf.update_traces(texttemplate='%{text:.3f}', textposition='outside')
        fig_conf.update_layout(height=400, showlegend=False)
        fig_conf.update_yaxes(range=[0, 1])
        st.plotly_chart(fig_conf, use_container_width=True)
    
    # Gráfico de precio por categoría
    st.markdown("### 💰 Análisis de Precios por Categoría")
    
    fig_price = go.Figure()
    
    for _, row in stats_df.iterrows():
        fig_price.add_trace(go.Bar(
            name=row['AI_CLASSIFICATION'],
            x=['Precio Promedio'],
            y=[row['PRECIO_PROMEDIO']],
            text=[f"${row['PRECIO_PROMEDIO']:.2f}"],
            textposition='auto',
            marker_color={'ZAPATOS': '#3498db', 'ZAPATILLAS': '#e74c3c', 'CHANCLAS': '#f39c12'}[row['AI_CLASSIFICATION']]
        ))
    
    fig_price.update_layout(
        title="💲 Precio Promedio por Categoría",
        barmode='group',
        height=400
    )
    st.plotly_chart(fig_price, use_container_width=True)

def main():
    """Función principal de la aplicación"""
    
    # Header principal
    st.markdown("""
    <div class="main-header">
        <h1>👟 Retail Shoes AI Classifier</h1>
        <h3>🤖 Clasificación Automática con Snowflake AISQL CLASSIFY</h3>
        <p style="margin: 0.5rem 0 0 0; font-size: 1rem;">
            Zapatos • Zapatillas • Chanclas | Powered by Snowflake Cortex AI
        </p>
    </div>
    """, unsafe_allow_html=True)
    
    # Inicializar clasificador
    if 'classifier' not in st.session_state:
        with st.spinner("🔄 Inicializando sistema de clasificación AI..."):
            st.session_state.classifier = RetailShoesClassifier()
    
    classifier = st.session_state.classifier
    
    # Sidebar con estadísticas y filtros
    with st.sidebar:
        st.markdown("### 📊 Panel de Control")
        
        # Cargar estadísticas
        stats_df = classifier.get_classification_stats()
        
        if not stats_df.empty:
            st.markdown('<div class="stats-container">', unsafe_allow_html=True)
            st.markdown("#### 🎯 Estadísticas Generales")
            
            total_products = stats_df['TOTAL_PRODUCTOS'].sum()
            avg_confidence = stats_df['CONFIANZA_PROMEDIO'].mean()
            
            st.metric("Total Productos", total_products)
            st.metric("Confianza Promedio", f"{avg_confidence:.3f}")
            
            st.markdown("#### 📋 Por Categoría")
            for _, row in stats_df.iterrows():
                st.markdown(f"**{row['AI_CLASSIFICATION']}:** {row['TOTAL_PRODUCTOS']} productos")
            
            st.markdown('</div>', unsafe_allow_html=True)
        
        st.markdown("---")
        
        # Filtros
        st.markdown('<div class="filter-section">', unsafe_allow_html=True)
        st.markdown("### 🔍 Filtros")
        
        # Filtro por categoría
        categories = ['Todas'] + list(stats_df['AI_CLASSIFICATION'].values) if not stats_df.empty else ['Todas']
        selected_category = st.selectbox("Categoría", categories)
        
        # Filtro por rango de precio
        price_range = st.slider("Rango de Precio ($)", 0, 300, (0, 300))
        
        # Filtro por confianza mínima
        min_confidence = st.slider("Confianza Mínima", 0.0, 1.0, 0.0, 0.1)
        
        st.markdown('</div>', unsafe_allow_html=True)
        
        st.markdown("---")
        
        # Botón para clasificar todos los productos
        if st.button("🤖 Clasificar Todos los Productos", type="primary"):
            with st.spinner("Ejecutando clasificación automática..."):
                try:
                    result = classifier.session.sql("CALL classify_all_products()").collect()
                    if result:
                        st.success(f"✅ {result[0][0]}")
                        st.rerun()
                except Exception as e:
                    st.error(f"❌ Error: {e}")
    
    # Tabs principales
    tab1, tab2, tab3, tab4 = st.tabs(["🛍️ Catálogo de Productos", "📊 Análisis de Clasificación", "➕ Agregar Producto", "ℹ️ Información"])
    
    with tab1:
        st.markdown("## 🛍️ Catálogo de Productos con Clasificación AI")
        
        # Cargar productos
        products_df = classifier.get_all_products()
        
        if products_df.empty:
            st.warning("⚠️ No hay productos en la base de datos")
            return
        
        # Aplicar filtros
        filtered_df = products_df.copy()
        
        if selected_category != 'Todas':
            filtered_df = filtered_df[filtered_df['AI_CLASSIFICATION'] == selected_category]
        
        filtered_df = filtered_df[
            (filtered_df['PRICE_USD'] >= price_range[0]) & 
            (filtered_df['PRICE_USD'] <= price_range[1])
        ]
        
        if min_confidence > 0:
            filtered_df = filtered_df[
                (filtered_df['AI_CONFIDENCE'] >= min_confidence) | 
                (filtered_df['AI_CONFIDENCE'].isna())
            ]
        
        st.markdown(f"**Mostrando {len(filtered_df)} de {len(products_df)} productos**")
        
        # Mostrar productos
        for _, product in filtered_df.iterrows():
            display_product_card(product, classifier)
    
    with tab2:
        st.markdown("## 📊 Análisis de Clasificación AI")
        
        if not stats_df.empty:
            create_classification_charts(stats_df)
            
            # Tabla de estadísticas detalladas
            st.markdown("### 📋 Estadísticas Detalladas")
            st.dataframe(
                stats_df.round(3),
                column_config={
                    "AI_CLASSIFICATION": "Categoría",
                    "TOTAL_PRODUCTOS": "Total Productos",
                    "CONFIANZA_PROMEDIO": "Confianza Promedio",
                    "PRECIO_PROMEDIO": "Precio Promedio ($)",
                    "PRECIO_MIN": "Precio Mínimo ($)",
                    "PRECIO_MAX": "Precio Máximo ($)"
                },
                use_container_width=True
            )
            
            # Productos con baja confianza
            st.markdown("### ⚠️ Productos que Requieren Revisión")
            low_confidence_df = products_df[
                (products_df['AI_CONFIDENCE'] < 0.7) & 
                (products_df['AI_CONFIDENCE'].notna())
            ][['PRODUCT_ID', 'PRODUCT_NAME', 'AI_CLASSIFICATION', 'AI_CONFIDENCE']]
            
            if not low_confidence_df.empty:
                st.dataframe(low_confidence_df, use_container_width=True)
            else:
                st.success("✅ Todos los productos tienen alta confianza de clasificación")
        else:
            st.info("📊 Ejecuta la clasificación automática para ver análisis")
    
    with tab3:
        st.markdown("## ➕ Agregar Nuevo Producto")
        
        with st.form("add_product_form"):
            col1, col2 = st.columns(2)
            
            with col1:
                name = st.text_input("Nombre del Producto *")
                brand = st.text_input("Marca *")
                price = st.number_input("Precio (USD) *", min_value=0.01, value=50.0)
                material = st.text_input("Material *")
                color = st.text_input("Color *")
            
            with col2:
                size_range = st.text_input("Rango de Tallas *", value="35-45")
                gender = st.selectbox("Género", ["Hombre", "Mujer", "Unisex"])
                season = st.selectbox("Temporada", ["Todo el año", "Primavera/Verano", "Otoño/Invierno", "Verano"])
                image_url = st.text_input("URL de Imagen", placeholder="https://...")
            
            description = st.text_area("Descripción del Producto *", height=100)
            keywords = st.text_input("Palabras Clave", placeholder="casual, cómodo, elegante...")
            
            submitted = st.form_submit_button("🤖 Agregar y Clasificar Automáticamente", type="primary")
            
            if submitted:
                if name and brand and description and material and color:
                    product_data = {
                        'name': name,
                        'brand': brand,
                        'price': price,
                        'description': description,
                        'image_url': image_url if image_url else 'https://via.placeholder.com/400x400/cccccc/666666?text=Sin+Imagen',
                        'material': material,
                        'color': color,
                        'size_range': size_range,
                        'gender': gender,
                        'season': season,
                        'keywords': keywords
                    }
                    
                    with st.spinner("Agregando producto y clasificando..."):
                        if classifier.add_new_product(product_data):
                            st.success("✅ Producto agregado y clasificado exitosamente!")
                            st.balloons()
                            st.rerun()
                        else:
                            st.error("❌ Error al agregar el producto")
                else:
                    st.error("⚠️ Por favor completa todos los campos obligatorios (*)")
    
    with tab4:
        st.markdown("## ℹ️ Información de la Demo")
        
        st.markdown("""
        ### 🤖 Sobre la Clasificación AI
        
        Esta demo utiliza **Snowflake AISQL CLASSIFY** para categorizar automáticamente productos de calzado en tres categorías principales:
        
        - **👔 ZAPATOS**: Calzado formal y elegante para oficina y eventos especiales
        - **👟 ZAPATILLAS**: Calzado deportivo y casual para actividades físicas y uso diario
        - **🩴 CHANCLAS**: Calzado abierto, sandalias para playa y clima cálido
        
        ### 🎯 Cómo Funciona
        
        1. **Análisis de Texto**: El AI analiza el nombre, descripción y palabras clave del producto
        2. **Clasificación Automática**: Determina la categoría más apropiada
        3. **Nivel de Confianza**: Asigna un puntaje de confianza (0-1)
        4. **Visualización**: Muestra resultados con imágenes y métricas
        
        ### 📊 Métricas de Confianza
        
        - **🟢 Alta Confianza (≥0.8)**: Clasificación muy confiable
        - **🟡 Confianza Media (0.6-0.8)**: Clasificación aceptable
        - **🔴 Baja Confianza (<0.6)**: Requiere revisión manual
        
        ### 🛠️ Tecnologías Utilizadas
        
        - **Snowflake Cortex AI**: Para clasificación automática de texto
        - **Streamlit**: Interfaz de usuario interactiva
        - **Plotly**: Visualizaciones y gráficos
        - **Pandas**: Manipulación de datos
        - **Unsplash**: Imágenes de productos de muestra
        
        ### 🎨 Características de la Demo
        
        - ✅ **Interfaz Visual**: Tarjetas de productos con imágenes
        - ✅ **Clasificación en Tiempo Real**: Reclasificación automática
        - ✅ **Análisis Estadístico**: Gráficos y métricas
        - ✅ **Filtros Dinámicos**: Por categoría, precio y confianza
        - ✅ **Agregar Productos**: Formulario para nuevos items
        - ✅ **Responsive Design**: Optimizado para diferentes pantallas
        """)
        
        # Mostrar información técnica
        with st.expander("🔧 Información Técnica"):
            st.code("""
            -- Función de clasificación utilizada:
            CREATE FUNCTION classify_shoe_product(description TEXT, product_name TEXT, style_keywords TEXT)
            RETURNS OBJECT
            AS $$
              SELECT SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
                CONCAT(product_name, '. ', description, '. Características: ', style_keywords),
                ['ZAPATOS', 'ZAPATILLAS', 'CHANCLAS'],
                'Clasifica este producto de calzado en una de estas categorías...'
              )
            $$;
            """, language="sql")

if __name__ == "__main__":
    main()