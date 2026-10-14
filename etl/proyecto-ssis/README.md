# Proyecto SSIS

Abrir `BikeZ_ETL.sln` en Visual Studio Community 2019 con SQL Server Integration Services Projects. El destino del proyecto es SQL Server 2019 y la protección es DontSaveSensitive.

## Conexiones

- `Origen_BikeZ`: lee BikeZ.
- `Destino_BikeZ_DW`: carga BikeZ_DW.
- Ambas usan autenticación de Windows y el parámetro de proyecto `ServidorSQL`.

Joaquín usa `BAKKAPO\BIT2019` y Frank `FRANK-PC`. Cada uno configura su servidor para las pruebas locales. Las conexiones utilizan SQL Server Native Client 11.0, que debe estar instalado en el equipo.

## Paquetes

| Paquete | Estado |
|---|---|
| CargaProducto | Implementado y probado: inserción, repetición y actualización tipo 1 |
| CargaCliente, CargaVendedor y CargaFecha | Preparados para el trabajo de Frank |
| CargaTerritorio | Preparado para el trabajo de Joaquín |
| CargarFactVentas | Pendiente de desarrollo conjunto |
| CargaCompleta | Pendiente de conectar las cargas en orden |

Para probar Producto, ejecutar únicamente `CargaProducto.dtsx`. Las dimensiones deben cargarse antes que FactVentas. No ejecutar el script 03 sobre una base ya cargada: elimina y recrea las tablas.

Dejé los resultados en las [pruebas de Producto](../../docs/evidencias/05_validacion_producto.md). Para ejecutar el paquete con la extensión SSIS 4.0 usé Run64BitRuntime = False.
