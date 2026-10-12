# Certamen 2 · Inteligencia de Negocios
## Caso 2: Bike Z · Sección 300

**Integrantes:** Joaquín Ramírez y Frank Soto.

**Fase actual:** Fase 1 — modelo dimensional y ETL.

**Estado:** preparación del entorno y análisis inicial. El modelo dimensional y la carga ETL todavía no están implementados.

## Problema y objetivo
Bike Z vende artículos para motocross y necesita apoyar sus decisiones comerciales mediante Inteligencia de Negocios. El proyecto busca transformar su información transaccional en un modelo dimensional que permita analizar ventas, productos, clientes, vendedores, territorios y fechas.

El objetivo de esta fase es definir indicadores, aplicar los cuatro pasos de Kimball, implementar el modelo en SQL Server y construir y validar su carga mediante SSIS. OLAP y Power BI corresponden a la Fase 2.

## Equipo
| Integrante | GitHub | Participación |
|---|---|---|
| Joaquín Ramírez | [@bakkap0](https://github.com/bakkap0) | Aportes verificables mediante sus commits y PR |
| Frank Soto | Pendiente de registrar su usuario | Aportes verificables mediante su propia cuenta |

Docente y bloque de presentación: pendientes de registrar. La distribución de tareas de [este plan](docs/plan-trabajo.md) es una propuesta que ambos deben acordar; no representa trabajo ya realizado.

## Estado verificable
| Componente | Estado | Evidencia o ubicación |
|---|---|---|
| Repositorio del equipo | Creado | Este repositorio |
| SQL Server 2019 y conexión en SSMS | Confirmados por captura durante la preparación | Incorporar captura en `docs/evidencias/` |
| Restauración de BikeZ | Informada como correcta por Joaquín | Confirmar versión y tablas ejecutando el script de exploración |
| Proyecto SSIS | Proyecto inicial creado; paquete vacío | [Solución](etl/proyecto-ssis/BikeZ_ETL.sln) |
| Configuración SSIS para SQL Server 2019 | Preparada en los archivos | Abrir y compilar en Visual Studio 2019 para validar |
| Análisis del origen y calidad | Consulta preparada; ejecución y resultados pendientes | [Exploración SQL](database/scripts/01_explorar_origen.sql) |
| KPI y Kimball | Propuesta inicial, pendiente de revisión por el equipo | [Diseño propuesto](docs/modelo-dimensional/propuesta.md) |
| Modelo dimensional, ETL y validaciones | Pendientes | Se incorporarán por avances |
| Backup dimensional y presentación | Pendientes | Se generan al completar y validar la implementación |

## KPI propuestos
Estos indicadores deben confirmarse con el esquema y los datos reales. Las fórmulas no constituyen resultados calculados.

| Indicador | Fórmula propuesta | Utilidad |
|---|---|---|
| Ventas monetarias | SUM(Cantidad × PrecioUnitario) | Comparar actividad comercial por período y segmento |
| Unidades vendidas | SUM(Cantidad) | Identificar demanda de productos y categorías |
| Pedidos | COUNT(DISTINCT VentaID) | Medir transacciones sin contar varias veces sus detalles |
| Ticket promedio | Ventas monetarias / pedidos distintos | Analizar el valor medio de la compra |
| Crecimiento mensual | (Ventas mes actual − ventas mes anterior) / ventas mes anterior × 100 | Detectar alzas y caídas; indefinido si el mes anterior es cero o no existe |
| Participación por categoría | Ventas de categoría / ventas totales × 100 | Identificar concentración comercial |

El esquema del caso no proporciona costos: no se calcula utilidad. La moneda no se asume. Tampoco se fijan metas de cumplimiento sin fundamento. PrecioUnitario, ticket, porcentajes y pedidos distintos no son medidas aditivas entre productos.

## Modelo dimensional propuesto
1. **Proceso:** ventas de artículos de Bike Z.
2. **Granularidad:** una fila por `(VentaID, DetalleVentaID)`.
3. **Dimensiones:** Fecha, Cliente, Producto, Vendedor y Territorio. Fecha tendrá roles de venta y envío; categoría se incorpora a Producto y país/grupo a Territorio.
4. **Hecho y medidas:** FactVentas con Cantidad, PrecioUnitario e ImporteVenta; este último se calcula como Cantidad × PrecioUnitario.

El diseño es una propuesta basada en el enunciado. Se debe contrastar con BikeZ antes de crear el DW. El territorio comercial proviene de Ventas; no se reemplaza por el territorio laboral del vendedor. Almacenes no se une directamente al hecho porque el esquema no identifica un almacén por venta; una unión solo por territorio puede duplicar montos. Véase [la explicación del modelo](docs/modelo-dimensional/propuesta.md).

## Proceso ETL — Fase 1
Flujo previsto: `BikeZ → extracción y transformaciones SSIS → dimensiones y hechos de BikeZ_DW → validación`.

El proyecto incluido permite continuar el desarrollo: contiene un paquete vacío, configurado para SQL Server 2019 y con protección `DontSaveSensitive`. Todavía no incluye conexiones, tareas de extracción, transformaciones ni carga de datos. Una ejecución correcta del paquete vacío no demuestra que exista un ETL.

## Tecnologías
- SQL Server 2019 Developer y SQL Server Management Studio.
- Visual Studio Community 2019 con SQL Server Integration Services Projects.
- Git y GitHub para trazabilidad y colaboración.

SSAS y Power BI se incorporarán en la Fase 2.

## Estructura
```text
Certamen2-BI/
├── README.md
├── CONTRIBUTING.md
├── .gitignore
├── .github/
│   └── pull_request_template.md
├── database/
│   ├── scripts/
│   │   └── 01_explorar_origen.sql
│   └── backup/
├── docs/
│   ├── analisis-origen.md
│   ├── plan-trabajo.md
│   ├── checklist-fase1.md
│   ├── aportes.md
│   ├── evidencias/
│   ├── modelo-dimensional/
│   └── presentacion/
└── etl/
    └── proyecto-ssis/
        ├── BikeZ_ETL.sln
        └── BikeZ_ETL/
```

## Cómo revisar el avance actual
1. Clonar el repositorio y usar la rama que se está revisando.
2. Conectarse en SSMS a la instancia de SQL Server 2019. En el equipo de Joaquín se utilizó `localhost\BI2019`; cada integrante debe usar el nombre de su propia instancia.
3. Restaurar el BikeZ.bak suministrado por el docente como base `BikeZ`. El respaldo de origen no es el respaldo dimensional de la entrega.
4. Abrir y ejecutar [01_explorar_origen.sql](database/scripts/01_explorar_origen.sql). Es de solo lectura: devuelve versión, tablas, columnas, PK, FK y conteos exactos por tabla.
5. Registrar los hallazgos reales en [analisis-origen.md](docs/analisis-origen.md) y guardar la evidencia de ejecución.
6. Abrir [BikeZ_ETL.sln](etl/proyecto-ssis/BikeZ_ETL.sln) en Visual Studio 2019 con SSIS. Comprobar `TargetServerVersion = SQL Server 2019` y compilar. La compilación y la ejecución del diseñador siguen pendientes de verificar para esta copia.
7. Continuar con KPI, Kimball y modelo dimensional según [el plan](docs/plan-trabajo.md).

## Colaboración y evaluación
Cada integrante usa su cuenta, realiza cambios sustantivos y explica sus aportes. Se recomienda trabajar en ramas y revisar los PR entre ambos. Los commits deben describir cambios concretos; su número por sí solo no demuestra participación.

La distribución propuesta combina SQL, documentación, ETL y validación para ambos. No se registran tareas como terminadas ni autorías de Frank hasta que existan aportes reales. El [registro de aportes](docs/aportes.md) se completa con enlaces a commits o PR efectivamente realizados.

La pauta asigna el 20% de la nota de cada fase al proyecto grupal y el 80% a la interrogación individual. Ambos deben comprender la solución completa. Revisar [CONTRIBUTING.md](CONTRIBUTING.md) y [la lista de entrega](docs/checklist-fase1.md).

## Fase 2
Cubo OLAP en SSAS y dashboard Power BI: fuera del avance actual.

## Fuentes del proyecto
- Certamen_2_Inteligencia_de_Negocios_UTFSM_v2.pdf: exigencias por fase, uso de GitHub, README y rúbrica.
- CASO2_CASOSEMESTRAL_BI.pdf, incluido en caso2.zip: contexto Bike Z y esquema relacional.
- BikeZ.bak: fuente transaccional que se debe analizar; no contiene el DW que se debe entregar.
