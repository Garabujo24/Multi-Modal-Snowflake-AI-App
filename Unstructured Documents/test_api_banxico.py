"""
Script de Prueba - API de Banxico
Cliente: Unstructured Docs
Propósito: Probar la API de Banxico antes de implementar en Snowflake

API: https://www.banxico.org.mx/SieAPIRest/service/v1/
Documentación: https://www.banxico.org.mx/SieAPIRest/service/v1/doc/introduccion

IMPORTANTE: Necesitas obtener un token gratuito en:
https://www.banxico.org.mx/SieAPIRest/service/v1/token
"""

import requests
import json
from datetime import datetime, timedelta
import pandas as pd

# ============================================================================
# CONFIGURACIÓN
# ============================================================================

# IMPORTANTE: Reemplaza con tu token de Banxico
TOKEN_BANXICO = "TU_TOKEN_AQUI"

# URL base de la API
BASE_URL = "https://www.banxico.org.mx/SieAPIRest/service/v1/series"

# Serie del tipo de cambio FIX (Pesos por Dólar)
SERIE_TIPO_CAMBIO = "SF43718"

# ============================================================================
# FUNCIONES
# ============================================================================

def obtener_token_instrucciones():
    """Muestra instrucciones para obtener el token"""
    print("="*70)
    print("CÓMO OBTENER TU TOKEN DE BANXICO (GRATIS)")
    print("="*70)
    print()
    print("1. Visita: https://www.banxico.org.mx/SieAPIRest/service/v1/token")
    print("2. Llena el formulario con tu correo electrónico")
    print("3. Recibirás el token por correo electrónico")
    print("4. Copia el token y reemplaza 'TU_TOKEN_AQUI' en este script")
    print()
    print("El token es gratuito y permite hasta 1000 peticiones por día.")
    print("="*70)
    print()

def consultar_tipo_cambio(fecha_inicio, fecha_fin, token):
    """
    Consulta el tipo de cambio de Banxico para un rango de fechas
    
    Args:
        fecha_inicio (str): Fecha inicial en formato YYYY-MM-DD
        fecha_fin (str): Fecha final en formato YYYY-MM-DD
        token (str): Token de autenticación de Banxico
    
    Returns:
        dict: Respuesta JSON de la API o None si hay error
    """
    
    # Construir URL
    url = f"{BASE_URL}/{SERIE_TIPO_CAMBIO}/datos/{fecha_inicio}/{fecha_fin}"
    
    # Headers con token
    headers = {
        'Bmx-Token': token,
        'Accept': 'application/json'
    }
    
    print(f"📡 Consultando API de Banxico...")
    print(f"   URL: {url}")
    print(f"   Periodo: {fecha_inicio} a {fecha_fin}")
    print()
    
    try:
        response = requests.get(url, headers=headers, timeout=30)
        
        if response.status_code == 200:
            print("✅ Conexión exitosa con Banxico")
            return response.json()
        elif response.status_code == 401:
            print("❌ ERROR: Token inválido o expirado")
            print("   Verifica tu token en la configuración")
            return None
        elif response.status_code == 404:
            print("❌ ERROR: Serie o fechas no encontradas")
            return None
        else:
            print(f"❌ ERROR: Código de estado {response.status_code}")
            print(f"   Respuesta: {response.text}")
            return None
            
    except requests.exceptions.Timeout:
        print("❌ ERROR: Timeout al conectar con Banxico")
        return None
    except requests.exceptions.RequestException as e:
        print(f"❌ ERROR de conexión: {e}")
        return None
    except Exception as e:
        print(f"❌ ERROR inesperado: {e}")
        return None

def procesar_respuesta(data):
    """
    Procesa la respuesta JSON de Banxico y extrae los datos relevantes
    
    Args:
        data (dict): Respuesta JSON de la API
    
    Returns:
        list: Lista de diccionarios con fecha y tipo de cambio
    """
    
    if not data or 'bmx' not in data:
        print("⚠️  Respuesta vacía o inválida")
        return []
    
    try:
        series = data['bmx']['series'][0]
        datos = series['datos']
        
        print(f"\n📊 Datos recibidos:")
        print(f"   Serie: {series['idSerie']} - {series['titulo']}")
        print(f"   Registros: {len(datos)}")
        print()
        
        # Procesar y limpiar datos
        resultados = []
        for dato in datos:
            fecha = dato['fecha']
            valor = dato['dato']
            
            # Saltar valores N/E (No Existe)
            if valor == 'N/E':
                continue
            
            # Convertir fecha de dd/MM/yyyy a yyyy-MM-dd
            fecha_parts = fecha.split('/')
            fecha_iso = f"{fecha_parts[2]}-{fecha_parts[1]}-{fecha_parts[0]}"
            
            resultados.append({
                'fecha': fecha_iso,
                'fecha_original': fecha,
                'tipo_cambio': float(valor)
            })
        
        return resultados
        
    except (KeyError, IndexError) as e:
        print(f"❌ ERROR al procesar respuesta: {e}")
        return []

def mostrar_resultados(resultados):
    """Muestra los resultados en formato tabla"""
    
    if not resultados:
        print("No hay resultados para mostrar")
        return
    
    print("="*70)
    print("TIPOS DE CAMBIO - BANXICO (Pesos por Dólar)")
    print("="*70)
    print()
    
    # Crear DataFrame para mejor visualización
    df = pd.DataFrame(resultados)
    df['fecha'] = pd.to_datetime(df['fecha'])
    df = df.sort_values('fecha', ascending=False)
    
    # Calcular estadísticas
    tc_actual = df.iloc[0]['tipo_cambio']
    tc_anterior = df.iloc[1]['tipo_cambio'] if len(df) > 1 else tc_actual
    variacion = tc_actual - tc_anterior
    variacion_pct = (variacion / tc_anterior * 100) if tc_anterior != 0 else 0
    
    # Mostrar resumen
    print(f"💵 Tipo de Cambio Más Reciente:")
    print(f"   Fecha: {df.iloc[0]['fecha'].strftime('%Y-%m-%d')}")
    print(f"   Valor: ${tc_actual:.6f} MXN por USD")
    print(f"   Variación: {variacion:+.6f} ({variacion_pct:+.2f}%)")
    print()
    
    print(f"📊 Estadísticas del Periodo:")
    print(f"   Mínimo: ${df['tipo_cambio'].min():.6f}")
    print(f"   Máximo: ${df['tipo_cambio'].max():.6f}")
    print(f"   Promedio: ${df['tipo_cambio'].mean():.6f}")
    print(f"   Desv. Est.: {df['tipo_cambio'].std():.6f}")
    print()
    
    # Mostrar tabla
    print("📋 Últimos 10 registros:")
    print("-"*70)
    print(f"{'FECHA':<15} {'TIPO DE CAMBIO':>20} {'VARIACIÓN':>15}")
    print("-"*70)
    
    for i, row in df.head(10).iterrows():
        tc = row['tipo_cambio']
        
        # Calcular variación respecto al día anterior
        if i + 1 < len(df):
            tc_prev = df.iloc[i + 1]['tipo_cambio']
            var = tc - tc_prev
            var_str = f"{var:+.4f}"
        else:
            var_str = "-"
        
        print(f"{row['fecha'].strftime('%Y-%m-%d'):<15} ${tc:>18.6f} {var_str:>15}")
    
    print("-"*70)
    print()

def guardar_csv(resultados, filename="tipo_cambio_banxico.csv"):
    """Guarda los resultados en un archivo CSV"""
    
    if not resultados:
        print("No hay datos para guardar")
        return
    
    df = pd.DataFrame(resultados)
    df.to_csv(filename, index=False)
    print(f"✅ Datos guardados en: {filename}")
    print()

def ejemplos_conversion(tipo_cambio):
    """Muestra ejemplos de conversión de moneda"""
    
    print("="*70)
    print("EJEMPLOS DE CONVERSIÓN")
    print("="*70)
    print()
    
    # USD a MXN
    print("💵 Dólares (USD) a Pesos (MXN):")
    for usd in [100, 500, 1000, 5000]:
        mxn = usd * tipo_cambio
        print(f"   ${usd:,} USD = ${mxn:,.2f} MXN")
    print()
    
    # MXN a USD
    print("💵 Pesos (MXN) a Dólares (USD):")
    for mxn in [1000, 5000, 10000, 50000]:
        usd = mxn / tipo_cambio
        print(f"   ${mxn:,} MXN = ${usd:,.2f} USD")
    print()

def consultar_series_disponibles(token):
    """Consulta el catálogo de series disponibles en Banxico"""
    
    url = "https://www.banxico.org.mx/SieAPIRest/service/v1/catalogoSeries"
    
    headers = {
        'Bmx-Token': token,
        'Accept': 'application/json'
    }
    
    print("📚 Consultando catálogo de series disponibles...")
    print()
    
    try:
        response = requests.get(url, headers=headers, timeout=30)
        
        if response.status_code == 200:
            data = response.json()
            series = data['bmx']['catalogoSeries']
            
            print(f"✅ Se encontraron {len(series)} series disponibles")
            print()
            print("🔍 Series relacionadas con tipo de cambio:")
            print("-"*70)
            
            for serie in series[:20]:  # Mostrar solo las primeras 20
                if 'cambio' in serie['titulo'].lower() or 'dolar' in serie['titulo'].lower():
                    print(f"   {serie['idSerie']}: {serie['titulo']}")
            
            print("-"*70)
            print()
        else:
            print(f"❌ Error al consultar catálogo: {response.status_code}")
    
    except Exception as e:
        print(f"❌ Error: {e}")

# ============================================================================
# FUNCIÓN PRINCIPAL
# ============================================================================

def main():
    """Función principal"""
    
    print("\n")
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║                                                                      ║")
    print("║           PRUEBA DE API DE BANXICO - TIPO DE CAMBIO                 ║")
    print("║                                                                      ║")
    print("║              Cliente: Unstructured Docs                              ║")
    print("║                                                                      ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    # Verificar token
    if TOKEN_BANXICO == "TU_TOKEN_AQUI" or not TOKEN_BANXICO:
        obtener_token_instrucciones()
        print("⚠️  IMPORTANTE: Configura tu token antes de continuar")
        print()
        return
    
    # Definir periodo de consulta (últimos 30 días)
    fecha_fin = datetime.now()
    fecha_inicio = fecha_fin - timedelta(days=30)
    
    fecha_inicio_str = fecha_inicio.strftime('%Y-%m-%d')
    fecha_fin_str = fecha_fin.strftime('%Y-%m-%d')
    
    # Consultar API
    data = consultar_tipo_cambio(fecha_inicio_str, fecha_fin_str, TOKEN_BANXICO)
    
    if data:
        # Procesar resultados
        resultados = procesar_respuesta(data)
        
        if resultados:
            # Mostrar resultados
            mostrar_resultados(resultados)
            
            # Guardar CSV
            guardar_csv(resultados)
            
            # Ejemplos de conversión
            tipo_cambio_actual = resultados[0]['tipo_cambio']
            ejemplos_conversion(tipo_cambio_actual)
            
            # Instrucciones para Snowflake
            print("="*70)
            print("PRÓXIMOS PASOS - IMPLEMENTAR EN SNOWFLAKE")
            print("="*70)
            print()
            print("1. Abre Snowsight y carga el archivo: banxico_tipo_cambio.sql")
            print()
            print("2. Actualiza el token en Snowflake:")
            print("   UPDATE CONFIG_API_BANXICO")
            print(f"   SET VALOR = '{TOKEN_BANXICO}'")
            print("   WHERE PARAMETRO = 'TOKEN_API';")
            print()
            print("3. Ejecuta el stored procedure:")
            print("   CALL SP_CONSULTAR_TIPO_CAMBIO_BANXICO(")
            print(f"       '{fecha_inicio_str}',")
            print(f"       '{fecha_fin_str}',")
            print(f"       '{TOKEN_BANXICO}'")
            print("   );")
            print()
            print("4. Verifica los datos:")
            print("   SELECT * FROM TIPO_CAMBIO_BANXICO")
            print("   ORDER BY FECHA DESC;")
            print()
            print("="*70)
            print()
            
            # Opcional: consultar series disponibles
            respuesta = input("¿Deseas ver el catálogo de series disponibles? (s/n): ")
            if respuesta.lower() == 's':
                print()
                consultar_series_disponibles(TOKEN_BANXICO)
        
        print("✅ Prueba completada exitosamente")
        print()
    else:
        print("❌ No se pudieron obtener datos")
        print()
        obtener_token_instrucciones()

if __name__ == "__main__":
    main()



