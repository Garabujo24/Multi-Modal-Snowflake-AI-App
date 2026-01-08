"""
Generador de CSV de Metadatos de Constancias
Cliente: Unstructured Docs
Propósito: Exportar metadatos para análisis y carga a bases de datos
"""

import csv
import json
from datetime import datetime

# Datos de las constancias (mismo dataset del generador principal)
CONTRIBUYENTES = [
    {
        "numero": 1,
        "tipo": "Persona Moral",
        "nombre": "TECNOLOGÍA AVANZADA DEL SURESTE SA DE CV",
        "rfc": "TAS180523KL8",
        "curp": None,
        "regimen": "601 - General de Ley Personas Morales",
        "estado": "Yucatán",
        "municipio": "Mérida",
        "colonia": "Montejo",
        "calle": "Paseo de Montejo",
        "num_ext": "485",
        "num_int": "Piso 3",
        "cp": "97000",
        "correo": "contacto@tecnologiasureste.com.mx",
        "fecha_inicio": "2018-05-23",
        "sector": "Tecnología"
    },
    {
        "numero": 2,
        "tipo": "Persona Física",
        "nombre": "MARÍA GUADALUPE HERNÁNDEZ SÁNCHEZ",
        "rfc": "HESM850614J39",
        "curp": "HESM850614MDFRNR09",
        "regimen": "612 - Personas Físicas con Actividades Empresariales y Profesionales",
        "estado": "Jalisco",
        "municipio": "Guadalajara",
        "colonia": "Americana",
        "calle": "Avenida Américas",
        "num_ext": "1234",
        "num_int": None,
        "cp": "44160",
        "correo": "mhernandez@consultora.mx",
        "fecha_inicio": "2010-03-15",
        "sector": "Servicios Profesionales"
    },
    {
        "numero": 3,
        "tipo": "Persona Moral",
        "nombre": "COMERCIALIZADORA DE ALIMENTOS DEL NORTE SA DE CV",
        "rfc": "CAN200815RT6",
        "curp": None,
        "regimen": "601 - General de Ley Personas Morales",
        "estado": "Nuevo León",
        "municipio": "Monterrey",
        "colonia": "San Pedro",
        "calle": "Avenida Gómez Morín",
        "num_ext": "2450",
        "num_int": "Suite 100",
        "cp": "66260",
        "correo": "ventas@alimentosnorte.mx",
        "fecha_inicio": "2020-08-15",
        "sector": "Alimentos"
    },
    {
        "numero": 4,
        "tipo": "Persona Física",
        "nombre": "JOSÉ ROBERTO GARCÍA LÓPEZ",
        "rfc": "GALR920327HG5",
        "curp": "GALR920327HDFRPS06",
        "regimen": "626 - Régimen Simplificado de Confianza",
        "estado": "Ciudad de México",
        "municipio": "Benito Juárez",
        "colonia": "Del Valle",
        "calle": "Eje 7 Sur",
        "num_ext": "678",
        "num_int": "Int 4",
        "cp": "03100",
        "correo": "jrgarcia@servicios.com",
        "fecha_inicio": "2022-01-01",
        "sector": "Servicios"
    },
    {
        "numero": 5,
        "tipo": "Persona Moral",
        "nombre": "CONSTRUCTORA INDUSTRIAL BAJÍO SA DE CV",
        "rfc": "CIB150309MN2",
        "curp": None,
        "regimen": "601 - General de Ley Personas Morales",
        "estado": "Guanajuato",
        "municipio": "León",
        "colonia": "Industrial",
        "calle": "Boulevard Aeropuerto",
        "num_ext": "3890",
        "num_int": None,
        "cp": "37290",
        "correo": "administracion@cibajio.mx",
        "fecha_inicio": "2015-03-09",
        "sector": "Construcción"
    },
    {
        "numero": 6,
        "tipo": "Persona Física",
        "nombre": "ANA PATRICIA MARTÍNEZ RODRÍGUEZ",
        "rfc": "MARA881205QT7",
        "curp": "MARA881205MSLRDN02",
        "regimen": "605 - Sueldos y Salarios e Ingresos Asimilados a Salarios",
        "estado": "Puebla",
        "municipio": "Puebla",
        "colonia": "Angelópolis",
        "calle": "Avenida Atlixcáyotl",
        "num_ext": "5600",
        "num_int": "Depto 302",
        "cp": "72830",
        "correo": "anamartinez@email.com",
        "fecha_inicio": "2015-06-01",
        "sector": "Empleado"
    },
    {
        "numero": 7,
        "tipo": "Persona Moral",
        "nombre": "SERVICIOS LOGÍSTICOS DEL PACÍFICO SA DE CV",
        "rfc": "SLP190722BC4",
        "curp": None,
        "regimen": "601 - General de Ley Personas Morales",
        "estado": "Sinaloa",
        "municipio": "Culiacán",
        "colonia": "Desarrollo Urbano Tres Ríos",
        "calle": "Boulevard Emiliano Zapata",
        "num_ext": "1500",
        "num_int": None,
        "cp": "80020",
        "correo": "operaciones@logisticapacifico.mx",
        "fecha_inicio": "2019-07-22",
        "sector": "Logística"
    },
    {
        "numero": 8,
        "tipo": "Persona Física",
        "nombre": "CARLOS EDUARDO RAMÍREZ FERNÁNDEZ",
        "rfc": "RAFC900518KP9",
        "curp": "RAFC900518HQTMRR04",
        "regimen": "612 - Personas Físicas con Actividades Empresariales y Profesionales",
        "estado": "Querétaro",
        "municipio": "Querétaro",
        "colonia": "Centro Sur",
        "calle": "Avenida Constituyentes",
        "num_ext": "89",
        "num_int": "Local 5",
        "cp": "76090",
        "correo": "cramirez.arquitecto@gmail.com",
        "fecha_inicio": "2016-08-10",
        "sector": "Servicios Profesionales"
    },
    {
        "numero": 9,
        "tipo": "Persona Moral",
        "nombre": "DESARROLLOS INMOBILIARIOS CANCÚN SA DE CV",
        "rfc": "DIC170411XY8",
        "curp": None,
        "regimen": "601 - General de Ley Personas Morales",
        "estado": "Quintana Roo",
        "municipio": "Benito Juárez",
        "colonia": "Supermanzana 15",
        "calle": "Avenida Tulum",
        "num_ext": "245",
        "num_int": "Oficina 12",
        "cp": "77500",
        "correo": "info@inmobiliariacancun.com.mx",
        "fecha_inicio": "2017-04-11",
        "sector": "Inmobiliario"
    },
    {
        "numero": 10,
        "tipo": "Persona Física",
        "nombre": "LAURA ISABEL TORRES MENDOZA",
        "rfc": "TOML870923FM2",
        "curp": "TOML870923MCSRND08",
        "regimen": "621 - Incorporación Fiscal",
        "estado": "Veracruz",
        "municipio": "Xalapa",
        "colonia": "Rafael Lucio",
        "calle": "Calle Úrsulo Galván",
        "num_ext": "34",
        "num_int": None,
        "cp": "91110",
        "correo": "lauratorres.asesoria@hotmail.com",
        "fecha_inicio": "2018-09-01",
        "sector": "Servicios Profesionales"
    },
    {
        "numero": 11,
        "tipo": "Persona Moral",
        "nombre": "MANUFACTURAS TEXTILES DE OCCIDENTE SA DE CV",
        "rfc": "MTO140627GH3",
        "curp": None,
        "regimen": "601 - General de Ley Personas Morales",
        "estado": "Jalisco",
        "municipio": "Tlaquepaque",
        "colonia": "La Guadalupana",
        "calle": "Carretera a Chapala",
        "num_ext": "6700",
        "num_int": None,
        "cp": "45588",
        "correo": "compras@textiloccidente.mx",
        "fecha_inicio": "2014-06-27",
        "sector": "Textil"
    },
    {
        "numero": 12,
        "tipo": "Persona Física",
        "nombre": "FERNANDO JAVIER LÓPEZ CASTILLO",
        "rfc": "LOCF830712MK6",
        "curp": "LOCF830712HSLPSR03",
        "regimen": "626 - Régimen Simplificado de Confianza",
        "estado": "San Luis Potosí",
        "municipio": "San Luis Potosí",
        "colonia": "Tangamanga",
        "calle": "Avenida Venustiano Carranza",
        "num_ext": "2315",
        "num_int": None,
        "cp": "78269",
        "correo": "flopez@servicioscontables.mx",
        "fecha_inicio": "2022-01-01",
        "sector": "Servicios Contables"
    },
    {
        "numero": 13,
        "tipo": "Persona Moral",
        "nombre": "EXPORTADORA AGRÍCOLA DE SONORA SA DE CV",
        "rfc": "EAS160105PL9",
        "curp": None,
        "regimen": "601 - General de Ley Personas Morales",
        "estado": "Sonora",
        "municipio": "Hermosillo",
        "colonia": "San Benito",
        "calle": "Boulevard Luis Encinas",
        "num_ext": "890",
        "num_int": None,
        "cp": "83190",
        "correo": "exportaciones@agricolasonora.mx",
        "fecha_inicio": "2016-01-05",
        "sector": "Agricultura"
    }
]

def generar_csv():
    """Genera archivo CSV con metadatos de todas las constancias"""
    
    filename = "output/metadatos_constancias.csv"
    
    # Definir campos del CSV
    campos = [
        'NUMERO',
        'ARCHIVO_PDF',
        'RFC',
        'NOMBRE_CONTRIBUYENTE',
        'TIPO_PERSONA',
        'CURP',
        'REGIMEN_FISCAL',
        'CODIGO_REGIMEN',
        'SECTOR',
        'ESTADO',
        'MUNICIPIO',
        'COLONIA',
        'CALLE',
        'NUMERO_EXTERIOR',
        'NUMERO_INTERIOR',
        'CODIGO_POSTAL',
        'CORREO_ELECTRONICO',
        'FECHA_INICIO_OPERACIONES',
        'AÑOS_OPERANDO',
        'ESTATUS',
        'FECHA_GENERACION'
    ]
    
    with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=campos)
        writer.writeheader()
        
        for contrib in CONTRIBUYENTES:
            # Calcular años de operación
            fecha_inicio = datetime.strptime(contrib['fecha_inicio'], '%Y-%m-%d')
            años_operando = (datetime.now() - fecha_inicio).days // 365
            
            # Extraer código de régimen
            codigo_regimen = contrib['regimen'].split(' ')[0]
            
            # Construir dirección de número interior
            num_interior = contrib['num_int'] if contrib['num_int'] else ''
            
            writer.writerow({
                'NUMERO': contrib['numero'],
                'ARCHIVO_PDF': f"CSF_{contrib['numero']:02d}_{contrib['rfc']}.pdf",
                'RFC': contrib['rfc'],
                'NOMBRE_CONTRIBUYENTE': contrib['nombre'],
                'TIPO_PERSONA': contrib['tipo'],
                'CURP': contrib['curp'] if contrib['curp'] else '',
                'REGIMEN_FISCAL': contrib['regimen'],
                'CODIGO_REGIMEN': codigo_regimen,
                'SECTOR': contrib['sector'],
                'ESTADO': contrib['estado'],
                'MUNICIPIO': contrib['municipio'],
                'COLONIA': contrib['colonia'],
                'CALLE': contrib['calle'],
                'NUMERO_EXTERIOR': contrib['num_ext'],
                'NUMERO_INTERIOR': num_interior,
                'CODIGO_POSTAL': contrib['cp'],
                'CORREO_ELECTRONICO': contrib['correo'],
                'FECHA_INICIO_OPERACIONES': contrib['fecha_inicio'],
                'AÑOS_OPERANDO': años_operando,
                'ESTATUS': 'ACTIVO',
                'FECHA_GENERACION': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            })
    
    print(f"✓ CSV generado: {filename}")
    print(f"  Registros: {len(CONTRIBUYENTES)}")
    print(f"  Campos: {len(campos)}")
    
    return filename

def generar_json():
    """Genera archivo JSON con metadatos enriquecidos"""
    
    filename = "output/metadatos_constancias.json"
    
    datos_json = []
    
    for contrib in CONTRIBUYENTES:
        # Calcular años de operación
        fecha_inicio = datetime.strptime(contrib['fecha_inicio'], '%Y-%m-%d')
        años_operando = (datetime.now() - fecha_inicio).days // 365
        
        # Construir objeto JSON enriquecido
        obj = {
            "id": contrib['numero'],
            "archivo": f"CSF_{contrib['numero']:02d}_{contrib['rfc']}.pdf",
            "identificacion": {
                "rfc": contrib['rfc'],
                "curp": contrib['curp'],
                "nombre": contrib['nombre'],
                "tipo": contrib['tipo']
            },
            "regimen_fiscal": {
                "codigo": contrib['regimen'].split(' ')[0],
                "descripcion": contrib['regimen']
            },
            "domicilio": {
                "calle": contrib['calle'],
                "numero_exterior": contrib['num_ext'],
                "numero_interior": contrib['num_int'],
                "colonia": contrib['colonia'],
                "codigo_postal": contrib['cp'],
                "municipio": contrib['municipio'],
                "estado": contrib['estado']
            },
            "contacto": {
                "correo": contrib['correo']
            },
            "datos_operativos": {
                "fecha_inicio": contrib['fecha_inicio'],
                "años_operando": años_operando,
                "sector": contrib['sector'],
                "estatus": "ACTIVO"
            },
            "metadata": {
                "fecha_generacion": datetime.now().isoformat(),
                "version": "1.0",
                "proposito": "Pruebas Cortex Search"
            }
        }
        
        datos_json.append(obj)
    
    with open(filename, 'w', encoding='utf-8') as jsonfile:
        json.dump(datos_json, jsonfile, ensure_ascii=False, indent=2)
    
    print(f"✓ JSON generado: {filename}")
    print(f"  Registros: {len(datos_json)}")
    
    return filename

def generar_estadisticas():
    """Genera un resumen estadístico de las constancias"""
    
    print("\n" + "="*70)
    print("ESTADÍSTICAS DE CONSTANCIAS GENERADAS")
    print("="*70)
    
    # Por tipo de persona
    tipos = {}
    for c in CONTRIBUYENTES:
        tipos[c['tipo']] = tipos.get(c['tipo'], 0) + 1
    
    print("\n📊 Por Tipo de Persona:")
    for tipo, count in tipos.items():
        print(f"  • {tipo}: {count} ({count/len(CONTRIBUYENTES)*100:.1f}%)")
    
    # Por estado
    estados = {}
    for c in CONTRIBUYENTES:
        estados[c['estado']] = estados.get(c['estado'], 0) + 1
    
    print("\n📍 Por Estado:")
    for estado, count in sorted(estados.items(), key=lambda x: x[1], reverse=True):
        print(f"  • {estado}: {count}")
    
    # Por régimen
    regimenes = {}
    for c in CONTRIBUYENTES:
        codigo = c['regimen'].split(' ')[0]
        regimenes[codigo] = regimenes.get(codigo, 0) + 1
    
    print("\n💼 Por Régimen Fiscal:")
    for regimen, count in sorted(regimenes.items()):
        print(f"  • Régimen {regimen}: {count}")
    
    # Por sector
    sectores = {}
    for c in CONTRIBUYENTES:
        sectores[c['sector']] = sectores.get(c['sector'], 0) + 1
    
    print("\n🏭 Por Sector:")
    for sector, count in sorted(sectores.items(), key=lambda x: x[1], reverse=True):
        print(f"  • {sector}: {count}")
    
    print("\n" + "="*70)

def main():
    """Función principal"""
    print("="*70)
    print("GENERADOR DE METADATOS DE CONSTANCIAS")
    print("Cliente: Unstructured Docs")
    print("="*70)
    print()
    
    # Generar archivos
    generar_csv()
    generar_json()
    
    # Mostrar estadísticas
    generar_estadisticas()
    
    print()
    print("✓ Archivos generados en la carpeta output/")
    print("  - metadatos_constancias.csv (formato tabular)")
    print("  - metadatos_constancias.json (formato jerárquico)")
    print()
    print("Estos archivos pueden usarse para:")
    print("  • Importar a Snowflake con COPY INTO")
    print("  • Análisis en Excel/Power BI")
    print("  • Integración con APIs")
    print("  • Documentación del dataset")
    print("="*70)

if __name__ == "__main__":
    main()



