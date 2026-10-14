# Plan de trabajo - Fase 1

Estado actualizado el 14 de octubre de 2026.

| Etapa | Joaquín Ramírez | Frank Soto | Estado |
|---|---|---|---|
| Análisis | Exploración, calidad, clasificación de clientes y comprobación de horas | Verificación de fechas y códigos de empleados | Resultados documentados |
| KPI y modelo | Revisión de coherencia con los datos | KPI, Kimball, dimensiones, medidas y SCD tipo 1 | Diseño implementado |
| SQL dimensional | Ejecución de scripts y controles de estructura | Creación del DDL, diagrama y pruebas de restricciones | Modelo creado y comprobado |
| ETL | Producto, Territorio, FactVentas y CargaCompleta | Cliente, Vendedor, Fecha y documentación | Paquetes implementados; bloqueo de CargaCompleta confirmado como resuelto |
| Validación | Pruebas individuales, repetición y actualización de hechos | Conciliación, repetición de FactVentas y restauración | 14 controles en OK y respaldo restaurado de prueba |
| Informe | Revisión e incorporación de la documentación final | Aportes técnicos y resultados de conciliación y respaldo | Informe incorporado |
| Presentación | Explicar su trabajo y la solución completa | Explicar su trabajo y la solución completa | Se llevará a la exposición de la próxima semana; archivo aún fuera del repositorio |

## Preparación de la exposición

Revisar el informe en Word para comprobar paginación e índice, preparar la presentación y ensayar la demostración. Ambos deben explicar el grano del hecho, las claves sustitutas, los datos faltantes, los Lookup, las actualizaciones y las cifras de conciliación.

## Colaboración

Cada integrante utiliza su cuenta y registra cambios concretos. Los avances se revisan mediante Pull Requests. El registro de [aportes](aportes.md) conserva las referencias a los trabajos realizados. El [cierre de fase](evidencias/10_cierre_fase1.md) distingue las capturas existentes de la confirmación posterior sobre CargaCompleta.
