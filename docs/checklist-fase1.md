# Lista de entrega — Fase 1

Esta lista recoge los entregables y controles de la pauta. Marcar una casilla únicamente cuando exista evidencia verificable en la versión presentada.

## Equipo y repositorio
- [x] Repositorio creado.
- [x] Nombres y sección registrados.
- [x] Usuario GitHub de Frank registrado y colaboración habilitada.
- [x] Aportes sustantivos de ambos identificables en Git.
- [x] Repositorio público y accesible para consulta; comprobar el enlace enviado al docente.
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
- [x] CargaCliente probada: primera carga, repetición y actualización tipo 1; evidencias `05_carga_cliente_*.png`.
- [x] CargaVendedor probada: primera carga, traducciones, repetición y actualización tipo 1; evidencias `06_*vendedor*.png`.
- [x] CargaFecha probada: 1.461 días, repetición sin duplicados y año bisiesto; evidencias `07_*.png`.
- [x] FactVentas probada individualmente: carga, repetición y actualización de un detalle; resultados en `evidencias/08_validacion_factventas.md`.
- [x] CargaCompleta configurada y compilada con las cinco dimensiones y FactVentas.
- [x] CargaCompleta ejecutada; bloqueo confirmado como resuelto por Joaquín el 14-10-2026. Alcance en `evidencias/10_cierre_fase1.md`.
- [x] Extracción, transformaciones y carga implementadas y explicadas.
- [x] Tratamiento de errores y reglas de calidad documentados.
- [x] Conteos, claves, cantidades y montos conciliados entre origen y DW.
- [x] Segunda ejecución probada sin duplicación de datos.
- [x] Evidencia de carga real guardada.
- [x] Backup dimensional con datos correspondiente a la versión demostrada.
- [x] Backup restaurado de prueba y resultados verificados.

## Presentación y comprensión
- [ ] Presentación final del equipo incorporada. El equipo la llevará a la exposición de la próxima semana; no está adjunta al repositorio.
- [x] Informe incorporado con portada, índice, introducción, desarrollo, conclusiones y bibliografía; redacción en tercera persona. Archivo en `informe/InformeBIRamirezSoto.docx`.
- [ ] Paginación e índice del informe comprobados en Word.
- [ ] Ambos pueden demostrar y explicar toda la Fase 1.

No se exige todavía cubo OLAP ni Power BI. Un proyecto SSIS vacío, el backup transaccional o capturas aisladas no sustituyen los entregables implementados.
