-- Ejecutar en el Motor de base de datos de BAKKAPO\BIT2019.
-- El cubo usa la cuenta local del servicio de Analysis Services.
USE [master];

IF SERVERPROPERTY('ServerName') <> N'BAKKAPO\BIT2019'
    THROW 50001, N'Conéctate al motor de base de datos BAKKAPO\BIT2019.', 1;

IF DB_ID(N'BikeZ_DW') IS NULL
    THROW 50002, N'BikeZ_DW no está disponible en esta instancia.', 1;

IF SUSER_ID(N'NT Service\MSOLAP$BIT2019') IS NULL
    CREATE LOGIN [NT Service\MSOLAP$BIT2019] FROM WINDOWS;

USE [BikeZ_DW];

IF DATABASE_PRINCIPAL_ID(N'NT Service\MSOLAP$BIT2019') IS NULL
    CREATE USER [NT Service\MSOLAP$BIT2019] FOR LOGIN [NT Service\MSOLAP$BIT2019];

GRANT SELECT ON OBJECT::dbo.FactVentas TO [NT Service\MSOLAP$BIT2019];
GRANT SELECT ON OBJECT::dbo.DimProducto TO [NT Service\MSOLAP$BIT2019];
GRANT SELECT ON OBJECT::dbo.DimFecha TO [NT Service\MSOLAP$BIT2019];
GRANT SELECT ON OBJECT::dbo.DimTerritorio TO [NT Service\MSOLAP$BIT2019];
GRANT SELECT ON OBJECT::dbo.DimCliente TO [NT Service\MSOLAP$BIT2019];
GRANT SELECT ON OBJECT::dbo.DimVendedor TO [NT Service\MSOLAP$BIT2019];
