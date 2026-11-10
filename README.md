# Certamen 2 · Inteligencia de Negocios

Solución de inteligencia de negocios para analizar las ventas de Bike Z:
modelo dimensional, ETL en SSIS, cubo OLAP en SSAS y dashboard en Power BI.

## Caso seleccionado

**Caso 2 · Bike Z**, empresa de venta de artículos para motocross. La base
transaccional `BikeZ` registra 31.465 ventas y 121.317 líneas de detalle entre
julio de 2015 y julio de 2018.

## Integrantes y sección

| Integrante | GitHub |
| --- | --- |
| Frank Soto Araya | FraankkkDev |
| Joaquín Ramírez Vaccaro | bakkap0 |

Sección 300 · Profesor: Hernán Saavedra González.

## Descripción del problema

Bike Z registra sus ventas en una base normalizada, pensada para operar y no para
analizar. Responder cuánto se vende por mes, producto o territorio exige unir
muchas tablas, y el origen tiene datos faltantes: el 87,90 % de las ventas no
tiene vendedor y 9.546 clientes no tienen nombre.

## Objetivo del proyecto

Construir una base analítica confiable y un tablero que permitan seguir los KPI de
ventas de Bike Z y apoyar sus decisiones comerciales.

## KPI definidos

| KPI | Cálculo | Utilidad |
| --- | --- | --- |
| Monto de ventas | Suma de cantidad × precio unitario | Medir el tamaño del negocio por período, producto y territorio |
| Crecimiento mensual | (Monto del mes − monto del mes anterior) / monto del mes anterior | Saber si la empresa crece. Se mide por mes porque 2015 y 2018 son años incompletos |
| % de ventas con vendedor informado | Ventas distintas con vendedor / ventas distintas | Medir la cobertura del dato de vendedor |
| Ticket promedio | Monto total / ventas distintas | Conocer el gasto promedio por compra |
| Días promedio de despacho | Promedio de días entre venta y envío, una vez por venta | Medir la rapidez de los envíos |

No se calcula rentabilidad ni inventario porque la base no tiene costos, stock ni
moneda.

## Modelo dimensional

Modelo estrella diseñado con los cuatro pasos de Kimball.
[Diagrama](fase-1/docs/modelo-dimensional/diagrama.png) ·
[diseño completo](fase-1/docs/modelo-dimensional/propuesta.md).

### Proceso de negocio

Ventas de artículos para motocross.

### Granularidad

Una fila por línea de detalle de venta: `VentaID` + `DetalleVentaID`.

### Dimensiones

| Dimensión | Atributos principales | Jerarquía |
| --- | --- | --- |
| DimFecha | Año, semestre, trimestre, mes y día. Se usa como fecha de venta y de envío | Año → Mes → Día |
| DimProducto | Producto, color y categoría | Categoría → Producto |
| DimCliente | Nombre, apellido y nombre completo | — |
| DimVendedor | Cargo, género, estado civil y territorio asignado | — |
| DimTerritorio | Territorio, país y grupo | Grupo → País → Territorio |

Las dimensiones usan claves sustitutas, un miembro desconocido `-1` y SCD tipo 1.

### Tabla de hechos y medidas

`FactVentas`: Cantidad e ImporteVenta (aditivas), PrecioUnitario y DiasDespacho
(no aditivas).

## Proceso ETL · Fase 1

Siete paquetes SSIS. `CargaCompleta` ejecuta Fecha → Producto → Cliente →
Territorio → Vendedor → FactVentas. Cada carga inserta lo nuevo y actualiza lo
que cambió, por lo que puede repetirse sin duplicar datos. La conciliación origen
frente a DW dio 14 de 14 controles en OK.
[Detalle de la Fase 1](fase-1/README.md).

## Cubo OLAP · Fase 2

Cubo multidimensional `Ventas` en SSAS 2019, sobre `BikeZ_DW`. Incluye las cinco
dimensiones, una dimensión oculta `Venta` para contar ventas distintas y los cinco
KPI calculados en MDX. Sus totales coinciden con el DW: 274.914 unidades,
110.373.889,3134 de importe y 31.465 ventas. [Detalle del cubo](fase-2/README.md).

## Dashboard Power BI · Fase 2

[dashboard.pbix](fase-2/powerbi/dashboard.pbix) se conecta en directo al cubo y
tiene tres páginas: Resumen, Productos, y Territorios y vendedores. El
[README de la Fase 2](fase-2/README.md#hallazgos) resume los hallazgos y las
consultas que los respaldan.

## Mejoras sobre la Fase 1

- El repositorio se reorganizó en carpetas `fase-1/` y `fase-2/`.
- Se resolvió el bloqueo de `CargaCompleta` en ejecuciones consecutivas.
- Se agregaron consultas de respaldo para los hallazgos del dashboard.

## Tecnologías utilizadas

| Tecnología | Uso |
| --- | --- |
| SQL Server 2019 Developer y SSMS | Base de origen, data warehouse, scripts y respaldo |
| Visual Studio 2019 + SSIS | Proyecto ETL |
| Visual Studio 2022 + Analysis Services Projects | Proyecto del cubo |
| SQL Server Analysis Services 2019 (multidimensional) | Cubo OLAP |
| Power BI Desktop | Dashboard |
| Git y GitHub | Control de versiones y trabajo colaborativo |

## Estructura del repositorio

```
Certamen2-BI/
├── README.md
├── fase-1/
│   ├── README.md
│   ├── database/
│   │   ├── scripts/        01 a 05: exploración, calidad, modelo, verificación y conciliación
│   │   └── backup/         BikeZ_DW.bak e instrucciones de restauración
│   ├── docs/               análisis, modelo, ETL, evidencias, informe y presentación
│   └── etl/proyecto-ssis/  solución BikeZ_ETL
└── fase-2/
    ├── README.md
    ├── olap/
    │   ├── proyecto-ssas/  solución BikeZ_OLAP
    │   └── scripts/        permisos, comprobaciones MDX y consultas de hallazgos
    └── powerbi/            dashboard.pbix
```

## Instrucciones de ejecución/revisión

1. Restaurar [BikeZ_DW.bak](fase-1/database/backup/BikeZ_DW.bak) siguiendo sus
   [instrucciones](fase-1/database/backup/README.md). Es el respaldo final: el
   data warehouse no cambió en la Fase 2.
2. Para ejecutar el ETL, seguir los pasos del [README de la Fase 1](fase-1/README.md#cómo-revisar-o-ejecutar).
3. Para el cubo, seguir la [implementación de la Fase 2](fase-2/README.md#implementación):
   apuntar el origen de datos a la instancia local, dar permiso de lectura a la
   cuenta de SSAS e implementar desde Visual Studio 2022.
4. Abrir `dashboard.pbix` y apuntar su origen a la instancia de Analysis Services
   donde se implementó el cubo.

## Distribución de responsabilidades y aportes

| Fase | Joaquín Ramírez | Frank Soto |
| --- | --- | --- |
| Fase 1 | Exploración del origen, verificación del modelo, conexiones parametrizadas, cargas de Producto, Territorio y FactVentas, y CargaCompleta | KPI, diseño del modelo, script de creación y diagrama, cargas de Cliente, Vendedor y Fecha, conciliación, documentación del ETL y respaldo con prueba de restauración |
| Fase 2 | Reorganización del repositorio, proyecto SSAS, dimensiones, jerarquías, cálculos MDX de los KPI y scripts de validación | Implementación y validación del cubo en una segunda instancia, dashboard de Power BI, análisis de hallazgos y sus consultas, y README final |

El trabajo se integró con ramas y pull requests de ambos integrantes. Ambos deben
poder explicar la solución completa.
