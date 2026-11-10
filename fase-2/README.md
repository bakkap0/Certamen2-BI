# Fase 2 · Cubo OLAP de Bike Z

El cubo `Ventas` toma los datos de `BikeZ_DW`. Permite analizar por Producto,
Cliente, Vendedor, Territorio y Fecha. Fecha se usa como fecha de venta y como
fecha de envío. El calendario se recorre por año, mes y día. También se puede
navegar de categoría a producto y de grupo a país y territorio.

- [Solución de Visual Studio](olap/proyecto-ssas/BikeZ_OLAP.sln)
- [Scripts de permisos y comprobación](olap/scripts/)
- [Respaldo de `BikeZ_DW` y restauración](../fase-1/database/backup/README.md)
- [Definiciones de los cinco KPI](../fase-1/docs/modelo-dimensional/propuesta.md#kpi-definidos)

## Implementación

1. Restaura el respaldo de la Fase 1 como `BikeZ_DW` en el motor de SQL Server.
2. Abre la solución con Visual Studio 2022 y la extensión **Microsoft Analysis
   Services Projects**. La configuración validada usa Analysis Services 2019
   en modo multidimensional y SQL Server Native Client 11.0.
3. En `BikeZ_DW.ds`, apunta el origen al motor que contiene `BikeZ_DW`. En
   **Propiedades del proyecto → Implementación**, apunta el destino a la
   instancia de Analysis Services y usa `BikeZ_OLAP_Prueba` como base de prueba.
4. Ejecuta [02_dar_lectura_ssas.sql](olap/scripts/02_dar_lectura_ssas.sql) en el
   **Motor de base de datos**. El script está configurado para `BAKKAPO\BIT2019`
   y `NT Service\MSOLAP$BIT2019`. Si trabajas en otra instancia, ajusta el
   servidor de la comprobación inicial y la cuenta del servicio en el script.
   Los permisos de lectura se conceden sobre las tablas que usa el cubo.
5. En Visual Studio, elige **Implementar** y comprueba el resultado del
   procesamiento. En SSMS, conéctate a **Analysis Services** y selecciona
   `BikeZ_OLAP_Prueba` para ejecutar las consultas `.mdx`.

## Validación

Comparamos [06_comprobar_kpi.mdx](olap/scripts/06_comprobar_kpi.mdx) con
[01_referencia_cubo.sql](olap/scripts/01_referencia_cubo.sql). Coincidieron los
totales generales, los cortes **Road Bikes** y **Vendedor no informado**, y
el importe y el crecimiento de julio de 2015 a enero de 2016.

| Comprobación | Resultado |
| --- | ---: |
| Unidades vendidas | 274.914 |
| Importe vendido | 110.373.889,3134 |
| Ventas distintas | 31.465 |
| Ticket promedio | 3.507,8306 |
| Ventas con vendedor informado | 12,10 % |
| Días promedio de despacho por venta | 6,988749 |
| Crecimiento en agosto de 2015 frente a julio | 112,55 % |

El ticket y el despacho se calculan por `VentaID`. Para analizar el crecimiento,
usa el nivel **Mes** de **Fecha de venta → Calendario**.

El tablero de Power BI se incorporará en esta fase cuando esté listo.
