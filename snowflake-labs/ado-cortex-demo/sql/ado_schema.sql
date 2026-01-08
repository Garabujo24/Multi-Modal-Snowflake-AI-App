-- Script para crear las tablas principales de ADO

-- Tabla: Rutas
CREATE TABLE Rutas (
    ID INT PRIMARY KEY,
    Origen VARCHAR(50),
    Destino VARCHAR(50),
    Distancia_KM DECIMAL(5,1),
    Duracion_Estimada_Horas DECIMAL(4,2)
);

-- Tabla: Autobuses
CREATE TABLE Autobuses (
    ID INT PRIMARY KEY,
    Numero_Economico VARCHAR(10),
    Capacidad_Asientos INT,
    Tipo_Servicio VARCHAR(20)
);

-- Tabla: Terminales
CREATE TABLE Terminales (
    ID INT PRIMARY KEY,
    Nombre VARCHAR(50),
    Ciudad VARCHAR(50),
    Estado VARCHAR(30)
);

-- Tabla: Corridas
CREATE TABLE Corridas (
    ID INT PRIMARY KEY,
    Ruta_ID INT REFERENCES Rutas(ID),
    Autobus_ID INT REFERENCES Autobuses(ID),
    Fecha_Hora_Salida TIMESTAMP,
    Fecha_Hora_Llegada TIMESTAMP,
    Precio_Boleto DECIMAL(7,2)
);

-- Tabla: Boletos
CREATE TABLE Boletos (
    ID INT PRIMARY KEY,
    Corrida_ID INT REFERENCES Corridas(ID),
    Pasajero_Nombre VARCHAR(60),
    Asiento INT,
    Fecha_Compra TIMESTAMP,
    Estatus VARCHAR(15)
);

-- Tabla: Registros_Busqueda
CREATE TABLE Registros_Busqueda (
    ID INT PRIMARY KEY AUTOINCREMENT,
    Pregunta_Usuario VARCHAR(500),
    Respuesta_Generada VARCHAR(2000),
    Documento_Fuente VARCHAR(100),
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


