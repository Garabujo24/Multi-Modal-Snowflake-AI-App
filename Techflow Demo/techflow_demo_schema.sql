-- =====================================================
-- TECHFLOW SOLUTIONS - SNOWFLAKE CORTEX DEMO SCHEMA
-- =====================================================
-- Demo Kit para Snowflake Cortex
-- Empresa: TechFlow Solutions (Tecnología y Servicios Digitales)
-- Ingeniero de Ventas: Demostración Integral de Capacidades Cortex
-- =====================================================

-- Configuración inicial de la base de datos y warehouse
CREATE DATABASE IF NOT EXISTS TECHFLOW_DEMO;
USE DATABASE TECHFLOW_DEMO;
CREATE SCHEMA IF NOT EXISTS CORTEX_DEMO;
USE SCHEMA CORTEX_DEMO;

-- =====================================================
-- 1. TABLA DE PRODUCTOS/SERVICIOS
-- =====================================================
CREATE OR REPLACE TABLE PRODUCTOS (
    PRODUCTO_ID VARCHAR(10) PRIMARY KEY,
    NOMBRE VARCHAR(100) NOT NULL,
    CATEGORIA VARCHAR(50) NOT NULL,
    DESCRIPCION VARCHAR(500),
    COSTO_UNITARIO DECIMAL(10,2),
    PRECIO_LISTA DECIMAL(10,2),
    FECHA_LANZAMIENTO DATE,
    ESTADO VARCHAR(20) DEFAULT 'ACTIVO',
    URL_IMAGEN VARCHAR(200),
    ESPECIFICACIONES_TECNICAS VARCHAR(1000)
);

-- Datos de ejemplo para PRODUCTOS
INSERT INTO PRODUCTOS VALUES
('PROD001', 'CloudSync Enterprise', 'Software', 'Plataforma de sincronización y gestión de datos empresariales en la nube con capacidades de IA', 1200.00, 2499.00, '2023-01-15', 'ACTIVO', 'https://techflow.com/images/cloudsync.jpg', 'CPU: 4 cores mín, RAM: 8GB, Storage: 100GB, API REST, Compatible con AWS/Azure/GCP'),
('PROD002', 'DataFlow Analytics Pro', 'Software', 'Suite completa de análisis de datos con visualizaciones avanzadas y machine learning integrado', 800.00, 1899.00, '2023-03-22', 'ACTIVO', 'https://techflow.com/images/dataflow.jpg', 'Web-based, Compatible con Snowflake/BigQuery/Redshift, 500GB almacenamiento incluido'),
('PROD003', 'SecureVault Premium', 'Seguridad', 'Sistema de gestión de credenciales empresariales con autenticación multifactor', 450.00, 999.00, '2022-11-08', 'ACTIVO', 'https://techflow.com/images/securevault.jpg', 'Encriptación AES-256, SSO, Compatible con LDAP/SAML, API disponible'),
('PROD004', 'Consultoría Digital Transformation', 'Servicios', 'Servicios especializados de consultoría para transformación digital empresarial', 2500.00, 5000.00, '2022-06-01', 'ACTIVO', 'https://techflow.com/images/consulting.jpg', 'Evaluación inicial, Roadmap estratégico, Implementación supervisada, Capacitación incluida'),
('PROD005', 'AIChat Assistant Business', 'IA/ML', 'Asistente virtual inteligente para atención al cliente y soporte interno', 600.00, 1299.00, '2024-01-10', 'ACTIVO', 'https://techflow.com/images/aichat.jpg', 'Procesamiento de lenguaje natural, Integración CRM, Soporte 24/7, Multi-idioma'),
('PROD006', 'Legacy Migration Tool', 'Herramientas', 'Herramienta automatizada para migración de sistemas legacy a arquitecturas modernas', 300.00, 799.00, '2023-08-15', 'ACTIVO', 'https://techflow.com/images/migration.jpg', 'Soporte mainframe, Base de datos legacy, Validación automática, Rollback capability'),
('PROD007', 'Mobile Workforce Suite', 'Software', 'Plataforma integral para gestión de equipos remotos y móviles', 350.00, 899.00, '2023-05-12', 'ACTIVO', 'https://techflow.com/images/mobile.jpg', 'Apps iOS/Android, GPS tracking, Gestión de tareas, Reportes en tiempo real'),
('PROD008', 'Quantum Analytics Beta', 'Software', 'Plataforma experimental de análisis cuántico para procesamiento de big data', 2000.00, 4999.00, '2024-02-28', 'BETA', 'https://techflow.com/images/quantum.jpg', 'Procesamiento cuántico simulado, Algoritmos avanzados ML, Requiere hardware especializado');

-- =====================================================
-- 2. TABLA DE CLIENTES
-- =====================================================
CREATE OR REPLACE TABLE CLIENTES (
    CLIENTE_ID VARCHAR(10) PRIMARY KEY,
    NOMBRE VARCHAR(100) NOT NULL,
    EMAIL VARCHAR(100),
    SEGMENTO VARCHAR(30),
    FECHA_REGISTRO DATE,
    REGION_GEOGRAFICA VARCHAR(50),
    CLTV_ESTIMADO DECIMAL(12,2),
    INDUSTRIA VARCHAR(50),
    TAMAÑO_EMPRESA VARCHAR(20),
    ESTADO_CLIENTE VARCHAR(20) DEFAULT 'ACTIVO'
);

-- Datos de ejemplo para CLIENTES
INSERT INTO CLIENTES VALUES
('CLI001', 'Global Manufacturing Corp', 'procurement@globalmanuf.com', 'Enterprise', '2022-03-15', 'Norte América', 125000.00, 'Manufactura', 'Grande', 'ACTIVO'),
('CLI002', 'FinTech Innovations Ltd', 'tech@fintechinno.com', 'Mid-Market', '2022-08-22', 'Europa', 75000.00, 'Servicios Financieros', 'Mediana', 'ACTIVO'),
('CLI003', 'HealthCare Solutions Inc', 'it@healthcaresol.com', 'Enterprise', '2021-11-30', 'Norte América', 200000.00, 'Salud', 'Grande', 'ACTIVO'),
('CLI004', 'RetailChain Express', 'systems@retailchain.com', 'SMB', '2023-01-18', 'Asia-Pacífico', 45000.00, 'Retail', 'Mediana', 'ACTIVO'),
('CLI005', 'EduTech University', 'admin@edutech.edu', 'Education', '2022-09-05', 'Europa', 35000.00, 'Educación', 'Mediana', 'ACTIVO'),
('CLI006', 'Energy Solutions Group', 'digitalteam@energysol.com', 'Enterprise', '2023-02-14', 'Norte América', 180000.00, 'Energía', 'Grande', 'ACTIVO'),
('CLI007', 'StartupTech Dynamics', 'founders@startuptech.com', 'SMB', '2023-06-20', 'Norte América', 25000.00, 'Tecnología', 'Pequeña', 'ACTIVO'),
('CLI008', 'Government Agency Alpha', 'procurement@gov-alpha.gov', 'Government', '2022-12-03', 'Norte América', 150000.00, 'Gobierno', 'Grande', 'ACTIVO'),
('CLI009', 'AutoMotive Innovations', 'it-dept@automotive-inno.com', 'Mid-Market', '2023-04-10', 'Europa', 85000.00, 'Automotriz', 'Mediana', 'ACTIVO'),
('CLI010', 'TelecomGlobal Networks', 'enterprise@telecomglobal.com', 'Enterprise', '2021-07-15', 'Asia-Pacífico', 220000.00, 'Telecomunicaciones', 'Grande', 'ACTIVO');

-- =====================================================
-- 3. TABLA DE TRANSACCIONES/VENTAS
-- =====================================================
CREATE OR REPLACE TABLE TRANSACCIONES (
    TRANSACCION_ID VARCHAR(15) PRIMARY KEY,
    FECHA_TRANSACCION TIMESTAMP,
    PRODUCTO_ID VARCHAR(10),
    CLIENTE_ID VARCHAR(10),
    CANTIDAD INT,
    PRECIO_UNITARIO DECIMAL(10,2),
    CANAL_VENTA VARCHAR(30),
    REGION VARCHAR(50),
    METODO_PAGO VARCHAR(30),
    ESTADO_PEDIDO VARCHAR(20),
    DESCUENTO_APLICADO DECIMAL(5,2) DEFAULT 0.00,
    VENDEDOR_ID VARCHAR(10),
    FOREIGN KEY (PRODUCTO_ID) REFERENCES PRODUCTOS(PRODUCTO_ID),
    FOREIGN KEY (CLIENTE_ID) REFERENCES CLIENTES(CLIENTE_ID)
);

-- Datos de ejemplo para TRANSACCIONES
INSERT INTO TRANSACCIONES VALUES
('TXN001-2024-001', '2024-01-15 10:30:00', 'PROD001', 'CLI001', 2, 2499.00, 'Venta Directa', 'Norte América', 'Transferencia', 'COMPLETADO', 10.00, 'VEND001'),
('TXN001-2024-002', '2024-01-22 14:45:00', 'PROD002', 'CLI002', 1, 1899.00, 'Partner', 'Europa', 'Tarjeta Crédito', 'COMPLETADO', 5.00, 'VEND002'),
('TXN001-2024-003', '2024-02-03 09:15:00', 'PROD003', 'CLI003', 5, 999.00, 'Online', 'Norte América', 'Transferencia', 'COMPLETADO', 15.00, 'VEND003'),
('TXN001-2024-004', '2024-02-10 16:20:00', 'PROD004', 'CLI001', 1, 5000.00, 'Venta Directa', 'Norte América', 'Transferencia', 'EN_PROCESO', 0.00, 'VEND001'),
('TXN001-2024-005', '2024-02-18 11:00:00', 'PROD005', 'CLI004', 3, 1299.00, 'Partner', 'Asia-Pacífico', 'Tarjeta Crédito', 'COMPLETADO', 8.00, 'VEND004'),
('TXN001-2024-006', '2024-03-05 13:30:00', 'PROD001', 'CLI005', 1, 2499.00, 'Online', 'Europa', 'PayPal', 'COMPLETADO', 0.00, 'VEND002'),
('TXN001-2024-007', '2024-03-12 08:45:00', 'PROD006', 'CLI006', 2, 799.00, 'Venta Directa', 'Norte América', 'Transferencia', 'COMPLETADO', 20.00, 'VEND005'),
('TXN001-2024-008', '2024-03-20 15:10:00', 'PROD007', 'CLI007', 1, 899.00, 'Online', 'Norte América', 'Tarjeta Crédito', 'PENDIENTE', 0.00, 'VEND003'),
('TXN001-2024-009', '2024-03-25 12:00:00', 'PROD002', 'CLI008', 3, 1899.00, 'Venta Directa', 'Norte América', 'Transferencia', 'COMPLETADO', 12.00, 'VEND001'),
('TXN001-2024-010', '2024-04-02 10:20:00', 'PROD003', 'CLI009', 4, 999.00, 'Partner', 'Europa', 'Transferencia', 'COMPLETADO', 10.00, 'VEND002'),
('TXN001-2024-011', '2024-04-08 14:35:00', 'PROD005', 'CLI010', 2, 1299.00, 'Venta Directa', 'Asia-Pacífico', 'Transferencia', 'COMPLETADO', 5.00, 'VEND004'),
('TXN001-2024-012', '2024-04-15 09:50:00', 'PROD008', 'CLI003', 1, 4999.00, 'Venta Directa', 'Norte América', 'Transferencia', 'EN_EVALUACION', 0.00, 'VEND005');

-- =====================================================
-- 4. TABLA DE CAMPAÑAS DE MARKETING
-- =====================================================
CREATE OR REPLACE TABLE CAMPANAS_MARKETING (
    CAMPANA_ID VARCHAR(10) PRIMARY KEY,
    NOMBRE VARCHAR(100) NOT NULL,
    FECHA_INICIO DATE,
    FECHA_FIN DATE,
    PRESUPUESTO DECIMAL(12,2),
    CANAL_MARKETING VARCHAR(50),
    REGION_OBJETIVO VARCHAR(50),
    LEADS_GENERADOS INT DEFAULT 0,
    CONVERSIONES INT DEFAULT 0,
    ROI_CALCULADO DECIMAL(5,2),
    ESTADO_CAMPANA VARCHAR(20)
);

-- Datos de ejemplo para CAMPAÑAS
INSERT INTO CAMPANAS_MARKETING VALUES
('CAMP001', 'CloudSync Q1 Launch', '2024-01-01', '2024-03-31', 75000.00, 'Digital + Events', 'Norte América', 1250, 85, 2.40, 'COMPLETADA'),
('CAMP002', 'European Expansion Drive', '2024-02-01', '2024-04-30', 120000.00, 'LinkedIn + Google Ads', 'Europa', 2100, 145, 3.20, 'COMPLETADA'),
('CAMP003', 'AI/ML Product Suite', '2024-03-15', '2024-06-15', 95000.00, 'Content Marketing', 'Global', 1800, 95, 1.85, 'ACTIVA'),
('CAMP004', 'Enterprise Security Focus', '2024-01-15', '2024-05-15', 85000.00, 'Webinars + Email', 'Norte América', 950, 125, 4.10, 'ACTIVA'),
('CAMP005', 'APAC Market Entry', '2024-04-01', '2024-07-31', 110000.00, 'Local Partners', 'Asia-Pacífico', 750, 45, 1.20, 'ACTIVA'),
('CAMP006', 'Government Sector Outreach', '2024-02-01', '2024-08-31', 65000.00, 'Industry Events', 'Norte América', 320, 25, 5.50, 'ACTIVA'),
('CAMP007', 'SMB Digital Transformation', '2024-03-01', '2024-05-31', 45000.00, 'Social Media', 'Global', 1100, 78, 2.10, 'ACTIVA');

-- =====================================================
-- 5. TABLA DE SOPORTE/FEEDBACK
-- =====================================================
CREATE OR REPLACE TABLE TICKETS_SOPORTE (
    TICKET_ID VARCHAR(15) PRIMARY KEY,
    CLIENTE_ID VARCHAR(10),
    PRODUCTO_ID VARCHAR(10),
    FECHA_CREACION TIMESTAMP,
    TIPO_PROBLEMA VARCHAR(50),
    DESCRIPCION_PROBLEMA VARCHAR(1000),
    PRIORIDAD VARCHAR(20),
    ESTADO VARCHAR(20),
    SENTIMIENTO VARCHAR(20),
    TIEMPO_RESOLUCION_HORAS INT,
    SATISFACCION_CLIENTE INT, -- Escala 1-5
    AGENTE_ASIGNADO VARCHAR(50),
    FOREIGN KEY (CLIENTE_ID) REFERENCES CLIENTES(CLIENTE_ID),
    FOREIGN KEY (PRODUCTO_ID) REFERENCES PRODUCTOS(PRODUCTO_ID)
);

-- Datos de ejemplo para TICKETS_SOPORTE
INSERT INTO TICKETS_SOPORTE VALUES
('TICK-2024-001', 'CLI001', 'PROD001', '2024-01-20 09:30:00', 'Error de Integración', 'CloudSync no puede conectarse con nuestro sistema ERP SAP. Error código CS-401 aparece constantemente durante la sincronización de datos de inventario.', 'ALTA', 'RESUELTO', 'NEGATIVO', 18, 4, 'Maria Rodriguez'),
('TICK-2024-002', 'CLI002', 'PROD002', '2024-01-25 14:15:00', 'Solicitud de Función', 'Necesitamos capacidad de exportar reportes a formato Excel con fórmulas dinámicas. Actualmente solo permite PDF estático que no es útil para nuestros analistas.', 'MEDIA', 'EN_DESARROLLO', 'NEUTRO', NULL, NULL, 'Carlos Martinez'),
('TICK-2024-003', 'CLI003', 'PROD003', '2024-02-02 11:45:00', 'Problema de Rendimiento', 'SecureVault está experimentando lentitud extrema al acceder a credenciales. Los usuarios reportan timeouts frecuentes especialmente en horas pico (9-11 AM).', 'ALTA', 'RESUELTO', 'NEGATIVO', 6, 5, 'Ana Silva'),
('TICK-2024-004', 'CLI004', 'PROD005', '2024-02-08 16:20:00', 'Consulta General', 'Excelente producto! Queremos expandir el uso de AIChat a otros departamentos. ¿Pueden proporcionar descuentos por volumen y capacitación adicional?', 'BAJA', 'CERRADO', 'POSITIVO', 2, 5, 'Luis Fernandez'),
('TICK-2024-005', 'CLI005', 'PROD001', '2024-02-12 08:00:00', 'Error de Configuración', 'Después de la última actualización, CloudSync perdió todas las configuraciones personalizadas de mapeo de datos. Necesitamos restaurar urgentemente las reglas de transformación.', 'CRITICA', 'RESUELTO', 'NEGATIVO', 4, 3, 'Maria Rodriguez'),
('TICK-2024-006', 'CLI006', 'PROD006', '2024-02-18 13:30:00', 'Problema de Compatibilidad', 'Legacy Migration Tool no reconoce nuestro mainframe IBM z/OS versión 2.4. La documentación menciona soporte hasta versión 2.3. ¿Cuándo estará disponible la actualización?', 'MEDIA', 'EN_PROCESO', 'NEUTRO', NULL, NULL, 'Roberto Kim'),
('TICK-2024-007', 'CLI007', 'PROD007', '2024-03-01 10:15:00', 'Error de Sincronización', 'Mobile Workforce Suite no sincroniza correctamente las ubicaciones GPS. Los reportes muestran coordenadas incorrectas para todo el equipo de campo desde hace 3 días.', 'ALTA', 'RESUELTO', 'NEGATIVO', 12, 4, 'Sofia Gonzalez'),
('TICK-2024-008', 'CLI008', 'PROD002', '2024-03-05 15:45:00', 'Solicitud de Seguridad', 'Necesitamos certificación SOC 2 Type II para DataFlow Analytics Pro para cumplir con requisitos gubernamentales. ¿Cuál es el timeline estimado para obtener esta certificación?', 'MEDIA', 'EN_PROCESO', 'NEUTRO', NULL, NULL, 'Manuel Torres'),
('TICK-2024-009', 'CLI009', 'PROD003', '2024-03-10 09:20:00', 'Problema de Licenciamiento', 'SecureVault reporta que hemos excedido el límite de usuarios concurrentes (licenciados para 500, usando 650). Necesitamos actualizar licencias urgentemente para evitar interrupciones.', 'CRITICA', 'RESUELTO', 'NEUTRO', 1, 4, 'Patricia Lopez'),
('TICK-2024-010', 'CLI010', 'PROD005', '2024-03-15 12:00:00', 'Consulta de Integración', 'AIChat Assistant funciona perfectamente! Queremos integrarlo con nuestro CRM Salesforce. ¿Tienen documentación de API y ejemplos de implementación disponibles?', 'BAJA', 'RESUELTO', 'POSITIVO', 8, 5, 'Diego Ramirez'),
('TICK-2024-011', 'CLI001', 'PROD004', '2024-03-20 14:30:00', 'Solicitud de Consultoría', 'Necesitamos extender el proyecto de Consultoría Digital Transformation. Los resultados han sido excelentes y queremos incluir migración a arquitectura de microservicios. ¿Pueden ajustar el scope?', 'MEDIA', 'EN_PROCESO', 'POSITIVO', NULL, NULL, 'Carlos Martinez'),
('TICK-2024-012', 'CLI003', 'PROD008', '2024-03-25 11:10:00', 'Error Beta', 'Quantum Analytics Beta presenta errores de memoria al procesar datasets mayores a 10TB. Los algoritmos cuánticos se cuelgan y requieren reinicio manual del sistema.', 'ALTA', 'EN_INVESTIGACION', 'NEGATIVO', NULL, NULL, 'Maria Rodriguez');

-- =====================================================
-- VISTAS ANALÍTICAS PARA CORTEX ANALYST
-- =====================================================

-- Vista de métricas de ventas por periodo
CREATE OR REPLACE VIEW VISTA_VENTAS_RESUMEN AS
SELECT 
    DATE_TRUNC('MONTH', FECHA_TRANSACCION) AS MES,
    COUNT(*) AS NUMERO_TRANSACCIONES,
    SUM(CANTIDAD * PRECIO_UNITARIO * (1 - DESCUENTO_APLICADO/100)) AS INGRESOS_TOTALES,
    AVG(CANTIDAD * PRECIO_UNITARIO * (1 - DESCUENTO_APLICADO/100)) AS TICKET_PROMEDIO,
    COUNT(DISTINCT CLIENTE_ID) AS CLIENTES_UNICOS
FROM TRANSACCIONES 
WHERE ESTADO_PEDIDO = 'COMPLETADO'
GROUP BY DATE_TRUNC('MONTH', FECHA_TRANSACCION)
ORDER BY MES;

-- Vista de rendimiento de productos
CREATE OR REPLACE VIEW VISTA_PRODUCTOS_RENDIMIENTO AS
SELECT 
    p.PRODUCTO_ID,
    p.NOMBRE,
    p.CATEGORIA,
    COUNT(t.TRANSACCION_ID) AS VENTAS_TOTALES,
    SUM(t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100)) AS INGRESOS_PRODUCTO,
    AVG(t.PRECIO_UNITARIO) AS PRECIO_PROMEDIO,
    (SUM(t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100)) - SUM(t.CANTIDAD * p.COSTO_UNITARIO)) AS MARGEN_BRUTO
FROM PRODUCTOS p
LEFT JOIN TRANSACCIONES t ON p.PRODUCTO_ID = t.PRODUCTO_ID AND t.ESTADO_PEDIDO = 'COMPLETADO'
GROUP BY p.PRODUCTO_ID, p.NOMBRE, p.CATEGORIA, p.COSTO_UNITARIO
ORDER BY INGRESOS_PRODUCTO DESC;

-- Vista de análisis de clientes
CREATE OR REPLACE VIEW VISTA_CLIENTES_ANALISIS AS
SELECT 
    c.CLIENTE_ID,
    c.NOMBRE,
    c.SEGMENTO,
    c.REGION_GEOGRAFICA,
    c.INDUSTRIA,
    COUNT(t.TRANSACCION_ID) AS TRANSACCIONES_TOTALES,
    SUM(t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100)) AS VALOR_TOTAL_CLIENTE,
    AVG(t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100)) AS VALOR_PROMEDIO_TRANSACCION,
    COUNT(DISTINCT t.PRODUCTO_ID) AS PRODUCTOS_DISTINTOS_COMPRADOS
FROM CLIENTES c
LEFT JOIN TRANSACCIONES t ON c.CLIENTE_ID = t.CLIENTE_ID AND t.ESTADO_PEDIDO = 'COMPLETADO'
GROUP BY c.CLIENTE_ID, c.NOMBRE, c.SEGMENTO, c.REGION_GEOGRAFICA, c.INDUSTRIA
ORDER BY VALOR_TOTAL_CLIENTE DESC;

-- =====================================================
-- COMENTARIOS Y METADATOS PARA CORTEX ANALYST
-- =====================================================

-- Agregar comentarios a las tablas para el modelo semántico
COMMENT ON TABLE PRODUCTOS IS 'Catálogo de productos y servicios de TechFlow Solutions con información de precios, especificaciones y estado';
COMMENT ON TABLE CLIENTES IS 'Base de datos de clientes con información demográfica, segmentación y valor estimado';
COMMENT ON TABLE TRANSACCIONES IS 'Registro completo de todas las transacciones de venta con detalles de productos, clientes y términos comerciales';
COMMENT ON TABLE CAMPANAS_MARKETING IS 'Campañas de marketing con métricas de rendimiento, presupuestos y ROI';
COMMENT ON TABLE TICKETS_SOPORTE IS 'Sistema de tickets de soporte al cliente con análisis de sentimiento y métricas de satisfacción';

-- Comentarios en columnas clave para el modelo semántico
COMMENT ON COLUMN PRODUCTOS.CATEGORIA IS 'Categoría principal del producto: Software, Servicios, Seguridad, IA/ML, Herramientas';
COMMENT ON COLUMN CLIENTES.SEGMENTO IS 'Segmentación de clientes: Enterprise, Mid-Market, SMB, Education, Government';
COMMENT ON COLUMN TRANSACCIONES.CANAL_VENTA IS 'Canal de distribución: Venta Directa, Partner, Online';
COMMENT ON COLUMN TICKETS_SOPORTE.SENTIMIENTO IS 'Análisis de sentimiento del ticket: POSITIVO, NEGATIVO, NEUTRO';

-- =====================================================
-- DATOS HISTÓRICOS ADICIONALES PARA ML Y FORECASTING
-- =====================================================

-- Insertar datos históricos adicionales para modelos predictivos
INSERT INTO TRANSACCIONES VALUES
-- Datos de 2023 para tendencias históricas
('TXN023-2023-001', '2023-01-15 10:30:00', 'PROD001', 'CLI001', 1, 2399.00, 'Venta Directa', 'Norte América', 'Transferencia', 'COMPLETADO', 5.00, 'VEND001'),
('TXN023-2023-002', '2023-02-22 14:45:00', 'PROD002', 'CLI002', 2, 1799.00, 'Partner', 'Europa', 'Tarjeta Crédito', 'COMPLETADO', 8.00, 'VEND002'),
('TXN023-2023-003', '2023-03-10 09:15:00', 'PROD003', 'CLI003', 3, 899.00, 'Online', 'Norte América', 'Transferencia', 'COMPLETADO', 12.00, 'VEND003'),
('TXN023-2023-004', '2023-04-05 16:20:00', 'PROD001', 'CLI004', 1, 2399.00, 'Venta Directa', 'Asia-Pacífico', 'Transferencia', 'COMPLETADO', 0.00, 'VEND004'),
('TXN023-2023-005', '2023-05-18 11:00:00', 'PROD002', 'CLI005', 1, 1799.00, 'Partner', 'Europa', 'PayPal', 'COMPLETADO', 5.00, 'VEND002'),
('TXN023-2023-006', '2023-06-25 13:30:00', 'PROD003', 'CLI001', 4, 899.00, 'Online', 'Norte América', 'Tarjeta Crédito', 'COMPLETADO', 15.00, 'VEND001'),
('TXN023-2023-007', '2023-07-12 08:45:00', 'PROD001', 'CLI006', 2, 2399.00, 'Venta Directa', 'Norte América', 'Transferencia', 'COMPLETADO', 10.00, 'VEND005'),
('TXN023-2023-008', '2023-08-20 15:10:00', 'PROD002', 'CLI007', 1, 1799.00, 'Online', 'Norte América', 'Transferencia', 'COMPLETADO', 0.00, 'VEND003'),
('TXN023-2023-009', '2023-09-15 12:00:00', 'PROD003', 'CLI008', 2, 899.00, 'Venta Directa', 'Norte América', 'Transferencia', 'COMPLETADO', 8.00, 'VEND001'),
('TXN023-2023-010', '2023-10-08 10:20:00', 'PROD001', 'CLI009', 1, 2399.00, 'Partner', 'Europa', 'Transferencia', 'COMPLETADO', 5.00, 'VEND002'),
('TXN023-2023-011', '2023-11-22 14:35:00', 'PROD002', 'CLI010', 3, 1799.00, 'Venta Directa', 'Asia-Pacífico', 'Transferencia', 'COMPLETADO', 12.00, 'VEND004'),
('TXN023-2023-012', '2023-12-18 09:50:00', 'PROD003', 'CLI002', 2, 899.00, 'Online', 'Europa', 'PayPal', 'COMPLETADO', 10.00, 'VEND002');

-- =====================================================
-- CONSULTAS DE VALIDACIÓN
-- =====================================================

-- Verificar datos insertados
SELECT 'PRODUCTOS' AS TABLA, COUNT(*) AS REGISTROS FROM PRODUCTOS
UNION ALL
SELECT 'CLIENTES' AS TABLA, COUNT(*) AS REGISTROS FROM CLIENTES  
UNION ALL
SELECT 'TRANSACCIONES' AS TABLA, COUNT(*) AS REGISTROS FROM TRANSACCIONES
UNION ALL
SELECT 'CAMPANAS_MARKETING' AS TABLA, COUNT(*) AS REGISTROS FROM CAMPANAS_MARKETING
UNION ALL
SELECT 'TICKETS_SOPORTE' AS TABLA, COUNT(*) AS REGISTROS FROM TICKETS_SOPORTE;

-- =====================================================
-- FIN DEL SCHEMA TECHFLOW SOLUTIONS
-- =====================================================





