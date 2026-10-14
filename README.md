# Certamen 2 - Inteligencia de Negocios

**Caso 2: Bike Z · Sección 300**

**Integrantes:** Joaquín Ramírez y Frank Soto.

## Sobre el proyecto

Bike Z necesita analizar sus ventas para apoyar sus decisiones comerciales. En este proyecto trabajamos con la base de datos entregada para analizar las ventas por fecha, producto, cliente, vendedor y territorio.

En la **Fase 1** vamos a crear un modelo dimensional en SQL Server y cargar sus datos mediante un proceso ETL en SSIS. El cubo OLAP y el dashboard en Power BI quedan para la Fase 2.

## Indicadores definidos

| KPI | Cálculo | ¿Para qué sirve? |
|---|---|---|
| Monto de ventas | Suma de cantidad × precio unitario | Medir el tamaño del negocio y compararlo por mes, producto, categoría o territorio |
| Crecimiento mensual de ventas | (Monto del mes − monto del mes anterior) / monto del mes anterior × 100 | Saber si la empresa sigue creciendo |
| % de ventas con vendedor informado | Ventas distintas con vendedor informado / total de ventas distintas × 100 | Medir la cobertura de identificación del vendedor |
| Ticket promedio | Monto de ventas / número de ventas distintas | Saber cuánto gasta un cliente por compra |
| Días promedio de despacho | Promedio de (fecha de envío − fecha de venta) | Medir qué tan rápido se envían los pedidos |

El crecimiento se mide por mes porque 2015 y 2018 son años incompletos; si el mes anterior no tiene ventas, queda sin calcular. El ticket se divide por ventas distintas y no por detalles, porque una venta tiene varias líneas. No calcularemos rentabilidad ni inventario porque la base no incluye costos ni stock. El detalle de cada indicador está en [la propuesta del modelo](docs/modelo-dimensional/propuesta.md).

## Modelo dimensional

La propuesta sigue los cuatro pasos de Kimball:

1. **Proceso:** ventas de Bike Z.
2. **Granularidad:** una fila por detalle de venta, identificado por `VentaID` y `DetalleVentaID`.
3. **Dimensiones:** Fecha, Producto, Cliente, Vendedor y Territorio. Fecha se usará para venta y envío; Producto incluirá categoría y Territorio incluirá país y grupo.
4. **Tabla de hechos:** `FactVentas`, con cantidad, precio unitario e importe de venta (cantidad × precio unitario).

Usaremos un modelo estrella. El diseño completo está en [la propuesta del modelo](docs/modelo-dimensional/propuesta.md) y debe confirmarse con los datos del origen.

## ETL y herramientas

El flujo previsto es: **BikeZ → limpieza y transformación en SSIS → dimensiones → FactVentas → validación de la carga**.

Trabajamos con SQL Server 2019 Developer, SSMS, Visual Studio Community 2019 con SSIS y GitHub.

## Organización del repositorio

```text
database/scripts/        Consultas y scripts SQL
database/backup/         Respaldo de la base dimensional
etl/proyecto-ssis/       Solución y paquetes SSIS
docs/modelo-dimensional/ Diseño y diagrama del modelo
docs/evidencias/         Capturas y resultados de las validaciones
docs/presentacion/       Material para la presentación
```

## Cómo revisar el avance

1. Clonar el repositorio y restaurar el archivo `BikeZ.bak` del caso como base `BikeZ` en SQL Server 2019.
2. Ejecutar [01_explorar_origen.sql](database/scripts/01_explorar_origen.sql) en SSMS y registrar los resultados en [análisis del origen](docs/analisis-origen.md).
3. Para una instalación inicial, ejecutar [03_crear_modelo_dimensional.sql](database/scripts/03_crear_modelo_dimensional.sql). El script elimina y recrea las tablas de BikeZ_DW, por lo que no se utiliza para revisar una base ya cargada.
4. Ejecutar [04_verificar_modelo.sql](database/scripts/04_verificar_modelo.sql), de solo lectura, para revisar conteos, miembros desconocidos, claves y relaciones.
5. Abrir [BikeZ_ETL.sln](etl/proyecto-ssis/BikeZ_ETL.sln) en Visual Studio 2019 con la extensión SSIS. El proyecto está configurado para SQL Server 2019 y tiene conexiones de origen y destino. `CargaProducto.dtsx` ya carga productos, evita duplicarlos y actualiza atributos con SCD tipo 1. Los demás paquetes siguen pendientes.

En el equipo de Joaquín la instancia es `BAKKAPO\BIT2019`. Ambas conexiones usan el parámetro de proyecto `ServidorSQL`; cada integrante debe configurar el valor de su instancia para las pruebas locales.

## Avance y trabajo en equipo

Tenemos el análisis del origen, el modelo dimensional creado y verificado, las conexiones y los siete paquetes SSIS preparados. En Producto ejecuté la primera carga, repetí el proceso y comprobé una actualización conservando la clave; los resultados están en [validación de Producto](docs/evidencias/05_validacion_producto.md). Falta completar las demás cargas, validar el DW completo y preparar el respaldo dimensional y la presentación. La Fase 2 todavía no está iniciada.

Joaquín realizó la exploración, los controles de datos y la comprobación inicial del modelo en su equipo; Frank amplió el análisis, documentó los KPI y creó el modelo y su diagrama. Ambos participarán en SSIS, validación y presentación. El detalle está en [el plan de trabajo](docs/plan-trabajo.md) y los avances registrados en [aportes.md](docs/aportes.md). Cada uno trabaja desde su cuenta y revisamos los cambios antes de integrarlos.
