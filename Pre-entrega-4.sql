--------------------------------------------------------
-- PRE-ENTREGA MÓDULO 4
-- Consultas multicapa para análisis de negocio
-- Retail Project
-- Alumno: Carlos Contreras
--------------------------------------------------------


--------------------------------------------------------
-- 1. RENTABILIDAD POR CATEGORÍA
--------------------------------------------------------
-- Problema de negocio:
-- Permite conocer cuántas unidades se vendieron y cuánto
-- ingreso generó cada género de libros.
--
-- Se unen las tablas compras y libros.
-- El género funciona como categoría dentro de la tabla libros.
--
-- Solo se muestran las categorías que superan
-- las 100.000 unidades monetarias de ingresos.

SELECT
    l.genero AS categoria,
    SUM(c.cantidad) AS unidades_vendidas,
    SUM(c.cantidad * l.precio) AS ingreso_total
FROM compras AS c
INNER JOIN libros AS l
    ON c.libro_id = l.libro_id
GROUP BY l.genero
HAVING SUM(c.cantidad * l.precio) > 100000
ORDER BY ingreso_total DESC;


--------------------------------------------------------
-- 2. CLIENTES SIN COMPRAS
--------------------------------------------------------
-- Problema de negocio:
-- Permite identificar clientes registrados que todavía
-- no realizaron ninguna compra.
--
-- Se utiliza LEFT JOIN para conservar todos los clientes.
-- Los clientes que no tienen compras tendrán NULL
-- en compra_id.
-- COALESCE permite mostrar 0 en lugar de NULL.

SELECT
    c.cliente_id,
    c.nombre,
    c.correo,
    COALESCE(co.compra_id, 0) AS compra_id
FROM clientes AS c
LEFT JOIN compras AS co
    ON c.cliente_id = co.cliente_id
WHERE co.compra_id IS NULL;


--------------------------------------------------------
-- 3. TOP DE COMPRAS POR CLIENTE
--------------------------------------------------------
-- Problema de negocio:
-- Permite identificar cuál es el libro que cada cliente
-- compró en mayor cantidad y conocer la fecha de su
-- última transacción.
--
-- Primero se agrupan las compras por cliente y libro.
-- SUM(cantidad) permite conocer cuántas unidades compró
-- de cada libro.
--
-- Luego ROW_NUMBER() genera un ranking para cada cliente.
-- Finalmente se conserva únicamente la posición 1.

WITH compras_por_cliente AS (

    SELECT
        cl.cliente_id,
        cl.nombre AS cliente,
        l.libro_id,
        l.titulo AS producto,
        SUM(co.cantidad) AS unidades_compradas,
        MAX(co.fecha_compra) AS ultima_transaccion

    FROM clientes AS cl

    INNER JOIN compras AS co
        ON cl.cliente_id = co.cliente_id

    INNER JOIN libros AS l
        ON co.libro_id = l.libro_id

    GROUP BY
        cl.cliente_id,
        cl.nombre,
        l.libro_id,
        l.titulo
),

ranking_productos AS (

    SELECT
        cliente_id,
        cliente,
        producto,
        unidades_compradas,
        ultima_transaccion,

        ROW_NUMBER() OVER (
            PARTITION BY cliente_id
            ORDER BY unidades_compradas DESC,
                     ultima_transaccion DESC
        ) AS posicion

    FROM compras_por_cliente
)

SELECT
    cliente,
    producto,
    unidades_compradas,
    ultima_transaccion
FROM ranking_productos
WHERE posicion = 1
ORDER BY cliente;