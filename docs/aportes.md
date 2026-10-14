# Aportes registrados

Este registro complementa el historial de Git. Describe avances realizados; no marca la implementación futura como terminada.

|Integrante|Avance|Evidencia|Qué debe poder explicar|
|-|-|-|-|
|Joaquín Ramírez|Exploración y primeros controles de calidad|[4f46815](https://github.com/bakkap0/Certamen2-BI/commit/4f46815)|Tablas, relaciones, conteos y detección de datos faltantes|
|Joaquín Ramírez|Completar fechas, claves y clasificación de clientes|[dd95c1c](https://github.com/bakkap0/Certamen2-BI/commit/dd95c1c)|Grano del detalle, período y clientes sin nombre ni apellido|
|Joaquín Ramírez|Integración del análisis y el diseño, resolución de conflictos y correcciones de documentación|[b23e8bd](https://github.com/bakkap0/Certamen2-BI/commit/b23e8bd)|Cómo se conservaron los aportes de ambos y se aclaró el indicador de vendedor informado|
|Joaquín Ramírez|Ejecución de la comprobación de horas|[Resultado obtenido](evidencias/02_horas_origen.tsv)|Por qué los conteos 0/0 respaldan trabajar con fechas al nivel de día|
|Frank Soto|Verificación de fechas y consulta de códigos de empleados|[20900a2](https://github.com/bakkap0/Certamen2-BI/commit/20900a2), [e8e4e41](https://github.com/bakkap0/Certamen2-BI/commit/e8e4e41)|Traducciones de género y estado civil y evidencia obtenida|
|Frank Soto|KPI y actualización del README|[2882b23](https://github.com/bakkap0/Certamen2-BI/commit/2882b23), [66d3b70](https://github.com/bakkap0/Certamen2-BI/commit/66d3b70)|Fórmulas, utilidad y limitaciones de los indicadores|
|Frank Soto|Proceso y granularidad|[23ebde0](https://github.com/bakkap0/Certamen2-BI/commit/23ebde0)|Los primeros dos pasos de Kimball y la clave compuesta del detalle|
|Frank Soto|Dimensiones y datos no informados|[3f4a104](https://github.com/bakkap0/Certamen2-BI/commit/3f4a104)|Roles de Fecha, desnormalización y miembros desconocidos|
|Frank Soto|Tabla de hechos, agregaciones e historia dimensional|[3100b5f](https://github.com/bakkap0/Certamen2-BI/commit/3100b5f), [8d075d6](https://github.com/bakkap0/Certamen2-BI/commit/8d075d6)|Medidas aditivas, promedios por venta y SCD tipo 1|
|Frank Soto|Script de creación del modelo, pruebas y diagrama|[313b9ae](https://github.com/bakkap0/Certamen2-BI/commit/313b9ae), [8f79512](https://github.com/bakkap0/Certamen2-BI/commit/8f79512)|Claves sustitutas, grano, relaciones y miembros desconocidos|
|Joaquín Ramírez|Ejecución del script dimensional y verificación de conteos, miembros desconocidos, claves y relaciones|[Resultados y alcance](modelo-dimensional/validacion-joaquin.md)|Cómo está preparada la estructura del modelo antes de cargarla mediante SSIS|
|Joaquín Ramírez|Conexiones parametrizadas y siete paquetes SSIS preparados|[12453bd](https://github.com/bakkap0/Certamen2-BI/commit/12453bd)|Diferencia entre origen y destino y uso de ServidorSQL|
|Frank Soto|Análisis de empleados que registran ventas y necesidad del LEFT JOIN|[fbba7de](https://github.com/bakkap0/Certamen2-BI/commit/fbba7de)|Cómo conservar vendedores identificados sin territorio asignado|
|Joaquín Ramírez|Carga de Producto con inserciones, detección de cambios y actualización tipo 1|[Pruebas de Producto](evidencias/05_validacion_producto.md)|Lookup, claves sustitutas, tratamiento de nulos y repetición de la carga|
|Joaquín Ramírez|Carga de Territorio y País con inserciones y actualización tipo 1|[Pruebas de Territorio](evidencias/06_validacion_territorio.md)|Desnormalización de País, Lookup y conservación de TerritorioKey|
| Frank Soto | Carga de Cliente con limpieza de nombres, inserciones y actualización tipo 1 | [37b8268](https://github.com/bakkap0/Certamen2-BI/commit/37b8268), [28dfb12](https://github.com/bakkap0/Certamen2-BI/commit/28dfb12) | Derived Column, Lookup, Conditional Split y por qué no se duplica al repetir la carga |
| Frank Soto | Carga de Vendedor con traducción de códigos, LEFT JOIN e inserciones y actualización tipo 1 | [bfd6574](https://github.com/bakkap0/Certamen2-BI/commit/bfd6574) | Por qué Genero y EstadoCivil se agregan como columnas nuevas y cómo se validaron las traducciones |
| Frank Soto | Carga de Fecha generando el calendario 2015-2018 | [3a92ae5](https://github.com/bakkap0/Certamen2-BI/commit/3a92ae5) | Generación del calendario, clave AAAAMMDD, año bisiesto y por qué no requiere actualización |
| Joaquín Ramírez | Configuración del paquete principal con ejecución secuencial | [77c032c](https://github.com/bakkap0/Certamen2-BI/commit/77c032c) | Referencias de proyecto, conexiones de éxito y fallo del paquete principal |
| Joaquín Ramírez | Carga de FactVentas con resolución de claves, cálculos, inserción y actualización por clave compuesta | [Pruebas de FactVentas](evidencias/08_validacion_factventas.md) | Grano del detalle, vendedor desconocido, cálculos y repetición de la carga |

Las revisiones e integraciones posteriores se registrarán con su commit o Pull Request real. Las cinco dimensiones están implementadas y FactVentas tiene pruebas individuales en el equipo de Joaquín; quedan pendientes la revisión conjunta y la validación del ETL completo.

