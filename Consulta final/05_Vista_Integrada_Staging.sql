/*
Descripción:
- Crea una vista integrada de ventas orientada a la futura carga del modelo estrella.
- Consolida pedido, cliente, empleado, oficina, producto y gama.
*/

USE jardineria_staging;

CREATE OR REPLACE VIEW vw_ventas_integradas AS
SELECT
  pe.codigo_pedido,
  dp.numero_linea,
  pe.fecha_pedido,
  pe.fecha_esperada,
  pe.fecha_entrega,
  pe.estado AS estado_pedido,
  cl.codigo_cliente,
  cl.nombre_cliente,
  cl.nombre_contacto,
  cl.apellido_contacto,
  cl.ciudad AS ciudad_cliente,
  cl.region AS region_cliente,
  cl.pais AS pais_cliente,
  cl.limite_credito,
  em.codigo_empleado AS codigo_representante_ventas,
  TRIM(CONCAT(
      COALESCE(em.nombre, ''),
      ' ',
      COALESCE(em.apellido1, ''),
      CASE
        WHEN em.apellido2 IS NULL OR em.apellido2 = '' THEN ''
        ELSE CONCAT(' ', em.apellido2)
      END
  )) AS representante_ventas,
  em.puesto,
  ofi.codigo_oficina,
  ofi.ciudad AS ciudad_oficina,
  ofi.pais AS pais_oficina,
  ofi.region AS region_oficina,
  pr.codigo_producto,
  pr.nombre AS nombre_producto,
  gp.gama,
  pr.cantidad_en_stock,
  pr.precio_venta,
  pr.precio_proveedor,
  dp.cantidad,
  dp.precio_unidad,
  CAST(dp.cantidad * dp.precio_unidad AS DECIMAL(15,2)) AS subtotal_venta,
  CAST(dp.cantidad * COALESCE(pr.precio_proveedor, 0) AS DECIMAL(15,2)) AS costo_estimado,
  CAST((dp.cantidad * dp.precio_unidad) - (dp.cantidad * COALESCE(pr.precio_proveedor, 0)) AS DECIMAL(15,2)) AS margen_estimado
FROM detalle_pedido dp
INNER JOIN pedido pe
  ON pe.codigo_pedido = dp.codigo_pedido
INNER JOIN cliente cl
  ON cl.codigo_cliente = pe.codigo_cliente
LEFT JOIN empleado em
  ON em.codigo_empleado = cl.codigo_empleado_rep_ventas
LEFT JOIN oficina ofi
  ON ofi.codigo_oficina = em.codigo_oficina
INNER JOIN producto pr
  ON pr.codigo_producto = dp.codigo_producto
LEFT JOIN gama_producto gp
  ON gp.gama = pr.gama;
