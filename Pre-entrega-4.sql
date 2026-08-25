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
-- ingreso generó cada categoría.
--
-- Se unen las tablas ventas, productos y categorias para
-- relacionar cada venta con su producto y categoría.
--
-- Solo se muestran las categorías que superan
-- los $100.000 de ingresos.
-- El filtro de la suma se realiza mediante HAVING.

SELECT
    cat.nombre AS categoria,
    SUM(v.cantidad) AS unidades_vendidas,
    SUM(v.cantidad * p.precio) AS ingreso_total
FROM ventas AS v
INNER JOIN productos AS p
    ON v.producto_id = p.producto_id
INNER JOIN categorias AS cat
    ON p.categoria_id = cat.categoria_id
GROUP BY
    cat.categoria_id,
    cat.nombre
HAVING SUM(v.cantidad * p.precio) > 100000
ORDER BY ingreso_total DESC;


--------------------------------------------------------
-- 2. CLIENTES SIN COMPRAS
--------------------------------------------------------
-- Problema de negocio:
-- Permite identificar clientes registrados que todavía
-- no realizaron ninguna compra.
--
-- Se utiliza LEFT JOIN para conservar todos los clientes,
-- incluso aquellos que no tienen ventas asociadas.
--
-- COALESCE permite mostrar 0 en lugar de NULL.

SELECT
    c.cliente_id,
    c.nombre,
    c.correo,
    COALESCE(v.venta_id, 0) AS venta_id
FROM clientes AS c
LEFT JOIN ventas AS v
    ON c.cliente_id = v.cliente_id
WHERE v.venta_id IS NULL;


--------------------------------------------------------
-- 3. TOP DE COMPRAS POR CLIENTE
--------------------------------------------------------
-- Problema de negocio:
-- Permite identificar cuál es el producto que cada cliente
-- compró en mayor cantidad y conocer la fecha de su
-- última transacción.
--
-- Primero se agrupan las ventas por cliente y producto.
-- SUM(cantidad) permite conocer cuántas unidades compró
-- de cada producto.
--
-- MAX(fecha_venta) permite obtener la última transacción.
--
-- ROW_NUMBER() genera un ranking para cada cliente y
-- finalmente se conserva únicamente la posición 1.

WITH compras_por_cliente AS (

    SELECT
        c.cliente_id,
        c.nombre AS cliente,
        p.producto_id,
        p.nombre AS producto,
        SUM(v.cantidad) AS unidades_compradas,
        MAX(v.fecha_venta) AS ultima_transaccion

    FROM clientes AS c

    INNER JOIN ventas AS v
        ON c.cliente_id = v.cliente_id

    INNER JOIN productos AS p
        ON v.producto_id = p.producto_id

    GROUP BY
        c.cliente_id,
        c.nombre,
        p.producto_id,
        p.nombre
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
            ORDER BY
                unidades_compradas DESC,
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
