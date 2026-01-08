-- ============================================================================
-- OFFICEMAX MÉXICO - GENERACIÓN DE DATOS SINTÉTICOS
-- Script para generar ventas históricas, eventos y documentos sintéticos
-- ============================================================================

USE DATABASE OFFICEMAX_MEXICO;
USE WAREHOUSE OFFICEMAX_WH;

-- ============================================================================
-- PASO 1: GENERAR VENTAS HISTÓRICAS (ÚLTIMOS 12 MESES)
-- ============================================================================

-- Generar ventas para cada mes de los últimos 12 meses
-- Simulando patrones estacionales típicos de OfficeMax

-- Crear tabla temporal para generar fechas
CREATE OR REPLACE TEMPORARY TABLE TEMP_FECHA_BASE AS
SELECT 
    DATEADD('day', SEQ4(), '2023-01-01')::DATE as FECHA_VENTA
FROM TABLE(GENERATOR(ROWCOUNT => 365))
WHERE FECHA_VENTA <= CURRENT_DATE();

-- Insertar ventas sintéticas con patrones realistas
INSERT INTO RAW_DATA.VENTAS (
    VENTA_ID, 
    TICKET_ID, 
    FECHA_VENTA, 
    CLIENTE_ID, 
    TIPO_CLIENTE, 
    PRODUCTO_ID, 
    CANTIDAD, 
    PRECIO_UNITARIO, 
    DESCUENTO_UNITARIO,
    SUCURSAL_ID, 
    CANAL_VENTA, 
    CODIGO_PROMOCION,
    TIPO_DESCUENTO,
    PORCENTAJE_DESCUENTO,
    VENDEDOR_ID, 
    METODO_PAGO,
    COSTO_TOTAL,
    MARGEN_BRUTO,
    PORCENTAJE_MARGEN
)
SELECT 
    -- ID único de venta
    'VTA-' || LPAD(ROW_NUMBER() OVER (ORDER BY f.FECHA_VENTA), 10, '0') as VENTA_ID,
    
    -- Ticket ID (agrupando algunas ventas por ticket)
    'TKT-' || LPAD(FLOOR(ROW_NUMBER() OVER (ORDER BY f.FECHA_VENTA) / 2.3), 8, '0') as TICKET_ID,
    
    -- Fecha de venta con hora realista
    f.FECHA_VENTA + 
    INTERVAL (CASE 
        WHEN EXTRACT(DOW FROM f.FECHA_VENTA) BETWEEN 1 AND 5 THEN 
            (8 + RANDOM() * 12) * 3600 + RANDOM() * 3600  -- Lun-Vie: 8AM-8PM
        ELSE 
            (9 + RANDOM() * 11) * 3600 + RANDOM() * 3600  -- Sáb-Dom: 9AM-8PM
    END) SECOND as FECHA_VENTA,
    
    -- Cliente (70% tienen cliente registrado)
    CASE 
        WHEN RANDOM() < 0.7 THEN 
            (SELECT CLIENTE_ID FROM RAW_DATA.CLIENTES ORDER BY RANDOM() LIMIT 1)
        ELSE NULL 
    END as CLIENTE_ID,
    
    -- Tipo de cliente basado en día y producto
    CASE 
        WHEN EXTRACT(DOW FROM f.FECHA_VENTA) BETWEEN 2 AND 4 AND RANDOM() < 0.3 THEN 'EMPRESARIAL'
        WHEN EXTRACT(DOW FROM f.FECHA_VENTA) = 1 AND RANDOM() < 0.4 THEN 'EDUCATIVO'
        WHEN RANDOM() < 0.05 THEN 'GOBIERNO'
        ELSE 'INDIVIDUAL'
    END as TIPO_CLIENTE,
    
    -- Producto (con distribución realista por categoría)
    (SELECT PRODUCTO_ID FROM RAW_DATA.PRODUCTOS 
     WHERE ACTIVO = TRUE 
     ORDER BY RANDOM() LIMIT 1) as PRODUCTO_ID,
    
    -- Cantidad (distribución realista)
    CASE 
        WHEN RANDOM() < 0.6 THEN 1  -- 60% compran 1 unidad
        WHEN RANDOM() < 0.85 THEN 2 -- 25% compran 2 unidades
        WHEN RANDOM() < 0.95 THEN FLOOR(RANDOM() * 5) + 3  -- 10% compran 3-7
        ELSE FLOOR(RANDOM() * 20) + 8  -- 5% compran volumen (8-27)
    END as CANTIDAD,
    
    -- Precio unitario con variaciones promocionales
    p.PRECIO_REGULAR * 
    CASE 
        -- Back-to-School (Julio-Agosto): más descuentos
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) IN (7, 8) THEN 
            CASE WHEN RANDOM() < 0.4 THEN 0.85 + RANDOM() * 0.1 ELSE 1.0 END
        -- Black Friday/Cyber Monday (Noviembre)
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) = 11 AND EXTRACT(DAY FROM f.FECHA_VENTA) BETWEEN 24 AND 30 THEN
            0.75 + RANDOM() * 0.15
        -- Enero (liquidaciones)
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) = 1 THEN
            CASE WHEN RANDOM() < 0.3 THEN 0.8 + RANDOM() * 0.15 ELSE 1.0 END
        -- Precio regular con variación mínima
        ELSE 0.98 + RANDOM() * 0.04
    END as PRECIO_UNITARIO,
    
    -- Descuento unitario
    CASE 
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) IN (7, 8) AND RANDOM() < 0.4 THEN 
            p.PRECIO_REGULAR * (0.1 + RANDOM() * 0.1)  -- 10-20% descuento
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) = 11 AND EXTRACT(DAY FROM f.FECHA_VENTA) BETWEEN 24 AND 30 THEN
            p.PRECIO_REGULAR * (0.15 + RANDOM() * 0.1)  -- 15-25% descuento
        ELSE 0
    END as DESCUENTO_UNITARIO,
    
    -- Sucursal (distribución basada en población)
    CASE 
        WHEN RANDOM() < 0.35 THEN (SELECT SUCURSAL_ID FROM RAW_DATA.SUCURSALES WHERE ESTADO = 'CDMX' ORDER BY RANDOM() LIMIT 1)
        WHEN RANDOM() < 0.55 THEN (SELECT SUCURSAL_ID FROM RAW_DATA.SUCURSALES WHERE ESTADO = 'Jalisco' ORDER BY RANDOM() LIMIT 1)
        WHEN RANDOM() < 0.75 THEN (SELECT SUCURSAL_ID FROM RAW_DATA.SUCURSALES WHERE ESTADO = 'Nuevo León' ORDER BY RANDOM() LIMIT 1)
        ELSE (SELECT SUCURSAL_ID FROM RAW_DATA.SUCURSALES WHERE ESTADO NOT IN ('CDMX', 'Jalisco', 'Nuevo León') ORDER BY RANDOM() LIMIT 1)
    END as SUCURSAL_ID,
    
    -- Canal de venta (tendencia hacia digital)
    CASE 
        WHEN RANDOM() < 0.65 THEN 'TIENDA'
        WHEN RANDOM() < 0.85 THEN 'ONLINE'
        WHEN RANDOM() < 0.95 THEN 'APP_MOVIL'
        ELSE 'TELEFONO'
    END as CANAL_VENTA,
    
    -- Código de promoción (solo cuando hay descuento)
    CASE 
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) IN (7, 8) AND RANDOM() < 0.4 THEN 'BACK2SCHOOL2024'
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) = 11 AND EXTRACT(DAY FROM f.FECHA_VENTA) BETWEEN 24 AND 30 THEN 'BLACKFRIDAY2024'
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) = 1 AND RANDOM() < 0.3 THEN 'ENERO2024'
        WHEN RANDOM() < 0.1 THEN 'CLIENTE_VIP'
        ELSE NULL
    END as CODIGO_PROMOCION,
    
    -- Tipo de descuento
    CASE 
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) IN (7, 8) AND RANDOM() < 0.4 THEN 'TEMPORADA'
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) = 11 AND EXTRACT(DAY FROM f.FECHA_VENTA) BETWEEN 24 AND 30 THEN 'BLACK_FRIDAY'
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) = 1 AND RANDOM() < 0.3 THEN 'LIQUIDACION'
        WHEN RANDOM() < 0.1 THEN 'VOLUMEN'
        ELSE NULL
    END as TIPO_DESCUENTO,
    
    -- Porcentaje de descuento
    CASE 
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) IN (7, 8) AND RANDOM() < 0.4 THEN 10 + RANDOM() * 10
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) = 11 AND EXTRACT(DAY FROM f.FECHA_VENTA) BETWEEN 24 AND 30 THEN 15 + RANDOM() * 10
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) = 1 AND RANDOM() < 0.3 THEN 15 + RANDOM() * 15
        WHEN RANDOM() < 0.1 THEN 5 + RANDOM() * 10
        ELSE 0
    END as PORCENTAJE_DESCUENTO,
    
    -- Vendedor ID
    'VND-' || LPAD(FLOOR(RANDOM() * 200) + 1, 3, '0') as VENDEDOR_ID,
    
    -- Método de pago (distribución realista para México)
    CASE 
        WHEN RANDOM() < 0.35 THEN 'EFECTIVO'
        WHEN RANDOM() < 0.65 THEN 'TARJETA_DEBITO'
        WHEN RANDOM() < 0.85 THEN 'TARJETA_CREDITO'
        WHEN RANDOM() < 0.95 THEN 'TRANSFERENCIA'
        ELSE 'MESES_SIN_INTERESES'
    END as METODO_PAGO,
    
    -- Costo total calculado
    (CASE 
        WHEN RANDOM() < 0.6 THEN 1
        WHEN RANDOM() < 0.85 THEN 2
        WHEN RANDOM() < 0.95 THEN FLOOR(RANDOM() * 5) + 3
        ELSE FLOOR(RANDOM() * 20) + 8
    END) * p.COSTO_UNITARIO as COSTO_TOTAL,
    
    -- Margen bruto
    ((p.PRECIO_REGULAR * 
    CASE 
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) IN (7, 8) THEN 
            CASE WHEN RANDOM() < 0.4 THEN 0.85 + RANDOM() * 0.1 ELSE 1.0 END
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) = 11 AND EXTRACT(DAY FROM f.FECHA_VENTA) BETWEEN 24 AND 30 THEN
            0.75 + RANDOM() * 0.15
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) = 1 THEN
            CASE WHEN RANDOM() < 0.3 THEN 0.8 + RANDOM() * 0.15 ELSE 1.0 END
        ELSE 0.98 + RANDOM() * 0.04
    END) - p.COSTO_UNITARIO) * 
    (CASE 
        WHEN RANDOM() < 0.6 THEN 1
        WHEN RANDOM() < 0.85 THEN 2
        WHEN RANDOM() < 0.95 THEN FLOOR(RANDOM() * 5) + 3
        ELSE FLOOR(RANDOM() * 20) + 8
    END) as MARGEN_BRUTO,
    
    -- Porcentaje de margen
    ((p.PRECIO_REGULAR - p.COSTO_UNITARIO) / p.PRECIO_REGULAR) * 100 as PORCENTAJE_MARGEN
    
FROM TEMP_FECHA_BASE f
CROSS JOIN (SELECT * FROM RAW_DATA.PRODUCTOS WHERE ACTIVO = TRUE ORDER BY RANDOM() LIMIT 1) p
WHERE RANDOM() < 
    CASE 
        -- Más ventas en Back-to-School
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) IN (7, 8) THEN 0.15
        -- Menos ventas en enero post-fiestas
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) = 1 THEN 0.05
        -- Black Friday/Cyber Monday
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) = 11 AND EXTRACT(DAY FROM f.FECHA_VENTA) BETWEEN 24 AND 30 THEN 0.25
        -- Fin de año
        WHEN EXTRACT(MONTH FROM f.FECHA_VENTA) = 12 THEN 0.12
        -- Patrones normales
        ELSE 0.08
    END
ORDER BY f.FECHA_VENTA, RANDOM();

-- ============================================================================
-- PASO 2: GENERAR EVENTOS DE MARKETING
-- ============================================================================

INSERT INTO RAW_DATA.EVENTOS_MARKETING (
    NOMBRE_EVENTO,
    TIPO_EVENTO,
    DESCRIPCION,
    FECHA_INICIO,
    FECHA_FIN,
    PORCENTAJE_DESCUENTO,
    COMPRA_MINIMA,
    LIMITE_USES_TOTAL,
    LIMITE_USES_CLIENTE,
    SUCURSALES_APLICABLES,
    CANALES_APLICABLES,
    PRODUCTOS_APLICABLES,
    CLIENTES_OBJETIVO,
    PRESUPUESTO_ASIGNADO,
    COSTO_REAL,
    VENTAS_GENERADAS,
    NUMERO_TRANSACCIONES
) VALUES
-- Evento Back-to-School 2024
('Regreso a Clases 2024 - OfficeMax', 'TEMPORADA', 
 'Promoción especial para la temporada de regreso a clases con descuentos en útiles escolares, mochilas y tecnología educativa',
 '2024-07-01', '2024-08-31', 15.0, 500.00, 10000, 5,
 PARSE_JSON('["all"]'),
 PARSE_JSON('["TIENDA", "ONLINE", "APP_MOVIL"]'),
 PARSE_JSON('{"categorias": ["Material Escolar", "Tecnología"], "productos_especificos": ["OM-ESC-001", "OM-ESC-002", "OM-TECH-004"]}'),
 PARSE_JSON('{"tipos_cliente": ["INDIVIDUAL", "EDUCATIVO"], "edades": [18, 45]}'),
 2500000.00, 2234500.00, 8750000.00, 2580),

-- Black Friday 2024
('Black Friday OfficeMax 2024', 'PROMOCION',
 'Descuentos masivos en tecnología, mobiliario de oficina y productos seleccionados durante el Black Friday',
 '2024-11-24', '2024-11-30', 25.0, 1000.00, 5000, 3,
 PARSE_JSON('["all"]'),
 PARSE_JSON('["ONLINE", "APP_MOVIL", "TIENDA"]'),
 PARSE_JSON('{"categorias": ["Tecnología", "Mobiliario de Oficina"], "exclusiones": ["OM-TECH-004"]}'),
 PARSE_JSON('{"tipos_cliente": ["all"], "segmentos": ["VIP", "CORPORATIVO"]}'),
 3000000.00, 2890000.00, 12500000.00, 1850),

-- Liquidación Enero 2024
('Liquidación de Inventario Enero 2024', 'LIQUIDACION',
 'Liquidación de inventarios del año anterior con descuentos hasta del 40% en productos seleccionados',
 '2024-01-08', '2024-01-31', 30.0, 300.00, 15000, 10,
 PARSE_JSON('["all"]'),
 PARSE_JSON('["TIENDA", "OUTLET"]'),
 PARSE_JSON('{"productos_liquidacion": true, "categorias": ["Papelería", "Material Escolar"]}'),
 PARSE_JSON('{"tipos_cliente": ["all"]}'),
 1500000.00, 1425000.00, 4200000.00, 3200),

-- Promoción Día del Maestro
('Día del Maestro 2024', 'PROMOCION',
 'Descuento especial para maestros y personal educativo en tecnología y material didáctico',
 '2024-05-10', '2024-05-20', 20.0, 800.00, 2000, 1,
 PARSE_JSON('[101, 102, 201, 301]'),
 PARSE_JSON('["TIENDA", "ONLINE"]'),
 PARSE_JSON('{"categorias": ["Tecnología", "Papelería"], "para_educadores": true}'),
 PARSE_JSON('{"tipos_cliente": ["EDUCATIVO"], "validacion_requerida": "credencial_maestro"}'),
 800000.00, 720000.00, 3200000.00, 1200),

-- Cyber Monday
('Cyber Monday OfficeMax 2024', 'PROMOCION',
 'Evento exclusivo online con descuentos especiales en tecnología y productos digitales',
 '2024-12-02', '2024-12-02', 20.0, 1500.00, 3000, 2,
 PARSE_JSON('["online_only"]'),
 PARSE_JSON('["ONLINE", "APP_MOVIL"]'),
 PARSE_JSON('{"categorias": ["Tecnología"], "productos_digitales": true}'),
 PARSE_JSON('{"canal_preferido": ["ONLINE", "APP_MOVIL"], "historial_compras_online": true}'),
 1200000.00, 1150000.00, 6800000.00, 980),

-- Promoción Empresarial Q1
('Descuentos Corporativos Q1 2024', 'DESCUENTO',
 'Descuentos especiales para empresas y corporativos en mobiliario de oficina y tecnología',
 '2024-01-15', '2024-03-31', 18.0, 5000.00, 500, 1,
 PARSE_JSON('["all"]'),
 PARSE_JSON('["TELEFONO", "ONLINE"]'),
 PARSE_JSON('{"categorias": ["Mobiliario de Oficina", "Tecnología"], "volumen_minimo": 10}'),
 PARSE_JSON('{"tipos_cliente": ["EMPRESARIAL", "GOBIERNO"], "limite_credito_minimo": 50000}'),
 5000000.00, 4200000.00, 18500000.00, 320);

-- ============================================================================
-- PASO 3: GENERAR DOCUMENTOS PARA CORTEX SEARCH
-- ============================================================================

INSERT INTO RAW_DATA.DOCUMENTOS VALUES
-- Manuales de productos
('DOC-001', 'Manual de Usuario - Laptop HP Pavilion 15.6"', 'MANUAL_PRODUCTO', 'PRODUCTOS',
 'Manual completo de usuario para laptop HP Pavilion 15.6". Incluye especificaciones técnicas, configuración inicial, instalación de software, solución de problemas comunes, y garantía. La laptop HP Pavilion cuenta con procesador Intel Core i5, 8GB de RAM DDR4, 256GB SSD y Windows 11 Home preinstalado. Características principales: pantalla de 15.6 pulgadas Full HD, batería de larga duración, conectividad WiFi 6, Bluetooth 5.0, puertos USB-A, USB-C, HDMI y lector de tarjetas SD.',
 'Manual de usuario completo para configuración y uso de laptop HP Pavilion 15.6"',
 'Departamento Técnico OfficeMax', 'TECNOLOGIA', '2.1', 'es-MX',
 PARSE_JSON('["laptop", "hp", "manual", "tecnologia", "windows"]'),
 PARSE_JSON('{"categoria_producto": "TECNOLOGIA", "marca": "HP", "modelo": "Pavilion 15.6", "version_manual": "2.1"}'),
 'HP_Pavilion_Manual_Usuario_v2.1.pdf', NULL,
 '2024-01-15 10:00:00', '2024-06-15 15:30:00', '2025-12-31', TRUE, TRUE, TRUE, CURRENT_TIMESTAMP()),

('DOC-002', 'Guía de Instalación - Mouse Logitech MX Master 3S', 'MANUAL_PRODUCTO', 'PRODUCTOS',
 'Guía rápida de instalación y configuración del mouse Logitech MX Master 3S. Proceso de emparejamiento Bluetooth, instalación del software Logitech Options, configuración de botones personalizables, ajuste de sensibilidad DPI, y sincronización entre múltiples dispositivos. El mouse MX Master 3S ofrece precisión de 8000 DPI, scroll electromagnético silencioso, hasta 7 botones programables, y batería recargable con duración de 70 días. Compatible con Windows, macOS, Linux, iPadOS y Android.',
 'Guía de instalación y configuración para mouse Logitech MX Master 3S',
 'Soporte Técnico OfficeMax', 'TECNOLOGIA', '1.5', 'es-MX',
 PARSE_JSON('["mouse", "logitech", "bluetooth", "instalacion", "configuracion"]'),
 PARSE_JSON('{"categoria_producto": "PERIFERICOS", "marca": "Logitech", "modelo": "MX Master 3S", "tipo": "mouse"}'),
 'Logitech_MX_Master_3S_Setup_Guide.pdf', NULL,
 '2024-02-01 09:00:00', '2024-08-01 14:20:00', '2025-12-31', TRUE, TRUE, TRUE, CURRENT_TIMESTAMP()),

-- Políticas de la empresa
('DOC-003', 'Política de Garantías OfficeMax México', 'POLITICA', 'NORMATIVAS',
 'Política integral de garantías para todos los productos vendidos en OfficeMax México. Garantías por categoría: Tecnología (1-3 años según fabricante), Mobiliario (2-5 años), Papelería (30 días), Material Escolar (90 días). Proceso de reclamación: presentar ticket de compra, evaluación técnica, opciones de reparación, reemplazo o reembolso. Exclusiones: daño por mal uso, desgaste normal, modificaciones no autorizadas. Cobertura extendida disponible para productos de tecnología. Centros de servicio autorizados en todas las ciudades principales.',
 'Política completa de garantías y servicio post-venta para productos OfficeMax',
 'Departamento Jurídico', 'NORMATIVAS', '3.2', 'es-MX',
 PARSE_JSON('["garantia", "politica", "servicio", "reclamacion", "cobertura"]'),
 PARSE_JSON('{"departamento": "JURIDICO", "vigencia": "2024-2025", "revision": "3.2", "alcance": "nacional"}'),
 'Politica_Garantias_OfficeMax_v3.2.pdf', 'https://www.officemax.com.mx/politicas/garantias',
 '2024-01-01 08:00:00', '2024-07-15 16:45:00', '2025-12-31', TRUE, TRUE, TRUE, CURRENT_TIMESTAMP()),

('DOC-004', 'Política de Devoluciones y Cambios', 'POLITICA', 'NORMATIVAS',
 'Política de devoluciones y cambios para clientes OfficeMax México. Plazos: 30 días para tecnología sin usar, 15 días para papelería, 7 días para material escolar personalizado. Condiciones: producto en estado original, empaque completo, ticket de compra. Excepciones: productos personalizados, software descargado, consumibles usados. Proceso en tienda: presentar producto y ticket, evaluación del estado, autorización de devolución, opciones de cambio por producto equivalente, nota de crédito o reembolso. Compras online: proceso similar más costos de envío.',
 'Política de devoluciones, cambios y reembolsos para todos los canales de venta',
 'Departamento de Atención al Cliente', 'NORMATIVAS', '2.8', 'es-MX',
 PARSE_JSON('["devolucion", "cambio", "reembolso", "politica", "cliente"]'),
 PARSE_JSON('{"departamento": "ATENCION_CLIENTE", "canales": ["TIENDA", "ONLINE", "TELEFONO"], "vigencia": "2024"}'),
 'Politica_Devoluciones_v2.8.pdf', 'https://www.officemax.com.mx/politicas/devoluciones',
 '2024-03-01 10:30:00', '2024-09-10 11:15:00', '2025-12-31', TRUE, TRUE, TRUE, CURRENT_TIMESTAMP()),

-- FAQs y tutoriales
('DOC-005', 'Preguntas Frecuentes - Compras Online', 'FAQ', 'SERVICIOS',
 'Preguntas frecuentes sobre compras en línea en OfficeMax México. ¿Cómo crear una cuenta? ¿Métodos de pago aceptados? ¿Tiempos de entrega? ¿Costos de envío? ¿Cómo rastrear mi pedido? ¿Qué hacer si no estoy satisfecho? Métodos de pago: tarjetas de crédito/débito, PayPal, transferencia bancaria, meses sin intereses. Envío gratis en compras mayores a $999. Entregas de 2-5 días hábiles según ubicación. Click & Collect disponible en todas las tiendas. Soporte técnico 24/7 para compras en línea.',
 'Preguntas y respuestas frecuentes sobre el proceso de compra en línea',
 'Equipo de E-commerce', 'SERVICIOS', '4.1', 'es-MX',
 PARSE_JSON('["faq", "compras", "online", "ecommerce", "soporte"]'),
 PARSE_JSON('{"canal": "ONLINE", "categoria": "FAQ", "actualizacion": "mensual", "idioma": "es-MX"}'),
 'FAQ_Compras_Online_v4.1.pdf', 'https://www.officemax.com.mx/ayuda/faq-online',
 '2024-04-15 14:00:00', '2024-10-01 09:30:00', '2025-12-31', TRUE, TRUE, TRUE, CURRENT_TIMESTAMP()),

('DOC-006', 'Tutorial - Configuración de Impresora HP en Red', 'TUTORIAL', 'CAPACITACION',
 'Tutorial paso a paso para configurar impresoras HP en red corporativa. Requisitos previos: red WiFi o Ethernet, drivers actualizados, permisos administrativos. Pasos: 1) Conexión física de la impresora, 2) Configuración de red desde panel de control, 3) Instalación de drivers en computadoras, 4) Configuración de impresión compartida, 5) Pruebas de conectividad, 6) Configuración de permisos de usuario, 7) Monitoreo de estado. Solución de problemas comunes: problemas de conectividad, drivers incompatibles, permisos de red.',
 'Guía técnica para configurar impresoras HP en entornos de red corporativa',
 'Especialista en Redes', 'CAPACITACION', '1.3', 'es-MX',
 PARSE_JSON('["tutorial", "impresora", "hp", "red", "configuracion"]'),
 PARSE_JSON('{"nivel": "intermedio", "tiempo_estimado": "45 minutos", "categoria": "REDES", "productos": ["HP_LaserJet", "HP_OfficeJet"]}'),
 'Tutorial_Configuracion_Impresora_HP_Red_v1.3.pdf', NULL,
 '2024-05-20 11:45:00', '2024-08-25 16:20:00', '2025-12-31', TRUE, FALSE, TRUE, CURRENT_TIMESTAMP()),

-- Promociones y marketing
('DOC-007', 'Catálogo Back-to-School 2024', 'PROMOCION', 'MARKETING',
 'Catálogo especial para la temporada de regreso a clases 2024. Productos destacados: mochilas JanSport y Kipling, útiles escolares básicos, tablets educativas, laptops para estudiantes, material de arte y manualidades. Ofertas especiales: 2x1 en cuadernos, 15% de descuento en mochilas, financiamiento sin intereses en tecnología. Kits escolares prearmados por nivel: preescolar, primaria, secundaria, preparatoria. Servicios adicionales: personalización de productos, entrega a domicilio gratuita en compras mayores a $1,500, programa de lealtad para familias.',
 'Catálogo promocional de productos para regreso a clases con ofertas especiales',
 'Departamento de Marketing', 'MARKETING', '1.0', 'es-MX',
 PARSE_JSON('["catalogo", "back-to-school", "promocion", "descuentos", "estudiantes"]'),
 PARSE_JSON('{"temporada": "BACK_TO_SCHOOL", "año": "2024", "vigencia": "julio-agosto", "publico": "familias"}'),
 'Catalogo_Back_to_School_2024.pdf', 'https://www.officemax.com.mx/promociones/back-to-school-2024',
 '2024-06-01 08:00:00', '2024-07-10 10:00:00', '2024-08-31', TRUE, TRUE, TRUE, CURRENT_TIMESTAMP()),

('DOC-008', 'Guía de Productos para Oficina en Casa', 'MANUAL_PRODUCTO', 'PRODUCTOS',
 'Guía completa para establecer una oficina en casa productiva y cómoda. Mobiliario esencial: escritorio ergonómico, silla con soporte lumbar, organizadores, iluminación adecuada. Tecnología necesaria: computadora o laptop, monitor adicional, webcam HD, audífonos con micrófono, router WiFi 6. Papelería básica: cuadernos, plumas, marcadores, organizadores de archivo. Consejos de productividad: organización del espacio, rutinas de trabajo, pausas activas. Recomendaciones de productos OfficeMax con precios y especificaciones.',
 'Guía para crear una oficina en casa efectiva con productos recomendados',
 'Consultor en Productividad', 'PRODUCTOS', '2.0', 'es-MX',
 PARSE_JSON('["oficina", "casa", "home-office", "productividad", "recomendaciones"]'),
 PARSE_JSON('{"categoria": "HOME_OFFICE", "target": "profesionales", "productos_incluidos": 25, "presupuesto": "todos"}'),
 'Guia_Oficina_en_Casa_v2.0.pdf', 'https://www.officemax.com.mx/guias/oficina-en-casa',
 '2024-03-10 13:20:00', '2024-09-15 14:40:00', '2025-12-31', TRUE, TRUE, TRUE, CURRENT_TIMESTAMP());

-- ============================================================================
-- PASO 4: ACTUALIZAR ESTADÍSTICAS Y CREAR VISTAS ANALÍTICAS
-- ============================================================================

-- Vista consolidada de ventas con información enriquecida
CREATE OR REPLACE VIEW ANALYTICS.VENTAS_CONSOLIDADAS AS
SELECT 
    v.VENTA_ID,
    v.TICKET_ID,
    v.FECHA_VENTA,
    v.FECHA_SOLO,
    v.MES_ANO,
    EXTRACT(YEAR FROM v.FECHA_VENTA) as AÑO,
    EXTRACT(MONTH FROM v.FECHA_VENTA) as MES,
    EXTRACT(DAY FROM v.FECHA_VENTA) as DIA,
    EXTRACT(DOW FROM v.FECHA_VENTA) as DIA_SEMANA,
    CASE EXTRACT(DOW FROM v.FECHA_VENTA)
        WHEN 0 THEN 'Domingo'
        WHEN 1 THEN 'Lunes'
        WHEN 2 THEN 'Martes'
        WHEN 3 THEN 'Miércoles'
        WHEN 4 THEN 'Jueves'
        WHEN 5 THEN 'Viernes'
        WHEN 6 THEN 'Sábado'
    END as NOMBRE_DIA,
    
    -- Cliente
    v.CLIENTE_ID,
    c.NOMBRE_COMPLETO as CLIENTE_NOMBRE,
    v.TIPO_CLIENTE,
    c.SEGMENTO as CLIENTE_SEGMENTO,
    c.ESTADO as CLIENTE_ESTADO,
    
    -- Producto
    v.PRODUCTO_ID,
    p.NOMBRE_PRODUCTO,
    p.MARCA,
    p.SKU,
    cat.CATEGORIA_PADRE,
    cat.CATEGORIA_HIJO,
    p.TEMPORADA,
    
    -- Transacción
    v.CANTIDAD,
    v.PRECIO_UNITARIO,
    v.DESCUENTO_UNITARIO,
    v.SUBTOTAL,
    v.DESCUENTO_TOTAL,
    v.TOTAL_LINEA,
    v.COSTO_TOTAL,
    v.MARGEN_BRUTO,
    v.PORCENTAJE_MARGEN,
    
    -- Ubicación y canal
    v.SUCURSAL_ID,
    s.NOMBRE_SUCURSAL,
    s.ESTADO as SUCURSAL_ESTADO,
    s.FORMATO_TIENDA,
    v.CANAL_VENTA,
    
    -- Promociones
    v.CODIGO_PROMOCION,
    v.TIPO_DESCUENTO,
    v.PORCENTAJE_DESCUENTO,
    
    -- Pago
    v.METODO_PAGO,
    v.VENDEDOR_ID
    
FROM RAW_DATA.VENTAS v
LEFT JOIN RAW_DATA.CLIENTES c ON v.CLIENTE_ID = c.CLIENTE_ID
LEFT JOIN RAW_DATA.PRODUCTOS p ON v.PRODUCTO_ID = p.PRODUCTO_ID
LEFT JOIN RAW_DATA.CATEGORIAS cat ON p.CATEGORIA_ID = cat.CATEGORIA_ID
LEFT JOIN RAW_DATA.SUCURSALES s ON v.SUCURSAL_ID = s.SUCURSAL_ID;

-- Vista de métricas diarias agregadas
CREATE OR REPLACE VIEW ANALYTICS.METRICAS_DIARIAS AS
SELECT 
    FECHA_SOLO,
    AÑO,
    MES,
    NOMBRE_DIA,
    
    -- Métricas de ventas
    COUNT(*) as TRANSACCIONES_TOTAL,
    COUNT(DISTINCT TICKET_ID) as TICKETS_UNICOS,
    COUNT(DISTINCT CLIENTE_ID) as CLIENTES_UNICOS,
    SUM(CANTIDAD) as UNIDADES_VENDIDAS,
    SUM(TOTAL_LINEA) as INGRESOS_BRUTOS,
    SUM(DESCUENTO_TOTAL) as DESCUENTOS_TOTALES,
    SUM(TOTAL_LINEA - DESCUENTO_TOTAL) as INGRESOS_NETOS,
    SUM(MARGEN_BRUTO) as MARGEN_TOTAL,
    
    -- Métricas promedio
    AVG(TOTAL_LINEA) as TICKET_PROMEDIO,
    AVG(CANTIDAD) as CANTIDAD_PROMEDIO,
    AVG(PORCENTAJE_MARGEN) as MARGEN_PROMEDIO_PCT,
    
    -- Por canal
    COUNT(CASE WHEN CANAL_VENTA = 'TIENDA' THEN 1 END) as VENTAS_TIENDA,
    COUNT(CASE WHEN CANAL_VENTA = 'ONLINE' THEN 1 END) as VENTAS_ONLINE,
    COUNT(CASE WHEN CANAL_VENTA = 'APP_MOVIL' THEN 1 END) as VENTAS_APP,
    COUNT(CASE WHEN CANAL_VENTA = 'TELEFONO' THEN 1 END) as VENTAS_TELEFONO,
    
    -- Por tipo de cliente
    COUNT(CASE WHEN TIPO_CLIENTE = 'INDIVIDUAL' THEN 1 END) as VENTAS_INDIVIDUAL,
    COUNT(CASE WHEN TIPO_CLIENTE = 'EMPRESARIAL' THEN 1 END) as VENTAS_EMPRESARIAL,
    COUNT(CASE WHEN TIPO_CLIENTE = 'EDUCATIVO' THEN 1 END) as VENTAS_EDUCATIVO,
    COUNT(CASE WHEN TIPO_CLIENTE = 'GOBIERNO' THEN 1 END) as VENTAS_GOBIERNO

FROM ANALYTICS.VENTAS_CONSOLIDADAS
GROUP BY FECHA_SOLO, AÑO, MES, NOMBRE_DIA
ORDER BY FECHA_SOLO;

-- Vista de análisis por producto
CREATE OR REPLACE VIEW ANALYTICS.ANALISIS_PRODUCTOS AS
SELECT 
    p.PRODUCTO_ID,
    p.SKU,
    p.NOMBRE_PRODUCTO,
    p.MARCA,
    cat.CATEGORIA_PADRE,
    cat.CATEGORIA_HIJO,
    p.PRECIO_REGULAR,
    p.COSTO_UNITARIO,
    
    -- Métricas de venta
    COUNT(v.VENTA_ID) as TRANSACCIONES,
    SUM(v.CANTIDAD) as UNIDADES_VENDIDAS,
    SUM(v.TOTAL_LINEA) as INGRESOS_TOTALES,
    AVG(v.PRECIO_UNITARIO) as PRECIO_PROMEDIO_VENTA,
    SUM(v.MARGEN_BRUTO) as MARGEN_TOTAL,
    
    -- Inventario
    SUM(i.STOCK_ACTUAL) as STOCK_TOTAL_SUCURSALES,
    AVG(i.ROTACION_DIAS) as ROTACION_PROMEDIO_DIAS,
    
    -- Análisis temporal
    MIN(v.FECHA_VENTA) as PRIMERA_VENTA,
    MAX(v.FECHA_VENTA) as ULTIMA_VENTA,
    COUNT(DISTINCT v.FECHA_SOLO) as DIAS_CON_VENTAS,
    
    -- Distribución por canal
    COUNT(CASE WHEN v.CANAL_VENTA = 'TIENDA' THEN 1 END) as VENTAS_TIENDA,
    COUNT(CASE WHEN v.CANAL_VENTA = 'ONLINE' THEN 1 END) as VENTAS_ONLINE,
    
    -- Top sucursales
    LISTAGG(DISTINCT s.NOMBRE_SUCURSAL, ', ') WITHIN GROUP (ORDER BY s.NOMBRE_SUCURSAL) as SUCURSALES_VENTAS
    
FROM RAW_DATA.PRODUCTOS p
LEFT JOIN RAW_DATA.VENTAS v ON p.PRODUCTO_ID = v.PRODUCTO_ID
LEFT JOIN RAW_DATA.CATEGORIAS cat ON p.CATEGORIA_ID = cat.CATEGORIA_ID
LEFT JOIN RAW_DATA.INVENTARIO i ON p.PRODUCTO_ID = i.PRODUCTO_ID
LEFT JOIN RAW_DATA.SUCURSALES s ON v.SUCURSAL_ID = s.SUCURSAL_ID
WHERE p.ACTIVO = TRUE
GROUP BY p.PRODUCTO_ID, p.SKU, p.NOMBRE_PRODUCTO, p.MARCA, 
         cat.CATEGORIA_PADRE, cat.CATEGORIA_HIJO, p.PRECIO_REGULAR, p.COSTO_UNITARIO
ORDER BY INGRESOS_TOTALES DESC NULLS LAST;

-- ============================================================================
-- Estadísticas finales
-- ============================================================================

SELECT 
    '🎯 DATOS SINTÉTICOS GENERADOS EXITOSAMENTE' as RESULTADO,
    'Ventas históricas, eventos de marketing y documentos creados' as DETALLE,
    (SELECT COUNT(*) FROM RAW_DATA.VENTAS) as TOTAL_VENTAS,
    (SELECT COUNT(*) FROM RAW_DATA.EVENTOS_MARKETING) as TOTAL_EVENTOS,
    (SELECT COUNT(*) FROM RAW_DATA.DOCUMENTOS) as TOTAL_DOCUMENTOS,
    CURRENT_TIMESTAMP() as TIMESTAMP_COMPLETION;


