#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para generar documentos PDF de URBANOVA
- Solicitudes de Reparación para Departamentos (15)
- Facturas de Materiales (15)
- Escrituras de Clientes (15)

Autor: Generado para URBANOVA
Fecha: Diciembre 2024
"""

from reportlab.lib.pagesizes import letter, A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, Image
from reportlab.lib.enums import TA_CENTER, TA_RIGHT, TA_LEFT, TA_JUSTIFY
from reportlab.lib import colors
from datetime import datetime, timedelta
import random
import os

# ============================================================================
# DATOS SINTÉTICOS PARA URBANOVA
# ============================================================================

DESARROLLOS = [
    "Residencial Polanco Heights", "Torres Interlomas", "Condesa Living",
    "Santa Fe Corporate Plaza", "Bosques Residencial", "Pedregal Towers",
    "Satélite Garden", "Angelópolis Premium", "San Pedro Luxury",
    "Zapopan Residencial", "Mérida Norte", "Cancún Bay View",
    "Querétaro Centro", "Monterrey Elite", "Guadalajara Midtown"
]

COLONIAS = [
    "Polanco", "Interlomas", "Condesa", "Santa Fe", "Bosques de las Lomas",
    "Pedregal", "Ciudad Satélite", "Angelópolis", "San Pedro Garza García",
    "Zapopan Centro", "Mérida Norte", "Cancún Centro", "Centro Querétaro",
    "San Pedro Monterrey", "Providencia"
]

CIUDADES = [
    "Ciudad de México", "Naucalpan, Edo. Méx.", "Ciudad de México",
    "Ciudad de México", "Huixquilucan, Edo. Méx.", "Ciudad de México",
    "Naucalpan, Edo. Méx.", "Puebla, Pue.", "San Pedro Garza García, N.L.",
    "Zapopan, Jal.", "Mérida, Yuc.", "Cancún, Q. Roo", "Querétaro, Qro.",
    "Monterrey, N.L.", "Guadalajara, Jal."
]

TIPOS_REPARACION = [
    # Plomería
    "Plomería - Fuga de agua", "Plomería - WC no funciona", "Plomería - Regadera gotea",
    "Plomería - Drenaje tapado", "Plomería - Calentador", "Plomería - Baja presión",
    "Plomería - Tinaco/Cisterna", "Plomería - Bomba de agua", "Plomería - Tubería rota",
    # Electricidad
    "Electricidad - Apagón parcial", "Electricidad - Cortocircuito", "Electricidad - Contactos",
    "Electricidad - Ventilador techo", "Electricidad - Centro de carga", "Electricidad - Iluminación",
    # Pintura
    "Pintura - Manchas de humedad", "Pintura - Desgaste general", "Pintura - Grietas",
    "Pintura - Hongos/Moho", "Pintura - Salitre", "Pintura - Plafón dañado",
    # Carpintería/Herrería
    "Carpintería - Puerta dañada", "Carpintería - Closet descuadrado", "Herrería - Ventana no cierra",
    "Cancelería - Vidrio roto", "Herrería - Cancel aluminio", "Carpintería - Persianas",
    # Clima
    "Aire Acondicionado - No enfría", "Calefacción - No enciende", "Clima - Fuga de agua",
    "Clima - Ruido excesivo", "Ventilación - Extractor", "Clima - Control remoto",
    # Pisos
    "Pisos - Loseta desprendida", "Pisos - Azulejo caído", "Pisos - Grieta",
    "Pisos - Laminado dañado", "Pisos - Junta deteriorada",
    # Impermeabilización
    "Impermeabilización - Filtración", "Impermeabilización - Goteras", "Impermeabilización - Humedad"
]

# ============================================================================
# PROVEEDORES POR CATEGORÍA
# ============================================================================

PROVEEDORES = {
    "Albañilería": [
        {
            "razon_social": "Materiales de Construcción del Centro S.A. de C.V.",
            "nombre_comercial": "MatCentro",
            "rfc": "MCC850623HG7",
            "direccion": "Av. Insurgentes Sur 1234, Col. Del Valle, CDMX",
            "telefono": "(55) 5512-3456",
            "email": "ventas@matcentro.mx",
            "contacto": "Ing. Roberto Mendoza"
        },
        {
            "razon_social": "Cementos y Agregados del Norte S.A. de C.V.",
            "nombre_comercial": "CemNorte",
            "rfc": "CAN910415XY9",
            "direccion": "Av. Constitución 890, Centro, Monterrey, N.L.",
            "telefono": "(81) 8123-4567",
            "email": "ventas@cemnorte.mx",
            "contacto": "Lic. Patricia Garza"
        },
        {
            "razon_social": "Blocks y Prefabricados Querétaro S.A. de C.V.",
            "nombre_comercial": "BlockQro",
            "rfc": "BPQ880912AB1",
            "direccion": "Carretera 57 Km 12, Zona Industrial, Querétaro",
            "telefono": "(442) 198-7654",
            "email": "contacto@blockqro.mx",
            "contacto": "Arq. Miguel Ángel Ruiz"
        }
    ],
    "Pintura": [
        {
            "razon_social": "Pinturas y Recubrimientos Nacionales S.A. de C.V.",
            "nombre_comercial": "PintuNac",
            "rfc": "PRN920708EF3",
            "direccion": "Av. Revolución 567, Col. Mixcoac, CDMX",
            "telefono": "(55) 5678-9012",
            "email": "ventas@pintunac.mx",
            "contacto": "Ing. Laura Castillo"
        },
        {
            "razon_social": "Comex Guadalajara Distribución S.A. de C.V.",
            "nombre_comercial": "Comex GDL",
            "rfc": "CGD870520GH4",
            "direccion": "Av. López Mateos 2345, Zona Industrial, Guadalajara",
            "telefono": "(33) 3345-6789",
            "email": "distribuidora@comexgdl.mx",
            "contacto": "Lic. Fernando Ochoa"
        },
        {
            "razon_social": "Impermeabilizantes del Sureste S.A. de C.V.",
            "nombre_comercial": "ImperSur",
            "rfc": "IDS940315IJ5",
            "direccion": "Av. Tulum 890, Zona Hotelera, Cancún, Q. Roo",
            "telefono": "(998) 123-4567",
            "email": "ventas@impersur.mx",
            "contacto": "Ing. Carlos Medina"
        },
        {
            "razon_social": "Acabados y Texturas Monterrey S.A. de C.V.",
            "nombre_comercial": "AcabTex",
            "rfc": "ATM900812KL6",
            "direccion": "Av. Ruiz Cortines 456, San Nicolás, Monterrey",
            "telefono": "(81) 8765-4321",
            "email": "contacto@acabtex.mx",
            "contacto": "Arq. Diana Villarreal"
        }
    ],
    "Plomería": [
        {
            "razon_social": "Plomería Industrial de México S.A. de C.V.",
            "nombre_comercial": "PlomerInd",
            "rfc": "PIM880625MN7",
            "direccion": "Av. Central 789, Parque Industrial, CDMX",
            "telefono": "(55) 5345-6789",
            "email": "ventas@plomerind.mx",
            "contacto": "Ing. Raúl Domínguez"
        },
        {
            "razon_social": "Hidráulica y Sanitarios del Bajío S.A. de C.V.",
            "nombre_comercial": "HidroSan",
            "rfc": "HSB910930OP8",
            "direccion": "Blvd. Bernardo Quintana 234, Centro, Querétaro",
            "telefono": "(442) 321-4567",
            "email": "ventas@hidrosan.mx",
            "contacto": "Ing. Alejandra Vega"
        },
        {
            "razon_social": "Materiales Sanitarios Premium S.A. de C.V.",
            "nombre_comercial": "SaniPrem",
            "rfc": "MSP950412QR9",
            "direccion": "Av. Chapultepec 567, Col. Americana, Guadalajara",
            "telefono": "(33) 3654-7890",
            "email": "premium@saniprem.mx",
            "contacto": "Lic. Roberto Silva"
        },
        {
            "razon_social": "Válvulas y Conexiones del Norte S.A. de C.V.",
            "nombre_comercial": "ValvuNor",
            "rfc": "VCN870218ST0",
            "direccion": "Av. Fundidora 123, Centro, Monterrey, N.L.",
            "telefono": "(81) 8987-6543",
            "email": "ventas@valvunor.mx",
            "contacto": "Ing. Francisco Torres"
        }
    ],
    "Mantenimiento": [
        {
            "razon_social": "Servicios Integrales de Mantenimiento S.A. de C.V.",
            "nombre_comercial": "ServiMan",
            "rfc": "SIM920815UV1",
            "direccion": "Calle Durango 234, Col. Roma, CDMX",
            "telefono": "(55) 5789-0123",
            "email": "servicios@serviman.mx",
            "contacto": "Ing. Marco Antonio López"
        },
        {
            "razon_social": "Mantenimiento Profesional Regio S.A. de C.V.",
            "nombre_comercial": "MantePro",
            "rfc": "MPR890623WX2",
            "direccion": "Av. Vasconcelos 890, Valle Oriente, Monterrey",
            "telefono": "(81) 8234-5678",
            "email": "contacto@mantepro.mx",
            "contacto": "Ing. Eduardo Garza"
        },
        {
            "razon_social": "Limpieza y Conservación del Caribe S.A. de C.V.",
            "nombre_comercial": "LimpCarib",
            "rfc": "LCC950220YZ3",
            "direccion": "Av. Nichupté 456, Zona Hotelera, Cancún",
            "telefono": "(998) 765-4321",
            "email": "servicios@limpcarib.mx",
            "contacto": "Lic. María del Carmen Sosa"
        },
        {
            "razon_social": "Técnicos Especializados HVAC S.A. de C.V.",
            "nombre_comercial": "TecHVAC",
            "rfc": "TEH910405A11",
            "direccion": "Av. Paseo de la Reforma 789, Polanco, CDMX",
            "telefono": "(55) 5456-7890",
            "email": "servicio@techvac.mx",
            "contacto": "Ing. Andrés Salazar"
        }
    ]
}

# Materiales por categoría
MATERIALES_ALBANILERIA = [
    ("Cemento Portland Gris CPC 30R 50kg", "Bulto", 185.00),
    ("Cemento Premium Alta Resistencia 50kg", "Bulto", 245.00),
    ("Arena de Río Cribada M³", "M³", 380.00),
    ("Grava Triturada 3/4\" M³", "M³", 420.00),
    ("Block Hueco 15x20x40cm", "Pieza", 18.50),
    ("Varilla Corrugada 3/8\" 12m", "Pieza", 95.50),
    ("Malla Electrosoldada 6x6/10-10", "Rollo", 650.00),
    ("Mortero para Pegar Block 50kg", "Bulto", 145.00),
    ("Adoquín Rectangular Rojo 10x20cm", "M²", 185.00),
    ("Ladrillo Rojo Recocido 7x14x28cm", "Millar", 4500.00),
    ("Alambre Recocido Cal. 18", "Kg", 35.00),
    ("Clavos 2.5\"", "Kg", 25.00)
]

MATERIALES_PINTURA = [
    ("Pintura Vinílica Blanca Premium 19L", "Cubeta", 750.00),
    ("Pintura Vinílica Color Pastel 19L", "Cubeta", 820.00),
    ("Esmalte Alkydálico Blanco 4L", "Galón", 450.00),
    ("Impermeabilizante Acrílico 5 Años 19L", "Cubeta", 1250.00),
    ("Impermeabilizante Fibratado 10 Años 19L", "Cubeta", 1850.00),
    ("Tirol Texturizado Blanco 25kg", "Bulto", 185.00),
    ("Pasta Texturizada Grano Fino 25kg", "Bulto", 245.00),
    ("Sellador Acrílico 19L", "Cubeta", 580.00),
    ("Primario Anticorrosivo 4L", "Galón", 380.00),
    ("Thinner Estándar 19L", "Cubeta", 450.00),
    ("Brocha Profesional 4\"", "Pieza", 85.00),
    ("Rodillo Antigota 9\"", "Pieza", 125.00)
]

MATERIALES_PLOMERIA = [
    ("Tubo PVC Hidráulico 4\" 6m", "Pieza", 320.00),
    ("Tubo PVC Hidráulico 2\" 6m", "Pieza", 145.00),
    ("Conexión Codo PVC 4\" 90°", "Pieza", 85.00),
    ("Tubo Cobre Tipo M 1/2\" 6m", "Pieza", 580.00),
    ("WC Completo Económico", "Juego", 2850.00),
    ("Lavabo Empotrado Premium", "Pieza", 3500.00),
    ("Grifería Monomando Cocina", "Pieza", 1850.00),
    ("Válvula Check Bronce 1\"", "Pieza", 450.00),
    ("Boiler Gas 40L", "Pieza", 4500.00),
    ("Tinaco Rotoplas 1100L", "Pieza", 2800.00),
    ("Bomba de Agua 1/2 HP", "Pieza", 1950.00),
    ("Flexibles para Lavabo", "Par", 120.00)
]

MATERIALES_MANTENIMIENTO = [
    ("Kit Herramientas Mantenimiento Básico", "Kit", 2500.00),
    ("Motor Elevador 5HP", "Pieza", 45000.00),
    ("Kit Limpieza Industrial", "Kit", 850.00),
    ("Filtro HVAC Carbón Activado", "Pieza", 350.00),
    ("Gas Refrigerante R410A 11.3kg", "Cilindro", 2800.00),
    ("Aceite Lubricante Industrial 20L", "Cubeta", 950.00),
    ("Luminaria LED Panel 60x60", "Pieza", 380.00),
    ("Interruptor Termomagnético 2P 30A", "Pieza", 185.00),
    ("Cable THW Calibre 12 AWG", "Metro", 12.50),
    ("Cinta Aislante Profesional", "Rollo", 45.00),
    ("Multicontacto Industrial 6 entradas", "Pieza", 250.00),
    ("Extintor PQS 4.5kg", "Pieza", 650.00)
]

# Diccionario para seleccionar materiales por categoría
MATERIALES_POR_CATEGORIA = {
    "Albañilería": MATERIALES_ALBANILERIA,
    "Pintura": MATERIALES_PINTURA,
    "Plomería": MATERIALES_PLOMERIA,
    "Mantenimiento": MATERIALES_MANTENIMIENTO
}

NOMBRES_CLIENTES = [
    # Nombres originales
    "María Guadalupe Hernández Sánchez", "José Luis Ramírez González",
    "Ana Patricia Martínez López", "Carlos Alberto Rodríguez Pérez",
    "Laura Elena Fernández Ruiz", "Miguel Ángel García Torres",
    "Rosa María López Jiménez", "Francisco Javier Díaz Morales",
    "Gabriela Alejandra Flores Castro", "Roberto Carlos Mendoza Silva",
    "Carmen Leticia Vargas Ortiz", "Alejandro Gómez Reyes",
    "Patricia Isabel Cruz Medina", "Eduardo Sánchez Gutiérrez",
    "Claudia Ivonne Morales Herrera",
    # Nombres adicionales
    "Fernando Antonio Jiménez Vega", "Mónica Alejandra Torres Ruiz",
    "Ricardo Arturo Salazar Mendez", "Adriana Beatriz Castillo Luna",
    "Jorge Eduardo Pérez Navarro", "Sandra Paola Delgado Ríos",
    "Luis Fernando Herrera Campos", "Verónica Nayeli Romero Ibarra",
    "Daniel Alejandro Cruz Espinoza", "Lucía Fernanda Valdez Corona",
    "Martín Eduardo Aguilar Rojas", "Karla Daniela Ortega Paredes",
    "Sergio Iván Maldonado Juárez", "Cecilia Margarita Fuentes Lara",
    "Raúl Antonio Estrada Moreno", "Silvia Elena Pacheco Guerrero",
    "Héctor Manuel Ramos Vásquez", "Diana Carolina Núñez Quintero",
    "Armando Felipe Soto Contreras", "Teresa Guadalupe Alvarado Méndez",
    "Guillermo Ernesto Montes Bernal", "Lorena Patricia Cabrera Solís",
    "Pablo César Guzmán Portillo", "Maricela Josefina Varela Ochoa",
    "Enrique Rafael Domínguez Arce", "Blanca Estela Sandoval Tapia",
    "Jaime Alejandro Carrillo Duarte", "Irma Yolanda Cervantes Quiroz",
    "Oscar Fernando Velázquez Ponce", "Gloria Isabel Acosta Villanueva",
    "Mario Alberto Luna Báez", "Yolanda Mercedes Ávila Coronado",
    "David Emmanuel Cortés Magaña", "Rosa Angélica Trejo Bustamante",
    "Arturo Ignacio Miranda Cárdenas", "Alicia Mariana Paredes Galván"
]

NOTARIOS = [
    ("Notaría Pública No. 45", "Lic. Rodrigo Cervantes Saavedra", "CDMX"),
    ("Notaría Pública No. 12", "Lic. María Teresa Olivares Montes", "Monterrey"),
    ("Notaría Pública No. 89", "Lic. Jorge Enrique Villalobos Pérez", "Guadalajara"),
    ("Notaría Pública No. 23", "Lic. Ana Cristina Benavides León", "Querétaro"),
    ("Notaría Pública No. 67", "Lic. Fernando Augusto Maldonado Cruz", "CDMX"),
    ("Notaría Pública No. 34", "Lic. Gabriela Patricia Rojas Campos", "Puebla"),
    ("Notaría Pública No. 56", "Lic. Ricardo Martín Sandoval Ruiz", "Mérida"),
    ("Notaría Pública No. 78", "Lic. Mónica Elizabeth Contreras Vega", "Cancún")
]

# ============================================================================
# FUNCIONES PARA GENERAR PDFs
# ============================================================================

def crear_directorio_salida():
    """Crea directorio para guardar los PDFs"""
    directorio = "documentos_pdf_urbanova"
    if not os.path.exists(directorio):
        os.makedirs(directorio)
    return directorio

def obtener_estilos():
    """Retorna estilos personalizados para los documentos"""
    estilos = getSampleStyleSheet()
    
    # Estilo título principal
    estilos.add(ParagraphStyle(
        name='TituloUrbanova',
        parent=estilos['Heading1'],
        fontSize=18,
        textColor=colors.HexColor('#003366'),
        spaceAfter=12,
        alignment=TA_CENTER,
        fontName='Helvetica-Bold'
    ))
    
    # Estilo subtítulo
    estilos.add(ParagraphStyle(
        name='SubtituloUrbanova',
        parent=estilos['Heading2'],
        fontSize=12,
        textColor=colors.HexColor('#006699'),
        spaceAfter=10,
        fontName='Helvetica-Bold'
    ))
    
    # Estilo texto normal
    estilos.add(ParagraphStyle(
        name='TextoNormal',
        parent=estilos['Normal'],
        fontSize=10,
        alignment=TA_LEFT,
        fontName='Helvetica'
    ))
    
    # Estilo texto justificado
    estilos.add(ParagraphStyle(
        name='TextoJustificado',
        parent=estilos['Normal'],
        fontSize=10,
        alignment=TA_JUSTIFY,
        fontName='Helvetica'
    ))
    
    return estilos

def generar_solicitud_reparacion(numero, directorio):
    """Genera una solicitud de reparación en PDF"""
    filename = f"{directorio}/solicitud_reparacion_{numero:02d}.pdf"
    doc = SimpleDocTemplate(filename, pagesize=letter)
    elementos = []
    estilos = obtener_estilos()
    
    # Encabezado
    elementos.append(Paragraph("URBANOVA", estilos['TituloUrbanova']))
    elementos.append(Paragraph("Desarrollos Inmobiliarios Urbanova S.A. de C.V.", estilos['SubtituloUrbanova']))
    elementos.append(Spacer(1, 0.3*inch))
    
    # Título del documento
    elementos.append(Paragraph(f"SOLICITUD DE REPARACIÓN No. SR-2024-{numero:04d}", estilos['SubtituloUrbanova']))
    elementos.append(Spacer(1, 0.2*inch))
    
    # Datos del desarrollo y departamento
    desarrollo_idx = numero % len(DESARROLLOS)
    fecha = datetime.now() - timedelta(days=random.randint(1, 90))
    
    datos_solicitud = [
        ["DATOS DEL INMUEBLE", ""],
        ["Desarrollo:", DESARROLLOS[desarrollo_idx]],
        ["Colonia:", COLONIAS[desarrollo_idx]],
        ["Ciudad:", CIUDADES[desarrollo_idx]],
        ["Torre/Edificio:", f"Torre {random.choice(['A', 'B', 'C', 'D'])}"],
        ["No. Departamento:", f"{random.randint(100, 1200)}"],
        ["", ""],
        ["DATOS DEL PROPIETARIO", ""],
        ["Nombre:", NOMBRES_CLIENTES[numero % len(NOMBRES_CLIENTES)]],
        ["Teléfono:", f"+52 55 {random.randint(1000, 9999)} {random.randint(1000, 9999)}"],
        ["Email:", f"cliente{numero}@email.com"],
        ["", ""],
        ["DATOS DE LA REPARACIÓN", ""],
        ["Tipo de Reparación:", TIPOS_REPARACION[numero % len(TIPOS_REPARACION)]],
        ["Fecha de Solicitud:", fecha.strftime("%d/%m/%Y")],
        ["Prioridad:", random.choice(["Alta", "Media", "Baja"])],
    ]
    
    tabla = Table(datos_solicitud, colWidths=[2.5*inch, 4*inch])
    tabla.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#003366')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('BACKGROUND', (0, 7), (-1, 7), colors.HexColor('#003366')),
        ('TEXTCOLOR', (0, 7), (-1, 7), colors.whitesmoke),
        ('BACKGROUND', (0, 12), (-1, 12), colors.HexColor('#003366')),
        ('TEXTCOLOR', (0, 12), (-1, 12), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTNAME', (0, 7), (-1, 7), 'Helvetica-Bold'),
        ('FONTNAME', (0, 12), (-1, 12), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
        ('SPAN', (0, 0), (-1, 0)),
        ('SPAN', (0, 7), (-1, 7)),
        ('SPAN', (0, 12), (-1, 12)),
    ]))
    
    elementos.append(tabla)
    elementos.append(Spacer(1, 0.2*inch))
    
    # Descripción del problema
    elementos.append(Paragraph("<b>DESCRIPCIÓN DEL PROBLEMA:</b>", estilos['TextoNormal']))
    elementos.append(Spacer(1, 0.1*inch))
    
    descripciones = [
        # PLOMERÍA (15 descripciones)
        "Se presenta fuga de agua en la llave del lavabo de la cocina. El goteo es constante y ha generado manchas en el gabinete inferior.",
        "El WC del baño de visitas no descarga el agua correctamente, se requiere revisión del mecanismo interno del tanque.",
        "La regadera del baño principal gotea constantemente, desperdiciando agua y generando ruido durante la noche.",
        "Fuga en la tubería debajo del fregadero de cocina, se observa charco de agua cada mañana.",
        "El calentador de agua no proporciona agua caliente suficiente, tarda más de 10 minutos en calentar.",
        "Drenaje del lavabo del baño principal se encuentra tapado, el agua tarda en bajar.",
        "La llave monomando de la cocina presenta fuga por la base cuando se abre el agua caliente.",
        "Baja presión de agua en toda la vivienda, especialmente en el segundo piso.",
        "El tinaco presenta fugas visibles en la base, se observa humedad en el techo del baño.",
        "La bomba de agua hace ruidos extraños y no presuriza correctamente el sistema.",
        "Fuga en el tubo de cobre del calentador, gotea agua caliente constantemente.",
        "El desagüe de la lavadora está tapado, el agua se regresa cuando se usa.",
        "Válvula de paso del baño no cierra completamente, gotea agua constantemente.",
        "Sarro acumulado en las llaves del baño, dificulta el paso del agua.",
        "Tubería del jardín presenta fuga subterránea, se observa área húmeda en el pasto.",
        
        # ELECTRICIDAD (12 descripciones)
        "El apagador de la recámara principal no enciende las luces. Se requiere revisión del sistema eléctrico.",
        "Se presenta cortocircuito en el contacto de la cocina, no funciona ningún aparato conectado ahí.",
        "Intermitencia en la luz del comedor, parpadea constantemente sin razón aparente.",
        "El ventilador de techo de la sala dejó de funcionar, no responde al control remoto ni al apagador.",
        "Calentamiento excesivo en el centro de carga, se percibe olor a quemado.",
        "Apagador de tres vías de la escalera no funciona, solo enciende desde un punto.",
        "Contactos de la recámara secundaria no proporcionan energía, se revisó con otros aparatos.",
        "La instalación del timbre dejó de funcionar, no suena cuando se presiona.",
        "Sobrecarga en el circuito de la cocina, se dispara el interruptor frecuentemente.",
        "Lámpara empotrada en el baño parpadea y hace ruido, posible balastro dañado.",
        "Cable expuesto en la pared del estudio, representa peligro de descarga eléctrica.",
        "El medidor de luz marca consumo excesivo, se sospecha fuga de corriente.",
        
        # PINTURA Y ACABADOS (12 descripciones)
        "Aparecen manchas de humedad en la pared de la recámara secundaria, cerca del techo. Posible filtración.",
        "Las paredes de las recámaras presentan desgaste en la pintura, se requiere repintado general.",
        "Grietas en las esquinas de las paredes de la sala, posible asentamiento del edificio.",
        "Desprendimiento de pintura en el baño debido a la humedad constante.",
        "Manchas de salitre en la pared exterior del balcón, afecta la estética del edificio.",
        "Pintura descascarada en el plafón de la cocina, cerca de la campana extractora.",
        "Hongos y moho en la esquina del baño de servicio, requiere tratamiento especial.",
        "Rayones y marcas en las paredes del pasillo, requiere retoque de pintura.",
        "Burbujas en la pintura del cuarto de lavado, indica humedad en la pared.",
        "Color desigual en paredes repintadas anteriormente, no coincide con el tono original.",
        "Fisuras en el acabado de pasta del techo de la sala principal.",
        "Manchas amarillentas en el techo de la cocina por acumulación de grasa.",
        
        # CARPINTERÍA Y HERRERÍA (12 descripciones)
        "La puerta principal no cierra correctamente, presenta descuadre en la cerradura.",
        "La puerta del closet principal está descuadrada y no cierra de manera correcta.",
        "La ventana del baño no cierra de manera hermética, permitiendo el paso de aire y polvo.",
        "El vidrio de la ventana de la cocina presenta una grieta diagonal de aproximadamente 30cm.",
        "Bisagras de la puerta de la recámara rechinan fuertemente al abrir y cerrar.",
        "Cancel de aluminio del balcón no desliza correctamente, se atora constantemente.",
        "Manija de la ventana de la sala está rota, no permite asegurar el cierre.",
        "Puerta corrediza del closet se salió del riel, no abre ni cierra.",
        "Marco de madera de la ventana presenta polilla, se observa aserrín en el piso.",
        "Cerradura de la puerta del baño no funciona, no se puede cerrar con llave.",
        "Mosquitero de la recámara principal está roto, permite entrada de insectos.",
        "Persianas de la sala no suben ni bajan correctamente, el mecanismo está dañado.",
        
        # CLIMA Y VENTILACIÓN (8 descripciones)
        "El aire acondicionado de la sala no enfría adecuadamente. El compresor enciende pero no genera frío.",
        "El sistema de calefacción no enciende, se requiere revisión del termostato y conexiones.",
        "Minisplit de la recámara presenta fuga de agua, gotea sobre el piso.",
        "El aire acondicionado emite olores desagradables cuando se enciende.",
        "Ruido excesivo en el compresor del minisplit, molesta durante la noche.",
        "El control remoto del aire acondicionado no funciona, no responde a ningún comando.",
        "Falta de ventilación en el baño de servicio, acumulación de humedad y malos olores.",
        "Extractor de aire de la cocina dejó de funcionar, no expulsa el humo.",
        
        # PISOS Y AZULEJOS (6 descripciones)
        "Una loseta del piso de la sala se encuentra desprendida, presenta riesgo de tropiezo.",
        "Azulejo del baño principal se despegó de la pared, dejando hueco visible.",
        "Grieta en el piso de la cocina, se extiende aproximadamente 50cm.",
        "Piso laminado de la recámara presenta levantamiento por humedad.",
        "Junta de losetas del baño está deteriorada, permite filtración de agua.",
        "Hundimiento en el piso de la entrada, posible problema en la cimentación.",
        
        # IMPERMEABILIZACIÓN (5 descripciones)
        "Se detecta filtración de agua en la losa durante época de lluvias, en el área de la terraza.",
        "Goteras en el techo de la recámara principal cuando llueve fuertemente.",
        "Humedad ascendente en la pared del jardín, sube aproximadamente 50cm desde el piso.",
        "Filtraciones en la junta de la losa con el muro perimetral del roof garden.",
        "Impermeabilizante del balcón está cuarteado, permite paso de agua al departamento de abajo."
    ]
    
    elementos.append(Paragraph(descripciones[numero % len(descripciones)], estilos['TextoJustificado']))
    elementos.append(Spacer(1, 0.3*inch))
    
    # Firmas
    elementos.append(Spacer(1, 0.5*inch))
    datos_firma = [
        ["_____________________________", "_____________________________"],
        ["Firma del Propietario", "Firma del Administrador"],
        [fecha.strftime("%d/%m/%Y"), fecha.strftime("%d/%m/%Y")]
    ]
    
    tabla_firma = Table(datos_firma, colWidths=[3*inch, 3*inch])
    tabla_firma.setStyle(TableStyle([
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
    ]))
    
    elementos.append(tabla_firma)
    
    # Footer
    elementos.append(Spacer(1, 0.3*inch))
    elementos.append(Paragraph(
        "<i>URBANOVA - Av. Paseo de la Reforma 505, CDMX - Tel: (55) 5555-1234 - www.urbanova.mx</i>",
        estilos['TextoNormal']
    ))
    
    doc.build(elementos)
    print(f"✓ Generada: {filename}")

def generar_factura_materiales(numero, directorio, categoria=None):
    """Genera una factura de materiales en PDF con proveedor especializado"""
    
    # Determinar categoría basada en el número de factura si no se especifica
    categorias = ["Albañilería", "Pintura", "Plomería", "Mantenimiento"]
    if categoria is None:
        categoria = categorias[(numero - 1) % len(categorias)]
    
    # Seleccionar proveedor de la categoría
    proveedores_cat = PROVEEDORES[categoria]
    proveedor = proveedores_cat[(numero - 1) % len(proveedores_cat)]
    
    # Nombre del archivo con categoría
    cat_abrev = categoria[:3].upper()
    filename = f"{directorio}/factura_{cat_abrev}_{numero:02d}.pdf"
    doc = SimpleDocTemplate(filename, pagesize=letter)
    elementos = []
    estilos = obtener_estilos()
    
    # Encabezado del Proveedor
    elementos.append(Paragraph(proveedor["nombre_comercial"], estilos['TituloUrbanova']))
    elementos.append(Paragraph(proveedor["razon_social"], estilos['SubtituloUrbanova']))
    elementos.append(Paragraph(f"RFC: {proveedor['rfc']} | Régimen General de Ley", estilos['TextoNormal']))
    elementos.append(Paragraph(f"Dirección: {proveedor['direccion']}", estilos['TextoNormal']))
    elementos.append(Paragraph(f"Tel: {proveedor['telefono']} | {proveedor['email']}", estilos['TextoNormal']))
    elementos.append(Spacer(1, 0.2*inch))
    
    # Título y folio
    fecha = datetime.now() - timedelta(days=random.randint(1, 60))
    folio = f"{cat_abrev}-{fecha.year}-{numero:04d}"
    uuid = f"{random.randint(10000000, 99999999)}-{random.randint(1000, 9999)}-{random.randint(1000, 9999)}-{random.randint(10000000, 99999999)}"
    
    elementos.append(Paragraph(f"FACTURA DE MATERIALES - {categoria.upper()}", estilos['SubtituloUrbanova']))
    elementos.append(Paragraph(f"Folio: {folio} | UUID: {uuid}", estilos['TextoNormal']))
    elementos.append(Paragraph(f"Fecha de Emisión: {fecha.strftime('%d/%m/%Y')}", estilos['TextoNormal']))
    elementos.append(Spacer(1, 0.15*inch))
    
    # Datos del cliente (URBANOVA) y proyecto
    desarrollo_idx = numero % len(DESARROLLOS)
    
    datos_factura = [
        ["DATOS DEL CLIENTE", ""],
        ["Razón Social:", "Desarrollos Inmobiliarios Urbanova S.A. de C.V."],
        ["RFC:", "DIU850623HG7"],
        ["Dirección:", "Av. Paseo de la Reforma 505, CDMX"],
        ["", ""],
        ["PROYECTO DESTINO", ""],
        ["Desarrollo:", DESARROLLOS[desarrollo_idx]],
        ["Ubicación:", f"{COLONIAS[desarrollo_idx]}, {CIUDADES[desarrollo_idx]}"],
        ["Orden de Compra:", f"OC-{fecha.year}-{numero:05d}"],
        ["Contacto:", proveedor["contacto"]],
    ]
    
    tabla_datos = Table(datos_factura, colWidths=[1.8*inch, 4.7*inch])
    tabla_datos.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#003366')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('BACKGROUND', (0, 5), (-1, 5), colors.HexColor('#003366')),
        ('TEXTCOLOR', (0, 5), (-1, 5), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTNAME', (0, 5), (-1, 5), 'Helvetica-Bold'),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
        ('SPAN', (0, 0), (-1, 0)),
        ('SPAN', (0, 5), (-1, 5)),
    ]))
    
    elementos.append(tabla_datos)
    elementos.append(Spacer(1, 0.2*inch))
    
    # Conceptos de materiales según categoría
    elementos.append(Paragraph(f"<b>CONCEPTOS - MATERIALES DE {categoria.upper()}:</b>", estilos['SubtituloUrbanova']))
    elementos.append(Spacer(1, 0.1*inch))
    
    # Seleccionar materiales de la categoría correspondiente
    materiales_categoria = MATERIALES_POR_CATEGORIA[categoria]
    num_items = random.randint(5, min(10, len(materiales_categoria)))
    items_seleccionados = random.sample(materiales_categoria, num_items)
    
    datos_items = [["#", "Descripción", "Unidad", "Cant.", "P. Unit.", "Importe"]]
    
    subtotal = 0
    for idx, (descripcion, unidad, precio_unit) in enumerate(items_seleccionados, 1):
        # Cantidades variables según tipo de material
        if unidad in ["Pieza", "Juego", "Kit"]:
            cantidad = random.randint(5, 50)
        elif unidad in ["M²", "M³"]:
            cantidad = random.randint(20, 200)
        elif unidad in ["Metro"]:
            cantidad = random.randint(100, 1000)
        else:
            cantidad = random.randint(20, 300)
            
        importe = cantidad * precio_unit
        subtotal += importe
        
        datos_items.append([
            str(idx),
            descripcion,
            unidad,
            str(cantidad),
            f"${precio_unit:,.2f}",
            f"${importe:,.2f}"
        ])
    
    # Calcular totales
    iva = subtotal * 0.16
    total = subtotal + iva
    
    # Agregar líneas de totales
    datos_items.append(["", "", "", "", "SUBTOTAL:", f"${subtotal:,.2f}"])
    datos_items.append(["", "", "", "", "IVA (16%):", f"${iva:,.2f}"])
    datos_items.append(["", "", "", "", "TOTAL:", f"${total:,.2f}"])
    
    tabla_items = Table(datos_items, colWidths=[0.3*inch, 2.5*inch, 0.8*inch, 0.6*inch, 1*inch, 1.3*inch])
    tabla_items.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#003366')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 9),
        ('ALIGN', (3, 1), (3, -1), 'CENTER'),
        ('ALIGN', (4, 1), (-1, -1), 'RIGHT'),
        ('FONTSIZE', (0, 1), (-1, -1), 8),
        ('GRID', (0, 0), (-1, -4), 0.5, colors.grey),
        ('LINEABOVE', (4, -3), (-1, -3), 1, colors.black),
        ('LINEABOVE', (4, -1), (-1, -1), 2, colors.black),
        ('FONTNAME', (4, -1), (-1, -1), 'Helvetica-Bold'),
    ]))
    
    elementos.append(tabla_items)
    elementos.append(Spacer(1, 0.2*inch))
    
    # Condiciones de pago
    elementos.append(Paragraph("<b>Condiciones de Pago:</b> 30 días a partir de la fecha de factura", estilos['TextoNormal']))
    elementos.append(Paragraph(f"<b>Forma de Pago:</b> Transferencia Electrónica", estilos['TextoNormal']))
    elementos.append(Paragraph(f"<b>Método de Pago:</b> PUE - Pago en Una Sola Exhibición", estilos['TextoNormal']))
    elementos.append(Paragraph(f"<b>Uso CFDI:</b> G03 - Gastos en General", estilos['TextoNormal']))
    elementos.append(Spacer(1, 0.2*inch))
    
    # Footer
    elementos.append(Paragraph(
        "<i>Este documento es una representación impresa de un CFDI versión 4.0. Consulte su versión digital en el portal del SAT.</i>",
        estilos['TextoNormal']
    ))
    elementos.append(Spacer(1, 0.1*inch))
    elementos.append(Paragraph(
        f"<i>{proveedor['nombre_comercial']} - {proveedor['direccion']} - {proveedor['telefono']}</i>",
        estilos['TextoNormal']
    ))
    
    doc.build(elementos)
    print(f"✓ Generada: {filename} [{categoria}]")

def generar_escritura_cliente(numero, directorio):
    """Genera una escritura de propiedad en PDF"""
    filename = f"{directorio}/escritura_propiedad_{numero:02d}.pdf"
    doc = SimpleDocTemplate(filename, pagesize=letter)
    elementos = []
    estilos = obtener_estilos()
    
    # Datos del documento
    notaria_idx = numero % len(NOTARIOS)
    notaria, notario, ciudad_notaria = NOTARIOS[notaria_idx]
    desarrollo_idx = numero % len(DESARROLLOS)
    cliente = NOMBRES_CLIENTES[numero % len(NOMBRES_CLIENTES)]
    fecha = datetime.now() - timedelta(days=random.randint(30, 365))
    num_escritura = 10000 + numero
    
    # Encabezado notarial
    elementos.append(Paragraph(notaria, estilos['TituloUrbanova']))
    elementos.append(Paragraph(f"{notario} - {ciudad_notaria}", estilos['SubtituloUrbanova']))
    elementos.append(Spacer(1, 0.3*inch))
    
    # Número de escritura
    elementos.append(Paragraph(f"ESCRITURA PÚBLICA No. {num_escritura}", estilos['SubtituloUrbanova']))
    elementos.append(Paragraph(f"COMPRAVENTA DE BIEN INMUEBLE", estilos['SubtituloUrbanova']))
    elementos.append(Spacer(1, 0.2*inch))
    
    # Fecha y lugar
    elementos.append(Paragraph(
        f"En la Ciudad de {ciudad_notaria}, a los {fecha.day} días del mes de {fecha.strftime('%B')} del año {fecha.year}, "
        f"ante mí, {notario}, Titular de la {notaria}, comparecen:",
        estilos['TextoJustificado']
    ))
    elementos.append(Spacer(1, 0.2*inch))
    
    # Partes del contrato
    elementos.append(Paragraph("<b>PARTE VENDEDORA:</b>", estilos['SubtituloUrbanova']))
    elementos.append(Paragraph(
        f"<b>DESARROLLOS INMOBILIARIOS URBANOVA S.A. DE C.V.</b>, sociedad mexicana constituida conforme a las leyes "
        f"de los Estados Unidos Mexicanos, representada en este acto por su Apoderado Legal, el C. Juan Carlos Méndez Acosta, "
        f"con RFC: DIU850623HG7, con domicilio fiscal en Av. Paseo de la Reforma 505, Colonia Cuauhtémoc, C.P. 06500, "
        f"Ciudad de México, a quien en lo sucesivo se le denominará como <b>LA VENDEDORA</b>.",
        estilos['TextoJustificado']
    ))
    elementos.append(Spacer(1, 0.2*inch))
    
    elementos.append(Paragraph("<b>PARTE COMPRADORA:</b>", estilos['SubtituloUrbanova']))
    elementos.append(Paragraph(
        f"<b>{cliente.upper()}</b>, de nacionalidad mexicana, mayor de edad, con RFC: {chr(65 + numero % 26)}{chr(65 + (numero*2) % 26)}"
        f"{chr(65 + (numero*3) % 26)}{random.randint(700101, 991231)}XX{numero % 10}, con domicilio para oír y recibir notificaciones "
        f"en {COLONIAS[desarrollo_idx]}, {CIUDADES[desarrollo_idx]}, a quien en lo sucesivo se le denominará como "
        f"<b>EL COMPRADOR</b>.",
        estilos['TextoJustificado']
    ))
    elementos.append(Spacer(1, 0.3*inch))
    
    # Declaraciones
    elementos.append(Paragraph("<b>D E C L A R A C I O N E S</b>", estilos['SubtituloUrbanova']))
    elementos.append(Spacer(1, 0.1*inch))
    
    elementos.append(Paragraph("<b>I. Declara LA VENDEDORA:</b>", estilos['TextoNormal']))
    elementos.append(Paragraph(
        "Que es legítima propietaria del inmueble objeto de esta escritura, mismo que se identifica en la "
        "cláusula PRIMERA de este instrumento, libre de todo gravamen y afectación.",
        estilos['TextoJustificado']
    ))
    elementos.append(Spacer(1, 0.1*inch))
    
    elementos.append(Paragraph("<b>II. Declara EL COMPRADOR:</b>", estilos['TextoNormal']))
    elementos.append(Paragraph(
        "Que conoce física y jurídicamente el inmueble objeto de esta compraventa, que se encuentra en perfecto "
        "estado de conservación y habitabilidad, y que es su voluntad adquirirlo en los términos establecidos.",
        estilos['TextoJustificado']
    ))
    elementos.append(Spacer(1, 0.2*inch))
    
    # Cláusulas
    elementos.append(Paragraph("<b>C L Á U S U L A S</b>", estilos['SubtituloUrbanova']))
    elementos.append(Spacer(1, 0.1*inch))
    
    # Datos del inmueble
    precio = random.randint(2500000, 8500000)
    superficie = random.randint(65, 180)
    num_depto = random.randint(100, 1500)
    
    elementos.append(Paragraph(
        f"<b>PRIMERA. IDENTIFICACIÓN DEL INMUEBLE.</b> El bien inmueble objeto de esta compraventa se describe como sigue: "
        f"Departamento número {num_depto}, ubicado en el desarrollo <b>{DESARROLLOS[desarrollo_idx]}</b>, "
        f"situado en {COLONIAS[desarrollo_idx]}, {CIUDADES[desarrollo_idx]}. "
        f"Con una superficie aproximada de <b>{superficie} metros cuadrados</b>. "
        f"Cuenta con {random.randint(2, 4)} recámaras, {random.randint(2, 3)} baños completos, sala, comedor, cocina integral, "
        f"área de lavado y {random.randint(1, 2)} cajón(es) de estacionamiento.",
        estilos['TextoJustificado']
    ))
    elementos.append(Spacer(1, 0.15*inch))
    
    elementos.append(Paragraph(
        f"<b>SEGUNDA. PRECIO Y FORMA DE PAGO.</b> El precio pactado por la compraventa del inmueble descrito es de "
        f"<b>${precio:,.2f} M.N. (SON: {numero_a_letras(precio)} PESOS 00/100 M.N.)</b>. "
        f"El comprador manifiesta haber pagado esta cantidad a entera satisfacción de la vendedora, mediante "
        f"transferencia bancaria realizada el día {(fecha - timedelta(days=5)).strftime('%d de %B de %Y')}.",
        estilos['TextoJustificado']
    ))
    elementos.append(Spacer(1, 0.15*inch))
    
    elementos.append(Paragraph(
        f"<b>TERCERA. TRANSMISIÓN DE DOMINIO.</b> Con la firma de la presente escritura, LA VENDEDORA transmite "
        f"a favor de EL COMPRADOR la propiedad, posesión, dominio y demás derechos inherentes al inmueble descrito, "
        f"quedando éste como único y legítimo propietario a partir de esta fecha.",
        estilos['TextoJustificado']
    ))
    elementos.append(Spacer(1, 0.3*inch))
    
    # Firmas
    elementos.append(Spacer(1, 0.4*inch))
    datos_firma = [
        ["_____________________________", "_____________________________"],
        ["LA VENDEDORA", "EL COMPRADOR"],
        ["Desarrollos Urbanova S.A. de C.V.", cliente],
        ["", ""],
        ["", "_____________________________"],
        ["", "DA FE"],
        ["", notario],
        ["", notaria]
    ]
    
    tabla_firma = Table(datos_firma, colWidths=[3.25*inch, 3.25*inch])
    tabla_firma.setStyle(TableStyle([
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTSIZE', (0, 0), (-1, -1), 8),
        ('FONTNAME', (0, 1), (-1, 1), 'Helvetica-Bold'),
        ('FONTNAME', (0, 5), (-1, 5), 'Helvetica-Bold'),
    ]))
    
    elementos.append(tabla_firma)
    
    # Footer
    elementos.append(Spacer(1, 0.2*inch))
    elementos.append(Paragraph(
        f"<i>Esta es una copia simple de la Escritura Pública No. {num_escritura}. El original se encuentra en el protocolo de la {notaria}.</i>",
        estilos['TextoNormal']
    ))
    
    doc.build(elementos)
    print(f"✓ Generada: {filename}")

def numero_a_letras(numero):
    """Convierte un número a su representación en letras (simplificado)"""
    millones = numero // 1000000
    resto = numero % 1000000
    
    if millones == 1:
        return f"UN MILLÓN {int(resto/1000):03d} MIL"
    elif millones > 1:
        return f"{millones} MILLONES {int(resto/1000):03d} MIL"
    else:
        return f"{int(numero/1000):03d} MIL"

# ============================================================================
# FUNCIÓN PRINCIPAL
# ============================================================================

def main():
    """Función principal para generar todos los documentos"""
    print("\n" + "="*70)
    print("GENERADOR DE DOCUMENTOS PDF - URBANOVA")
    print("Desarrollos Inmobiliarios Urbanova S.A. de C.V.")
    print("="*70 + "\n")
    
    directorio = crear_directorio_salida()
    print(f"📁 Directorio de salida: {directorio}\n")
    
    # =========================================================================
    # SOLICITUDES DE REPARACIÓN: 65 documentos (15 originales + 50 nuevos)
    # =========================================================================
    total_solicitudes = 65
    print(f"📋 Generando {total_solicitudes} Solicitudes de Reparación...")
    for i in range(1, total_solicitudes + 1):
        generar_solicitud_reparacion(i, directorio)
        if i % 10 == 0:
            print(f"   ... {i} solicitudes generadas")
    
    # =========================================================================
    # FACTURAS DE MATERIALES: 65 documentos (15 originales + 50 nuevos)
    # Distribuidas equitativamente entre las 4 categorías
    # =========================================================================
    categorias = ["Albañilería", "Pintura", "Plomería", "Mantenimiento"]
    facturas_por_categoria = {cat: 0 for cat in categorias}
    total_facturas = 65
    
    print(f"\n💰 Generando {total_facturas} Facturas de Materiales por Categoría...")
    
    # Distribuir: 17 Albañilería, 16 Pintura, 16 Plomería, 16 Mantenimiento = 65
    distribucion = {"Albañilería": 17, "Pintura": 16, "Plomería": 16, "Mantenimiento": 16}
    
    factura_num = 1
    for categoria in categorias:
        num_facturas = distribucion[categoria]
        print(f"\n  🔧 {categoria} ({num_facturas} facturas):")
        for i in range(1, num_facturas + 1):
            generar_factura_materiales(factura_num, directorio, categoria)
            facturas_por_categoria[categoria] += 1
            factura_num += 1
            if facturas_por_categoria[categoria] % 5 == 0:
                print(f"      ... {facturas_por_categoria[categoria]} facturas de {categoria}")
    
    # =========================================================================
    # ESCRITURAS DE PROPIEDAD: 15 documentos (sin cambios)
    # =========================================================================
    total_escrituras = 15
    print(f"\n📜 Generando {total_escrituras} Escrituras de Propiedad...")
    for i in range(1, total_escrituras + 1):
        generar_escritura_cliente(i, directorio)
    
    # =========================================================================
    # RESUMEN FINAL
    # =========================================================================
    total_docs = total_solicitudes + total_facturas + total_escrituras
    
    print("\n" + "="*70)
    print("✅ PROCESO COMPLETADO")
    print(f"Total de documentos generados: {total_docs}")
    print(f"\n  📋 Solicitudes de Reparación: {total_solicitudes}")
    print(f"\n  💰 Facturas de Materiales: {total_facturas}")
    for cat, num in facturas_por_categoria.items():
        print(f"      • {cat}: {num}")
    print(f"\n  📜 Escrituras de Propiedad: {total_escrituras}")
    print(f"\n📂 Ubicación: {os.path.abspath(directorio)}")
    print("="*70 + "\n")

if __name__ == "__main__":
    main()

