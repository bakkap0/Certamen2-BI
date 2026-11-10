/* =====================================================================
   05_conciliar_carga.sql
   Concilia el origen BikeZ con el DW BikeZ_DW despues de ejecutar el ETL.
   Solo lectura. Cada control compara el valor del origen con el del DW.
   Estado OK = coinciden. REVISAR = hay una diferencia que explicar.
   Los controles marcados "(esperado 0)" cuentan problemas: deben dar 0.
   ===================================================================== */
USE BikeZ_DW;
GO

WITH Controles AS (
    /* ---------- 1. Dimensiones: una fila por registro del origen ---------- */
    SELECT 1 AS Orden, N'DimProducto: filas (sin -1)' AS Control,
           CAST((SELECT COUNT(*) FROM BikeZ.dbo.Productos) AS DECIMAL(38,4)) AS Origen,
           CAST((SELECT COUNT(*) FROM dbo.DimProducto WHERE ProductoKey > 0) AS DECIMAL(38,4)) AS DW
    UNION ALL
    SELECT 2, N'DimCliente: filas (sin -1)',
           (SELECT COUNT(*) FROM BikeZ.dbo.Clientes),
           (SELECT COUNT(*) FROM dbo.DimCliente WHERE ClienteKey > 0)
    UNION ALL
    SELECT 3, N'DimVendedor: filas (sin -1)',
           (SELECT COUNT(*) FROM BikeZ.dbo.Empleados),
           (SELECT COUNT(*) FROM dbo.DimVendedor WHERE VendedorKey > 0)
    UNION ALL
    SELECT 4, N'DimTerritorio: filas (sin -1)',
           (SELECT COUNT(*) FROM BikeZ.dbo.Territorios),
           (SELECT COUNT(*) FROM dbo.DimTerritorio WHERE TerritorioKey > 0)
    UNION ALL
    SELECT 5, N'DimFecha: dias 2015-01-01 a 2018-12-31',
           DATEDIFF(DAY, '20150101', '20181231') + 1,
           (SELECT COUNT(*) FROM dbo.DimFecha)
    UNION ALL
    SELECT 6, N'Miembros desconocidos -1 (esperado 4)',
           4,
           (SELECT COUNT(*) FROM dbo.DimProducto   WHERE ProductoKey   = -1)
         + (SELECT COUNT(*) FROM dbo.DimCliente    WHERE ClienteKey    = -1)
         + (SELECT COUNT(*) FROM dbo.DimVendedor   WHERE VendedorKey   = -1)
         + (SELECT COUNT(*) FROM dbo.DimTerritorio WHERE TerritorioKey = -1)

    /* ---------- 2. Hechos: totales ---------- */
    UNION ALL
    SELECT 7, N'FactVentas: filas (lineas de detalle)',
           (SELECT COUNT(*) FROM BikeZ.dbo.DetalleVentas),
           (SELECT COUNT(*) FROM dbo.FactVentas)
    UNION ALL
    SELECT 8, N'Ventas distintas',
           (SELECT COUNT(*) FROM BikeZ.dbo.Ventas),
           (SELECT COUNT(DISTINCT VentaID) FROM dbo.FactVentas)
    UNION ALL
    SELECT 9, N'Cantidad total',
           (SELECT ISNULL(SUM(CAST(Cantidad AS BIGINT)), 0) FROM BikeZ.dbo.DetalleVentas),
           (SELECT ISNULL(SUM(CAST(Cantidad AS BIGINT)), 0) FROM dbo.FactVentas)
    UNION ALL
    SELECT 10, N'Monto total (Cantidad x PrecioUnitario)',
           (SELECT ISNULL(SUM(CAST(Cantidad * PrecioUnitario AS DECIMAL(38,4))), 0) FROM BikeZ.dbo.DetalleVentas),
           (SELECT ISNULL(SUM(CAST(ImporteVenta AS DECIMAL(38,4))), 0) FROM dbo.FactVentas)
    UNION ALL
    SELECT 11, N'Lineas sin vendedor (VendedorKey -1)',
           (SELECT COUNT(*) FROM BikeZ.dbo.DetalleVentas d
                JOIN BikeZ.dbo.Ventas v ON v.VentaID = d.VentaID
             WHERE v.VendedorID IS NULL),
           (SELECT COUNT(*) FROM dbo.FactVentas WHERE VendedorKey = -1)

    /* ---------- 3. Revision de claves (esperado 0) ---------- */
    UNION ALL
    SELECT 12, N'Lineas del origen sin fila en FactVentas (esperado 0)',
           0,
           (SELECT COUNT(*) FROM BikeZ.dbo.DetalleVentas d
             WHERE NOT EXISTS (SELECT 1 FROM dbo.FactVentas f
                               WHERE f.VentaID = d.VentaID
                                 AND f.DetalleVentaID = d.DetalleVentaID))
    UNION ALL
    SELECT 13, N'Lineas duplicadas en FactVentas (esperado 0)',
           0,
           (SELECT COUNT(*) FROM (SELECT VentaID, DetalleVentaID
                                  FROM dbo.FactVentas
                                  GROUP BY VentaID, DetalleVentaID
                                  HAVING COUNT(*) > 1) x)
    UNION ALL
    SELECT 14, N'Claves que no corresponden al origen (esperado 0)',
           0,
           (SELECT COUNT(*)
            FROM dbo.FactVentas f
            JOIN BikeZ.dbo.DetalleVentas d ON d.VentaID = f.VentaID
                                          AND d.DetalleVentaID = f.DetalleVentaID
            JOIN BikeZ.dbo.Ventas v        ON v.VentaID = d.VentaID
            JOIN dbo.DimProducto p         ON p.ProductoKey = f.ProductoKey
            JOIN dbo.DimCliente c          ON c.ClienteKey = f.ClienteKey
            JOIN dbo.DimVendedor ve        ON ve.VendedorKey = f.VendedorKey
            JOIN dbo.DimTerritorio t       ON t.TerritorioKey = f.TerritorioKey
            WHERE p.ProductoID   <> d.ProductoID
               OR c.ClienteID    <> v.ClienteID
               OR ve.EmpleadoID  <> ISNULL(v.VendedorID, -1)
               OR t.TerritorioID <> ISNULL(v.TerritorioID, -1)
               OR f.FechaVentaKey <> CONVERT(INT, CONVERT(CHAR(8), v.Fecha, 112))
               OR f.FechaEnvioKey <> CONVERT(INT, CONVERT(CHAR(8), v.FechaEnvio, 112)))
)
SELECT Control,
       Origen,
       DW,
       DW - Origen AS Diferencia,
       CASE WHEN Origen = DW THEN N'OK' ELSE N'REVISAR' END AS Estado
FROM Controles
ORDER BY Orden;
GO