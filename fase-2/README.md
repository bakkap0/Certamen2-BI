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

## Dashboard en Power BI

El archivo [dashboard.pbix](powerbi/dashboard.pbix) se conecta **en directo** al
cubo `Ventas`. No guarda una copia de los datos: cada visual consulta el cubo, por
lo que usa las mismas medidas y KPI validados arriba.

Para abrirlo en otro equipo: **Inicio → Transformar datos → Configuración del
origen de datos** y apuntar el servidor a la instancia de Analysis Services que
tenga desplegada la base `BikeZ_OLAP`.

| Página | Contenido | KPI que cubre |
| --- | --- | --- |
| Resumen | Tarjetas de los cinco KPI, importe por mes, crecimiento mensual e importe por categoría | Los cinco |
| Productos | Matriz Categoría → Producto con unidades, importe y ventas, y los diez productos con más importe | Monto de ventas |
| Territorios y vendedores | Importe por Grupo → País → Territorio, ventas por cargo, % con vendedor por año y días de despacho por mes | Monto, % con vendedor y despacho |

Las segmentaciones de **Año** y **Grupo** están sincronizadas entre las páginas.

## Hallazgos

Las consultas que respaldan cada hallazgo están en
[07_revisar_hallazgos.sql](olap/scripts/07_revisar_hallazgos.sql).

1. **Las bicicletas explican la mayor parte del importe.** Road Bikes
   (43.978.443), Mountain Bikes (36.622.296) y Touring Bikes (14.545.074) suman
   el 86 % del total. Tires and Tubes es la categoría con más ventas distintas
   (10.030), pero aporta poco importe.
2. **Julio de 2018 no es comparable.** Es el último mes de la base: registra 976
   ventas, pero solo 50.840,63 de importe, porque no contiene bicicletas, cuadros
   ni componentes, solo accesorios y ropa. La caída del gráfico mensual no debe
   leerse como una baja del negocio.
3. **El crecimiento vino de ventas sin vendedor.** Entre 2016 y 2017 las ventas con
   vendedor pasan de 1.015 a 1.524, mientras que el total pasa de 3.692 a 12.443. Por eso el porcentaje con vendedor baja:

   | Año | Ventas | Con vendedor | % con vendedor |
   | --- | ---: | ---: | ---: |
   | 2015 (desde julio) | 1.379 | 367 | 26,61 % |
   | 2016 | 3.692 | 1.015 | 27,49 % |
   | 2017 | 12.443 | 1.524 | 12,25 % |
   | 2018 (hasta julio) | 13.951 | 901 | 6,46 % |

   La base no registra el canal de venta, así que no se puede afirmar por qué
   esas ventas no tienen vendedor.
4. **El despacho es constante: 7 días.** Solo unas 470 ventas difieren, y todas
   caen entre el 22 y el 28 de febrero de 2016 (8 días) y de 2018 (6 días), o en
   un fin de mes de 2018 (8 días). Coinciden con el año bisiesto y con los fines
   de mes, por lo que provienen de cómo se generaron las fechas del caso y no de
   un cambio en la logística.
