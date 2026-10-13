# Propuesta inicial — pendiente de contrastar con BikeZ

## KPI definidos

Los KPI se definieron a partir del análisis del origen (`docs/analisis-origen.md`). Solo se incluyen indicadores que pueden calcularse con los datos disponibles: la base no tiene costos, stock ni moneda, por lo que no se miden rentabilidad ni inventario.

| # | KPI | Cálculo | ¿Para qué sirve? |
|---|---|---|---|
| 1 | Monto de ventas | Suma de Cantidad × PrecioUnitario | Medir el tamaño del negocio y compararlo por mes, producto, categoría o territorio. |
| 2 | Crecimiento mensual de ventas | (Monto del mes − Monto del mes anterior) / Monto del mes anterior × 100 | Saber si la empresa sigue creciendo. Se mide por mes porque 2015 y 2018 son años incompletos. Si el mes anterior no tiene ventas, no se calcula. |
| 3 | % de ventas con vendedor | Ventas con vendedor / Total de ventas × 100 | Conocer qué parte del negocio pasa por el equipo comercial y cómo cambia en el tiempo. Hoy es cerca del 12%. |
| 4 | Ticket promedio | Monto de ventas / Número de ventas distintas (`COUNT(DISTINCT VentaID)`) | Saber cuánto gasta un cliente por compra. Se divide por ventas y no por detalles, porque una venta tiene varias líneas. |
| 5 | Días promedio de despacho | Promedio de (FechaEnvio − Fecha de venta) | Medir qué tan rápido Bike Z envía sus pedidos. La base no registra la fecha de entrega al cliente, solo la de envío. |

Todos los KPI se pueden analizar por las dimensiones del modelo: fecha, producto, cliente, vendedor y territorio.

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
