USE BikeZ_DW;
GO

SELECT 'DimProducto' AS Tabla, COUNT_BIG(*) AS Filas
FROM dbo.DimProducto
UNION ALL
SELECT 'DimCliente', COUNT_BIG(*) FROM dbo.DimCliente
UNION ALL
SELECT 'DimVendedor', COUNT_BIG(*) FROM dbo.DimVendedor
UNION ALL
SELECT 'DimTerritorio', COUNT_BIG(*) FROM dbo.DimTerritorio
UNION ALL
SELECT 'DimFecha', COUNT_BIG(*) FROM dbo.DimFecha
UNION ALL
SELECT 'FactVentas', COUNT_BIG(*) FROM dbo.FactVentas;

SELECT 'DimProducto' AS Dimension,
       ProductoKey AS ClaveSustituta, ProductoID AS IdOrigen,
       Producto AS Etiqueta
FROM dbo.DimProducto WHERE ProductoKey = -1
UNION ALL
SELECT 'DimCliente', ClienteKey, ClienteID, NombreCompleto
FROM dbo.DimCliente WHERE ClienteKey = -1
UNION ALL
SELECT 'DimVendedor', VendedorKey, EmpleadoID, Vendedor
FROM dbo.DimVendedor WHERE VendedorKey = -1
UNION ALL
SELECT 'DimTerritorio', TerritorioKey, TerritorioID, Territorio
FROM dbo.DimTerritorio WHERE TerritorioKey = -1;

SELECT t.name AS Tabla,
       k.name AS Restriccion,
       k.type AS Tipo,
       c.name AS Columna,
       ic.key_ordinal AS OrdenEnClave,
       c.is_identity AS EsIdentity
FROM sys.key_constraints k
JOIN sys.tables t ON t.object_id = k.parent_object_id
JOIN sys.index_columns ic
    ON ic.object_id = t.object_id AND ic.index_id = k.unique_index_id
JOIN sys.columns c
    ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE t.schema_id = SCHEMA_ID(N'dbo')
  AND t.name IN ('DimProducto', 'DimCliente', 'DimVendedor',
                 'DimTerritorio', 'DimFecha', 'FactVentas')
  AND k.type IN ('PK', 'UQ')
  AND ic.key_ordinal > 0
ORDER BY t.name, k.type, k.name, ic.key_ordinal;

SELECT fk.name AS Relacion,
       cp.name AS ColumnaHecho,
       OBJECT_NAME(fk.referenced_object_id) AS Dimension,
       cr.name AS ClaveDimension,
       fk.is_disabled AS Deshabilitada,
       fk.is_not_trusted AS NoVerificada
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc
    ON fkc.constraint_object_id = fk.object_id
JOIN sys.columns cp
    ON cp.object_id = fkc.parent_object_id
   AND cp.column_id = fkc.parent_column_id
JOIN sys.columns cr
    ON cr.object_id = fkc.referenced_object_id
   AND cr.column_id = fkc.referenced_column_id
WHERE fk.parent_object_id = OBJECT_ID(N'dbo.FactVentas')
ORDER BY fk.name, fkc.constraint_column_id;
GO
