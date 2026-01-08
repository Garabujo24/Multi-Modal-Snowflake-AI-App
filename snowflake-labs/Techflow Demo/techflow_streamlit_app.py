"""
Liverpool México - Snowflake Cortex Retail Analytics Demo
=========================================================
Comprehensive Streamlit application demonstrating Snowflake Cortex capabilities for retail:
- Cortex Analyst (Natural Language Queries for Retail Analytics)
- Cortex Search (Product Catalog and Documentation Search)
- AISQL Multimodal (Customer Review and Product Image Analysis)
- ML Predictive (Sales Forecasting and Customer Behavior Prediction)

Author: Snowflake Sales Engineer
Version: 1.0 - Liverpool México Edition
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import snowflake.connector
from snowflake.snowpark import Session
import json
import datetime
from typing import Dict, List, Any
import base64
from io import StringIO

# =====================================================
# CONFIGURACIÓN DE LA APLICACIÓN
# =====================================================

st.set_page_config(
    page_title="TechFlow Solutions - Cortex Demo",
    page_icon="🚀",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Liverpool México Color Palette
LIVERPOOL_COLORS = {
    'primary': '#E53E3E',      # Liverpool Red
    'secondary': '#FC8181',    # Light Red
    'accent': '#38B2AC',       # Teal Accent
    'warning': '#D69E2E',      # Gold
    'danger': '#E53E3E',       # Liverpool Red
    'neutral': '#4A5568',      # Gray
    'background': '#FFF5F5'    # Light Red Background
}

# Custom CSS for Liverpool branding
st.markdown(f"""
<style>
    .main-header {{
        background: linear-gradient(90deg, {LIVERPOOL_COLORS['primary']} 0%, {LIVERPOOL_COLORS['secondary']} 100%);
        padding: 1rem;
        border-radius: 10px;
        margin-bottom: 2rem;
        color: white;
        text-align: center;
    }}
    
    .metric-card {{
        background: white;
        padding: 1rem;
        border-radius: 8px;
        border-left: 4px solid {LIVERPOOL_COLORS['primary']};
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        margin-bottom: 1rem;
    }}
    
    .section-header {{
        color: {LIVERPOOL_COLORS['primary']};
        border-bottom: 2px solid {LIVERPOOL_COLORS['secondary']};
        padding-bottom: 0.5rem;
        margin-bottom: 1rem;
    }}
    
    .alert-box {{
        padding: 1rem;
        border-radius: 8px;
        margin-bottom: 1rem;
    }}
    
    .alert-success {{
        background-color: #D1FAE5;
        border-left: 4px solid {LIVERPOOL_COLORS['accent']};
        color: #065F46;
    }}
    
    .alert-warning {{
        background-color: #FEF3C7;
        border-left: 4px solid {LIVERPOOL_COLORS['warning']};
        color: #92400E;
    }}
    
    .alert-danger {{
        background-color: #FEE2E2;
        border-left: 4px solid {LIVERPOOL_COLORS['danger']};
        color: #991B1B;
    }}
    
    .sidebar .sidebar-content {{
        background: {LIVERPOOL_COLORS['background']};
    }}
    
    .stButton > button {{
        background-color: {LIVERPOOL_COLORS['primary']};
        color: white;
        border-radius: 6px;
        border: none;
        padding: 0.5rem 1rem;
        font-weight: 500;
    }}
    
    .stButton > button:hover {{
        background-color: {LIVERPOOL_COLORS['secondary']};
        transform: translateY(-1px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.2);
    }}
</style>
""", unsafe_allow_html=True)

# =====================================================
# CONFIGURACIÓN DE SNOWFLAKE
# =====================================================

@st.cache_resource
def init_snowflake_connection():
    """Inicializar conexión a Snowflake"""
    try:
        # En producción, usar st.secrets para credenciales
        connection_params = {
            "user": st.secrets.get("snowflake_user", "DEMO_USER"),
            "password": st.secrets.get("snowflake_password", "DEMO_PASSWORD"),
            "account": st.secrets.get("snowflake_account", "DEMO_ACCOUNT"),
            "warehouse": st.secrets.get("snowflake_warehouse", "LIVERPOOL_WH"),
            "database": "LIVERPOOL_RETAIL",
            "schema": "ANALYTICS",
            "role": "RETAIL_ANALYST_ROLE"
        }
        
        session = Session.builder.configs(connection_params).create()
        return session, True
    except Exception as e:
        st.error(f"Error conectando a Snowflake: {str(e)}")
        return None, False

@st.cache_data(ttl=300)  # Cache por 5 minutos
def execute_query(query: str) -> pd.DataFrame:
    """Ejecutar query en Snowflake y retornar DataFrame"""
    session, connected = init_snowflake_connection()
    if not connected:
        return pd.DataFrame()
    
    try:
        result = session.sql(query).to_pandas()
        return result
    except Exception as e:
        st.error(f"Error ejecutando query: {str(e)}")
        return pd.DataFrame()

# =====================================================
# SIMULADOR DE DATOS (Para demo sin Snowflake)
# =====================================================

def simulate_snowflake_data():
    """Simulate retail data for Liverpool México when Snowflake is not available"""
    
    # Retail sales data - monthly revenue in millions (MXN)
    # Generate exactly 16 monthly periods
    meses = pd.date_range('2023-01-01', periods=16, freq='ME')
    # Liverpool-scale revenue figures (in millions MXN)
    ingresos = [2450, 2820, 2680, 3210, 2950, 3180, 
                3420, 3150, 3680, 3920, 3850, 4250,
                4180, 4520, 4280, 4650]
    # Transaction counts (in thousands)
    transacciones = [450, 520, 480, 610, 550, 580, 620, 590, 670, 710, 690, 750, 780, 820, 760, 850]
    # New customer registrations (in thousands)
    clientes_nuevos = [18, 22, 19, 25, 21, 23, 24, 22, 26, 28, 25, 29, 31, 34, 28, 32]
    
    # Verificar longitudes antes de crear DataFrame
    assert len(meses) == len(ingresos) == len(transacciones) == len(clientes_nuevos), \
        f"Length mismatch: meses={len(meses)}, ingresos={len(ingresos)}, transacciones={len(transacciones)}, clientes_nuevos={len(clientes_nuevos)}"
    
    ventas_data = pd.DataFrame({
        'mes': meses,
        'ingresos': ingresos,
        'transacciones': transacciones,
        'clientes_nuevos': clientes_nuevos
    })
    
    # Product categories and performance
    productos_data = pd.DataFrame({
        'producto': ['Fashion & Apparel', 'Home & Furniture', 'Electronics & Tech', 
                    'Beauty & Cosmetics', 'Sports & Outdoor', 'Jewelry & Watches'],
        'categoria': ['Fashion', 'Home', 'Electronics', 'Beauty', 'Sports', 'Luxury'],
        'ingresos': [1250, 980, 750, 650, 420, 380],  # in millions MXN
        'crecimiento': [18.5, 12.3, 25.2, 15.7, 8.1, 22.9]
    })
    
    # Customer segments at risk
    churn_data = pd.DataFrame({
        'cliente': ['Premium Members Segment', 'Young Professionals', 'Family Shoppers',
                   'Senior Citizens', 'Fashion Enthusiasts'],
        'segmento': ['Premium', 'Millennials', 'Families', 'Seniors', 'Fashion'],
        'probabilidad_churn': [0.15, 0.25, 0.12, 0.35, 0.18],
        'valor_cliente': [125000, 45000, 75000, 85000, 95000],  # Annual CLV in MXN
        'riesgo': ['LOW', 'MEDIUM', 'LOW', 'HIGH', 'LOW']
    })
    
    # Customer service tickets (120 days of data)
    num_days = 120
    tickets_data = pd.DataFrame({
        'fecha': pd.date_range('2024-01-01', periods=num_days, freq='D'),
        'tickets_nuevos': ([30, 45, 28, 52, 38, 41, 35, 48, 55, 32, 42, 39, 44, 58, 29, 37] * (num_days // 16 + 1))[:num_days],
        'satisfaccion': ([4.2, 4.5, 4.1, 4.3, 3.8, 4.6, 4.4, 4.0, 3.9, 4.5] * (num_days // 10 + 1))[:num_days]
    })
    
    return ventas_data, productos_data, churn_data, tickets_data

# =====================================================
# MAIN HEADER
# =====================================================

st.markdown("""
<div class="main-header">
    <h1>🛍️ Liverpool México</h1>
    <h3>Snowflake Cortex - Retail Analytics & AI Demo</h3>
    <p>Transforming retail operations with intelligent data analytics and predictive insights</p>
</div>
""", unsafe_allow_html=True)

# =====================================================
# SIDEBAR - NAVIGATION
# =====================================================

with st.sidebar:
    st.image("https://via.placeholder.com/200x80/E53E3E/FFFFFF?text=Liverpool+M%C3%A9xico", 
             caption="Department Store & E-Commerce")
    
    st.markdown("### 🧭 Navigation")
    
    demo_section = st.radio(
        "Select a section:",
        [
            "🏠 Introduction",
            "📊 Executive Dashboard",
            "🤖 Cortex Analyst", 
            "🔍 Cortex Search",
            "🎯 AISQL Multimodal",
            "📈 ML Predictive",
            "⚠️ Alerts & Monitoring"
        ]
    )
    
    st.markdown("---")
    
    # Connection configuration
    st.markdown("### ⚙️ Configuration")
    use_simulation = st.checkbox("Use simulated data", value=True, 
                                help="Enable for demo without Snowflake connection")
    
    if not use_simulation:
        st.text_input("Snowflake Account", placeholder="abc12345.us-east-1")
        st.text_input("Username", placeholder="user@company.com")
        st.text_input("Password", type="password")
    
    st.markdown("---")
    
    # Demo information
    st.markdown("### ℹ️ Information")
    st.info("""
    **Demo Kit v1.0**
    
    This application demonstrates the complete capabilities of Snowflake Cortex for intelligent business analytics.
    
    🎯 **Included use cases:**
    - Sales analysis and forecasting
    - Intelligent document search
    - Natural language processing
    - Anomaly detection
    - Predictive churn analysis
    """)

# =====================================================
# AUXILIARY FUNCTION FOR METRICS
# =====================================================

def display_metric_card(title: str, value: str, delta: str = None, delta_color: str = "normal"):
    """Display custom metric card"""
    delta_html = ""
    if delta:
        color = LIVERPOOL_COLORS['accent'] if delta_color == "normal" else LIVERPOOL_COLORS['danger']
        delta_html = f'<p style="color: {color}; font-size: 0.9rem; margin: 0;">{delta}</p>'
    
    st.markdown(f"""
    <div class="metric-card">
        <h4 style="margin: 0; color: {LIVERPOOL_COLORS['neutral']};">{title}</h4>
        <h2 style="margin: 0.5rem 0; color: {LIVERPOOL_COLORS['primary']};">{value}</h2>
        {delta_html}
    </div>
    """, unsafe_allow_html=True)

# =====================================================
# SECTION 0: INTRODUCTION
# =====================================================

if demo_section == "🏠 Introduction":
    st.markdown('<h2 class="section-header">🏠 Welcome to Liverpool México Cortex Demo</h2>', unsafe_allow_html=True)
    
    # Hero section
    col1, col2 = st.columns([2, 1])
    
    with col1:
        st.markdown("""
        ## 🛍️ **Revolutionizing Retail with Snowflake Cortex**
        
        Welcome to Liverpool México's comprehensive demonstration of **Snowflake Cortex AI capabilities for retail**. 
        This interactive application showcases how modern retailers can leverage artificial intelligence 
        to transform their merchandising, customer experience, and operational efficiency.
        
        ### 🎯 **What You'll Experience**
        
        This demo simulates Liverpool México's **real retail environment** where Mexico's leading department store 
        uses Snowflake Cortex to power their omnichannel analytics, customer insights, and inventory optimization.
        """)
    
    with col2:
        # Key metrics overview
        st.markdown("### 📊 **Demo Highlights**")
        
        metrics_data = [
            {"icon": "🏪", "value": "120+", "label": "Store Locations"},
            {"icon": "📊", "value": "25+", "label": "AI Functions"},
            {"icon": "🛍️", "value": "6", "label": "Product Categories"},
            {"icon": "📈", "value": "12", "label": "Predictive Models"}
        ]
        
        for metric in metrics_data:
            st.markdown(f"""
            <div style="background: white; padding: 0.8rem; border-radius: 8px; margin-bottom: 0.5rem; 
                        border-left: 4px solid {LIVERPOOL_COLORS['primary']}; text-align: center;">
                <div style="font-size: 1.5rem;">{metric['icon']}</div>
                <div style="font-size: 1.2rem; font-weight: bold; color: {LIVERPOOL_COLORS['primary']};">{metric['value']}</div>
                <div style="font-size: 0.9rem; color: {LIVERPOOL_COLORS['neutral']};">{metric['label']}</div>
            </div>
            """, unsafe_allow_html=True)
    
    st.markdown("---")
    
    # Snowflake Cortex Features
    st.markdown("## 🧠 **Snowflake Cortex AI Features Demonstrated**")
    
    # Create feature cards for retail
    features = [
        {
            "title": "🤖 Cortex Analyst",
            "description": "Natural language queries for retail analytics",
            "functions": ["Sales Analysis", "Customer Insights", "Inventory Intelligence"],
            "business_value": "Enable merchandisers to query data without SQL knowledge",
            "demo_highlight": "Ask 'Which fashion categories performed best this season?' in plain English"
        },
        {
            "title": "🔍 Cortex Search",
            "description": "Product catalog and documentation search",
            "functions": ["Product Search", "Policy Retrieval", "Training Materials"],
            "business_value": "Instant access to product information and procedures",
            "demo_highlight": "Search through product catalogs, policies, and training materials"
        },
        {
            "title": "🎯 AISQL Multimodal",
            "description": "Customer review and product image analysis",
            "functions": ["Review Sentiment", "Product Classification", "Visual Analysis"],
            "business_value": "Automate product categorization and customer feedback analysis",
            "demo_highlight": "Analyze customer reviews and classify product images automatically"
        },
        {
            "title": "📈 ML Predictive",
            "description": "Sales forecasting and demand planning",
            "functions": ["Demand Forecasting", "Customer Churn", "Inventory Optimization"],
            "business_value": "Optimize inventory and predict customer behavior patterns",
            "demo_highlight": "Forecast seasonal demand and identify customers at risk of churn"
        }
    ]
    
    # Display feature cards using tabs for better organization
    tab1, tab2, tab3, tab4 = st.tabs([f['title'] for f in features])
    
    tabs = [tab1, tab2, tab3, tab4]
    
    for i, (tab, feature) in enumerate(zip(tabs, features)):
        with tab:
            st.markdown(f"### {feature['description']}")
            
            col1, col2 = st.columns(2)
            
            with col1:
                st.markdown("#### 🔧 **Key Functions**")
                for func in feature['functions']:
                    st.write(f"• {func}")
                
                st.markdown("#### 💼 **Business Value**")
                st.write(f"*{feature['business_value']}*")
            
            with col2:
                st.markdown("#### 💡 **Try This Demo**")
                st.info(feature['demo_highlight'])
                
                # Add retail-specific SQL examples
                if 'Analyst' in feature['title']:
                    st.code("SELECT category, sales_amount FROM transactions WHERE season = 'Spring'", language='sql')
                elif 'Search' in feature['title']:
                    st.code("SEARCH('product return policy') IN policy_documents", language='sql')
                elif 'AISQL' in feature['title']:
                    st.code("SELECT SNOWFLAKE.CORTEX.SENTIMENT(customer_review)", language='sql')
                elif 'ML' in feature['title']:
                    st.code("SELECT FORECAST(demand) FROM sales_history GROUP BY category", language='sql')
    
    st.markdown("---")
    
    # Business Impact Section
    st.markdown("## 💼 **Business Impact & ROI**")
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        st.markdown(f"""
        ### 📈 **Retail Operations**
        
        <div style="background: {LIVERPOOL_COLORS['accent']}15; padding: 1rem; border-radius: 8px;">
            <ul style="color: {LIVERPOOL_COLORS['neutral']};">
                <li><strong>40% improvement</strong> in inventory turnover</li>
                <li><strong>25% reduction</strong> in stockouts</li>
                <li><strong>30% faster</strong> product categorization</li>
                <li><strong>50% improvement</strong> in demand forecasting accuracy</li>
            </ul>
        </div>
        """, unsafe_allow_html=True)
    
    with col2:
        st.markdown(f"""
        ### 🎯 **Customer Experience**
        
        <div style="background: {LIVERPOOL_COLORS['warning']}15; padding: 1rem; border-radius: 8px;">
            <ul style="color: {LIVERPOOL_COLORS['neutral']};">
                <li><strong>Personalized recommendations</strong> for every customer</li>
                <li><strong>Real-time inventory</strong> visibility across channels</li>
                <li><strong>Sentiment analysis</strong> on customer reviews</li>
                <li><strong>Automated customer</strong> service insights</li>
            </ul>
        </div>
        """, unsafe_allow_html=True)
    
    with col3:
        st.markdown(f"""
        ### 🚀 **Market Leadership**
        
        <div style="background: {LIVERPOOL_COLORS['primary']}15; padding: 1rem; border-radius: 8px;">
            <ul style="color: {LIVERPOOL_COLORS['neutral']};">
                <li><strong>Omnichannel</strong> analytics integration</li>
                <li><strong>AI-powered</strong> merchandising decisions</li>
                <li><strong>Scalable</strong> across 120+ stores</li>
                <li><strong>Data-driven</strong> competitive advantage</li>
            </ul>
        </div>
        """, unsafe_allow_html=True)
    
    # Getting Started
    st.markdown("---")
    st.markdown("## 🎯 **Ready to Explore?**")
    
    st.markdown(f"""
    <div style="background: linear-gradient(135deg, {LIVERPOOL_COLORS['primary']} 0%, {LIVERPOOL_COLORS['secondary']} 100%); 
                color: white; padding: 2rem; border-radius: 12px; text-align: center;">
        <h3 style="margin: 0 0 1rem 0;">Start Your Journey</h3>
        <p style="margin: 0 0 1.5rem 0; font-size: 1.1rem;">
            Use the navigation menu on the left to explore different Snowflake Cortex capabilities. 
            Each section includes interactive demos with real business scenarios.
        </p>
        <div style="display: flex; justify-content: center; gap: 1rem; flex-wrap: wrap;">
            <div style="background: rgba(255,255,255,0.2); padding: 0.5rem 1rem; border-radius: 6px;">
                📊 Start with Executive Dashboard
            </div>
            <div style="background: rgba(255,255,255,0.2); padding: 0.5rem 1rem; border-radius: 6px;">
                🤖 Try Natural Language Queries
            </div>
            <div style="background: rgba(255,255,255,0.2); padding: 0.5rem 1rem; border-radius: 6px;">
                🔍 Search Enterprise Documents
            </div>
        </div>
    </div>
    """, unsafe_allow_html=True)

# =====================================================
# SECTION 1: EXECUTIVE DASHBOARD
# =====================================================

elif demo_section == "📊 Executive Dashboard":
    st.markdown('<h2 class="section-header">📊 Executive Dashboard</h2>', unsafe_allow_html=True)
    
    # Get data (simulated or real)
    if use_simulation:
        ventas_data, productos_data, churn_data, tickets_data = simulate_snowflake_data()
    else:
        # Real Snowflake queries
        ventas_data = execute_query("SELECT * FROM VISTA_VENTAS_RESUMEN ORDER BY MES")
        productos_data = execute_query("SELECT * FROM VISTA_PRODUCTOS_RENDIMIENTO")
        churn_data = execute_query("SELECT * FROM ANALISIS_CHURN_CLIENTES WHERE CHURN_ANALYSIS:risk_level::VARCHAR != 'LOW'")
    
    # Key metrics
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        display_metric_card(
            "Monthly Revenue", 
            "$4.65B MXN", 
            "↗️ +8.2% vs previous month"
        )
    
    with col2:
        display_metric_card(
            "New Customers", 
            "32K", 
            "↗️ +14% vs previous month"
        )
    
    with col3:
        display_metric_card(
            "Customer Satisfaction", 
            "4.3/5.0", 
            "↗️ +0.2 points"
        )
    
    with col4:
        display_metric_card(
            "Inventory Alerts", 
            "3", 
            "⚠️ 1 critical stockout",
            "warning"
        )
    
    # Main charts
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("### 📈 Revenue Trend")
        if not ventas_data.empty:
            fig_ventas = px.line(
                ventas_data, 
                x='mes', 
                y='ingresos',
                title="Monthly Revenue Evolution",
                color_discrete_sequence=[LIVERPOOL_COLORS['primary']]
            )
            fig_ventas.update_layout(
                plot_bgcolor='rgba(0,0,0,0)',
                paper_bgcolor='rgba(0,0,0,0)'
            )
            st.plotly_chart(fig_ventas, use_container_width=True)
    
    with col2:
        st.markdown("### 🎯 Product Performance")
        if not productos_data.empty:
            fig_productos = px.bar(
                productos_data.head(6), 
                x='ingresos', 
                y='producto',
                orientation='h',
                title="Top Products by Revenue",
                color='crecimiento',
                color_continuous_scale=['red', 'yellow', 'green']
            )
            fig_productos.update_layout(
                plot_bgcolor='rgba(0,0,0,0)',
                paper_bgcolor='rgba(0,0,0,0)'
            )
            st.plotly_chart(fig_productos, use_container_width=True)
    
    # Alerts and customers at risk
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("### ⚠️ Customers at Risk of Churn")
        if not churn_data.empty:
            for _, cliente in churn_data.iterrows():
                risk_color = {
                    'HIGH': 'alert-danger',
                    'MEDIUM': 'alert-warning',
                    'LOW': 'alert-success'
                }.get(cliente['riesgo'], 'alert-warning')
                
                st.markdown(f"""
                <div class="alert-box {risk_color}">
                    <strong>{cliente['cliente']}</strong><br>
                    Churn Probability: {cliente['probabilidad_churn']:.1%}<br>
                    Customer Value: ${cliente['valor_cliente']:,}
                </div>
                """, unsafe_allow_html=True)
    
    with col2:
        st.markdown("### 📞 Support Analysis")
        
        # Métricas de soporte
        col_a, col_b = st.columns(2)
        with col_a:
            st.metric("Open Tickets", "47", "↓ -8%")
        with col_b:
            st.metric("Avg Response Time", "4.2h", "↓ -15%")
        
        # Distribución de sentimientos
        sentiment_data = pd.DataFrame({
            'sentimiento': ['Positive', 'Neutral', 'Negative'],
            'cantidad': [65, 25, 10]
        })
        
        fig_sentiment = px.pie(
            sentiment_data, 
            values='cantidad', 
            names='sentimiento',
            title="Sentiment Distribution",
            color_discrete_sequence=[LIVERPOOL_COLORS['accent'], 
                                   LIVERPOOL_COLORS['neutral'], 
                                   LIVERPOOL_COLORS['danger']]
        )
        st.plotly_chart(fig_sentiment, use_container_width=True)

# =====================================================
# SECCIÓN 2: CORTEX ANALYST
# =====================================================

elif demo_section == "🤖 Cortex Analyst":
    st.markdown('<h2 class="section-header">🤖 Cortex Analyst - Natural Language Analysis</h2>', unsafe_allow_html=True)
    
    st.markdown("""
    Cortex Analyst allows asking questions about business data in natural language. 
    The semantic model automatically translates questions to SQL y provides accurate answers.
    """)
    
    # Ejemplos de preguntas predefinidas
    st.markdown("### 💡 Sample Questions")
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        if st.button("What were our total revenues in Q1 2024?"):
            st.session_state['analyst_query'] = "What were our total revenues in Q1 2024?"
    
    with col2:
        if st.button("Which product had the best performance this year?"):
            st.session_state['analyst_query'] = "Which product had the best performance this year?"
    
    with col3:
        if st.button("What is the gross margin by region?"):
            st.session_state['analyst_query'] = "What is the gross margin by region?"
    
    # Input personalizado
    st.markdown("### 🗣️ Ask Custom Question")
    
    user_question = st.text_input(
        "Write your question about TechFlow Solutions data:",
        value=st.session_state.get('analyst_query', ''),
        placeholder="Ejemplo: ¿Cuántos clientes nuevos hemos adquirido este trimestre?"
    )
    
    if st.button("🔍 Analyze") and user_question:
        with st.spinner("Cortex Analyst is processing your question..."):
            
            # Simular procesamiento de Cortex Analyst
            st.markdown("#### 🤖 Cortex Analyst Response:")
            
            # Respuestas simuladas basadas en la pregunta
            if "ingresos" in user_question.lower() and "q1" in user_question.lower():
                st.success("""
                **Analysis Completed** ✅
                
                **Total Revenue Q1 2024:** $241,000
                
                **Monthly breakdown:**
                - Enero: $78,000
                - Febrero: $82,000  
                - Marzo: $76,000
                - Abril: $85,000
                
                **Additional insights:**
                - Growth of 15.2% vs Q1 2023
                - Best month: Abril ($85,000)
                - Main contribution: Enterprise Segment (68%)
                """)
                
                # Gráfico de respuesta
                months_data = pd.DataFrame({
                    'mes': ['Enero', 'Febrero', 'Marzo', 'Abril'],
                    'ingresos': [78000, 82000, 76000, 85000]
                })
                
                fig = px.bar(
                    months_data, 
                    x='mes', 
                    y='ingresos',
                    title="Ingresos Mensuales Q1 2024",
                    color='ingresos',
                    color_continuous_scale=[LIVERPOOL_COLORS['secondary'], LIVERPOOL_COLORS['primary']]
                )
                st.plotly_chart(fig, use_container_width=True)
                
            elif "producto" in user_question.lower() and "mejor" in user_question.lower():
                st.success("""
                **Analysis Completed** ✅
                
                **Producto con Mejor Desempeño 2024:** CloudSync Enterprise
                
                **Métricas clave:**
                - Ingresos: $125,000 (26% del total)
                - Crecimiento: +18.5% vs 2023
                - Clientes: 45 implementaciones
                - Margen bruto: 43.2%
                
                **Top 3 productos por ingresos:**
                1. CloudSync Enterprise - $125,000
                2. DataFlow Analytics Pro - $98,000
                3. Consultoría Digital - $85,000
                """)
                
            elif "margen" in user_question.lower() and "región" in user_question.lower():
                st.success("""
                **Analysis Completed** ✅
                
                **Margen Bruto por Región:**
                
                📍 **Norte América:** 42.8%
                - Ingresos: $285,000
                - Margen: $122,000
                
                🌍 **Europa:** 39.5%
                - Ingresos: $145,000
                - Margen: $57,300
                
                🌏 **Asia-Pacífico:** 45.2%
                - Ingresos: $95,000
                - Margen: $42,900
                
                **Insight:** Asia-Pacífico tiene el mayor margen debido a menor competencia y pricing premium.
                """)
                
                region_data = pd.DataFrame({
                    'region': ['Norte América', 'Europa', 'Asia-Pacífico'],
                    'margen_porcentaje': [42.8, 39.5, 45.2],
                    'ingresos': [285000, 145000, 95000]
                })
                
                fig = px.scatter(
                    region_data, 
                    x='ingresos', 
                    y='margen_porcentaje',
                    size='ingresos',
                    title="Margen vs Ingresos por Región",
                    labels={'margen_porcentaje': 'Margen Bruto (%)', 'ingresos': 'Ingresos ($)'}
                )
                st.plotly_chart(fig, use_container_width=True)
            
            else:
                st.info(f"""
                **Procesando:** "{user_question}"
                
                🔄 Cortex Analyst está analizando tu pregunta...
                
                En una implementación real, aquí veríamos:
                1. **Query SQL generado** automáticamente
                2. **Resultados precisos** basados en datos reales
                3. **Visualizaciones** contextuales
                4. **Insights adicionales** descubiertos por IA
                
                💡 **Prueba con preguntas sobre:**
                - Métricas de ventas y crecimiento
                - Análisis de clientes y segmentos
                - Rendimiento de productos
                - Tendencias temporales
                """)
    
    # Mostrar capacidades del modelo semántico
    st.markdown("### 🧠 Capacidades del Modelo Semántico")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("""
        **📊 Medidas Disponibles:**
        - Ingresos Totales
        - Margen Bruto y %
        - Número de Transacciones
        - Clientes Nuevos y Activos
        - Ticket Promedio
        - Satisfacción del Cliente
        - ROI de Marketing
        - Tiempo de Resolución
        """)
    
    with col2:
        st.markdown("""
        **🎯 Dimensiones Disponibles:**
        - Tiempo (Año, Trimestre, Mes)
        - Geografía (Región, País)
        - Productos (Categoría, Individual)
        - Clientes (Segmento, Industria)
        - Canales de Venta
        - Campañas de Marketing
        """)

# =====================================================
# SECCIÓN 3: CORTEX SEARCH
# =====================================================

elif demo_section == "🔍 Cortex Search":
    st.markdown('<h2 class="section-header">🔍 Cortex Search - Intelligent Document Search</h2>', unsafe_allow_html=True)
    
    st.markdown("""
    Cortex Search uses RAG (Retrieval-Augmented Generation) to search for specific information 
    in the enterprise document library de TechFlow Solutions.
    """)
    
    # Selector de biblioteca de documentos
    st.markdown("### 📚 Available Document Library")
    
    documents = [
        "📊 TechFlow Solutions - Informe Anual 2023",
        "🔧 Manual de Troubleshooting - CloudSync Enterprise v2.4", 
        "📈 Análisis de Feedback de Clientes - Q1 2024",
        "⚙️ Especificaciones Técnicas - AIChat Assistant Business v3.1",
        "🎯 Plan Estratégico 2024-2026 - Expansión Global"
    ]
    
    selected_docs = st.multiselect(
        "Select documents for search:",
        documents,
        default=documents[:3]
    )
    
    # Búsqueda de ejemplo
    st.markdown("### 🔍 Quick Sample Searches")
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        if st.button("🏦 Information Financiera"):
            st.session_state['search_query'] = "¿Cuáles fueron los ingresos y márgenes en 2023?"
    
    with col2:
        if st.button("🛠️ Troubleshooting"):
            st.session_state['search_query'] = "¿Cómo resolver errores de conectividad en CloudSync?"
    
    with col3:
        if st.button("😊 Customer Satisfaction"):
            st.session_state['search_query'] = "¿Cuál es el NPS actual y principales quejas?"
    
    # Campo de búsqueda principal
    search_query = st.text_input(
        "🔍 Search in documents:",
        value=st.session_state.get('search_query', ''),
        placeholder="Ejemplo: ¿Cuáles son los requisitos técnicos para AIChat Assistant?"
    )
    
    if st.button("🚀 Search") and search_query:
        with st.spinner("Cortex Search is analyzing the documents..."):
            
            st.markdown("#### 🎯 Search Results:")
            
            # Simular resultados de búsqueda basados en la query
            if "ingresos" in search_query.lower() or "financier" in search_query.lower():
                st.markdown("""
                **📊 Informe Anual 2023** - Relevance: 95%
                
                > **Ingresos totales: $52.3M** (crecimiento 18% vs 2022)  
                > **Margen bruto mejorado a 42%** (vs 38% en 2022)  
                > **EBITDA de $12.8M** con margen del 24.5%  
                > **Desglose por segmento:** Enterprise (65%), Mid-Market (25%), SMB (10%)
                
                📍 **Página 8-12** | 🔗 [View complete document]
                """)
                
                st.markdown("""
                **🎯 Plan Estratégico 2024-2026** - Relevance: 78%
                
                > **Meta: $150M en ingresos para 2026** (crecimiento 3x)  
                > **40% de ingresos de mercados internacionales**  
                > **ROI esperado: 35%** para iniciativas de expansión
                
                📍 **Página 36-38** | 🔗 [View complete document]
                """)
                
            elif "cloudync" in search_query.lower() or "error" in search_query.lower():
                st.markdown("""
                **🔧 Manual CloudSync Enterprise v2.4** - Relevance: 98%
                
                > **Error CS-401:** "Cannot establish ERP connection"  
                > **Causa:** Configuración incorrecta de puertos o certificados SSL  
                > **Solución:** Verificar puertos 443/8443, actualizar certificados  
                > **Tiempo estimado:** 15-30 minutos
                
                📍 **Página 8-15** | 🔗 [Ver procedimiento detallado]
                """)
                
                st.markdown("""
                **📈 Análisis de Feedback Q1 2024** - Relevance: 72%
                
                > **CloudSync Enterprise:** NPS 75  
                > **Principales quejas:** documentación insuficiente  
                > **Solicitudes:** mejor integración con sistemas ERP
                
                📍 **Página 5-8** | 🔗 [Ver análisis completo]
                """)
                
            elif "nps" in search_query.lower() or "satisfacción" in search_query.lower():
                st.markdown("""
                **📈 Análisis de Feedback Q1 2024** - Relevance: 96%
                
                > **Net Promoter Score (NPS): 72** (+8 puntos vs Q4 2023)  
                > **Satisfacción general: 4.3/5.0** (meta alcanzada)  
                > **1,247 respuestas** de clientes (tasa de respuesta 34%)
                
                📍 **Página 1-4** | 🔗 [Ver resumen ejecutivo]
                """)
                
                st.markdown("""
                **📈 Análisis de Feedback Q1 2024** - Relevance: 89%
                
                > **Temas Positives:** "Excelente soporte técnico", "Interfaz intuitiva"  
                > **Temas Negatives:** "Documentación insuficiente", "Proceso implementación largo"  
                > **Sugerencias:** "Más tutoriales en video", "API más robusta"
                
                📍 **Página 26-30** | 🔗 [Ver análisis detallado]
                """)
                
            elif "requisitos" in search_query.lower() or "técnico" in search_query.lower():
                st.markdown("""
                **⚙️ Especificaciones AIChat Assistant v3.1** - Relevance: 94%
                
                > **Mínimos:** 4 vCPUs, 16GB RAM, 100GB SSD  
                > **Recomendados:** 8 vCPUs, 32GB RAM, 500GB SSD  
                > **Red:** Latencia <100ms, ancho de banda 1Gbps  
                > **Compatibilidad:** AWS, Azure, GCP, on-premises
                
                📍 **Página 46-50** | 🔗 [Ver especificaciones completas]
                """)
                
            else:
                st.info(f"""
                **Buscando:** "{search_query}"
                
                🔄 Cortex Search está procesando tu consulta en {len(selected_docs)} documentos...
                
                En una implementación real, verías:
                1. **Fragmentos relevantes** extraídos de documentos
                2. **Scores de relevancia** calculados por IA
                3. **Referencias exactas** con páginas y secciones
                4. **Resúmenes contextuales** generados automáticamente
                5. **Sugerencias relacionadas** para explorar más
                """)
    
    # Estadísticas de la biblioteca
    st.markdown("### 📊 Library Statistics")
    
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.metric("Documents", "5", "")
    with col2:
        st.metric("Total Pages", "249", "")
    with col3:
        st.metric("Searches Today", "47", "↑ 23%")
    with col4:
        st.metric("Average Precision", "94.2%", "↑ 2.1%")
    
    # Documents más consultados
    st.markdown("### 📈 Documents Más Consultados")
    
    doc_stats = pd.DataFrame({
        'documento': [
            'Manual CloudSync Enterprise',
            'Análisis Feedback Q1 2024', 
            'Especificaciones AIChat',
            'Informe Anual 2023',
            'Plan Estratégico 2024-2026'
        ],
        'consultas': [156, 89, 67, 45, 23],
        'satisfaccion': [4.6, 4.3, 4.7, 4.1, 4.0]
    })
    
    fig_docs = px.bar(
        doc_stats, 
        x='consultas', 
        y='documento',
        orientation='h',
        title="Number of Queries per Document",
        color='satisfaccion',
        color_continuous_scale=['red', 'yellow', 'green']
    )
    fig_docs.update_layout(height=400)
    st.plotly_chart(fig_docs, use_container_width=True)

# =====================================================
# SECCIÓN 4: AISQL MULTIMODAL
# =====================================================

elif demo_section == "🎯 AISQL Multimodal":
    st.markdown('<h2 class="section-header">🎯 AISQL Multimodal - Intelligent Data Analysis</h2>', unsafe_allow_html=True)
    
    st.markdown("""
    Las funciones AISQL multimodales permiten analizar texto, imágenes y otros datos no estructurados 
    directamente en SQL, extrayendo insights valiosos automáticamente.
    """)
    
    # Pestañas para diferentes tipos de análisis
    tab1, tab2, tab3, tab4 = st.tabs([
        "📝 Análisis de Texto", 
        "🖼️ Análisis de Imágenes", 
        "📊 Insights Automáticos",
        "🔧 Casos de Uso"
    ])
    
    with tab1:
        st.markdown("### 📝 Análisis Inteligente de Tickets de Soporte")
        
        # Simuler algunos tickets para analizar
        sample_tickets = [
            {
                'id': 'TICK-2024-001',
                'cliente': 'Global Manufacturing Corp',
                'descripcion': 'CloudSync no puede conectarse con nuestro sistema ERP SAP. Error código CS-401 aparece constantemente durante la sincronización de datos de inventario.',
                'sentimiento_manual': 'NEGATIVO'
            },
            {
                'id': 'TICK-2024-004', 
                'cliente': 'RetailChain Express',
                'descripcion': 'Excelente producto! Queremos expandir el uso de AIChat a otros departamentos. ¿Pueden proporcionar descuentos por volumen y capacitación adicional?',
                'sentimiento_manual': 'POSITIVO'
            },
            {
                'id': 'TICK-2024-008',
                'cliente': 'Government Agency Alpha', 
                'descripcion': 'Necesitamos certificación SOC 2 Type II para DataFlow Analytics Pro para cumplir con requisitos gubernamentales. ¿Cuál es el timeline estimado?',
                'sentimiento_manual': 'NEUTRO'
            }
        ]
        
        selected_ticket = st.selectbox(
            "Selecciona un ticket para analizar:",
            [f"{t['id']} - {t['cliente']}" for t in sample_tickets]
        )
        
        ticket_idx = next(i for i, t in enumerate(sample_tickets) if t['id'] in selected_ticket)
        ticket = sample_tickets[ticket_idx]
        
        st.markdown("#### 📋 Descripción del Problema:")
        st.write(f"**Cliente:** {ticket['cliente']}")
        st.write(f"**Descripción:** {ticket['descripcion']}")
        
        if st.button("🔍 Analyze con AISQL"):
            with st.spinner("Procesando con funciones AISQL..."):
                
                col1, col2 = st.columns(2)
                
                with col1:
                    st.markdown("#### 🎯 Clasificación Automática")
                    
                    if 'error' in ticket['descripcion'].lower():
                        categoria = 'Technical Error'
                        urgencia = 'ALTA'
                        color = LIVERPOOL_COLORS['danger']
                    elif 'excelente' in ticket['descripcion'].lower():
                        categoria = 'Feature Request'
                        urgencia = 'BAJA' 
                        color = LIVERPOOL_COLORS['accent']
                    else:
                        categoria = 'Compliance Request'
                        urgencia = 'MEDIA'
                        color = LIVERPOOL_COLORS['warning']
                    
                    st.markdown(f"""
                    <div style="background: {color}15; padding: 1rem; border-radius: 8px; border-left: 4px solid {color};">
                        <strong>Categoría:</strong> {categoria}<br>
                        <strong>Urgencia:</strong> {urgencia}<br>
                        <strong>Confianza:</strong> 94.2%
                    </div>
                    """, unsafe_allow_html=True)
                
                with col2:
                    st.markdown("#### 😊 Análisis de Sentimiento")
                    
                    if ticket['sentimiento_manual'] == 'NEGATIVO':
                        sentiment_score = -0.7
                        sentiment_text = "Frustración moderada"
                        sentiment_color = LIVERPOOL_COLORS['danger']
                    elif ticket['sentimiento_manual'] == 'POSITIVO':
                        sentiment_score = 0.8
                        sentiment_text = "Muy satisfecho"
                        sentiment_color = LIVERPOOL_COLORS['accent']
                    else:
                        sentiment_score = 0.1
                        sentiment_text = "Neutral/Profesional"
                        sentiment_color = LIVERPOOL_COLORS['neutral']
                    
                    st.markdown(f"""
                    <div style="background: {sentiment_color}15; padding: 1rem; border-radius: 8px; border-left: 4px solid {sentiment_color};">
                        <strong>Sentimiento:</strong> {sentiment_text}<br>
                        <strong>Score:</strong> {sentiment_score:.1f}<br>
                        <strong>Tono:</strong> {'Urgente' if sentiment_score < -0.5 else 'Colaborativo' if sentiment_score > 0.5 else 'Profesional'}
                    </div>
                    """, unsafe_allow_html=True)
                
                st.markdown("#### 💡 Insights Extraídos")
                
                if 'CS-401' in ticket['descripcion']:
                    insights = [
                        "🔧 Código de error específico identificado: CS-401",
                        "🏭 Sistema afectado: ERP SAP",
                        "⚡ Proceso afectado: Sincronización de inventario",
                        "📚 Solución disponible en manual técnico"
                    ]
                elif 'excelente' in ticket['descripcion'].lower():
                    insights = [
                        "🎯 Oportunidad de upselling identificada",
                        "👥 Interés en expansión a otros departamentos", 
                        "💰 Solicitud de descuentos por volumen",
                        "📚 Necesidad de capacitación adicional"
                    ]
                else:
                    insights = [
                        "🛡️ Requisito de compliance: SOC 2 Type II",
                        "🏛️ Cliente gubernamental con regulaciones estrictas",
                        "⏰ Necesidad de timeline específico",
                        "📋 Posible bloqueador para implementación"
                    ]
                
                for insight in insights:
                    st.write(insight)
                
                st.markdown("#### 🎯 Respuesta Sugerida")
                
                if 'error' in ticket['descripcion'].lower():
                    response = """
                    Estimado equipo de Global Manufacturing Corp,
                    
                    Hemos identificado que el error CS-401 está relacionado con la configuración de certificados SSL en la conexión ERP. 
                    
                    **Pasos inmediatos:**
                    1. Verificar configuración de puertos 443/8443
                    2. Renovar certificados SSL si han expirado
                    3. Validar credenciales de conexión
                    
                    **Tiempo estimado de resolución:** 15-30 minutos
                    
                    Nuestro equipo técnico está disponible para una sesión de soporte en vivo. ¿Cuándo sería conveniente para ustedes?
                    """
                else:
                    response = """
                    Estimado equipo,
                    
                    Nos complace saber de su interés en expandir el uso de nuestras soluciones.
                    
                    **Próximos pasos:**
                    1. Evaluación de descuentos por volumen
                    2. Plan de capacitación personalizado
                    3. Cronograma de implementación por departamentos
                    
                    Nuestro Customer Success Manager se pondrá en contacto dentro de 24 horas para discutir los detalles.
                    """
                
                st.text_area("Respuesta generada automáticamente:", response, height=200)
    
    with tab2:
        st.markdown("### 🖼️ Análisis de Imágenes de Productos")
        
        # Simulación de análisis de imágenes de productos con URLs más confiables
        product_images = [
            {
                'nombre': 'CloudSync Enterprise',
                'url': 'https://picsum.photos/400/300?random=1',
                'fallback_url': 'https://via.placeholder.com/400x300/1E3A8A/FFFFFF?text=CloudSync+Dashboard',
                'descripcion_ai': 'Interfaz web moderna con dashboard principal mostrando métricas de sincronización en tiempo real, gráficos de barras azules y navegación lateral intuitiva.'
            },
            {
                'nombre': 'DataFlow Analytics Pro', 
                'url': 'https://picsum.photos/400/300?random=2',
                'fallback_url': 'https://via.placeholder.com/400x300/3B82F6/FFFFFF?text=DataFlow+Analytics',
                'descripcion_ai': 'Plataforma de visualización de datos con múltiples gráficos interactivos, tablas dinámicas y controles de filtrado avanzados.'
            },
            {
                'nombre': 'AIChat Assistant',
                'url': 'https://picsum.photos/400/300?random=3',
                'fallback_url': 'https://via.placeholder.com/400x300/10B981/FFFFFF?text=AIChat+Interface', 
                'descripcion_ai': 'Interfaz de chat conversacional con burbujas de mensajes, sugerencias de respuesta y panel de configuración de IA.'
            }
        ]
        
        # Selector de producto
        selected_product = st.selectbox(
            "Selecciona un producto para análisis visual:",
            [p['nombre'] for p in product_images]
        )
        
        # Selector de fuente de imagen
        image_source = st.radio(
            "Fuente de imagen:",
            ["🎲 Imagen aleatoria (Picsum)", "🖼️ Placeholder personalizado", "📱 Mockup de demo", "🎨 Gráfico generado"],
            horizontal=True,
            help="Selecciona el tipo de imagen para mostrar en la simulación"
        )
        
        product = next(p for p in product_images if p['nombre'] == selected_product)
        
        # Determinar URL según la fuente seleccionada
        display_url = None
        use_generated_chart = False
        
        if image_source == "🎲 Imagen aleatoria (Picsum)":
            display_url = product['url']
        elif image_source == "🖼️ Placeholder personalizado":
            display_url = product['fallback_url']
        elif image_source == "📱 Mockup de demo":
            # URLs de mockups más realistas para demo
            mockup_urls = {
                'CloudSync Enterprise': 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&h=300&fit=crop&crop=center',
                'DataFlow Analytics Pro': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&h=300&fit=crop&crop=center',
                'AIChat Assistant': 'https://images.unsplash.com/photo-1587620962725-abab7fe55159?w=400&h=300&fit=crop&crop=center'
            }
            display_url = mockup_urls.get(product['nombre'], product['fallback_url'])
        else:  # Gráfico generado
            use_generated_chart = True
        
        col1, col2 = st.columns([1, 1])
        
        with col1:
            st.markdown(f"#### 📷 Imagen del Producto: {product['nombre']}")
            
            # Mostrar información de la fuente seleccionada
            st.info(f"🔗 Fuente: {image_source}")
            
            if use_generated_chart:
                # Generar un gráfico simulado usando Plotly
                st.markdown("##### 📊 Gráfico Generado - Simulación de Dashboard")
                
                import numpy as np
                
                # Datos simulados específicos para cada producto
                if product['nombre'] == 'CloudSync Enterprise':
                    # Dashboard de sincronización
                    sync_data = pd.DataFrame({
                        'hora': pd.date_range('2024-01-01 00:00', periods=24, freq='h'),
                        'archivos_sincronizados': np.random.poisson(150, 24) + 100,
                        'latencia_ms': np.random.normal(45, 10, 24),
                        'usuarios_activos': np.random.poisson(25, 24) + 10
                    })
                    
                    fig = make_subplots(
                        rows=2, cols=2,
                        subplot_titles=('Archivos Sincronizados', 'Latencia (ms)', 'Usernames Activos', 'Estado del Sistema'),
                        specs=[[{"type": "scatter"}, {"type": "scatter"}],
                               [{"type": "scatter"}, {"type": "indicator"}]]
                    )
                    
                    fig.add_trace(go.Scatter(x=sync_data['hora'], y=sync_data['archivos_sincronizados'], 
                                           mode='lines+markers', name='Archivos', line=dict(color='#1E3A8A')), row=1, col=1)
                    fig.add_trace(go.Scatter(x=sync_data['hora'], y=sync_data['latencia_ms'], 
                                           mode='lines+markers', name='Latencia', line=dict(color='#3B82F6')), row=1, col=2)
                    fig.add_trace(go.Scatter(x=sync_data['hora'], y=sync_data['usuarios_activos'], 
                                           mode='lines+markers', name='Usernames', line=dict(color='#10B981')), row=2, col=1)
                    fig.add_trace(go.Indicator(mode="gauge+number", value=98.5, title={'text': "Uptime %"},
                                             gauge={'bar': {'color': '#10B981'}, 'axis': {'range': [0, 100]}}), row=2, col=2)
                    
                elif product['nombre'] == 'DataFlow Analytics Pro':
                    # Dashboard de analytics
                    analytics_data = pd.DataFrame({
                        'categoria': ['Ventas', 'Marketing', 'Soporte', 'Producto', 'Finanzas'],
                        'valor': [1250000, 850000, 650000, 920000, 1100000],
                        'crecimiento': [15.2, 22.8, -3.1, 18.7, 8.4]
                    })
                    
                    fig = make_subplots(
                        rows=1, cols=2,
                        subplot_titles=('Ingresos por Categoría', 'Crecimiento %'),
                        specs=[[{"type": "bar"}, {"type": "bar"}]]
                    )
                    
                    fig.add_trace(go.Bar(x=analytics_data['categoria'], y=analytics_data['valor'], 
                                        name='Ingresos', marker=dict(color='#3B82F6')), row=1, col=1)
                    fig.add_trace(go.Bar(x=analytics_data['categoria'], y=analytics_data['crecimiento'], 
                                        name='Crecimiento', marker=dict(color='#10B981')), row=1, col=2)
                    
                else:  # AIChat Assistant
                    # Dashboard de chat
                    chat_data = pd.DataFrame({
                        'dia': pd.date_range('2024-01-01', periods=7, freq='D'),
                        'mensajes': [1250, 1580, 1420, 1890, 1650, 2100, 1980],
                        'satisfaccion': [4.2, 4.5, 4.3, 4.7, 4.4, 4.6, 4.5],
                        'tiempo_respuesta': [2.1, 1.8, 2.3, 1.5, 1.9, 1.6, 1.7]
                    })
                    
                    fig = make_subplots(
                        rows=2, cols=1,
                        subplot_titles=('Mensajes Diarios', 'Tiempo de Respuesta (seg)'),
                        specs=[[{"type": "scatter"}], [{"type": "scatter"}]]
                    )
                    
                    fig.add_trace(go.Scatter(x=chat_data['dia'], y=chat_data['mensajes'], 
                                           mode='lines+markers', name='Mensajes', line=dict(color='#10B981')), row=1, col=1)
                    fig.add_trace(go.Scatter(x=chat_data['dia'], y=chat_data['tiempo_respuesta'], 
                                           mode='lines+markers', name='Tiempo Resp.', line=dict(color='#F59E0B')), row=2, col=1)
                
                fig.update_layout(height=400, showlegend=False, title_text=f"Dashboard: {product['nombre']}")
                st.plotly_chart(fig, use_container_width=True)
                
            else:
                # Intentar mostrar la imagen con manejo de errores mejorado
                try:
                    st.image(display_url, 
                            caption=f"Vista previa de {product['nombre']}", 
                            width=400,
                            use_column_width=False)
                    
                    # Mostrar URL para debugging si es necesario
                    with st.expander("🔗 Information técnica de la imagen"):
                        st.code(f"URL: {display_url}")
                        st.write(f"**Tipo de fuente:** {image_source}")
                        
                except Exception as e:
                    # Si la imagen no carga, mostrar error detallado
                    st.error("🖼️ No se pudo cargar la imagen del producto")
                    st.warning(f"URL que falló: {display_url}")
                    st.info("💡 **Sugerencia:** Prueba la opción '🎨 Gráfico generado' que siempre funciona")
                    
                    # Crear un placeholder visual con información del producto
                    st.markdown(f"""
                    <div style="background: linear-gradient(135deg, #1E3A8A 0%, #3B82F6 100%); 
                                color: white; 
                                padding: 2rem; 
                                border-radius: 8px; 
                                text-align: center;
                                width: 400px;
                                height: 250px;
                                display: flex;
                                align-items: center;
                                justify-content: center;
                                flex-direction: column;
                                font-size: 1.2rem;
                                font-weight: bold;
                                margin: 1rem 0;">
                        📱 {product['nombre']}<br>
                        <small style="font-size: 0.9rem; opacity: 0.8; margin-top: 1rem;">
                            Imagen de demostración<br>
                            (Error al cargar imagen externa)
                        </small>
                        <div style="font-size: 0.7rem; margin-top: 1rem; opacity: 0.6;">
                            Prueba "🎨 Gráfico generado"
                        </div>
                    </div>
                    """, unsafe_allow_html=True)
        
        with col2:
            st.markdown("#### 🔍 Análisis de IA")
            
            # Botón mejorado con más contexto
            if st.button("🔍 Analyze Imagen con AISQL", 
                        help="Simula el análisis de la imagen usando funciones AISQL multimodales"):
                with st.spinner("Analizando imagen con IA..."):
                    
                    st.markdown("#### 🎨 Análisis Visual Automático")
                    
                    st.success(f"""
                    **Descripción generada por IA:**
                    
                    {product.get('descripcion_ai', 'Análisis visual completado')}
                    
                    **Elementos UI detectados:**
                    - Navegación: Sidebar moderna
                    - Colores: Azul corporativo dominante
                    - Tipografía: Sans-serif, legible
                    - Layout: Grid responsivo
                    - Componentes: Cards, gráficos, botones
                    
                    **Evaluación UX:**
                    - Usabilidad: ⭐⭐⭐⭐⭐ (Excelente)
                    - Accesibilidad: ⭐⭐⭐⭐⭐ (Muy buena)
                    - Modernidad: ⭐⭐⭐⭐⭐ (Contemporáneo)
                    """)
                    
                    st.markdown("#### 📊 Insights de Marketing")
                    
                    marketing_insights = [
                        "💼 Interfaz profesional atractiva para segmento Enterprise",
                        "📱 Diseño responsive sugiere compatibilidad móvil",
                        "🎯 Colores corporativos transmiten confianza y estabilidad", 
                        "📈 Visualizaciones prominentes destacan capacidades analíticas",
                        "⚡ Dashboard limpio sugiere facilidad de uso"
                    ]
                    
                    for insight in marketing_insights:
                        st.write(insight)
    
    with tab3:
        st.markdown("### 📊 Insights Automáticos Generados por IA")
        
        # Simuler insights automáticos generados
        if st.button("🧠 Generar Insights del Mes"):
            with st.spinner("Generando insights con AISQL..."):
                
                st.markdown("#### 🎯 Top Insights de Abril 2024")
                
                insights_data = [
                    {
                        'categoria': 'Customer Satisfaction',
                        'insight': 'Los tickets relacionados con "documentación" han disminuido 23% tras las mejoras en tutoriales.',
                        'impacto': 'HIGH',
                        'accion': 'Continuar invirtiendo en contenido educativo'
                    },
                    {
                        'categoria': 'Oportunidades de Venta',
                        'insight': '3 clientes Enterprise mencionaron interés en funciones de IA en sus tickets de soporte.',
                        'impacto': 'MEDIUM',
                        'accion': 'Contacto proactivo del equipo de ventas'
                    },
                    {
                        'categoria': 'Riesgo Operacional',
                        'insight': 'Aumento 15% en errores CS-401 sugiere problema sistémico en infraestructura.',
                        'impacto': 'CRITICO',
                        'accion': 'Revisión urgente de configuraciones SSL'
                    },
                    {
                        'categoria': 'Tendencia de Producto',
                        'insight': 'AIChat Assistant tiene mayor crecimiento en solicitudes de integración (+45%).',
                        'impacto': 'HIGH',
                        'accion': 'Priorizar desarrollo de conectores API'
                    }
                ]
                
                for i, insight in enumerate(insights_data):
                    impact_color = {
                        'CRITICO': LIVERPOOL_COLORS['danger'],
                        'HIGH': LIVERPOOL_COLORS['warning'], 
                        'MEDIUM': LIVERPOOL_COLORS['accent']
                    }[insight['impacto']]
                    
                    st.markdown(f"""
                    <div style="background: white; padding: 1rem; border-radius: 8px; margin-bottom: 1rem; border-left: 4px solid {impact_color}; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                        <h4 style="color: {LIVERPOOL_COLORS['primary']}; margin: 0;">
                            {insight['categoria']} 
                            <span style="background: {impact_color}; color: white; padding: 0.2rem 0.5rem; border-radius: 4px; font-size: 0.8rem; margin-left: 1rem;">
                                {insight['impacto']}
                            </span>
                        </h4>
                        <p style="margin: 0.5rem 0; color: {LIVERPOOL_COLORS['neutral']};">{insight['insight']}</p>
                        <p style="margin: 0; font-weight: 500; color: {LIVERPOOL_COLORS['primary']};">
                            💡 <strong>Acción recomendada:</strong> {insight['accion']}
                        </p>
                    </div>
                    """, unsafe_allow_html=True)
    
    with tab4:
        st.markdown("### 🔧 Casos de Uso Avanzados AISQL")
        
        use_cases = [
            {
                'titulo': '🎯 Clasificación Automática de Tickets',
                'descripcion': 'Clasificar automáticamente tickets de soporte en categorías técnicas usando CLASSIFY()',
                'ejemplo': "SNOWFLAKE.CORTEX.CLASSIFY(descripcion_problema, ['Technical Error', 'Feature Request', 'User Training'])",
                'beneficio': 'Reduce tiempo de triaje en 60% y mejora routing automático'
            },
            {
                'titulo': '💡 Extracción de Information Específica',
                'descripcion': 'Extraer códigos de error, nombres de productos y urgencia de tickets usando EXTRACT_ANSWER()',
                'ejemplo': "SNOWFLAKE.CORTEX.EXTRACT_ANSWER(descripcion, 'What error codes are mentioned?')",
                'beneficio': 'Identifica automáticamente problemas recurrentes y acelera resolución'
            },
            {
                'titulo': '📝 Resumen Automático de Feedback',
                'descripcion': 'Generar resúmenes ejecutivos de feedback extenso usando SUMMARIZE()',
                'ejemplo': "SNOWFLAKE.CORTEX.SUMMARIZE(feedback_text)",
                'beneficio': 'Convierte texto largo en insights accionables para management'
            },
            {
                'titulo': '😊 Análisis de Sentimiento Granular',
                'descripcion': 'Análisis detallado de emociones y tono en comunicaciones de clientes',
                'ejemplo': "SNOWFLAKE.CORTEX.SENTIMENT(mensaje_cliente)",
                'beneficio': 'Detecta clientes en riesgo y oportunidades de upselling'
            },
            {
                'titulo': '🖼️ Descripción de Capturas de Producto',
                'descripcion': 'Generar descripciones de marketing automáticas de capturas de producto',
                'ejemplo': "SNOWFLAKE.CORTEX.DESCRIBE_IMAGE(product_screenshot_url)",
                'beneficio': 'Acelera creación de contenido y mantiene consistencia de marca'
            },
            {
                'titulo': '🔍 Búsqueda Semántica en Documentación',
                'descripcion': 'Encontrar soluciones relevantes en base de conocimiento técnica',
                'ejemplo': "CORTEX.SEARCH(query='error de conexión', documents=tech_docs)",
                'beneficio': 'Mejora eficiencia de soporte y satisfacción del cliente'
            }
        ]
        
        for case in use_cases:
            with st.expander(f"{case['titulo']}"):
                st.markdown(f"**Descripción:** {case['descripcion']}")
                st.code(case['ejemplo'], language='sql')
                st.success(f"💼 **Beneficio:** {case['beneficio']}")

# =====================================================
# SECCIÓN 5: ML PREDICTIVO
# =====================================================

elif demo_section == "📈 ML Predictive":
    st.markdown('<h2 class="section-header">📈 Machine Learning Predictive</h2>', unsafe_allow_html=True)
    
    st.markdown("""
    Utiliza las capacidades de ML integradas de Snowflake para pronósticos, detección de anomalías 
    y análisis predictivo avanzado directamente en SQL.
    """)
    
    # Pestañas para diferentes tipos de ML
    tab1, tab2, tab3, tab4 = st.tabs([
        "📊 Forecasting", 
        "⚠️ Detección de Anomalías", 
        "🎯 Análisis de Churn",
        "📈 Tendencias"
    ])
    
    with tab1:
        st.markdown("### 📊 Pronósticos de Ventas")
        
        # Datos simulados de pronósticos
        forecast_data = pd.DataFrame({
            'mes': pd.date_range('2024-01-01', '2024-12-01', freq='M'),
            'historico': [78000, 82000, 76000, 85000, None, None, None, None, None, None, None, None],
            'pronostico': [None, None, None, None, 88000, 92000, 87000, 95000, 89000, 96000, 91000, 98000],
            'confianza_min': [None, None, None, None, 82000, 86000, 81000, 88000, 83000, 89000, 84000, 91000],
            'confianza_max': [None, None, None, None, 94000, 98000, 93000, 102000, 95000, 103000, 98000, 105000]
        })
        
        # Gráfico de pronóstico
        fig_forecast = go.Figure()
        
        # Datos históricos
        fig_forecast.add_trace(go.Scatter(
            x=forecast_data['mes'],
            y=forecast_data['historico'],
            mode='lines+markers',
            name='Histórico',
            line=dict(color=LIVERPOOL_COLORS['primary'], width=3)
        ))
        
        # Pronóstico
        fig_forecast.add_trace(go.Scatter(
            x=forecast_data['mes'],
            y=forecast_data['pronostico'],
            mode='lines+markers',
            name='Pronóstico',
            line=dict(color=LIVERPOOL_COLORS['secondary'], width=3, dash='dash')
        ))
        
        # Banda de confianza
        fig_forecast.add_trace(go.Scatter(
            x=forecast_data['mes'],
            y=forecast_data['confianza_max'],
            mode='lines',
            line=dict(width=0),
            showlegend=False,
            hoverinfo='skip'
        ))
        
        fig_forecast.add_trace(go.Scatter(
            x=forecast_data['mes'],
            y=forecast_data['confianza_min'],
            mode='lines',
            line=dict(width=0),
            fill='tonexty',
            fillcolor=f'rgba(59, 130, 246, 0.2)',
            name='Intervalo de Confianza 95%',
            hoverinfo='skip'
        ))
        
        fig_forecast.update_layout(
            title="Pronóstico de Ingresos Mensuales 2024",
            xaxis_title="Mes",
            yaxis_title="Ingresos ($)",
            hovermode='x unified',
            plot_bgcolor='rgba(0,0,0,0)',
            paper_bgcolor='rgba(0,0,0,0)'
        )
        
        st.plotly_chart(fig_forecast, use_container_width=True)
        
        # Métricas del pronóstico
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.metric("Próximo Mes", "$88,000", "↗️ +3.5%")
        with col2:
            st.metric("Q3 2024 Total", "$271,000", "↗️ +8.2%")
        with col3:
            st.metric("Crecimiento Anual", "+12.8%", "vs 2023")
        with col4:
            st.metric("Precisión Modelo", "94.2%", "↗️ +1.8%")
        
        # Pronóstico por segmento
        st.markdown("#### 🎯 Pronóstico por Segmento de Cliente")
        
        segment_forecast = pd.DataFrame({
            'segmento': ['Enterprise', 'Mid-Market', 'SMB', 'Government'],
            'actual_abril': [56000, 18500, 7200, 3300],
            'pronostico_mayo': [58800, 19200, 7100, 3000],
            'crecimiento': [5.0, 3.8, -1.4, -9.1]
        })
        
        fig_segment = px.bar(
            segment_forecast,
            x='segmento',
            y=['actual_abril', 'pronostico_mayo'],
            barmode='group',
            title="Actual vs Pronóstico por Segmento",
            color_discrete_sequence=[LIVERPOOL_COLORS['primary'], LIVERPOOL_COLORS['secondary']]
        )
        
        st.plotly_chart(fig_segment, use_container_width=True)
    
    with tab2:
        st.markdown("### ⚠️ Detección de Anomalías")
        
        # Simuler detección de anomalías
        st.markdown("#### 🔍 Transacciones Anómalas Detectadas")
        
        anomalies_data = pd.DataFrame({
            'transaccion_id': ['TXN-2024-089', 'TXN-2024-102', 'TXN-2024-156'],
            'fecha': ['2024-04-28', '2024-04-29', '2024-04-30'],
            'cliente': ['StartupTech Dynamics', 'EduTech University', 'AutoMotive Innovations'],
            'valor': [15000, 8500, 22000],
            'anomaly_score': [0.87, 0.72, 0.94],
            'razon': ['Valor 5x superior al promedio del cliente', 
                     'Compra fuera de patrón temporal habitual',
                     'Combinación inusual de productos']
        })
        
        for _, anomaly in anomalies_data.iterrows():
            severity = "🔴 CRÍTICA" if anomaly['anomaly_score'] > 0.8 else "🟡 MODERADA"
            
            st.markdown(f"""
            <div class="alert-box alert-warning">
                <strong>{anomaly['transaccion_id']}</strong> - {severity}<br>
                <strong>Cliente:</strong> {anomaly['cliente']}<br>
                <strong>Valor:</strong> ${anomaly['valor']:,} | <strong>Score:</strong> {anomaly['anomaly_score']:.2f}<br>
                <strong>Razón:</strong> {anomaly['razon']}
            </div>
            """, unsafe_allow_html=True)
        
        # Gráfico de distribución de scores
        st.markdown("#### 📊 Distribución de Scores de Anomalía")
        
        # Simular distribución de scores
        normal_scores = [0.1, 0.15, 0.08, 0.22, 0.18, 0.12, 0.25, 0.3, 0.2, 0.35] * 20
        anomaly_scores = [0.72, 0.87, 0.94, 0.68, 0.81]
        all_scores = normal_scores + anomaly_scores
        
        fig_anomaly = px.histogram(
            x=all_scores,
            nbins=20,
            title="Distribución de Scores de Anomalía - Últimos 30 días",
            labels={'x': 'Score de Anomalía', 'y': 'Número de Transacciones'}
        )
        
        # Línea de umbral
        fig_anomaly.add_vline(x=0.6, line_dash="dash", line_color="red", 
                             annotation_text="Umbral de Alerta")
        
        st.plotly_chart(fig_anomaly, use_container_width=True)
        
        # Métricas de anomalías
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.metric("Anomalías Hoy", "3", "↑ +2")
        with col2:
            st.metric("Falsos Positives", "5.2%", "↓ -1.1%")
        with col3:
            st.metric("Ahorro Estimado", "$45K", "en fraudes prevenidos")
        with col4:
            st.metric("Tiempo Detección", "12 min", "promedio")
    
    with tab3:
        st.markdown("### 🎯 Análisis Predictivo de Churn")
        
        # Tabla de clientes en riesgo
        churn_data = pd.DataFrame({
            'cliente': ['Global Manufacturing Corp', 'RetailChain Express', 'FinTech Innovations Ltd', 
                       'StartupTech Dynamics', 'EduTech University'],
            'probabilidad_churn': [0.78, 0.65, 0.42, 0.71, 0.38],
            'valor_cliente': [125000, 45000, 75000, 25000, 35000],
            'dias_inactivo': [89, 45, 12, 156, 23],
            'tickets_recientes': [8, 3, 1, 12, 2],
            'satisfaccion': [2.8, 3.2, 4.1, 2.1, 4.3],
            'segmento': ['Enterprise', 'SMB', 'Mid-Market', 'SMB', 'Education']
        })
        
        st.markdown("#### 🚨 Customers at Risk of Churn")
        
        # Filtrar solo alto riesgo para mostrar
        high_risk = churn_data[churn_data['probabilidad_churn'] > 0.6].copy()
        
        for _, cliente in high_risk.iterrows():
            risk_level = "🔴 CRÍTICO" if cliente['probabilidad_churn'] > 0.7 else "🟡 HIGH"
            
            col1, col2 = st.columns([2, 1])
            
            with col1:
                st.markdown(f"""
                <div class="alert-box alert-danger">
                    <strong>{cliente['cliente']}</strong> - {risk_level}<br>
                    <strong>Probabilidad Churn:</strong> {cliente['probabilidad_churn']:.1%}<br>
                    <strong>Valor en Riesgo:</strong> ${cliente['valor_cliente']:,}<br>
                    <strong>Días Inactivo:</strong> {cliente['dias_inactivo']} | <strong>Satisfacción:</strong> {cliente['satisfaccion']}/5
                </div>
                """, unsafe_allow_html=True)
            
            with col2:
                if cliente['probabilidad_churn'] > 0.7:
                    action = "🔥 Contacto Urgente CSM"
                    color = LIVERPOOL_COLORS['danger']
                else:
                    action = "📞 Programa Retención"
                    color = LIVERPOOL_COLORS['warning']
                
                if st.button(f"🎯 {action}", key=f"action_{cliente['cliente']}"):
                    st.success(f"✅ Acción programada para {cliente['cliente']}")
        
        # Gráfico de segmentación por riesgo
        st.markdown("#### 📊 Segmentación de Riesgo por Valor de Cliente")
        
        fig_churn = px.scatter(
            churn_data,
            x='valor_cliente',
            y='probabilidad_churn',
            size='dias_inactivo',
            color='segmento',
            title="Matriz de Riesgo vs Valor del Cliente",
            labels={
                'valor_cliente': 'Valor del Cliente ($)',
                'probabilidad_churn': 'Probabilidad de Churn (%)',
                'dias_inactivo': 'Días Inactivo'
            }
        )
        
        # Líneas de referencia
        fig_churn.add_hline(y=0.6, line_dash="dash", line_color="orange", 
                           annotation_text="Umbral Alto Riesgo")
        fig_churn.add_hline(y=0.8, line_dash="dash", line_color="red", 
                           annotation_text="Umbral Crítico")
        
        st.plotly_chart(fig_churn, use_container_width=True)
        
        # ROI del programa de retención
        st.markdown("#### 💰 ROI del Programa de Retención")
        
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.metric("Clientes Salvados", "12", "este mes")
        with col2:
            st.metric("Revenue Retenido", "$380K", "↗️ +23%")
        with col3:
            st.metric("Costo Programa", "$45K", "inversión mensual")
        with col4:
            st.metric("ROI", "8.4x", "retorno inversión")
    
    with tab4:
        st.markdown("### 📈 Análisis de Tendencias")
        
        # Tendencias por producto
        trends_data = pd.DataFrame({
            'producto': ['CloudSync Enterprise', 'DataFlow Analytics Pro', 'AIChat Assistant Business', 
                        'SecureVault Premium', 'Legacy Migration Tool', 'Mobile Workforce Suite'],
            'crecimiento_6m': [18.5, 22.3, 35.7, -5.2, -8.9, 12.1],
            'ingresos_6m': [62500, 49000, 32500, 37500, 21000, 28000],
            'clientes_nuevos': [23, 18, 28, 8, 3, 15],
            'clasificacion': ['CRECIMIENTO FUERTE', 'CRECIMIENTO FUERTE', 'CRECIMIENTO FUERTE', 
                            'DECLIVE MODERADO', 'DECLIVE FUERTE', 'CRECIMIENTO MODERADO']
        })
        
        # Matriz de crecimiento
        fig_trends = px.scatter(
            trends_data,
            x='ingresos_6m',
            y='crecimiento_6m',
            size='clientes_nuevos',
            color='clasificacion',
            title="Matriz de Growth of Productos",
            labels={
                'ingresos_6m': 'Ingresos Últimos 6 Meses ($)',
                'crecimiento_6m': 'Crecimiento (%)',
                'clientes_nuevos': 'Clientes Nuevos'
            },
            color_discrete_map={
                'CRECIMIENTO FUERTE': LIVERPOOL_COLORS['accent'],
                'CRECIMIENTO MODERADO': LIVERPOOL_COLORS['warning'],
                'DECLIVE MODERADO': LIVERPOOL_COLORS['danger'],
                'DECLIVE FUERTE': '#8B0000'
            }
        )
        
        # Líneas de referencia
        fig_trends.add_hline(y=0, line_dash="solid", line_color="gray", opacity=0.5)
        fig_trends.add_hline(y=10, line_dash="dash", line_color="green", 
                           annotation_text="Crecimiento Objetivo")
        
        st.plotly_chart(fig_trends, use_container_width=True)
        
        # Recomendaciones estratégicas
        st.markdown("#### 🎯 Recomendaciones Estratégicas")
        
        recommendations = [
            {
                'categoria': '🚀 Productos Estrella',
                'productos': 'AIChat Assistant Business, DataFlow Analytics Pro',
                'accion': 'Aumentar inversión en marketing y desarrollo de funcionalidades',
                'prioridad': 'ALTA'
            },
            {
                'categoria': '⚠️ Productos en Riesgo', 
                'productos': 'Legacy Migration Tool, SecureVault Premium',
                'accion': 'Revisar estrategia de producto y posicionamiento de mercado',
                'prioridad': 'MEDIA'
            },
            {
                'categoria': '💡 Oportunidades',
                'productos': 'Mobile Workforce Suite',
                'accion': 'Acelerar desarrollo e integración con productos principales',
                'prioridad': 'MEDIA'
            }
        ]
        
        for rec in recommendations:
            priority_color = {
                'ALTA': LIVERPOOL_COLORS['danger'],
                'MEDIA': LIVERPOOL_COLORS['warning'],
                'BAJA': LIVERPOOL_COLORS['accent']
            }[rec['prioridad']]
            
            st.markdown(f"""
            <div style="background: white; padding: 1rem; border-radius: 8px; margin-bottom: 1rem; border-left: 4px solid {priority_color}; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                <h4 style="color: {LIVERPOOL_COLORS['primary']}; margin: 0;">
                    {rec['categoria']}
                    <span style="background: {priority_color}; color: white; padding: 0.2rem 0.5rem; border-radius: 4px; font-size: 0.8rem; float: right;">
                        {rec['prioridad']}
                    </span>
                </h4>
                <p style="margin: 0.5rem 0; color: {LIVERPOOL_COLORS['neutral']};"><strong>Productos:</strong> {rec['productos']}</p>
                <p style="margin: 0; font-weight: 500; color: {LIVERPOOL_COLORS['primary']};">
                    💡 <strong>Acción:</strong> {rec['accion']}
                </p>
            </div>
            """, unsafe_allow_html=True)

# =====================================================
# SECCIÓN 6: ALERTAS Y MONITOREO
# =====================================================

elif demo_section == "⚠️ Alerts & Monitoring":
    st.markdown('<h2 class="section-header">⚠️ Real-Time Alerts and Monitoring</h2>', unsafe_allow_html=True)
    
    st.markdown("""
    Sistema inteligente de monitoreo que utiliza ML para detectar patrones anómalos 
    y generar alertas proactivas para el equipo de operaciones.
    """)
    
    # Resumen de alertas activas
    st.markdown("### 🚨 Alertas Activas")
    
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.markdown(f"""
        <div style="background: {LIVERPOOL_COLORS['danger']}15; padding: 1rem; border-radius: 8px; text-align: center; border: 2px solid {LIVERPOOL_COLORS['danger']};">
            <h2 style="color: {LIVERPOOL_COLORS['danger']}; margin: 0;">1</h2>
            <p style="margin: 0; font-weight: 500;">CRÍTICAS</p>
        </div>
        """, unsafe_allow_html=True)
    
    with col2:
        st.markdown(f"""
        <div style="background: {LIVERPOOL_COLORS['warning']}15; padding: 1rem; border-radius: 8px; text-align: center; border: 2px solid {LIVERPOOL_COLORS['warning']};">
            <h2 style="color: {LIVERPOOL_COLORS['warning']}; margin: 0;">3</h2>
            <p style="margin: 0; font-weight: 500;">ALTAS</p>
        </div>
        """, unsafe_allow_html=True)
    
    with col3:
        st.markdown(f"""
        <div style="background: {LIVERPOOL_COLORS['secondary']}15; padding: 1rem; border-radius: 8px; text-align: center; border: 2px solid {LIVERPOOL_COLORS['secondary']};">
            <h2 style="color: {LIVERPOOL_COLORS['secondary']}; margin: 0;">8</h2>
            <p style="margin: 0; font-weight: 500;">MEDIAS</p>
        </div>
        """, unsafe_allow_html=True)
    
    with col4:
        st.markdown(f"""
        <div style="background: {LIVERPOOL_COLORS['accent']}15; padding: 1rem; border-radius: 8px; text-align: center; border: 2px solid {LIVERPOOL_COLORS['accent']};">
            <h2 style="color: {LIVERPOOL_COLORS['accent']}; margin: 0;">47</h2>
            <p style="margin: 0; font-weight: 500;">RESUELTAS HOY</p>
        </div>
        """, unsafe_allow_html=True)
    
    # Lista de alertas críticas y altas
    st.markdown("### 🔥 Alertas Prioritarias")
    
    priority_alerts = [
        {
            'id': 'ALT-CRIT-001',
            'tipo': 'Anomalía de Transacción',
            'severidad': 'CRÍTICA',
            'descripcion': 'Transacción TXN-2024-157 con valor $22,000 - 10x superior al promedio del cliente',
            'entidad': 'AutoMotive Innovations',
            'tiempo': '5 min',
            'score': 0.94
        },
        {
            'id': 'ALT-HIGH-002', 
            'tipo': 'Riesgo de Churn',
            'severidad': 'ALTA',
            'descripcion': 'Cliente Global Manufacturing Corp con probabilidad de churn 78%',
            'entidad': 'Global Manufacturing Corp',
            'tiempo': '12 min',
            'score': 0.78
        },
        {
            'id': 'ALT-HIGH-003',
            'tipo': 'Pico de Errores',
            'severidad': 'ALTA', 
            'descripcion': 'Aumento 300% en errores CS-401 en últimas 2 horas',
            'entidad': 'CloudSync Enterprise',
            'tiempo': '8 min',
            'score': 0.85
        },
        {
            'id': 'ALT-HIGH-004',
            'tipo': 'Customer Satisfaction',
            'severidad': 'ALTA',
            'descripcion': 'Caída súbita en satisfacción promedio a 2.1/5 para producto AIChat',
            'entidad': 'AIChat Assistant',
            'tiempo': '15 min', 
            'score': 0.72
        }
    ]
    
    for alert in priority_alerts:
        severity_config = {
            'CRÍTICA': {'color': LIVERPOOL_COLORS['danger'], 'icon': '🔴'},
            'ALTA': {'color': LIVERPOOL_COLORS['warning'], 'icon': '🟡'},
            'MEDIA': {'color': LIVERPOOL_COLORS['secondary'], 'icon': '🔵'}
        }
        
        config = severity_config[alert['severidad']]
        
        col1, col2 = st.columns([4, 1])
        
        with col1:
            st.markdown(f"""
            <div style="background: white; padding: 1rem; border-radius: 8px; margin-bottom: 1rem; border-left: 4px solid {config['color']}; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem;">
                    <h4 style="color: {LIVERPOOL_COLORS['primary']}; margin: 0;">
                        {config['icon']} {alert['tipo']} - {alert['id']}
                    </h4>
                    <span style="background: {config['color']}; color: white; padding: 0.2rem 0.8rem; border-radius: 4px; font-size: 0.8rem;">
                        {alert['severidad']}
                    </span>
                </div>
                <p style="margin: 0.5rem 0; color: {LIVERPOOL_COLORS['neutral']};">{alert['descripcion']}</p>
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <span style="color: {LIVERPOOL_COLORS['primary']}; font-weight: 500;">
                        🎯 {alert['entidad']} | ⏰ Hace {alert['tiempo']} | 📊 Score: {alert['score']}
                    </span>
                </div>
            </div>
            """, unsafe_allow_html=True)
        
        with col2:
            col_a, col_b = st.columns(2)
            with col_a:
                if st.button("🔍 Ver", key=f"view_{alert['id']}"):
                    st.info(f"Abriendo detalles de {alert['id']}")
            with col_b:
                if st.button("✅ Resolver", key=f"resolve_{alert['id']}"):
                    st.success(f"Alerta {alert['id']} marcada como resuelta")
    
    # Dashboard de métricas en tiempo real
    st.markdown("### 📊 Métricas en Tiempo Real")
    
    # Simular datos en tiempo real (9 horas de datos)
    real_time_data = pd.DataFrame({
        'hora': pd.date_range('2024-04-30 08:00', periods=9, freq='h'),
        'transacciones': [12, 18, 15, 22, 28, 35, 42, 38, 33],
        'errores': [0, 1, 0, 2, 1, 8, 12, 6, 3],
        'satisfaccion': [4.5, 4.3, 4.4, 4.2, 4.1, 3.8, 3.2, 3.6, 4.0]
    })
    
    col1, col2 = st.columns(2)
    
    with col1:
        # Gráfico de transacciones vs errores
        fig_ops = make_subplots(
            rows=2, cols=1,
            subplot_titles=('Transacciones por Hora', 'Errores Detectados'),
            vertical_spacing=0.15
        )
        
        fig_ops.add_trace(
            go.Scatter(x=real_time_data['hora'], y=real_time_data['transacciones'],
                      mode='lines+markers', name='Transacciones',
                      line=dict(color=LIVERPOOL_COLORS['primary'])),
            row=1, col=1
        )
        
        fig_ops.add_trace(
            go.Scatter(x=real_time_data['hora'], y=real_time_data['errores'],
                      mode='lines+markers', name='Errores',
                      line=dict(color=LIVERPOOL_COLORS['danger'])),
            row=2, col=1
        )
        
        fig_ops.update_layout(height=400, title_text="Monitoreo Operacional")
        st.plotly_chart(fig_ops, use_container_width=True)
    
    with col2:
        # Gráfico de satisfacción
        fig_satisfaction = px.line(
            real_time_data,
            x='hora',
            y='satisfaccion',
            title='Satisfacción del Cliente - Tiempo Real',
            markers=True
        )
        
        fig_satisfaction.add_hline(y=4.0, line_dash="dash", line_color="green", 
                                 annotation_text="Meta: 4.0")
        fig_satisfaction.add_hline(y=3.5, line_dash="dash", line_color="red", 
                                 annotation_text="Umbral Crítico: 3.5")
        
        fig_satisfaction.update_layout(height=400)
        st.plotly_chart(fig_satisfaction, use_container_width=True)
    
    # Configuración de alertas
    st.markdown("### ⚙️ Configuración de Alertas")
    
    with st.expander("🔧 Configurar Umbrales y Notificaciones"):
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown("**Umbrales de Anomalías**")
            anomaly_threshold = st.slider("Score de Anomalía", 0.1, 1.0, 0.6, 0.1)
            churn_threshold = st.slider("Probabilidad de Churn", 0.1, 1.0, 0.7, 0.1)
            error_threshold = st.slider("Incremento de Errores (%)", 50, 500, 200, 50)
        
        with col2:
            st.markdown("**Canales de Notificación**")
            email_alerts = st.checkbox("Email", value=True)
            slack_alerts = st.checkbox("Slack", value=True)
            sms_alerts = st.checkbox("SMS (solo críticas)", value=False)
            dashboard_alerts = st.checkbox("Dashboard", value=True)
        
        if st.button("💾 Guardar Configuración"):
            st.success("✅ Configuración de alertas actualizada exitosamente")
    
    # Historial de alertas
    st.markdown("### 📈 Tendencias de Alertas")
    
    # Datos simulados de tendencias (30 días de datos)
    num_days_trends = 30
    alert_trends = pd.DataFrame({
        'fecha': pd.date_range('2024-04-01', periods=num_days_trends, freq='D'),
        'criticas': ([0, 1, 0, 0, 2, 0, 1, 0, 0, 1] * (num_days_trends // 10 + 1))[:num_days_trends],
        'altas': ([2, 3, 1, 4, 5, 3, 2, 4, 3, 2] * (num_days_trends // 10 + 1))[:num_days_trends],
        'medias': ([8, 12, 6, 15, 18, 10, 9, 13, 11, 7] * (num_days_trends // 10 + 1))[:num_days_trends]
    })
    
    fig_trends = px.area(
        alert_trends,
        x='fecha',
        y=['criticas', 'altas', 'medias'],
        title='Evolución de Alertas - Últimos 30 días',
        color_discrete_map={
            'criticas': LIVERPOOL_COLORS['danger'],
            'altas': LIVERPOOL_COLORS['warning'],
            'medias': LIVERPOOL_COLORS['secondary']
        }
    )
    
    st.plotly_chart(fig_trends, use_container_width=True)

# =====================================================
# FOOTER
# =====================================================

st.markdown("---")
st.markdown(f"""
<div style="text-align: center; color: {LIVERPOOL_COLORS['neutral']}; padding: 2rem;">
    <p><strong>Liverpool México - Snowflake Cortex Retail Demo</strong></p>
    <p>Demonstrating AI-powered retail analytics and customer intelligence capabilities</p>
    <p>🛍️ Retail Excellence | 🤖 Artificial Intelligence | 📊 Customer Analytics | 🔍 Product Intelligence</p>
</div>
""", unsafe_allow_html=True)

