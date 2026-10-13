# Modelo dimensional — Bike Z

Diseño definido a partir del análisis del origen (`docs/analisis-origen.md`), siguiendo los cuatro pasos de Kimball. Pendientes: implementar `database/scripts/03_crear_modelo_dimensional.sql` y generar `docs/modelo-dimensional/diagrama.png` a partir del modelo creado.

## KPI definidos

Los KPI se definieron a partir del análisis del origen (`docs/analisis-origen.md`). Solo se incluyen indicadores que pueden calcularse con los datos disponibles: la base no tiene costos, stock ni moneda, por lo que no se miden rentabilidad ni inventario.

| # | KPI | Cálculo | ¿Para qué sirve? |
|---|---|---|---|
| 1 | Monto de ventas | Suma de Cantidad × PrecioUnitario | Medir el tamaño del negocio y compararlo por mes, producto, categoría o territorio. |
| 2 | Crecimiento mensual de ventas | (Monto del mes − Monto del mes anterior) / Monto del mes anterior × 100 | Saber si la empresa sigue creciendo. Se mide por mes porque 2015 y 2018 son años incompletos. Si el mes anterior no tiene ventas, no se calcula. |
| 3 | % de ventas con vendedor informado | Ventas distintas con vendedor informado / Total de ventas distintas × 100 | Medir la cobertura de identificación del vendedor. En el origen: 3807 / 31465 × 100 = 12,10%. Un vendedor nulo no demuestra otro canal de venta. |
| 4 | Ticket promedio | Monto de ventas / Número de ventas distintas (`COUNT(DISTINCT VentaID)`) | Saber cuánto gasta un cliente por compra. Se divide por ventas y no por detalles, porque una venta tiene varias líneas. |
| 5 | Días promedio de despacho | Promedio de (FechaEnvio − Fecha de venta) | Medir qué tan rápido Bike Z envía sus pedidos. La base no registra la fecha de entrega al cliente, solo la de envío. |

Los KPI se calculan en el contexto de las dimensiones del modelo: fecha, producto, cliente, vendedor y territorio. El porcentaje de vendedor informado es un indicador de cobertura del dato; al filtrar un vendedor concreto pierde utilidad para comparar vendedores. En el DW, el miembro -1 se excluye del numerador, pero permanece en el denominador.

## Cuatro pasos de Kimball

### 1. Proceso de negocio
**Ventas de artículos para motocross.**

Es el proceso central de Bike Z y el que permite medir su crecimiento. El origen contiene la cabecera y el detalle necesarios para modelarlo, aunque algunos atributos estén sin informar: la cabecera de la venta (`Ventas`) registra fecha, cliente y, cuando están informados, vendedor y territorio, y el detalle (`DetalleVentas`) registra qué producto, en qué cantidad y a qué precio. No se modela inventario porque `Almacenes` solo contiene el nombre del almacén y su territorio, sin stock ni movimientos.

### 2. Granularidad
**Una fila por detalle de venta, identificada por `VentaID` + `DetalleVentaID`** (un producto dentro de una venta).

Es el nivel más fino disponible en el origen. El producto, la cantidad y el precio solo existen en `DetalleVentas`; con una fila por venta se perdería qué productos y categorías se vendieron. Con el grano por detalle se puede agregar hacia arriba (venta, día, mes, categoría, territorio), pero no se puede bajar a un detalle que no se guardó.

Como una venta tiene varias líneas (31.465 ventas y 121.317 detalles), el número de ventas se calcula con `COUNT(DISTINCT VentaID)` y no contando filas.

### 3. Dimensiones

Modelo **estrella**: cada dimensión es una sola tabla unida directamente a la tabla de hechos. Los datos que en el origen están en tablas separadas se desnormalizan dentro de su dimensión.

| Dimensión | Tablas de origen | Atributos principales | Jerarquía |
|---|---|---|---|
| DimFecha | Generada por script (no existe en el origen) | Fecha, día, mes, trimestre, semestre, año | Año → Semestre → Trimestre → Mes → Fecha |
| DimProducto | `Productos` + `Categorias` | Producto, color, categoría | Categoría → Producto |
| DimCliente | `Clientes` | ClienteID, nombre, apellido y etiqueta de presentación | — |
| DimVendedor | `Empleados` + `Territorios` | Cargo, género, estado civil, territorio asignado | — |
| DimTerritorio | `Territorios` + `Paises` | Territorio, país, grupo | Grupo → País → Territorio |

- **DimFecha** cubre del 2015-01-01 al 2018-12-31 e incluye las fechas de venta y de envío. La misma tabla se usa dos veces en el hecho: como fecha de venta y como fecha de envío.
- **DimVendedor:** el origen no tiene nombres de empleados, por lo que cada vendedor se identifica como "Vendedor ‹EmpleadoID›". Los códigos se traducen: Genero `F`/`M` → Femenino/Masculino y EstadoCivil `S`/`M` → Soltero(a)/Casado(a).
- **La geografía de la venta** se toma de `Ventas.TerritorioID` (DimTerritorio), no del territorio asignado al vendedor.
- **Almacenes no se incluye:** la venta no indica desde qué almacén se despachó, y unirla por territorio asignaría ventas a almacenes sin evidencia.

**Estrella o copo de nieve:** se eligió estrella porque `Categorias` y `Paises` solo contienen un nombre. Integrarlos en sus dimensiones evita joins adicionales, simplifica las consultas y el cubo, y es más fácil de entender para el usuario.

#### Tratamiento de datos no informados

| Situación | Tratamiento |
|---|---|
| Venta sin vendedor (27.658 ventas, 87,90%) | Se asocia a un **miembro desconocido** de DimVendedor (clave -1, "Vendedor no informado"). Así no se pierde ninguna venta y el total cuadra con el origen. |
| Cliente sin nombre ni apellido (9.546) | Conserva su fila y ClienteID. Los atributos faltantes se etiquetan como "Sin nombre informado" y "Sin apellido informado"; la etiqueta de presentación puede ser "Cliente <ClienteID>". Los otros 10.274 tienen ambos datos. No se unen clientes distintos en uno solo. |
| Producto sin color (248) | Conserva su fila; color = "Sin color informado". |
| Producto sin categoría (209) | Conserva su fila; categoría = "Sin categoría informada". |
| Empleado sin territorio asignado (275) | Territorio asignado = "Territorio no informado". |

Todas las dimensiones (salvo DimFecha, cuya clave es la fecha) tienen una fila -1 de miembro desconocido para referencias faltantes. La fila -1 se usa cuando no se sabe **quién** es; cuando el registro existe pero falta un atributo, se mantiene su fila y se rellena el texto.

### 4. Tabla de hechos y medidas

**FactVentas**: una fila por detalle de venta.

| Columna | Tipo | Origen o cálculo |
|---|---|---|
| `VentaID`, `DetalleVentaID` | Dimensiones degeneradas (clave primaria) | `DetalleVentas`. Identifican la línea; la clave primaria impide cargar dos veces el mismo detalle. |
| `FechaVentaKey` | Clave de DimFecha | `Ventas.Fecha` en formato AAAAMMDD |
| `FechaEnvioKey` | Clave de DimFecha (rol envío) | `Ventas.FechaEnvio` en formato AAAAMMDD |
| `ProductoKey` | Clave de DimProducto | Búsqueda por `DetalleVentas.ProductoID` |
| `ClienteKey` | Clave de DimCliente | Búsqueda por `Ventas.ClienteID` |
| `VendedorKey` | Clave de DimVendedor | Búsqueda por `Ventas.VendedorID`; -1 si no tiene vendedor |
| `TerritorioKey` | Clave de DimTerritorio | Búsqueda por `Ventas.TerritorioID` |
| `Cantidad` | Medida | `DetalleVentas.Cantidad` |
| `PrecioUnitario` | Medida | `DetalleVentas.PrecioUnitario` (`money`, 4 decimales) |
| `ImporteVenta` | Medida calculada | `Cantidad × PrecioUnitario` |
| `DiasDespacho` | Medida calculada | Días entre `Fecha` y `FechaEnvio` |

#### Medidas que se suman y medidas que se recalculan

| Medida | Clasificación | Cómo se agrega |
|---|---|---|
| Cantidad | **Aditiva** | Se suma por cualquier dimensión. |
| ImporteVenta | **Aditiva** | Se suma por cualquier dimensión. Se guarda calculada para no multiplicar en cada consulta. |
| PrecioUnitario | **No aditiva** | No se suma: sumar precios no representa ningún valor. El precio promedio se recalcula como Σ ImporteVenta / Σ Cantidad. |
| DiasDespacho | **No aditiva** | No se suma. Se promedia en cada nivel de análisis. Como los días pertenecen a la venta y se repiten en cada línea, el promedio se calcula por venta distinta. |
| Número de ventas | **Calculada** (conteo distinto) | `COUNT(DISTINCT VentaID)` en cada contexto. Los conteos de distintos grupos no se suman, porque una misma venta puede aparecer en varios productos. |
| Ticket promedio, crecimiento y porcentajes | **Calculadas** | Se recalculan en cada nivel a partir del monto y el número de ventas. Nunca se suman porcentajes ni promedios. |

## Decisiones del modelo

- **Historia de las dimensiones (SCD tipo 1):** los cambios se sobrescriben. El origen solo guarda el valor actual de cada atributo y no tiene fechas de vigencia, por lo que no hay historia que conservar.
- **Claves sustitutas:** cada dimensión (salvo DimFecha) usa una clave propia generada en el DW y conserva el ID del origen para la trazabilidad. Las claves se resuelven durante el ETL.
- **Referencias inexistentes y devoluciones:** el análisis del origen no encontró referencias inexistentes, cantidades negativas ni precios negativos, por lo que no se requiere un tratamiento especial. Si aparecieran en cargas futuras, las referencias faltantes se asocian al miembro -1.
- **Sin rentabilidad ni moneda:** no se calcula utilidad porque no hay costos, y los montos se presentan sin convertir porque el origen no informa la moneda.

## Pendiente
Script de creación en SQL Server (`03_crear_modelo_dimensional.sql`), diagrama del modelo implementado y proceso ETL. Este documento describe el diseño; el DW todavía no está creado ni cargado.
