# Plan de trabajo - Fase 1

Distribución acordada durante el avance. Las tareas futuras siguen pendientes hasta contar con código ejecutado y evidencia.

| Etapa | Joaquín Ramírez | Frank Soto | Estado o criterio para cerrar |
|---|---|---|---|
| Análisis del origen | Tablas, columnas, claves, calidad, clasificación de clientes y comprobación de horas | Verificar fechas y consultar códigos de empleados | Resultados registrados; revisar textos y tamaños al preparar el ETL |
| KPI y modelo | Revisar coherencia con los resultados del origen | Documentar KPI, Kimball, dimensiones, hechos e historia | Diseño documentado; revisión conjunta antes de crear las tablas |
| SQL dimensional | Ejecutó los scripts 03 y 04 y registró conteos, miembros desconocidos, claves y relaciones | Creó el script, el diagrama y pruebas de restricciones | Estructura creada en ambos equipos y verificación de Joaquín registrada |
| ETL | Producto implementado y probado; seguir con Territorio y participar en FactVentas | Cargas de Cliente, Vendedor y Fecha; revisar FactVentas | Conexiones y paquetes preparados; Producto validado, demás cargas pendientes |
| Validación | Conciliar registros e importes; participar en el backup | Revisar controles, repetición y restauración | Ambos ejecutan y comprenden las comprobaciones |
| Presentación | Explicar su trabajo y la solución completa | Explicar su trabajo y la solución completa | Demostración y ensayo de interrogación individual |

## Próximos pasos

1. Revisar e integrar la carga de Producto y sus pruebas mediante un Pull Request.
2. Joaquín continúa con Territorio y Frank con Cliente, Vendedor y Fecha.
3. Después integrar FactVentas, el paquete principal y las validaciones completas.

## Colaboración

Cada integrante usa su cuenta y registra cambios concretos. Los avances se revisan mediante Pull Requests. Se acuerda quién modifica cada paquete SSIS para evitar conflictos. El registro de aportes se completa con commits reales, y ambos deben comprender el proyecto completo.
