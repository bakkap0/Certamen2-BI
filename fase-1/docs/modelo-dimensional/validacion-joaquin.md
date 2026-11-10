# Verificación del modelo en el equipo de Joaquín

Joaquín ejecutó `03_crear_modelo_dimensional.sql` en su instancia `BAKKAPO\BIT2019`. SSMS mostró cuatro mensajes de una fila afectada y finalizó el 13 de octubre de 2026 a las 12:42:29, hora de Chile.

Después ejecutó la consulta de conteos sobre BikeZ_DW y compartió estos resultados:

| Tabla | Filas |
|---|---:|
| DimProducto | 1 |
| DimCliente | 1 |
| DimVendedor | 1 |
| DimTerritorio | 1 |
| DimFecha | 0 |
| FactVentas | 0 |

Los conteos coinciden con el estado inicial previsto por el script 03: cuatro dimensiones con un miembro desconocido, calendario sin cargar y hecho sin ventas cargadas. Se conserva el [resultado copiado desde SSMS](../evidencias/04_conteo_modelo_joaquin.tsv).

## Comprobaciones ejecutadas

Joaquín ejecutó el script `database/scripts/04_verificar_modelo.sql` y compartió los cuatro resultados desde SSMS. El script solo consulta información:

1. Los conteos de las seis tablas coinciden con los registrados arriba.
2. Aparecen cuatro miembros desconocidos, con clave sustituta e ID de origen iguales a -1, y sus etiquetas de no informado.
3. Se obtienen 12 filas de columnas de claves. FactVentas tiene la PK compuesta por VentaID, orden 1, y DetalleVentaID, orden 2. Las claves de Producto, Cliente, Vendedor y Territorio tienen EsIdentity = 1; FechaKey no es una identidad. Los identificadores de origen y la fecha tienen sus restricciones únicas.
4. Se obtienen seis relaciones del hecho: Cliente, Producto, Vendedor, Territorio y los dos roles de Fecha. Todas tienen Deshabilitada = 0 y NoVerificada = 0.

Se guardaron los resultados copiados de SSMS: [miembros desconocidos](../evidencias/04_miembros_desconocidos_joaquin.tsv), [claves](../evidencias/04_claves_modelo_joaquin.tsv) y [relaciones](../evidencias/04_relaciones_modelo_joaquin.tsv).

La estructura consultada en el equipo de Joaquín coincide con el diseño. Las capturas de pruebas de inserción y rechazo de restricciones de Frank se conservan en `docs/evidencias/03_*.png`; esas ejecuciones son distintas de esta comprobación de metadatos y no se atribuyen a Joaquín.

## Alcance

Esta verificación corresponde a la preparación de la estructura. Todavía no se ejecutó la carga SSIS ni se validaron sus cantidades e importes. El script 03 elimina y recrea las tablas: se usa para preparar el modelo y no para verificarlo después de cargar datos.

## Estado posterior al registro inicial

Las observaciones anteriores conservan el alcance de la prueba original. La conciliación, el respaldo y la confirmación de cierre de CargaCompleta ya están registrados en [el cierre de la Fase 1](../evidencias/10_cierre_fase1.md), actualizado el 14 de octubre de 2026.
