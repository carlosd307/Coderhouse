--------------------------------------------------------
-- PRE-ENTREGA
-- Retail Project
-- Alumno: Carlos Contreras
--------------------------------------------------------

--------------------------------------------------------
-- Crear Base de Datos
--------------------------------------------------------

CREATE DATABASE libreria_online;

-- Conectarse a la base de datos libreria_online antes de continuar.

--------------------------------------------------------
-- CREACIÓN DE TABLAS
--------------------------------------------------------

CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL UNIQUE,
    edad INT NOT NULL,
    fecha_alta DATE NOT NULL,

    CONSTRAINT chk_edad_cliente
        CHECK (edad >= 18)
);

CREATE TABLE libros (
    libro_id SERIAL PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    genero VARCHAR(50) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,

    CONSTRAINT chk_precio_libro
        CHECK (precio > 0),

    CONSTRAINT chk_stock_libro
        CHECK (stock >= 0)
);

CREATE TABLE compras (
    compra_id SERIAL PRIMARY KEY,

    cliente_id INT NOT NULL,
    libro_id INT NOT NULL,

    cantidad INT NOT NULL,
    fecha_compra DATE NOT NULL,

    CONSTRAINT chk_cantidad_compra
        CHECK (cantidad > 0),

    CONSTRAINT fk_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes(cliente_id),

    CONSTRAINT fk_libro
        FOREIGN KEY (libro_id)
        REFERENCES libros(libro_id)
);

--------------------------------------------------------
-- CARGA INICIAL DE DATOS
--------------------------------------------------------

BEGIN;

--------------------------------------------------------
-- CLIENTES
--------------------------------------------------------

INSERT INTO clientes (nombre, correo, edad, fecha_alta)
VALUES
('Mariana López','mariana.lopez@mail.com',26,'2026-06-10'),
('Federico Ruiz','federico.ruiz@mail.com',39,'2026-06-12'),
('Camila Benítez','camila.benitez@mail.com',22,'2026-06-15'),
('Nicolás Herrera','nicolas.herrera@mail.com',31,'2026-06-18'),
('Lucía Fernández','lucia.fernandez@mail.com',29,'2026-06-20');

--------------------------------------------------------
-- LIBROS
--------------------------------------------------------

INSERT INTO libros (titulo, genero, precio, stock)
VALUES
('El Código Perdido','Novela',38000,20),
('Introducción a SQL','Tecnología',52000,15),
('Historia Universal','Educación',47000,12),
('Programación en Python','Tecnología',69000,10),
('Cuentos Fantásticos','Literatura',29000,25);

--------------------------------------------------------
-- COMPRAS
--------------------------------------------------------

INSERT INTO compras (cliente_id, libro_id, cantidad, fecha_compra)
VALUES
(1,2,1,'2026-07-10'),
(2,4,1,'2026-07-11'),
(3,1,2,'2026-07-12'),
(4,5,3,'2026-07-13'),
(5,3,1,'2026-07-14');

COMMIT;

--------------------------------------------------------
-- ACTUALIZACIÓN DE DATOS
--------------------------------------------------------

-- Verificar primero

SELECT *
FROM libros
WHERE genero = 'Tecnología';

UPDATE libros
SET precio = precio * 1.08
WHERE genero = 'Tecnología';

--------------------------------------------------------
-- ELIMINACIÓN DE DATOS
--------------------------------------------------------

-- Verificar primero

SELECT *
FROM compras
WHERE compra_id = 5;

DELETE FROM compras
WHERE compra_id = 5;

--------------------------------------------------------
-- CONSULTAS DE VERIFICACIÓN
--------------------------------------------------------

SELECT * FROM clientes;
SELECT * FROM libros;
SELECT * FROM compras;