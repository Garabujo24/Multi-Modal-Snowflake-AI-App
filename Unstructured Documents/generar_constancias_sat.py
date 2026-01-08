"""
Generador de Constancias de Situación Fiscal (SAT México) - Versión de Prueba
Cliente: Unstructured Docs
Propósito: Pruebas de Cortex Search con documentos no estructurados

Este script genera constancias sintéticas con diseño oficial del SAT mexicano.
NOTA: Estos documentos son ÚNICAMENTE para pruebas y no tienen validez legal.
"""

from reportlab.lib.pagesizes import letter
from reportlab.lib.units import inch, cm
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, Image, PageBreak
from reportlab.pdfgen import canvas
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT, TA_JUSTIFY
from datetime import datetime, timedelta
import random
from PIL import Image as PILImage, ImageDraw, ImageFont
import qrcode
import os
import io
import PyPDF2

# Crear directorios de salida
os.makedirs("output/pdfs", exist_ok=True)
os.makedirs("output/imagenes", exist_ok=True)

# Datos sintéticos para 13 contribuyentes con variedad
CONTRIBUYENTES = [
    {
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
        "fecha_inicio": "2018-05-23"
    },
    {
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
        "fecha_inicio": "2010-03-15"
    },
    {
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
        "fecha_inicio": "2020-08-15"
    },
    {
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
        "fecha_inicio": "2022-01-01"
    },
    {
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
        "fecha_inicio": "2015-03-09"
    },
    {
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
        "fecha_inicio": "2015-06-01"
    },
    {
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
        "fecha_inicio": "2019-07-22"
    },
    {
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
        "fecha_inicio": "2016-08-10"
    },
    {
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
        "fecha_inicio": "2017-04-11"
    },
    {
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
        "fecha_inicio": "2018-09-01"
    },
    {
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
        "fecha_inicio": "2014-06-27"
    },
    {
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
        "fecha_inicio": "2022-01-01"
    },
    {
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
        "fecha_inicio": "2016-01-05"
    }
]

# Obligaciones fiscales por régimen
OBLIGACIONES = {
    "601": [
        "Declaración anual de ISR del ejercicio (AM)",
        "Pago provisional o definitivo de ISR (AG)",
        "Declaración informativa de operaciones con terceros (DIOT)",
        "Declaración del IVA (Mensual)",
        "Retenciones de ISR por salarios y asimilados"
    ],
    "612": [
        "Declaración anual de ISR del ejercicio Persona Física",
        "Pago provisional de ISR por Actividad Empresarial y Profesional",
        "Declaración informativa de operaciones con terceros (DIOT)",
        "Declaración del IVA (Mensual)",
        "Llevar contabilidad electrónica"
    ],
    "626": [
        "Declaración bimestral de ISR",
        "Declaración informativa anual",
        "Expedir comprobantes fiscales (Facturas)"
    ],
    "605": [
        "Presentación de declaración anual",
        "Solicitar constancias de retenciones al empleador"
    ],
    "621": [
        "Pago bimestral definitivo de ISR",
        "Llevar registro de ingresos, egresos e inversiones",
        "Entregar comprobantes simplificados"
    ]
}

def generar_qr_code(data):
    """Genera un código QR con los datos proporcionados"""
    qr = qrcode.QRCode(version=1, box_size=3, border=1)
    qr.add_data(data)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")
    
    # Convertir a formato compatible con ReportLab
    buffer = io.BytesIO()
    img.save(buffer, format='PNG')
    buffer.seek(0)
    return buffer

def generar_folio():
    """Genera un folio aleatorio de constancia"""
    año = random.choice([2023, 2024, 2025])
    numero = random.randint(100000000, 999999999)
    return f"{año}{numero}"

def generar_fecha_emision():
    """Genera una fecha de emisión aleatoria"""
    dias_atras = random.randint(1, 365)
    fecha = datetime.now() - timedelta(days=dias_atras)
    return fecha.strftime("%d/%m/%Y")

def crear_constancia_sat(contribuyente, numero):
    """
    Crea una constancia de situación fiscal con diseño oficial del SAT
    """
    filename_pdf = f"output/pdfs/CSF_{numero:02d}_{contribuyente['rfc']}.pdf"
    
    # Crear el PDF
    c = canvas.Canvas(filename_pdf, pagesize=letter)
    width, height = letter
    
    # --- ENCABEZADO OFICIAL SAT ---
    # Logo SAT (simulado con texto)
    c.setFillColorRGB(0.5, 0, 0)  # Color guinda oficial
    c.setFont("Helvetica-Bold", 20)
    c.drawString(50, height - 50, "SAT")
    
    c.setFillColorRGB(0, 0, 0)
    c.setFont("Helvetica", 8)
    c.drawString(80, height - 45, "Servicio de Administración Tributaria")
    c.drawString(80, height - 55, "México")
    
    # Título principal
    c.setFont("Helvetica-Bold", 16)
    c.drawString(width/2 - 150, height - 80, "CONSTANCIA DE SITUACIÓN FISCAL")
    
    # Folio
    folio = generar_folio()
    c.setFont("Helvetica", 9)
    c.drawRightString(width - 50, height - 50, f"Folio: {folio}")
    c.drawRightString(width - 50, height - 65, f"Fecha de emisión: {generar_fecha_emision()}")
    
    # --- DATOS DEL CONTRIBUYENTE ---
    y_position = height - 120
    
    c.setFont("Helvetica-Bold", 11)
    c.drawString(50, y_position, "DATOS DE IDENTIFICACIÓN DEL CONTRIBUYENTE")
    c.line(50, y_position - 5, width - 50, y_position - 5)
    
    y_position -= 25
    c.setFont("Helvetica-Bold", 9)
    c.drawString(50, y_position, "RFC:")
    c.setFont("Helvetica", 9)
    c.drawString(180, y_position, contribuyente['rfc'])
    
    y_position -= 15
    c.setFont("Helvetica-Bold", 9)
    c.drawString(50, y_position, "Nombre / Razón Social:")
    c.setFont("Helvetica", 9)
    c.drawString(180, y_position, contribuyente['nombre'])
    
    y_position -= 15
    c.setFont("Helvetica-Bold", 9)
    c.drawString(50, y_position, "Tipo de Contribuyente:")
    c.setFont("Helvetica", 9)
    c.drawString(180, y_position, contribuyente['tipo'])
    
    if contribuyente['curp']:
        y_position -= 15
        c.setFont("Helvetica-Bold", 9)
        c.drawString(50, y_position, "CURP:")
        c.setFont("Helvetica", 9)
        c.drawString(180, y_position, contribuyente['curp'])
    
    y_position -= 15
    c.setFont("Helvetica-Bold", 9)
    c.drawString(50, y_position, "Fecha de inicio de operaciones:")
    c.setFont("Helvetica", 9)
    c.drawString(180, y_position, contribuyente['fecha_inicio'])
    
    y_position -= 15
    c.setFont("Helvetica-Bold", 9)
    c.drawString(50, y_position, "Estatus en el padrón:")
    c.setFont("Helvetica", 9)
    c.drawString(180, y_position, "ACTIVO")
    
    # --- DOMICILIO FISCAL ---
    y_position -= 30
    c.setFont("Helvetica-Bold", 11)
    c.drawString(50, y_position, "DOMICILIO FISCAL")
    c.line(50, y_position - 5, width - 50, y_position - 5)
    
    y_position -= 20
    c.setFont("Helvetica", 9)
    direccion = f"{contribuyente['calle']} No. {contribuyente['num_ext']}"
    if contribuyente['num_int']:
        direccion += f" {contribuyente['num_int']}"
    c.drawString(50, y_position, direccion)
    
    y_position -= 12
    c.drawString(50, y_position, f"Colonia: {contribuyente['colonia']}, C.P. {contribuyente['cp']}")
    
    y_position -= 12
    c.drawString(50, y_position, f"{contribuyente['municipio']}, {contribuyente['estado']}")
    
    y_position -= 12
    c.drawString(50, y_position, f"Correo electrónico: {contribuyente['correo']}")
    
    # --- RÉGIMEN FISCAL ---
    y_position -= 30
    c.setFont("Helvetica-Bold", 11)
    c.drawString(50, y_position, "RÉGIMEN FISCAL")
    c.line(50, y_position - 5, width - 50, y_position - 5)
    
    y_position -= 20
    c.setFont("Helvetica", 9)
    c.drawString(50, y_position, contribuyente['regimen'])
    
    # --- OBLIGACIONES FISCALES ---
    y_position -= 30
    c.setFont("Helvetica-Bold", 11)
    c.drawString(50, y_position, "OBLIGACIONES FISCALES")
    c.line(50, y_position - 5, width - 50, y_position - 5)
    
    # Obtener obligaciones según régimen
    codigo_regimen = contribuyente['regimen'].split(' ')[0]
    obligaciones = OBLIGACIONES.get(codigo_regimen, ["Consultar obligaciones en el portal del SAT"])
    
    y_position -= 20
    c.setFont("Helvetica", 8)
    for obligacion in obligaciones:
        if y_position < 100:  # Si llegamos al final de la página
            break
        c.drawString(60, y_position, f"• {obligacion}")
        y_position -= 12
    
    # --- CÓDIGO QR ---
    qr_data = f"RFC:{contribuyente['rfc']}|Nombre:{contribuyente['nombre']}|Folio:{folio}"
    qr_buffer = generar_qr_code(qr_data)
    
    # Guardar temporalmente el QR
    qr_temp = f"temp_qr_{numero}.png"
    with open(qr_temp, 'wb') as f:
        f.write(qr_buffer.read())
    
    # Agregar QR al PDF
    c.drawImage(qr_temp, width - 120, 80, width=60, height=60)
    
    # --- PIE DE PÁGINA ---
    c.setFont("Helvetica", 7)
    c.drawString(50, 60, "Este documento es una representación impresa de la Constancia de Situación Fiscal.")
    c.drawString(50, 50, "Para verificar su autenticidad, consulte el código QR en el portal oficial del SAT.")
    c.drawString(50, 40, "Documento generado electrónicamente para fines de prueba.")
    
    c.setFont("Helvetica-Bold", 7)
    c.setFillColorRGB(0.8, 0, 0)
    c.drawCentredString(width/2, 25, "*** DOCUMENTO DE PRUEBA - SIN VALIDEZ OFICIAL ***")
    
    # Guardar PDF
    c.save()
    
    # Limpiar archivo temporal
    if os.path.exists(qr_temp):
        os.remove(qr_temp)
    
    print(f"✓ PDF generado: {filename_pdf}")
    
    return filename_pdf

def convertir_pdf_a_imagen(pdf_path, numero, rfc):
    """
    Convierte un PDF a imagen PNG usando renderizado directo
    """
    try:
        # Intentar primero con pdf2image si está disponible
        try:
            from pdf2image import convert_from_path
            images = convert_from_path(pdf_path, dpi=200)
            
            if images:
                img_path = f"output/imagenes/CSF_{numero:02d}_{rfc}.png"
                images[0].save(img_path, 'PNG')
                print(f"✓ Imagen generada: {img_path}")
                return img_path
        except ImportError:
            # Si pdf2image no está disponible, crear una imagen renderizada básica
            # Esta es una solución alternativa que crea una representación visual
            img_path = f"output/imagenes/CSF_{numero:02d}_{rfc}.png"
            
            # Crear una imagen en blanco tamaño carta
            width_px = 1700  # 8.5 pulgadas a 200 DPI
            height_px = 2200  # 11 pulgadas a 200 DPI
            
            img = PILImage.new('RGB', (width_px, height_px), 'white')
            draw = ImageDraw.Draw(img)
            
            # Dibujar un borde
            draw.rectangle([50, 50, width_px-50, height_px-50], outline='gray', width=3)
            
            # Agregar texto indicativo
            try:
                # Intentar usar una fuente del sistema
                font_large = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 60)
                font_medium = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 40)
                font_small = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 30)
            except:
                # Si no hay fuentes disponibles, usar la fuente por defecto
                font_large = ImageFont.load_default()
                font_medium = ImageFont.load_default()
                font_small = ImageFont.load_default()
            
            # Agregar texto
            draw.text((width_px//2 - 200, 150), "SAT", fill='maroon', font=font_large)
            draw.text((width_px//2 - 400, 250), "CONSTANCIA DE SITUACIÓN FISCAL", fill='black', font=font_medium)
            draw.text((width_px//2 - 300, 400), f"RFC: {rfc}", fill='black', font=font_small)
            draw.text((width_px//2 - 500, 500), "Consultar PDF para detalles completos", fill='gray', font=font_small)
            draw.text((width_px//2 - 350, height_px - 150), "DOCUMENTO DE PRUEBA", fill='red', font=font_medium)
            
            img.save(img_path, 'PNG')
            print(f"✓ Imagen generada (renderizado básico): {img_path}")
            print(f"  Nota: Instala poppler para imágenes de alta calidad")
            return img_path
            
    except Exception as e:
        print(f"⚠ No se pudo convertir a imagen: {e}")
        return None

def main():
    """
    Función principal que genera todas las constancias
    """
    print("="*70)
    print("GENERADOR DE CONSTANCIAS DE SITUACIÓN FISCAL (SAT México)")
    print("Cliente: Unstructured Docs")
    print("Propósito: Pruebas de Cortex Search")
    print("="*70)
    print()
    
    total = len(CONTRIBUYENTES)
    print(f"Generando {total} constancias de situación fiscal...")
    print()
    
    for i, contribuyente in enumerate(CONTRIBUYENTES, 1):
        print(f"[{i}/{total}] Procesando: {contribuyente['nombre']}")
        
        # Generar PDF
        pdf_path = crear_constancia_sat(contribuyente, i)
        
        # Convertir a imagen
        convertir_pdf_a_imagen(pdf_path, i, contribuyente['rfc'])
        
        print()
    
    print("="*70)
    print("✓ PROCESO COMPLETADO")
    print(f"✓ PDFs generados en: output/pdfs/")
    print(f"✓ Imágenes generadas en: output/imagenes/")
    print()
    print("NOTA: Estos documentos son ÚNICAMENTE para pruebas y capacitación.")
    print("      NO tienen validez oficial ni legal.")
    print("="*70)

if __name__ == "__main__":
    main()

