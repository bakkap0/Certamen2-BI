# Aportes registrados

Este registro complementa el historial de Git. Describe avances realizados; no marca la implementación futura como terminada.

| Integrante | Avance | Evidencia | Qué debe poder explicar |
|---|---|---|---|
| Joaquín Ramírez | Exploración y primeros controles de calidad | [4f46815](https://github.com/bakkap0/Certamen2-BI/commit/4f46815) | Tablas, relaciones, conteos y detección de datos faltantes |
| Joaquín Ramírez | Completar fechas, claves y clasificación de clientes | [dd95c1c](https://github.com/bakkap0/Certamen2-BI/commit/dd95c1c) | Grano del detalle, período y clientes sin nombre ni apellido |
| Joaquín Ramírez | Integración del análisis y el diseño, resolución de conflictos y correcciones de documentación | [b23e8bd](https://github.com/bakkap0/Certamen2-BI/commit/b23e8bd) | Cómo se conservaron los aportes de ambos y se aclaró el indicador de vendedor informado |
| Joaquín Ramírez | Ejecución de la comprobación de horas | [Resultado obtenido](evidencias/02_horas_origen.tsv) | Por qué los conteos 0/0 respaldan trabajar con fechas al nivel de día |
| Frank Soto | Verificación de fechas y consulta de códigos de empleados | [20900a2](https://github.com/bakkap0/Certamen2-BI/commit/20900a2), [e8e4e41](https://github.com/bakkap0/Certamen2-BI/commit/e8e4e41) | Traducciones de género y estado civil y evidencia obtenida |
| Frank Soto | KPI y actualización del README | [2882b23](https://github.com/bakkap0/Certamen2-BI/commit/2882b23), [66d3b70](https://github.com/bakkap0/Certamen2-BI/commit/66d3b70) | Fórmulas, utilidad y limitaciones de los indicadores |
| Frank Soto | Proceso y granularidad | [23ebde0](https://github.com/bakkap0/Certamen2-BI/commit/23ebde0) | Los primeros dos pasos de Kimball y la clave compuesta del detalle |
| Frank Soto | Dimensiones y datos no informados | [3f4a104](https://github.com/bakkap0/Certamen2-BI/commit/3f4a104) | Roles de Fecha, desnormalización y miembros desconocidos |
| Frank Soto | Tabla de hechos, agregaciones e historia dimensional | [3100b5f](https://github.com/bakkap0/Certamen2-BI/commit/3100b5f), [8d075d6](https://github.com/bakkap0/Certamen2-BI/commit/8d075d6) | Medidas aditivas, promedios por venta y SCD tipo 1 |
| Frank Soto | Script de creación del modelo, pruebas y diagrama | [313b9ae](https://github.com/bakkap0/Certamen2-BI/commit/313b9ae), [8f79512](https://github.com/bakkap0/Certamen2-BI/commit/8f79512) | Claves sustitutas, grano, relaciones y miembros desconocidos |
| Joaquín Ramírez | Ejecución del script dimensional y verificación de conteos, miembros desconocidos, claves y relaciones | [Resultados y alcance](modelo-dimensional/validacion-joaquin.md) | Cómo está preparada la estructura del modelo antes de cargarla mediante SSIS |
| Joaquín Ramírez | Conexiones parametrizadas y siete paquetes SSIS preparados | [12453bd](https://github.com/bakkap0/Certamen2-BI/commit/12453bd) | Diferencia entre origen y destino y uso de ServidorSQL |
| Frank Soto | Análisis de empleados que registran ventas y necesidad del LEFT JOIN | [fbba7de](https://github.com/bakkap0/Certamen2-BI/commit/fbba7de) | Cómo conservar vendedores identificados sin territorio asignado |
| Joaquín Ramírez | Carga de Producto con inserciones, detección de cambios y actualización tipo 1 | [Pruebas de Producto](evidencias/05_validacion_producto.md) | Lookup, claves sustitutas, tratamiento de nulos y repetición de la carga |
| Joaquín Ramírez | Carga de Territorio y País con inserciones y actualización tipo 1 | [Pruebas de Territorio](evidencias/06_validacion_territorio.md) | Desnormalización de País, Lookup y conservación de TerritorioKey |

Las revisiones e integraciones posteriores se registrarán con su commit o Pull Request real. Producto y Territorio están cargados y probados en el equipo de Joaquín; falta integrar las demás cargas y validar el ETL completo.
