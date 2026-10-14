\# Respaldo dimensional BikeZ\_DW



| Dato | Valor |

|---|---|

| Archivo | `BikeZ\_DW.bak` (respaldo completo) |

| Motor | SQL Server 2019 (15.0) |

| Fecha | 14-10-2026 |

| Contenido | Modelo estrella cargado y conciliado (controles 1 a 14 en OK) |



\## Cómo restaurar



Se restaura con otro nombre para no tocar la base original. `MOVE` crea archivos físicos nuevos:



&#x20;   USE master;

&#x20;   RESTORE DATABASE BikeZ\_DW\_Prueba

&#x20;   FROM DISK = N'<ruta>\\BikeZ\_DW.bak'

&#x20;   WITH

&#x20;       MOVE N'BikeZ\_DW'     TO N'<carpeta DATA>\\BikeZ\_DW\_Prueba.mdf',

&#x20;       MOVE N'BikeZ\_DW\_log' TO N'<carpeta DATA>\\BikeZ\_DW\_Prueba\_log.ldf',

&#x20;       RECOVERY;



La carpeta DATA de la instancia se obtiene con

`SELECT physical\_name FROM sys.master\_files WHERE database\_id = DB\_ID('BikeZ\_DW');`



\## Prueba de restauración



Se restauró como `BikeZ\_DW\_Prueba` y se verificaron las cifras de control:



| Control | Esperado | Obtenido |

|---|---|---|

| Filas de FactVentas | 121.317 | 121.317 |

| Monto total | 110.373.889,3134 | 110.373.889,3134 |

| Clientes (incluye miembro -1) | 19.821 | 19.821 |



Prueba realizada por Frank Soto en su instancia local (FRANK-PC)..



El archivo `BikeZ.bak` original es el origen transaccional y no reemplaza este respaldo.

