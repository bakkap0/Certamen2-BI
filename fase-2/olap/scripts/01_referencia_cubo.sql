-- BikeZ Fase 2: cifras de referencia para comprobar el cubo y el informe.
-- Ejecutar en SSMS, conectado al Motor de base de datos. Solo lectura.
USE BikeZ_DW;
GO

IF DB_NAME() <> N'BikeZ_DW'
    THROW 50001, N'Conéctate a BikeZ_DW antes de ejecutar este control.', 1;

-- 1. Totales globales. Comparar con el cubo sin filtros.
-- DiasDespacho es de cabecera y se repite en las líneas de la misma venta.
WITH PorVenta AS (
    SELECT VentaID, MAX(DiasDespacho) AS DiasDespacho
    FROM dbo.FactVentas
    GROUP BY VentaID
), Totales AS (
    SELECT COUNT_BIG(*) AS Detalles,
           COUNT(DISTINCT VentaID) AS Ventas,
           SUM(CONVERT(bigint, Cantidad)) AS Unidades,
           SUM(ImporteVenta) AS Importe,
           COUNT(DISTINCT CASE WHEN VendedorKey <> -1 THEN VentaID END)
               AS VentasConVendedor
    FROM dbo.FactVentas
)
SELECT t.*,
       CONVERT(decimal(19, 4), t.Importe / NULLIF(t.Ventas, 0)) AS TicketPromedio,
       CONVERT(decimal(9, 4), 100.0 * t.VentasConVendedor / NULLIF(t.Ventas, 0))
           AS PorcentajeVentasConVendedor,
       (SELECT AVG(CONVERT(decimal(19, 4), DiasDespacho)) FROM PorVenta)
           AS DiasPromedioDespachoPorVenta
FROM Totales AS t;

-- 2. Serie por fecha de venta. El calendario conserva meses sin ventas,
-- para que "mes anterior" nunca salte a otro mes con datos.
WITH Calendario AS (
    SELECT DISTINCT DATEFROMPARTS(YEAR(Fecha), MONTH(Fecha), 1) AS Mes
    FROM dbo.DimFecha
), ImporteMensual AS (
    SELECT DATEFROMPARTS(YEAR(d.Fecha), MONTH(d.Fecha), 1) AS Mes,
           SUM(f.ImporteVenta) AS Importe
    FROM dbo.FactVentas AS f
    JOIN dbo.DimFecha AS d ON d.FechaKey = f.FechaVentaKey
    GROUP BY DATEFROMPARTS(YEAR(d.Fecha), MONTH(d.Fecha), 1)
), Comparacion AS (
    SELECT c.Mes, m.Importe,
           LAG(m.Importe) OVER (ORDER BY c.Mes) AS ImporteMesAnterior
    FROM Calendario AS c
    LEFT JOIN ImporteMensual AS m ON m.Mes = c.Mes
)
SELECT Mes, Importe, ImporteMesAnterior,
       CONVERT(decimal(19, 4),
           (Importe - ImporteMesAnterior) / NULLIF(ImporteMesAnterior, 0) * 100)
           AS CrecimientoMensualPct
FROM Comparacion
WHERE Importe IS NOT NULL
ORDER BY Mes;

-- 3. Corte por categoría, para comprobar filtros y navegación del cubo.
-- Las ventas distintas de cada categoría no se suman entre sí.
SELECT p.Categoria,
       COUNT(DISTINCT f.VentaID) AS Ventas,
       SUM(CONVERT(bigint, f.Cantidad)) AS Unidades,
       SUM(f.ImporteVenta) AS Importe
FROM dbo.FactVentas AS f
JOIN dbo.DimProducto AS p ON p.ProductoKey = f.ProductoKey
GROUP BY p.Categoria
ORDER BY Importe DESC, p.Categoria;

-- 4. Comprobar Cliente y Vendedor en el cubo.
SELECT COUNT(DISTINCT ClienteKey) AS ClientesConVentas,
       COUNT(DISTINCT CASE WHEN VendedorKey <> -1 THEN VendedorKey END) AS VendedoresInformadosConVentas,
       SUM(CASE WHEN VendedorKey = -1 THEN ImporteVenta ELSE 0 END) AS ImporteSinVendedor
FROM dbo.FactVentas;

-- 5. Conciliar los KPI de los cortes Road Bikes y Vendedor no informado.
WITH PorVenta AS (
    SELECT c.Corte, f.VentaID, SUM(f.ImporteVenta) AS Importe,
           MAX(f.DiasDespacho) AS DiasDespacho,
           MAX(CASE WHEN f.VendedorKey <> -1 THEN 1 ELSE 0 END) AS VendedorInformado
    FROM dbo.FactVentas AS f
    JOIN dbo.DimProducto AS p ON p.ProductoKey = f.ProductoKey
    CROSS APPLY (VALUES
        (N'Road Bikes', CASE WHEN p.Categoria = N'Road Bikes' THEN 1 ELSE 0 END),
        (N'Vendedor no informado', CASE WHEN f.VendedorKey = -1 THEN 1 ELSE 0 END)
    ) AS c(Corte, Incluir)
    WHERE c.Incluir = 1
    GROUP BY c.Corte, f.VentaID
)
SELECT Corte, SUM(Importe) AS Importe, COUNT_BIG(*) AS Ventas,
       SUM(VendedorInformado) AS VentasConVendedor,
       CONVERT(decimal(19, 4), SUM(Importe) / NULLIF(COUNT_BIG(*), 0)) AS TicketPromedio,
       CONVERT(decimal(9, 4), 100.0 * SUM(VendedorInformado) / NULLIF(COUNT_BIG(*), 0))
           AS PorcentajeVentasConVendedor,
       AVG(CONVERT(decimal(19, 4), DiasDespacho)) AS DiasPromedioDespachoPorVenta
FROM PorVenta
GROUP BY Corte
ORDER BY Corte;
