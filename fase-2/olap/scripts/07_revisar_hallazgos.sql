-- BikeZ Fase 2: consultas que respaldan los hallazgos del tablero de Power BI.
-- Ejecutar en SSMS, conectado al Motor de base de datos. Solo lectura.
USE BikeZ_DW;
GO

IF DB_NAME() <> N'BikeZ_DW'
    THROW 50001, N'Conéctate a BikeZ_DW antes de ejecutar estas consultas.', 1;

-- 1. Julio de 2018 frente a junio de 2018, por categoría.
-- Julio es el último mes de la base y no registra bicicletas, cuadros ni componentes.
SELECT p.Categoria,
       SUM(CASE WHEN f.Mes = 6 THEN v.ImporteVenta END) AS ImporteJunio,
       SUM(CASE WHEN f.Mes = 7 THEN v.ImporteVenta END) AS ImporteJulio
FROM dbo.FactVentas v
JOIN dbo.DimProducto p ON p.ProductoKey = v.ProductoKey
JOIN dbo.DimFecha f ON f.FechaKey = v.FechaVentaKey
WHERE f.Anio = 2018 AND f.Mes IN (6, 7)
GROUP BY p.Categoria
ORDER BY ImporteJunio DESC;

-- 2. Ventas cuyo despacho no fue de 7 días, por fecha de venta.
-- Todas caen entre el 22 y el 28 de febrero (2016 y 2018) o en un fin de mes de 2018.
SELECT f.Anio, f.Mes, f.Dia, v.DiasDespacho,
       COUNT(DISTINCT v.VentaID) AS Ventas
FROM dbo.FactVentas v
JOIN dbo.DimFecha f ON f.FechaKey = v.FechaVentaKey
WHERE v.DiasDespacho <> 7
GROUP BY f.Anio, f.Mes, f.Dia, v.DiasDespacho
ORDER BY f.Anio, f.Mes, f.Dia;

-- 3. Porcentaje de ventas con vendedor informado por año.
SELECT f.Anio,
       COUNT(DISTINCT v.VentaID) AS Ventas,
       COUNT(DISTINCT CASE WHEN v.VendedorKey <> -1 THEN v.VentaID END) AS VentasConVendedor,
       CAST(100.0 * COUNT(DISTINCT CASE WHEN v.VendedorKey <> -1 THEN v.VentaID END)
            / COUNT(DISTINCT v.VentaID) AS DECIMAL(5, 2)) AS PorcentajeConVendedor
FROM dbo.FactVentas v
JOIN dbo.DimFecha f ON f.FechaKey = v.FechaVentaKey
GROUP BY f.Anio
ORDER BY f.Anio;
