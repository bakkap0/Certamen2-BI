USE BikeZ;
GO
SELECT DB_NAME() AS BaseActual,
       CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(50)) AS VersionSQL,
       CAST(SERVERPROPERTY('Edition') AS nvarchar(100)) AS Edicion,
       SYSDATETIME() AS MomentoEjecucion;

SELECT s.name AS Esquema,t.name AS Tabla,c.column_id AS OrdenColumna,
       c.name AS Columna,ty.name AS Tipo,
       CASE WHEN c.max_length=-1 THEN -1
            WHEN ty.name IN ('nvarchar','nchar') THEN c.max_length/2
            WHEN ty.name IN ('varchar','char') THEN c.max_length
            ELSE NULL END AS LongitudTexto,
       c.precision AS PrecisionNumerica,c.scale AS Decimales,
       c.is_nullable AS PermiteNulos,c.is_identity AS EsIdentity
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id=t.schema_id
JOIN sys.columns c ON c.object_id=t.object_id
JOIN sys.types ty ON ty.user_type_id=c.user_type_id
WHERE t.is_ms_shipped=0
ORDER BY s.name,t.name,c.column_id;

SELECT s.name AS Esquema,t.name AS Tabla,k.name AS ClavePrimaria,
       c.name AS Columna,ic.key_ordinal AS OrdenEnClave
FROM sys.key_constraints k
JOIN sys.tables t ON t.object_id=k.parent_object_id
JOIN sys.schemas s ON s.schema_id=t.schema_id
JOIN sys.index_columns ic ON ic.object_id=t.object_id AND ic.index_id=k.unique_index_id
JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
WHERE k.type='PK'
ORDER BY s.name,t.name,ic.key_ordinal;

SELECT fk.name AS Relacion,
       OBJECT_SCHEMA_NAME(fkc.parent_object_id) AS EsquemaHijo,
       OBJECT_NAME(fkc.parent_object_id) AS TablaHija,
       COL_NAME(fkc.parent_object_id,fkc.parent_column_id) AS ColumnaHija,
       OBJECT_SCHEMA_NAME(fkc.referenced_object_id) AS EsquemaPadre,
       OBJECT_NAME(fkc.referenced_object_id) AS TablaPadre,
       COL_NAME(fkc.referenced_object_id,fkc.referenced_column_id) AS ColumnaPadre,
       fk.is_disabled AS Deshabilitada,fk.is_not_trusted AS NoVerificada
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id=fk.object_id
ORDER BY fk.name,fkc.constraint_column_id;
GO

DECLARE @Consulta nvarchar(max);
SELECT @Consulta=STRING_AGG(
 CAST(N'SELECT N'+QUOTENAME(s.name,CHAR(39))+N' AS Esquema, N'
 +QUOTENAME(t.name,CHAR(39))+N' AS Tabla, COUNT_BIG(*) AS Filas FROM '
 +QUOTENAME(s.name)+N'.'+QUOTENAME(t.name) AS nvarchar(max)),
 N' UNION ALL ')
FROM sys.tables t JOIN sys.schemas s ON s.schema_id=t.schema_id
WHERE t.is_ms_shipped=0;
IF @Consulta IS NOT NULL
BEGIN
 SET @Consulta+=N' ORDER BY Esquema,Tabla;';
 EXEC sys.sp_executesql @Consulta;
END;
GO
