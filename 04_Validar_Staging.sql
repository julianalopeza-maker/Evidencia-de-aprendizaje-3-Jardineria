/*
Descripción:
- Compara conteos entre la base fuente y la base staging.
- Identifica nombres comerciales repetidos.
- Detecta pedidos con fechas potencialmente inconsistentes.
- Revisa pagos huérfanos y una vista previa de la vista integrada.
*/

SELECT '1. Comparación de conteos origen vs staging' AS seccion;
SELECT 'oficina' AS tabla,
       (SELECT COUNT(*) FROM jardineria.oficina) AS registros_origen,
       (SELECT COUNT(*) FROM jardineria_staging.oficina) AS registros_staging,
       CASE WHEN (SELECT COUNT(*) FROM jardineria.oficina) = (SELECT COUNT(*) FROM jardineria_staging.oficina)
            THEN 'OK' ELSE 'REVISAR' END AS estado
UNION ALL
SELECT 'empleado',
       (SELECT COUNT(*) FROM jardineria.empleado),
       (SELECT COUNT(*) FROM jardineria_staging.empleado),
       CASE WHEN (SELECT COUNT(*) FROM jardineria.empleado) = (SELECT COUNT(*) FROM jardineria_staging.empleado)
            THEN 'OK' ELSE 'REVISAR' END
UNION ALL
SELECT 'gama_producto',
       (SELECT COUNT(*) FROM jardineria.gama_producto),
       (SELECT COUNT(*) FROM jardineria_staging.gama_producto),
       CASE WHEN (SELECT COUNT(*) FROM jardineria.gama_producto) = (SELECT COUNT(*) FROM jardineria_staging.gama_producto)
            THEN 'OK' ELSE 'REVISAR' END
UNION ALL
SELECT 'cliente',
       (SELECT COUNT(*) FROM jardineria.cliente),
       (SELECT COUNT(*) FROM jardineria_staging.cliente),
       CASE WHEN (SELECT COUNT(*) FROM jardineria.cliente) = (SELECT COUNT(*) FROM jardineria_staging.cliente)
            THEN 'OK' ELSE 'REVISAR' END
UNION ALL
SELECT 'pedido',
       (SELECT COUNT(*) FROM jardineria.pedido),
       (SELECT COUNT(*) FROM jardineria_staging.pedido),
       CASE WHEN (SELECT COUNT(*) FROM jardineria.pedido) = (SELECT COUNT(*) FROM jardineria_staging.pedido)
            THEN 'OK' ELSE 'REVISAR' END
UNION ALL
SELECT 'producto',
       (SELECT COUNT(*) FROM jardineria.producto),
       (SELECT COUNT(*) FROM jardineria_staging.producto),
       CASE WHEN (SELECT COUNT(*) FROM jardineria.producto) = (SELECT COUNT(*) FROM jardineria_staging.producto)
            THEN 'OK' ELSE 'REVISAR' END
UNION ALL
SELECT 'detalle_pedido',
       (SELECT COUNT(*) FROM jardineria.detalle_pedido),
       (SELECT COUNT(*) FROM jardineria_staging.detalle_pedido),
       CASE WHEN (SELECT COUNT(*) FROM jardineria.detalle_pedido) = (SELECT COUNT(*) FROM jardineria_staging.detalle_pedido)
            THEN 'OK' ELSE 'REVISAR' END
UNION ALL
SELECT 'pago',
       (SELECT COUNT(*) FROM jardineria.pago),
       (SELECT COUNT(*) FROM jardineria_staging.pago),
       CASE WHEN (SELECT COUNT(*) FROM jardineria.pago) = (SELECT COUNT(*) FROM jardineria_staging.pago)
            THEN 'OK' ELSE 'REVISAR' END;

SELECT '2. Clientes con nombre comercial repetido' AS seccion;
SELECT nombre_cliente, COUNT(*) AS repeticiones
FROM jardineria_staging.cliente
GROUP BY nombre_cliente
HAVING COUNT(*) > 1
ORDER BY repeticiones DESC, nombre_cliente;

SELECT '3. Pedidos con fechas potencialmente inconsistentes' AS seccion;
SELECT codigo_pedido, fecha_pedido, fecha_esperada, fecha_entrega, estado, codigo_cliente
FROM jardineria_staging.pedido
WHERE fecha_esperada < fecha_pedido
   OR (fecha_entrega IS NOT NULL AND fecha_entrega < fecha_pedido)
ORDER BY codigo_pedido;

SELECT '4. Pagos sin cliente asociado (debe devolver 0 filas)' AS seccion;
SELECT p.*
FROM jardineria_staging.pago p
LEFT JOIN jardineria_staging.cliente c
  ON c.codigo_cliente = p.codigo_cliente
WHERE c.codigo_cliente IS NULL;

SELECT '5. Resumen de nulos en campos opcionales de cliente' AS seccion;
SELECT
  SUM(CASE WHEN linea_direccion2 IS NULL THEN 1 ELSE 0 END) AS clientes_sin_direccion2,
  SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS clientes_sin_region,
  SUM(CASE WHEN pais IS NULL THEN 1 ELSE 0 END) AS clientes_sin_pais,
  SUM(CASE WHEN codigo_empleado_rep_ventas IS NULL THEN 1 ELSE 0 END) AS clientes_sin_representante
FROM jardineria_staging.cliente;

SELECT '6. Vista previa de la vista integrada' AS seccion;
SELECT *
FROM jardineria_staging.vw_ventas_integradas
ORDER BY codigo_pedido, numero_linea
LIMIT 20;
