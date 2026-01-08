"""
Script para crear vistas analíticas del modelo de datos de Fénix Energía
Autor: Generado para análisis energético mexicano
"""

import snowflake.connector
from typing import Dict, List
import os
from datetime import datetime

class FenixEnergiaViewCreator:
    """
    Clase para crear vistas analíticas del modelo de datos de Fénix Energía
    """
    
    def __init__(self, connection_params: Dict[str, str]):
        """
        Inicializa la conexión a Snowflake
        
        Args:
            connection_params: Diccionario con parámetros de conexión
        """
        self.connection_params = connection_params
        self.database = "FENIX_DB"
        self.schema = "FENIX_ENERGY_SCHEMA"
        
    def connect(self):
        """Establece conexión con Snowflake"""
        try:
            self.conn = snowflake.connector.connect(**self.connection_params)
            self.cursor = self.conn.cursor()
            print("✅ Conexión establecida con Snowflake")
            return True
        except Exception as e:
            print(f"❌ Error de conexión: {e}")
            return False
    
    def execute_sql(self, sql: str, description: str = ""):
        """
        Ejecuta una consulta SQL
        
        Args:
            sql: Consulta SQL a ejecutar
            description: Descripción de la consulta
        """
        try:
            print(f"🔄 Ejecutando: {description}")
            self.cursor.execute(sql)
            print(f"✅ Completado: {description}")
            return True
        except Exception as e:
            print(f"❌ Error en {description}: {e}")
            return False
    
    def create_consumption_analysis_view(self):
        """Crea vista para análisis de consumo energético"""
        sql = f"""
        CREATE OR REPLACE VIEW {self.database}.{self.schema}.VW_ANALISIS_CONSUMO AS
        SELECT 
            c.ESTADO,
            c.INDUSTRIA,
            c.NOMBRE_CLIENTE,
            f.FECHA,
            f.CONSUMO_MWH,
            f.PRECIO_MONOMICO_MXN,
            f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN AS INGRESOS_MXN,
            
            -- Métricas temporales
            DATE_TRUNC('MONTH', f.FECHA) AS MES,
            DATE_TRUNC('QUARTER', f.FECHA) AS TRIMESTRE,
            YEAR(f.FECHA) AS ANNO,
            DAYOFWEEK(f.FECHA) AS DIA_SEMANA,
            
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
            END AS CATEGORIA_PRECIO
            
        FROM {self.database}.{self.schema}.FACT_CONSUMO_DIARIO f
        JOIN {self.database}.{self.schema}.DIM_CLIENTES c 
            ON f.ID_CLIENTE = c.ID_CLIENTE
        """
        
        return self.execute_sql(sql, "Vista de Análisis de Consumo")
    
    def create_climate_impact_view(self):
        """Crea vista para análisis del impacto climático"""
        sql = f"""
        CREATE OR REPLACE VIEW {self.database}.{self.schema}.VW_IMPACTO_CLIMATICO AS
        SELECT 
            f.FECHA,
            c.ESTADO,
            c.INDUSTRIA,
            
            -- Datos climáticos
            h.TEMPERATURA_PROMEDIO_C,
            h.PRECIPITACION_MENSUAL_MM,
            h.NIVEL_PRESA_PORCENTAJE,
            
            -- Métricas de consumo
            SUM(f.CONSUMO_MWH) AS CONSUMO_TOTAL_MWH,
            AVG(f.PRECIO_MONOMICO_MXN) AS PRECIO_PROMEDIO_MXN,
            COUNT(DISTINCT f.ID_CLIENTE) AS CLIENTES_ACTIVOS,
            
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
            END AS ESTADO_PRESA
            
        FROM {self.database}.{self.schema}.FACT_CONSUMO_DIARIO f
        JOIN {self.database}.{self.schema}.DIM_CLIENTES c 
            ON f.ID_CLIENTE = c.ID_CLIENTE
        JOIN {self.database}.{self.schema}.DIM_CONDICIONES_HIDROCLIMATICAS h 
            ON f.FECHA = h.FECHA
        GROUP BY 
            f.FECHA, c.ESTADO, c.INDUSTRIA,
            h.TEMPERATURA_PROMEDIO_C, h.PRECIPITACION_MENSUAL_MM, h.NIVEL_PRESA_PORCENTAJE
        """
        
        return self.execute_sql(sql, "Vista de Impacto Climático")
    
    def create_market_conditions_view(self):
        """Crea vista para análisis de condiciones de mercado"""
        sql = f"""
        CREATE OR REPLACE VIEW {self.database}.{self.schema}.VW_CONDICIONES_MERCADO AS
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
            END AS ESTADO_GAS_NATURAL
            
        FROM {self.database}.{self.schema}.FACT_CONSUMO_DIARIO f
        JOIN {self.database}.{self.schema}.DIM_CONDICIONES_MERCADO m 
            ON f.FECHA = m.FECHA
        GROUP BY 
            f.FECHA, m.INPC_GENERAL, m.PRECIO_GAS_NATURAL_HHm, m.TIPO_DE_CAMBIO_FIX
        """
        
        return self.execute_sql(sql, "Vista de Condiciones de Mercado")
    
    def create_efficiency_dashboard_view(self):
        """Crea vista para dashboard de eficiencia energética"""
        sql = f"""
        CREATE OR REPLACE VIEW {self.database}.{self.schema}.VW_DASHBOARD_EFICIENCIA AS
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
            SUM(f.CONSUMO_MWH) / COUNT(DISTINCT c.ID_CLIENTE) AS MWH_POR_CLIENTE,
            SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) / COUNT(DISTINCT c.ID_CLIENTE) AS INGRESOS_POR_CLIENTE,
            SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) / SUM(f.CONSUMO_MWH) AS PRECIO_EFECTIVO_MWH,
            
            -- Ranking y percentiles
            RANK() OVER (PARTITION BY DATE_TRUNC('MONTH', f.FECHA) ORDER BY SUM(f.CONSUMO_MWH) DESC) AS RANKING_CONSUMO,
            RANK() OVER (PARTITION BY DATE_TRUNC('MONTH', f.FECHA) ORDER BY SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) DESC) AS RANKING_INGRESOS,
            
            -- Tendencias (comparación mes anterior)
            LAG(SUM(f.CONSUMO_MWH), 1) OVER (PARTITION BY c.ESTADO, c.INDUSTRIA ORDER BY DATE_TRUNC('MONTH', f.FECHA)) AS CONSUMO_MES_ANTERIOR,
            LAG(SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN), 1) OVER (PARTITION BY c.ESTADO, c.INDUSTRIA ORDER BY DATE_TRUNC('MONTH', f.FECHA)) AS INGRESOS_MES_ANTERIOR
            
        FROM {self.database}.{self.schema}.FACT_CONSUMO_DIARIO f
        JOIN {self.database}.{self.schema}.DIM_CLIENTES c 
            ON f.ID_CLIENTE = c.ID_CLIENTE
        GROUP BY 
            c.ESTADO, c.INDUSTRIA, DATE_TRUNC('MONTH', f.FECHA)
        """
        
        return self.execute_sql(sql, "Vista de Dashboard de Eficiencia")
    
    def create_comprehensive_analytics_view(self):
        """Crea vista comprehensiva que combina todos los datos"""
        sql = f"""
        CREATE OR REPLACE VIEW {self.database}.{self.schema}.VW_ANALYTICS_INTEGRAL AS
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
            
            -- Indicadores calculados
            CASE 
                WHEN h.TEMPERATURA_PROMEDIO_C > 25 AND f.CONSUMO_MWH > 1500 THEN 'Alta Demanda Climática'
                WHEN h.TEMPERATURA_PROMEDIO_C < 15 AND f.CONSUMO_MWH > 1200 THEN 'Demanda Invernal'
                ELSE 'Demanda Normal'
            END AS TIPO_DEMANDA,
            
            -- Correlación precio-mercado
            CASE 
                WHEN m.PRECIO_GAS_NATURAL_HHm > 3.5 AND f.PRECIO_MONOMICO_MXN > 2.0 THEN 'Impacto Gas Alto'
                WHEN m.TIPO_DE_CAMBIO_FIX > 19 AND f.PRECIO_MONOMICO_MXN > 2.2 THEN 'Impacto Tipo Cambio'
                ELSE 'Precio Estable'
            END AS FACTOR_PRECIO,
            
            -- Eficiencia hídrica
            CASE 
                WHEN h.NIVEL_PRESA_PORCENTAJE > 70 AND h.PRECIPITACION_MENSUAL_MM > 100 THEN 'Óptima'
                WHEN h.NIVEL_PRESA_PORCENTAJE > 50 THEN 'Buena'
                WHEN h.NIVEL_PRESA_PORCENTAJE > 30 THEN 'Regular'
                ELSE 'Crítica'
            END AS EFICIENCIA_HIDRICA
            
        FROM {self.database}.{self.schema}.FACT_CONSUMO_DIARIO f
        JOIN {self.database}.{self.schema}.DIM_CLIENTES c 
            ON f.ID_CLIENTE = c.ID_CLIENTE
        LEFT JOIN {self.database}.{self.schema}.DIM_CONDICIONES_HIDROCLIMATICAS h 
            ON f.FECHA = h.FECHA
        LEFT JOIN {self.database}.{self.schema}.DIM_CONDICIONES_MERCADO m 
            ON f.FECHA = m.FECHA
        """
        
        return self.execute_sql(sql, "Vista de Analytics Integral")
    
    def create_all_views(self):
        """Crea todas las vistas analíticas"""
        print("🚀 Iniciando creación de vistas analíticas para Fénix Energía")
        print("=" * 60)
        
        views_created = 0
        total_views = 5
        
        # Lista de vistas a crear
        views = [
            ("VW_ANALISIS_CONSUMO", self.create_consumption_analysis_view),
            ("VW_IMPACTO_CLIMATICO", self.create_climate_impact_view),
            ("VW_CONDICIONES_MERCADO", self.create_market_conditions_view),
            ("VW_DASHBOARD_EFICIENCIA", self.create_efficiency_dashboard_view),
            ("VW_ANALYTICS_INTEGRAL", self.create_comprehensive_analytics_view)
        ]
        
        for view_name, create_function in views:
            if create_function():
                views_created += 1
                print(f"✅ {view_name} creada exitosamente")
            else:
                print(f"❌ Error creando {view_name}")
        
        print("=" * 60)
        print(f"📊 Resumen: {views_created}/{total_views} vistas creadas exitosamente")
        
        if views_created == total_views:
            print("🎉 ¡Todas las vistas fueron creadas correctamente!")
            self.print_usage_examples()
        
        return views_created == total_views
    
    def print_usage_examples(self):
        """Imprime ejemplos de uso de las vistas creadas"""
        print("\n📋 EJEMPLOS DE USO DE LAS VISTAS CREADAS:")
        print("=" * 60)
        
        examples = [
            {
                "title": "1. Análisis de Consumo por Estado",
                "sql": f"SELECT ESTADO, SUM(CONSUMO_MWH) as TOTAL_MWH FROM {self.database}.{self.schema}.VW_ANALISIS_CONSUMO GROUP BY ESTADO ORDER BY TOTAL_MWH DESC;"
            },
            {
                "title": "2. Impacto Climático en Consumo",
                "sql": f"SELECT CATEGORIA_TEMPERATURA, AVG(CONSUMO_TOTAL_MWH) as PROMEDIO_CONSUMO FROM {self.database}.{self.schema}.VW_IMPACTO_CLIMATICO GROUP BY CATEGORIA_TEMPERATURA;"
            },
            {
                "title": "3. Correlación Mercado-Precios",
                "sql": f"SELECT ESTADO_INFLACION, AVG(PRECIO_PROMEDIO_MXN) as PRECIO_PROMEDIO FROM {self.database}.{self.schema}.VW_CONDICIONES_MERCADO GROUP BY ESTADO_INFLACION;"
            },
            {
                "title": "4. Dashboard de Eficiencia Top 5",
                "sql": f"SELECT ESTADO, INDUSTRIA, CONSUMO_TOTAL_MWH, RANKING_CONSUMO FROM {self.database}.{self.schema}.VW_DASHBOARD_EFICIENCIA WHERE RANKING_CONSUMO <= 5;"
            },
            {
                "title": "5. Analytics Integral - Demanda Climática",
                "sql": f"SELECT TIPO_DEMANDA, COUNT(*) as FRECUENCIA, AVG(CONSUMO_MWH) as CONSUMO_PROMEDIO FROM {self.database}.{self.schema}.VW_ANALYTICS_INTEGRAL GROUP BY TIPO_DEMANDA;"
            }
        ]
        
        for example in examples:
            print(f"\n{example['title']}:")
            print(f"SQL: {example['sql']}")
    
    def close_connection(self):
        """Cierra la conexión con Snowflake"""
        if hasattr(self, 'cursor'):
            self.cursor.close()
        if hasattr(self, 'conn'):
            self.conn.close()
        print("🔌 Conexión cerrada")


def main():
    """Función principal para ejecutar la creación de vistas"""
    
    # Configuración de conexión (actualizar con tus credenciales)
    connection_params = {
        'user': os.getenv('SNOWFLAKE_USER', 'tu_usuario'),
        'password': os.getenv('SNOWFLAKE_PASSWORD', 'tu_password'),
        'account': os.getenv('SNOWFLAKE_ACCOUNT', 'tu_account'),
        'warehouse': os.getenv('SNOWFLAKE_WAREHOUSE', 'FENIX_WH'),
        'database': os.getenv('SNOWFLAKE_DATABASE', 'FENIX_DB'),
        'schema': os.getenv('SNOWFLAKE_SCHEMA', 'FENIX_ENERGY_SCHEMA'),
        'role': os.getenv('SNOWFLAKE_ROLE', 'FENIX_ANALYST_ROLE')
    }
    
    # Crear instancia del creador de vistas
    view_creator = FenixEnergiaViewCreator(connection_params)
    
    try:
        # Conectar a Snowflake
        if view_creator.connect():
            # Crear todas las vistas
            view_creator.create_all_views()
        else:
            print("❌ No se pudo establecer conexión con Snowflake")
            
    except Exception as e:
        print(f"❌ Error general: {e}")
        
    finally:
        # Cerrar conexión
        view_creator.close_connection()


if __name__ == "__main__":
    print("🏭 CREADOR DE VISTAS ANALÍTICAS - FÉNIX ENERGÍA")
    print("=" * 60)
    print("📅 Fecha de ejecución:", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    print("🎯 Objetivo: Crear vistas para análisis energético en México")
    print("=" * 60)
    
    main()


