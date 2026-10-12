# Propuesta inicial — pendiente de contrastar con BikeZ

## Cuatro pasos de Kimball
1. **Proceso de negocio:** ventas de artículos para motocross.
2. **Granularidad:** una fila por detalle `(VentaID, DetalleVentaID)`.
3. **Dimensiones:** Fecha, Cliente, Producto, Vendedor y Territorio.
4. **Hecho y medidas:** FactVentas con Cantidad, PrecioUnitario e ImporteVenta.

## Componentes propuestos
| Componente | Contenido previsto |
|---|---|
| DimFecha | Clave YYYYMMDD, fecha, año, trimestre, mes y día; roles venta y envío |
| DimCliente | Clave sustituta, ClienteID, nombre y apellido |
| DimProducto | Clave sustituta, ProductoID, producto, color y categoría |
| DimVendedor | Clave sustituta, EmpleadoID y atributos pertinentes del empleado |
| DimTerritorio | Clave sustituta, TerritorioID, territorio, país y grupo |
| FactVentas | Claves dimensionales, VentaID, DetalleVentaID, Cantidad, PrecioUnitario, ImporteVenta |

La estrella desnormaliza categoría dentro de Producto y país/grupo dentro de Territorio. Las claves de referencia deben resolverse durante el ETL y conservar la trazabilidad con claves naturales.

## Decisiones que deben explicarse
- Un pedido puede contener varias líneas. Contar pedidos con DISTINCT VentaID, no con COUNT(*).
- Cantidad e ImporteVenta son aditivos. PrecioUnitario, ticket, porcentajes y conteos distintos se recalculan en su contexto.
- El ticket se obtiene como importe total / pedidos distintos; no como promedio de tickets parciales.
- Usar Ventas.TerritorioID para la geografía comercial.
- No atribuir ventas a Almacenes solo por territorio. El esquema no ofrece AlmacenID en la venta y una unión podría multiplicar filas.
- No calcular utilidad sin costos ni asumir una moneda que el origen no informa.
- Definir tratamiento de NULL, huérfanos, devoluciones, fechas y cambios dimensionales después del perfilamiento real.

## Pendiente de implementar
Diagrama definitivo, diccionario con tipos reales, DDL, claves, restricciones, política de historia dimensional, miembros desconocidos, reglas de calidad y medidas finales. Este documento no afirma que exista un DW creado o cargado.
