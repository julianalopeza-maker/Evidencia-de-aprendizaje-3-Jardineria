/*
Descripción:
- Carga la base `jardineria_staging` desde la base operacional `jardineria`.
- Conserva las claves fuente.
- Aplica limpiezas básicas de espacios vacíos en campos opcionales.
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE jardineria_staging.pago;
TRUNCATE TABLE jardineria_staging.detalle_pedido;
TRUNCATE TABLE jardineria_staging.producto;
TRUNCATE TABLE jardineria_staging.pedido;
TRUNCATE TABLE jardineria_staging.cliente;
TRUNCATE TABLE jardineria_staging.empleado;
TRUNCATE TABLE jardineria_staging.gama_producto;
TRUNCATE TABLE jardineria_staging.oficina;

SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO jardineria_staging.oficina
(codigo_oficina, ciudad, pais, region, codigo_postal, telefono, linea_direccion1, linea_direccion2)
SELECT
  TRIM(codigo_oficina),
  TRIM(ciudad),
  TRIM(pais),
  NULLIF(TRIM(region), ''),
  TRIM(codigo_postal),
  TRIM(telefono),
  TRIM(linea_direccion1),
  NULLIF(TRIM(linea_direccion2), '')
FROM jardineria.oficina;

INSERT INTO jardineria_staging.empleado
(codigo_empleado, nombre, apellido1, apellido2, extension, email, codigo_oficina, codigo_jefe, puesto)
SELECT
  codigo_empleado,
  TRIM(nombre),
  TRIM(apellido1),
  NULLIF(TRIM(apellido2), ''),
  TRIM(extension),
  LOWER(TRIM(email)),
  TRIM(codigo_oficina),
  codigo_jefe,
  NULLIF(TRIM(puesto), '')
FROM jardineria.empleado;

INSERT INTO jardineria_staging.gama_producto
(gama, descripcion_texto, descripcion_html, imagen)
SELECT
  TRIM(gama),
  descripcion_texto,
  descripcion_html,
  NULLIF(TRIM(imagen), '')
FROM jardineria.gama_producto;

INSERT INTO jardineria_staging.cliente
(codigo_cliente, nombre_cliente, nombre_contacto, apellido_contacto, telefono, fax,
 linea_direccion1, linea_direccion2, ciudad, region, pais, codigo_postal,
 codigo_empleado_rep_ventas, limite_credito)
SELECT
  codigo_cliente,
  TRIM(nombre_cliente),
  NULLIF(TRIM(nombre_contacto), ''),
  NULLIF(TRIM(apellido_contacto), ''),
  TRIM(telefono),
  TRIM(fax),
  TRIM(linea_direccion1),
  NULLIF(TRIM(linea_direccion2), ''),
  TRIM(ciudad),
  NULLIF(TRIM(region), ''),
  NULLIF(TRIM(pais), ''),
  NULLIF(TRIM(codigo_postal), ''),
  codigo_empleado_rep_ventas,
  limite_credito
FROM jardineria.cliente;

INSERT INTO jardineria_staging.pedido
(codigo_pedido, fecha_pedido, fecha_esperada, fecha_entrega, estado, comentarios, codigo_cliente)
SELECT
  codigo_pedido,
  fecha_pedido,
  fecha_esperada,
  fecha_entrega,
  TRIM(estado),
  comentarios,
  codigo_cliente
FROM jardineria.pedido;

INSERT INTO jardineria_staging.producto
(codigo_producto, nombre, gama, dimensiones, proveedor, descripcion, cantidad_en_stock, precio_venta, precio_proveedor)
SELECT
  TRIM(codigo_producto),
  TRIM(nombre),
  TRIM(gama),
  NULLIF(TRIM(dimensiones), ''),
  NULLIF(TRIM(proveedor), ''),
  descripcion,
  cantidad_en_stock,
  precio_venta,
  precio_proveedor
FROM jardineria.producto;

INSERT INTO jardineria_staging.detalle_pedido
(codigo_pedido, codigo_producto, cantidad, precio_unidad, numero_linea)
SELECT
  codigo_pedido,
  TRIM(codigo_producto),
  cantidad,
  precio_unidad,
  numero_linea
FROM jardineria.detalle_pedido;

INSERT INTO jardineria_staging.pago
(codigo_cliente, forma_pago, id_transaccion, fecha_pago, total)
SELECT
  codigo_cliente,
  TRIM(forma_pago),
  TRIM(id_transaccion),
  fecha_pago,
  total
FROM jardineria.pago;
