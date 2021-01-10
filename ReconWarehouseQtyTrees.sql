USE [${Environment}Trees]
GO

/****** Object:  UserDefinedTableType [dbo].[ReconWarehouseQty]    Script Date: 29-12-2020 12:52:25 ******/
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


