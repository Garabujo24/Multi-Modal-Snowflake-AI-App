"""
Generador de Recibos y Estados de Cuenta - Versión de Prueba
Cliente: Unstructured Docs
Propósito: Pruebas de Cortex Search con diversos documentos no estructurados

Este script genera:
- Recibos de nómina (para personas físicas)
- Recibos de agua (CFE)
- Recibos de luz (CFE)
- Estados de cuenta bancarios

NOTA: Estos documentos son ÚNICAMENTE para pruebas y no tienen validez legal.
"""

from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from datetime import datetime, timedelta
import random
import os
import io
import qrcode
from PIL import Image as PILImage, ImageDraw, ImageFont

# Crear directorios de salida
os.makedirs("output/recibos_nomina/pdfs", exist_ok=True)
os.makedirs("output/recibos_nomina/imagenes", exist_ok=True)
os.makedirs("output/recibos_agua/pdfs", exist_ok=True)
os.makedirs("output/recibos_agua/imagenes", exist_ok=True)
os.makedirs("output/recibos_luz/pdfs", exist_ok=True)
os.makedirs("output/recibos_luz/imagenes", exist_ok=True)
os.makedirs("output/estados_cuenta/pdfs", exist_ok=True)
os.makedirs("output/estados_cuenta/imagenes", exist_ok=True)

# Importar datos de contribuyentes del script original
CONTRIBUYENTES = [
    {
        "numero": 1,
        "tipo": "Persona Moral",
        "nombre": "TECNOLOGÍA AVANZADA DEL SURESTE SA DE CV",
        "rfc": "TAS180523KL8",
        "curp": None,
        "estado": "Yucatán",
        "municipio": "Mérida",
        "calle": "Paseo de Montejo",
        "num_ext": "485",
        "cp": "97000",
        "empleados": 45
    },
    {
        "numero": 2,
        "tipo": "Persona Física",
        "nombre": "MARÍA GUADALUPE HERNÁNDEZ SÁNCHEZ",
        "rfc": "HESM850614J39",
        "curp": "HESM850614MDFRNR09",
        "estado": "Jalisco",
        "municipio": "Guadalajara",
        "calle": "Avenida Américas",
        "num_ext": "1234",
        "cp": "44160",
        "empleador": "CONSULTORA MH SC",
        "puesto": "Directora General"
    },
    {
        "numero": 3,
        "tipo": "Persona Moral",
        "nombre": "COMERCIALIZADORA DE ALIMENTOS DEL NORTE SA DE CV",
        "rfc": "CAN200815RT6",
        "curp": None,
        "estado": "Nuevo León",
        "municipio": "Monterrey",
        "calle": "Avenida Gómez Morín",
        "num_ext": "2450",
        "cp": "66260",
        "empleados": 120
    },
    {
        "numero": 4,
        "tipo": "Persona Física",
        "nombre": "JOSÉ ROBERTO GARCÍA LÓPEZ",
        "rfc": "GALR920327HG5",
        "curp": "GALR920327HDFRPS06",
        "estado": "Ciudad de México",
        "municipio": "Benito Juárez",
        "calle": "Eje 7 Sur",
        "num_ext": "678",
        "cp": "03100",
        "empleador": "SERVICIOS GARCÍA LÓPEZ",
        "puesto": "Consultor Independiente"
    },
    {
        "numero": 5,
        "tipo": "Persona Moral",
        "nombre": "CONSTRUCTORA INDUSTRIAL BAJÍO SA DE CV",
        "rfc": "CIB150309MN2",
        "curp": None,
        "estado": "Guanajuato",
        "municipio": "León",
        "calle": "Boulevard Aeropuerto",
        "num_ext": "3890",
        "cp": "37290",
        "empleados": 85
    },
    {
        "numero": 6,
        "tipo": "Persona Física",
        "nombre": "ANA PATRICIA MARTÍNEZ RODRÍGUEZ",
        "rfc": "MARA881205QT7",
        "curp": "MARA881205MSLRDN02",
        "estado": "Puebla",
        "municipio": "Puebla",
        "calle": "Avenida Atlixcáyotl",
        "num_ext": "5600",
        "cp": "72830",
        "empleador": "GRUPO FINANCIERO NACIONAL",
        "puesto": "Gerente de Proyectos"
    },
    {
        "numero": 7,
        "tipo": "Persona Moral",
        "nombre": "SERVICIOS LOGÍSTICOS DEL PACÍFICO SA DE CV",
        "rfc": "SLP190722BC4",
        "curp": None,
        "estado": "Sinaloa",
        "municipio": "Culiacán",
        "calle": "Boulevard Emiliano Zapata",
        "num_ext": "1500",
        "cp": "80020",
        "empleados": 65
    },
    {
        "numero": 8,
        "tipo": "Persona Física",
        "nombre": "CARLOS EDUARDO RAMÍREZ FERNÁNDEZ",
        "rfc": "RAFC900518KP9",
        "curp": "RAFC900518HQTMRR04",
        "estado": "Querétaro",
        "municipio": "Querétaro",
        "calle": "Avenida Constituyentes",
        "num_ext": "89",
        "cp": "76090",
        "empleador": "ARQUITECTURA Y DISEÑO RAMÍREZ",
        "puesto": "Arquitecto Principal"
    },
    {
        "numero": 9,
        "tipo": "Persona Moral",
        "nombre": "DESARROLLOS INMOBILIARIOS CANCÚN SA DE CV",
        "rfc": "DIC170411XY8",
        "curp": None,
        "estado": "Quintana Roo",
        "municipio": "Benito Juárez",
        "calle": "Avenida Tulum",
        "num_ext": "245",
        "cp": "77500",
        "empleados": 35
    },
    {
        "numero": 10,
        "tipo": "Persona Física",
        "nombre": "LAURA ISABEL TORRES MENDOZA",
        "rfc": "TOML870923FM2",
        "curp": "TOML870923MCSRND08",
        "estado": "Veracruz",
        "municipio": "Xalapa",
        "calle": "Calle Úrsulo Galván",
        "num_ext": "34",
        "cp": "91110",
        "empleador": "DESPACHO TORRES Y ASOCIADOS",
        "puesto": "Contadora Pública"
    },
    {
        "numero": 11,
        "tipo": "Persona Moral",
        "nombre": "MANUFACTURAS TEXTILES DE OCCIDENTE SA DE CV",
        "rfc": "MTO140627GH3",
        "curp": None,
        "estado": "Jalisco",
        "municipio": "Tlaquepaque",
        "calle": "Carretera a Chapala",
        "num_ext": "6700",
        "cp": "45588",
        "empleados": 150
    },
    {
        "numero": 12,
        "tipo": "Persona Física",
        "nombre": "FERNANDO JAVIER LÓPEZ CASTILLO",
        "rfc": "LOCF830712MK6",
        "curp": "LOCF830712HSLPSR03",
        "estado": "San Luis Potosí",
        "municipio": "San Luis Potosí",
        "calle": "Avenida Venustiano Carranza",
        "num_ext": "2315",
        "cp": "78269",
        "empleador": "SERVICIOS CONTABLES LÓPEZ",
        "puesto": "Contador Independiente"
    },
    {
        "numero": 13,
        "tipo": "Persona Moral",
        "nombre": "EXPORTADORA AGRÍCOLA DE SONORA SA DE CV",
        "rfc": "EAS160105PL9",
        "curp": None,
        "estado": "Sonora",
        "municipio": "Hermosillo",
        "calle": "Boulevard Luis Encinas",
        "num_ext": "890",
        "cp": "83190",
        "empleados": 95
    }
]

def generar_qr_code(data):
    """Genera un código QR"""
    qr = qrcode.QRCode(version=1, box_size=3, border=1)
    qr.add_data(data)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")
    buffer = io.BytesIO()
    img.save(buffer, format='PNG')
    buffer.seek(0)
    return buffer

def crear_recibo_nomina(persona, periodo, numero_global):
    """Genera un recibo de nómina para una persona física"""
    
    if persona['tipo'] != 'Persona Física':
        return None
    
    # Generar datos del periodo
    mes = periodo['mes']
    año = periodo['año']
    periodo_str = f"{mes:02d}/{año}"
    
    # Calcular salarios
    salario_base = random.randint(15000, 85000)
    dias_trabajados = random.choice([15, 30])
    salario_periodo = salario_base if dias_trabajados == 30 else salario_base / 2
    
    # Prestaciones
    vales_despensa = salario_base * 0.10
    fondo_ahorro = salario_base * 0.06
    prima_vacacional = random.choice([0, salario_base * 0.05])
    
    # Deducciones
    isr = salario_periodo * random.uniform(0.10, 0.20)
    imss = salario_periodo * 0.0236
    infonavit = random.choice([0, salario_periodo * 0.05])
    
    percepciones_total = salario_periodo + vales_despensa + fondo_ahorro + prima_vacacional
    deducciones_total = isr + imss + infonavit
    neto = percepciones_total - deducciones_total
    
    filename_pdf = f"output/recibos_nomina/pdfs/NOMINA_{numero_global:03d}_{persona['rfc']}_{año}{mes:02d}.pdf"
    
    c = canvas.Canvas(filename_pdf, pagesize=letter)
    width, height = letter
    
    # --- ENCABEZADO ---
    c.setFillColorRGB(0.2, 0.4, 0.8)
    c.rect(0, height - 80, width, 80, fill=True, stroke=False)
    
    c.setFillColorRGB(1, 1, 1)
    c.setFont("Helvetica-Bold", 18)
    c.drawString(50, height - 35, persona.get('empleador', 'EMPRESA EMPLEADORA SA DE CV'))
    c.setFont("Helvetica", 10)
    c.drawString(50, height - 55, "RECIBO DE NÓMINA")
    
    c.setFillColorRGB(0, 0, 0)
    c.setFont("Helvetica", 9)
    c.drawRightString(width - 50, height - 35, f"Periodo: {periodo_str}")
    c.drawRightString(width - 50, height - 50, f"Folio: NOM-{año}{mes:02d}-{random.randint(1000, 9999)}")
    c.drawRightString(width - 50, height - 65, f"Fecha de pago: {periodo['fecha_pago']}")
    
    # --- DATOS DEL EMPLEADO ---
    y_pos = height - 110
    c.setFont("Helvetica-Bold", 11)
    c.drawString(50, y_pos, "DATOS DEL EMPLEADO")
    c.line(50, y_pos - 5, width - 50, y_pos - 5)
    
    y_pos -= 25
    c.setFont("Helvetica-Bold", 9)
    c.drawString(50, y_pos, "Nombre:")
    c.setFont("Helvetica", 9)
    c.drawString(150, y_pos, persona['nombre'])
    
    y_pos -= 15
    c.setFont("Helvetica-Bold", 9)
    c.drawString(50, y_pos, "RFC:")
    c.setFont("Helvetica", 9)
    c.drawString(150, y_pos, persona['rfc'])
    
    c.setFont("Helvetica-Bold", 9)
    c.drawString(300, y_pos, "CURP:")
    c.setFont("Helvetica", 9)
    c.drawString(400, y_pos, persona['curp'])
    
    y_pos -= 15
    c.setFont("Helvetica-Bold", 9)
    c.drawString(50, y_pos, "Puesto:")
    c.setFont("Helvetica", 9)
    c.drawString(150, y_pos, persona.get('puesto', 'Empleado'))
    
    c.setFont("Helvetica-Bold", 9)
    c.drawString(300, y_pos, "Días trabajados:")
    c.setFont("Helvetica", 9)
    c.drawString(400, y_pos, str(dias_trabajados))
    
    # --- PERCEPCIONES ---
    y_pos -= 35
    c.setFont("Helvetica-Bold", 11)
    c.drawString(50, y_pos, "PERCEPCIONES")
    c.line(50, y_pos - 5, 280, y_pos - 5)
    
    y_pos -= 20
    c.setFont("Helvetica", 9)
    c.drawString(60, y_pos, f"Sueldo base")
    c.drawRightString(270, y_pos, f"${salario_periodo:,.2f}")
    
    y_pos -= 15
    c.drawString(60, y_pos, f"Vales de despensa")
    c.drawRightString(270, y_pos, f"${vales_despensa:,.2f}")
    
    y_pos -= 15
    c.drawString(60, y_pos, f"Fondo de ahorro")
    c.drawRightString(270, y_pos, f"${fondo_ahorro:,.2f}")
    
    if prima_vacacional > 0:
        y_pos -= 15
        c.drawString(60, y_pos, f"Prima vacacional")
        c.drawRightString(270, y_pos, f"${prima_vacacional:,.2f}")
    
    y_pos -= 20
    c.setFont("Helvetica-Bold", 10)
    c.drawString(60, y_pos, "Total percepciones:")
    c.drawRightString(270, y_pos, f"${percepciones_total:,.2f}")
    
    # --- DEDUCCIONES ---
    y_pos_ded = height - 110 - 25 - 15 - 15 - 35
    c.setFont("Helvetica-Bold", 11)
    c.drawString(320, y_pos_ded, "DEDUCCIONES")
    c.line(320, y_pos_ded - 5, width - 50, y_pos_ded - 5)
    
    y_pos_ded -= 20
    c.setFont("Helvetica", 9)
    c.drawString(330, y_pos_ded, f"ISR")
    c.drawRightString(width - 60, y_pos_ded, f"${isr:,.2f}")
    
    y_pos_ded -= 15
    c.drawString(330, y_pos_ded, f"IMSS")
    c.drawRightString(width - 60, y_pos_ded, f"${imss:,.2f}")
    
    if infonavit > 0:
        y_pos_ded -= 15
        c.drawString(330, y_pos_ded, f"INFONAVIT")
        c.drawRightString(width - 60, y_pos_ded, f"${infonavit:,.2f}")
    
    y_pos_ded -= 20
    c.setFont("Helvetica-Bold", 10)
    c.drawString(330, y_pos_ded, "Total deducciones:")
    c.drawRightString(width - 60, y_pos_ded, f"${deducciones_total:,.2f}")
    
    # --- NETO A PAGAR ---
    y_pos = min(y_pos, y_pos_ded) - 30
    c.setFillColorRGB(0.9, 0.95, 1.0)
    c.rect(50, y_pos - 25, width - 100, 35, fill=True, stroke=True)
    
    c.setFillColorRGB(0, 0, 0)
    c.setFont("Helvetica-Bold", 14)
    c.drawString(60, y_pos - 10, "NETO A PAGAR:")
    c.drawRightString(width - 60, y_pos - 10, f"${neto:,.2f}")
    
    # --- PIE DE PÁGINA ---
    c.setFont("Helvetica", 7)
    c.drawString(50, 60, f"Este recibo de nómina ampara el pago correspondiente al periodo {periodo_str}.")
    c.drawString(50, 50, f"Forma de pago: Transferencia bancaria")
    
    c.setFont("Helvetica-Bold", 7)
    c.setFillColorRGB(0.8, 0, 0)
    c.drawCentredString(width/2, 25, "*** DOCUMENTO DE PRUEBA - SIN VALIDEZ OFICIAL ***")
    
    c.save()
    print(f"✓ Nómina generada: {filename_pdf}")
    
    # Generar imagen
    generar_imagen_documento(filename_pdf, numero_global, persona['rfc'], f"{año}{mes:02d}", "NOMINA", "RECIBO DE NÓMINA")
    
    return filename_pdf

def crear_recibo_agua(entidad, mes_año, numero_global):
    """Genera un recibo de agua (COMAPA)"""
    
    mes, año = mes_año
    periodo_str = f"{mes:02d}/{año}"
    
    # Datos del recibo
    num_servicio = f"{random.randint(100000, 999999)}"
    consumo_m3 = random.randint(10, 150)
    tarifa_por_m3 = random.uniform(8.0, 15.0)
    cargo_fijo = random.uniform(50, 120)
    alcantarillado = consumo_m3 * tarifa_por_m3 * 0.35
    
    subtotal = (consumo_m3 * tarifa_por_m3) + cargo_fijo + alcantarillado
    iva = subtotal * 0.16
    total = subtotal + iva
    
    fecha_vencimiento = (datetime(año, mes, 1) + timedelta(days=20)).strftime("%d/%m/%Y")
    
    filename_pdf = f"output/recibos_agua/pdfs/AGUA_{numero_global:03d}_{entidad['rfc']}_{año}{mes:02d}.pdf"
    
    c = canvas.Canvas(filename_pdf, pagesize=letter)
    width, height = letter
    
    # --- ENCABEZADO ---
    c.setFillColorRGB(0.0, 0.4, 0.8)
    c.rect(0, height - 100, width, 100, fill=True, stroke=False)
    
    c.setFillColorRGB(1, 1, 1)
    c.setFont("Helvetica-Bold", 20)
    c.drawString(50, height - 40, "COMAPA")
    c.setFont("Helvetica", 11)
    c.drawString(50, height - 60, f"Comisión Municipal de Agua Potable y Alcantarillado")
    c.drawString(50, height - 75, f"{entidad['municipio']}, {entidad['estado']}")
    
    c.setFont("Helvetica-Bold", 10)
    c.drawRightString(width - 50, height - 40, f"Periodo: {periodo_str}")
    c.drawRightString(width - 50, height - 55, f"No. Servicio: {num_servicio}")
    c.drawRightString(width - 50, height - 70, f"Vence: {fecha_vencimiento}")
    
    # --- DATOS DEL USUARIO ---
    y_pos = height - 130
    c.setFillColorRGB(0, 0, 0)
    c.setFont("Helvetica-Bold", 11)
    c.drawString(50, y_pos, "DATOS DEL USUARIO")
    c.line(50, y_pos - 5, width - 50, y_pos - 5)
    
    y_pos -= 25
    c.setFont("Helvetica-Bold", 9)
    c.drawString(50, y_pos, "Nombre/Razón Social:")
    c.setFont("Helvetica", 9)
    c.drawString(180, y_pos, entidad['nombre'][:60])
    
    y_pos -= 15
    c.setFont("Helvetica-Bold", 9)
    c.drawString(50, y_pos, "Domicilio:")
    c.setFont("Helvetica", 9)
    c.drawString(180, y_pos, f"{entidad['calle']} {entidad['num_ext']}, CP {entidad['cp']}")
    
    y_pos -= 15
    c.setFont("Helvetica-Bold", 9)
    c.drawString(50, y_pos, "RFC:")
    c.setFont("Helvetica", 9)
    c.drawString(180, y_pos, entidad['rfc'])
    
    # --- DETALLE DE CONSUMO ---
    y_pos -= 35
    c.setFont("Helvetica-Bold", 11)
    c.drawString(50, y_pos, "DETALLE DE CONSUMO")
    c.line(50, y_pos - 5, width - 50, y_pos - 5)
    
    y_pos -= 25
    c.setFont("Helvetica", 9)
    c.drawString(60, y_pos, "Consumo de agua")
    c.drawString(250, y_pos, f"{consumo_m3} m³")
    c.drawRightString(width - 60, y_pos, f"${consumo_m3 * tarifa_por_m3:,.2f}")
    
    y_pos -= 15
    c.drawString(60, y_pos, "Cargo fijo")
    c.drawRightString(width - 60, y_pos, f"${cargo_fijo:,.2f}")
    
    y_pos -= 15
    c.drawString(60, y_pos, "Alcantarillado y saneamiento")
    c.drawRightString(width - 60, y_pos, f"${alcantarillado:,.2f}")
    
    y_pos -= 15
    c.drawString(60, y_pos, "Subtotal")
    c.drawRightString(width - 60, y_pos, f"${subtotal:,.2f}")
    
    y_pos -= 15
    c.drawString(60, y_pos, "IVA (16%)")
    c.drawRightString(width - 60, y_pos, f"${iva:,.2f}")
    
    y_pos -= 20
    c.setFont("Helvetica-Bold", 12)
    c.drawString(60, y_pos, "TOTAL A PAGAR:")
    c.drawRightString(width - 60, y_pos, f"${total:,.2f}")
    
    # --- INFORMACIÓN DE PAGO ---
    y_pos -= 40
    c.setFillColorRGB(0.95, 0.95, 0.95)
    c.rect(50, y_pos - 60, width - 100, 70, fill=True, stroke=True)
    
    c.setFillColorRGB(0, 0, 0)
    c.setFont("Helvetica-Bold", 10)
    c.drawString(60, y_pos - 15, "FORMAS DE PAGO")
    
    c.setFont("Helvetica", 8)
    c.drawString(60, y_pos - 30, "• En sucursales bancarias con referencia")
    c.drawString(60, y_pos - 42, "• Tiendas de conveniencia (OXXO, 7-Eleven)")
    c.drawString(60, y_pos - 54, "• Banca en línea - Referencia: " + num_servicio)
    
    # --- PIE ---
    c.setFont("Helvetica", 7)
    c.drawString(50, 50, "Conserve este recibo como comprobante de pago.")
    c.drawString(50, 40, f"Línea de atención: 01-800-AGUA-{random.randint(100, 999)}")
    
    c.setFont("Helvetica-Bold", 7)
    c.setFillColorRGB(0.8, 0, 0)
    c.drawCentredString(width/2, 25, "*** DOCUMENTO DE PRUEBA - SIN VALIDEZ OFICIAL ***")
    
    c.save()
    print(f"✓ Recibo agua generado: {filename_pdf}")
    
    generar_imagen_documento(filename_pdf, numero_global, entidad['rfc'], f"{año}{mes:02d}", "AGUA", "RECIBO DE AGUA")
    
    return filename_pdf

def crear_recibo_luz(entidad, mes_año, numero_global):
    """Genera un recibo de luz (CFE)"""
    
    mes, año = mes_año
    periodo_str = f"{mes:02d}/{año}"
    
    # Datos del recibo
    num_servicio = f"{random.randint(100000000000, 999999999999)}"
    consumo_kwh = random.randint(150, 2500)
    tarifa_por_kwh = random.uniform(0.80, 2.50)
    cargo_fijo = random.uniform(30, 80)
    
    # Calcular DAC (Doméstico de Alto Consumo) si aplica
    limite_basico = 300
    if consumo_kwh > limite_basico:
        consumo_basico = limite_basico * tarifa_por_kwh
        consumo_excedente = (consumo_kwh - limite_basico) * (tarifa_por_kwh * 3)
        subtotal = consumo_basico + consumo_excedente + cargo_fijo
    else:
        subtotal = (consumo_kwh * tarifa_por_kwh) + cargo_fijo
    
    total = subtotal  # CFE no cobra IVA en tarifa doméstica
    
    fecha_vencimiento = (datetime(año, mes, 1) + timedelta(days=15)).strftime("%d/%m/%Y")
    
    filename_pdf = f"output/recibos_luz/pdfs/LUZ_{numero_global:03d}_{entidad['rfc']}_{año}{mes:02d}.pdf"
    
    c = canvas.Canvas(filename_pdf, pagesize=letter)
    width, height = letter
    
    # --- ENCABEZADO CFE ---
    c.setFillColorRGB(0.0, 0.6, 0.2)
    c.rect(0, height - 100, width, 100, fill=True, stroke=False)
    
    c.setFillColorRGB(1, 1, 1)
    c.setFont("Helvetica-Bold", 24)
    c.drawString(50, height - 45, "CFE")
    c.setFont("Helvetica", 11)
    c.drawString(120, height - 45, "Comisión Federal de Electricidad")
    c.drawString(50, height - 65, "RECIBO DE ENERGÍA ELÉCTRICA")
    
    c.setFont("Helvetica-Bold", 9)
    c.drawRightString(width - 50, height - 35, f"Periodo: {periodo_str}")
    c.drawRightString(width - 50, height - 50, f"No. Servicio: {num_servicio}")
    c.drawRightString(width - 50, height - 65, f"Fecha límite de pago: {fecha_vencimiento}")
    c.drawRightString(width - 50, height - 80, f"RMU: {random.randint(100000, 999999)}")
    
    # --- DATOS DEL USUARIO ---
    y_pos = height - 130
    c.setFillColorRGB(0, 0, 0)
    c.setFont("Helvetica-Bold", 11)
    c.drawString(50, y_pos, "DATOS DEL USUARIO")
    c.line(50, y_pos - 5, width - 50, y_pos - 5)
    
    y_pos -= 25
    c.setFont("Helvetica-Bold", 9)
    c.drawString(50, y_pos, "Nombre/Razón Social:")
    c.setFont("Helvetica", 8)
    c.drawString(180, y_pos, entidad['nombre'][:55])
    
    y_pos -= 15
    c.setFont("Helvetica-Bold", 9)
    c.drawString(50, y_pos, "Dirección del servicio:")
    c.setFont("Helvetica", 8)
    c.drawString(180, y_pos, f"{entidad['calle']} {entidad['num_ext']}")
    
    y_pos -= 12
    c.drawString(180, y_pos, f"{entidad['municipio']}, {entidad['estado']}, CP {entidad['cp']}")
    
    y_pos -= 15
    c.setFont("Helvetica-Bold", 9)
    c.drawString(50, y_pos, "RFC:")
    c.setFont("Helvetica", 9)
    c.drawString(180, y_pos, entidad['rfc'])
    
    c.setFont("Helvetica-Bold", 9)
    c.drawString(350, y_pos, "Tarifa:")
    c.setFont("Helvetica", 9)
    tarifa_tipo = "DAC" if consumo_kwh > limite_basico else "1C"
    c.drawString(400, y_pos, tarifa_tipo)
    
    # --- HISTORIAL DE CONSUMO ---
    y_pos -= 35
    c.setFont("Helvetica-Bold", 11)
    c.drawString(50, y_pos, "HISTORIAL DE CONSUMO")
    c.line(50, y_pos - 5, width - 50, y_pos - 5)
    
    y_pos -= 25
    c.setFont("Helvetica", 8)
    meses_previos = ["Ene", "Feb", "Mar", "Abr", "May", "Jun"]
    consumos_hist = [random.randint(100, consumo_kwh + 200) for _ in range(6)]
    
    x_start = 60
    for i, (mes_name, cons) in enumerate(zip(meses_previos, consumos_hist)):
        c.drawString(x_start + (i * 85), y_pos, f"{mes_name}: {cons} kWh")
    
    # --- DETALLE DE CONSUMO ---
    y_pos -= 35
    c.setFont("Helvetica-Bold", 11)
    c.drawString(50, y_pos, "DETALLE DE CARGOS")
    c.line(50, y_pos - 5, width - 50, y_pos - 5)
    
    y_pos -= 25
    c.setFont("Helvetica", 9)
    c.drawString(60, y_pos, f"Consumo del periodo")
    c.drawString(250, y_pos, f"{consumo_kwh} kWh")
    c.drawRightString(width - 60, y_pos, f"${(consumo_kwh * tarifa_por_kwh):,.2f}")
    
    if consumo_kwh > limite_basico:
        y_pos -= 15
        c.drawString(60, y_pos, f"Consumo excedente (DAC)")
        c.drawRightString(width - 60, y_pos, f"${consumo_excedente:,.2f}")
    
    y_pos -= 15
    c.drawString(60, y_pos, "Servicios adicionales")
    c.drawRightString(width - 60, y_pos, f"${cargo_fijo:,.2f}")
    
    y_pos -= 20
    c.setFillColorRGB(0.9, 1.0, 0.9)
    c.rect(50, y_pos - 20, width - 100, 30, fill=True, stroke=True)
    
    c.setFillColorRGB(0, 0, 0)
    c.setFont("Helvetica-Bold", 13)
    c.drawString(60, y_pos - 8, "TOTAL A PAGAR:")
    c.drawRightString(width - 60, y_pos - 8, f"${total:,.2f}")
    
    # --- CÓDIGO DE BARRAS SIMULADO ---
    y_pos -= 50
    c.setFont("Helvetica", 7)
    c.drawString(50, y_pos, "Código de barras para pago:")
    c.rect(50, y_pos - 25, 300, 20, stroke=True)
    
    # --- PIE ---
    c.setFont("Helvetica", 7)
    c.drawString(50, 60, "Puede pagar en: Bancos, Tiendas de conveniencia, CFEMático, App CFE Contigo")
    c.drawString(50, 50, f"Atención a clientes: 071")
    c.drawString(50, 40, "Este recibo incluye el subsidio aplicable a su región.")
    
    c.setFont("Helvetica-Bold", 7)
    c.setFillColorRGB(0.8, 0, 0)
    c.drawCentredString(width/2, 25, "*** DOCUMENTO DE PRUEBA - SIN VALIDEZ OFICIAL ***")
    
    c.save()
    print(f"✓ Recibo luz generado: {filename_pdf}")
    
    generar_imagen_documento(filename_pdf, numero_global, entidad['rfc'], f"{año}{mes:02d}", "LUZ", "RECIBO DE LUZ")
    
    return filename_pdf

def crear_estado_cuenta(entidad, mes_año, numero_global):
    """Genera un estado de cuenta bancario"""
    
    mes, año = mes_año
    periodo_str = f"{mes:02d}/{año}"
    
    # Datos de la cuenta
    num_cuenta = f"****{random.randint(1000, 9999)}"
    clabe = f"012180{random.randint(1000000000, 9999999999)}"
    saldo_inicial = random.uniform(5000, 500000)
    
    # Generar movimientos
    movimientos = []
    saldo_actual = saldo_inicial
    
    for dia in range(1, random.randint(8, 15)):
        tipo = random.choice(['DEPOSITO', 'RETIRO', 'COMPRA', 'TRANSFERENCIA'])
        monto = random.uniform(100, saldo_actual * 0.3) if tipo in ['RETIRO', 'COMPRA'] else random.uniform(100, 50000)
        
        if tipo in ['RETIRO', 'COMPRA', 'TRANSFERENCIA']:
            saldo_actual -= monto
            signo = "-"
        else:
            saldo_actual += monto
            signo = "+"
        
        concepto = {
            'DEPOSITO': 'Depósito en efectivo',
            'RETIRO': 'Retiro cajero automático',
            'COMPRA': random.choice(['Compra en comercio', 'Pago servicios', 'Supermercado']),
            'TRANSFERENCIA': 'Transfer SPE'
        }[tipo]
        
        movimientos.append({
            'fecha': f"{dia:02d}/{mes:02d}/{año}",
            'concepto': concepto,
            'cargo': monto if signo == "-" else 0,
            'abono': monto if signo == "+" else 0,
            'saldo': saldo_actual
        })
    
    filename_pdf = f"output/estados_cuenta/pdfs/EDO_CTA_{numero_global:03d}_{entidad['rfc']}_{año}{mes:02d}.pdf"
    
    c = canvas.Canvas(filename_pdf, pagesize=letter)
    width, height = letter
    
    # --- ENCABEZADO BANCO ---
    c.setFillColorRGB(0.8, 0, 0)
    c.rect(0, height - 90, width, 90, fill=True, stroke=False)
    
    c.setFillColorRGB(1, 1, 1)
    c.setFont("Helvetica-Bold", 22)
    banco = random.choice(['BANCO NACIONAL', 'BANCO DEL CENTRO', 'BANCO REGIONAL'])
    c.drawString(50, height - 40, banco)
    c.setFont("Helvetica", 10)
    c.drawString(50, height - 60, "ESTADO DE CUENTA")
    c.drawString(50, height - 75, f"Periodo: {periodo_str}")
    
    c.setFont("Helvetica", 9)
    c.drawRightString(width - 50, height - 40, f"Fecha de corte: {random.randint(25, 28)}/{mes:02d}/{año}")
    c.drawRightString(width - 50, height - 55, f"No. Cliente: {random.randint(100000, 999999)}")
    
    # --- DATOS DEL CLIENTE ---
    y_pos = height - 120
    c.setFillColorRGB(0, 0, 0)
    c.setFont("Helvetica-Bold", 11)
    c.drawString(50, y_pos, "DATOS DEL CLIENTE")
    c.line(50, y_pos - 5, width - 50, y_pos - 5)
    
    y_pos -= 25
    c.setFont("Helvetica-Bold", 9)
    c.drawString(50, y_pos, "Titular:")
    c.setFont("Helvetica", 8)
    c.drawString(150, y_pos, entidad['nombre'][:50])
    
    y_pos -= 15
    c.setFont("Helvetica-Bold", 9)
    c.drawString(50, y_pos, "RFC:")
    c.setFont("Helvetica", 9)
    c.drawString(150, y_pos, entidad['rfc'])
    
    c.setFont("Helvetica-Bold", 9)
    c.drawString(350, y_pos, "No. Cuenta:")
    c.setFont("Helvetica", 9)
    c.drawString(430, y_pos, num_cuenta)
    
    y_pos -= 15
    c.setFont("Helvetica-Bold", 9)
    c.drawString(50, y_pos, "CLABE:")
    c.setFont("Helvetica", 9)
    c.drawString(150, y_pos, clabe)
    
    # --- RESUMEN DE CUENTA ---
    y_pos -= 30
    c.setFont("Helvetica-Bold", 11)
    c.drawString(50, y_pos, "RESUMEN DE CUENTA")
    c.line(50, y_pos - 5, width - 50, y_pos - 5)
    
    y_pos -= 25
    c.setFont("Helvetica", 9)
    c.drawString(60, y_pos, "Saldo inicial:")
    c.drawRightString(200, y_pos, f"${saldo_inicial:,.2f}")
    
    total_cargos = sum(m['cargo'] for m in movimientos)
    total_abonos = sum(m['abono'] for m in movimientos)
    
    c.drawString(250, y_pos, "Total cargos:")
    c.drawRightString(390, y_pos, f"${total_cargos:,.2f}")
    
    y_pos -= 15
    c.drawString(60, y_pos, "Total abonos:")
    c.drawRightString(200, y_pos, f"${total_abonos:,.2f}")
    
    c.setFont("Helvetica-Bold", 10)
    c.drawString(250, y_pos, "Saldo final:")
    c.drawRightString(390, y_pos, f"${saldo_actual:,.2f}")
    
    # --- MOVIMIENTOS ---
    y_pos -= 35
    c.setFont("Helvetica-Bold", 11)
    c.drawString(50, y_pos, "MOVIMIENTOS DEL PERIODO")
    c.line(50, y_pos - 5, width - 50, y_pos - 5)
    
    y_pos -= 20
    c.setFont("Helvetica-Bold", 8)
    c.drawString(55, y_pos, "FECHA")
    c.drawString(120, y_pos, "CONCEPTO")
    c.drawRightString(350, y_pos, "CARGO")
    c.drawRightString(430, y_pos, "ABONO")
    c.drawRightString(width - 60, y_pos, "SALDO")
    
    y_pos -= 15
    c.setFont("Helvetica", 7)
    
    for mov in movimientos[:10]:  # Limitar a 10 movimientos
        if y_pos < 100:
            break
        c.drawString(55, y_pos, mov['fecha'])
        c.drawString(120, y_pos, mov['concepto'][:25])
        if mov['cargo'] > 0:
            c.drawRightString(350, y_pos, f"${mov['cargo']:,.2f}")
        if mov['abono'] > 0:
            c.drawRightString(430, y_pos, f"${mov['abono']:,.2f}")
        c.drawRightString(width - 60, y_pos, f"${mov['saldo']:,.2f}")
        y_pos -= 12
    
    # --- PIE ---
    c.setFont("Helvetica", 7)
    c.drawString(50, 60, f"Atención a clientes: 01-800-BANCO-{random.randint(100, 999)}")
    c.drawString(50, 50, "Consulte su saldo en cajeros automáticos, banca móvil o sucursales.")
    c.drawString(50, 40, "Este estado de cuenta tiene validez oficial para trámites.")
    
    c.setFont("Helvetica-Bold", 7)
    c.setFillColorRGB(0.8, 0, 0)
    c.drawCentredString(width/2, 25, "*** DOCUMENTO DE PRUEBA - SIN VALIDEZ OFICIAL ***")
    
    c.save()
    print(f"✓ Estado de cuenta generado: {filename_pdf}")
    
    generar_imagen_documento(filename_pdf, numero_global, entidad['rfc'], f"{año}{mes:02d}", "EDO_CTA", "ESTADO DE CUENTA")
    
    return filename_pdf

def generar_imagen_documento(pdf_path, numero, rfc, periodo, tipo, titulo):
    """Genera una imagen PNG básica del documento"""
    
    tipo_dir = {
        'NOMINA': 'recibos_nomina',
        'AGUA': 'recibos_agua',
        'LUZ': 'recibos_luz',
        'EDO_CTA': 'estados_cuenta'
    }
    
    img_path = f"output/{tipo_dir[tipo]}/imagenes/{tipo}_{numero:03d}_{rfc}_{periodo}.png"
    
    width_px = 1700
    height_px = 2200
    
    img = PILImage.new('RGB', (width_px, height_px), 'white')
    draw = ImageDraw.Draw(img)
    
    draw.rectangle([50, 50, width_px-50, height_px-50], outline='gray', width=3)
    
    try:
        font_large = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 60)
        font_medium = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 40)
        font_small = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 30)
    except:
        font_large = ImageFont.load_default()
        font_medium = ImageFont.load_default()
        font_small = ImageFont.load_default()
    
    color_map = {
        'NOMINA': 'blue',
        'AGUA': 'darkblue',
        'LUZ': 'darkgreen',
        'EDO_CTA': 'darkred'
    }
    
    draw.text((width_px//2 - 400, 250), titulo, fill=color_map.get(tipo, 'black'), font=font_medium)
    draw.text((width_px//2 - 300, 400), f"RFC: {rfc}", fill='black', font=font_small)
    draw.text((width_px//2 - 300, 500), f"Periodo: {periodo[:2]}/{periodo[2:]}", fill='black', font=font_small)
    draw.text((width_px//2 - 500, 600), "Consultar PDF para detalles completos", fill='gray', font=font_small)
    draw.text((width_px//2 - 350, height_px - 150), "DOCUMENTO DE PRUEBA", fill='red', font=font_medium)
    
    img.save(img_path, 'PNG')
    print(f"  → Imagen: {img_path}")

def main():
    """Función principal"""
    print("="*70)
    print("GENERADOR DE RECIBOS Y ESTADOS DE CUENTA")
    print("Cliente: Unstructured Docs")
    print("Propósito: Pruebas de Cortex Search")
    print("="*70)
    print()
    
    # Definir periodos (últimos 3 meses)
    hoy = datetime.now()
    periodos = []
    for i in range(3):
        fecha = hoy - timedelta(days=30 * i)
        periodos.append({
            'mes': fecha.month,
            'año': fecha.year,
            'fecha_pago': fecha.strftime("%d/%m/%Y")
        })
    
    contador = 1
    total_docs = 0
    
    # RECIBOS DE NÓMINA (solo personas físicas, 3 meses cada una)
    print("\n📄 Generando recibos de nómina...")
    personas_fisicas = [c for c in CONTRIBUYENTES if c['tipo'] == 'Persona Física']
    for persona in personas_fisicas:
        for periodo in periodos:
            crear_recibo_nomina(persona, periodo, contador)
            contador += 1
            total_docs += 1
    
    # RECIBOS DE AGUA (todas las entidades, 3 meses)
    print("\n💧 Generando recibos de agua...")
    contador = 1
    for entidad in CONTRIBUYENTES:
        for periodo in periodos:
            crear_recibo_agua(entidad, (periodo['mes'], periodo['año']), contador)
            contador += 1
            total_docs += 1
    
    # RECIBOS DE LUZ (todas las entidades, 2 meses - bimestral)
    print("\n💡 Generando recibos de luz...")
    contador = 1
    for entidad in CONTRIBUYENTES:
        for i in range(2):  # Solo 2 recibos (bimestrales)
            periodo = periodos[i * 1]  # Cada 2 meses aproximadamente
            crear_recibo_luz(entidad, (periodo['mes'], periodo['año']), contador)
            contador += 1
            total_docs += 1
    
    # ESTADOS DE CUENTA (todas las entidades, 3 meses)
    print("\n🏦 Generando estados de cuenta...")
    contador = 1
    for entidad in CONTRIBUYENTES:
        for periodo in periodos:
            crear_estado_cuenta(entidad, (periodo['mes'], periodo['año']), contador)
            contador += 1
            total_docs += 1
    
    print("\n" + "="*70)
    print("✓ PROCESO COMPLETADO")
    print(f"✓ Total documentos generados: {total_docs}")
    print(f"  • Recibos de nómina: {len(personas_fisicas) * 3}")
    print(f"  • Recibos de agua: {len(CONTRIBUYENTES) * 3}")
    print(f"  • Recibos de luz: {len(CONTRIBUYENTES) * 2}")
    print(f"  • Estados de cuenta: {len(CONTRIBUYENTES) * 3}")
    print()
    print("NOTA: Estos documentos son ÚNICAMENTE para pruebas.")
    print("="*70)

if __name__ == "__main__":
    main()



