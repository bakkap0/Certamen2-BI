# Análisis del origen BikeZ

**Estado:** pendiente de incorporar resultados de ejecución. La restauración fue informada como correcta por Joaquín; todavía no se incluyen resultados medidos en este documento.

Ejecutar `database/scripts/01_explorar_origen.sql` en SSMS y completar:

| Dato | Resultado real |
|---|---|
| Fecha de ejecución | Pendiente |
| Motor y edición | Pendiente |
| Nombre de base | Pendiente |
| Tablas y conteos | Pendiente; adjuntar exportación de resultados |
| PK y FK confirmadas | Pendiente |
| Diferencias con el esquema del caso | Pendiente |

## Hallazgos y decisiones
Documentar cada hallazgo con su consulta, resultado e implicación para KPI o modelo. No reemplazar los pendientes por suposiciones del PDF.

En el siguiente avance revisar:
1. Rango de fechas de venta y envío; fechas de envío anteriores a la venta.
2. Duplicados de la clave `(VentaID, DetalleVentaID)`.
3. Referencias inexistentes, detalles sin cabecera y ventas sin detalle.
4. NULL en claves, fechas, cantidades, precios y atributos.
5. Cantidades no positivas, precios negativos, escala y precisión reales.
6. Longitudes y espacios en descripciones de productos, categorías y territorios.

Si existen devoluciones legítimas, una cantidad negativa no debe eliminarse automáticamente: se debe acordar cómo modelarla. El perfilamiento define las reglas del ETL.

## Evidencia
Guardar resultados y capturas en `docs/evidencias/` y enlazarlos aquí con una explicación. Indicar quién ejecutó el análisis y enlazar su commit/PR real. La consulta preparada no equivale a consulta ejecutada.
