USE BikeZ;
GO

SELECT MIN(Fecha) AS PrimeraVenta,
       MAX(Fecha) AS UltimaVenta,
       MIN(FechaEnvio) AS PrimerEnvio,
       MAX(FechaEnvio) AS UltimoEnvio
FROM dbo.Ventas;

SELECT N'Ventas sin fecha de envio' AS Control, COUNT_BIG(*) AS Filas
FROM dbo.Ventas WHERE FechaEnvio IS NULL
UNION ALL
SELECT N'Ventas con envio anterior a la venta', COUNT_BIG(*)
FROM dbo.Ventas WHERE FechaEnvio < Fecha
UNION ALL
SELECT N'Ventas sin vendedor', COUNT_BIG(*)
FROM dbo.Ventas WHERE VendedorID IS NULL
UNION ALL
SELECT N'Ventas sin territorio', COUNT_BIG(*)
FROM dbo.Ventas WHERE TerritorioID IS NULL
UNION ALL
SELECT N'Detalles con cantidad cero', COUNT_BIG(*)
FROM dbo.DetalleVentas WHERE Cantidad = 0
UNION ALL
SELECT N'Detalles con cantidad negativa', COUNT_BIG(*)
FROM dbo.DetalleVentas WHERE Cantidad < 0
UNION ALL
SELECT N'Detalles con precio cero', COUNT_BIG(*)
FROM dbo.DetalleVentas WHERE PrecioUnitario = 0
UNION ALL
SELECT N'Detalles con precio negativo', COUNT_BIG(*)
FROM dbo.DetalleVentas WHERE PrecioUnitario < 0
UNION ALL
SELECT N'Clientes sin nombre o con nombre vacio', COUNT_BIG(*)
FROM dbo.Clientes WHERE NULLIF(LTRIM(RTRIM(Nombre)), N'') IS NULL
UNION ALL
SELECT N'Clientes sin apellido o con apellido vacio', COUNT_BIG(*)
FROM dbo.Clientes WHERE NULLIF(LTRIM(RTRIM(Apellido)), N'') IS NULL
UNION ALL
SELECT N'Productos sin color o con color vacio', COUNT_BIG(*)
FROM dbo.Productos WHERE NULLIF(LTRIM(RTRIM(Color)), N'') IS NULL
UNION ALL
SELECT N'Productos sin categoria', COUNT_BIG(*)
FROM dbo.Productos WHERE CategoriaID IS NULL
UNION ALL
SELECT N'Empleados sin territorio', COUNT_BIG(*)
FROM dbo.Empleados WHERE TerritorioID IS NULL
UNION ALL
SELECT N'Almacenes sin territorio', COUNT_BIG(*)
FROM dbo.Almacenes WHERE TerritorioID IS NULL
UNION ALL
SELECT N'Ventas sin detalles', COUNT_BIG(*)
FROM dbo.Ventas v
WHERE NOT EXISTS (SELECT 1 FROM dbo.DetalleVentas d WHERE d.VentaID = v.VentaID)
UNION ALL
SELECT N'Claves de detalle duplicadas', COUNT_BIG(*)
FROM (
    SELECT VentaID, DetalleVentaID
    FROM dbo.DetalleVentas
    GROUP BY VentaID, DetalleVentaID
    HAVING COUNT_BIG(*) > 1
) duplicados;

SELECT N'Productos con categoria inexistente' AS Control, COUNT_BIG(*) AS Filas
FROM dbo.Productos p
WHERE p.CategoriaID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.Categorias c WHERE c.CategoriaID = p.CategoriaID)
UNION ALL
SELECT N'Ventas con cliente inexistente', COUNT_BIG(*)
FROM dbo.Ventas v
WHERE NOT EXISTS (SELECT 1 FROM dbo.Clientes c WHERE c.ClienteID = v.ClienteID)
UNION ALL
SELECT N'Territorios con pais inexistente', COUNT_BIG(*)
FROM dbo.Territorios t
WHERE NOT EXISTS (SELECT 1 FROM dbo.Paises p WHERE p.PaisID = t.PaisID)
UNION ALL
SELECT N'Detalles con producto inexistente', COUNT_BIG(*)
FROM dbo.DetalleVentas d
WHERE NOT EXISTS (SELECT 1 FROM dbo.Productos p WHERE p.ProductoID = d.ProductoID)
UNION ALL
SELECT N'Almacenes con territorio inexistente', COUNT_BIG(*)
FROM dbo.Almacenes a
WHERE a.TerritorioID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.Territorios t WHERE t.TerritorioID = a.TerritorioID)
UNION ALL
SELECT N'Empleados con territorio inexistente', COUNT_BIG(*)
FROM dbo.Empleados e
WHERE e.TerritorioID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.Territorios t WHERE t.TerritorioID = e.TerritorioID)
UNION ALL
SELECT N'Ventas con territorio inexistente', COUNT_BIG(*)
FROM dbo.Ventas v
WHERE v.TerritorioID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.Territorios t WHERE t.TerritorioID = v.TerritorioID)
UNION ALL
SELECT N'Ventas con vendedor inexistente', COUNT_BIG(*)
FROM dbo.Ventas v
WHERE v.VendedorID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.Empleados e WHERE e.EmpleadoID = v.VendedorID)
UNION ALL
SELECT N'Detalles con venta inexistente', COUNT_BIG(*)
FROM dbo.DetalleVentas d
WHERE NOT EXISTS (SELECT 1 FROM dbo.Ventas v WHERE v.VentaID = d.VentaID);
GO

;WITH ClientesRevisados AS (
    SELECT
        CASE WHEN NULLIF(LTRIM(RTRIM(Nombre)), N'') IS NULL
             THEN 1 ELSE 0 END AS SinNombre,
        CASE WHEN NULLIF(LTRIM(RTRIM(Apellido)), N'') IS NULL
             THEN 1 ELSE 0 END AS SinApellido
    FROM dbo.Clientes
)
SELECT
    COUNT_BIG(*) AS TotalClientes,
    COUNT_BIG(CASE WHEN SinNombre = 1 AND SinApellido = 1 THEN 1 END)
        AS SinNombreNiApellido,
    COUNT_BIG(CASE WHEN SinNombre = 1 AND SinApellido = 0 THEN 1 END)
        AS SoloSinNombre,
    COUNT_BIG(CASE WHEN SinNombre = 0 AND SinApellido = 1 THEN 1 END)
        AS SoloSinApellido,
    COUNT_BIG(CASE WHEN SinNombre = 0 AND SinApellido = 0 THEN 1 END)
        AS ConNombreYApellido
FROM ClientesRevisados;
GO
