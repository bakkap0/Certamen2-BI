# Lista de entrega — Fase 1

Esta lista recoge los entregables y controles de la pauta. Marcar una casilla únicamente cuando exista evidencia verificable en la versión presentada.

## Equipo y repositorio
- [x] Repositorio creado.
- [x] Nombres y sección registrados.
- [ ] Usuario GitHub de Frank registrado y colaboración habilitada.
- [x] Aportes sustantivos de ambos identificables en Git.
- [ ] Repositorio accesible para el docente.
- [x] README actualizado para el avance actual; volver a revisar antes de presentar.

## Análisis y diseño
- [x] Esquema del origen, conteos y controles iniciales de calidad documentados con resultados reales.
- [x] KPI definidos y justificados.
- [x] Cuatro pasos de Kimball documentados y contrastados con el origen.
- [x] Diagrama coherente con el modelo implementado; revisar si cambia el diseño.
- [x] DDL de dimensiones, hechos, claves y relaciones ejecutado en SQL Server 2019.
- [x] Verificación de miembros desconocidos, claves y relaciones con el script 04 en el equipo de Joaquín.

## ETL y validación
- [x] Proyecto SSIS guardado, compartible y compilado para SQL Server 2019.
- [x] CargaProducto probada: primera carga, repetición y actualización tipo 1; resultados en `evidencias/05_validacion_producto.md`.
- [x] CargaTerritorio probada: primera carga, repetición y actualización tipo 1; resultados en `evidencias/06_validacion_territorio.md`.
- [ ] Extracción, transformaciones y carga implementadas y explicadas.
- [ ] Tratamiento de errores y reglas de calidad documentados.
- [ ] Conteos, claves, cantidades y montos conciliados entre origen y DW.
- [ ] Segunda ejecución probada sin duplicación de datos.
- [ ] Evidencia de carga real guardada.
- [ ] Backup dimensional con datos correspondiente a la versión demostrada.
- [ ] Backup restaurado de prueba y resultados verificados.

## Presentación y comprensión
- [ ] Presentación final del equipo incorporada.
- [ ] Informe del caso completado con portada, índice, introducción, desarrollo, conclusiones y bibliografía.
- [ ] Ambos pueden demostrar y explicar toda la Fase 1.

No se exige todavía cubo OLAP ni Power BI. Un proyecto SSIS vacío, el backup transaccional o capturas aisladas no sustituyen los entregables implementados.
