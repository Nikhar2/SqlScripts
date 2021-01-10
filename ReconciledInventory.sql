USE [${Environment}International]
GO

/****** Object:  UserDefinedTableType [dbo].[ReconciledInventory]    Script Date: 28-12-2020 23:40:25 ******/
CREATE TYPE [dbo].[ReconciledInventory] AS TABLE(
	[Update] [bit] NOT NULL,
	[WarehouseManagerSKU] [varchar](100) NOT NULL,
	[WMAdjustments] [int] NOT NULL,
	[AvailableStoreInventory] [int] NOT NULL,
	[StoreAdjustments] [int] NOT NULL,
	[TotalStoreInventory] [int] NOT NULL,
	[TotalCurrentlyInSystem] [int] NOT NULL,
	[NewStoreAvailable] [int] NOT NULL,
	[Difference] [int] NOT NULL,
	[Shrink] [int] NOT NULL,
	[SKUStatus] [varchar](max) NULL,
	[ReconciliationComments] [varchar](max) NULL,
	[IsLinkedSku] [bit] NOT NULL,
	[ErrorMessage] [varchar](max) NULL,
	[ErrorType] [varchar](max) NULL,
	PRIMARY KEY CLUSTERED 
(
	[WarehouseManagerSKU] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO


