--------------------------------------------------------
-- PRE-ENTREGA MÓDULO 5
-- Script de análisis avanzado con Window Functions
-- Retail Project
-- Alumno: Carlos Contreras
--------------------------------------------------------
-- Escenario:
-- A partir de las ventas registradas, se busca un reporte
-- mensual por categoría que muestre el ranking de cada
-- categoría dentro de su mes, el acumulado histórico de
-- ventas y si el mes fue "Exitoso" o quedó "Bajo el
-- promedio" respecto al comportamiento habitual de esa
-- categoría.
--
-- Tablas utilizadas: ventas, productos, categorias
-- (mismo dataset del Módulo 4).
--------------------------------------------------------
 
 
--------------------------------------------------------
-- 1. CTE ventas_mensuales
--------------------------------------------------------
-- Problema de negocio:
-- Agrupa las ventas por mes y por categoría de producto,
-- para conocer cuánto ingreso generó cada categoría en
-- cada período.
--
-- DATE_TRUNC('month', fecha_venta) normaliza la fecha al
-- primer día del mes, para poder agrupar por mes sin
-- importar el día exacto de cada venta.
--
-- El ingreso de cada venta se calcula como
-- cantidad * precio del producto.
 
WITH ventas_mensuales AS (
 
    SELECT
        DATE_TRUNC('month', v.fecha_venta) AS mes,
        cat.nombre AS categoria,
        SUM(v.cantidad * p.precio) AS venta_total
 
    FROM ventas AS v
 
    INNER JOIN productos AS p
        ON v.producto_id = p.producto_id
 
    INNER JOIN categorias AS cat
        ON p.categoria_id = cat.categoria_id
 
    GROUP BY
        DATE_TRUNC('month', v.fecha_venta),
        cat.nombre
),
 
 
--------------------------------------------------------
-- 2. CTE metricas_ventana
--------------------------------------------------------
-- Problema de negocio:
-- Sobre las ventas mensuales por categoría, calcula tres
-- métricas usando funciones de ventana:
--
--   - ranking_categoria: posición de la categoría dentro
--     de cada mes según sus ventas (RANK, para que las
--     categorías empatadas compartan posición).
--
--   - ventas_acumuladas: total acumulado de la categoría
--     a lo largo del tiempo (running total). Es clave el
--     ORDER BY dentro del OVER: sin él, SQL devolvería el
--     total general de la categoría en cada fila en lugar
--     de la suma progresiva mes a mes.
--
--   - promedio_historico: promedio de ventas mensuales de
--     esa categoría a lo largo de todo el período, para
--     poder comparar cada mes puntual contra su propio
--     comportamiento habitual (misma granularidad:
--     mes/categoría en ambos lados de la comparación).
 
metricas_ventana AS (
 
    SELECT
        mes,
        categoria,
        venta_total,
 
        RANK() OVER (
            PARTITION BY mes
            ORDER BY venta_total DESC
        ) AS ranking_categoria,
 
        SUM(venta_total) OVER (
            PARTITION BY categoria
            ORDER BY mes
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS ventas_acumuladas,
 
        AVG(venta_total) OVER (
            PARTITION BY categoria
        ) AS promedio_historico
 
    FROM ventas_mensuales
)
 
 
--------------------------------------------------------
-- 3. Reporte final
--------------------------------------------------------
-- Problema de negocio:
-- Compara la venta de cada mes/categoría contra el
-- promedio histórico de esa misma categoría, para marcar
-- si ese mes fue "Exitoso" o quedó "Bajo el promedio".
 
SELECT
    mes,
    categoria,
    venta_total,
    ranking_categoria,
    ventas_acumuladas,
 
    CASE
        WHEN venta_total >= promedio_historico
            THEN 'Exitoso'
        ELSE 'Bajo el promedio'
    END AS comparativa
 
FROM metricas_ventana
 
ORDER BY
    mes,
    ranking_categoria;
