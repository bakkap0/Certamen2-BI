# Evidencias de ejecución

Los archivos de esta carpeta contienen resultados del análisis, controles del modelo y pruebas del ETL.

| Evidencia | Alcance |
|---|---|
| Archivos 01 y 02 | Conteos, estructura, claves, fechas y calidad del origen |
| Archivos 03 y 04 | Creación del modelo, restricciones, miembros desconocidos y relaciones |
| 05_validacion_producto.md y capturas 05 | Producto, Cliente y casos de NombreCompleto |
| 06_validacion_territorio.md y capturas 06 | Territorio y Vendedor |
| Capturas 07 | Calendario, repetición y comprobaciones de Fecha |
| 08_validacion_factventas.md | Pruebas individuales, repetición y actualización controlada de un detalle |
| 09_conciliacion_completa.png | Los 14 controles de conciliación en OK |
| 09_factventas_segunda.png | Repetición individual de FactVentas sin inserciones ni actualizaciones |
| 10_cierre_fase1.md | Confirmación del cierre de CargaCompleta y estado del informe, respaldo y presentación |

La prueba de restauración está documentada en [database/backup/README.md](../../database/backup/README.md). Las cifras de control son 121.317 detalles, 31.465 ventas distintas, 274.914 unidades y 110.373.889,3134 de importe total.

Las pruebas iniciales conservan el alcance que tenían cuando se realizaron. Su estado posterior se encuentra en [el cierre de fase](10_cierre_fase1.md). Las capturas complementan los scripts y paquetes ejecutables; no se incluyen contraseñas ni datos personales fila por fila.
