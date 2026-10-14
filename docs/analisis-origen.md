# Análisis del origen BikeZ

**Estado:** se integraron la exploración y los controles de Joaquín con la revisión de fechas y códigos de empleados de Frank. Están registrados los conteos, las claves de las 9 tablas de negocio, los datos faltantes y la clasificación de clientes. Joaquín ejecutó la comprobación de horas: ambos conteos dieron 0.

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

El rango se incorporó el 13 de octubre de 2026 a partir de la captura compartida por Joaquín. Frank comprobó el mismo rango en su equipo. Para el modelo se propone generar años completos del 2015-01-01 al 2018-12-31, que incluyen todas las fechas observadas. Los años extremos tienen ventas para una parte del año; esto se debe considerar al comparar períodos.

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

## Códigos de género y estado civil

Frank ejecutó la consulta de códigos el 13 de octubre de 2026 en su instancia FRANK-PC. La consulta se conservó en el script 02 como resultado 5, después de la clasificación de clientes de Joaquín.

| Genero | EstadoCivil | Empleados |
|---|---|---:|
| F | M | 49 |
| F | S | 35 |
| M | M | 97 |
| M | S | 109 |
| Total | | 290 |

Los cuatro grupos suman los 290 empleados del origen. Solo se observaron F/M en Genero y M/S en EstadoCivil, sin nulos en ese resultado. Las traducciones propuestas son Femenino/Masculino y Casado(a)/Soltero(a), respectivamente. La M necesita una regla distinta según la columna.

Frank también verificó el rango de fechas y registró que los controles generales coincidían con los obtenidos por Joaquín. Sus capturas se conservan junto con las de Joaquín.

## Comprobación de horas

Joaquín ejecutó el resultado 6 de `02_revisar_calidad.sql` y compartió los valores desde SSMS el 13 de octubre de 2026.

| Control | Filas |
|---|---:|
| VentasConHora | 0 |
| EnviosConHora | 0 |

La consulta cuenta fechas informadas cuya hora es distinta de `00:00:00`. Ambos resultados confirman que las fechas de venta y envío informadas están a medianoche. Los controles anteriores también dieron 0 ventas sin fecha de envío. Para este origen podemos trabajar al nivel de día mediante una dimensión Fecha de tipo `date`, con roles de venta y envío.

## Orden de resultados del script 02

1. Rango de fechas.
2. Conteos de situaciones por revisar.
3. Referencias inexistentes.
4. Clasificación de clientes por nombre y apellido.
5. Códigos de género y estado civil.
6. Ventas y envíos con hora distinta de medianoche: ejecutado; ambos conteos dieron 0.

## Empleados que registran ventas

Consulta agregada por Frank Soto al final de `02_revisar_calidad.sql`.

De los 290 empleados, solo **18 aparecen como vendedor** en `Ventas.VendedorID`. El resto pertenece a otras áreas de la empresa (ingeniería, marketing, producción, etc.).

| Sales Representative | 14 | 3.703 | Sí |
| Gerentes de ventas regionales (North American, European y Pacific Sales Manager) | 3 | 103 | No |
| Design Engineer (EmpleadoID 6) | 1 | 1 | No |
| **Total** | **18** | **3.807** | |
El total de 3.807 ventas coincide con las ventas con vendedor informado (31.465 − 27.658).

- Los gerentes regionales no tienen un territorio asignado porque están a cargo de varias regiones, pero sí registran ventas.
- El empleado 6 es ingeniero de diseño y registra una venta. Puede ser un error de registro en el origen; se conserva tal cual, porque el DW debe reflejar los datos de origen.
- Tener territorio no define a un vendedor: el empleado 1 (Chief Executive Officer) tiene territorio asignado y no registra ventas.

**Implicancia para el ETL:** DimVendedor se carga con `LEFT JOIN` a `Territorios`. Con `INNER JOIN` se perderían los 4 vendedores sin territorio y sus ventas quedarían asociadas a "Vendedor no informado", aunque el vendedor sí está identificado.

Evidencia: [vendedores con ventas](evidencias/02_vendedores_con_ventas.png).

## Pendientes del análisis

- Revisar espacios y longitudes antes de construir las transformaciones que los utilicen. Los tamaños del destino deben admitir las etiquetas: por ejemplo, Color del origen permite 15 caracteres, pero "Sin color informado" ocupa 19.
- Mantener la comprobación de horas en futuras cargas para detectar cambios en el origen y revisar el tratamiento si fuera necesario.

## Evidencia
- [Estructura y claves primarias](evidencias/01_exploracion_estructura.png): base, versión, columnas visibles y parte de las claves.
- [Relaciones y conteos parciales](evidencias/02_exploracion_conteos_parciales.png): relaciones visibles y conteos; algunos valores están cortados y faltan las últimas filas.
- [Conteos completos](evidencias/01_conteos_origen.tsv), [columnas](evidencias/01_columnas_origen.tsv), [relaciones](evidencias/01_claves_foraneas.tsv) y [claves primarias parciales](evidencias/01_claves_primarias_parciales.tsv): resultados copiados por Joaquín desde SSMS y compartidos en texto.
- [Columnas clave de Ventas y Territorios](evidencias/01_claves_primarias_adicionales.tsv) y [captura de confirmación](evidencias/04_exploracion_claves_primarias.png): completan las columnas de las claves primarias de negocio. Los nombres generados de las restricciones se conservan en la captura, sin transcribir valores que aparecen cortados.
- [Controles de calidad](evidencias/02_calidad_origen.tsv) y [referencias inexistentes](evidencias/02_referencias_origen.tsv): resultados de la segunda consulta compartidos por Joaquín.
- [Rango de fechas](evidencias/02_rango_fechas.tsv) y [captura del rango](evidencias/03_exploracion_rango_fechas.png): resultado de PrimeraVenta, UltimaVenta, PrimerEnvio y UltimoEnvio compartido por Joaquín.
- [Clasificación de clientes](evidencias/02_nombres_clientes.tsv) y [captura de clientes](evidencias/05_exploracion_nombres_clientes.png): resultado 4, que confirma la coincidencia de clientes sin nombre y sin apellido.
- [Rango verificado por Frank](evidencias/02_rango_fechas.png) y [códigos de empleados](evidencias/02_codigos_genero_estado_civil.png): capturas aportadas por Frank desde su instancia.
- [Horas del origen](evidencias/02_horas_origen.tsv): resultado 6 compartido por Joaquín en texto desde SSMS; 0 ventas y 0 envíos con hora distinta de medianoche.

Joaquín ejecutó y documentó la exploración, los controles y la clasificación de clientes. Frank verificó el rango de fechas y agregó la consulta y evidencia de códigos. Los commits de ambos se registran en [aportes.md](aportes.md). El DW y el ETL siguen pendientes de implementar.
