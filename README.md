# Certamen 2 - Inteligencia de Negocios

**Caso 2: Bike Z · Sección 300**

**Integrantes:** Joaquín Ramírez y Frank Soto. **Profesor:** Hernan Saavedra.

## Sobre el proyecto

Bike Z necesita analizar sus ventas para apoyar sus decisiones comerciales. En la Fase 1 construimos un modelo estrella en SQL Server y un ETL en SSIS para analizar las ventas por fecha, producto, categoría, cliente, vendedor y territorio. El cubo OLAP y Power BI corresponden a la Fase 2.

## Estado de la Fase 1

El modelo, las cinco dimensiones, FactVentas y el paquete CargaCompleta están implementados. La conciliación registrada compara origen y DW con los 14 controles en OK. El respaldo dimensional está disponible y Frank documentó su restauración de prueba. El 14 de octubre de 2026, Joaquín confirmó que el bloqueo de CargaCompleta quedó resuelto.

| Control | Origen | DW |
|---|---:|---:|
| Detalles de venta | 121.317 | 121.317 |
| Ventas distintas | 31.465 | 31.465 |
| Unidades | 274.914 | 274.914 |
| Importe total | 110.373.889,3134 | 110.373.889,3134 |

La repetición individual de FactVentas registra 121.317 coincidencias, cero inserciones y cero actualizaciones. Los resultados y el alcance de las comprobaciones están en [evidencias](docs/evidencias/README.md).

La presentación se llevará al momento de la exposición de la próxima semana; su archivo aún no está incorporado al repositorio. El cierre de la documentación está en [10_cierre_fase1.md](docs/evidencias/10_cierre_fase1.md).

## Entregables y documentación

- [Informe en Word](docs/informe/InformeBIRamirezSoto.docx).
- [Análisis del origen](docs/analisis-origen.md) y [diseño con Kimball](docs/modelo-dimensional/propuesta.md).
- [Diagrama dimensional](docs/modelo-dimensional/diagrama.png).
- [Script de creación del modelo](database/scripts/03_crear_modelo_dimensional.sql).
- [Solución SSIS](etl/proyecto-ssis/BikeZ_ETL.sln) y [documentación del ETL](docs/proceso-etl.md).
- [Conciliación de la carga](database/scripts/05_conciliar_carga.sql).
- [Respaldo BikeZ_DW.bak](database/backup/BikeZ_DW.bak) e [instrucciones de restauración](database/backup/README.md).
- [Aportes del equipo](docs/aportes.md), [plan de trabajo](docs/plan-trabajo.md) y [checklist](docs/checklist-fase1.md).

## Indicadores definidos

| KPI | Cálculo | Utilidad |
|---|---|---|
| Monto de ventas | Suma de cantidad × precio unitario | Comparar períodos, productos, categorías y territorios |
| Crecimiento mensual | (Monto del mes − monto anterior) / monto anterior × 100 | Identificar aumentos o caídas |
| Ventas con vendedor informado | Ventas distintas identificadas / ventas distintas totales × 100 | Medir la cobertura del dato de vendedor |
| Ticket promedio | Monto total / ventas distintas | Conocer el monto promedio por compra |
| Días promedio de despacho | Promedio de días entre venta y envío, una vez por venta | Medir el tiempo hasta el envío |

Si el mes anterior no existe o su monto es cero, el crecimiento queda sin calcular. Los años 2015 y 2018 tienen ventas en parte del año. Los días se promedian por VentaID, no por detalle ni con AVG(DISTINCT DiasDespacho). No se calcula rentabilidad ni inventario porque la base no incluye costos ni stock; tampoco identifica la moneda de los montos.

## Modelo y carga

El grano es una fila por VentaID y DetalleVentaID. FactVentas se relaciona con Producto, Cliente, Vendedor y Territorio, y con Fecha mediante dos roles: venta y envío. Categoría y país se integran en sus dimensiones. Las cuatro dimensiones con claves sustitutas incluyen un miembro desconocido con clave -1.

CargaCompleta ejecuta: **Fecha → Producto → Cliente → Territorio → Vendedor → FactVentas**. Las cargas insertan registros nuevos y actualizan los que cambian; las dimensiones siguen SCD tipo 1 y conservan su clave sustituta.

## Cómo revisar o ejecutar

1. Para revisar directamente el DW cargado, restaurar [BikeZ_DW.bak](database/backup/BikeZ_DW.bak) siguiendo las instrucciones del respaldo.
2. Para ejecutar el ETL, restaurar el BikeZ.bak del caso como BikeZ en SQL Server 2019 y disponer de BikeZ_DW. En una instalación inicial puede usarse el script 03; elimina y recrea las tablas, por lo que no debe ejecutarse sobre una carga que se quiera conservar.
3. Abrir BikeZ_ETL.sln en Visual Studio 2019 con SSIS y configurar el parámetro ServidorSQL con la instancia local. Las conexiones usan autenticación de Windows y SQL Server Native Client 11.0.
4. Ejecutar CargaCompleta o las dimensiones antes de CargarFactVentas. Cada tarea del paquete principal requiere el éxito de la anterior.
5. Ejecutar el script 05_conciliar_carga.sql en una instancia con BikeZ y BikeZ_DW. Es de solo lectura y compara filas, cantidades, importes y correspondencia de claves.

Las instancias usadas durante el trabajo fueron BAKKAPO\BIT2019 y FRANK-PC. La configuración local Run64BitRuntime = False se utilizó para depurar con la extensión SSIS instalada. El proyecto usa DontSaveSensitive.

## Trabajo en equipo

Joaquín implementó Producto, Territorio, FactVentas y CargaCompleta. Frank implementó Cliente, Vendedor y Fecha, preparó la conciliación, documentó el ETL y generó el respaldo con su prueba de restauración. El análisis y las revisiones se integraron mediante ramas y Pull Requests de ambos integrantes. Cada uno debe poder explicar la solución completa.
