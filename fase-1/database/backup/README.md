# Respaldo dimensional BikeZ_DW

| Dato | Valor |
|---|---|
| Archivo | `BikeZ_DW.bak` (respaldo completo) |
| Motor | SQL Server 2019 (15.0) |
| Fecha | 14-10-2026 |
| Contenido | Modelo estrella cargado y conciliado, controles 1 a 14 en OK |

## Cómo restaurar

Se restaura con otro nombre para conservar la base original. `MOVE` crea archivos físicos nuevos. Antes de ejecutar, sustituir las rutas y comprobar los nombres lógicos con `RESTORE FILELISTONLY`:

```sql
USE master;

RESTORE FILELISTONLY
FROM DISK = N'<ruta>\BikeZ_DW.bak';

RESTORE DATABASE BikeZ_DW_Prueba
FROM DISK = N'<ruta>\BikeZ_DW.bak'
WITH
    MOVE N'BikeZ_DW' TO N'<carpeta DATA>\BikeZ_DW_Prueba.mdf',
    MOVE N'BikeZ_DW_log' TO N'<carpeta DATA>\BikeZ_DW_Prueba_log.ldf',
    RECOVERY;
```

La carpeta DATA de la instancia se puede consultar con:

```sql
SELECT physical_name
FROM sys.master_files
WHERE database_id = DB_ID('BikeZ_DW');
```

## Prueba de restauración

Frank Soto restauró el respaldo como `BikeZ_DW_Prueba` en su instancia local `FRANK-PC` y registró los siguientes resultados:

| Control | Esperado | Obtenido |
|---|---:|---:|
| Filas de FactVentas | 121.317 | 121.317 |
| Monto total | 110.373.889,3134 | 110.373.889,3134 |
| Clientes, incluido el miembro -1 | 19.821 | 19.821 |

El respaldo y la prueba se incorporaron mediante el [Pull Request 23](https://github.com/bakkap0/Certamen2-BI/pull/23). El archivo `BikeZ.bak` del caso contiene el origen transaccional y no reemplaza este respaldo dimensional.
