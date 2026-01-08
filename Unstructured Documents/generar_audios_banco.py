"""
Generador de Audios de Llamadas Bancarias - Versión de Prueba
Cliente: Unstructured Docs
Propósito: Pruebas de Cortex Search con audio y transcripciones

Este script genera:
- Audios MP3 de llamadas bancarias sintéticas
- Transcripciones en formato TXT y JSON
- Metadatos de cada llamada
- Variedad de escenarios bancarios

NOTA: Estos audios son ÚNICAMENTE para pruebas y no representan llamadas reales.
"""

from gtts import gTTS
import os
from datetime import datetime, timedelta
import random
import json

# Crear directorios de salida
os.makedirs("output/audios_banco/mp3", exist_ok=True)
os.makedirs("output/audios_banco/transcripciones", exist_ok=True)
os.makedirs("output/audios_banco/metadata", exist_ok=True)

# Importar datos de contribuyentes
CONTRIBUYENTES = [
    {
        "numero": 1, "tipo": "Persona Moral",
        "nombre": "TECNOLOGÍA AVANZADA DEL SURESTE SA DE CV",
        "rfc": "TAS180523KL8", "estado": "Yucatán"
    },
    {
        "numero": 2, "tipo": "Persona Física",
        "nombre": "MARÍA GUADALUPE HERNÁNDEZ SÁNCHEZ",
        "rfc": "HESM850614J39", "estado": "Jalisco"
    },
    {
        "numero": 3, "tipo": "Persona Moral",
        "nombre": "COMERCIALIZADORA DE ALIMENTOS DEL NORTE SA DE CV",
        "rfc": "CAN200815RT6", "estado": "Nuevo León"
    },
    {
        "numero": 4, "tipo": "Persona Física",
        "nombre": "JOSÉ ROBERTO GARCÍA LÓPEZ",
        "rfc": "GALR920327HG5", "estado": "Ciudad de México"
    },
    {
        "numero": 5, "tipo": "Persona Moral",
        "nombre": "CONSTRUCTORA INDUSTRIAL BAJÍO SA DE CV",
        "rfc": "CIB150309MN2", "estado": "Guanajuato"
    },
    {
        "numero": 6, "tipo": "Persona Física",
        "nombre": "ANA PATRICIA MARTÍNEZ RODRÍGUEZ",
        "rfc": "MARA881205QT7", "estado": "Puebla"
    },
    {
        "numero": 7, "tipo": "Persona Moral",
        "nombre": "SERVICIOS LOGÍSTICOS DEL PACÍFICO SA DE CV",
        "rfc": "SLP190722BC4", "estado": "Sinaloa"
    },
    {
        "numero": 8, "tipo": "Persona Física",
        "nombre": "CARLOS EDUARDO RAMÍREZ FERNÁNDEZ",
        "rfc": "RAFC900518KP9", "estado": "Querétaro"
    },
    {
        "numero": 9, "tipo": "Persona Moral",
        "nombre": "DESARROLLOS INMOBILIARIOS CANCÚN SA DE CV",
        "rfc": "DIC170411XY8", "estado": "Quintana Roo"
    },
    {
        "numero": 10, "tipo": "Persona Física",
        "nombre": "LAURA ISABEL TORRES MENDOZA",
        "rfc": "TOML870923FM2", "estado": "Veracruz"
    },
    {
        "numero": 11, "tipo": "Persona Moral",
        "nombre": "MANUFACTURAS TEXTILES DE OCCIDENTE SA DE CV",
        "rfc": "MTO140627GH3", "estado": "Jalisco"
    },
    {
        "numero": 12, "tipo": "Persona Física",
        "nombre": "FERNANDO JAVIER LÓPEZ CASTILLO",
        "rfc": "LOCF830712MK6", "estado": "San Luis Potosí"
    },
    {
        "numero": 13, "tipo": "Persona Moral",
        "nombre": "EXPORTADORA AGRÍCOLA DE SONORA SA DE CV",
        "rfc": "EAS160105PL9", "estado": "Sonora"
    }
]

# Plantillas de conversaciones bancarias
ESCENARIOS = {
    "consulta_saldo": {
        "titulo": "Consulta de Saldo",
        "categoria": "Información",
        "duracion_aprox": "2-3 minutos",
        "plantilla": """
Ejecutivo: Buen día, le atiende {ejecutivo} del Banco Nacional. ¿En qué puedo ayudarle?

Cliente: Hola, buenos días. Quisiera consultar el saldo de mi cuenta.

Ejecutivo: Con gusto le ayudo. ¿Me podría proporcionar su número de cuenta o tarjeta, por favor?

Cliente: Sí, claro. Mi número de cuenta es {num_cuenta}.

Ejecutivo: Perfecto. ¿Me puede confirmar su nombre completo?

Cliente: {nombre_cliente}.

Ejecutivo: Gracias. Por seguridad, ¿me podría proporcionar los últimos cuatro dígitos de su RFC?

Cliente: Sí, son {ultimos_rfc}.

Ejecutivo: Excelente, gracias por confirmar. Su saldo actual es de {saldo} pesos con {centavos} centavos. Su último movimiento fue {ultimo_movimiento} por {monto_movimiento} pesos.

Cliente: Perfecto, muchas gracias. ¿Y cuál es mi saldo disponible?

Ejecutivo: Su saldo disponible es de {saldo_disponible} pesos. ¿Hay algo más en lo que pueda ayudarle?

Cliente: No, eso es todo. Muchas gracias.

Ejecutivo: A usted. Que tenga un excelente día.
"""
    },
    
    "reporte_fraude": {
        "titulo": "Reporte de Fraude",
        "categoria": "Seguridad",
        "duracion_aprox": "4-5 minutos",
        "plantilla": """
Ejecutivo: Buenas tardes, le atiende {ejecutivo} del área de seguridad del Banco Nacional. ¿En qué puedo ayudarle?

Cliente: Buenas tardes. Necesito reportar un cargo no reconocido en mi tarjeta.

Ejecutivo: Entiendo su preocupación. Le voy a ayudar de inmediato. ¿Me podría proporcionar su número de tarjeta?

Cliente: Es la {num_tarjeta}.

Ejecutivo: Gracias. ¿Me puede confirmar su nombre completo?

Cliente: {nombre_cliente}.

Ejecutivo: Perfecto. ¿Cuál es el monto del cargo no reconocido?

Cliente: Son {monto_fraude} pesos. Aparece como {comercio_fraude}.

Ejecutivo: Entiendo. ¿Recuerda cuándo se realizó este cargo?

Cliente: Según mi estado de cuenta, fue el {fecha_fraude}.

Ejecutivo: De acuerdo. Por seguridad, voy a bloquear su tarjeta inmediatamente. ¿Tiene la tarjeta física en su poder?

Cliente: Sí, la tengo aquí conmigo.

Ejecutivo: Perfecto. He bloqueado su tarjeta y he iniciado el proceso de reclamación. En un plazo de 3 a 5 días hábiles, recibirá una tarjeta de reemplazo en su domicilio. El monto será acreditado durante la investigación, que toma aproximadamente 45 días hábiles.

Cliente: De acuerdo. ¿Puedo seguir usando mi cuenta?

Ejecutivo: Sí, su cuenta sigue activa. Solo está bloqueada la tarjeta física. ¿Desea que le enviemos una tarjeta digital temporal?

Cliente: Sí, por favor.

Ejecutivo: Listo, en unos minutos recibirá la tarjeta digital en su aplicación móvil. Su número de reporte es {num_reporte}. ¿Algo más en que pueda ayudarle?

Cliente: No, eso es todo. Muchas gracias por su ayuda.

Ejecutivo: A sus órdenes. Cualquier cosa, estamos para servirle.
"""
    },
    
    "solicitud_credito": {
        "titulo": "Solicitud de Crédito",
        "categoria": "Productos",
        "duracion_aprox": "5-7 minutos",
        "plantilla": """
Ejecutivo: Buenos días, le atiende {ejecutivo} del área de créditos del Banco Nacional. ¿En qué puedo ayudarle?

Cliente: Buenos días. Me gustaría solicitar un crédito personal.

Ejecutivo: Con gusto. ¿Es cliente del banco?

Cliente: Sí, tengo mi cuenta de nómina con ustedes.

Ejecutivo: Excelente. ¿Me puede proporcionar su número de cuenta?

Cliente: Sí, es {num_cuenta}.

Ejecutivo: Gracias. ¿Y su nombre completo?

Cliente: {nombre_cliente}.

Ejecutivo: Perfecto. Déjeme verificar su información. Veo que tiene {antiguedad} de antigüedad con nosotros. ¿Qué monto le gustaría solicitar?

Cliente: Necesito {monto_credito} pesos.

Ejecutivo: Entiendo. ¿Y en cuántos meses le gustaría pagarlo?

Cliente: En {plazo_credito} meses, si es posible.

Ejecutivo: Déjeme revisar su historial crediticio y capacidad de pago. Por favor, espere un momento.

Cliente: Claro, sin problema.

Ejecutivo: Gracias por su espera. Tengo buenas noticias. Su solicitud ha sido pre-aprobada por {monto_aprobado} pesos a {plazo_credito} meses, con una tasa de interés del {tasa_interes} por ciento anual. Su pago mensual sería de aproximadamente {pago_mensual} pesos.

Cliente: ¿Y cuándo podría tener el dinero?

Ejecutivo: Una vez que firme el contrato, el dinero se depositará en su cuenta en un plazo de 24 a 48 horas. ¿Le gustaría proceder con la solicitud?

Cliente: Sí, me interesa. ¿Qué documentos necesito?

Ejecutivo: Como ya es cliente, solo necesitamos que confirme sus datos en la aplicación móvil y firme el contrato digital. Le enviaré un correo con los detalles y el link para continuar.

Cliente: Perfecto, muchas gracias.

Ejecutivo: A sus órdenes. Si tiene alguna duda, puede llamarnos al centro de atención. Que tenga un excelente día.
"""
    },
    
    "aclaracion_cargo": {
        "titulo": "Aclaración de Cargo",
        "categoria": "Soporte",
        "duracion_aprox": "3-4 minutos",
        "plantilla": """
Ejecutivo: Buenas tardes, le atiende {ejecutivo} del Banco Nacional. ¿En qué puedo ayudarle?

Cliente: Buenas tardes. Tengo una duda sobre un cargo en mi tarjeta.

Ejecutivo: Con gusto le ayudo. ¿Me puede proporcionar su número de tarjeta?

Cliente: Sí, es la {num_tarjeta}.

Ejecutivo: Gracias. ¿Y su nombre completo?

Cliente: {nombre_cliente}.

Ejecutivo: Perfecto. ¿Cuál es el cargo que desea aclarar?

Cliente: Hay un cargo de {monto_cargo} pesos de {comercio}. No recuerdo haberlo hecho.

Ejecutivo: Entiendo. Déjeme revisar los detalles de la transacción. ¿Recuerda la fecha aproximada?

Cliente: Fue hace como {dias_atras} días.

Ejecutivo: Ya lo tengo. El cargo se realizó el {fecha_cargo} en {comercio}, ubicado en {ciudad}. La transacción fue aprobada con chip y NIP.

Cliente: Ah, ya recuerdo. Sí fui yo. Es que la compra aparece con otro nombre en el estado de cuenta.

Ejecutivo: Sí, a veces los comercios tienen razones sociales diferentes. ¿Hay algo más que necesite aclarar?

Cliente: No, ya quedó claro. Disculpe las molestias.

Ejecutivo: No hay ninguna molestia. Estamos para servirle. Si tiene alguna otra duda, no dude en contactarnos.

Cliente: Muchas gracias.

Ejecutivo: A sus órdenes. Que tenga un excelente día.
"""
    },
    
    "transferencia": {
        "titulo": "Solicitud de Transferencia",
        "categoria": "Operaciones",
        "duracion_aprox": "3-4 minutos",
        "plantilla": """
Ejecutivo: Buenos días, le atiende {ejecutivo} del Banco Nacional. ¿En qué puedo ayudarle?

Cliente: Buenos días. Necesito hacer una transferencia.

Ejecutivo: Con gusto le ayudo. ¿Me puede proporcionar su número de cuenta?

Cliente: Sí, es {num_cuenta}.

Ejecutivo: Gracias. ¿Y su nombre completo?

Cliente: {nombre_cliente}.

Ejecutivo: Perfecto. ¿Tiene la CLABE del beneficiario?

Cliente: Sí, es {clabe_destino}.

Ejecutivo: Déjeme verificar. El beneficiario es {nombre_beneficiario}. ¿Es correcto?

Cliente: Sí, es correcto.

Ejecutivo: ¿Qué monto desea transferir?

Cliente: {monto_transferencia} pesos.

Ejecutivo: Entiendo. Por seguridad, ¿me puede confirmar el concepto de la transferencia?

Cliente: Es por {concepto_transferencia}.

Ejecutivo: Perfecto. La transferencia tiene un costo de {comision_transferencia} pesos. El beneficiario recibirá {monto_neto} pesos. ¿Desea continuar?

Cliente: Sí, adelante.

Ejecutivo: Excelente. Le voy a enviar un código de verificación a su celular registrado. ¿Me puede proporcionar el código cuando lo reciba?

Cliente: Sí, el código es {codigo_verificacion}.

Ejecutivo: Gracias. La transferencia ha sido procesada exitosamente. El número de referencia es {num_referencia}. El beneficiario recibirá el dinero en un plazo máximo de 24 horas.

Cliente: Perfecto, muchas gracias.

Ejecutivo: A sus órdenes. ¿Hay algo más en lo que pueda ayudarle?

Cliente: No, eso es todo.

Ejecutivo: Que tenga un excelente día.
"""
    },
    
    "actualizacion_datos": {
        "titulo": "Actualización de Datos",
        "categoria": "Administración",
        "duracion_aprox": "3-4 minutos",
        "plantilla": """
Ejecutivo: Buenas tardes, le atiende {ejecutivo} del Banco Nacional. ¿En qué puedo ayudarle?

Cliente: Buenas tardes. Necesito actualizar mi dirección y teléfono.

Ejecutivo: Con gusto le ayudo. ¿Me puede proporcionar su número de cuenta?

Cliente: Sí, es {num_cuenta}.

Ejecutivo: Gracias. ¿Y su nombre completo?

Cliente: {nombre_cliente}.

Ejecutivo: Perfecto. ¿Cuál es su nueva dirección?

Cliente: {nueva_direccion}, colonia {nueva_colonia}, código postal {nuevo_cp}, en {nueva_ciudad}, {nuevo_estado}.

Ejecutivo: Entendido. ¿Y su nuevo teléfono?

Cliente: Es el {nuevo_telefono}.

Ejecutivo: Perfecto. ¿También desea actualizar su correo electrónico?

Cliente: Sí, el nuevo correo es {nuevo_correo}.

Ejecutivo: Excelente. He actualizado toda su información. En un plazo de 24 horas, los cambios estarán reflejados en todos nuestros sistemas. Le enviaremos una confirmación a su nuevo correo.

Cliente: Perfecto. ¿Necesitan algún documento?

Ejecutivo: Sí, por regulaciones bancarias, necesitamos que nos envíe una copia de un comprobante de domicilio reciente a través de la aplicación móvil o puede acudir a sucursal.

Cliente: De acuerdo, lo haré desde la aplicación.

Ejecutivo: Perfecto. ¿Hay algo más en lo que pueda ayudarle?

Cliente: No, eso es todo. Gracias.

Ejecutivo: A sus órdenes. Que tenga un excelente día.
"""
    }
}

def generar_datos_llamada(contribuyente, escenario):
    """Genera datos específicos para cada llamada"""
    
    # Datos generales
    num_cuenta = f"****{random.randint(1000, 9999)}"
    num_tarjeta = f"****-****-****-{random.randint(1000, 9999)}"
    ultimos_rfc = contribuyente['rfc'][-4:]
    
    # Nombres de ejecutivos bancarios
    ejecutivos = [
        "Diana Morales", "Roberto Sánchez", "Patricia Gutiérrez", 
        "Miguel Ángel Ruiz", "Laura Fernández", "Carlos Mendoza",
        "Ana María López", "Jorge Ramírez", "Sofía Castillo"
    ]
    
    # Montos y datos financieros
    saldo = random.randint(5000, 250000)
    centavos = random.randint(0, 99)
    saldo_disponible = int(saldo * random.uniform(0.7, 0.95))
    
    monto_movimiento = random.randint(500, 15000)
    movimientos = [
        f"un depósito", f"un retiro en cajero automático",
        f"una compra en comercio", f"una transferencia recibida",
        f"un pago de servicio"
    ]
    
    # Datos de fraude
    monto_fraude = random.randint(1000, 8000)
    comercios_fraude = [
        "AMAZON MARKETPLACE", "MERCADO LIBRE", "STEAM GAMES",
        "SPOTIFY PREMIUM", "NETFLIX SERVICES", "UBER RIDE"
    ]
    
    fecha_fraude = (datetime.now() - timedelta(days=random.randint(1, 5))).strftime("%d de %B")
    num_reporte = f"FR{random.randint(100000, 999999)}"
    
    # Datos de crédito
    antiguedad = f"{random.randint(1, 10)} años"
    monto_credito = random.choice([50000, 75000, 100000, 150000, 200000])
    plazo_credito = random.choice([12, 18, 24, 36, 48])
    monto_aprobado = monto_credito
    tasa_interes = round(random.uniform(12.5, 18.9), 2)
    pago_mensual = int((monto_aprobado * (1 + tasa_interes/100)) / plazo_credito)
    
    # Datos de transferencia
    clabe_destino = f"012180{random.randint(1000000000, 9999999999)}"
    nombres_beneficiarios = [
        "Juan Carlos Pérez García", "María Elena Rodríguez Sánchez",
        "Luis Fernando Martínez López", "Ana Cristina González Díaz"
    ]
    monto_transferencia = random.randint(5000, 50000)
    comision_transferencia = 15
    monto_neto = monto_transferencia - comision_transferencia
    conceptos = [
        "pago de servicios", "préstamo familiar", "pago de proveedor",
        "inversión", "pago de renta"
    ]
    codigo_verificacion = f"{random.randint(100000, 999999)}"
    num_referencia = f"TR{random.randint(10000000, 99999999)}"
    
    # Datos de actualización
    ciudades = ["Monterrey", "Guadalajara", "Puebla", "Querétaro", "León"]
    calles = ["Avenida Reforma", "Calle Juárez", "Boulevard Insurgentes", "Avenida Universidad"]
    colonias = ["Centro", "Del Valle", "Polanco", "Roma Norte", "Condesa"]
    
    # Datos de aclaración
    monto_cargo = random.randint(200, 5000)
    comercios = ["OXXO", "WALMART", "LIVERPOOL", "SORIANA", "HOME DEPOT"]
    dias_atras = random.randint(3, 10)
    fecha_cargo = (datetime.now() - timedelta(days=dias_atras)).strftime("%d de %B")
    ciudades_comercio = contribuyente['estado']
    
    # Diccionario de reemplazos
    datos = {
        'ejecutivo': random.choice(ejecutivos),
        'nombre_cliente': contribuyente['nombre'],
        'num_cuenta': num_cuenta,
        'num_tarjeta': num_tarjeta,
        'ultimos_rfc': ultimos_rfc,
        'saldo': f"{saldo:,}",
        'centavos': f"{centavos:02d}",
        'saldo_disponible': f"{saldo_disponible:,}",
        'ultimo_movimiento': random.choice(movimientos),
        'monto_movimiento': f"{monto_movimiento:,}",
        'monto_fraude': f"{monto_fraude:,}",
        'comercio_fraude': random.choice(comercios_fraude),
        'fecha_fraude': fecha_fraude,
        'num_reporte': num_reporte,
        'monto_credito': f"{monto_credito:,}",
        'plazo_credito': plazo_credito,
        'antiguedad': antiguedad,
        'monto_aprobado': f"{monto_aprobado:,}",
        'tasa_interes': tasa_interes,
        'pago_mensual': f"{pago_mensual:,}",
        'clabe_destino': clabe_destino,
        'nombre_beneficiario': random.choice(nombres_beneficiarios),
        'monto_transferencia': f"{monto_transferencia:,}",
        'comision_transferencia': comision_transferencia,
        'monto_neto': f"{monto_neto:,}",
        'concepto_transferencia': random.choice(conceptos),
        'codigo_verificacion': codigo_verificacion,
        'num_referencia': num_referencia,
        'nueva_direccion': f"{random.choice(calles)} {random.randint(100, 999)}",
        'nueva_colonia': random.choice(colonias),
        'nuevo_cp': f"{random.randint(10000, 99999)}",
        'nueva_ciudad': random.choice(ciudades),
        'nuevo_estado': contribuyente['estado'],
        'nuevo_telefono': f"55-{random.randint(1000, 9999)}-{random.randint(1000, 9999)}",
        'nuevo_correo': f"nuevo.correo{random.randint(100, 999)}@email.com",
        'monto_cargo': f"{monto_cargo:,}",
        'comercio': random.choice(comercios),
        'dias_atras': dias_atras,
        'fecha_cargo': fecha_cargo,
        'ciudad': ciudades_comercio
    }
    
    return datos

def generar_audio(texto, filename, idioma='es', lento=False):
    """Genera un archivo de audio MP3 a partir de texto"""
    
    try:
        # Crear objeto gTTS
        tts = gTTS(text=texto, lang=idioma, slow=lento)
        
        # Guardar archivo
        tts.save(filename)
        
        return True
    except Exception as e:
        print(f"  ❌ Error al generar audio: {e}")
        return False

def crear_llamada_bancaria(contribuyente, tipo_escenario, numero_global):
    """Crea una llamada bancaria completa con audio, transcripción y metadata"""
    
    escenario = ESCENARIOS[tipo_escenario]
    datos = generar_datos_llamada(contribuyente, escenario)
    
    # Generar transcripción completando la plantilla
    transcripcion = escenario['plantilla'].format(**datos)
    
    # Limpiar transcripción
    transcripcion = transcripcion.strip()
    
    # Generar nombres de archivos
    fecha_llamada = datetime.now() - timedelta(days=random.randint(0, 30))
    fecha_str = fecha_llamada.strftime("%Y%m%d")
    
    base_filename = f"LLAMADA_{numero_global:03d}_{contribuyente['rfc']}_{tipo_escenario}_{fecha_str}"
    
    audio_file = f"output/audios_banco/mp3/{base_filename}.mp3"
    transcripcion_file = f"output/audios_banco/transcripciones/{base_filename}.txt"
    metadata_file = f"output/audios_banco/metadata/{base_filename}.json"
    
    print(f"[{numero_global}] Procesando: {escenario['titulo']} - {contribuyente['nombre'][:40]}...")
    
    # Guardar transcripción
    with open(transcripcion_file, 'w', encoding='utf-8') as f:
        f.write(f"LLAMADA BANCARIA - {escenario['titulo']}\n")
        f.write(f"{'='*70}\n\n")
        f.write(f"Cliente: {contribuyente['nombre']}\n")
        f.write(f"RFC: {contribuyente['rfc']}\n")
        f.write(f"Fecha: {fecha_llamada.strftime('%d/%m/%Y %H:%M')}\n")
        f.write(f"Duración estimada: {escenario['duracion_aprox']}\n")
        f.write(f"Categoría: {escenario['categoria']}\n")
        f.write(f"\n{'='*70}\n\n")
        f.write("TRANSCRIPCIÓN:\n\n")
        f.write(transcripcion)
        f.write(f"\n\n{'='*70}\n")
        f.write("*** TRANSCRIPCIÓN SINTÉTICA - SOLO PARA PRUEBAS ***\n")
    
    print(f"  ✓ Transcripción guardada")
    
    # Generar audio
    print(f"  🔊 Generando audio (esto puede tomar unos segundos)...")
    if generar_audio(transcripcion, audio_file):
        print(f"  ✓ Audio generado: {base_filename}.mp3")
        audio_generado = True
    else:
        print(f"  ⚠️  Audio no generado (continuar con transcripción)")
        audio_generado = False
    
    # Crear metadata
    metadata = {
        "id_llamada": numero_global,
        "cliente": {
            "nombre": contribuyente['nombre'],
            "rfc": contribuyente['rfc'],
            "tipo": contribuyente['tipo'],
            "estado": contribuyente['estado']
        },
        "llamada": {
            "tipo": tipo_escenario,
            "titulo": escenario['titulo'],
            "categoria": escenario['categoria'],
            "fecha": fecha_llamada.isoformat(),
            "duracion_estimada": escenario['duracion_aprox']
        },
        "archivos": {
            "audio": base_filename + ".mp3" if audio_generado else None,
            "transcripcion": base_filename + ".txt",
            "metadata": base_filename + ".json"
        },
        "datos_extraidos": {
            key: datos[key] for key in ['ejecutivo', 'num_cuenta', 'ultimos_rfc']
            if key in datos
        },
        "proposito": "Pruebas de Cortex Search y Speech-to-Text",
        "nota": "Contenido sintético sin validez real"
    }
    
    with open(metadata_file, 'w', encoding='utf-8') as f:
        json.dump(metadata, f, ensure_ascii=False, indent=2)
    
    print(f"  ✓ Metadata guardada")
    print()
    
    return {
        'audio_generado': audio_generado,
        'transcripcion': transcripcion_file,
        'metadata': metadata_file
    }

def main():
    """Función principal"""
    
    print("="*70)
    print("GENERADOR DE AUDIOS DE LLAMADAS BANCARIAS")
    print("Cliente: Unstructured Docs")
    print("Propósito: Pruebas de Cortex Search con Audio")
    print("="*70)
    print()
    
    print("📋 INSTALANDO DEPENDENCIAS (si es necesario)...")
    print("   Ejecuta: pip3 install gtts")
    print()
    
    # Seleccionar escenarios y contribuyentes
    escenarios_lista = list(ESCENARIOS.keys())
    
    contador = 1
    total_exitosos = 0
    total_audios = 0
    
    # Generar 2 llamadas para cada contribuyente (diferentes escenarios)
    for contribuyente in CONTRIBUYENTES:
        # Seleccionar 2 escenarios aleatorios para cada contribuyente
        escenarios_seleccionados = random.sample(escenarios_lista, min(2, len(escenarios_lista)))
        
        for tipo_escenario in escenarios_seleccionados:
            resultado = crear_llamada_bancaria(contribuyente, tipo_escenario, contador)
            
            if resultado['audio_generado']:
                total_audios += 1
            total_exitosos += 1
            contador += 1
    
    print("="*70)
    print("✓ PROCESO COMPLETADO")
    print(f"✓ Total de llamadas generadas: {total_exitosos}")
    print(f"✓ Audios MP3 generados: {total_audios}")
    print(f"✓ Transcripciones TXT: {total_exitosos}")
    print(f"✓ Metadata JSON: {total_exitosos}")
    print()
    print("📁 Archivos en:")
    print("   • output/audios_banco/mp3/")
    print("   • output/audios_banco/transcripciones/")
    print("   • output/audios_banco/metadata/")
    print()
    print("NOTA: Los audios son sintéticos y solo para pruebas.")
    print("      NO representan grabaciones reales de llamadas bancarias.")
    print("="*70)

if __name__ == "__main__":
    main()



