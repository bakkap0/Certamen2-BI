# Plan de trabajo - Fase 1

Distribución acordada durante el avance. Las tareas futuras siguen pendientes hasta contar con código ejecutado y evidencia.

| Etapa | Joaquín Ramírez | Frank Soto | Estado o criterio para cerrar |
|---|---|---|---|
| Análisis del origen | Tablas, columnas, claves, calidad, clasificación de clientes y comprobación de horas | Verificar fechas y consultar códigos de empleados | Resultados registrados; revisar textos y tamaños al preparar el ETL |
| KPI y modelo | Revisar coherencia con los resultados del origen | Documentar KPI, Kimball, dimensiones, hechos e historia | Diseño documentado; revisión conjunta antes de crear las tablas |
| SQL dimensional | Ejecutar y revisar el script en su equipo | Crear 03_crear_modelo_dimensional.sql y diagrama | DW creado en SQL Server 2019 y coherente con el diseño |
| ETL | Cargas de Producto y Territorio; participar en FactVentas | Cargas de Cliente, Vendedor y Fecha; revisar FactVentas | Asignación propuesta para la siguiente etapa; ETL todavía no implementado |
| Validación | Conciliar registros e importes; participar en el backup | Revisar controles, repetición y restauración | Ambos ejecutan y comprenden las comprobaciones |
| Presentación | Explicar su trabajo y la solución completa | Explicar su trabajo y la solución completa | Demostración y ensayo de interrogación individual |

## Próximos pasos

1. Revisar e integrar a main la rama que conserva el análisis de ambos y la comprobación de horas.
2. Frank implementa el modelo y prepara su diagrama; Joaquín prueba el script.
3. Ambos revisan el diseño implementado antes de construir SSIS.

## Colaboración

Cada integrante usa su cuenta y registra cambios concretos. Los avances se revisan mediante Pull Requests. Se acuerda quién modifica cada paquete SSIS para evitar conflictos. El registro de aportes se completa con commits reales, y ambos deben comprender el proyecto completo.
