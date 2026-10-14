# Proceso ETL — Bike Z

Proyecto SSIS: `etl/proyecto-ssis/BikeZ_ETL.sln` (Visual Studio 2019, SQL Server 2019).
Origen: base transaccional `BikeZ`. Destino: modelo dimensional `BikeZ_DW` creado con `database/scripts/03_crear_modelo_dimensional.sql`.

## Conexiones y configuración

| Elemento | Descripción |
|---|---|
| `Origen_BikeZ` | Conexión de lectura a BikeZ |
| `Destino_BikeZ_DW` | Conexión de carga a BikeZ_DW |
| `ServidorSQL` | Parámetro del proyecto que define el servidor de ambas conexiones mediante una expresión. Cada integrante lo ajusta a su instancia local |
| `Run64BitRuntime = False` | Configuración local de depuración necesaria para ejecutar los paquetes con la extensión SSIS instalada (evita el error COM `IDTSApplication160`) |

## Orden de ejecución

El paquete `CargaCompleta.dtsx` ejecuta las cargas en este orden:

`01 Fecha → 02 Producto → 03 Cliente → 04 Territorio → 05 Vendedor → 06 FactVentas`

Las dimensiones se cargan primero porque FactVentas necesita sus claves sustitutas para resolver cada venta mediante Lookup.

## Patrón común de las dimensiones

Todas las dimensiones, salvo Fecha, siguen el mismo flujo:

1. **Origen:** consulta a las tablas de BikeZ.
2. **Derived Column:** limpieza, textos de relleno y traducciones.
3. **Lookup por la clave del origen:** decide si el registro ya existe en el DW.
   - **No Match →** se inserta como registro nuevo.
   - **Match → Conditional Split →** si algún atributo cambió, un **OLE DB Command** hace el UPDATE; si no, la fila se descarta.

Consecuencias del diseño:

- **Ejecutar el paquete dos veces no duplica datos:** en la segunda ejecución todos los registros salen por Match y ninguno se inserta.
- **SCD tipo 1:** si un atributo cambió en el origen, se sobrescribe en la misma fila. La clave sustituta no cambia.
- **Miembro -1:** lo crea el script del modelo. Los Lookup lo excluyen (`WHERE Key > 0`) y las cargas no lo modifican.

## Paquetes

| Paquete | Origen | Transformaciones y reglas | Responsable |
|---|---|---|---|
| CargaFecha | Consulta que genera los días entre 2015-01-01 y 2018-12-31 | FechaKey AAAAMMDD, año, semestre, trimestre, mes y día; nombres en español; día de la semana con lunes = 1, independiente del idioma del servidor. Sin actualización, porque un día del calendario no cambia | Frank |
| CargaProducto | `Productos` LEFT JOIN `Categorias` | Color faltante → "Sin color informado"; categoría faltante → "Sin categoría informada". La comparación de cambios controla CategoriaID nulo | Joaquín |
| CargaCliente | `Clientes` | Nombre y apellido faltantes → "Sin nombre informado" / "Sin apellido informado". NombreCompleto: ambos datos → "Nombre Apellido"; solo uno → el dato disponible; ninguno → "Cliente ‹ID›" | Frank |
| CargaTerritorio | `Territorios` INNER JOIN `Paises` | INNER JOIN porque todos los territorios tienen país (verificado en el análisis). Desnormaliza país y grupo | Joaquín |
| CargaVendedor | `Empleados` LEFT JOIN `Territorios` | "Vendedor ‹ID›"; Genero F/M → Femenino/Masculino y EstadoCivil S/M → Soltero(a)/Casado(a), como columnas nuevas porque el origen es nchar(1); territorio faltante → "Territorio no informado". LEFT JOIN para no perder los 275 empleados sin territorio, entre ellos 4 que registran ventas | Frank |
| CargarFactVentas | `Ventas` JOIN `DetalleVentas` | FechaVentaKey y FechaEnvioKey AAAAMMDD; ImporteVenta = Cantidad × PrecioUnitario en decimal(19,4); DiasDespacho; VendedorID y TerritorioID nulos → -1. Cuatro Lookups resuelven las claves sustitutas y dos validan las fechas contra DimFecha. Si una referencia no existe, el paquete falla en vez de cargar un dato incorrecto (el análisis no encontró referencias inexistentes). Un Lookup por VentaID + DetalleVentaID inserta los detalles nuevos y actualiza solo los que cambiaron | Joaquín, con revisión de Frank |

## Reglas de calidad aplicadas

| Situación del origen | Tratamiento en el ETL |
|---|---|
| Venta sin vendedor (27.658 ventas) | Se asocia al miembro -1 "Vendedor no informado" |
| Cliente sin nombre ni apellido (9.546) | Conserva su fila; NombreCompleto = "Cliente ‹ID›" |
| Producto sin color (248) o sin categoría (209) | Conserva su fila con el texto de relleno correspondiente |
| Empleado sin territorio (275) | TerritorioAsignado = "Territorio no informado" |
| Códigos de una letra | Se traducen a texto; la `M` significa algo distinto en Genero y en EstadoCivil |

Ninguna regla elimina filas: todas las ventas y sus montos llegan al DW.

## Validación

| Prueba | Dónde |
|---|---|
| Primera carga, repetición sin duplicados y actualización tipo 1 de cada dimensión | `docs/evidencias/05_*` a `07_*` |
| Los cuatro casos de NombreCompleto | `docs/evidencias/05_nombre_completo_*` |
| Conciliación origen vs. DW: filas, ventas distintas, cantidades, montos y claves | `database/scripts/05_conciliar_carga.sql` |
| Dimensiones conciliadas (controles 1 a 6 en OK) | `docs/evidencias/08_conciliacion_dimensiones.png` |
| Carga completa: los 14 controles de conciliación en OK, monto total 110.373.889,3134 en origen y DW | `docs/evidencias/09_conciliacion_completa.png` |
| Repetición de FactVentas: 121.317 coincidencias, 0 insertados y 0 actualizados; la conciliación sigue en OK | `docs/evidencias/09_factventas_segunda.png`, `09_conciliacion_segunda.png` |

Cifras de control del origen para validar FactVentas: **121.317 líneas**, **31.465 ventas**, **274.914 unidades** y un monto total de **110.373.889,3134**. Las líneas sin vendedor son **60.397**.



## Observación

En el equipo de Frank, la segunda ejecución consecutiva de `CargaCompleta` quedó detenida dentro de CargarFactVentas, sin actividad en SQL Server, y dejó bloqueado el archivo `.ispac`. Ejecutado por separado, CargarFactVentas repite la carga correctamente. Queda por revisar la ejecución repetida de CargaCompleta (por ejemplo, con `ExecuteOutOfProcess` en las tareas Execute Package).