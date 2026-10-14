# Validación de CargaTerritorio

Ejecuté las pruebas en SQL Server 2019, instancia `BAKKAPO\BIT2019`, con origen `BikeZ` y destino `BikeZ_DW`. Revisé los resultados en SSMS y comprobé la repetición y la actualización durante la ejecución local.

| Prueba | Resultado |
|---|---|
| Primera carga | Cargué los 10 territorios y comprobé que DimTerritorio quedó con 11 filas, incluyendo el miembro -1. |
| Segunda ejecución | Volví a ejecutar el paquete y comprobé que los conteos se mantuvieron en 11 filas, 10 territorios del origen y 1 miembro desconocido. |
| Actualización SCD tipo 1 | Cambié temporalmente el nombre del TerritorioID 1 a "Prueba SCD1" en el DW. Ejecuté el paquete y comprobé que volvió a "Northwest", conservó su TerritorioKey y el total siguió en 11. |

Hice el cambio temporal en el DW y mantuve los datos de BikeZ. Al terminar la prueba, comprobé que el territorio quedó nuevamente con el nombre del origen.

## Cómo funciona

El origen une Territorios y Paises para obtener el país y el grupo de cada territorio. Usé INNER JOIN porque el análisis comprobó que todos los territorios tienen un país existente. El Lookup busca por TerritorioID: los nuevos se insertan y los existentes pasan por una división condicional que compara Territorio, PaisID, Pais y Grupo. Si alguno cambió, el comando OLE DB actualiza la fila por TerritorioKey conservando esa clave.

## Alcance

Estas pruebas corresponden solo a DimTerritorio. Ya comprobé Producto y Territorio; falta integrar las demás dimensiones, FactVentas, el paquete principal y las validaciones completas.

## Estado posterior al registro inicial

Las observaciones anteriores conservan el alcance de la prueba original. La conciliación, el respaldo y la confirmación de cierre de CargaCompleta ya están registrados en [el cierre de la Fase 1](10_cierre_fase1.md), actualizado el 14 de octubre de 2026.
