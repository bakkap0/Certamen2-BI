# Análisis del origen BikeZ

**Estado:** exploración inicial y controles de calidad ejecutados por Joaquín. Frank registró el rango de fechas y los códigos de género y estado civil. Faltan las claves primarias de Ventas y Territorios y algunas comprobaciones adicionales.

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

## Hallazgos y decisiones

- Hay 31465 ventas y 121317 detalles de venta. Una venta puede tener varios detalles, por lo que el número de ventas debe calcularse con `COUNT(DISTINCT VentaID)` cuando se consulta el detalle.
- La clave primaria de DetalleVentas es `(VentaID, DetalleVentaID)`. Esta combinación permite identificar cada fila del hecho propuesto.
- `Cantidad` es `smallint` y `PrecioUnitario` es `money`, con precisión 19 y escala 4. Debemos conservar los decimales al calcular los importes.
- `Ventas.Fecha` y `Ventas.FechaEnvio` son `datetime`. Aunque FechaEnvio permite nulos, el control detectó 0 ventas sin envío informado y 0 envíos anteriores a la venta. Falta registrar el rango de fechas.
- Los controles confirmaron datos faltantes en nombres, apellidos, colores, categorías, vendedores y territorios de empleados. Su tratamiento propuesto se detalla abajo.
- `PaisID` es `nvarchar(3)` tanto en Paises como en Territorios. Se debe mantener como texto al relacionar estas tablas.
- Las 9 claves foráneas compartidas están habilitadas y verificadas (`Deshabilitada = 0`, `NoVerificada = 0`). Los 9 controles de referencias no nulas inexistentes dieron 0; los nulos permitidos se revisaron por separado.
- El territorio de la venta proviene de `Ventas.TerritorioID`. Almacenes no tiene una relación directa con cada venta, por lo que no lo uniremos al hecho solo por territorio.

Las claves primarias recibidas cubren Almacenes, Categorias, Clientes, DetalleVentas, Empleados, Paises y Productos. Faltan las filas de Ventas y Territorios para completar ese registro.

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

Los conteos de nombre y apellido coinciden, pero todavía no comprobamos que correspondan a los mismos clientes. Las reglas pueden afectar al mismo registro, por lo que no se suman estos conteos para calcular un total de filas con problemas.

### Tratamiento propuesto para el ETL

| Situación | Tratamiento |
|---|---|
| Venta sin vendedor | Conservar la venta y asociarla a un miembro de DimVendedor etiquetado como "Vendedor no informado". No inventar un empleado ni atribuirla a uno existente. |
| Cliente sin nombre o apellido | Mantener su ClienteID y una fila propia en DimCliente; completar los textos faltantes con etiquetas claras. No reunir distintos clientes en uno solo por faltar su nombre. |
| Producto sin color | Mantener el producto y usar "Sin color informado" como etiqueta. |
| Producto sin categoría | Mantener el producto y usar "Sin categoría informada" en el atributo de categoría. |
| Empleado sin territorio | Si se conserva ese atributo, identificarlo como "Territorio no informado". La geografía de la venta sigue viniendo de Ventas.TerritorioID. |

Estas reglas están propuestas para la implementación. El DW y el ETL aún no están construidos. Los controles ejecutados no justifican rechazar ventas por los datos descriptivos faltantes; debemos conservar las filas y sus importes, manteniendo trazabilidad de estos casos.

## Rango de fechas y códigos de empleados

Consultas ejecutadas por Frank Soto el 13 de octubre de 2026 en SQL Server 2019 (instancia FRANK-PC), sobre la base `BikeZ` restaurada. El rango de fechas corresponde al primer resultado de `02_revisar_calidad.sql`; los códigos corresponden al último resultado, agregado por Frank Soto a ese mismo script. Los demás controles de `02_revisar_calidad.sql` dieron los mismos valores registrados por Joaquín.

### Rango de fechas

| Campo | Primera fecha | Última fecha |
|---|---|---|
| Fecha de venta | 2015-07-01 | 2018-07-31 |
| Fecha de envío | 2015-07-08 | 2018-08-07 |

- Todas las fechas tienen hora `00:00:00`. Aunque las columnas son `datetime`, solo registran el día, por lo que en el modelo dimensional se pueden manejar como `date`.
- La dimensión Fecha debe cubrir desde el 2015-01-01 hasta el 2018-12-31, en años completos, para incluir tanto las fechas de venta como las de envío. La última fecha de envío (agosto de 2018) es posterior a la última venta.
- 2015 (desde julio) y 2018 (hasta julio) son años parciales. Comparar sus totales anuales con 2016 o 2017 distorsionaría el crecimiento, por lo que conviene medirlo por mes o comparando los mismos meses entre años.

### Códigos de género y estado civil

| Genero | EstadoCivil | Empleados |
|---|---|---:|
| F | M | 49 |
| M | M | 97 |
| F | S | 35 |
| M | S | 109 |
| **Total** | | **290** |

- Solo existen los códigos `F`/`M` en Genero y `M`/`S` en EstadoCivil, sin nulos. El total coincide con los 290 empleados de la tabla.
- La letra `M` tiene un significado distinto en cada columna: en Genero corresponde a masculino y en EstadoCivil a casado (*married*). Por eso cada columna necesita su propia regla de traducción en el ETL:
  - Genero: `F` → Femenino, `M` → Masculino.
  - EstadoCivil: `S` → Soltero(a), `M` → Casado(a).

## Pendientes del análisis

1. ~~Registrar el rango de fechas de `02_revisar_calidad.sql`.~~ Resuelto: ver "Rango de fechas y códigos de empleados".
2. Completar las claves primarias de Ventas y Territorios.
3. Comprobar el solapamiento de clientes sin nombre y sin apellido, y revisar espacios y longitudes de textos antes de construir las transformaciones. Los códigos de género y estado civil ya fueron revisados.

## Evidencia

- [Estructura y claves primarias](evidencias/01_exploracion_estructura.png): base, versión, columnas visibles y parte de las claves.

- [Relaciones y conteos parciales](evidencias/02_exploracion_conteos_parciales.png): relaciones visibles y conteos; algunos valores están cortados y faltan las últimas filas.

- [Conteos completos](evidencias/01_conteos_origen.tsv), [columnas](evidencias/01_columnas_origen.tsv), [relaciones](evidencias/01_claves_foraneas.tsv) y [claves primarias parciales](evidencias/01_claves_primarias_parciales.tsv): resultados copiados por Joaquín desde SSMS y compartidos en texto.

- [Controles de calidad](evidencias/02_calidad_origen.tsv) y [referencias inexistentes](evidencias/02_referencias_origen.tsv): resultados de la segunda consulta compartidos por Joaquín.

Evidencia: [rango de fechas](evidencias/02_rango_fechas.png) y [códigos de género y estado civil](evidencias/02_codigos_genero_estado_civil.png).

