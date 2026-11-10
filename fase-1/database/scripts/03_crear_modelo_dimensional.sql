/* =====================================================================
   03_crear_modelo_dimensional.sql
   Crea la base dimensional BikeZ_DW (modelo estrella) en SQL Server 2019.
   Diseño: docs/modelo-dimensional/propuesta.md
   Granularidad: una fila por detalle de venta (VentaID + DetalleVentaID).
   ===================================================================== */
USE master;
GO
IF DB_ID(N'BikeZ_DW') IS NULL
    CREATE DATABASE BikeZ_DW;
GO
USE BikeZ_DW;
GO
/* La tabla de hechos se borra primero porque depende de las dimensiones */
DROP TABLE IF EXISTS dbo.FactVentas;
GO

/* ---------- DimProducto: Productos + Categorias (desnormalizada) ---------- */
DROP TABLE IF EXISTS dbo.DimProducto;
GO
CREATE TABLE dbo.DimProducto (
    ProductoKey  INT IDENTITY(1,1) NOT NULL,   -- clave sustituta del DW
    ProductoID   INT               NOT NULL,   -- clave del origen
    Producto     NVARCHAR(50)      NOT NULL,
    Color        NVARCHAR(30)      NOT NULL,   -- 'Sin color informado' si viene NULL
    CategoriaID  INT               NULL,
    Categoria    NVARCHAR(50)      NOT NULL,   -- 'Sin categoría informada'
    CONSTRAINT PK_DimProducto PRIMARY KEY (ProductoKey),
    CONSTRAINT UQ_DimProducto_ProductoID UNIQUE (ProductoID)
);
GO

/* ---------- DimCliente ---------- */
DROP TABLE IF EXISTS dbo.DimCliente;
GO
CREATE TABLE dbo.DimCliente (
    ClienteKey      INT IDENTITY(1,1) NOT NULL,   -- clave sustituta del DW
    ClienteID       INT               NOT NULL,   -- clave del origen
    Nombre          NVARCHAR(50)      NOT NULL,   -- 'Sin nombre informado' si viene NULL
    Apellido        NVARCHAR(50)      NOT NULL,   -- 'Sin apellido informado' si viene NULL
    NombreCompleto  NVARCHAR(101)     NOT NULL,   -- Nombre + ' ' + Apellido
    CONSTRAINT PK_DimCliente PRIMARY KEY (ClienteKey),
    CONSTRAINT UQ_DimCliente_ClienteID UNIQUE (ClienteID)
);
GO

/* ---------- DimTerritorio: Territorios + Paises (desnormalizada) ---------- */
DROP TABLE IF EXISTS dbo.DimTerritorio;
GO
CREATE TABLE dbo.DimTerritorio (
    TerritorioKey  INT IDENTITY(1,1) NOT NULL,   -- clave sustituta del DW
    TerritorioID   INT               NOT NULL,   -- clave del origen
    Territorio     NVARCHAR(50)      NOT NULL,
    PaisID         NVARCHAR(3)       NOT NULL,   -- en el origen es texto (ej. 'US')
    Pais           NVARCHAR(50)      NOT NULL,   -- viene de Paises
    Grupo          NVARCHAR(50)      NOT NULL,   -- jerarquía: Grupo > Pais > Territorio
    CONSTRAINT PK_DimTerritorio PRIMARY KEY (TerritorioKey),
    CONSTRAINT UQ_DimTerritorio_TerritorioID UNIQUE (TerritorioID)
);
GO

/* ---------- DimVendedor: Empleados + territorio asignado ---------- */
DROP TABLE IF EXISTS dbo.DimVendedor;
GO
CREATE TABLE dbo.DimVendedor (
    VendedorKey         INT IDENTITY(1,1) NOT NULL,   -- clave sustituta del DW
    EmpleadoID          INT               NOT NULL,   -- = Ventas.VendedorID
    Vendedor            NVARCHAR(30)      NOT NULL,   -- 'Vendedor 274' (el origen no tiene nombres)
    Cargo               NVARCHAR(50)      NOT NULL,
    Genero              NVARCHAR(15)      NOT NULL,   -- F/M traducido a Femenino/Masculino
    EstadoCivil         NVARCHAR(15)      NOT NULL,   -- S/M traducido a Soltero(a)/Casado(a)
    FechaNacimiento     DATE              NOT NULL,
    FechaContratacion   DATE              NOT NULL,
    TerritorioAsignado  NVARCHAR(50)      NOT NULL,   -- 'Territorio no informado' (275 sin territorio)
    CONSTRAINT PK_DimVendedor PRIMARY KEY (VendedorKey),
    CONSTRAINT UQ_DimVendedor_EmpleadoID UNIQUE (EmpleadoID)
);
GO

/* ---------- DimFecha: generada por script (no existe en el origen) ---------- */
DROP TABLE IF EXISTS dbo.DimFecha;
GO
CREATE TABLE dbo.DimFecha (
    FechaKey         INT           NOT NULL,   -- AAAAMMDD, ej. 20150701 (sin IDENTITY)
    Fecha            DATE          NOT NULL,
    Anio             SMALLINT      NOT NULL,
    Semestre         TINYINT       NOT NULL,   -- 1 o 2
    Trimestre        TINYINT       NOT NULL,   -- 1 a 4
    Mes              TINYINT       NOT NULL,   -- 1 a 12 (para ordenar)
    NombreMes        NVARCHAR(15)  NOT NULL,   -- 'Julio' (para mostrar)
    Dia              TINYINT       NOT NULL,
    DiaSemana        TINYINT       NOT NULL,   -- 1 = Lunes ... 7 = Domingo
    NombreDiaSemana  NVARCHAR(15)  NOT NULL,
    CONSTRAINT PK_DimFecha PRIMARY KEY (FechaKey),
    CONSTRAINT UQ_DimFecha_Fecha UNIQUE (Fecha)
);
GO
/* ---------- FactVentas: una fila por detalle de venta ---------- */
CREATE TABLE dbo.FactVentas (
    -- Grano: identifican cada línea de venta (dimensiones degeneradas)
    VentaID         INT            NOT NULL,
    DetalleVentaID  INT            NOT NULL,
    -- Claves hacia las dimensiones
    FechaVentaKey   INT            NOT NULL,
    FechaEnvioKey   INT            NOT NULL,
    ProductoKey     INT            NOT NULL,
    ClienteKey      INT            NOT NULL,
    VendedorKey     INT            NOT NULL,   -- -1 = Vendedor no informado
    TerritorioKey   INT            NOT NULL,
    -- Medidas
    Cantidad        INT            NOT NULL,   -- aditiva
    PrecioUnitario  DECIMAL(19,4)  NOT NULL,   -- no aditiva (money en el origen)
    ImporteVenta    DECIMAL(19,4)  NOT NULL,   -- aditiva: Cantidad * PrecioUnitario
    DiasDespacho    INT            NULL,       -- no aditiva: se promedia

    CONSTRAINT PK_FactVentas PRIMARY KEY (VentaID, DetalleVentaID),

    CONSTRAINT FK_FactVentas_FechaVenta FOREIGN KEY (FechaVentaKey) REFERENCES dbo.DimFecha (FechaKey),
    CONSTRAINT FK_FactVentas_FechaEnvio FOREIGN KEY (FechaEnvioKey) REFERENCES dbo.DimFecha (FechaKey),
    CONSTRAINT FK_FactVentas_Producto   FOREIGN KEY (ProductoKey)   REFERENCES dbo.DimProducto (ProductoKey),
    CONSTRAINT FK_FactVentas_Cliente    FOREIGN KEY (ClienteKey)    REFERENCES dbo.DimCliente (ClienteKey),
    CONSTRAINT FK_FactVentas_Vendedor   FOREIGN KEY (VendedorKey)   REFERENCES dbo.DimVendedor (VendedorKey),
    CONSTRAINT FK_FactVentas_Territorio FOREIGN KEY (TerritorioKey) REFERENCES dbo.DimTerritorio (TerritorioKey)
);
GO

/* ---------- Miembros desconocidos (clave -1) ----------
   Reciben las ventas con referencias faltantes, para no perder filas.
   DimFecha no lo necesita: no hay ventas sin fecha ni sin envío. */

SET IDENTITY_INSERT dbo.DimProducto ON;
INSERT INTO dbo.DimProducto (ProductoKey, ProductoID, Producto, Color, CategoriaID, Categoria)
VALUES (-1, -1, N'Producto no informado', N'No informado', NULL, N'No informada');
SET IDENTITY_INSERT dbo.DimProducto OFF;

SET IDENTITY_INSERT dbo.DimCliente ON;
INSERT INTO dbo.DimCliente (ClienteKey, ClienteID, Nombre, Apellido, NombreCompleto)
VALUES (-1, -1, N'No informado', N'No informado', N'Cliente no informado');
SET IDENTITY_INSERT dbo.DimCliente OFF;

SET IDENTITY_INSERT dbo.DimVendedor ON;
INSERT INTO dbo.DimVendedor (VendedorKey, EmpleadoID, Vendedor, Cargo, Genero, EstadoCivil,
                             FechaNacimiento, FechaContratacion, TerritorioAsignado)
VALUES (-1, -1, N'Vendedor no informado', N'No informado', N'No informado', N'No informado',
        '19000101', '19000101', N'No informado');
SET IDENTITY_INSERT dbo.DimVendedor OFF;

SET IDENTITY_INSERT dbo.DimTerritorio ON;
INSERT INTO dbo.DimTerritorio (TerritorioKey, TerritorioID, Territorio, PaisID, Pais, Grupo)
VALUES (-1, -1, N'Territorio no informado', N'N/A', N'No informado', N'No informado');
SET IDENTITY_INSERT dbo.DimTerritorio OFF;
GO
