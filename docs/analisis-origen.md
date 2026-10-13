# Análisis del origen BikeZ

**Estado:** exploración inicial y primeros controles de calidad ejecutados por Joaquín. Se registraron los conteos, el rango de fechas y las columnas de las claves primarias de las 9 tablas de negocio. Faltan algunas comprobaciones adicionales para preparar las transformaciones.

Consultas utilizadas: `database/scripts/01_explorar_origen.sql` y `database/scripts/02_revisar_calidad.sql`.

| Dato | Resultado real |
|---|---|
| Fecha de ejecución | 12 de octubre de 2026 |
| Motor y edición | SQL Server 2019 Developer Edition (64-bit), versión 15.0.2000.5 |
| Nombre de base | BikeZ |
| Ejecución | SSMS muestra que la consulta terminó correctamente |

## Cantidad de registros

| Tabla | Filas |
|---|---:|
| Almacenes | 701 |
| Categorias | 37 |
| Clientes | 19820 |
| DetalleVentas | 121317 |
| Empleados | 290 |
| Paises | 238 |
| Productos | 504 |
| Territorios | 10 |
| Ventas | 31465 |

También aparece `sysdiagrams` con 1 registro. Es una tabla de soporte de los diagramas de SSMS y no se utilizará como fuente de negocio.

## Período de los datos

| Resultado | Fecha |
|---|---|
| PrimeraVenta | 2015-07-01 |
| UltimaVenta | 2018-07-31 |
| PrimerEnvio | 2015-07-08 |
| UltimoEnvio | 2018-08-07 |

La dimensión Fecha debe cubrir, como mínimo, del 1 de julio de 2015 al 7 de agosto de 2018 para resolver tanto la fecha de venta como la de envío. El último envío está fuera del mes de la última venta, por lo que el calendario no debe terminar en julio de 2018.

El rango se incorporó el 13 de octubre de 2026 a partir de la captura compartida por Joaquín. Los años extremos tienen información de ventas para una parte del año; esto se debe considerar al comparar períodos.

## Hallazgos y decisiones

- Hay 31465 ventas y 121317 detalles de venta. Una venta puede tener varios detalles, por lo que el número de ventas debe calcularse con `COUNT(DISTINCT VentaID)` cuando se consulta el detalle.
- La clave primaria de DetalleVentas es `(VentaID, DetalleVentaID)`. Esta combinación permite identificar cada fila del hecho propuesto.
- `Cantidad` es `smallint` y `PrecioUnitario` es `money`, con precisión 19 y escala 4. Debemos conservar los decimales al calcular los importes.
- `Ventas.Fecha` y `Ventas.FechaEnvio` son `datetime`. Aunque FechaEnvio permite nulos, el control detectó 0 ventas sin envío informado y 0 envíos anteriores a la venta. Los rangos se registraron en la sección anterior.
- Los controles confirmaron datos faltantes en nombres, apellidos, colores, categorías, vendedores y territorios de empleados. Su tratamiento propuesto se detalla abajo.
- `PaisID` es `nvarchar(3)` tanto en Paises como en Territorios. Se debe mantener como texto al relacionar estas tablas.
- Las 9 claves foráneas compartidas están habilitadas y verificadas (`Deshabilitada = 0`, `NoVerificada = 0`). Los 9 controles de referencias no nulas inexistentes dieron 0; los nulos permitidos se revisaron por separado.
- El territorio de la venta proviene de `Ventas.TerritorioID`. Almacenes no tiene una relación directa con cada venta, por lo que no lo uniremos al hecho solo por territorio.

Las claves primarias recibidas cubren las 9 tablas de negocio. La captura adicional confirmó `Ventas.VentaID` y `Territorios.TerritorioID`, ambas claves de una sola columna. DetalleVentas tiene la clave compuesta indicada anteriormente; las otras tablas usan sus identificadores respectivos.

## Calidad de datos

| Control | Filas |
|---|---:|
| Ventas sin vendedor | 27658 |
| Clientes sin nombre o con nombre vacío | 9546 |
| Clientes sin apellido o con apellido vacío | 9546 |
| Productos sin color o con color vacío | 248 |
| Productos sin categoría | 209 |
| Empleados sin territorio | 275 |

Los controles restantes de `02_revisar_calidad.sql` dieron 0: ventas sin envío, envíos anteriores a la venta, ventas sin territorio, cantidades cero o negativas, precios cero o negativos, almacenes sin territorio, ventas sin detalles y claves de detalle duplicadas. También dieron 0 los 9 controles de referencias inexistentes.

Las ventas sin vendedor representan el 87,90% de las 31465 ventas; las otras 3807 sí tienen vendedor informado. Esto limita la comparación de vendedores identificados: debemos mostrar también las ventas sin vendedor para conservar el total.

El resultado 4 confirmó que los 9546 clientes sin nombre son los mismos que no tienen apellido. Los otros 10274 tienen ambos datos informados. No hay clientes con solo uno de los dos datos faltante.

| Clasificación | Clientes |
|---|---:|
| Sin nombre ni apellido | 9546 |
| Solo sin nombre | 0 |
| Solo sin apellido | 0 |
| Con nombre y apellido | 10274 |
| Total | 19820 |

Las categorías suman los 19820 clientes del origen. No se suman los dos conteos de 9546 como si fueran personas diferentes.

### Tratamiento propuesto para el ETL

| Situación | Tratamiento |
|---|---|
| Venta sin vendedor | Conservar la venta y asociarla a un miembro de DimVendedor etiquetado como "Vendedor no informado". No inventar un empleado ni atribuirla a uno existente. |
| Cliente sin nombre o apellido | Mantener su ClienteID y una fila propia en DimCliente. Para los 9546 sin ambos datos, proponer la etiqueta de presentación "Cliente <ClienteID>"; por ejemplo, "Cliente 123". Conservar la identificación de los atributos faltantes y no reunir distintos clientes en uno solo. |
| Producto sin color | Mantener el producto y usar "Sin color informado" como etiqueta. |
| Producto sin categoría | Mantener el producto y usar "Sin categoría informada" en el atributo de categoría. |
| Empleado sin territorio | Si se conserva ese atributo, identificarlo como "Territorio no informado". La geografía de la venta sigue viniendo de Ventas.TerritorioID. |

Estas reglas están propuestas para la implementación. El DW y el ETL aún no están construidos. Los controles ejecutados no justifican rechazar ventas por los datos descriptivos faltantes; debemos conservar las filas y sus importes, manteniendo trazabilidad de estos casos.

## Pendientes del análisis

La exploración inicial y los cuatro resultados de `02_revisar_calidad.sql` quedaron registrados. Antes de construir las transformaciones que los utilicen, revisar códigos de género y estado civil, espacios y longitudes de textos.

## Evidencia
- [Estructura y claves primarias](evidencias/01_exploracion_estructura.png): base, versión, columnas visibles y parte de las claves.
- [Relaciones y conteos parciales](evidencias/02_exploracion_conteos_parciales.png): relaciones visibles y conteos; algunos valores están cortados y faltan las últimas filas.
- [Conteos completos](evidencias/01_conteos_origen.tsv), [columnas](evidencias/01_columnas_origen.tsv), [relaciones](evidencias/01_claves_foraneas.tsv) y [claves primarias parciales](evidencias/01_claves_primarias_parciales.tsv): resultados copiados por Joaquín desde SSMS y compartidos en texto.
- [Columnas clave de Ventas y Territorios](evidencias/01_claves_primarias_adicionales.tsv) y [captura de confirmación](evidencias/04_exploracion_claves_primarias.png): completan las columnas de las claves primarias de negocio. Los nombres generados de las restricciones se conservan en la captura, sin transcribir valores que aparecen cortados.
- [Controles de calidad](evidencias/02_calidad_origen.tsv) y [referencias inexistentes](evidencias/02_referencias_origen.tsv): resultados de la segunda consulta compartidos por Joaquín.
- [Rango de fechas](evidencias/02_rango_fechas.tsv) y [captura del rango](evidencias/03_exploracion_rango_fechas.png): resultado de PrimeraVenta, UltimaVenta, PrimerEnvio y UltimoEnvio compartido por Joaquín.
- [Clasificación de clientes](evidencias/02_nombres_clientes.tsv) y [captura de clientes](evidencias/05_exploracion_nombres_clientes.png): resultado 4, que confirma la coincidencia de clientes sin nombre y sin apellido.

Ejecución realizada por Joaquín Ramírez. Falta completar los pendientes indicados y registrar el commit o PR de este avance.
