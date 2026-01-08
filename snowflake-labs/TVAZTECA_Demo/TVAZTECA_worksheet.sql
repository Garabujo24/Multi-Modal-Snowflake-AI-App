-- =====================================================================
-- TV AZTECA DIGITAL - CORTEX SEARCH DEMO
-- =====================================================================
-- Cliente: TV Azteca Digital
-- Tipo de Demo: Búsqueda Semántica con Cortex Search
-- Rol: Analista de Medios Digitales
-- Fecha: Septiembre 2025
-- =====================================================================

-- Section 0: Story and Use Case
-- =====================================================================
/*
HISTORIA Y CASO DE USO: TV AZTECA DIGITAL - INTELIGENCIA DE CONTENIDO

TV Azteca, la segunda televisora más importante de México, se enfrenta al desafío 
de gestionar y extraer insights de una vasta cantidad de documentos corporativos 
que incluyen manuales operativos, informes financieros, estrategias de marketing, 
análisis de audiencia y documentación técnica.

Como Analista de Medios Digitales, necesito poder realizar búsquedas inteligentes 
y semánticas sobre esta información para:

1. ANÁLISIS ESTRATÉGICO: Encontrar rápidamente información sobre estrategias de 
   expansión, competencia y oportunidades de mercado.

2. INSIGHTS DE AUDIENCIA: Descubrir patrones en el comportamiento de audiencia, 
   preferencias de contenido y métricas de engagement.

3. OPTIMIZACIÓN OPERATIVA: Acceder a mejores prácticas, procedimientos y 
   lineamientos para mejorar la eficiencia operacional.

4. COMPLIANCE Y REGULACIÓN: Localizar información sobre cumplimiento regulatorio, 
   políticas internas y aspectos legales.

5. INNOVACIÓN Y TENDENCIAS: Identificar oportunidades de innovación tecnológica 
   y tendencias del mercado de medios.

El valor de negocio incluye:
- Reducción del 70% en tiempo de búsqueda de información
- Mejora en la toma de decisiones basada en datos
- Identificación proactiva de oportunidades y riesgos
- Democratización del conocimiento organizacional
- Aceleración en respuesta a cambios del mercado

Este demo utiliza Cortex Search para crear una experiencia de búsqueda inteligente 
que comprende el contexto y la semántica de las consultas, proporcionando respuestas 
relevantes y precisas sobre el universo de información de TV Azteca.
*/

-- Section 1: Resource Setup
-- =====================================================================

-- Configuración inicial del entorno
USE ROLE SYSADMIN;

-- Crear almacén de datos dedicado
CREATE OR REPLACE WAREHOUSE TVAZTECA_WH 
WITH 
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse para demo TV Azteca Digital Cortex Search';

-- Crear base de datos principal
CREATE OR REPLACE DATABASE TVAZTECA_DB 
    COMMENT = 'Base de datos para demo TV Azteca Digital';

-- Crear esquemas organizacionales
CREATE OR REPLACE SCHEMA TVAZTECA_DB.RAW_SCHEMA 
    COMMENT = 'Esquema para datos en bruto de documentos TV Azteca';

CREATE OR REPLACE SCHEMA TVAZTECA_DB.ANALYTICS_SCHEMA 
    COMMENT = 'Esquema para análisis y métricas de contenido';

CREATE OR REPLACE SCHEMA TVAZTECA_DB.SEARCH_SCHEMA 
    COMMENT = 'Esquema para servicios de búsqueda y Cortex Search';

-- Configurar contexto de trabajo
USE WAREHOUSE TVAZTECA_WH;
USE DATABASE TVAZTECA_DB;
USE SCHEMA RAW_SCHEMA;

-- Crear rol específico para el demo
CREATE OR REPLACE ROLE TVAZTECA_ANALYST_ROLE 
    COMMENT = 'Rol para analistas de medios digitales TV Azteca';

-- Otorgar permisos necesarios
GRANT USAGE ON WAREHOUSE TVAZTECA_WH TO ROLE TVAZTECA_ANALYST_ROLE;
GRANT USAGE ON DATABASE TVAZTECA_DB TO ROLE TVAZTECA_ANALYST_ROLE;
GRANT USAGE ON SCHEMA TVAZTECA_DB.RAW_SCHEMA TO ROLE TVAZTECA_ANALYST_ROLE;
GRANT USAGE ON SCHEMA TVAZTECA_DB.ANALYTICS_SCHEMA TO ROLE TVAZTECA_ANALYST_ROLE;
GRANT USAGE ON SCHEMA TVAZTECA_DB.SEARCH_SCHEMA TO ROLE TVAZTECA_ANALYST_ROLE;

-- Crear stage para carga de documentos
CREATE OR REPLACE STAGE TVAZTECA_DB.RAW_SCHEMA.DOCUMENTS_STAGE
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage para almacenar documentos PDF de TV Azteca';

-- Crear tabla principal para documentos
CREATE OR REPLACE TABLE TVAZTECA_DB.RAW_SCHEMA.CORPORATE_DOCUMENTS (
    DOCUMENT_ID NUMBER AUTOINCREMENT,
    DOCUMENT_NAME VARCHAR(255) NOT NULL,
    DOCUMENT_TYPE VARCHAR(100) NOT NULL,
    DEPARTMENT VARCHAR(100) NOT NULL,
    UPLOAD_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FILE_SIZE_BYTES NUMBER,
    CONTENT_TEXT TEXT,
    DOCUMENT_SUMMARY TEXT,
    KEYWORDS ARRAY,
    PRIORITY_LEVEL VARCHAR(20) DEFAULT 'MEDIUM',
    IS_CONFIDENTIAL BOOLEAN DEFAULT FALSE,
    LAST_UPDATED TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    METADATA VARIANT,
    PRIMARY KEY (DOCUMENT_ID)
) COMMENT = 'Tabla principal para almacenar documentos corporativos de TV Azteca';

-- Crear tabla de categorías de documentos
CREATE OR REPLACE TABLE TVAZTECA_DB.RAW_SCHEMA.DOCUMENT_CATEGORIES (
    CATEGORY_ID NUMBER AUTOINCREMENT,
    CATEGORY_NAME VARCHAR(100) NOT NULL,
    DESCRIPTION TEXT,
    DEPARTMENT VARCHAR(100),
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (CATEGORY_ID)
) COMMENT = 'Catálogo de categorías para clasificación de documentos';

-- Crear tabla de métricas de búsqueda
CREATE OR REPLACE TABLE TVAZTECA_DB.ANALYTICS_SCHEMA.SEARCH_METRICS (
    SEARCH_ID NUMBER AUTOINCREMENT,
    SEARCH_QUERY TEXT NOT NULL,
    SEARCH_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    USER_ROLE VARCHAR(100),
    RESULTS_COUNT NUMBER,
    RESPONSE_TIME_MS NUMBER,
    RELEVANCE_SCORE FLOAT,
    CLICKED_DOCUMENT_ID NUMBER,
    SESSION_ID VARCHAR(255),
    PRIMARY KEY (SEARCH_ID)
) COMMENT = 'Métricas de uso y performance del sistema de búsqueda';

-- Configurar el formato de archivo
CREATE OR REPLACE FILE FORMAT TVAZTECA_DB.RAW_SCHEMA.TEXT_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = '|'
    RECORD_DELIMITER = '\n'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE_CHARACTER = '\\'
    COMMENT = 'Formato para archivos de texto plano';

-- Section 2: Synthetic Data Generation
-- =====================================================================

-- Insertar categorías de documentos
INSERT INTO TVAZTECA_DB.RAW_SCHEMA.DOCUMENT_CATEGORIES 
(CATEGORY_NAME, DESCRIPTION, DEPARTMENT) VALUES
('Manual Operativo', 'Documentos de procedimientos y operaciones', 'Operaciones'),
('Informe Financiero', 'Reportes financieros y análisis económicos', 'Finanzas'),
('Estrategia Marketing', 'Planes y estrategias de marketing digital', 'Marketing'),
('Análisis Audiencia', 'Estudios de audiencia y rating', 'Investigación'),
('Recursos Humanos', 'Políticas y procedimientos de RH', 'Recursos Humanos'),
('Tecnología', 'Documentación técnica y sistemas', 'Tecnología'),
('Compliance', 'Documentos regulatorios y cumplimiento', 'Legal'),
('Sustentabilidad', 'Reportes ambientales y responsabilidad social', 'Sustentabilidad'),
('Innovación', 'Proyectos de I+D y nuevas tecnologías', 'Innovación'),
('Contenido', 'Producción y programación de contenidos', 'Contenido');

-- Generar datos sintéticos para documentos corporativos
INSERT INTO TVAZTECA_DB.RAW_SCHEMA.CORPORATE_DOCUMENTS 
(DOCUMENT_NAME, DOCUMENT_TYPE, DEPARTMENT, FILE_SIZE_BYTES, CONTENT_TEXT, DOCUMENT_SUMMARY, KEYWORDS, PRIORITY_LEVEL, IS_CONFIDENTIAL, METADATA)
VALUES
('manual_programacion_azteca_uno.txt', 'Manual Operativo', 'Programación', 45678, 
 'MANUAL DE PROGRAMACIÓN AZTECA UNO. TV Azteca - División Digital. Azteca UNO es el canal principal de TV Azteca, transmitiendo las 24 horas del día con una programación variada que incluye entretenimiento, noticias, deportes y contenido original. PROGRAMACIÓN MATUTINA: 6:00 AM - 7:00 AM: Hechos AM Primera Línea. PROGRAMACIÓN VESPERTINA: 1:00 PM - 2:00 PM: Ventaneando. PROGRAMACIÓN ESTELAR: 7:30 PM - 8:30 PM: Entre Correr y Vivir.',
 'Manual de programación del canal principal Azteca UNO con horarios, shows y lineamientos de transmisión 24/7.',
 ['programación', 'azteca uno', 'televisión', 'horarios', 'entretenimiento', 'noticias'],
 'HIGH', FALSE,
 '{"document_version": "2025.1", "language": "spanish", "pages": 12, "classification": "internal"}'),

('guia_azteca_7_deportes.txt', 'Guía Especializada', 'Deportes', 38492,
 'GUÍA DE PROGRAMACIÓN AZTECA 7 - DEPORTES. TV Azteca - Canal Deportivo. Azteca 7 es el canal deportivo líder en México, dedicado a transmitir los mejores eventos deportivos nacionales e internacionales. FÚTBOL MEXICANO - LIGA MX: Transmisiones exclusivas de partidos de Liga MX cada fin de semana. BOX AZTECA: Transmisiones en vivo de peleas de Canelo Álvarez y box internacional. ESPORTS: Programación dedicada a deportes electrónicos.',
 'Guía completa de programación deportiva de Azteca 7 incluyendo fútbol, box y esports.',
 ['deportes', 'azteca 7', 'fútbol', 'box', 'liga mx', 'esports'],
 'HIGH', FALSE,
 '{"document_version": "2025.2", "language": "spanish", "pages": 8, "classification": "internal"}'),

('manual_hechos_noticias.txt', 'Manual Editorial', 'Noticias', 52341,
 'MANUAL DE PRODUCCIÓN HECHOS - NOTICIAS TV AZTECA. División de Noticias TV Azteca. "Hechos" es el noticiero líder de TV Azteca, comprometido con informar la verdad de manera objetiva. PRINCIPIOS FUNDAMENTALES: Veracidad, Objetividad, Oportunidad, Responsabilidad Social. FORMATOS DE NOTICIEROS: HECHOS AM PRIMERA LÍNEA, HECHOS CON JAVIER ALATORRE con rating promedio de 11.4 puntos.',
 'Manual de producción editorial para los noticieros Hechos con principios periodísticos y formatos.',
 ['noticias', 'hechos', 'periodismo', 'javier alatorre', 'editorial', 'objetividad'],
 'CRITICAL', TRUE,
 '{"document_version": "2025.1", "language": "spanish", "pages": 15, "classification": "confidential"}'),

('guia_ventaneando_espectaculos.txt', 'Guía Editorial', 'Entretenimiento', 41267,
 'GUÍA DE PRODUCCIÓN VENTANEANDO - ESPECTÁCULOS. TV Azteca - Programa Líder de Espectáculos. Ventaneando inició transmisiones el 19 de enero de 1996, convirtiéndose en el programa de espectáculos más longevo y exitoso. Bajo la conducción de Pati Chapoy, ha mantenido el liderazgo en rating durante más de 29 años. EQUIPO CONDUCTORES: Patricia "Pati" Chapoy, Pedro Sola, Daniel Bisogno.',
 'Guía de producción del programa líder de espectáculos Ventaneando con 29 años al aire.',
 ['entretenimiento', 'ventaneando', 'pati chapoy', 'espectáculos', 'rating', 'celebridades'],
 'HIGH', FALSE,
 '{"document_version": "2025.1", "language": "spanish", "pages": 10, "classification": "internal"}'),

('manual_venga_alegria_matutino.txt', 'Manual Producción', 'Entretenimiento', 47823,
 'MANUAL DE PRODUCCIÓN VENGA LA ALEGRÍA. TV Azteca - Programa Matutino de Entretenimiento. "Venga la Alegría" es el programa matutino líder de entretenimiento en México, transmitido de lunes a viernes de 9:00 AM a 1:00 PM. EQUIPO DE CONDUCCIÓN: Kristal Silva, Roger González, Sergio Sepúlveda, Anette Cuburu. SEGMENTOS ESPECIALES: VLA COCINA, VLA FIT, VLA SALUD, VLA MÚSICA.',
 'Manual de producción del programa matutino líder Venga la Alegría con 4 horas de entretenimiento diario.',
 ['matutino', 'venga la alegría', 'entretenimiento', 'vla', 'cocina', 'fitness'],
 'MEDIUM', FALSE,
 '{"document_version": "2025.1", "language": "spanish", "pages": 11, "classification": "internal"}'),

('guia_adn40_noticias_digitales.txt', 'Guía Digital', 'Noticias Digital', 43567,
 'GUÍA ADN40 - NOTICIAS DIGITALES 24/7. TV Azteca - Canal de Noticias Continuas. ADN40 es el canal de noticias 24/7 de TV Azteca, comprometido con informar de manera continua. PROGRAMACIÓN 24/7: Despertar Informativo, Despierta con Loret, Noticias ADN40 Matutino. TECNOLOGÍA DE PRODUCCIÓN: Realidad aumentada para gráficos informativos, Edge computing, transmisión 4K.',
 'Guía del canal de noticias continuas ADN40 con programación 24/7 y tecnología avanzada.',
 ['noticias', 'adn40', '24/7', 'digital', 'streaming', 'tecnología'],
 'HIGH', FALSE,
 '{"document_version": "2025.1", "language": "spanish", "pages": 9, "classification": "internal"}'),

('manual_novelas_produccion_original.txt', 'Manual Producción', 'Contenido', 56234,
 'MANUAL DE PRODUCCIÓN DE NOVELAS TV AZTECA. División de Telenovelas - TV Azteca. TV Azteca se caracteriza por producir telenovelas con historias frescas y contemporáneas. NOVELAS EN EMISIÓN 2025: "Las Bravo" - Horario Estelar 8:30 PM, "La Mujer de Judas" - Horario Nocturno 9:30 PM. EQUIPO CREATIVO: Carmen Armendáriz, Ignacio Sada, Rosy Ocampo, Pedro Damián.',
 'Manual de producción de telenovelas originales de TV Azteca con elencos y procesos creativos.',
 ['telenovelas', 'producción', 'drama', 'las bravo', 'contenido original', 'estelar'],
 'MEDIUM', FALSE,
 '{"document_version": "2025.1", "language": "spanish", "pages": 14, "classification": "internal"}'),

('informe_audiencias_rating_2025.txt', 'Informe Analítico', 'Investigación', 62187,
 'INFORME DE AUDIENCIAS Y RATING TV AZTECA 2025. Departamento de Investigación de Audiencias. TV Azteca mantiene su posición como la segunda televisora más vista de México, con un share promedio del 28.5% y un rating consolidado de 8.2 puntos. MÉTRICAS PRINCIPALES: Azteca UNO: 9.8 puntos, Azteca 7: 6.4 puntos. HORARIO ESTELAR: "Las Bravo" 12.3 puntos, "Hechos con Javier Alatorre" 11.4 puntos.',
 'Informe trimestral de audiencias y rating con métricas de performance de todos los canales.',
 ['audiencia', 'rating', 'share', 'métricas', 'nielsen', 'investigación'],
 'CRITICAL', TRUE,
 '{"document_version": "Q1-2025", "language": "spanish", "pages": 18, "classification": "confidential"}'),

('manual_tecnologia_transmision.txt', 'Manual Técnico', 'Tecnología', 71456,
 'MANUAL DE TECNOLOGÍA Y TRANSMISIÓN TV AZTECA. Dirección de Ingeniería y Tecnología. INFRAESTRUCTURA DE TRANSMISIÓN: Centro principal en Ajusco con torre de 250 metros. RED NACIONAL: 340 estaciones repetidoras en todo México con cobertura del 94.8%. TECNOLOGÍA: ATSC 3.0 Next Gen TV, transmisión 4K, audio Dolby Digital 5.1.',
 'Manual técnico de infraestructura de transmisión con 340 repetidoras nacionales y tecnología 4K.',
 ['tecnología', 'transmisión', 'ajusco', 'atsc', '4k', 'repetidoras'],
 'CRITICAL', TRUE,
 '{"document_version": "2025.1", "language": "spanish", "pages": 20, "classification": "technical"}'),

('plan_marketing_digital_2025.txt', 'Plan Estratégico', 'Marketing Digital', 58923,
 'PLAN DE MARKETING DIGITAL TV AZTECA 2025. Dirección de Marketing Digital y Redes Sociales. OBJETIVOS ESTRATÉGICOS 2025: Incrementar followers en redes sociales +25%, aumentar engagement rate +30%. ESTRATEGIA POR PLATAFORMA: Facebook 25M seguidores, Instagram 18M, TikTok 15M, YouTube 12M. PRESUPUESTO 2025: $12M USD con ROI esperado de 4.8x.',
 'Plan estratégico de marketing digital con objetivos 2025 y estrategias por plataforma social.',
 ['marketing digital', 'redes sociales', 'facebook', 'instagram', 'tiktok', 'estrategia'],
 'HIGH', TRUE,
 '{"document_version": "2025.1", "language": "spanish", "pages": 16, "classification": "strategic"}'),

('informe_redes_sociales_engagement.txt', 'Informe Mensual', 'Marketing Digital', 67345,
 'INFORME DE REDES SOCIALES Y ENGAGEMENT TV AZTECA. TV Azteca mantiene una presencia dominante en redes sociales con 72 millones de seguidores totales. MÉTRICAS GLOBALES: Facebook 23.8M seguidores, Instagram 14.2M, TikTok 8.1M. ENGAGEMENT TOTAL MENSUAL: 63M interacciones (+17% vs febrero). CONTENIDO VIRAL: #VentaneandoChallenge 89M views.',
 'Informe mensual de performance en redes sociales con 72M seguidores totales y métricas de engagement.',
 ['redes sociales', 'engagement', 'viral', 'followers', 'métricas', 'social media'],
 'MEDIUM', FALSE,
 '{"document_version": "Marzo-2025", "language": "spanish", "pages": 12, "classification": "internal"}'),

('manual_recursos_humanos_talento.txt', 'Manual RH', 'Recursos Humanos', 54678,
 'MANUAL DE RECURSOS HUMANOS Y GESTIÓN DEL TALENTO. TV Azteca - Dirección de Capital Humano. EMPLEADOS TOTALES: 4,850 personas distribuidas en personal administrativo (25%), producción (40%), técnico (18%). PROGRAMA DE CAPACITACIÓN: Academia TV Azteca con 150 cursos disponibles. BENEFICIOS: Seguro médico, fondo de ahorro, becas educativas.',
 'Manual de recursos humanos con políticas para 4,850 empleados y programas de desarrollo.',
 ['recursos humanos', 'talento', 'capacitación', 'beneficios', 'empleados', 'academia'],
 'MEDIUM', TRUE,
 '{"document_version": "2025.1", "language": "spanish", "pages": 17, "classification": "hr-confidential"}'),

('informe_financiero_ingresos_2025.txt', 'Informe Financiero', 'Finanzas', 78934,
 'INFORME FINANCIERO Y INGRESOS TV AZTECA 2025. Dirección de Finanzas Corporativas. INGRESOS TOTALES Q1 2025: $3,847 millones de pesos (+8.7% vs Q1 2024). EBITDA: $1,156 millones (30.1% margen). TELEVISIÓN ABIERTA: $2,890 millones (75.1% de ingresos). DIGITAL Y STREAMING: $289 millones (+34.2% crecimiento).',
 'Informe financiero trimestral con ingresos de $3,847M y crecimiento digital del 34.2%.',
 ['finanzas', 'ingresos', 'ebitda', 'digital', 'streaming', 'crecimiento'],
 'CRITICAL', TRUE,
 '{"document_version": "Q1-2025", "language": "spanish", "pages": 22, "classification": "financial-confidential"}'),

('plan_sustentabilidad_ambiental.txt', 'Plan Sustentabilidad', 'Sustentabilidad', 49876,
 'PLAN DE SUSTENTABILIDAD AMBIENTAL TV AZTECA. Dirección de Sustentabilidad Corporativa. COMPROMISO AMBIENTAL: Carbono neutralidad para 2030. METAS AMBIENTALES: 80% energías renovables, 90% reducción residuos. HUELLA DE CARBONO ACTUAL: 45,678 toneladas CO2e (-12.5% vs 2023). PROYECTO SOLAR AJUSCO: 5.2 MW de capacidad instalada.',
 'Plan de sustentabilidad ambiental con meta de carbono neutralidad 2030 y proyectos de energía renovable.',
 ['sustentabilidad', 'carbono neutral', 'energía renovable', 'medio ambiente', 'solar'],
 'MEDIUM', FALSE,
 '{"document_version": "2025-2030", "language": "spanish", "pages": 15, "classification": "sustainability"}'),

('manual_seguridad_informacion.txt', 'Manual Seguridad', 'Tecnología', 65432,
 'MANUAL DE SEGURIDAD DE LA INFORMACIÓN TV AZTECA. Dirección de Tecnología y Ciberseguridad. CENTRO DE OPERACIONES DE SEGURIDAD (SOC): Operación 24/7/365. ARQUITECTURA DE SEGURIDAD: Defensa en profundidad con 5 capas. MÉTRICAS: 2.3M eventos diarios, 8 minutos tiempo de detección, 15 minutos tiempo de respuesta.',
 'Manual de ciberseguridad con SOC 24/7 y arquitectura de defensa en profundidad.',
 ['ciberseguridad', 'soc', 'información', 'defensa', 'monitoreo', '24/7'],
 'CRITICAL', TRUE,
 '{"document_version": "2025.1", "language": "spanish", "pages": 19, "classification": "security-restricted"}'),

('estrategia_expansion_internacional.txt', 'Estrategia Internacional', 'Negocios Internacionales', 72189,
 'ESTRATEGIA DE EXPANSIÓN INTERNACIONAL TV AZTECA. Dirección de Negocios Internacionales. OBJETIVOS ESTRATÉGICOS 2030: Presencia en 45 países, $500M USD ingresos internacionales. MERCADOS PRIORITARIOS: Estados Unidos (62.1M audiencia hispana), España, Colombia. INGRESOS INTERNACIONALES 2024: $435M USD (+18.5% crecimiento).',
 'Estrategia de expansión internacional con meta de $500M USD y presencia en 45 países.',
 ['internacional', 'expansión', 'estados unidos', 'colombia', 'ingresos', 'mercados'],
 'CRITICAL', TRUE,
 '{"document_version": "2025-2030", "language": "spanish", "pages": 21, "classification": "strategic-confidential"}'),

('manual_innovacion_investigacion.txt', 'Manual I+D', 'Innovación', 68754,
 'MANUAL DE INNOVACIÓN E INVESTIGACIÓN TV AZTECA. Laboratorio de Innovación y Desarrollo Tecnológico. CENTRO DE INNOVACIÓN: 2,400 m² con 45 especialistas. ÁREAS DE INVESTIGACIÓN: Inteligencia Artificial, Realidad Virtual, Blockchain, 5G. PROYECTOS DESTACADOS: AZTECA VISION AI, Predictive Analytics Engine, VR Productions.',
 'Manual de innovación y R&D con laboratorio de 2,400m² enfocado en IA, VR y blockchain.',
 ['innovación', 'investigación', 'inteligencia artificial', 'realidad virtual', 'blockchain'],
 'HIGH', TRUE,
 '{"document_version": "2025.1", "language": "spanish", "pages": 18, "classification": "innovation-confidential"}'),

('informe_responsabilidad_social.txt', 'Informe RSE', 'Responsabilidad Social', 59876,
 'INFORME DE RESPONSABILIDAD SOCIAL CORPORATIVA. TV Azteca - Fundación TV Azteca. INVERSIÓN SOCIAL 2025: $189 millones de pesos. BENEFICIARIOS DIRECTOS: 2.3 millones de personas en 1,450 comunidades. PROGRAMAS: Educación (42%), Salud (27%), Desarrollo económico (18%). RECONOCIMIENTOS: Distintivo ESR 13° año consecutivo.',
 'Informe de responsabilidad social con inversión de $189M y 2.3M beneficiarios directos.',
 ['responsabilidad social', 'fundación', 'educación', 'salud', 'comunidades', 'esr'],
 'MEDIUM', FALSE,
 '{"document_version": "2025.1", "language": "spanish", "pages": 16, "classification": "public"}'),

('manual_crisis_comunicacion.txt', 'Manual Crisis', 'Comunicación Corporativa', 54321,
 'MANUAL DE GESTIÓN DE CRISIS Y COMUNICACIÓN. TV Azteca - Dirección de Comunicación Corporativa. NIVELES DE ESCALAMIENTO: 4 niveles de crisis con tiempos de respuesta de 5-30 minutos. EQUIPO DE MANEJO: Crisis Management Team liderado por CEO. PROTOCOLO DE ACTIVACIÓN: Detección, análisis, implementación en 3 fases.',
 'Manual de gestión de crisis con 4 niveles de escalamiento y protocolo de respuesta rápida.',
 ['crisis', 'comunicación', 'protocolo', 'manejo', 'escalamiento', 'respuesta'],
 'CRITICAL', TRUE,
 '{"document_version": "2025.1", "language": "spanish", "pages": 13, "classification": "crisis-management"}'),

('manual_cumplimiento_regulatorio.txt', 'Manual Compliance', 'Legal', 61245,
 'MANUAL DE CUMPLIMIENTO REGULATORIO TV AZTECA. Dirección de Asuntos Regulatorios y Compliance. AUTORIDADES REGULADORAS: IFT, SEGOB, COFECE, SHCP. CONCESIONES VIGENTES: 92 Azteca UNO, 91 Azteca 7. SISTEMA DE GESTIÓN: Chief Compliance Officer con reporte directo al CEO. MÉTRICAS: Zero violaciones regulatorias críticas.',
 'Manual de cumplimiento regulatorio con 183 concesiones vigentes y sistema de gestión integral.',
 ['compliance', 'regulatorio', 'ift', 'concesiones', 'legal', 'cumplimiento'],
 'CRITICAL', TRUE,
 '{"document_version": "2025.1", "language": "spanish", "pages": 20, "classification": "legal-confidential"}');

-- Generar métricas sintéticas de búsqueda
INSERT INTO TVAZTECA_DB.ANALYTICS_SCHEMA.SEARCH_METRICS 
(SEARCH_QUERY, USER_ROLE, RESULTS_COUNT, RESPONSE_TIME_MS, RELEVANCE_SCORE, SESSION_ID)
SELECT 
    search_queries.query,
    roles.role_name,
    UNIFORM(1, 25, RANDOM()),
    UNIFORM(50, 2000, RANDOM()),
    UNIFORM(0.6, 1.0, RANDOM())::FLOAT,
    'session_' || SEQ8()
FROM (
    SELECT * FROM VALUES 
    ('¿Cuál es el rating de Ventaneando?'),
    ('Estrategia de marketing digital para redes sociales'),
    ('Información sobre programación de Azteca UNO'),
    ('Políticas de recursos humanos y beneficios'),
    ('Métricas de audiencia del horario estelar'),
    ('Procedimientos de seguridad de la información'),
    ('Planes de expansión internacional'),
    ('Tecnología de transmisión 4K'),
    ('Presupuesto de marketing digital 2025'),
    ('Proyectos de sustentabilidad ambiental')
) AS search_queries(query)
CROSS JOIN (
    SELECT * FROM VALUES 
    ('Analista de Medios'),
    ('Director de Programación'),
    ('Gerente de Marketing'),
    ('Especialista en Tecnología'),
    ('Coordinador de RH')
) AS roles(role_name);

-- Section 3: The Demo
-- =====================================================================

-- Configurar contexto para el demo
USE SCHEMA TVAZTECA_DB.SEARCH_SCHEMA;

-- Crear servicio de Cortex Search
CREATE OR REPLACE CORTEX SEARCH SERVICE tv_azteca_search
ON CONTENT_TEXT
ATTRIBUTES DOCUMENT_NAME, DOCUMENT_TYPE, DEPARTMENT, KEYWORDS, PRIORITY_LEVEL
WAREHOUSE = TVAZTECA_WH
TARGET_LAG = '1 minute'
AS (
    SELECT 
        DOCUMENT_ID,
        CONTENT_TEXT,
        DOCUMENT_NAME,
        DOCUMENT_TYPE,
        DEPARTMENT,
        KEYWORDS,
        PRIORITY_LEVEL,
        DOCUMENT_SUMMARY
    FROM TVAZTECA_DB.RAW_SCHEMA.CORPORATE_DOCUMENTS
    WHERE CONTENT_TEXT IS NOT NULL
);

-- Esperar a que el servicio se complete
-- (En producción, verificar el estado con: SELECT SYSTEM$GET_SEARCH_SERVICE_STATUS('tv_azteca_search'))

-- Demo Query 1: Búsqueda de información sobre rating y audiencia
SELECT 
    'BÚSQUEDA: Información sobre rating y audiencia de programas' AS CONSULTA;

SELECT 
    SNOWFLAKE.CORTEX.SEARCH(
        'tv_azteca_search',
        'rating audiencia programas share puntos televisión métricas'
    ) AS RESULTADOS_RATING;

-- Demo Query 2: Estrategias de marketing digital y redes sociales  
SELECT 
    'BÚSQUEDA: Estrategias de marketing digital y redes sociales' AS CONSULTA;

SELECT 
    SNOWFLAKE.CORTEX.SEARCH(
        'tv_azteca_search', 
        'marketing digital redes sociales Facebook Instagram TikTok estrategia'
    ) AS RESULTADOS_MARKETING;

-- Demo Query 3: Información técnica sobre transmisión y tecnología
SELECT 
    'BÚSQUEDA: Tecnología de transmisión y infraestructura técnica' AS CONSULTA;
    
SELECT 
    SNOWFLAKE.CORTEX.SEARCH(
        'tv_azteca_search',
        'tecnología transmisión 4K infraestructura ATSC repetidoras Ajusco'
    ) AS RESULTADOS_TECNOLOGIA;

-- Demo Query 4: Programación y contenido de entretenimiento
SELECT 
    'BÚSQUEDA: Programación y contenido de entretenimiento' AS CONSULTA;

SELECT 
    SNOWFLAKE.CORTEX.SEARCH(
        'tv_azteca_search',
        'programación entretenimiento Ventaneando Venga la Alegría telenovelas'
    ) AS RESULTADOS_ENTRETENIMIENTO;

-- Demo Query 5: Información financiera y de negocios
SELECT 
    'BÚSQUEDA: Información financiera e ingresos' AS CONSULTA;

SELECT 
    SNOWFLAKE.CORTEX.SEARCH(
        'tv_azteca_search',
        'ingresos financiero EBITDA millones pesos crecimiento digital'
    ) AS RESULTADOS_FINANCIEROS;

-- Demo Query 6: Compliance y aspectos regulatorios
SELECT 
    'BÚSQUEDA: Cumplimiento regulatorio y concesiones' AS CONSULTA;

SELECT 
    SNOWFLAKE.CORTEX.SEARCH(
        'tv_azteca_search',
        'compliance regulatorio IFT concesiones legal cumplimiento'
    ) AS RESULTADOS_COMPLIANCE;

-- Demo Query 7: Innovación y desarrollo tecnológico
SELECT 
    'BÚSQUEDA: Proyectos de innovación y nuevas tecnologías' AS CONSULTA;

SELECT 
    SNOWFLAKE.CORTEX.SEARCH(
        'tv_azteca_search',
        'innovación inteligencia artificial blockchain realidad virtual I+D'
    ) AS RESULTADOS_INNOVACION;

-- Demo Query 8: Responsabilidad social y sustentabilidad
SELECT 
    'BÚSQUEDA: Responsabilidad social y sustentabilidad' AS CONSULTA;

SELECT 
    SNOWFLAKE.CORTEX.SEARCH(
        'tv_azteca_search',
        'responsabilidad social sustentabilidad ambiental carbono neutral'
    ) AS RESULTADOS_SUSTENTABILIDAD;

-- Análisis de performance del sistema de búsqueda
SELECT 
    'ANÁLISIS: Performance y métricas del sistema de búsqueda' AS REPORTE;

-- Métricas agregadas de búsqueda
SELECT 
    USER_ROLE,
    COUNT(*) as TOTAL_SEARCHES,
    AVG(RESPONSE_TIME_MS) as AVG_RESPONSE_TIME,
    AVG(RELEVANCE_SCORE) as AVG_RELEVANCE,
    AVG(RESULTS_COUNT) as AVG_RESULTS
FROM TVAZTECA_DB.ANALYTICS_SCHEMA.SEARCH_METRICS
GROUP BY USER_ROLE
ORDER BY TOTAL_SEARCHES DESC;

-- Top consultas por volumen
SELECT 
    SEARCH_QUERY,
    COUNT(*) as FREQUENCY,
    AVG(RELEVANCE_SCORE) as AVG_RELEVANCE
FROM TVAZTECA_DB.ANALYTICS_SCHEMA.SEARCH_METRICS
GROUP BY SEARCH_QUERY
ORDER BY FREQUENCY DESC
LIMIT 10;

-- Distribución de documentos por departamento
SELECT 
    DEPARTMENT,
    COUNT(*) as DOCUMENT_COUNT,
    AVG(FILE_SIZE_BYTES) as AVG_SIZE_BYTES,
    ARRAY_AGG(DISTINCT DOCUMENT_TYPE) as DOCUMENT_TYPES
FROM TVAZTECA_DB.RAW_SCHEMA.CORPORATE_DOCUMENTS
GROUP BY DEPARTMENT
ORDER BY DOCUMENT_COUNT DESC;

-- Documentos por nivel de prioridad
SELECT 
    PRIORITY_LEVEL,
    COUNT(*) as COUNT,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as PERCENTAGE
FROM TVAZTECA_DB.RAW_SCHEMA.CORPORATE_DOCUMENTS
GROUP BY PRIORITY_LEVEL
ORDER BY COUNT DESC;

-- Demo de búsqueda con filtros específicos
SELECT 
    'DEMO AVANZADO: Búsqueda con filtros por departamento y prioridad' AS TITULO;

-- Buscar solo en documentos críticos del departamento de Finanzas
SELECT 
    SNOWFLAKE.CORTEX.SEARCH(
        'tv_azteca_search',
        'ingresos EBITDA financiero',
        OPTIONS => {'filter': {'@and': [
            {'@eq': {'department': 'Finanzas'}},
            {'@eq': {'priority_level': 'CRITICAL'}}
        ]}}
    ) AS RESULTADOS_FINANZAS_CRITICOS;

-- Búsqueda en documentos de tecnología
SELECT 
    SNOWFLAKE.CORTEX.SEARCH(
        'tv_azteca_search',
        'tecnología transmisión infraestructura',
        OPTIONS => {'filter': {'@eq': {'department': 'Tecnología'}}}
    ) AS RESULTADOS_TECNOLOGIA_FILTRADO;

-- Resumen y conclusiones del demo
SELECT 
    '=== RESUMEN DEL DEMO TV AZTECA DIGITAL ===' AS TITULO,
    'Se ha implementado exitosamente un sistema de búsqueda semántica 
     con Cortex Search que permite a los analistas de TV Azteca encontrar 
     información relevante en su vasta biblioteca de documentos corporativos.
     
     El sistema procesa 20 documentos diferentes que cubren:
     - Programación y contenido
     - Análisis de audiencia y rating  
     - Estrategias de marketing digital
     - Información financiera
     - Aspectos técnicos y tecnológicos
     - Compliance y regulación
     - Innovación y desarrollo
     - Responsabilidad social
     
     Beneficios demostrados:
     ✓ Búsqueda semántica inteligente
     ✓ Filtrado por departamento y prioridad
     ✓ Respuestas contextualmente relevantes
     ✓ Reducción significativa en tiempo de búsqueda
     ✓ Democratización del conocimiento organizacional' AS RESUMEN;

-- Limpiar recursos (opcional - comentado para preservar el demo)
-- DROP CORTEX SEARCH SERVICE IF EXISTS tv_azteca_search;
-- DROP DATABASE IF EXISTS TVAZTECA_DB;
-- DROP WAREHOUSE IF EXISTS TVAZTECA_WH;
-- DROP ROLE IF EXISTS TVAZTECA_ANALYST_ROLE;
