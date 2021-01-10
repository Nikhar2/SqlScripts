USE [${Environment}International]
GO

/****** Object:  UserDefinedTableType [dbo].[ReconWarehouseQty]    Script Date: 28-12-2020 23:42:55 ******/
CREATE TYPE [dbo].[ReconWarehouseQty] AS TABLE(
	[WarehouseID] [int] NOT NULL,
	[SkuWarehouse] [varchar](100) NOT NULL,
	[Qty] [int] NOT NULL,
	[StatusCode] [varchar](100) NULL,
	PRIMARY KEY CLUSTERED 
(
	[WarehouseID] ASC,
	[SkuWarehouse] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO


