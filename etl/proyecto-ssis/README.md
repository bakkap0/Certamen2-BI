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
| CargaCliente y CargaVendedor | Implementados por Frank con inserción y actualización tipo 1; pruebas en `docs/evidencias/` |
| CargaFecha | Implementado por Frank: 1.461 días de 2015 a 2018 y repetición sin duplicados |
| CargaTerritorio | Implementado y probado: inserción, repetición y actualización tipo 1 |
| CargarFactVentas | Implementado y probado individualmente; pendiente revisión y conciliación de Frank |
| CargaCompleta | Configurado y compilado; pendiente prueba completa |

Para probar un paquete, ejecutarlo individualmente. Las cinco dimensiones deben cargarse antes que FactVentas. El paquete principal las llama en orden y después ejecuta FactVentas; sus conexiones de éxito impiden continuar si una tarea falla. No ejecutar el script 03 sobre una base ya cargada: elimina y recrea las tablas.

Dejé los resultados en las pruebas de [Producto](../../docs/evidencias/05_validacion_producto.md), [Territorio](../../docs/evidencias/06_validacion_territorio.md) y [FactVentas](../../docs/evidencias/08_validacion_factventas.md). Para ejecutar con la extensión SSIS 4.0 usé Run64BitRuntime = False.
