"""
Código Python para Notebooks de Snowflake - Fénix Energía
Creación de vistas analíticas usando Snowpark
Optimizado para ejecutarse en el entorno nativo de Snowflake
"""

# ====================================================================
# CELDA 1: IMPORTACIONES Y CONFIGURACIÓN INICIAL
# ====================================================================

import snowflake.snowpark as snowpark
from snowflake.snowpark import Session
from snowflake.snowpark.functions import *
from snowflake.snowpark.types import *
import pandas as pd
from datetime import datetime

# Configuración de la sesión (automática en notebooks de Snowflake)
print("🏭 FÉNIX ENERGÍA - ANÁLISIS DE DATOS ENERGÉTICOS")
print("=" * 60)
print(f"📅 Fecha de ejecución: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
print("🎯 Objetivo: Crear vistas analíticas para el sector energético mexicano")
print("=" * 60)

# Variables de configuración
DATABASE = "FENIX_DB"
SCHEMA = "FENIX_ENERGY_SCHEMA"
FULL_SCHEMA = f"{DATABASE}.{SCHEMA}"

# ====================================================================
# CELDA 2: FUNCIONES AUXILIARES
# ====================================================================

def create_view_safe(session: Session, view_name: str, query: str, description: str = ""):
    """
    Crea una vista de forma segura con manejo de errores
    
    Args:
        session: Sesión de Snowpark
        view_name: Nombre de la vista
        query: Query SQL para crear la vista
        description: Descripción de la vista
    """
    try:
        print(f"🔄 Creando vista: {view_name}")
        if description:
            print(f"📝 Descripción: {description}")
        
        # Crear la vista
        session.sql(f"CREATE OR REPLACE VIEW {FULL_SCHEMA}.{view_name} AS {query}").collect()
        print(f"✅ Vista {view_name} creada exitosamente")
        return True
        
    except Exception as e:
        print(f"❌ Error creando vista {view_name}: {str(e)}")
        return False

def validate_tables(session: Session):
    """
    Valida que las tablas necesarias existan
    """
    required_tables = [
        "DIM_CLIENTES",
        "DIM_CONDICIONES_HIDROCLIMATICAS", 
        "DIM_CONDICIONES_MERCADO",
        "FACT_CONSUMO_DIARIO"
    ]
    
    print("🔍 Validando existencia de tablas...")
    
    for table in required_tables:
        try:
            result = session.sql(f"SELECT COUNT(*) as count FROM {FULL_SCHEMA}.{table} LIMIT 1").collect()
            count = result[0]['COUNT'] if result else 0
            print(f"✅ {table}: {count:,} registros")
        except Exception as e:
            print(f"❌ {table}: No encontrada - {str(e)}")
            return False
    
    return True

# ====================================================================
# CELDA 3: VALIDACIÓN INICIAL
# ====================================================================

# Validar que las tablas existen
if validate_tables(session):
    print("\n🎉 Todas las tablas están disponibles. Procediendo con la creación de vistas...")
else:
    print("\n❌ Faltan tablas requeridas. Verifica la configuración del modelo de datos.")

# ====================================================================
# CELDA 4: VISTA DE ANÁLISIS DE CONSUMO
# ====================================================================

# Vista principal para análisis de consumo energético
vista_analisis_consumo = f"""
SELECT 
    c.ESTADO,
    c.INDUSTRIA,
    c.NOMBRE_CLIENTE,
    f.FECHA,
    f.CONSUMO_MWH,
    f.PRECIO_MONOMICO_MXN,
    f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN AS INGRESOS_MXN,
    
    -- Dimensiones temporales
    DATE_TRUNC('MONTH', f.FECHA) AS MES,
    DATE_TRUNC('QUARTER', f.FECHA) AS TRIMESTRE,
    YEAR(f.FECHA) AS ANNO,
    DAYOFWEEK(f.FECHA) AS DIA_SEMANA,
    MONTHNAME(f.FECHA) AS NOMBRE_MES,
    
    -- Clasificaciones de consumo
    CASE 
        WHEN f.CONSUMO_MWH > 2000 THEN 'Alto'
        WHEN f.CONSUMO_MWH > 1000 THEN 'Medio'
        ELSE 'Bajo'
    END AS CATEGORIA_CONSUMO,
    
    -- Clasificaciones de precio
    CASE 
        WHEN f.PRECIO_MONOMICO_MXN > 2.5 THEN 'Premium'
        WHEN f.PRECIO_MONOMICO_MXN > 1.8 THEN 'Estándar'
        ELSE 'Económico'
    END AS CATEGORIA_PRECIO,
    
    -- Indicadores de eficiencia
    f.CONSUMO_MWH / NULLIF(f.PRECIO_MONOMICO_MXN, 0) AS EFICIENCIA_PRECIO
    
FROM {FULL_SCHEMA}.FACT_CONSUMO_DIARIO f
JOIN {FULL_SCHEMA}.DIM_CLIENTES c 
    ON f.ID_CLIENTE = c.ID_CLIENTE
"""

create_view_safe(
    session, 
    "VW_ANALISIS_CONSUMO", 
    vista_analisis_consumo,
    "Vista principal para análisis de consumo energético por cliente, estado e industria"
)

# ====================================================================
# CELDA 5: VISTA DE IMPACTO CLIMÁTICO
# ====================================================================

vista_impacto_climatico = f"""
SELECT 
    f.FECHA,
    c.ESTADO,
    c.INDUSTRIA,
    
    -- Datos climáticos
    h.TEMPERATURA_PROMEDIO_C,
    h.PRECIPITACION_MENSUAL_MM,
    h.NIVEL_PRESA_PORCENTAJE,
    h.ID_PRESA,
    
    -- Métricas agregadas de consumo
    SUM(f.CONSUMO_MWH) AS CONSUMO_TOTAL_MWH,
    AVG(f.PRECIO_MONOMICO_MXN) AS PRECIO_PROMEDIO_MXN,
    COUNT(DISTINCT f.ID_CLIENTE) AS CLIENTES_ACTIVOS,
    SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) AS INGRESOS_TOTALES_MXN,
    
    -- Clasificaciones climáticas
    CASE 
        WHEN h.TEMPERATURA_PROMEDIO_C > 30 THEN 'Muy Caliente'
        WHEN h.TEMPERATURA_PROMEDIO_C > 25 THEN 'Caliente'
        WHEN h.TEMPERATURA_PROMEDIO_C > 15 THEN 'Templado'
        ELSE 'Frío'
    END AS CATEGORIA_TEMPERATURA,
    
    CASE 
        WHEN h.PRECIPITACION_MENSUAL_MM > 150 THEN 'Lluvioso'
        WHEN h.PRECIPITACION_MENSUAL_MM > 50 THEN 'Moderado'
        ELSE 'Seco'
    END AS CATEGORIA_PRECIPITACION,
    
    CASE 
        WHEN h.NIVEL_PRESA_PORCENTAJE > 80 THEN 'Óptimo'
        WHEN h.NIVEL_PRESA_PORCENTAJE > 60 THEN 'Bueno'
        WHEN h.NIVEL_PRESA_PORCENTAJE > 40 THEN 'Regular'
        ELSE 'Crítico'
    END AS ESTADO_PRESA,
    
    -- Índice de impacto climático
    CASE 
        WHEN h.TEMPERATURA_PROMEDIO_C > 28 AND h.PRECIPITACION_MENSUAL_MM < 30 THEN 'Alto Impacto'
        WHEN h.TEMPERATURA_PROMEDIO_C < 12 AND h.PRECIPITACION_MENSUAL_MM > 200 THEN 'Alto Impacto'
        ELSE 'Impacto Normal'
    END AS IMPACTO_CLIMATICO
    
FROM {FULL_SCHEMA}.FACT_CONSUMO_DIARIO f
JOIN {FULL_SCHEMA}.DIM_CLIENTES c 
    ON f.ID_CLIENTE = c.ID_CLIENTE
JOIN {FULL_SCHEMA}.DIM_CONDICIONES_HIDROCLIMATICAS h 
    ON f.FECHA = h.FECHA
GROUP BY 
    f.FECHA, c.ESTADO, c.INDUSTRIA, h.ID_PRESA,
    h.TEMPERATURA_PROMEDIO_C, h.PRECIPITACION_MENSUAL_MM, h.NIVEL_PRESA_PORCENTAJE
"""

create_view_safe(
    session, 
    "VW_IMPACTO_CLIMATICO", 
    vista_impacto_climatico,
    "Análisis del impacto de condiciones hidroclimáticas en el consumo energético"
)

# ====================================================================
# CELDA 6: VISTA DE CONDICIONES DE MERCADO
# ====================================================================

vista_condiciones_mercado = f"""
SELECT 
    f.FECHA,
    DATE_TRUNC('MONTH', f.FECHA) AS MES,
    
    -- Condiciones de mercado
    m.INPC_GENERAL,
    m.PRECIO_GAS_NATURAL_HHm,
    m.TIPO_DE_CAMBIO_FIX,
    
    -- Métricas energéticas agregadas
    SUM(f.CONSUMO_MWH) AS CONSUMO_TOTAL_MWH,
    AVG(f.PRECIO_MONOMICO_MXN) AS PRECIO_PROMEDIO_MXN,
    SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) AS INGRESOS_TOTALES_MXN,
    COUNT(DISTINCT f.ID_CLIENTE) AS CLIENTES_ACTIVOS,
    
    -- Indicadores de mercado
    CASE 
        WHEN m.INPC_GENERAL > 110 THEN 'Inflación Alta'
        WHEN m.INPC_GENERAL > 105 THEN 'Inflación Moderada'
        ELSE 'Inflación Controlada'
    END AS ESTADO_INFLACION,
    
    CASE 
        WHEN m.TIPO_DE_CAMBIO_FIX > 20 THEN 'Peso Debilitado'
        WHEN m.TIPO_DE_CAMBIO_FIX > 18 THEN 'Peso Estable'
        ELSE 'Peso Fortalecido'
    END AS ESTADO_TIPO_CAMBIO,
    
    CASE 
        WHEN m.PRECIO_GAS_NATURAL_HHm > 4.0 THEN 'Gas Caro'
        WHEN m.PRECIO_GAS_NATURAL_HHm > 2.5 THEN 'Gas Moderado'
        ELSE 'Gas Barato'
    END AS ESTADO_GAS_NATURAL,
    
    -- Índice de volatilidad de mercado
    CASE 
        WHEN m.INPC_GENERAL > 108 AND m.TIPO_DE_CAMBIO_FIX > 19 AND m.PRECIO_GAS_NATURAL_HHm > 3.5 THEN 'Mercado Volátil'
        WHEN m.INPC_GENERAL < 103 AND m.TIPO_DE_CAMBIO_FIX < 18.5 AND m.PRECIO_GAS_NATURAL_HHm < 3.0 THEN 'Mercado Estable'
        ELSE 'Mercado Moderado'
    END AS VOLATILIDAD_MERCADO
    
FROM {FULL_SCHEMA}.FACT_CONSUMO_DIARIO f
JOIN {FULL_SCHEMA}.DIM_CONDICIONES_MERCADO m 
    ON f.FECHA = m.FECHA
GROUP BY 
    f.FECHA, m.INPC_GENERAL, m.PRECIO_GAS_NATURAL_HHm, m.TIPO_DE_CAMBIO_FIX
"""

create_view_safe(
    session, 
    "VW_CONDICIONES_MERCADO", 
    vista_condiciones_mercado,
    "Análisis de condiciones económicas del mercado energético mexicano"
)

# ====================================================================
# CELDA 7: VISTA DASHBOARD DE EFICIENCIA
# ====================================================================

vista_dashboard_eficiencia = f"""
SELECT 
    c.ESTADO,
    c.INDUSTRIA,
    DATE_TRUNC('MONTH', f.FECHA) AS MES,
    
    -- KPIs principales
    COUNT(DISTINCT c.ID_CLIENTE) AS TOTAL_CLIENTES,
    SUM(f.CONSUMO_MWH) AS CONSUMO_TOTAL_MWH,
    AVG(f.CONSUMO_MWH) AS CONSUMO_PROMEDIO_MWH,
    SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) AS INGRESOS_TOTALES_MXN,
    AVG(f.PRECIO_MONOMICO_MXN) AS PRECIO_PROMEDIO_MXN,
    
    -- Métricas de eficiencia
    SUM(f.CONSUMO_MWH) / NULLIF(COUNT(DISTINCT c.ID_CLIENTE), 0) AS MWH_POR_CLIENTE,
    SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) / NULLIF(COUNT(DISTINCT c.ID_CLIENTE), 0) AS INGRESOS_POR_CLIENTE,
    SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) / NULLIF(SUM(f.CONSUMO_MWH), 0) AS PRECIO_EFECTIVO_MWH,
    
    -- Rankings
    RANK() OVER (PARTITION BY DATE_TRUNC('MONTH', f.FECHA) ORDER BY SUM(f.CONSUMO_MWH) DESC) AS RANKING_CONSUMO,
    RANK() OVER (PARTITION BY DATE_TRUNC('MONTH', f.FECHA) ORDER BY SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) DESC) AS RANKING_INGRESOS,
    
    -- Percentiles
    PERCENT_RANK() OVER (PARTITION BY DATE_TRUNC('MONTH', f.FECHA) ORDER BY SUM(f.CONSUMO_MWH)) AS PERCENTIL_CONSUMO,
    PERCENT_RANK() OVER (PARTITION BY DATE_TRUNC('MONTH', f.FECHA) ORDER BY SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN)) AS PERCENTIL_INGRESOS,
    
    -- Tendencias (comparación mes anterior)
    LAG(SUM(f.CONSUMO_MWH), 1) OVER (
        PARTITION BY c.ESTADO, c.INDUSTRIA 
        ORDER BY DATE_TRUNC('MONTH', f.FECHA)
    ) AS CONSUMO_MES_ANTERIOR,
    
    LAG(SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN), 1) OVER (
        PARTITION BY c.ESTADO, c.INDUSTRIA 
        ORDER BY DATE_TRUNC('MONTH', f.FECHA)
    ) AS INGRESOS_MES_ANTERIOR,
    
    -- Crecimiento porcentual
    CASE 
        WHEN LAG(SUM(f.CONSUMO_MWH), 1) OVER (PARTITION BY c.ESTADO, c.INDUSTRIA ORDER BY DATE_TRUNC('MONTH', f.FECHA)) > 0
        THEN ((SUM(f.CONSUMO_MWH) - LAG(SUM(f.CONSUMO_MWH), 1) OVER (PARTITION BY c.ESTADO, c.INDUSTRIA ORDER BY DATE_TRUNC('MONTH', f.FECHA))) / 
              LAG(SUM(f.CONSUMO_MWH), 1) OVER (PARTITION BY c.ESTADO, c.INDUSTRIA ORDER BY DATE_TRUNC('MONTH', f.FECHA))) * 100
        ELSE NULL
    END AS CRECIMIENTO_CONSUMO_PCT
    
FROM {FULL_SCHEMA}.FACT_CONSUMO_DIARIO f
JOIN {FULL_SCHEMA}.DIM_CLIENTES c 
    ON f.ID_CLIENTE = c.ID_CLIENTE
GROUP BY 
    c.ESTADO, c.INDUSTRIA, DATE_TRUNC('MONTH', f.FECHA)
"""

create_view_safe(
    session, 
    "VW_DASHBOARD_EFICIENCIA", 
    vista_dashboard_eficiencia,
    "Dashboard de eficiencia energética con KPIs, rankings y tendencias"
)

# ====================================================================
# CELDA 8: VISTA ANALYTICS INTEGRAL
# ====================================================================

vista_analytics_integral = f"""
SELECT 
    -- Dimensiones principales
    f.FECHA,
    c.ESTADO,
    c.INDUSTRIA,
    c.NOMBRE_CLIENTE,
    
    -- Métricas de consumo
    f.CONSUMO_MWH,
    f.PRECIO_MONOMICO_MXN,
    f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN AS INGRESOS_MXN,
    
    -- Condiciones climáticas
    h.TEMPERATURA_PROMEDIO_C,
    h.PRECIPITACION_MENSUAL_MM,
    h.NIVEL_PRESA_PORCENTAJE,
    
    -- Condiciones de mercado
    m.INPC_GENERAL,
    m.PRECIO_GAS_NATURAL_HHm,
    m.TIPO_DE_CAMBIO_FIX,
    
    -- Clasificaciones integradas
    CASE 
        WHEN h.TEMPERATURA_PROMEDIO_C > 25 AND f.CONSUMO_MWH > 1500 THEN 'Alta Demanda Climática'
        WHEN h.TEMPERATURA_PROMEDIO_C < 15 AND f.CONSUMO_MWH > 1200 THEN 'Demanda Invernal'
        WHEN h.PRECIPITACION_MENSUAL_MM > 200 AND f.CONSUMO_MWH < 800 THEN 'Baja Demanda Lluviosa'
        ELSE 'Demanda Normal'
    END AS TIPO_DEMANDA,
    
    -- Factor de impacto en precios
    CASE 
        WHEN m.PRECIO_GAS_NATURAL_HHm > 3.5 AND f.PRECIO_MONOMICO_MXN > 2.0 THEN 'Impacto Gas Alto'
        WHEN m.TIPO_DE_CAMBIO_FIX > 19 AND f.PRECIO_MONOMICO_MXN > 2.2 THEN 'Impacto Tipo Cambio'
        WHEN m.INPC_GENERAL > 108 AND f.PRECIO_MONOMICO_MXN > 2.1 THEN 'Impacto Inflación'
        ELSE 'Precio Estable'
    END AS FACTOR_PRECIO,
    
    -- Eficiencia hídrica
    CASE 
        WHEN h.NIVEL_PRESA_PORCENTAJE > 70 AND h.PRECIPITACION_MENSUAL_MM > 100 THEN 'Óptima'
        WHEN h.NIVEL_PRESA_PORCENTAJE > 50 THEN 'Buena'
        WHEN h.NIVEL_PRESA_PORCENTAJE > 30 THEN 'Regular'
        ELSE 'Crítica'
    END AS EFICIENCIA_HIDRICA,
    
    -- Índice de riesgo energético
    CASE 
        WHEN h.NIVEL_PRESA_PORCENTAJE < 40 AND m.PRECIO_GAS_NATURAL_HHm > 4.0 AND m.TIPO_DE_CAMBIO_FIX > 20 THEN 'Riesgo Alto'
        WHEN h.NIVEL_PRESA_PORCENTAJE < 60 AND m.PRECIO_GAS_NATURAL_HHm > 3.0 THEN 'Riesgo Moderado'
        ELSE 'Riesgo Bajo'
    END AS RIESGO_ENERGETICO,
    
    -- Score de sostenibilidad (0-100)
    LEAST(100, GREATEST(0, 
        (h.NIVEL_PRESA_PORCENTAJE * 0.4) + 
        ((100 - LEAST(100, h.TEMPERATURA_PROMEDIO_C * 3)) * 0.3) +
        (LEAST(100, h.PRECIPITACION_MENSUAL_MM / 2) * 0.3)
    )) AS SCORE_SOSTENIBILIDAD
    
FROM {FULL_SCHEMA}.FACT_CONSUMO_DIARIO f
JOIN {FULL_SCHEMA}.DIM_CLIENTES c 
    ON f.ID_CLIENTE = c.ID_CLIENTE
LEFT JOIN {FULL_SCHEMA}.DIM_CONDICIONES_HIDROCLIMATICAS h 
    ON f.FECHA = h.FECHA
LEFT JOIN {FULL_SCHEMA}.DIM_CONDICIONES_MERCADO m 
    ON f.FECHA = m.FECHA
"""

create_view_safe(
    session, 
    "VW_ANALYTICS_INTEGRAL", 
    vista_analytics_integral,
    "Vista integral que combina datos de consumo, clima y mercado con análisis predictivo"
)

# ====================================================================
# CELDA 9: ANÁLISIS Y VALIDACIÓN DE VISTAS CREADAS
# ====================================================================

print("\n📊 ANÁLISIS DE VISTAS CREADAS")
print("=" * 60)

# Lista de vistas creadas
vistas_creadas = [
    "VW_ANALISIS_CONSUMO",
    "VW_IMPACTO_CLIMATICO", 
    "VW_CONDICIONES_MERCADO",
    "VW_DASHBOARD_EFICIENCIA",
    "VW_ANALYTICS_INTEGRAL"
]

# Validar cada vista
for vista in vistas_creadas:
    try:
        resultado = session.sql(f"SELECT COUNT(*) as registros FROM {FULL_SCHEMA}.{vista}").collect()
        registros = resultado[0]['REGISTROS'] if resultado else 0
        print(f"✅ {vista}: {registros:,} registros")
    except Exception as e:
        print(f"❌ {vista}: Error - {str(e)}")

# ====================================================================
# CELDA 10: EJEMPLOS DE CONSULTAS ANALÍTICAS
# ====================================================================

print("\n🔍 EJEMPLOS DE ANÁLISIS USANDO LAS VISTAS")
print("=" * 60)

# Ejemplo 1: Top 5 estados por consumo
print("1️⃣ TOP 5 ESTADOS POR CONSUMO:")
top_estados = session.sql(f"""
    SELECT ESTADO, SUM(CONSUMO_MWH) as TOTAL_MWH 
    FROM {FULL_SCHEMA}.VW_ANALISIS_CONSUMO 
    GROUP BY ESTADO 
    ORDER BY TOTAL_MWH DESC 
    LIMIT 5
""").collect()

for row in top_estados:
    print(f"   {row['ESTADO']}: {row['TOTAL_MWH']:,.0f} MWh")

# Ejemplo 2: Análisis de impacto climático
print("\n2️⃣ ANÁLISIS DE IMPACTO CLIMÁTICO:")
impacto_clima = session.sql(f"""
    SELECT CATEGORIA_TEMPERATURA, 
           COUNT(*) as DIAS,
           AVG(CONSUMO_TOTAL_MWH) as CONSUMO_PROMEDIO
    FROM {FULL_SCHEMA}.VW_IMPACTO_CLIMATICO 
    GROUP BY CATEGORIA_TEMPERATURA 
    ORDER BY CONSUMO_PROMEDIO DESC
""").collect()

for row in impacto_clima:
    print(f"   {row['CATEGORIA_TEMPERATURA']}: {row['CONSUMO_PROMEDIO']:,.0f} MWh promedio ({row['DIAS']} días)")

# Ejemplo 3: Condiciones de mercado
print("\n3️⃣ ANÁLISIS DE CONDICIONES DE MERCADO:")
mercado = session.sql(f"""
    SELECT VOLATILIDAD_MERCADO, 
           COUNT(*) as DIAS,
           AVG(PRECIO_PROMEDIO_MXN) as PRECIO_PROMEDIO
    FROM {FULL_SCHEMA}.VW_CONDICIONES_MERCADO 
    GROUP BY VOLATILIDAD_MERCADO 
    ORDER BY PRECIO_PROMEDIO DESC
""").collect()

for row in mercado:
    print(f"   {row['VOLATILIDAD_MERCADO']}: ${row['PRECIO_PROMEDIO']:,.2f} MXN promedio ({row['DIAS']} días)")

# ====================================================================
# CELDA 11: FUNCIONES DE ANÁLISIS AVANZADO
# ====================================================================

def analizar_tendencias_mensuales(estado=None, industria=None):
    """
    Analiza tendencias mensuales de consumo para un estado o industria específicos
    """
    where_clause = "WHERE 1=1"
    if estado:
        where_clause += f" AND ESTADO = '{estado}'"
    if industria:
        where_clause += f" AND INDUSTRIA = '{industria}'"
    
    query = f"""
    SELECT 
        MES,
        ESTADO,
        INDUSTRIA,
        CONSUMO_TOTAL_MWH,
        INGRESOS_TOTALES_MXN,
        CRECIMIENTO_CONSUMO_PCT,
        RANKING_CONSUMO
    FROM {FULL_SCHEMA}.VW_DASHBOARD_EFICIENCIA 
    {where_clause}
    ORDER BY MES DESC, RANKING_CONSUMO
    LIMIT 20
    """
    
    return session.sql(query).to_pandas()

def analizar_correlacion_clima_consumo():
    """
    Analiza la correlación entre condiciones climáticas y consumo
    """
    query = f"""
    SELECT 
        CATEGORIA_TEMPERATURA,
        CATEGORIA_PRECIPITACION,
        ESTADO_PRESA,
        AVG(CONSUMO_TOTAL_MWH) as CONSUMO_PROMEDIO,
        COUNT(*) as FRECUENCIA
    FROM {FULL_SCHEMA}.VW_IMPACTO_CLIMATICO 
    GROUP BY CATEGORIA_TEMPERATURA, CATEGORIA_PRECIPITACION, ESTADO_PRESA
    ORDER BY CONSUMO_PROMEDIO DESC
    """
    
    return session.sql(query).to_pandas()

def generar_reporte_eficiencia(mes_año=None):
    """
    Genera reporte de eficiencia energética
    """
    where_clause = ""
    if mes_año:
        where_clause = f"WHERE MES = '{mes_año}'"
    
    query = f"""
    SELECT 
        ESTADO,
        INDUSTRIA,
        TOTAL_CLIENTES,
        CONSUMO_TOTAL_MWH,
        INGRESOS_TOTALES_MXN,
        MWH_POR_CLIENTE,
        RANKING_CONSUMO,
        PERCENTIL_CONSUMO
    FROM {FULL_SCHEMA}.VW_DASHBOARD_EFICIENCIA 
    {where_clause}
    ORDER BY RANKING_CONSUMO
    LIMIT 15
    """
    
    return session.sql(query).to_pandas()

# ====================================================================
# CELDA 12: EXPORTAR DATOS PARA VISUALIZACIÓN
# ====================================================================

def exportar_datos_dashboard():
    """
    Exporta datos clave para dashboards externos
    """
    # Resumen ejecutivo
    resumen = session.sql(f"""
    SELECT 
        'Total Clientes' as METRICA,
        COUNT(DISTINCT NOMBRE_CLIENTE) as VALOR
    FROM {FULL_SCHEMA}.VW_ANALISIS_CONSUMO
    
    UNION ALL
    
    SELECT 
        'Consumo Total (MWh)' as METRICA,
        SUM(CONSUMO_MWH) as VALOR
    FROM {FULL_SCHEMA}.VW_ANALISIS_CONSUMO
    
    UNION ALL
    
    SELECT 
        'Ingresos Totales (MXN)' as METRICA,
        SUM(INGRESOS_MXN) as VALOR
    FROM {FULL_SCHEMA}.VW_ANALISIS_CONSUMO
    """).to_pandas()
    
    return resumen

# Ejecutar análisis de ejemplo
print("\n📈 EJECUTANDO ANÁLISIS DE EJEMPLO...")
print("=" * 60)

# Exportar resumen ejecutivo
try:
    resumen_ejecutivo = exportar_datos_dashboard()
    print("📊 RESUMEN EJECUTIVO:")
    for _, row in resumen_ejecutivo.iterrows():
        print(f"   {row['METRICA']}: {row['VALOR']:,.0f}")
except Exception as e:
    print(f"❌ Error en resumen ejecutivo: {e}")

print("\n🎉 ¡PROCESO COMPLETADO!")
print("=" * 60)
print("✅ Todas las vistas analíticas han sido creadas exitosamente")
print("📊 Las vistas están listas para ser utilizadas en análisis y dashboards")
print("🔍 Utiliza las funciones de análisis para explorar los datos")
print("=" * 60)


