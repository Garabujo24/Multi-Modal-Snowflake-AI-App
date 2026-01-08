#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
SEGUROS CENTINELA - Generador de Pólizas PDF
=============================================
Genera 40 pólizas de Seguro de Automóviles y 40 de GMM en formato PDF
con datos realistas y diseño profesional.

Autor: Ingeniero de Datos
Fecha: 2024
"""

import os
import random
from datetime import datetime, timedelta
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch, cm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT, TA_JUSTIFY

# ============================================================================
# CONFIGURACIÓN
# ============================================================================
OUTPUT_DIR_AUTO = "../polizas/autos"
OUTPUT_DIR_GMM = "../polizas/gmm"

# Colores corporativos de Seguros Centinela
COLOR_PRIMARIO = colors.HexColor("#1B4F72")  # Azul oscuro
COLOR_SECUNDARIO = colors.HexColor("#2E86AB")  # Azul medio
COLOR_ACENTO = colors.HexColor("#F39C12")  # Dorado
COLOR_GRIS = colors.HexColor("#566573")

# ============================================================================
# DATOS BASE PARA GENERACIÓN
# ============================================================================

# Nombres y apellidos mexicanos realistas
NOMBRES_MASCULINOS = [
    "Juan", "Carlos", "Miguel", "Roberto", "José", "Fernando", "Alejandro", 
    "Ricardo", "Eduardo", "Arturo", "Gerardo", "Pablo", "Andrés", "Víctor",
    "Héctor", "Raúl", "Sergio", "Mario", "Oscar", "Felipe", "Guillermo",
    "Javier", "Daniel", "Rafael", "Tomás", "Ernesto", "Adrián", "Samuel"
]

NOMBRES_FEMENINOS = [
    "María", "Ana", "Patricia", "Laura", "Gabriela", "Sandra", "Mónica",
    "Claudia", "Diana", "Verónica", "Beatriz", "Adriana", "Karla", "Teresa",
    "Alicia", "Silvia", "Norma", "Leticia", "Rosa", "Carmen", "Elena",
    "Margarita", "Gloria", "Yolanda", "Lorena", "Cecilia", "Vanessa", "Paola"
]

APELLIDOS = [
    "Pérez", "García", "López", "Hernández", "Martínez", "González", "Rodríguez",
    "Sánchez", "Ramírez", "Torres", "Flores", "Rivera", "Morales", "Díaz",
    "Reyes", "Cruz", "Ortiz", "Gutiérrez", "Mendoza", "Ruiz", "Aguilar",
    "Vargas", "Medina", "Castro", "Jiménez", "Herrera", "Vega", "Núñez",
    "Cervantes", "Pacheco", "Miranda", "Fuentes", "Salazar", "Lara", "Contreras"
]

ESTADOS_MEXICO = [
    ("Ciudad de México", "CDMX", ["Benito Juárez", "Coyoacán", "Miguel Hidalgo", "Cuauhtémoc", "Tlalpan"]),
    ("Jalisco", "JAL", ["Guadalajara", "Zapopan", "Tlaquepaque", "Tonalá"]),
    ("Nuevo León", "NL", ["Monterrey", "San Pedro Garza García", "San Nicolás", "Apodaca"]),
    ("Puebla", "PUE", ["Puebla", "Cholula", "Atlixco", "Tehuacán"]),
    ("Querétaro", "QRO", ["Querétaro", "San Juan del Río", "Corregidora"]),
    ("Guanajuato", "GTO", ["León", "Irapuato", "Celaya", "Guanajuato"])
]

COLONIAS = [
    "Del Valle", "Roma Norte", "Polanco", "Condesa", "Narvarte", "Portales",
    "San Ángel", "Coyoacán Centro", "Santa Fe", "Lomas de Chapultepec",
    "Americana", "Providencia", "Country Club", "Centro", "Jardines del Moral"
]

# Datos de vehículos
VEHICULOS_AUTO = [
    {"marca": "Nissan", "modelos": [("Sentra", "Sedan", 340000, 420000), ("Kicks", "SUV", 380000, 460000), ("Versa", "Sedan", 280000, 350000), ("X-Trail", "SUV", 580000, 720000)]},
    {"marca": "Volkswagen", "modelos": [("Jetta", "Sedan", 420000, 520000), ("Tiguan", "SUV", 620000, 780000), ("Taos", "SUV", 520000, 650000), ("Passat", "Sedan", 580000, 720000)]},
    {"marca": "Toyota", "modelos": [("Corolla", "Sedan", 380000, 480000), ("Camry", "Sedan", 580000, 720000), ("RAV4", "SUV", 650000, 820000), ("Yaris", "Sedan", 300000, 380000)]},
    {"marca": "Honda", "modelos": [("Civic", "Sedan", 420000, 540000), ("CR-V", "SUV", 620000, 780000), ("HR-V", "SUV", 450000, 560000), ("Accord", "Sedan", 620000, 780000)]},
    {"marca": "Mazda", "modelos": [("3", "Sedan", 420000, 540000), ("CX-5", "SUV", 550000, 700000), ("CX-30", "SUV", 480000, 580000), ("6", "Sedan", 520000, 650000)]},
    {"marca": "Chevrolet", "modelos": [("Equinox", "SUV", 520000, 650000), ("Tracker", "SUV", 380000, 480000), ("Cheyenne", "Pickup", 980000, 1250000)]},
    {"marca": "Ford", "modelos": [("Escape", "SUV", 580000, 720000), ("Ranger", "Pickup", 680000, 850000), ("Bronco Sport", "SUV", 680000, 820000)]},
    {"marca": "Kia", "modelos": [("Sportage", "SUV", 480000, 600000), ("Seltos", "SUV", 420000, 520000), ("Forte", "Sedan", 380000, 480000)]},
    {"marca": "Hyundai", "modelos": [("Tucson", "SUV", 520000, 680000), ("Creta", "SUV", 400000, 500000), ("Elantra", "Sedan", 380000, 480000)]},
    {"marca": "BMW", "modelos": [("Serie 3", "Sedan", 850000, 1100000), ("X1", "SUV", 780000, 950000), ("X3", "SUV", 950000, 1200000)]},
    {"marca": "Mercedes-Benz", "modelos": [("Clase C", "Sedan", 920000, 1150000), ("GLA", "SUV", 850000, 1050000), ("Clase E", "Sedan", 1100000, 1400000)]},
    {"marca": "Audi", "modelos": [("A4", "Sedan", 780000, 950000), ("Q3", "SUV", 720000, 900000), ("A3", "Sedan", 620000, 780000)]}
]

COLORES_AUTO = ["Blanco", "Negro", "Gris Plata", "Rojo", "Azul", "Gris Oxford", "Blanco Perla", "Negro Ónix", "Plata", "Azul Metálico"]

PAQUETES_COBERTURA = [
    {"nombre": "Amplia", "descripcion": "Cobertura completa", "rc": 3000000, "gm": 500000},
    {"nombre": "Limitada", "descripcion": "Cobertura esencial", "rc": 3000000, "gm": 300000},
    {"nombre": "Premium", "descripcion": "Máxima protección", "rc": 5000000, "gm": 1000000},
    {"nombre": "RC Básica", "descripcion": "Solo responsabilidad civil", "rc": 3000000, "gm": 0}
]

# Planes GMM
PLANES_GMM = [
    {"id": "PLAN_BAS", "nombre": "Centinela Básico", "sa": 5000000, "ded": 25000, "nivel": "Estándar"},
    {"id": "PLAN_ESE", "nombre": "Centinela Esencial", "sa": 10000000, "ded": 20000, "nivel": "Ejecutivo"},
    {"id": "PLAN_PLU", "nombre": "Centinela Plus", "sa": 20000000, "ded": 15000, "nivel": "Premium"},
    {"id": "PLAN_ELI", "nombre": "Centinela Elite", "sa": 50000000, "ded": 10000, "nivel": "Premium"},
    {"id": "PLAN_FAM", "nombre": "Centinela Familiar", "sa": 15000000, "ded": 18000, "nivel": "Ejecutivo"}
]

OCUPACIONES = [
    "Ingeniero", "Médico", "Abogado", "Contador", "Arquitecto", "Empresario",
    "Director General", "Gerente", "Consultor", "Profesor", "Administrador",
    "Economista", "Diseñador", "Ejecutivo de Ventas", "Analista", "Supervisor"
]

# ============================================================================
# FUNCIONES AUXILIARES
# ============================================================================

def generar_rfc(nombre, apellido_paterno, fecha_nacimiento):
    """Genera un RFC válido basado en los datos personales."""
    rfc = apellido_paterno[:2].upper()
    rfc += nombre[0].upper()
    rfc += fecha_nacimiento.strftime("%y%m%d")
    rfc += ''.join(random.choices('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', k=3))
    return rfc

def generar_numero_serie():
    """Genera un número de serie de vehículo realista."""
    prefijos = ['3N1', 'WVW', '4T1', '7FA', 'JM3', 'KND', '3GN', '1FM', 'MAL', 'WBA', 'WDC', 'WAU']
    return random.choice(prefijos) + ''.join(random.choices('ABCDEFGHJKLMNPRSTUVWXYZ0123456789', k=14))

def generar_placas():
    """Genera placas mexicanas realistas."""
    letras = ''.join(random.choices('ABCDEFGHJKLMNPQRSTUVWXYZ', k=3))
    numeros = ''.join(random.choices('0123456789', k=4))
    return f"{letras}-{numeros[:2]}-{numeros[2:]}"

def generar_telefono():
    """Genera un número de teléfono celular mexicano."""
    ladas = ['55', '33', '81', '22', '44', '47']
    lada = random.choice(ladas)
    return f"{lada}" + ''.join(random.choices('0123456789', k=8))

def formatear_moneda(valor):
    """Formatea un valor numérico como moneda mexicana."""
    return f"${valor:,.2f} MXN"

def generar_datos_cliente():
    """Genera datos aleatorios de un cliente."""
    genero = random.choice(['M', 'F'])
    if genero == 'M':
        nombre = random.choice(NOMBRES_MASCULINOS)
    else:
        nombre = random.choice(NOMBRES_FEMENINOS)
    
    apellido_paterno = random.choice(APELLIDOS)
    apellido_materno = random.choice(APELLIDOS)
    
    # Edad entre 25 y 60 años
    edad = random.randint(25, 60)
    fecha_nac = datetime.now() - timedelta(days=edad*365 + random.randint(0, 364))
    
    estado_info = random.choice(ESTADOS_MEXICO)
    estado = estado_info[0]
    municipio = random.choice(estado_info[2])
    
    return {
        "nombre": nombre,
        "apellido_paterno": apellido_paterno,
        "apellido_materno": apellido_materno,
        "nombre_completo": f"{nombre} {apellido_paterno} {apellido_materno}",
        "genero": genero,
        "fecha_nacimiento": fecha_nac,
        "edad": edad,
        "rfc": generar_rfc(nombre, apellido_paterno, fecha_nac),
        "telefono": generar_telefono(),
        "email": f"{nombre.lower()}.{apellido_paterno.lower()}@{'gmail.com' if random.random() > 0.5 else 'outlook.com'}",
        "calle": f"Calle {random.choice(['Reforma', 'Juárez', 'Hidalgo', 'Morelos', 'Insurgentes', 'Revolución'])} #{random.randint(100, 999)}",
        "colonia": random.choice(COLONIAS),
        "codigo_postal": f"{random.randint(10, 99)}{random.randint(100, 999)}",
        "municipio": municipio,
        "estado": estado
    }

def generar_datos_vehiculo():
    """Genera datos aleatorios de un vehículo."""
    marca_info = random.choice(VEHICULOS_AUTO)
    modelo_info = random.choice(marca_info["modelos"])
    
    anio = random.randint(2020, 2024)
    valor_min, valor_max = modelo_info[2], modelo_info[3]
    valor_factura = random.randint(valor_min, valor_max)
    # Depreciación del 5-15% por año
    anios_antiguedad = 2024 - anio
    depreciacion = 1 - (anios_antiguedad * random.uniform(0.05, 0.10))
    valor_comercial = int(valor_factura * depreciacion)
    
    return {
        "marca": marca_info["marca"],
        "modelo": modelo_info[0],
        "tipo": modelo_info[1],
        "anio": anio,
        "color": random.choice(COLORES_AUTO),
        "numero_serie": generar_numero_serie(),
        "placas": generar_placas(),
        "valor_factura": valor_factura,
        "valor_comercial": valor_comercial
    }

# ============================================================================
# GENERADOR DE PDF - PÓLIZA DE AUTO
# ============================================================================

def crear_poliza_auto_pdf(numero_poliza, cliente, vehiculo, cobertura, fecha_emision, ruta_salida):
    """Crea un PDF de póliza de seguro de automóvil."""
    
    doc = SimpleDocTemplate(
        ruta_salida,
        pagesize=letter,
        rightMargin=0.75*inch,
        leftMargin=0.75*inch,
        topMargin=0.5*inch,
        bottomMargin=0.5*inch
    )
    
    elementos = []
    estilos = getSampleStyleSheet()
    
    # Estilos personalizados
    estilo_titulo = ParagraphStyle(
        'Titulo',
        parent=estilos['Heading1'],
        fontSize=18,
        textColor=COLOR_PRIMARIO,
        alignment=TA_CENTER,
        spaceAfter=12
    )
    
    estilo_subtitulo = ParagraphStyle(
        'Subtitulo',
        parent=estilos['Heading2'],
        fontSize=14,
        textColor=COLOR_SECUNDARIO,
        spaceBefore=15,
        spaceAfter=8
    )
    
    estilo_normal = ParagraphStyle(
        'Normal',
        parent=estilos['Normal'],
        fontSize=10,
        textColor=COLOR_GRIS
    )
    
    estilo_destacado = ParagraphStyle(
        'Destacado',
        parent=estilos['Normal'],
        fontSize=11,
        textColor=COLOR_PRIMARIO,
        fontName='Helvetica-Bold'
    )
    
    # === ENCABEZADO ===
    encabezado_data = [
        [
            Paragraph('<b>SEGUROS CENTINELA</b><br/><font size="9">S.A. de C.V.</font>', 
                     ParagraphStyle('Header', fontSize=16, textColor=COLOR_PRIMARIO, alignment=TA_LEFT)),
            Paragraph(f'<b>PÓLIZA DE SEGURO</b><br/><font size="9">DE AUTOMÓVIL</font>', 
                     ParagraphStyle('Header', fontSize=14, textColor=COLOR_PRIMARIO, alignment=TA_CENTER)),
            Paragraph(f'<b>No. {numero_poliza}</b><br/><font size="9">Vigente</font>', 
                     ParagraphStyle('Header', fontSize=11, textColor=COLOR_ACENTO, alignment=TA_RIGHT))
        ]
    ]
    
    tabla_encabezado = Table(encabezado_data, colWidths=[2.5*inch, 2.5*inch, 2*inch])
    tabla_encabezado.setStyle(TableStyle([
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('LINEBELOW', (0, 0), (-1, -1), 2, COLOR_PRIMARIO),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 10),
    ]))
    elementos.append(tabla_encabezado)
    elementos.append(Spacer(1, 20))
    
    # === VIGENCIA ===
    fecha_fin = fecha_emision + timedelta(days=365)
    vigencia_data = [
        ['VIGENCIA DE LA PÓLIZA', ''],
        ['Fecha de Emisión:', fecha_emision.strftime('%d/%m/%Y')],
        ['Inicio de Vigencia:', (fecha_emision + timedelta(days=1)).strftime('%d/%m/%Y a las 12:00 hrs')],
        ['Fin de Vigencia:', fecha_fin.strftime('%d/%m/%Y a las 12:00 hrs')],
    ]
    
    tabla_vigencia = Table(vigencia_data, colWidths=[2.5*inch, 4.5*inch])
    tabla_vigencia.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), COLOR_PRIMARIO),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 11),
        ('SPAN', (0, 0), (-1, 0)),
        ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
        ('FONTNAME', (0, 1), (0, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 1), (-1, -1), 9),
        ('GRID', (0, 0), (-1, -1), 0.5, COLOR_GRIS),
        ('BACKGROUND', (0, 1), (-1, -1), colors.HexColor("#F8F9FA")),
        ('PADDING', (0, 0), (-1, -1), 8),
    ]))
    elementos.append(tabla_vigencia)
    elementos.append(Spacer(1, 15))
    
    # === DATOS DEL CONTRATANTE ===
    elementos.append(Paragraph('DATOS DEL CONTRATANTE / ASEGURADO', estilo_subtitulo))
    
    cliente_data = [
        ['Nombre Completo:', cliente['nombre_completo'], 'RFC:', cliente['rfc']],
        ['Domicilio:', f"{cliente['calle']}, Col. {cliente['colonia']}", 'C.P.:', cliente['codigo_postal']],
        ['Municipio:', cliente['municipio'], 'Estado:', cliente['estado']],
        ['Teléfono:', cliente['telefono'], 'Email:', cliente['email']],
    ]
    
    tabla_cliente = Table(cliente_data, colWidths=[1.5*inch, 2.5*inch, 1*inch, 2*inch])
    tabla_cliente.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTNAME', (2, 0), (2, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('TEXTCOLOR', (0, 0), (-1, -1), COLOR_GRIS),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E0E0E0")),
        ('BACKGROUND', (0, 0), (-1, -1), colors.white),
        ('PADDING', (0, 0), (-1, -1), 6),
    ]))
    elementos.append(tabla_cliente)
    elementos.append(Spacer(1, 15))
    
    # === DATOS DEL VEHÍCULO ===
    elementos.append(Paragraph('DATOS DEL VEHÍCULO ASEGURADO', estilo_subtitulo))
    
    vehiculo_data = [
        ['Marca:', vehiculo['marca'], 'Modelo:', vehiculo['modelo']],
        ['Año:', str(vehiculo['anio']), 'Tipo:', vehiculo['tipo']],
        ['Color:', vehiculo['color'], 'Placas:', vehiculo['placas']],
        ['Número de Serie:', vehiculo['numero_serie'], '', ''],
        ['Valor Factura:', formatear_moneda(vehiculo['valor_factura']), 'Valor Comercial:', formatear_moneda(vehiculo['valor_comercial'])],
    ]
    
    tabla_vehiculo = Table(vehiculo_data, colWidths=[1.5*inch, 2*inch, 1.5*inch, 2*inch])
    tabla_vehiculo.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTNAME', (2, 0), (2, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('TEXTCOLOR', (0, 0), (-1, -1), COLOR_GRIS),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E0E0E0")),
        ('BACKGROUND', (0, 0), (-1, -1), colors.white),
        ('PADDING', (0, 0), (-1, -1), 6),
        ('SPAN', (1, 3), (3, 3)),
    ]))
    elementos.append(tabla_vehiculo)
    elementos.append(Spacer(1, 15))
    
    # === COBERTURAS ===
    elementos.append(Paragraph('COBERTURAS CONTRATADAS', estilo_subtitulo))
    
    # Calcular deducibles
    deducible_dm = vehiculo['valor_comercial'] * 0.05 if cobertura['nombre'] != 'RC Básica' else 0
    deducible_rt = vehiculo['valor_comercial'] * 0.10 if cobertura['nombre'] != 'RC Básica' else 0
    
    coberturas_data = [
        ['COBERTURA', 'SUMA ASEGURADA', 'DEDUCIBLE'],
        ['Daños Materiales', formatear_moneda(vehiculo['valor_comercial']) if cobertura['nombre'] != 'RC Básica' else 'No Aplica', 
         f"5% ({formatear_moneda(deducible_dm)})" if cobertura['nombre'] != 'RC Básica' else 'N/A'],
        ['Robo Total', formatear_moneda(vehiculo['valor_comercial']) if cobertura['nombre'] != 'RC Básica' else 'No Aplica', 
         f"10% ({formatear_moneda(deducible_rt)})" if cobertura['nombre'] != 'RC Básica' else 'N/A'],
        ['Responsabilidad Civil', formatear_moneda(cobertura['rc']), 'Sin deducible'],
        ['Gastos Médicos Ocupantes', formatear_moneda(cobertura['gm']) if cobertura['gm'] > 0 else 'No Aplica', 'Sin deducible'],
        ['Asistencia Legal', 'Amparada', 'Sin deducible'],
        ['Asistencia Vial 24/7', 'Incluida', 'Sin deducible'],
    ]
    
    tabla_coberturas = Table(coberturas_data, colWidths=[2.5*inch, 2.5*inch, 2*inch])
    tabla_coberturas.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), COLOR_SECUNDARIO),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 10),
        ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
        ('FONTSIZE', (0, 1), (-1, -1), 9),
        ('ALIGN', (1, 1), (-1, -1), 'CENTER'),
        ('GRID', (0, 0), (-1, -1), 0.5, COLOR_GRIS),
        ('BACKGROUND', (0, 1), (-1, -1), colors.white),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor("#F8F9FA")]),
        ('PADDING', (0, 0), (-1, -1), 8),
    ]))
    elementos.append(tabla_coberturas)
    elementos.append(Spacer(1, 15))
    
    # === RESUMEN DE PRIMA ===
    elementos.append(Paragraph('RESUMEN DE PRIMA', estilo_subtitulo))
    
    # Calcular prima basada en valor del vehículo y tipo de cobertura
    factor_prima = {'Amplia': 0.045, 'Limitada': 0.035, 'Premium': 0.055, 'RC Básica': 0.025}
    prima_neta = vehiculo['valor_comercial'] * factor_prima.get(cobertura['nombre'], 0.04)
    derecho_poliza = 450.00
    forma_pago = random.choice(['Anual', 'Semestral', 'Trimestral', 'Mensual'])
    recargos = {'Anual': 0, 'Semestral': 0.03, 'Trimestral': 0.04, 'Mensual': 0.06}
    recargo = prima_neta * recargos[forma_pago]
    subtotal = prima_neta + derecho_poliza + recargo
    iva = subtotal * 0.16
    prima_total = subtotal + iva
    
    prima_data = [
        ['CONCEPTO', 'IMPORTE'],
        ['Prima Neta', formatear_moneda(prima_neta)],
        ['Derecho de Póliza', formatear_moneda(derecho_poliza)],
        ['Recargo por pago fraccionado', formatear_moneda(recargo)],
        ['Subtotal', formatear_moneda(subtotal)],
        ['I.V.A. (16%)', formatear_moneda(iva)],
        ['PRIMA TOTAL', formatear_moneda(prima_total)],
    ]
    
    tabla_prima = Table(prima_data, colWidths=[4*inch, 3*inch])
    tabla_prima.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), COLOR_PRIMARIO),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('BACKGROUND', (0, -1), (-1, -1), COLOR_ACENTO),
        ('TEXTCOLOR', (0, -1), (-1, -1), colors.white),
        ('FONTNAME', (0, -1), (-1, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, -1), (-1, -1), 11),
        ('FONTSIZE', (0, 0), (-1, 0), 10),
        ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
        ('ALIGN', (1, 1), (1, -1), 'RIGHT'),
        ('FONTSIZE', (0, 1), (-1, -2), 9),
        ('GRID', (0, 0), (-1, -1), 0.5, COLOR_GRIS),
        ('PADDING', (0, 0), (-1, -1), 8),
    ]))
    elementos.append(tabla_prima)
    elementos.append(Spacer(1, 10))
    
    # Forma de pago
    elementos.append(Paragraph(f'<b>Forma de Pago:</b> {forma_pago}', estilo_normal))
    elementos.append(Spacer(1, 20))
    
    # === PIE DE PÁGINA ===
    pie_texto = """
    <font size="8" color="#566573">
    Este documento es una póliza de seguro emitida por Seguros Centinela S.A. de C.V.<br/>
    Para reportar siniestros o asistencia, llame al: <b>800-CENTINELA (236-8463)</b><br/>
    Consulte condiciones generales en: www.seguroscentinela.com.mx<br/>
    Documento generado electrónicamente. Folio de verificación: SC-{folio}
    </font>
    """.format(folio=''.join(random.choices('0123456789ABCDEF', k=12)))
    
    elementos.append(Paragraph(pie_texto, ParagraphStyle('Pie', alignment=TA_CENTER)))
    
    # Generar PDF
    doc.build(elementos)
    return prima_total

# ============================================================================
# GENERADOR DE PDF - PÓLIZA GMM
# ============================================================================

def crear_poliza_gmm_pdf(numero_poliza, cliente, plan, asegurados, fecha_emision, ruta_salida):
    """Crea un PDF de póliza de Gastos Médicos Mayores."""
    
    doc = SimpleDocTemplate(
        ruta_salida,
        pagesize=letter,
        rightMargin=0.75*inch,
        leftMargin=0.75*inch,
        topMargin=0.5*inch,
        bottomMargin=0.5*inch
    )
    
    elementos = []
    estilos = getSampleStyleSheet()
    
    # Estilos personalizados
    estilo_subtitulo = ParagraphStyle(
        'Subtitulo',
        parent=estilos['Heading2'],
        fontSize=13,
        textColor=COLOR_SECUNDARIO,
        spaceBefore=12,
        spaceAfter=6
    )
    
    estilo_normal = ParagraphStyle(
        'Normal',
        parent=estilos['Normal'],
        fontSize=10,
        textColor=COLOR_GRIS
    )
    
    # === ENCABEZADO ===
    encabezado_data = [
        [
            Paragraph('<b>SEGUROS CENTINELA</b><br/><font size="9">S.A. de C.V.</font>', 
                     ParagraphStyle('Header', fontSize=16, textColor=COLOR_PRIMARIO, alignment=TA_LEFT)),
            Paragraph(f'<b>PÓLIZA GMM</b><br/><font size="9">Gastos Médicos Mayores</font>', 
                     ParagraphStyle('Header', fontSize=14, textColor=COLOR_PRIMARIO, alignment=TA_CENTER)),
            Paragraph(f'<b>No. {numero_poliza}</b><br/><font size="9">Vigente</font>', 
                     ParagraphStyle('Header', fontSize=11, textColor=COLOR_ACENTO, alignment=TA_RIGHT))
        ]
    ]
    
    tabla_encabezado = Table(encabezado_data, colWidths=[2.5*inch, 2.5*inch, 2*inch])
    tabla_encabezado.setStyle(TableStyle([
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('LINEBELOW', (0, 0), (-1, -1), 2, COLOR_PRIMARIO),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 10),
    ]))
    elementos.append(tabla_encabezado)
    elementos.append(Spacer(1, 15))
    
    # === PLAN CONTRATADO ===
    tipo_poliza = "Familiar" if len(asegurados) > 1 else "Individual"
    plan_data = [
        [f'PLAN: {plan["nombre"].upper()}', ''],
        ['Tipo de Póliza:', tipo_poliza],
        ['Nivel Hospitalario:', plan['nivel']],
        ['Suma Asegurada:', formatear_moneda(plan['sa'])],
        ['Deducible:', formatear_moneda(plan['ded'])],
        ['Coaseguro:', '10% (Tope: $200,000 MXN)'],
    ]
    
    tabla_plan = Table(plan_data, colWidths=[2.5*inch, 4.5*inch])
    tabla_plan.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), COLOR_ACENTO),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 12),
        ('SPAN', (0, 0), (-1, 0)),
        ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
        ('FONTNAME', (0, 1), (0, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 1), (-1, -1), 9),
        ('GRID', (0, 0), (-1, -1), 0.5, COLOR_GRIS),
        ('BACKGROUND', (0, 1), (-1, -1), colors.HexColor("#FEF9E7")),
        ('PADDING', (0, 0), (-1, -1), 8),
    ]))
    elementos.append(tabla_plan)
    elementos.append(Spacer(1, 12))
    
    # === VIGENCIA ===
    fecha_fin = fecha_emision + timedelta(days=365)
    vigencia_data = [
        ['VIGENCIA', ''],
        ['Inicio:', (fecha_emision + timedelta(days=1)).strftime('%d/%m/%Y')],
        ['Fin:', fecha_fin.strftime('%d/%m/%Y')],
    ]
    
    tabla_vigencia = Table(vigencia_data, colWidths=[2*inch, 5*inch])
    tabla_vigencia.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), COLOR_PRIMARIO),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('SPAN', (0, 0), (-1, 0)),
        ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
        ('FONTNAME', (0, 1), (0, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('GRID', (0, 0), (-1, -1), 0.5, COLOR_GRIS),
        ('PADDING', (0, 0), (-1, -1), 6),
    ]))
    elementos.append(tabla_vigencia)
    elementos.append(Spacer(1, 12))
    
    # === DATOS DEL CONTRATANTE ===
    elementos.append(Paragraph('DATOS DEL CONTRATANTE', estilo_subtitulo))
    
    cliente_data = [
        ['Nombre:', cliente['nombre_completo'], 'RFC:', cliente['rfc']],
        ['Domicilio:', f"{cliente['calle']}, {cliente['colonia']}", 'C.P.:', cliente['codigo_postal']],
        ['Municipio:', cliente['municipio'], 'Estado:', cliente['estado']],
        ['Teléfono:', cliente['telefono'], 'Email:', cliente['email']],
    ]
    
    tabla_cliente = Table(cliente_data, colWidths=[1.2*inch, 2.8*inch, 0.8*inch, 2.2*inch])
    tabla_cliente.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTNAME', (2, 0), (2, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 8),
        ('TEXTCOLOR', (0, 0), (-1, -1), COLOR_GRIS),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E0E0E0")),
        ('PADDING', (0, 0), (-1, -1), 5),
    ]))
    elementos.append(tabla_cliente)
    elementos.append(Spacer(1, 12))
    
    # === ASEGURADOS ===
    elementos.append(Paragraph('PERSONAS ASEGURADAS', estilo_subtitulo))
    
    asegurados_header = ['NOMBRE', 'PARENTESCO', 'F. NACIMIENTO', 'EDAD', 'GÉNERO']
    asegurados_data = [asegurados_header]
    
    for aseg in asegurados:
        asegurados_data.append([
            aseg['nombre'],
            aseg['parentesco'],
            aseg['fecha_nacimiento'].strftime('%d/%m/%Y'),
            str(aseg['edad']),
            'Masculino' if aseg['genero'] == 'M' else 'Femenino'
        ])
    
    tabla_asegurados = Table(asegurados_data, colWidths=[2.2*inch, 1.3*inch, 1.3*inch, 0.8*inch, 1.4*inch])
    tabla_asegurados.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), COLOR_SECUNDARIO),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 9),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTSIZE', (0, 1), (-1, -1), 8),
        ('GRID', (0, 0), (-1, -1), 0.5, COLOR_GRIS),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor("#F8F9FA")]),
        ('PADDING', (0, 0), (-1, -1), 6),
    ]))
    elementos.append(tabla_asegurados)
    elementos.append(Spacer(1, 12))
    
    # === COBERTURAS ===
    elementos.append(Paragraph('COBERTURAS INCLUIDAS', estilo_subtitulo))
    
    incluye_dental = plan['id'] in ['PLAN_ESE', 'PLAN_PLU', 'PLAN_ELI', 'PLAN_FAM']
    incluye_vision = plan['id'] in ['PLAN_PLU', 'PLAN_ELI', 'PLAN_FAM']
    incluye_internacional = plan['id'] == 'PLAN_ELI'
    
    coberturas_data = [
        ['COBERTURA', 'LÍMITE', 'PERÍODO DE ESPERA'],
        ['Hospitalización', 'Suma Asegurada', 'Sin espera'],
        ['Cirugía', 'Suma Asegurada', 'Sin espera'],
        ['Honorarios Médicos', 'Suma Asegurada', 'Sin espera'],
        ['Medicamentos (hospitalización)', 'Suma Asegurada', 'Sin espera'],
        ['Laboratorio y Gabinete', 'Suma Asegurada', 'Sin espera'],
        ['Ambulancia terrestre/aérea', '$50,000 MXN', 'Sin espera'],
        ['Oncología', 'Suma Asegurada', 'Sin espera'],
        ['Cobertura Dental', '$15,000 MXN' if incluye_dental else 'No incluida', '90 días' if incluye_dental else 'N/A'],
        ['Cobertura Visual', '$8,000 MXN' if incluye_vision else 'No incluida', '90 días' if incluye_vision else 'N/A'],
        ['Maternidad', '$150,000 MXN', '10 meses'],
        ['Cobertura Internacional', 'Incluida' if incluye_internacional else 'No incluida', 'Sin espera' if incluye_internacional else 'N/A'],
    ]
    
    tabla_coberturas = Table(coberturas_data, colWidths=[2.8*inch, 2.2*inch, 2*inch])
    tabla_coberturas.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), COLOR_SECUNDARIO),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 9),
        ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
        ('ALIGN', (1, 1), (-1, -1), 'CENTER'),
        ('FONTSIZE', (0, 1), (-1, -1), 8),
        ('GRID', (0, 0), (-1, -1), 0.5, COLOR_GRIS),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor("#F8F9FA")]),
        ('PADDING', (0, 0), (-1, -1), 5),
    ]))
    elementos.append(tabla_coberturas)
    elementos.append(Spacer(1, 12))
    
    # === RESUMEN DE PRIMA ===
    elementos.append(Paragraph('RESUMEN DE PRIMA', estilo_subtitulo))
    
    # Calcular prima basada en plan y número de asegurados
    prima_base = {'PLAN_BAS': 12000, 'PLAN_ESE': 18000, 'PLAN_PLU': 28000, 'PLAN_ELI': 45000, 'PLAN_FAM': 22000}
    factor_edad = sum([1 + (a['edad'] - 30) * 0.02 if a['edad'] > 30 else 1 for a in asegurados]) / len(asegurados)
    prima_por_asegurado = prima_base.get(plan['id'], 15000) * factor_edad
    prima_neta = prima_por_asegurado * len(asegurados)
    derecho_poliza = 650.00
    forma_pago = random.choice(['Anual', 'Semestral', 'Trimestral', 'Mensual'])
    recargos = {'Anual': 0, 'Semestral': 0.03, 'Trimestral': 0.04, 'Mensual': 0.06}
    recargo = prima_neta * recargos[forma_pago]
    subtotal = prima_neta + derecho_poliza + recargo
    iva = subtotal * 0.16
    prima_total = subtotal + iva
    
    prima_data = [
        ['CONCEPTO', 'IMPORTE'],
        [f'Prima ({len(asegurados)} asegurado{"s" if len(asegurados) > 1 else ""})', formatear_moneda(prima_neta)],
        ['Derecho de Póliza', formatear_moneda(derecho_poliza)],
        ['Recargo por pago fraccionado', formatear_moneda(recargo)],
        ['Subtotal', formatear_moneda(subtotal)],
        ['I.V.A. (16%)', formatear_moneda(iva)],
        ['PRIMA TOTAL ANUAL', formatear_moneda(prima_total)],
    ]
    
    tabla_prima = Table(prima_data, colWidths=[4*inch, 3*inch])
    tabla_prima.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), COLOR_PRIMARIO),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('BACKGROUND', (0, -1), (-1, -1), COLOR_ACENTO),
        ('TEXTCOLOR', (0, -1), (-1, -1), colors.white),
        ('FONTNAME', (0, -1), (-1, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, -1), (-1, -1), 10),
        ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
        ('ALIGN', (1, 1), (1, -1), 'RIGHT'),
        ('FONTSIZE', (0, 0), (-1, -2), 9),
        ('GRID', (0, 0), (-1, -1), 0.5, COLOR_GRIS),
        ('PADDING', (0, 0), (-1, -1), 6),
    ]))
    elementos.append(tabla_prima)
    elementos.append(Spacer(1, 8))
    
    elementos.append(Paragraph(f'<b>Forma de Pago:</b> {forma_pago}', estilo_normal))
    elementos.append(Spacer(1, 15))
    
    # === PIE DE PÁGINA ===
    pie_texto = """
    <font size="7" color="#566573">
    Seguros Centinela S.A. de C.V. - Póliza de Gastos Médicos Mayores<br/>
    Línea de atención médica 24/7: <b>800-CENTINELA (236-8463)</b> | Red hospitalaria: www.seguroscentinela.com.mx/red<br/>
    Folio: SC-GMM-{folio}
    </font>
    """.format(folio=''.join(random.choices('0123456789ABCDEF', k=12)))
    
    elementos.append(Paragraph(pie_texto, ParagraphStyle('Pie', alignment=TA_CENTER)))
    
    # Generar PDF
    doc.build(elementos)
    return prima_total

# ============================================================================
# FUNCIÓN PRINCIPAL
# ============================================================================

def main():
    """Función principal que genera todas las pólizas."""
    
    # Crear directorios de salida
    script_dir = os.path.dirname(os.path.abspath(__file__))
    dir_auto = os.path.join(script_dir, OUTPUT_DIR_AUTO)
    dir_gmm = os.path.join(script_dir, OUTPUT_DIR_GMM)
    
    os.makedirs(dir_auto, exist_ok=True)
    os.makedirs(dir_gmm, exist_ok=True)
    
    print("=" * 60)
    print("SEGUROS CENTINELA - Generador de Pólizas PDF")
    print("=" * 60)
    
    # =========================================
    # GENERAR 40 PÓLIZAS DE AUTOMÓVIL
    # =========================================
    print("\n📄 Generando pólizas de AUTOMÓVIL...")
    
    total_prima_auto = 0
    for i in range(1, 41):
        numero_poliza = f"AUTO-2024-{i:06d}"
        cliente = generar_datos_cliente()
        vehiculo = generar_datos_vehiculo()
        cobertura = random.choice(PAQUETES_COBERTURA)
        
        # Fecha de emisión aleatoria en 2024
        dias_desde_inicio = random.randint(0, 300)
        fecha_emision = datetime(2024, 1, 1) + timedelta(days=dias_desde_inicio)
        
        nombre_archivo = f"poliza_{numero_poliza}.pdf"
        ruta_archivo = os.path.join(dir_auto, nombre_archivo)
        
        prima = crear_poliza_auto_pdf(numero_poliza, cliente, vehiculo, cobertura, fecha_emision, ruta_archivo)
        total_prima_auto += prima
        
        print(f"  ✓ {numero_poliza} - {cliente['nombre_completo'][:30]} - {vehiculo['marca']} {vehiculo['modelo']}")
    
    print(f"\n  📊 Total pólizas AUTO: 40 | Prima total: {formatear_moneda(total_prima_auto)}")
    
    # =========================================
    # GENERAR 40 PÓLIZAS DE GMM
    # =========================================
    print("\n📄 Generando pólizas de GMM...")
    
    total_prima_gmm = 0
    for i in range(1, 41):
        numero_poliza = f"GMM-2024-{i:06d}"
        cliente = generar_datos_cliente()
        plan = random.choice(PLANES_GMM)
        
        # Generar asegurados (1-4 para pólizas familiares)
        es_familiar = random.random() > 0.4
        asegurados = []
        
        # Titular
        asegurados.append({
            'nombre': cliente['nombre_completo'],
            'parentesco': 'Titular',
            'fecha_nacimiento': cliente['fecha_nacimiento'],
            'edad': cliente['edad'],
            'genero': cliente['genero']
        })
        
        if es_familiar:
            # Cónyuge
            genero_conyuge = 'F' if cliente['genero'] == 'M' else 'M'
            nombre_conyuge = random.choice(NOMBRES_FEMENINOS if genero_conyuge == 'F' else NOMBRES_MASCULINOS)
            edad_conyuge = cliente['edad'] + random.randint(-5, 5)
            asegurados.append({
                'nombre': f"{nombre_conyuge} {random.choice(APELLIDOS)} {random.choice(APELLIDOS)}",
                'parentesco': 'Cónyuge',
                'fecha_nacimiento': datetime.now() - timedelta(days=edad_conyuge*365),
                'edad': edad_conyuge,
                'genero': genero_conyuge
            })
            
            # Hijos (0-2)
            num_hijos = random.randint(0, 2)
            for h in range(num_hijos):
                genero_hijo = random.choice(['M', 'F'])
                nombre_hijo = random.choice(NOMBRES_MASCULINOS if genero_hijo == 'M' else NOMBRES_FEMENINOS)
                edad_hijo = random.randint(3, 18)
                asegurados.append({
                    'nombre': f"{nombre_hijo} {cliente['apellido_paterno']} {random.choice(APELLIDOS)}",
                    'parentesco': 'Hijo/a',
                    'fecha_nacimiento': datetime.now() - timedelta(days=edad_hijo*365),
                    'edad': edad_hijo,
                    'genero': genero_hijo
                })
        
        # Fecha de emisión aleatoria en 2024
        dias_desde_inicio = random.randint(0, 300)
        fecha_emision = datetime(2024, 1, 1) + timedelta(days=dias_desde_inicio)
        
        nombre_archivo = f"poliza_{numero_poliza}.pdf"
        ruta_archivo = os.path.join(dir_gmm, nombre_archivo)
        
        prima = crear_poliza_gmm_pdf(numero_poliza, cliente, plan, asegurados, fecha_emision, ruta_archivo)
        total_prima_gmm += prima
        
        tipo = "Familiar" if len(asegurados) > 1 else "Individual"
        print(f"  ✓ {numero_poliza} - {cliente['nombre_completo'][:25]} - {plan['nombre']} ({tipo}, {len(asegurados)} aseg.)")
    
    print(f"\n  📊 Total pólizas GMM: 40 | Prima total: {formatear_moneda(total_prima_gmm)}")
    
    # =========================================
    # RESUMEN FINAL
    # =========================================
    print("\n" + "=" * 60)
    print("RESUMEN DE GENERACIÓN")
    print("=" * 60)
    print(f"  📁 Pólizas AUTO guardadas en: {dir_auto}")
    print(f"  📁 Pólizas GMM guardadas en: {dir_gmm}")
    print(f"  📄 Total documentos generados: 80")
    print(f"  💰 Prima total cartera: {formatear_moneda(total_prima_auto + total_prima_gmm)}")
    print("=" * 60)
    print("✅ Proceso completado exitosamente")

if __name__ == "__main__":
    main()



