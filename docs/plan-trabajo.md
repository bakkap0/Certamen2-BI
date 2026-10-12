# Plan de trabajo — dos integrantes

Distribución propuesta para acordar entre ambos. Cada uno debe hacer avances de SQL, ETL y documentación, y revisar cambios del otro. Los nombres en esta tabla no significan que las tareas estén realizadas.

| Etapa | Joaquín Ramírez — propuesta | Frank Soto — propuesta | Criterio para cerrar |
|---|---|---|---|
| 1. Análisis | Explorar tablas, tipos y conteos; documentar entorno | Revisar calidad, relaciones y significado comercial | Resultados reales y hallazgos explicados por ambos |
| 2. KPI y Kimball | Proponer medidas, fórmulas y consultas de comprobación | Justificar indicadores, grano y dimensiones; preparar diagrama | Diseño coherente revisado entre ambos |
| 3. SQL dimensional | DimFecha, DimCliente y restricciones de FactVentas | DimProducto, DimVendedor y DimTerritorio; revisar relaciones | Modelo creado y DDL reproducible |
| 4. SSIS | Flujos de fecha/cliente y hecho; trazabilidad de carga | Flujos de producto/vendedor/territorio; reglas de calidad | Paquete completo ejecuta y ambos explican transformaciones |
| 5. Validación | Conciliar claves, filas y montos; generar backup | Verificar calidad, repetición y restauración del backup | Evidencia de integridad y restauración correcta |
| 6. Presentación | Explicar modelo y ejecución; revisar exposición del compañero | Explicar KPI y controles; revisar exposición del compañero | Ambos pueden responder sobre toda la solución |

## Forma de registrar avances
Cada cambio se registra al realizarlo, desde la cuenta de su autor, con un mensaje concreto. Una tarea puede requerir varios commits si hay avances sustantivos; no se fija una cuota artificial. Un PR puede agruparlos y facilitar revisión.

## Próxima tarea
1. Ambos clonan el repositorio.
2. Frank acepta la invitación como colaborador y registra su usuario.
3. Joaquín ejecuta la consulta de exploración y documenta los resultados.
4. Frank prepara las consultas de calidad sobre el esquema confirmado.
5. Ambos revisan los hallazgos antes de aprobar el modelo dimensional.

No completar de una vez todas las carpetas con archivos no probados: el README debe mostrar el avance real. El equipo revisa y entiende cualquier material preparado con asistencia antes de incorporarlo a la solución.
