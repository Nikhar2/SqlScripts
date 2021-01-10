/****** Object:  UserDefinedFunction [dbo].[fn_GetReconSkuWarehouseLinks]    Script Date: 11/30/2020 11:26:14 AM ******/
USE [${Environment}Trees]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
*/
CREATE FUNCTION [dbo].[fn_GetReconSkuWarehouseLinks]
(	
)
RETURNS @table TABLE
(
	OriginalSkuWarehouse varchar(25) not null,
	SkuWarehouse varchar(25) not null,
	Qty int not null,
	WarehouseID int null
) 
AS
BEGIN
	declare @ReconWarehouseQty ReconWarehouseQty
	insert into @ReconWarehouseQty
	select warehouseid, skuwarehouse, qty, statuscode
	from reconwarehouseqty
	order by skuwarehouse, warehouseid
	 
	insert into @table
	select a.skuwarehouse, b.skuwarehouse, b.qty, b.warehouseid
	from skuwarehouselink a
	cross apply [fn_GetReconSkuWarehouseLinksWithInventoryByParent](a.skuwarehouse, null, @ReconWarehouseQty) b
	where a.parent is null
		
	RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetReconSkuWarehouseLinksWithInventoryByParent]    Script Date: 11/30/2020 11:26:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
*/
CREATE FUNCTION [dbo].[fn_GetReconSkuWarehouseLinksWithInventoryByParent]
(	
	@skuwarehouse varchar(25),
	@parentskuwarehouse varchar(25),
	@ReconWarehouseQty ReconWarehouseQty READONLY
)
RETURNS @table TABLE
(
	SkuWarehouse varchar(25) not null,
	Parent varchar(25) null,
	Qty int not null,
	WarehouseID int null
) 
AS
BEGIN 
	insert into @table
	select a.skuwarehouse, a.parentskuwarehouse, isnull(b.qty, 0), b.warehouseid 
	from (select @skuwarehouse as skuwarehouse, @parentskuwarehouse as parentskuwarehouse) a
	left join @ReconWarehouseQty b on (a.skuwarehouse = b.skuwarehouse)
	where a.skuwarehouse = @skuwarehouse
	declare @childskuwarehouse varchar(25) = (select skuwarehouse from skuwarehouselink where parent in (select id from skuwarehouselink where skuwarehouse = @skuwarehouse))
	if @childskuwarehouse is null
		return
	
	insert into @table
	select skuwarehouse, parent, qty, warehouseid
	from fn_GetReconSkuWarehouseLinksWithInventoryByParent(@childskuwarehouse, @skuwarehouse, @ReconWarehouseQty)	
	
	RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[fn_InlineMax]    Script Date: 11/30/2020 11:26:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
*/
CREATE FUNCTION [dbo].[fn_InlineMax] 
(
	@val1 int,
	@val2 int
)
RETURNS int
AS
BEGIN
  if @val1 > @val2
    return @val1
  return isnull(@val2,@val1)
END

GO
/****** Object:  UserDefinedFunction [dbo].[fn_LsnSegmentToHexa]    Script Date: 11/30/2020 11:26:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_LsnSegmentToHexa] (@InputData VARBINARY(32)) RETURNS VARCHAR(64)
AS
  BEGIN
    DECLARE  @HexDigits   	CHAR(16),
             @OutputData      VARCHAR(64),
             @i           	INT,
             @InputDataLength INT

    DECLARE  @ByteInfo  	INT,
             @LeftNibble 	INT,
             @RightNibble INT

    SET @OutputData = ''

    SET @i = 1

    SET @InputDataLength = DATALENGTH(@InputData)

    SET @HexDigits = '0123456789abcdef'

    WHILE (@i <= @InputDataLength)
      BEGIN
        SET @ByteInfo = CONVERT(INT,SUBSTRING(@InputData,@i,1))
        SET @LeftNibble= FLOOR(@ByteInfo / 16)
        SET @RightNibble = @ByteInfo - (@LeftNibble* 16)
        SET @OutputData = @OutputData + SUBSTRING(@HexDigits,@LeftNibble+ 1,1) + SUBSTRING(@HexDigits,@RightNibble + 1,1)
        SET @i = @i + 1
      END

    RETURN @OutputData

  END

GO
/****** Object:  UserDefinedFunction [dbo].[fn_NumericLsnToHexa]    Script Date: 11/30/2020 11:26:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_NumericLsnToHexa](@numeric25Lsn numeric(25,0)) returns varchar(32)
 AS
 BEGIN
/*
-- In order to avoid form sign overflow problems - declare the LSN segments 
-- to be one 'type' larger than the intendent target type.
-- For example, convert(smallint, convert(numeric(25,0),65535)) will fail 
-- but convert(binary(2), convert(int,convert(numeric(25,0),65535))) will give the 
-- expected result of 0xffff.
*/

declare @high4bytelsnSegment bigint,@mid4bytelsnSegment bigint,@low2bytelsnSegment int
declare @highFactor bigint, @midFactor int

declare @lsnLeftSeg	binary(4)
declare @lsnMidSeg	binary(4)
declare @lsnRightSeg	binary(2)

declare	@hexaLsn	varchar(32)

select @highFactor = 1000000000000000
select @midFactor  = 100000

select @high4bytelsnSegment = convert(bigint, floor(@numeric25Lsn / @highFactor))
select @numeric25Lsn = @numeric25Lsn - convert(numeric(25,0), @high4bytelsnSegment) * @highFactor
select @mid4bytelsnSegment = convert(bigint,floor(@numeric25Lsn / @midFactor ))
select @numeric25Lsn = @numeric25Lsn - convert(numeric(25,0), @mid4bytelsnSegment) * @midFactor
select @low2bytelsnSegment = convert(int, @numeric25Lsn)

set	@lsnLeftSeg	= convert(binary(4), @high4bytelsnSegment)
set	@lsnMidSeg	= convert(binary(4), @mid4bytelsnSegment)
set   @lsnRightSeg	= convert(binary(2), @low2bytelsnSegment)

return [dbo].[fn_LsnSegmentToHexa](@lsnLeftSeg)+':'+[dbo].[fn_LsnSegmentToHexa](@lsnMidSeg)+':'+[dbo].[fn_LsnSegmentToHexa](@lsnRightSeg)
END

GO
/****** Object:  UserDefinedFunction [dbo].[IR_FN_GetReconSkuWarehouseLinks]    Script Date: 11/30/2020 11:26:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
*/
CREATE FUNCTION [dbo].[IR_FN_GetReconSkuWarehouseLinks]
(	
)
RETURNS @table TABLE
(
	OriginalSkuWarehouse varchar(25) not null,
	SkuWarehouse varchar(25) not null,
	Qty int not null,
	WarehouseID int null
) 
AS
BEGIN
	declare @ReconWarehouseQty ReconWarehouseQty
	/*--take into account storewarehouses here*/
	insert into @ReconWarehouseQty
	select warehouseid, skuwarehouse, qty, statuscode
	from reconwarehouseqty
	order by skuwarehouse, warehouseid
	 
	insert into @table
	select a.skuwarehouse, b.skuwarehouse, b.qty, b.warehouseid
	from skuwarehouselink a
	cross apply [IR_FN_GetReconSkuWarehouseLinksWithInventoryByParent](a.skuwarehouse, null, @ReconWarehouseQty) b
	where a.parent is null
		
	RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[IR_FN_GetReconSkuWarehouseLinksWithInventoryByParent]    Script Date: 11/30/2020 11:26:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
*/
CREATE FUNCTION [dbo].[IR_FN_GetReconSkuWarehouseLinksWithInventoryByParent]
(	
	@skuwarehouse varchar(25),
	@parentskuwarehouse varchar(25),
	@ReconWarehouseQty ReconWarehouseQty READONLY
)
RETURNS @table TABLE
(
	SkuWarehouse varchar(25) not null,
	Parent varchar(25) null,
	Qty int not null,
	WarehouseID int null
) 
AS
BEGIN 
	insert into @table
	select a.skuwarehouse, a.parentskuwarehouse, isnull(b.qty, 0), b.warehouseid 
	from (select @skuwarehouse as skuwarehouse, @parentskuwarehouse as parentskuwarehouse) a
	left join @ReconWarehouseQty b on (a.skuwarehouse = b.skuwarehouse)
	where a.skuwarehouse = @skuwarehouse

	declare @childskuwarehouse varchar(25) = (select skuwarehouse from skuwarehouselink where parent in (select id from skuwarehouselink where skuwarehouse = @skuwarehouse))
	if @childskuwarehouse is null
		return
	
	insert into @table
	select skuwarehouse, parent, qty, warehouseid
	from IR_FN_GetReconSkuWarehouseLinksWithInventoryByParent(@childskuwarehouse, @skuwarehouse, @ReconWarehouseQty)	
	
	RETURN
END
GO
/****** Object:  Table [dbo].[Warehouse]    Script Date: 11/30/2020 11:26:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Warehouse](
	[WarehouseID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](200) NOT NULL,
	[FullName] [varchar](200) NOT NULL,
	[Address1] [varchar](200) NULL,
	[Address2] [varchar](200) NULL,
	[City] [varchar](200) NULL,
	[State] [varchar](200) NULL,
	[Zip] [varchar](200) NULL,
	[Phone] [varchar](200) NULL,
	[Priority] [int] NULL,
	[Email] [varchar](1000) NULL,
	[WarehouseTrackingNumberDirectory] [varchar](200) NULL,
	[InventoryLastLoaded] [datetime] NULL,
	[InventoryLastLoadedFile] [varchar](200) NULL,
	[InventoryLoadCount] [int] NULL,
	[InventoryLoadStatus] [varchar](200) NULL,
	[InventoryLoadMapping] [varchar](200) NULL,
	[ReconciledDate] [datetime] NULL,
	[FedexFile] [varchar](200) NULL,
	[FedexFileLoaded] [datetime] NULL,
	[FedexFileEffectiveDate] [varchar](200) NULL,
	[FedexFileOriginRange] [varchar](200) NULL,
	[Active] [bit] NOT NULL,
	[GenerateOrderFileCSV] [bit] NOT NULL,
	[GenerateOrderFileXML] [bit] NOT NULL,
	[SendViaFTP] [bit] NOT NULL,
	[SendViaEMAIL] [bit] NOT NULL,
	[WarehousePrefix] [varchar](100) NULL,
	[WarehouseOrdersDirectory] [varchar](200) NULL,
	[WarehouseInventoryDirectory] [varchar](200) NULL,
	[SendViaWebService] [bit] NOT NULL,
	[CheckFTPForFile] [bit] NOT NULL,
	[CutOffTime] [varchar](20) NULL,
	[SendCommercialInvoicesViaFTP] [bit] NOT NULL,
	[SendCommercialInvoicesViaEmail] [bit] NOT NULL,
	[FileIteration] [int] NOT NULL,
	[GenerateWarrantyOrderFileCSV] [bit] NOT NULL,
	[GenerateWarrantyOrderFileXML] [bit] NOT NULL,
	[SendNoOrdersNotificationEmail] [bit] NOT NULL,
	[HandlesTrackingNumbers] [bit] NOT NULL,
	[IsWarranty] [bit] NOT NULL,
	[DoNotResetFileIteration] [bit] NOT NULL,
	[HandlesPersonalization] [bit] NOT NULL,
	[UsesUniqueOrderID] [bit] NULL,
	[AutomatedTNPulling] [bit] NOT NULL,
	[FedExFreightEnabled] [bit] NOT NULL,
	[WarehouseAllocationToggle] [bit] NOT NULL,
	[GenerateOrderFileExcel] [bit] NOT NULL,
	[LocalDirectoryCommercialInvoices] [varchar](100) NOT NULL,
	[PersonalizationExclusive] [bit] NOT NULL,
	[TermsOfSale] [varchar](20) NOT NULL,
	[PersonalizationPriority] [int] NULL,
 CONSTRAINT [PK_Warehouse] PRIMARY KEY CLUSTERED 
(
	[WarehouseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Inventory]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Inventory](
	[WarehouseID] [int] NOT NULL,
	[Qty] [int] NULL,
	[Description] [varchar](max) NULL,
	[misc1] [varchar](max) NULL,
	[misc2] [varchar](max) NULL,
	[misc3] [varchar](max) NULL,
	[misc4] [varchar](max) NULL,
	[misc5] [varchar](max) NULL,
	[UpcID] [int] NOT NULL,
	[ActualHoldQty] [int] NOT NULL,
	[ActualWarehouseQty] [int] NULL,
 CONSTRAINT [PK_Inventory] PRIMARY KEY CLUSTERED 
(
	[WarehouseID] ASC,
	[UpcID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Upc]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Upc](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Upc] [nvarchar](100) NOT NULL,
	[VendorPartNumber] [nvarchar](100) NOT NULL,
	[Description] [varchar](1000) NOT NULL,
	[CartonNumber] [int] NOT NULL,
	[QuantityInCarton] [int] NOT NULL,
	[TotalCartons] [int] NOT NULL,
	[IsMasterPack] [bit] NOT NULL,
	[Length] [float] NULL,
	[LengthUoM] [nvarchar](25) NULL,
	[Width] [float] NULL,
	[WidthUoM] [nvarchar](25) NULL,
	[Height] [float] NULL,
	[HeightUoM] [nvarchar](25) NULL,
	[Weight] [float] NULL,
	[WeightUoM] [nvarchar](25) NULL,
	[CubicFeet] [float] NULL,
	[CubicFeetPerItem] [float] NULL,
	[LotCode] [int] NOT NULL,
	[IsDropShip] [bit] NOT NULL,
	[IsBackOrdered] [bit] NOT NULL,
	[DefaultPrice] [money] NULL,
	[PreferredCarrierID] [int] NULL,
	[WarrantyLotCode] [int] NOT NULL,
	[IsLTL] [bit] NOT NULL,
	[IsTree] [bit] NOT NULL,
	[IsRTP] [bit] NOT NULL,
	[IsFedExFreight] [bit] NOT NULL,
	[CommodityClass] [int] NULL,
 CONSTRAINT [PK_Upc] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[BrandSku]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrandSku](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BrandID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Comments] [varchar](255) NULL,
	[Alert] [varchar](255) NULL,
	[OrderNotes] [varchar](255) NULL,
	[Active] [bit] NOT NULL,
	[InternalSku] [varchar](255) NOT NULL,
 CONSTRAINT [PK_BrandSku] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BrandSkuUpc]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrandSkuUpc](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BrandSkuID] [int] NOT NULL,
	[UpcID] [int] NOT NULL,
	[GroupNumber] [int] NOT NULL,
	[QtyInGroup] [int] NULL,
 CONSTRAINT [PK_BrandSkuUpc] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SourceBrandSkuUpcRecon]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SourceBrandSkuUpcRecon](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[BrandSkuUpcID] [int] NOT NULL,
	[ReconPercentage] [float] NOT NULL,
	[AllocationThreshold] [int] NULL,
 CONSTRAINT [PK_SourceBrandSkuUpcRecon] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[VW_GetInventorySnapshotData]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[VW_GetInventorySnapshotData]
                    as
                    select distinct
                    Products.Sku as Sku,
                    Upc.LotCode as LotCode,
                    ISNULL(Warehouse.WarehouseID, -1) as WarehouseID,
                    ISNULL(Inventory.Qty, 0) as Quantity,
                    Upc.Upc as Upc,
                    NULL as Section,
                    cast(0 as bit) as IsEasyPlug,
                    cast(0 as bit) as IsException,
                    Upc.TotalCartons as TotalCartonsForUpc,
                    Products.RegionID as RegionID,
                    Upc.WarrantyLotCode as WarrantyLotCode,
                    Upc.Upc as RawUpc,
                    Upc.CartonNumber as CartonNumber,
                    Products.ReconPercentage as MaxReconPercentage,
                    Products.BrandID as BrandID
                    from
                    (
                    select BrandSku.InternalSku as Sku, Source.RegionID, BrandSkuUpc.UpcID, SourceBrandSkuUpcRecon.ReconPercentage, Source.BrandID, Source.ID as SourceID, Source.HandlesInventoryAllocation
                    from BrandSkuUpc
                    join BrandSku on BrandSkuUpc.BrandSkuID = BrandSku.ID
                    join SourceBrandSkuUpcRecon on BrandSkuUpc.ID = SourceBrandSkuUpcRecon.BrandSkuUpcID
                    join ${Environment}WarehouseManager..Source on SourceBrandSkuUpcRecon.SourceID = Source.ID
                    group by BrandSku.InternalSku, Source.RegionID, BrandSkuUpc.UpcID, SourceBrandSkuUpcRecon.ReconPercentage, Source.BrandID, Source.ID, Source.HandlesInventoryAllocation
                    ) Products
                    join Upc on Products.UpcID = Upc.ID
                    left join Inventory on Products.UpcID = Inventory.UpcID
                    left join Warehouse on Inventory.WarehouseID = Warehouse.WarehouseID and Warehouse.Active = 1
                    where Upc.LotCode > 0 and Products.HandlesInventoryAllocation = 1 and Products.ReconPercentage > 0; 
GO
/****** Object:  Table [dbo].[SourceWarehouse]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SourceWarehouse](
	[SourceID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[OrderFileGenerated] [datetime] NULL,
	[Active] [bit] NOT NULL,
	[Priority] [int] NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_StoreWarehouse] PRIMARY KEY CLUSTERED 
(
	[SourceID] ASC,
	[WarehouseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[VW_CurrentStandardInventoryWithBrandAndReconPercentage]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[VW_CurrentStandardInventoryWithBrandAndReconPercentage]
                    as                                 
                    select distinct                     
                    Products.Sku as Sku,
                    Upc.LotCode as LotCode,
                    ISNULL(Warehouse.WarehouseID, -1) as WarehouseID,
                    ISNULL(Inventory.Qty, 0) as Quantity,
                    Upc.Upc as Upc,
                    NULL as Section,
                    cast(0 as bit) as IsEasyPlug,
                    cast(0 as bit) as IsException,
                    Upc.TotalCartons as TotalCartonsForUpc,
                    Products.RegionID as RegionID,
                    Upc.WarrantyLotCode as WarrantyLotCode,
                    Upc.Upc as RawUpc,
                    Upc.CartonNumber as CartonNumber,
                    Products.ReconPercentage as MaxReconPercentage,
                    Products.BrandID as BrandID,
                    Upc.IsRTP,
                    Upc.IsMasterPack,
                    Upc.IsLTL,
                    Upc.IsFedExFreight
                    from
                    (
                    select BrandSku.InternalSku as Sku, Source.RegionID, BrandSkuUpc.UpcID, SourceBrandSkuUpcRecon.ReconPercentage, Source.BrandID
                    from BrandSkuUpc
                    join BrandSku on BrandSkuUpc.BrandSkuID = BrandSku.ID        
                    join SourceBrandSkuUpcRecon on BrandSkuUpc.ID = SourceBrandSkuUpcRecon.BrandSkuUpcID 
                    join ${Environment}WarehouseManager..Source on SourceBrandSkuUpcRecon.SourceID = Source.ID
                    group by BrandSku.InternalSku, Source.RegionID, BrandSkuUpc.UpcID, SourceBrandSkuUpcRecon.ReconPercentage, Source.BrandID
                    ) Products
                    join Upc on Products.UpcID = Upc.ID
                    left join Inventory on Products.UpcID = Inventory.UpcID
                    left join Warehouse on Inventory.WarehouseID = Warehouse.WarehouseID and Warehouse.Active = 1
                    left join SourceWarehouse on Inventory.WarehouseID = SourceWarehouse.WarehouseID and SourceWarehouse.Active = 1
                    left join ${Environment}WarehouseManager..Source on Products.RegionID = Source.RegionID and SourceWarehouse.SourceID = Source.ID
                    where Upc.LotCode > 0 and ${Environment}WarehouseManager..Source.HandlesInventoryAllocation = 1 and Products.ReconPercentage > 0
GO
/****** Object:  View [dbo].[VW_CurrentStandardInventory]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_CurrentStandardInventory] as
            SELECT DISTINCT Sku, LotCode, WarehouseID, Quantity, Upc, Section, IsEasyPlug, IsException, TotalCartonsForUpc, RegionID, WarrantyLotCode, RawUpc, CartonNumber, IsRTP, IsMasterPack, IsLTL, IsFedExFreight
            FROM dbo.VW_CurrentStandardInventoryWithBrandAndReconPercentage
GO
/****** Object:  View [dbo].[CustOrderSku]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Object:  Table [dbo].[AmazonInventoryPendingUpdate]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AmazonInventoryPendingUpdate](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Sku] [varchar](100) NOT NULL,
	[Qty] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
 CONSTRAINT [PK_AmazonInventoryPendingUpdate] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AmazonSettings]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AmazonSettings](
	[MarketplaceID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyName] [nvarchar](255) NOT NULL,
	[SellerID] [nvarchar](255) NOT NULL,
	[AccessKey] [nvarchar](255) NOT NULL,
	[SecretKey] [nvarchar](255) NOT NULL,
	[Site] [nvarchar](255) NOT NULL,
	[Username] [nvarchar](255) NOT NULL,
	[Password] [nvarchar](255) NOT NULL,
	[MarketplaceName] [nvarchar](255) NOT NULL,
	[Marketplace] [nvarchar](255) NOT NULL,
	[SourceID] [int] NOT NULL,
	[BypassOrders] [bit] NOT NULL,
	[BrandID] [int] NOT NULL,
	[LastOrderRequest] [datetime] NOT NULL,
	[LastOrderLineRequest] [datetime] NOT NULL,
	[LastOrderRequestsRemaining] [int] NOT NULL,
	[LastOrderLineRequestsRemaining] [int] NOT NULL,
	[FulfilledByThirdParty] [bit] NOT NULL,
	[ServiceURL] [varchar](255) NOT NULL,
	[OrderStatuses] [varchar](255) NOT NULL,
	[FulfillmentChannels] [varchar](255) NOT NULL,
	[FromDate] [datetime] NULL,
	[ToDate] [datetime] NULL,
	[FulfillmentType] [varchar](255) NULL,
 CONSTRAINT [PK_AmazonSettings] PRIMARY KEY CLUSTERED 
(
	[MarketplaceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AmazonTrackingNumberInProcessing]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AmazonTrackingNumberInProcessing](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MarketplaceOrderReferenceNumber] [varchar](255) NOT NULL,
	[SourceRefNum] [varchar](255) NOT NULL,
	[TrackingNumber] [varchar](255) NOT NULL,
	[UPC] [varchar](255) NOT NULL,
	[StoreSku] [varchar](255) NOT NULL,
	[UploadedDate] [datetime] NULL,
	[MarketplaceOrderLineItemID] [int] NOT NULL,
	[MarketplaceAmazonFeedStatusInProcessingID] [int] NULL,
	[SourceID] [int] NOT NULL,
 CONSTRAINT [PK_MarketplaceTrackingNumberInProcessing] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AmendmentCorrelation]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AmendmentCorrelation](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](200) NOT NULL,
	[ID] [uniqueidentifier] NOT NULL,
	[ExternalID] [varchar](max) NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [text] NOT NULL,
	[ParentAmendmentCorrelationID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_AmendmentCorrelation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AmendmentQueue]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AmendmentQueue](
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](200) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[IsShippingAddressOnlyAmendment] [bit] NOT NULL,
	[ID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_AmendmentQueue] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AmendmentStagedOrder]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AmendmentStagedOrder](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](200) NOT NULL,
	[SalesforceOrderExtensionID] [int] NOT NULL,
	[CustomerID] [varchar](100) NOT NULL,
	[CVV2_Response] [varchar](255) NULL,
	[AVS] [varchar](255) NULL,
	[Total_Payment_Authorized] [money] NULL,
	[Total_Payment_Received] [money] NULL,
	[PaymentAmount] [varchar](255) NULL,
	[BillingFirstName] [varchar](255) NULL,
	[BillingLastName] [varchar](255) NULL,
	[BillingAddress1] [varchar](255) NULL,
	[BillingAddress2] [varchar](255) NULL,
	[BillingCity] [varchar](255) NULL,
	[BillingCompanyName] [varchar](255) NULL,
	[BillingCountry] [varchar](255) NULL,
	[BillingFaxNumber] [varchar](255) NULL,
	[BillingPhoneNumber] [varchar](255) NULL,
	[BillingPostalCode] [varchar](255) NULL,
	[BillingState] [varchar](255) NULL,
	[SalesRep_CustomerID] [varchar](100) NULL,
	[UploadedDate] [datetime] NULL,
	[CC_Last4] [varchar](255) NULL,
	[OrderStatus] [varchar](100) NOT NULL,
	[TaxExemptOrder] [bit] NOT NULL,
	[Currency] [varchar](20) NULL,
	[DoNotSendToSf] [bit] NOT NULL,
	[DateEntered] [datetime] NULL,
	[SalesforceOrderStatus] [varchar](100) NOT NULL,
	[AmendmentCorrelationID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_AmendmentStagedOrder] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AmendmentStagedOrderDetail]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AmendmentStagedOrderDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](200) NOT NULL,
	[SalesforceOrderExtensionID] [int] NOT NULL,
	[SalesforceOrderDetailExtensionID] [int] NULL,
	[OrderDetailID] [varchar](100) NOT NULL,
	[ProductName] [varchar](1000) NULL,
	[StoreSku] [varchar](255) NOT NULL,
	[TaxableProduct] [bit] NOT NULL,
	[OriginalQuantity] [int] NOT NULL,
	[CurrentQuantity] [int] NOT NULL,
	[LastModified] [datetime] NULL,
	[Options] [varchar](max) NULL,
	[DateEntered] [datetime] NOT NULL,
	[Processed] [bit] NOT NULL,
	[AmendmentCorrelationID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_AmendmentStagedOrderDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AmendmentStagedOrderDiscountDetail]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AmendmentStagedOrderDiscountDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AmendmentCorrelationID] [uniqueidentifier] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](200) NOT NULL,
	[SalesforceOrderExtensionID] [int] NULL,
	[SalesforceOrderDetailExtensionID] [int] NULL,
	[OrderDetailID] [varchar](100) NOT NULL,
	[ProductName] [varchar](1000) NULL,
	[StoreSku] [varchar](255) NOT NULL,
	[SalesforceID] [varchar](255) NULL,
	[LastModified] [datetime] NULL,
	[OrderEntryID] [varchar](255) NOT NULL,
	[ParentOrderDetailID] [varchar](255) NOT NULL,
	[Amount] [decimal](19, 5) NULL,
	[DetailTypeID] [int] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
 CONSTRAINT [PK_AmendmentStagedOrderDiscountDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AmendmentStagedOrderTax]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AmendmentStagedOrderTax](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](200) NOT NULL,
	[SalesforceOrderTaxExtensionID] [int] NULL,
	[SalesforceOrderDetailExtensionID] [int] NULL,
	[Name] [varchar](100) NOT NULL,
	[TaxType] [varchar](50) NOT NULL,
	[Amount] [decimal](19, 5) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[SalesforceTaxID] [varchar](100) NOT NULL,
	[AmendmentCorrelationID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_AmendmentStagedOrderTax] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ApprovedSkus]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApprovedSkus](
	[Store SKU] [nvarchar](255) NULL,
	[Product Name] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[awsdms_truncation_safeguard]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[awsdms_truncation_safeguard](
	[latchTaskName] [varchar](128) NOT NULL,
	[latchMachineGUID] [varchar](40) NOT NULL,
	[LatchKey] [char](1) NOT NULL,
	[latchLocker] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[latchTaskName] ASC,
	[latchMachineGUID] ASC,
	[LatchKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BatchedHybrisTrackingNumber]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BatchedHybrisTrackingNumber](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
	[PublishedAt] [datetime] NULL,
	[Sku] [varchar](255) NOT NULL,
	[TrackingNumber] [varchar](255) NOT NULL,
	[SourceRefNum] [varchar](255) NOT NULL,
	[BrandCode] [varchar](255) NOT NULL,
	[SourceID] [int] NOT NULL,
	[ShipDate] [datetime] NOT NULL,
	[TrackingUrl] [varchar](255) NOT NULL,
	[CartonNumber] [int] NOT NULL,
	[ShipMethod] [varchar](255) NOT NULL,
	[TotalCartons] [int] NOT NULL,
 CONSTRAINT [PK_BatchedHybrisTrackingNumber] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BatchedSalesforceTrackingNumber]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BatchedSalesforceTrackingNumber](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
	[PublishedAt] [datetime] NULL,
	[SourceID] [int] NOT NULL,
	[WarehouseID] [int] NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[TrackingNumber] [varchar](255) NULL,
	[SourceRefNum] [varchar](255) NULL,
	[ShipDate] [datetime] NULL,
	[ShipMethod] [varchar](255) NOT NULL,
	[SalesforceOrderItemID] [varchar](255) NULL,
	[SalesforceInternalID] [varchar](255) NOT NULL,
	[SalesforceBatchID] [varchar](255) NULL,
 CONSTRAINT [PK_BatchedSalesforceTrackingNumber] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BrandSkuBackOrder]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrandSkuBackOrder](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](200) NULL,
	[BrandSkuID] [int] NOT NULL,
	[Active] [bit] NOT NULL,
 CONSTRAINT [PK_StoreSkuBackOrder] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BrandSkuFraudItem]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrandSkuFraudItem](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BrandSkuID] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[Description] [varchar](200) NULL,
	[BrandID] [int] NOT NULL,
 CONSTRAINT [PK_StoreSkuFraudItem] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BrontoApiSettings]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoApiSettings](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ApiType] [varchar](30) NOT NULL,
	[ClientID] [varchar](255) NOT NULL,
	[ClientPassword] [varchar](255) NOT NULL,
	[ApiToken] [varchar](255) NULL,
	[ApiRefreshToken] [varchar](255) NULL,
	[ApiTokenTimeout] [datetime] NULL,
	[ApiRefreshTokenTimeout] [datetime] NULL,
	[BrandID] [int] NOT NULL,
 CONSTRAINT [PK_BrontoApiSettings] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BrontoBrandSkuImage]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoBrandSkuImage](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Sku] [varchar](30) NOT NULL,
	[ProductName] [varchar](1000) NULL,
	[ImageUrl] [varchar](255) NOT NULL,
	[DateUpdated] [datetime] NOT NULL,
	[SourceID] [int] NOT NULL,
	[ProductURL] [varchar](255) NULL,
	[DateEntered] [datetime] NOT NULL,
	[EmailSent] [bit] NOT NULL,
	[Active] [bit] NOT NULL,
	[Notes] [varchar](max) NULL,
 CONSTRAINT [PK_BrontoStoreSkuImage] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BrontoEmailContact]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoEmailContact](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Email] [varchar](255) NOT NULL,
	[ExternalContactID] [varchar](255) NOT NULL,
	[SourceID] [int] NOT NULL,
	[Invalid] [bit] NOT NULL,
 CONSTRAINT [PK_BrontoEmailContact] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BrontoEmailTemplate]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoEmailTemplate](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MessageId] [varchar](255) NOT NULL,
	[Type] [varchar](30) NOT NULL,
	[Description] [varchar](100) NOT NULL,
	[SourceID] [int] NOT NULL,
	[ShippingConfirmationVersion] [varchar](50) NOT NULL,
 CONSTRAINT [PK_BrontoEmailTemplate] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BrontoEmailTemplateFields]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoEmailTemplateFields](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TemplateID] [int] NOT NULL,
	[Field] [varchar](50) NOT NULL,
	[Description] [varchar](50) NOT NULL,
	[IsCollection] [bit] NOT NULL,
	[DefaultValue] [varchar](250) NOT NULL,
 CONSTRAINT [PK_BrontoEmailTemplateFields] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BrontoOrderEmail]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoOrderEmail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceRefNum] [varchar](50) NULL,
	[SourceID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[EmailContactID] [int] NOT NULL,
	[OrderType] [varchar](100) NULL,
 CONSTRAINT [PK_BrontoOrderEmail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BrontoOrderEmailConfirmation]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoOrderEmailConfirmation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OrderEmailID] [int] NOT NULL,
	[LineItem] [varchar](255) NULL,
	[Sku] [varchar](30) NOT NULL,
	[Qty] [int] NOT NULL,
	[DateSent] [datetime] NULL,
	[StoreSkuImageID] [int] NOT NULL,
 CONSTRAINT [PK_BrontoOrderEmailConfirmation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BrontoOrderEmailTrackingNumber]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoOrderEmailTrackingNumber](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OrderEmailID] [int] NOT NULL,
	[Sku] [varchar](30) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[ShippingMethodID] [varchar](20) NOT NULL,
	[Qty] [int] NOT NULL,
	[Upc] [varchar](50) NOT NULL,
	[TrackingNumber] [varchar](50) NULL,
	[StoreSkuImageID] [int] NOT NULL,
	[DateSent] [datetime] NULL,
	[DateTrackingNumberReceived] [datetime] NULL,
	[ShipDate] [datetime] NULL,
 CONSTRAINT [PK_BrontoOrderEmailTrackingNumber] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CatalogOrder]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CatalogOrder](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceRefNum] [varchar](25) NOT NULL,
	[FirstName] [varchar](100) NOT NULL,
	[LastName] [varchar](100) NOT NULL,
	[ShippingAddress1] [varchar](100) NOT NULL,
	[ShippingAddress2] [varchar](100) NULL,
	[PostalCode] [varchar](100) NOT NULL,
	[City] [varchar](100) NOT NULL,
	[State] [varchar](100) NOT NULL,
	[Country] [varchar](100) NOT NULL,
	[SourceID] [int] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[Year]  AS (datepart(year,[DateEntered])) PERSISTED,
 CONSTRAINT [PK_CatalogOrder] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CommercialInvoice]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CommercialInvoice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [nvarchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[GeneratedFilePath] [nvarchar](max) NOT NULL,
	[DeliveredFilePath] [nvarchar](max) NULL,
	[WarehouseID] [int] NOT NULL,
	[Delivered] [bit] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[SentViaEmail] [bit] NOT NULL,
	[SentViaFTP] [bit] NOT NULL,
	[DateDelivered] [datetime] NULL,
 CONSTRAINT [PK_CommercialInvoice] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CountryPriority]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryPriority](
	[Country] [varchar](100) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Priority] [int] NOT NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_CountryPriority] PRIMARY KEY CLUSTERED 
(
	[Country] ASC,
	[WarehouseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customer]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[BillingAddress1] [nvarchar](255) NOT NULL,
	[BillingAddress2] [nvarchar](255) NOT NULL,
	[CatalogSubscriber] [nvarchar](255) NOT NULL,
	[Checkbox_For_New_Customers] [nvarchar](255) NOT NULL,
	[City] [nvarchar](255) NOT NULL,
	[CompanyName] [nvarchar](255) NOT NULL,
	[Country] [nvarchar](255) NOT NULL,
	[Custom_Field_Custom1] [nvarchar](255) NOT NULL,
	[Custom_Field_Custom2] [nvarchar](255) NOT NULL,
	[Custom_Field_Custom3] [nvarchar](255) NOT NULL,
	[Custom_Field_Custom4] [nvarchar](255) NOT NULL,
	[Custom_Field_Custom5] [nvarchar](255) NOT NULL,
	[Customer_IsAnonymous] [nvarchar](255) NOT NULL,
	[Customer_Notes] [nvarchar](255) NOT NULL,
	[CustomerType] [nvarchar](255) NOT NULL,
	[EmailAddress] [nvarchar](255) NOT NULL,
	[EmailSubscriber] [nvarchar](255) NOT NULL,
	[FaxNumber] [nvarchar](255) NOT NULL,
	[FirstDateVisited] [datetime] NULL,
	[FirstOrderDate] [datetime] NULL,
	[FirstName] [nvarchar](255) NOT NULL,
	[LastLogin] [datetime] NULL,
	[LastName] [nvarchar](255) NOT NULL,
	[PhoneNumber] [nvarchar](255) NOT NULL,
	[State] [nvarchar](255) NOT NULL,
	[PostalCode] [nvarchar](255) NOT NULL,
	[SourceRefNum] [varchar](255) NOT NULL,
	[TaxExemptAccount] [bit] NOT NULL,
	[DateEntered] [datetime] NULL,
	[DateLastModified] [datetime] NULL,
	[OrderPlaced] [bit] NOT NULL,
	[SourceID] [int] NOT NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customer_WHM_SourceRefNum]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer_WHM_SourceRefNum](
	[ID] [int] NOT NULL,
	[SourceID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[BillingAddress1] [nvarchar](255) NOT NULL,
	[BillingAddress2] [nvarchar](255) NOT NULL,
	[CatalogSubscriber] [nvarchar](255) NOT NULL,
	[Checkbox_For_New_Customers] [nvarchar](255) NOT NULL,
	[City] [nvarchar](255) NOT NULL,
	[CompanyName] [nvarchar](255) NOT NULL,
	[Country] [nvarchar](255) NOT NULL,
	[Custom_Field_Custom1] [nvarchar](255) NOT NULL,
	[Custom_Field_Custom2] [nvarchar](255) NOT NULL,
	[Custom_Field_Custom3] [nvarchar](255) NOT NULL,
	[Custom_Field_Custom4] [nvarchar](255) NOT NULL,
	[Custom_Field_Custom5] [nvarchar](255) NOT NULL,
	[Customer_IsAnonymous] [nvarchar](255) NOT NULL,
	[Customer_Notes] [nvarchar](255) NOT NULL,
	[CustomerType] [nvarchar](255) NOT NULL,
	[EmailAddress] [nvarchar](255) NOT NULL,
	[EmailSubscriber] [nvarchar](255) NOT NULL,
	[FaxNumber] [nvarchar](255) NOT NULL,
	[FirstDateVisited] [datetime] NULL,
	[FirstOrderDate] [datetime] NULL,
	[FirstName] [nvarchar](255) NOT NULL,
	[LastLogin] [datetime] NULL,
	[LastName] [nvarchar](255) NOT NULL,
	[PhoneNumber] [nvarchar](255) NOT NULL,
	[State] [nvarchar](255) NOT NULL,
	[PostalCode] [nvarchar](255) NOT NULL,
	[SourceRefNum] [varchar](255) NOT NULL,
	[TaxExemptAccount] [bit] NOT NULL,
	[DateEntered] [datetime] NULL,
	[DateLastModified] [datetime] NULL,
 CONSTRAINT [PK_Customer_WHM_SourceRefNum] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DataToLoad]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataToLoad](
	[UPC] [varchar](50) NULL,
	[Store SKU] [varchar](50) NULL,
	[Brand] [varchar](50) NULL,
	[Percent] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DeliveredLineItemHistory]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeliveredLineItemHistory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderIDForWarehouse] [varchar](255) NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Qty] [int] NOT NULL,
	[DateDelivered] [datetime] NOT NULL,
	[WarehouseReferenceNumber] [varchar](255) NULL,
	[IsResend] [bit] NOT NULL,
	[IsReroute] [bit] NOT NULL,
	[IsSuccessful] [bit] NOT NULL,
	[ShippingMethodID] [varchar](255) NULL,
	[OrderID] [int] NULL,
	[PlatformID] [int] NOT NULL,
	[OrderType] [varchar](100) NULL,
	[ShipAddress1] [varchar](200) NULL,
	[ShipAddress2] [varchar](200) NULL,
	[ShipCity] [varchar](200) NULL,
	[ShipState] [varchar](200) NULL,
	[ShipPostalCode] [varchar](200) NULL,
	[ShipFirstName] [varchar](200) NULL,
	[ShipLastName] [varchar](200) NULL,
	[ShipCompanyName] [varchar](200) NULL,
	[OrderDate] [datetime] NULL,
	[SourceID] [int] NOT NULL,
	[WarehouseShippingMethodID] [varchar](50) NOT NULL,
	[CarrierCode] [varchar](255) NULL,
 CONSTRAINT [PK_DeliveredLineItemHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FedExAddressValidationAttributes]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FedExAddressValidationAttributes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FedExAttribute] [varchar](255) NOT NULL,
	[Active] [bit] NOT NULL,
 CONSTRAINT [PK_FedExAddressValidationAttributes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[freightUpcs]    Script Date: 11/30/2020 11:26:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[freightUpcs](
	[Upc] [nvarchar](50) NOT NULL,
	[Carrier_Code] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HeavyGoodBackup]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HeavyGoodBackup](
	[id] [int] NOT NULL,
	[upc] [varchar](20) NOT NULL,
	[isltl] [bit] NOT NULL,
	[isheavygood] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HeavyGoodsFileGenerated]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HeavyGoodsFileGenerated](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FileName] [varchar](max) NOT NULL,
	[OutboundPath] [varchar](max) NOT NULL,
	[InboundPath] [varchar](max) NOT NULL,
	[SourceID] [int] NOT NULL,
	[BrandCode] [varchar](100) NOT NULL,
	[BrandID] [int] NOT NULL,
	[SourceRefNum] [varchar](200) NOT NULL,
	[ShipmentID] [varchar](200) NOT NULL,
	[OrderIdForWarehouse] [varchar](200) NOT NULL,
	[ShippingMethodID] [varchar](100) NOT NULL,
	[Upc] [varchar](100) NOT NULL,
	[Quantity] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[LabelReceivedFromWorldship] [bit] NOT NULL,
	[RecordImportedIntoWorldship] [bit] NOT NULL,
	[SentToWarehouse] [bit] NOT NULL,
	[TrackingNumberProcessed] [bit] NOT NULL,
	[Error] [bit] NOT NULL,
 CONSTRAINT [PK_HeavyGoodsFileGenerated] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HybrisNotifyMe]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HybrisNotifyMe](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[Email] [varchar](255) NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[DateAdded] [datetime] NOT NULL,
	[Active] [bit] NOT NULL,
	[InStockNotificationDate] [datetime] NULL,
	[BrontoStoreSkuImageID] [int] NULL,
	[BrontoEmailContactID] [int] NULL,
	[HasBeenSent] [bit] NOT NULL,
 CONSTRAINT [PK_HybrisNotifyMe] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IncompatibleUPC]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IncompatibleUPC](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UpcID] [int] NOT NULL,
	[IncompatibleUpcID] [int] NOT NULL,
 CONSTRAINT [PK_IncompatibleUPC] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvalidLineItemTrackingNumberDetail]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvalidLineItemTrackingNumberDetail](
	[SourceID] [int] NOT NULL,
	[WarehouseReferenceNumber] [varchar](255) NULL,
	[TrackingNumber] [varchar](200) NOT NULL,
	[ShipMethod] [varchar](255) NULL,
	[ShipDate] [datetime] NULL,
	[Gateway] [varchar](200) NULL,
	[ShipmentCost] [varchar](100) NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[ErrorMessage] [nvarchar](max) NULL,
	[UPC] [nvarchar](100) NULL,
	[Source] [varchar](max) NOT NULL,
	[FromFile] [bit] NOT NULL,
	[FromAPI] [bit] NOT NULL,
	[LoadedOn] [datetime] NOT NULL,
	[LoadedBy] [varchar](100) NOT NULL,
	[IsWarranty] [bit] NULL,
	[OrderID] [int] NULL,
	[SourceRefNum] [varchar](255) NULL,
	[Quantity] [int] NOT NULL,
	[BrandID] [int] NULL,
 CONSTRAINT [PK_InvalidLineItemTrackingNumberDetail_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvalidOrder]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvalidOrder](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[ShippingMethodID] [varchar](50) NULL,
	[ShipFirstName] [nvarchar](100) NOT NULL,
	[ShipLastName] [nvarchar](100) NOT NULL,
	[ShipAddress1] [nvarchar](100) NOT NULL,
	[ShipAddress2] [nvarchar](100) NULL,
	[ShipCity] [nvarchar](100) NOT NULL,
	[ShipState] [nvarchar](50) NOT NULL,
	[ShipPostalCode] [nvarchar](50) NOT NULL,
	[ShipCountry] [nvarchar](50) NOT NULL,
	[ShipCompanyName] [nvarchar](100) NULL,
	[EmailAddress] [nvarchar](100) NULL,
	[ShipPhoneNumber] [nvarchar](50) NULL,
	[OrderComments] [nvarchar](max) NULL,
	[OrderNotes] [nvarchar](max) NULL,
	[ShipResidential] [nvarchar](25) NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[Error] [nvarchar](max) NOT NULL,
	[ValidationStatus] [varchar](50) NULL,
	[OverrideErrorsAndWarnings] [bit] NULL,
	[FileName] [nvarchar](max) NOT NULL,
	[PlatformID] [int] NOT NULL,
	[CustomerID] [varchar](100) NULL,
	[OrderID] [int] NOT NULL,
	[PreferredShipDate] [datetime] NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[OrderType] [varchar](100) NOT NULL,
	[OrderTotal] [decimal](19, 5) NOT NULL,
	[DestinationType] [int] NULL,
 CONSTRAINT [PK_InvalidOrder] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvalidOrderLineItem]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvalidOrderLineItem](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InvalidOrderID] [int] NOT NULL,
	[LineItemID] [int] NOT NULL,
	[Status] [nvarchar](50) NULL,
	[StatusMessage] [nvarchar](max) NULL,
	[Comments] [nvarchar](max) NULL,
	[Sku] [nvarchar](100) NOT NULL,
	[ProductPrice] [decimal](19, 5) NOT NULL,
	[Quantity] [int] NOT NULL,
	[Options] [varchar](max) NULL,
	[TaxableProduct] [bit] NOT NULL,
	[OrderDetailID] [varchar](100) NULL,
 CONSTRAINT [PK_InvalidOrderLineItem] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvalidOrderLineItemUpcDetail]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvalidOrderLineItemUpcDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InvalidOrderLineItemID] [int] NOT NULL,
	[Upc] [varchar](200) NOT NULL,
	[WarehouseID] [int] NULL,
	[Qty] [int] NOT NULL,
 CONSTRAINT [PK_InvalidOrderLineItemUpcDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryHistory]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DateArchived] [datetime] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[SkuWarehouse] [varchar](100) NOT NULL,
	[Qty] [int] NULL,
	[Description] [varchar](max) NULL,
	[Misc1] [varchar](max) NULL,
	[Misc2] [varchar](max) NULL,
	[Misc3] [varchar](max) NULL,
	[Misc4] [varchar](max) NULL,
	[Misc5] [varchar](max) NULL,
 CONSTRAINT [PK_InventoryHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryHoldForWarehouse]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryHoldForWarehouse](
	[UpcID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[HoldQty] [int] NOT NULL,
	[EffectiveDate] [datetime] NOT NULL,
	[ExpiryDate] [datetime] NULL,
	[Comment] [varchar](255) NULL,
	[StatusCodeID] [int] NOT NULL,
 CONSTRAINT [PK_InventoryHoldForWarehouse] PRIMARY KEY CLUSTERED 
(
	[UpcID] ASC,
	[WarehouseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryReconciliationRunHistory]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryReconciliationRunHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LastReconciliationRun] [datetime] NOT NULL,
	[VolusionUpdated] [datetime] NULL,
	[User] [varchar](200) NOT NULL,
	[ForWarehouseIDs] [varchar](200) NOT NULL,
 CONSTRAINT [PK_InventoryReconciliationRunHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryThreshold]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryThreshold](
	[WarehouseID] [int] NOT NULL,
	[SkuLevel] [int] NOT NULL,
	[SkuAmount] [int] NOT NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_InventoryThreshold] PRIMARY KEY CLUSTERED 
(
	[WarehouseID] ASC,
	[SkuLevel] ASC,
	[SkuAmount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvPurchaseCarton]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvPurchaseCarton](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CartonNumber] [varchar](50) NOT NULL,
 CONSTRAINT [PK_InvPurchaseCarton] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvPurchaseInvoice]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvPurchaseInvoice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ShippedDate] [datetime] NULL,
	[ReceivedDate] [datetime] NULL,
	[InvoiceNumber] [varchar](50) NOT NULL,
	[InvPurchaseReceiptFileID] [int] NOT NULL,
	[InvoiceDate] [datetime] NULL,
 CONSTRAINT [PK_WarehouseInvoice] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvPurchaseInvoiceProduct]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvPurchaseInvoiceProduct](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Container] [varchar](100) NOT NULL,
	[InvoiceQuantity] [int] NOT NULL,
	[QuantityReceived] [int] NULL,
	[InvPurchaseReceiptProductID] [int] NOT NULL,
	[InvPurchaseInvoiceID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
 CONSTRAINT [PK_WarehouseInvoiceProduct] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvPurchaseProduct]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvPurchaseProduct](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VendorPartNumber] [varchar](100) NOT NULL,
	[ProductCode] [varchar](100) NOT NULL,
 CONSTRAINT [PK_InvPurchaseProduct] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvPurchaseProductCarton]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvPurchaseProductCarton](
	[InvPurchaseProductID] [int] NOT NULL,
	[InvPurchaseCartonID] [int] NOT NULL,
 CONSTRAINT [PK_InvPurchaseProductCarton] PRIMARY KEY CLUSTERED 
(
	[InvPurchaseProductID] ASC,
	[InvPurchaseCartonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvPurchaseReceiptFile]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvPurchaseReceiptFile](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FileName] [varchar](300) NOT NULL,
	[OriginalFileName] [varchar](300) NULL,
	[DateLoaded] [datetime] NOT NULL,
 CONSTRAINT [PK_InvPurchaseReceiptFile] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvPurchaseReceiptProduct]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvPurchaseReceiptProduct](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InvPurchaseReceiptFileID] [int] NOT NULL,
	[InvPurchaseProductID] [int] NOT NULL,
	[UnitCost] [decimal](18, 4) NOT NULL,
 CONSTRAINT [PK_InvPurchaseReceiptProduct] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvPurchaseReceiptProductStoreAssociation]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvPurchaseReceiptProductStoreAssociation](
	[SourceID] [int] NOT NULL,
	[InvPurchaseReceiptProductID] [int] NOT NULL,
 CONSTRAINT [PK_InvPurchaseReceiptProductStoreAssociation] PRIMARY KEY CLUSTERED 
(
	[SourceID] ASC,
	[InvPurchaseReceiptProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IsTreeSkus]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IsTreeSkus](
	[UPC] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LineItemRequiringTrackingNumber]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LineItemRequiringTrackingNumber](
	[SourceRefNum] [varchar](50) NULL,
	[WarehouseID] [int] NOT NULL,
	[ProcessedDate] [datetime] NULL,
	[Comments] [varchar](max) NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StoreSku] [nvarchar](50) NULL,
	[WarehouseReferenceNumber] [varchar](255) NULL,
	[TotalTNs] [int] NOT NULL,
	[ReceivedTNs] [int] NOT NULL,
	[ShippingMethod] [varchar](50) NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceID] [int] NOT NULL,
 CONSTRAINT [PK_UpcForLineItemRequiringTrackingNumber_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LoadedUndeliveredLineItem]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoadedUndeliveredLineItem](
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](50) NOT NULL,
	[BrandSkuID] [int] NOT NULL,
	[Qty] [int] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[OrderID] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LoadedUndeliveredLineItemWithAllocationDetails]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoadedUndeliveredLineItemWithAllocationDetails](
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](50) NOT NULL,
	[BrandSkuID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[UpcID] [int] NOT NULL,
	[Qty] [int] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[OrderID] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LotCodePriority]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LotCodePriority](
	[LotCode] [int] NOT NULL,
	[Priority] [int] NOT NULL,
 CONSTRAINT [PK_LotCodePriority] PRIMARY KEY CLUSTERED 
(
	[LotCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LtlCustomerCodeLookUp]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LtlCustomerCodeLookUp](
	[Sku] [varchar](100) NOT NULL,
	[CustomerCode] [varchar](100) NOT NULL,
 CONSTRAINT [PK_LtlCustomerCodeLookUp] PRIMARY KEY CLUSTERED 
(
	[Sku] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LTLUpcsToUpdate]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LTLUpcsToUpdate](
	[UpcToUpdate] [varchar](200) NULL,
	[Weight] [float] NULL,
	[Length] [float] NULL,
	[Width] [float] NULL,
	[Height] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Mapping]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Mapping](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MappingCategoryID] [int] NOT NULL,
	[MappingFileCategoryID] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[HasHeader] [bit] NOT NULL,
	[Delimiter/SpreadSheet] [varchar](50) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[NumOfHeaderRows] [int] NULL,
	[IsDefault] [bit] NOT NULL,
 CONSTRAINT [PK_MappingFiles] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MappingCategory]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MappingCategory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](200) NOT NULL,
 CONSTRAINT [PK_MappingCategory_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MappingCategoryField]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MappingCategoryField](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MappingCategoryID] [int] NOT NULL,
	[MappingCategoryFieldDetailID] [int] NOT NULL,
 CONSTRAINT [PK_MappingCategoryField] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MappingCategoryFieldDetail]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MappingCategoryFieldDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](100) NOT NULL,
	[ColumnName] [varchar](100) NOT NULL,
	[Required] [bit] NOT NULL,
 CONSTRAINT [PK_MappingCategoryFieldDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MappingCategoryFieldWarehouse]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MappingCategoryFieldWarehouse](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[MappingCategoryID] [int] NOT NULL,
	[MappingCategoryFieldDetailID] [int] NOT NULL,
 CONSTRAINT [PK_MappingCategoryFieldWarehouse] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MappingDetail]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MappingDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MappingID] [int] NOT NULL,
	[MappingCategoryFieldDetailID] [int] NOT NULL,
	[MappingPosition] [int] NULL,
 CONSTRAINT [PK_MappingDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MappingFileCategory]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MappingFileCategory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](50) NOT NULL,
	[Active] [bit] NOT NULL,
 CONSTRAINT [PK_FileCategory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MarketplaceAmazonFeedStatusInProcessing]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MarketplaceAmazonFeedStatusInProcessing](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FeedSubmissionID] [varchar](255) NOT NULL,
	[FeedSubmissionStartDateTime] [datetime] NOT NULL,
	[FeedType] [varchar](255) NOT NULL,
	[FeedSubmissionCompletedDateTime] [datetime] NULL,
	[NumberOfRecordsSent] [int] NOT NULL,
	[NumberOfRecordsSuccessful] [int] NULL,
	[RawRequestData] [varchar](max) NOT NULL,
	[SourceID] [int] NOT NULL,
 CONSTRAINT [PK_MarketplaceAmazonFeedStatusInProcessing] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MarketplaceCountryFullName_LU]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MarketplaceCountryFullName_LU](
	[CountryCode] [varchar](255) NOT NULL,
	[CountryName] [varchar](255) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MarketplaceFTPSettings]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MarketplaceFTPSettings](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MarketplaceTypeID] [int] NOT NULL,
	[MarketplaceFtpTypeID] [int] NOT NULL,
	[SourceID] [int] NOT NULL,
	[FtpSiteCode] [varchar](200) NOT NULL,
	[FtpSite] [varchar](200) NOT NULL,
	[FtpUserID] [varchar](200) NOT NULL,
	[FtpPassword] [varchar](200) NOT NULL,
	[FtpRemoteGetDirectory] [varchar](max) NULL,
	[FtpRemotePutDirectory] [varchar](max) NULL,
	[LocalDirectory] [varchar](max) NOT NULL,
	[Port] [int] NULL,
	[Secure] [bit] NOT NULL,
	[IsConnectionModeActive] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MarketplaceFtpType]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MarketplaceFtpType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Type] [varchar](100) NOT NULL,
 CONSTRAINT [PK_MarketplaceFtpType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MarketplaceOrder]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MarketplaceOrder](
	[MarketplaceOrderID] [int] IDENTITY(1,1) NOT NULL,
	[MarketplaceOrderReferenceNumber] [nvarchar](255) NOT NULL,
	[SourceRefNum] [varchar](50) NULL,
	[OrderTotal] [nvarchar](255) NULL,
	[CurrencyCode] [nvarchar](255) NULL,
	[TypeOfShippingAddress] [nvarchar](255) NULL,
	[FirstNameBilling] [nvarchar](255) NULL,
	[LastNameBilling] [nvarchar](255) NULL,
	[CompanyBilling] [nvarchar](255) NULL,
	[Address1Billing] [nvarchar](255) NULL,
	[Address2Billing] [nvarchar](255) NULL,
	[CityBilling] [nvarchar](255) NULL,
	[CountryBilling] [nvarchar](255) NULL,
	[StateBilling] [nvarchar](255) NULL,
	[ZipBilling] [nvarchar](255) NULL,
	[PhoneBilling] [nvarchar](255) NULL,
	[FaxBilling] [nvarchar](255) NULL,
	[FirstNameShipping] [nvarchar](255) NULL,
	[LastNameShipping] [nvarchar](255) NULL,
	[CompanyShipping] [nvarchar](255) NULL,
	[Address1Shipping] [nvarchar](255) NULL,
	[Address2Shipping] [nvarchar](255) NULL,
	[CityShipping] [nvarchar](255) NULL,
	[CountryShipping] [nvarchar](255) NULL,
	[StateShipping] [nvarchar](255) NULL,
	[ZipShipping] [nvarchar](255) NULL,
	[PhoneShipping] [nvarchar](255) NULL,
	[FaxShipping] [nvarchar](255) NULL,
	[OrderStatus] [nvarchar](255) NULL,
	[OrderDate] [datetime] NULL,
	[BuyerEmail] [nvarchar](255) NULL,
	[IsPlacedToStore] [bit] NOT NULL,
	[ErrorMessage] [nvarchar](255) NULL,
	[MarketplaceName] [nvarchar](255) NULL,
	[OrderType] [varchar](100) NOT NULL,
	[DateEntered] [datetime] NULL,
	[SourceID] [int] NOT NULL,
 CONSTRAINT [PK_MarketplaceOrder] PRIMARY KEY CLUSTERED 
(
	[MarketplaceOrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MarketplaceOrderLineItem]    Script Date: 11/30/2020 11:26:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MarketplaceOrderLineItem](
	[MarketplaceOrderLineItemID] [int] IDENTITY(1,1) NOT NULL,
	[MarketplaceOrderID] [int] NOT NULL,
	[Title] [nvarchar](255) NULL,
	[Qty] [int] NOT NULL,
	[Price] [nvarchar](255) NULL,
	[CurrencyCode] [nvarchar](255) NULL,
	[ASIN] [nvarchar](255) NULL,
	[Sku] [nvarchar](255) NULL,
	[OrderItemID] [nvarchar](255) NULL,
	[ConditionID] [nvarchar](255) NULL,
	[ConditionSubtypeID] [nvarchar](255) NULL,
	[IsGiftWrapped] [nvarchar](255) NULL,
 CONSTRAINT [PK_MarketplaceOrderLineItem] PRIMARY KEY CLUSTERED 
(
	[MarketplaceOrderLineItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MarketplaceSettings]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MarketplaceSettings](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MarketplaceTypeID] [int] NOT NULL,
	[SourceID] [int] NOT NULL,
	[Name] [varchar](200) NOT NULL,
 CONSTRAINT [PK_MarketplaceSettings] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NewAmazonSKUs]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NewAmazonSKUs](
	[SKU] [varchar](max) NOT NULL,
	[BrandID] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Order]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Order](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[StoreCode] [varchar](25) NOT NULL,
	[FileName] [varchar](max) NOT NULL,
	[ShipFirstName] [varchar](200) NOT NULL,
	[ShipLastName] [varchar](200) NOT NULL,
	[ShipPhoneNumber] [varchar](100) NOT NULL,
	[ShipCompanyName] [varchar](200) NULL,
	[ShipAddress1] [varchar](200) NOT NULL,
	[ShipAddress2] [varchar](200) NULL,
	[ShipCity] [varchar](200) NOT NULL,
	[ShipState] [varchar](200) NOT NULL,
	[ShipPostalCode] [varchar](200) NOT NULL,
	[ShipCountry] [varchar](200) NOT NULL,
	[ShipResidential] [varchar](20) NULL,
	[BillingFirstName] [varchar](200) NOT NULL,
	[BillingLastName] [varchar](200) NOT NULL,
	[BillingPhoneNumber] [varchar](100) NOT NULL,
	[BillingCompanyName] [varchar](200) NULL,
	[BillingAddress1] [varchar](200) NOT NULL,
	[BillingAddress2] [varchar](200) NULL,
	[BillingCity] [varchar](200) NOT NULL,
	[BillingState] [varchar](200) NOT NULL,
	[BillingPostalCode] [varchar](200) NOT NULL,
	[BillingCountry] [varchar](200) NOT NULL,
	[BillingFaxNumber] [varchar](100) NULL,
	[EmailAddress] [varchar](200) NOT NULL,
	[OrderComments] [varchar](max) NULL,
	[OrderDate] [datetime] NOT NULL,
	[OrderNotes] [varchar](max) NULL,
	[DateLoaded] [datetime] NOT NULL,
	[ShippingMethodID] [varchar](100) NOT NULL,
	[OverrideErrorsAndWarnings] [bit] NULL,
	[TotalShippingCost] [decimal](19, 5) NOT NULL,
	[PlatformID] [int] NOT NULL,
	[CustomerID] [varchar](50) NOT NULL,
	[CVV2_Response] [varchar](100) NOT NULL,
	[AVS] [varchar](100) NOT NULL,
	[Total_Payment_Authorized] [varchar](100) NOT NULL,
	[Total_Payment_Received] [varchar](100) NOT NULL,
	[PaymentAmount] [varchar](20) NULL,
	[SalesRep_CustomerID] [varchar](100) NULL,
	[LastModified] [datetime] NULL,
	[TaxableProduct] [bit] NOT NULL,
	[OrderStatus] [varchar](100) NOT NULL,
	[ProductPrice] [decimal](19, 5) NOT NULL,
	[LineItemStatus] [varchar](50) NOT NULL,
	[LineItemStatusMessage] [varchar](200) NULL,
	[LineItemComments] [varchar](200) NULL,
	[Sku] [varchar](200) NOT NULL,
	[Quantity] [int] NOT NULL,
	[TotalPriceOfProductOrdered] [decimal](19, 5) NOT NULL,
	[Options] [varchar](200) NULL,
	[OrderDetailID] [nvarchar](100) NOT NULL,
	[ProductName] [varchar](1000) NULL,
	[PersonalizationFee] [decimal](19, 5) NOT NULL,
	[Personalized] [bit] NOT NULL,
	[PersonalizedText] [varchar](max) NULL,
	[PersonalizedFontColor] [varchar](100) NULL,
	[PersonalizedFontStyle] [varchar](100) NULL,
	[OrderType] [varchar](100) NULL,
	[Currency] [varchar](50) NULL,
	[PreferredShipDate] [datetime] NULL,
	[OrderTotal] [decimal](19, 5) NOT NULL,
	[SourceID] [int] NULL,
	[DiscountOrderTotal] [decimal](19, 5) NULL,
	[DestinationType] [int] NULL,
	[ProductType] [varchar](50) NULL,
 CONSTRAINT [PK_Order] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderAmendmentCode]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderAmendmentCode](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OrderAmendmentTypeID] [int] NOT NULL,
	[Code] [varchar](100) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[RequiresSku] [bit] NOT NULL,
	[RequiresCode] [bit] NOT NULL,
	[SendToHybris] [bit] NOT NULL,
	[RequiresOrderUpdate] [bit] NOT NULL,
 CONSTRAINT [PK_OrderAmendmentCode] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderAmendmentType]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderAmendmentType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Type] [varchar](100) NOT NULL,
 CONSTRAINT [PK_OrderAmendmentType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderOption]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderOption](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Category] [varchar](255) NOT NULL,
	[Label] [varchar](255) NOT NULL,
	[Code] [varchar](255) NOT NULL,
 CONSTRAINT [PK_OrderOption] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderStatus]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderStatus](
	[OrderID] [varchar](50) NULL,
	[SourceID] [varchar](50) NULL,
	[Status] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderTax]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderTax](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[Sku] [varchar](50) NULL,
	[TaxName] [varchar](100) NOT NULL,
	[TaxAmount] [decimal](19, 5) NOT NULL,
	[Options] [varchar](max) NULL,
	[SourceID] [int] NULL,
	[TaxType] [varchar](100) NULL,
	[OrderEntryID] [varchar](100) NULL,
 CONSTRAINT [PK_OrderTax] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrnamentSkus]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrnamentSkus](
	[SKU] [varchar](50) NULL,
	[Description] [varchar](500) NULL,
	[Piece Count] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PaymentLog]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PaymentLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[TransactionID] [varchar](100) NOT NULL,
	[OriginalTotal] [decimal](19, 5) NOT NULL,
	[CurrentTotal] [decimal](19, 5) NOT NULL,
	[PaymentAmount] [decimal](19, 5) NOT NULL,
	[PaymentType] [varchar](20) NOT NULL,
	[DateLoaded] [datetime] NOT NULL,
	[OrderID] [int] NOT NULL,
	[Currency] [varchar](50) NULL,
	[PaymentMethodID] [varchar](100) NULL,
 CONSTRAINT [PK_PaymentLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PendingAmazonOrder]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PendingAmazonOrder](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[ProcessedAt] [datetime] NULL,
	[BrandID] [int] NOT NULL,
	[SourceID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[CompanyName] [varchar](255) NULL,
	[CNameAbrv] [varchar](255) NULL,
	[MarketplaceOrderID] [int] NOT NULL,
	[MarketplaceReferenceNumber] [varchar](255) NOT NULL,
	[EcommerceOrderID] [varchar](255) NULL,
	[CurrencyCode] [varchar](255) NULL,
	[OrderTotal] [decimal](19, 5) NULL,
	[OrderStatus] [varchar](255) NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[OrderType] [varchar](255) NOT NULL,
	[BuyerEmail] [varchar](255) NOT NULL,
	[FulfillmentChannel] [varchar](255) NULL,
	[BillingAddressFirstName] [varchar](255) NULL,
	[BillingAddressLastName] [varchar](255) NULL,
	[ShippingAddressFirstName] [varchar](255) NULL,
	[ShippingAddressLastName] [varchar](255) NULL,
	[ShippingAddressAddressLine1] [varchar](255) NULL,
	[ShippingAddressAddressLine2] [varchar](255) NULL,
	[ShippingAddressCity] [varchar](255) NULL,
	[ShippingAddressStateOrRegion] [varchar](255) NULL,
	[ShippingAddressPostalCode] [varchar](255) NULL,
	[ShippingAddressCountryCode] [varchar](255) NULL,
	[ShippingAddressPhone] [varchar](255) NULL,
	[ShippingAddressCountry] [varchar](255) NULL,
	[TypeOfShippingAddress] [varchar](255) NULL,
	[Sku] [varchar](255) NOT NULL,
	[Qty] [int] NOT NULL,
	[Title] [varchar](255) NOT NULL,
	[Price] [varchar](255) NULL,
	[ASIN] [varchar](255) NULL,
	[OrderItemID] [varchar](255) NULL,
	[ConditionID] [varchar](255) NULL,
	[IsGiftWrapped] [bit] NOT NULL,
	[ConditionSubtypeID] [varchar](255) NULL,
	[FulfilledByAPI] [bit] NOT NULL,
	[FulfilledByFile] [bit] NOT NULL,
	[CancelledAt] [datetime] NULL,
 CONSTRAINT [PK_PendingAmazonOrder] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PostalCodePromotion]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PostalCodePromotion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MinRange] [int] NOT NULL,
	[MaxRange] [int] NOT NULL,
	[Country] [varchar](100) NOT NULL,
	[Active] [bit] NOT NULL,
	[UpgradedShippingMethodID] [int] NOT NULL,
	[Description] [varchar](max) NULL,
	[UpgradedTmsShipMethodID] [int] NULL,
 CONSTRAINT [PK_PostalCodePromotion] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductOptionCategory]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductOptionCategory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TemplateCategory] [varchar](255) NOT NULL,
 CONSTRAINT [PK_ProductOptionCategory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductOptionCategorySkus]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductOptionCategorySkus](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StoreSku] [varchar](255) NOT NULL,
	[ProductOptionCategoryID] [int] NOT NULL,
 CONSTRAINT [PK_ProductOptionCategorySkus] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductOptionTemplate]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductOptionTemplate](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TemplateLineNumber] [varchar](255) NOT NULL,
	[TemplateDescription] [varchar](255) NOT NULL,
	[TemplateCategoryID] [int] NOT NULL,
 CONSTRAINT [PK_ProductOptionTemplate] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductOptionTemplateDefaults]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductOptionTemplateDefaults](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProductOptionTemplateID] [int] NOT NULL,
	[ProductOptionValueID] [int] NOT NULL,
	[ProductOptionCategoryID] [int] NOT NULL,
 CONSTRAINT [PK_ProductOptionTemplateDefaults] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductOptionValue]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductOptionValue](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Value] [varchar](255) NOT NULL,
	[RequiresUserInput] [bit] NOT NULL,
	[ProductOptionTemplateId] [int] NOT NULL,
 CONSTRAINT [PK_ProductOptionValue] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[QaCacheTableDefinition]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QaCacheTableDefinition](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Table] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_QaCacheTableDefinition] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReconInventoryForHybrisRegion]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReconInventoryForHybrisRegion](
	[Sku] [varchar](250) NOT NULL,
	[Quantity] [int] NOT NULL,
	[RegionID] [int] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
 CONSTRAINT [ReconStoreInventoryForHybris_PK_Key] PRIMARY KEY CLUSTERED 
(
	[Sku] ASC,
	[RegionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReconInventoryForVolusionStore]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReconInventoryForVolusionStore](
	[Sku] [varchar](250) NOT NULL,
	[Quantity] [int] NOT NULL,
	[SourceID] [int] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
 CONSTRAINT [ReconStoreInventoryForVolusion_PK_Key] PRIMARY KEY CLUSTERED 
(
	[Sku] ASC,
	[SourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReconLoadedInventory]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReconLoadedInventory](
	[WarehouseID] [int] NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Qty] [int] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[IsReconciled] [bit] NOT NULL,
 CONSTRAINT [PK_ReconLoadedInventory] PRIMARY KEY CLUSTERED 
(
	[WarehouseID] ASC,
	[Upc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReconSnapshotDetail]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReconSnapshotDetail](
	[ID] [int] NOT NULL,
	[SourceID] [int] NOT NULL,
	[Sku] [varchar](100) NOT NULL,
	[NewQty] [int] NOT NULL,
	[WHMAdjustmentsForSku] [int] NOT NULL,
	[GroupNumber] [int] NOT NULL,
	[QtyAvailableForGroup] [int] NOT NULL,
	[Lot] [int] NOT NULL,
	[QtyAvailableForLot] [int] NOT NULL,
	[Upc] [varchar](100) NOT NULL,
	[AllocationPercentageForSku] [int] NOT NULL,
	[TotalQtyAvailableForUpc] [int] NOT NULL,
	[WarehouseWHMAdjustmentsForUpc] [int] NOT NULL,
	[QtyToAllocateToSku] [int] NOT NULL,
	[Warehouse] [varchar](100) NOT NULL,
	[WarehouseQty] [int] NOT NULL,
	[WarehouseHoldQty] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[WarehouseActualHoldQty] [int] NULL,
	[WarehouseActualQty] [int] NULL,
 CONSTRAINT [PK_ReconSnapshotDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReconSnapshotSummary]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReconSnapshotSummary](
	[ID] [int] NOT NULL,
	[SourceID] [int] NOT NULL,
	[Sku] [varchar](100) NOT NULL,
	[NewQty] [int] NOT NULL,
	[OldQty] [int] NULL,
	[WHMAdjustments] [int] NOT NULL,
	[StoreAdjustments] [int] NOT NULL,
 CONSTRAINT [PK_ReconSnapshotSummary] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RemainingAllocations]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RemainingAllocations](
	[Store] [nvarchar](255) NULL,
	[UPC] [nvarchar](255) NULL,
	[Sku] [nvarchar](255) NULL,
	[Current_Allocation_Percentage_In_WHM] [nvarchar](255) NULL,
	[WHM_Upc_ID] [nvarchar](255) NULL,
	[Allocation_Percentage_Should_Be] [nvarchar](255) NULL,
	[NOTES] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalesForceExtension]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesForceExtension](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ObjectType] [nvarchar](255) NOT NULL,
	[InternalIDName] [nvarchar](255) NOT NULL,
	[InternalID] [varchar](255) NOT NULL,
	[ExternalIDName] [nvarchar](255) NOT NULL,
	[ExternalID] [nvarchar](255) NOT NULL,
	[SourceID] [int] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
 CONSTRAINT [PK_SalesForceExtension] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalesforceLTLOrder]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesforceLTLOrder](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceRefNum] [nvarchar](255) NOT NULL,
	[BrandID] [int] NOT NULL,
	[SourceID] [int] NOT NULL,
 CONSTRAINT [PK_SalesforceLTLOrder] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalesForceOrderDetailExtension]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesForceOrderDetailExtension](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SalesForceOrderExtensionID] [int] NOT NULL,
	[OrderDetailID] [varchar](100) NOT NULL,
	[ProductName] [varchar](1000) NULL,
	[StoreSku] [nvarchar](255) NOT NULL,
	[TaxableProduct] [bit] NOT NULL,
	[OriginalQuantity] [int] NOT NULL,
	[CurrentQuantity] [int] NOT NULL,
	[LastModified] [datetime] NULL,
	[Options] [varchar](max) NULL,
	[DateEntered] [datetime] NULL,
	[OrderEntryID] [varchar](100) NULL,
	[Amount] [decimal](19, 5) NULL,
	[DetailTypeID] [int] NULL,
	[ParentOrderDetailID] [varchar](255) NULL,
	[ProductType] [varchar](50) NULL,
 CONSTRAINT [PK_SalesForceOrderDetailExtension] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalesForceOrderExtension]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesForceOrderExtension](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[CustomerID] [varchar](100) NOT NULL,
	[CVV2_Response] [nvarchar](255) NULL,
	[AVS] [nvarchar](255) NULL,
	[Total_Payment_Authorized] [money] NULL,
	[Total_Payment_Received] [money] NULL,
	[PaymentAmount] [nvarchar](255) NULL,
	[BillingFirstName] [nvarchar](255) NULL,
	[BillingLastName] [nvarchar](255) NULL,
	[BillingAddress1] [nvarchar](255) NULL,
	[BillingAddress2] [nvarchar](255) NULL,
	[BillingCity] [nvarchar](255) NULL,
	[BillingCompanyName] [nvarchar](255) NULL,
	[BillingCountry] [nvarchar](255) NULL,
	[BillingFaxNumber] [nvarchar](255) NULL,
	[BillingPhoneNumber] [nvarchar](255) NULL,
	[BillingPostalCode] [nvarchar](255) NULL,
	[BillingState] [nvarchar](255) NULL,
	[SalesRep_CustomerID] [varchar](100) NULL,
	[UploadedDate] [datetime] NULL,
	[CC_Last4] [varchar](255) NULL,
	[OrderStatus] [varchar](100) NOT NULL,
	[TaxExemptOrder] [bit] NOT NULL,
	[Currency] [varchar](20) NULL,
	[DoNotSendToSf] [bit] NOT NULL,
	[DateEntered] [datetime] NULL,
	[SalesforceOrderStatus] [varchar](100) NOT NULL,
	[PlatformID] [int] NOT NULL,
 CONSTRAINT [PK_SalesForceOrderExtension] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalesforceOrderPaymentExtension]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesforceOrderPaymentExtension](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[SalesForceOrderExtensionID] [int] NOT NULL,
	[PaymentID] [varchar](100) NOT NULL,
	[PaymentMethod] [varchar](100) NOT NULL,
	[PaymentDate] [datetime] NOT NULL,
	[PaymentAmount] [money] NOT NULL,
	[TransactionID] [varchar](100) NOT NULL,
	[PaymentType] [varchar](50) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[LastModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_SalesforceOrderPaymentExtension] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalesforceShippingDetail]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesforceShippingDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](255) NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Qty] [int] NOT NULL,
	[SalesforceOrderDetailExtensionID] [int] NOT NULL,
	[SalesforceShippingDetailID] [varchar](255) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[IsFulfilled] [bit] NOT NULL,
	[Options] [varchar](max) NULL,
	[CartonNumber] [int] NULL,
 CONSTRAINT [PK_SalesforceShippingDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalesforceTax]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesforceTax](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](50) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[TaxType] [varchar](50) NOT NULL,
	[Amount] [decimal](19, 5) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[SalesforceOrderDetailExtensionID] [int] NULL,
	[SalesforceTaxID] [varchar](100) NOT NULL,
	[TaxRate] [decimal](19, 5) NULL,
 CONSTRAINT [PK_SalesforceTax] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ScraperSettings]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScraperSettings](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StoreID] [int] NOT NULL,
	[QueryBankID] [int] NOT NULL,
	[IsUpdate] [bit] NOT NULL,
	[RunOrder] [int] NOT NULL,
	[ScraperSettingTypeID] [int] NOT NULL,
	[ScraperTarget] [nvarchar](50) NULL,
	[SourceID] [int] NULL,
 CONSTRAINT [PK_OrderScraperSettings] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ScraperSettingsType]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScraperSettingsType](
	[ScraperSettingTypeID] [int] IDENTITY(1,1) NOT NULL,
	[QueryType_CD] [nvarchar](10) NOT NULL,
	[QueryTypeDescription] [nvarchar](250) NULL,
 CONSTRAINT [PK_OrderScraperSettingsType] PRIMARY KEY CLUSTERED 
(
	[ScraperSettingTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Setting]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Setting](
	[SettingID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](max) NOT NULL,
	[Value] [varchar](max) NOT NULL,
 CONSTRAINT [PK_Setting] PRIMARY KEY CLUSTERED 
(
	[SettingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ShipMethodFilter]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShipMethodFilter](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ShippingCode] [varchar](100) NOT NULL,
	[ShippingMethodID] [varchar](255) NOT NULL,
	[GroupNumber] [int] NULL,
	[DateCreated] [datetime] NOT NULL,
	[Active] [bit] NOT NULL,
	[SourceID] [int] NOT NULL,
 CONSTRAINT [PK_ShipMethodFilter] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ShipMethodFilterWarehouseAssociation]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShipMethodFilterWarehouseAssociation](
	[ShipMethodFilterID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
 CONSTRAINT [PK_ShipMethodFilterWarehouseAssociation] PRIMARY KEY CLUSTERED 
(
	[ShipMethodFilterID] ASC,
	[WarehouseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ShipZone]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShipZone](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[BeginZip] [varchar](50) NULL,
	[EndZip] [varchar](50) NULL,
	[Zone] [varchar](100) NULL,
	[GroundZone] [varchar](100) NULL,
 CONSTRAINT [PK_ShipZone] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SkuPriority]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SkuPriority](
	[WarehouseID] [int] NOT NULL,
	[SkuWarehouse] [varchar](100) NOT NULL,
	[Active] [bit] NOT NULL,
	[Priority] [int] NOT NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UpcID] [int] NULL,
 CONSTRAINT [PK_SkuPriority] PRIMARY KEY CLUSTERED 
(
	[WarehouseID] ASC,
	[SkuWarehouse] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SkusNeedingBatteryPack]    Script Date: 11/30/2020 11:26:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SkusNeedingBatteryPack](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BrandSkuID] [int] NOT NULL,
	[UpcID] [int] NOT NULL,
 CONSTRAINT [PK_SkusNeedingBatteryPack] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SourceSkusNotToProcess]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SourceSkusNotToProcess](
	[SourceID] [int] NOT NULL,
	[ProductCode] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_StoreSkusNotToProcess_StoreID_ProductCode] PRIMARY KEY CLUSTERED 
(
	[SourceID] ASC,
	[ProductCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SourceWarehouseFtpSiteAssociation]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SourceWarehouseFtpSiteAssociation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[WarehouseFTPSiteID] [int] NOT NULL,
	[GetFolder] [varchar](200) NULL,
	[PutFolder] [varchar](200) NULL,
 CONSTRAINT [PK_StoreWarehouseFtpSiteAssociation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StoreAdjustmentSource]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StoreAdjustmentSource](
	[StoreID] [int] IDENTITY(1,1) NOT NULL,
	[StatusText] [varchar](100) NOT NULL,
	[Description] [varchar](100) NULL,
	[SourceID] [int] NULL,
 CONSTRAINT [PK_StoreAdjustmentSource] PRIMARY KEY CLUSTERED 
(
	[StoreID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StoreMappings]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StoreMappings](
	[MappingID] [int] NOT NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Active] [bit] NOT NULL,
	[SourceID] [int] NOT NULL,
 CONSTRAINT [PK_StoreMappings] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tmp_Weights]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_Weights](
	[upc] [varchar](50) NULL,
	[lotcode] [varchar](50) NULL,
	[qty] [varchar](50) NULL,
	[Weight (lbs)] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TrackingNumbersRequiringAttention]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrackingNumbersRequiringAttention](
	[SourceID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[WarehouseReferenceNumber] [varchar](100) NOT NULL,
	[TrackingNumber] [varchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_43]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_43](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_44]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_44](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_45]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_45](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_48]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_48](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_58]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_58](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_60]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_60](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_61]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_61](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_63]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_63](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_65]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_65](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_66]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_66](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_67]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_67](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_68]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_68](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_69]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_69](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_70]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_70](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_73]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_73](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_74]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_74](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_76]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_76](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_77]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_77](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_78]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_78](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_79]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_79](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_80]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_80](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_81]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_81](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_82]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_82](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_83]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_83](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_84]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_84](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_85]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_85](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_86]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_86](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_88]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_88](
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Options] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[DateEntered] [datetime] NOT NULL,
	[Payload] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_Temp]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_Temp](
	[WarehouseID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Description] [varchar](255) NOT NULL,
	[Qty] [int] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[EmailAddress] [varchar](255) NOT NULL,
	[ShipFirstName] [varchar](255) NOT NULL,
	[ShipLastName] [varchar](255) NOT NULL,
	[ShipCompanyName] [varchar](255) NOT NULL,
	[ShipAddress1] [varchar](255) NOT NULL,
	[ShipAddress2] [varchar](255) NOT NULL,
	[ShipCity] [varchar](255) NOT NULL,
	[ShipState] [varchar](255) NOT NULL,
	[ShipCountry] [varchar](255) NOT NULL,
	[ShipPhoneNumber] [varchar](255) NOT NULL,
	[ShippingMethodID] [varchar](100) NOT NULL,
	[ShipPostalCode] [varchar](255) NOT NULL,
	[ShipResidential] [varchar](255) NOT NULL,
	[OrderComments] [nvarchar](max) NULL,
	[OrderNotes] [nvarchar](max) NULL,
	[OrderStatus] [varchar](255) NOT NULL,
	[ProductPrice] [decimal](10, 2) NOT NULL,
	[WarehousesToShipThisOrder] [varchar](255) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[Options] [nvarchar](max) NULL,
	[CustomerID] [nvarchar](max) NULL,
	[CVV2_Response] [nvarchar](max) NULL,
	[Total_Payment_Authorized] [nvarchar](max) NULL,
	[Total_Payment_Received] [nvarchar](max) NULL,
	[PaymentAmount] [nvarchar](max) NULL,
	[BillingFirstName] [nvarchar](max) NULL,
	[BillingLastName] [nvarchar](max) NULL,
	[BillingAddress1] [nvarchar](max) NULL,
	[BillingAddress2] [nvarchar](max) NULL,
	[BillingCity] [nvarchar](max) NULL,
	[BillingCompanyName] [nvarchar](max) NULL,
	[BillingCountry] [nvarchar](max) NULL,
	[BillingFaxNumber] [nvarchar](max) NULL,
	[BillingPhoneNumber] [nvarchar](max) NULL,
	[BillingPostalCode] [nvarchar](max) NULL,
	[BillingState] [nvarchar](max) NULL,
	[SalesRep_CustomerID] [nvarchar](max) NULL,
	[AVS] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[IsReroute] [bit] NOT NULL,
	[IsResend] [bit] NOT NULL,
	[TaxableProduct] [bit] NULL,
	[OrderID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[PreferredShipDate] [datetime] NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[OrderType] [varchar](100) NOT NULL,
	[OrderDetailID] [varchar](100) NOT NULL,
	[Height] [float] NULL,
	[Width] [float] NULL,
	[Length] [float] NULL,
	[Weight] [float] NULL,
	[OrderShipMethodType] [int] NOT NULL,
	[OrderTotal] [decimal](18, 0) NOT NULL,
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemAllocatedToWarehouseID_Temp1]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_Temp1](
	[WarehouseID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Options] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[Description] [varchar](max) NOT NULL,
	[Qty] [int] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[EmailAddress] [varchar](255) NOT NULL,
	[ShipFirstName] [varchar](255) NOT NULL,
	[ShipLastName] [varchar](255) NOT NULL,
	[ShipCompanyName] [varchar](255) NOT NULL,
	[ShipAddress1] [varchar](255) NOT NULL,
	[ShipAddress2] [varchar](255) NOT NULL,
	[ShipCity] [varchar](255) NOT NULL,
	[ShipState] [varchar](255) NOT NULL,
	[ShipCountry] [varchar](255) NOT NULL,
	[ShipPhoneNumber] [varchar](255) NOT NULL,
	[ShippingMethodID] [varchar](100) NOT NULL,
	[ShipPostalCode] [varchar](255) NOT NULL,
	[ShipResidential] [varchar](255) NOT NULL,
	[OrderComments] [varchar](max) NOT NULL,
	[OrderNotes] [varchar](max) NOT NULL,
	[OrderStatus] [varchar](255) NOT NULL,
	[ProductPrice] [decimal](10, 2) NOT NULL,
	[WarehousesToShipThisOrder] [varchar](255) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[CustomerID] [nvarchar](max) NULL,
	[CVV2_Response] [nvarchar](max) NULL,
	[Total_Payment_Authorized] [nvarchar](max) NULL,
	[Total_Payment_Received] [nvarchar](max) NULL,
	[PaymentAmount] [nvarchar](max) NULL,
	[BillingFirstName] [nvarchar](max) NULL,
	[BillingLastName] [nvarchar](max) NULL,
	[BillingAddress1] [nvarchar](max) NULL,
	[BillingAddress2] [nvarchar](max) NULL,
	[BillingCity] [nvarchar](max) NULL,
	[BillingCompanyName] [nvarchar](max) NULL,
	[BillingCountry] [nvarchar](max) NULL,
	[BillingFaxNumber] [nvarchar](max) NULL,
	[BillingPhoneNumber] [nvarchar](max) NULL,
	[BillingPostalCode] [nvarchar](max) NULL,
	[BillingState] [nvarchar](max) NULL,
	[SalesRep_CustomerID] [nvarchar](max) NULL,
	[AVS] [nvarchar](max) NULL,
	[BeingDelivered] [bit] NOT NULL,
	[IsReroute] [bit] NOT NULL,
	[IsResend] [bit] NOT NULL,
	[TaxableProduct] [bit] NULL,
	[OrderID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[PreferredShipDate] [datetime] NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[OrderType] [varchar](100) NOT NULL,
	[OrderDetailID] [varchar](100) NOT NULL,
	[Height] [float] NULL,
	[Width] [float] NULL,
	[Length] [float] NULL,
	[Weight] [float] NULL,
	[OrderShipMethodType] [int] NOT NULL,
	[OrderTotal] [decimal](18, 0) NOT NULL,
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcForLineItemSendingLTL]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcForLineItemSendingLTL](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceRefNum] [varchar](255) NOT NULL,
	[TransactionType] [varchar](255) NOT NULL,
	[CustomerCode] [varchar](255) NOT NULL,
	[PickUpLocation] [varchar](255) NOT NULL,
	[PickUpAddress] [varchar](255) NOT NULL,
	[PickUpCity] [varchar](255) NOT NULL,
	[PickUpState] [varchar](255) NOT NULL,
	[PickUpPostalCode] [varchar](255) NOT NULL,
	[ReadyBy] [varchar](255) NOT NULL,
	[PickUpBy] [varchar](255) NOT NULL,
	[DropLocation] [varchar](255) NOT NULL,
	[DropAddress] [varchar](255) NOT NULL,
	[DropCity] [varchar](255) NOT NULL,
	[DropState] [varchar](255) NOT NULL,
	[DropPostalCode] [varchar](255) NOT NULL,
	[DeliveryAvailableDate] [varchar](255) NOT NULL,
	[DeliverByDate] [varchar](255) NOT NULL,
	[ProductCode] [varchar](255) NOT NULL,
	[ProductName] [varchar](1000) NULL,
	[PackagingCode] [varchar](255) NOT NULL,
	[Quantity] [varchar](255) NOT NULL,
	[TotalWeight] [varchar](255) NOT NULL,
	[TotalValue] [varchar](255) NOT NULL,
	[DropPhoneNumber] [varchar](255) NOT NULL,
	[DropContactName] [varchar](255) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Upc] [varchar](100) NOT NULL,
	[WarehouseReferenceNumber] [varchar](100) NOT NULL,
	[OrderID] [int] NOT NULL,
	[LotCode] [int] NOT NULL,
	[SourceID] [int] NOT NULL,
 CONSTRAINT [PK_UpcForLineItemSendingLTL] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcMasterPackAssociations]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcMasterPackAssociations](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MasterPackUpcID] [int] NOT NULL,
	[InnerPackUpcID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
 CONSTRAINT [PK_UpcMasterPackAssociations] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcShipMethodConversion]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcShipMethodConversion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Upc] [varchar](200) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[ShipMethodID] [int] NOT NULL,
	[RequiresWarehousePostalCodePromotion] [bit] NOT NULL,
	[Active] [bit] NOT NULL,
	[ShipMethodExceptionID] [int] NULL,
	[DestinationException] [int] NULL,
 CONSTRAINT [PK_BurlingameUpcShipMethodConversion] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UPCsMissingWeights]    Script Date: 11/30/2020 11:26:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UPCsMissingWeights](
	[Upc] [varchar](50) NULL,
	[Weight] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpsHeavyGoodsDailyReturns]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpsHeavyGoodsDailyReturns](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TrackingNumber] [varchar](255) NOT NULL,
	[OrderNumber] [varchar](255) NOT NULL,
	[ProductCode] [varchar](255) NOT NULL,
	[CustomerName] [varchar](255) NOT NULL,
	[DateReturnCreated] [datetime] NOT NULL,
	[SentToUps] [bit] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[SourceID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
 CONSTRAINT [PK_UpsHeavyGoodsDailyReturns] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VersionInfo]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VersionInfo](
	[Version] [bigint] NOT NULL,
	[AppliedOn] [datetime] NULL,
	[Description] [nvarchar](1024) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [UC_Version]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE UNIQUE CLUSTERED INDEX [UC_Version] ON [dbo].[VersionInfo]
(
	[Version] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VolusionSetting]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VolusionSetting](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](200) NOT NULL,
	[Code] [varchar](100) NOT NULL,
	[FullName] [varchar](100) NOT NULL,
	[EIN] [varchar](50) NULL,
	[URL] [varchar](100) NULL,
	[UserID] [varchar](50) NULL,
	[PlainTextPassword] [varchar](200) NULL,
	[EncryptedPassword] [varchar](200) NULL,
	[DiscountPercentage] [decimal](18, 2) NOT NULL,
	[LocalDirectoryOrders] [varchar](100) NULL,
	[LocalDirectoryTracking] [varchar](100) NULL,
	[LocalDirectoryCommercialInvoices] [varchar](100) NULL,
	[OrderStatus] [varchar](100) NULL,
	[LastOrderFileCount] [int] NULL,
	[LastOrderFileName] [varchar](100) NULL,
	[LastOrderFileLoaded] [datetime] NULL,
	[LastProcessingDate] [datetime] NULL,
	[LastProcessingCount] [int] NULL,
	[LastGenerateDate] [datetime] NULL,
	[LastGenerateCount] [int] NULL,
	[LastTrackingFileCount] [int] NULL,
	[LastTrackingFileName] [varchar](100) NULL,
	[LastTrackingFileLoaded] [datetime] NULL,
	[Active] [bit] NOT NULL,
	[UseWarehousePriorityOverride] [bit] NULL,
	[ReallocationLevelThreshold] [int] NULL,
	[PseudoStore] [bit] NOT NULL,
	[TimeZoneOffset] [int] NULL,
	[PlatformID] [int] NOT NULL,
	[CanSendConfirmationEmails] [bit] NULL,
	[CanSendTrackingNumberEmails] [bit] NULL,
	[StoreDomain] [varchar](50) NULL,
	[IsActiveInOrderLoader] [bit] NOT NULL,
	[RegionID] [int] NOT NULL,
	[HasCatalog] [bit] NOT NULL,
	[NarvarCode] [varchar](50) NOT NULL,
	[BrontoName] [varchar](100) NULL,
	[TaxPercentage] [int] NULL,
	[BrandID] [int] NOT NULL,
	[SourceID] [int] NOT NULL,
 CONSTRAINT [PK_Store] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseApiSettingsForAmware]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseApiSettingsForAmware](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PushOrdersUrl] [varchar](250) NOT NULL,
	[PullInventoryUrl] [varchar](250) NOT NULL,
	[ApiKey] [varchar](100) NOT NULL,
	[OwnerCode] [varchar](100) NOT NULL,
 CONSTRAINT [PK_WarehouseApiSettingsForAmware] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseApiSettingsForBalsamIndianapolis]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseApiSettingsForBalsamIndianapolis](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ClientID] [varchar](255) NOT NULL,
	[LocationID] [varchar](255) NOT NULL,
	[ApiKey] [varchar](255) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[TrackingNumberPullDate] [datetime] NOT NULL,
	[SendOrdersUrl] [varchar](255) NOT NULL,
	[PullTrackingNumbersUrl] [varchar](255) NOT NULL,
	[PullInventoryUrl] [varchar](255) NOT NULL,
	[InventoryAccount] [varchar](255) NOT NULL,
 CONSTRAINT [PK_WarehouseApiSettingsForBalsamIndianapolis] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseApiSettingsForBurlingame]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseApiSettingsForBurlingame](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](255) NOT NULL,
	[Password] [varchar](255) NOT NULL,
	[Url] [varchar](255) NOT NULL,
	[Port] [int] NOT NULL,
	[IADescription] [varchar](255) NOT NULL,
	[IAID] [varchar](255) NOT NULL,
	[IAName] [varchar](255) NOT NULL,
	[GroundShipMethodConversion] [int] NOT NULL,
	[MaxGroundShippingMethod] [int] NOT NULL,
	[BalsamQBC] [varchar](255) NOT NULL,
	[TreetopiaQBC] [varchar](255) NOT NULL,
	[ChristmasTreeMarketQBC] [varchar](255) NOT NULL,
	[TreeClassicsQBC] [varchar](255) NOT NULL,
	[DateToPullTrackingNumbersForBalsamHill] [datetime] NOT NULL,
	[DateToPullTrackingNumbersForTreetopia] [datetime] NOT NULL,
	[DateToPullTrackingNumbersForChristmasTreeMarket] [datetime] NOT NULL,
	[DateToPullTrackingNumbersForTreeClassics] [datetime] NOT NULL,
 CONSTRAINT [PK_WarehouseApiSettingsForBurlingame] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseApiSettingsForFifthGear]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseApiSettingsForFifthGear](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](255) NOT NULL,
	[Password] [varchar](255) NOT NULL,
	[InventoryLookUpUrl] [varchar](255) NOT NULL,
	[OrderStatusLookUpUrl] [varchar](255) NOT NULL,
	[OrderStatusLookUpUsingReferenceNumberUrl] [varchar](255) NOT NULL,
	[OrderSubmissionUrl] [varchar](255) NOT NULL,
 CONSTRAINT [PK_WarehouseApiSettingsForFifthGear] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseApiSettingsForHanover]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseApiSettingsForHanover](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FetchInventoryUrl] [varchar](255) NOT NULL,
	[FetchTrackingNumbersUrl] [varchar](255) NOT NULL,
	[PushOrdersUrl] [varchar](255) NOT NULL,
	[AuthenticationUrl] [varchar](255) NOT NULL,
	[UserName] [varchar](255) NOT NULL,
	[Password] [varchar](255) NOT NULL,
	[OrderChunkSize] [int] NOT NULL,
 CONSTRAINT [PK_WarehouseApiSettingsForHanover] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseApiSettingsForHanzo]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseApiSettingsForHanzo](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ClientID] [varchar](255) NOT NULL,
	[LocationID] [varchar](255) NOT NULL,
	[ApiKey] [varchar](255) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[TrackingNumberPullDate] [datetime] NOT NULL,
	[SendOrdersUrl] [varchar](255) NOT NULL,
	[PullTrackingNumbersUrl] [varchar](255) NOT NULL,
	[PullInventoryUrl] [varchar](255) NOT NULL,
	[InventoryAccount] [varchar](255) NOT NULL,
 CONSTRAINT [PK_WarehouseApiSettingsForHanzo] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseApiSettingsForIDS]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseApiSettingsForIDS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ApiKey] [varchar](255) NOT NULL,
	[PullInventoryUrl] [varchar](255) NOT NULL,
	[PullTrackingNumberUrl] [varchar](255) NOT NULL,
	[SendOrdersUrl] [varchar](255) NOT NULL,
 CONSTRAINT [PK_WarehouseApiSettingsForIDS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseApiSettingsForMochila]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseApiSettingsForMochila](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ApiKey] [varchar](255) NOT NULL,
	[ClientId] [varchar](255) NOT NULL,
	[Version] [varchar](255) NOT NULL,
	[InventoryRequestSize] [int] NOT NULL,
	[TrackingNumberRequestSize] [int] NOT NULL,
	[TrackingNumberRequestUrl] [varchar](255) NOT NULL,
	[OrderSubmissionUrl] [varchar](255) NOT NULL,
	[InventoryRequestUrl] [varchar](255) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[LocationCode] [varchar](10) NOT NULL,
	[BAL_Profile] [varchar](25) NOT NULL,
	[CTM_Profile] [varchar](25) NOT NULL,
	[TC_Profile] [varchar](25) NOT NULL,
	[TREE_Profile] [varchar](25) NOT NULL,
	[WarrantyApiKey] [varchar](255) NOT NULL,
	[WarrantyClientID] [varchar](255) NOT NULL,
	[BAL_Warranty_Profile] [varchar](100) NOT NULL,
	[BAL_USPS_Profile] [varchar](50) NULL,
	[CTM_USPS_Profile] [varchar](50) NULL,
	[TC_USPS_Profile] [varchar](50) NULL,
	[TREE_USPS_Profile] [varchar](50) NULL,
	[FedEx_Freight_Profile] [varchar](50) NULL,
	[GetStatusInformationForOrderUrl] [varchar](max) NULL,
	[FedEx_Freight_Url] [varchar](max) NULL,
	[BAL_Amazon_Profile] [varchar](255) NOT NULL,
	[BAL_OnTrac_Profile] [varchar](200) NOT NULL,
	[TC_Ontrac_Profile] [varchar](200) NOT NULL,
	[TreeTopia_Ontrac_Profile] [varchar](200) NOT NULL,
	[BAL_Pitney_Profile] [varchar](200) NULL,
	[TC_Pitney_Profile] [varchar](200) NULL,
	[TREE_Pitney_Profile] [varchar](200) NULL,
	[BAL_Ltl_Profile] [varchar](255) NULL,
	[TC_Ltl_Profile] [varchar](255) NULL,
	[TREE_Ltl_Profile] [varchar](255) NULL,
	[TC_UPS_Profile] [varchar](255) NULL,
	[BAL_UPS_Profile] [varchar](255) NULL,
	[TREE_UPS_Profile] [varchar](255) NULL,
	[BAL_LSO_Profile] [varchar](255) NULL,
	[TC_LSO_Profile] [varchar](255) NULL,
	[TREE_LSO_Profile] [varchar](255) NULL,
 CONSTRAINT [PK_WarehouseApiSettingsForMochila] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseApiSettingsForSeko]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseApiSettingsForSeko](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Token] [varchar](255) NOT NULL,
	[BaseUrl] [varchar](255) NOT NULL,
	[GetAllStockUrl] [varchar](255) NOT NULL,
	[TrackingNumberBulkLoadUrl] [varchar](255) NOT NULL,
	[SubmitSalesOrderUrl] [varchar](255) NOT NULL,
 CONSTRAINT [PK_WarehouseApiSettingsForSeko] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseCodeLookup]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseCodeLookup](
	[WarehouseID] [int] NOT NULL,
	[WarehouseCode] [varchar](50) NOT NULL,
 CONSTRAINT [PK_WarehouseCodeLookup] PRIMARY KEY CLUSTERED 
(
	[WarehouseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseErrorCode]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseErrorCode](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WarehouseID] [int] NULL,
	[Message] [varchar](255) NOT NULL,
	[Action] [varchar](255) NOT NULL,
	[Exception] [varchar](255) NULL,
	[CreatedAt] [datetime] NOT NULL,
 CONSTRAINT [PK_WarehouseErrorCode] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseFTPSite]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseFTPSite](
	[WarehouseID] [int] NOT NULL,
	[FtpSiteCode] [varchar](200) NOT NULL,
	[FtpSite] [varchar](200) NOT NULL,
	[FtpUserID] [varchar](200) NOT NULL,
	[FtpPassword] [varchar](200) NOT NULL,
	[FtpRemoteGetDirectory] [varchar](200) NULL,
	[FtpRemotePutDirectory] [varchar](200) NULL,
	[Inventory] [bit] NULL,
	[TrackingNumbers] [bit] NULL,
	[Orders] [bit] NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Port] [int] NULL,
	[Secure] [bit] NOT NULL,
	[IsConnectionModeActive] [bit] NOT NULL,
	[WarrantyOrders] [bit] NULL,
 CONSTRAINT [PK_WarehouseFTPSite] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseInventoryMapping]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseInventoryMapping](
	[WarehouseID] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[CustomConversion] [varchar](100) NULL,
	[FileType] [varchar](50) NOT NULL,
	[ExcelSheetName] [varchar](100) NULL,
	[FileExt] [varchar](50) NULL,
	[Header] [bit] NOT NULL,
	[HeaderPos] [int] NULL,
	[HeaderText] [varchar](100) NULL,
	[MapType] [varchar](50) NOT NULL,
	[MapSkuLoc] [varchar](50) NOT NULL,
	[MapQtyLoc] [varchar](50) NOT NULL,
	[MapDescLoc] [varchar](50) NULL,
	[MapUser1Name] [varchar](50) NULL,
	[MapUser1Loc] [varchar](50) NULL,
	[MapUser2Name] [varchar](50) NULL,
	[MapUser2Loc] [varchar](50) NULL,
	[MapUser3Name] [varchar](50) NULL,
	[MapUser3Loc] [varchar](50) NULL,
	[MapUser4Name] [varchar](50) NULL,
	[MapUser4Loc] [varchar](50) NULL,
	[MapUser5Name] [varchar](50) NULL,
	[MapUser5Loc] [varchar](50) NULL,
	[IsCurrent] [bit] NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_WarehouseInventoryMapping] PRIMARY KEY CLUSTERED 
(
	[WarehouseID] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseMappings]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseMappings](
	[WarehouseID] [int] NOT NULL,
	[MappingID] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IsCustom] [bit] NULL,
 CONSTRAINT [PK_WarehouseMappings] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehousePostalCodePromotion]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehousePostalCodePromotion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[MinRange] [int] NOT NULL,
	[MaxRange] [int] NOT NULL,
	[Country] [varchar](100) NOT NULL,
	[Active] [bit] NOT NULL,
	[Description] [varchar](max) NOT NULL,
	[Zone] [int] NOT NULL,
	[ShippingMethodExceptions] [varchar](max) NULL,
	[SourceTmsShipMethodID] [int] NULL,
	[UpgradedTmsShipMethodID] [int] NULL,
 CONSTRAINT [PK_WarehousePostalCodePromotion] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehousePromotions]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehousePromotions](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[PromotionName] [varchar](200) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[SourceShippingMethodID] [int] NULL,
	[DestinationShippingMethodID] [int] NOT NULL,
	[PromotionZone] [int] NULL,
	[Active] [bit] NOT NULL,
	[ShippingMethodExceptions] [varchar](max) NULL,
 CONSTRAINT [PK_WarehousePromotions] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseRegexPattern]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseRegexPattern](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[TrackingFile] [bit] NOT NULL,
	[FileType] [varchar](50) NOT NULL,
 CONSTRAINT [PK_WarehouseRegexPattern_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseRegexPatternDetail]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseRegexPatternDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WarehouseRegexPatternID] [int] NOT NULL,
	[Pattern] [varchar](50) NULL,
	[Position] [int] NULL,
 CONSTRAINT [PK_Table_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseSchedule]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseSchedule](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[SendEmail] [bit] NOT NULL,
 CONSTRAINT [PK_WarehouseSchedule] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseScheduleDetail]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseScheduleDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WarehouseScheduleID] [int] NOT NULL,
	[StartTime] [varchar](100) NOT NULL,
	[NextRun] [datetime] NOT NULL,
	[LastRun] [datetime] NULL,
	[Active] [bit] NOT NULL,
	[ScheduleCreated] [datetime] NOT NULL,
	[ScheduleModified] [datetime] NULL,
	[Monday] [bit] NOT NULL,
	[Tuesday] [bit] NOT NULL,
	[Wednesday] [bit] NOT NULL,
	[Thursday] [bit] NOT NULL,
	[Friday] [bit] NOT NULL,
	[Saturday] [bit] NOT NULL,
	[Sunday] [bit] NOT NULL,
	[ShipFilterGroupID] [int] NULL,
 CONSTRAINT [PK_WarehouseScheduleDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseTrackingMapping]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseTrackingMapping](
	[WarehouseID] [int] NOT NULL,
	[Name] [nchar](100) NOT NULL,
	[FileType] [nchar](50) NOT NULL,
	[Header] [bit] NOT NULL,
	[HeaderPos] [int] NULL,
	[HeaderText] [varchar](100) NULL,
	[MapType] [varchar](50) NOT NULL,
	[MapOrderIDLoc] [varchar](50) NOT NULL,
	[MapTrackNumLoc] [varchar](50) NULL,
	[MapShipMethodLoc] [varchar](50) NULL,
	[MapShipDateLoc] [varchar](50) NULL,
	[IsCurrent] [bit] NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_WarehouseTrackingMapping] PRIMARY KEY CLUSTERED 
(
	[WarehouseID] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseWebService]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseWebService](
	[WarehouseID] [int] NOT NULL,
	[Client] [varchar](100) NOT NULL,
	[Username] [varchar](100) NOT NULL,
	[Password] [varchar](100) NOT NULL,
	[CustomerNumber] [varchar](100) NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_WarehouseWebService] PRIMARY KEY CLUSTERED 
(
	[WarehouseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarrantyOrderSectionUpc]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarrantyOrderSectionUpc](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[Sku] [varchar](50) NOT NULL,
	[SectionUpc] [varchar](50) NOT NULL,
 CONSTRAINT [PK_WarrantyOrderSectionUpc] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarrantyToPreLoad]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarrantyToPreLoad](
	[UPC] [nvarchar](200) NOT NULL,
	[QTY] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarrantyUpcSection]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarrantyUpcSection](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ParentUpcID] [int] NOT NULL,
	[UpcSectionID] [int] NOT NULL,
	[Section] [varchar](50) NOT NULL,
 CONSTRAINT [PK_WarrantyUpcSection] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WayfairOrder]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WayfairOrder](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[PoType] [varchar](100) NOT NULL,
	[PoNumber] [varchar](200) NOT NULL,
	[CustomerOrderNumber] [varchar](200) NOT NULL,
	[PoDate] [datetime] NOT NULL,
	[SupplierID] [varchar](200) NOT NULL,
	[Store] [varchar](100) NULL,
	[SupplierWarehouseZipCode] [varchar](200) NOT NULL,
	[SupplierName] [varchar](200) NULL,
	[SupplierFax] [varchar](100) NULL,
	[SupplierStore] [varchar](100) NULL,
	[FOB] [varchar](100) NULL,
	[AllowanceCode] [varchar](100) NULL,
	[AllowanceAmount] [float] NULL,
	[PaymentTerms] [varchar](100) NULL,
	[MaxShipDate] [varchar](100) NULL,
	[ShipCarrierCode] [varchar](200) NOT NULL,
	[ShipSpeedCode] [varchar](200) NOT NULL,
	[BillingFirstName] [varchar](200) NOT NULL,
	[BillingLastName] [varchar](200) NOT NULL,
	[BillingAddress1] [varchar](200) NOT NULL,
	[BillingAddress2] [varchar](200) NULL,
	[BillingCity] [varchar](200) NOT NULL,
	[BillingState] [varchar](50) NOT NULL,
	[BillingPostalCode] [varchar](50) NOT NULL,
	[BillingCountry] [varchar](200) NOT NULL,
	[BillingPhoneNumber] [varchar](50) NOT NULL,
	[BillingFaxNumber] [varchar](50) NULL,
	[BillingEmail] [varchar](200) NULL,
	[ShipFirstName] [varchar](200) NOT NULL,
	[ShipLastName] [varchar](200) NOT NULL,
	[ShipCompanyName] [varchar](200) NULL,
	[ShipAddress1] [varchar](200) NOT NULL,
	[ShipAddress2] [varchar](200) NULL,
	[ShipCity] [varchar](200) NOT NULL,
	[ShipState] [varchar](200) NOT NULL,
	[ShipPostalCode] [varchar](50) NOT NULL,
	[ShipCountry] [varchar](200) NOT NULL,
	[ShipPhoneNumber] [varchar](50) NOT NULL,
	[ShipFaxNumber] [varchar](50) NULL,
	[EmailAddress] [varchar](200) NOT NULL,
	[CustomerName] [varchar](100) NULL,
	[CustomerAddress1] [varchar](200) NULL,
	[CustomerAddress2] [varchar](200) NULL,
	[CustomerShipCity] [varchar](200) NULL,
	[CustomerShipState] [varchar](50) NULL,
	[CustomerShipPostalCode] [varchar](50) NULL,
	[CustomerShipCountry] [varchar](100) NULL,
	[PoolPointID] [varchar](200) NULL,
	[PoolPointShortName] [varchar](200) NULL,
	[CrossDockID] [varchar](200) NULL,
	[CossDockShortName] [varchar](200) NULL,
	[DeliveryAgentID] [varchar](200) NULL,
	[DeliveryAgentName] [varchar](200) NULL,
	[PackingSlipURL] [varchar](200) NULL,
	[Acknowledged] [datetime] NULL,
 CONSTRAINT [PK_WayfairOrder] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WayfairOrderLineItem]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WayfairOrderLineItem](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WayfairOrderID] [int] NOT NULL,
	[SupplierPartNumber] [varchar](200) NOT NULL,
	[Quantity] [int] NOT NULL,
	[WholesalePrice] [float] NOT NULL,
	[ItemDescription] [varchar](max) NOT NULL,
	[SaleType] [varchar](100) NULL,
	[EventID] [varchar](100) NULL,
	[EventEndDate] [datetime] NULL,
	[CustomComments] [varchar](max) NULL,
 CONSTRAINT [PK_WayfairOrderLineItem] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WayfairTrackingNumbersInProcessing]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WayfairTrackingNumbersInProcessing](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[DatePublished] [datetime] NULL,
	[SourceRefNum] [varchar](255) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[ShipMethod] [varchar](255) NOT NULL,
	[ShipDate] [datetime] NOT NULL,
	[Quantity] [int] NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[TrackingNumber] [varchar](255) NOT NULL,
	[SCAC] [varchar](255) NOT NULL,
 CONSTRAINT [PK_WayfairTrackingNumbersInProcessing] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorldshipOpenShipment]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorldshipOpenShipment](
	[PlatformID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[BrandCode] [varchar](50) NOT NULL,
	[StoreCode] [varchar](50) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](200) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[OrderIdForWarehouse] [varchar](100) NULL,
	[Sku] [varchar](200) NOT NULL,
	[Upc] [varchar](200) NOT NULL,
	[ProcessStatus] [varchar](200) NOT NULL,
	[ShipmentOption] [varchar](200) NOT NULL,
	[CustomerID] [varchar](200) NOT NULL,
	[CompanyOrName] [varchar](max) NOT NULL,
	[Attention] [varchar](200) NULL,
	[Address1] [varchar](max) NOT NULL,
	[Address2] [varchar](max) NULL,
	[Address3] [varchar](max) NULL,
	[CountryTerritory] [varchar](200) NOT NULL,
	[PostalCode] [varchar](50) NOT NULL,
	[CityOrTown] [varchar](200) NOT NULL,
	[StateProvinceCounty] [varchar](200) NOT NULL,
	[Telephone] [varchar](50) NOT NULL,
	[Email] [varchar](200) NULL,
	[UpsAccountNumber] [varchar](200) NOT NULL,
	[ServiceType] [varchar](100) NOT NULL,
	[DescriptionOfGoods] [varchar](max) NOT NULL,
	[NumberOfPackages] [int] NOT NULL,
	[Reference1] [varchar](max) NOT NULL,
	[Reference2] [varchar](max) NULL,
	[Reference3] [varchar](max) NULL,
	[Reference4] [varchar](max) NULL,
	[Reference5] [varchar](max) NULL,
	[SpecialInstructionForShipment] [varchar](max) NULL,
	[ShipperNumber] [varchar](max) NULL,
	[BillingOption] [varchar](50) NOT NULL,
	[PackageType] [varchar](100) NOT NULL,
	[PackageWeight] [float] NOT NULL,
	[PackageLength] [float] NOT NULL,
	[PackageWidth] [float] NOT NULL,
	[PackageHeight] [float] NOT NULL,
	[PackageReference1] [varchar](200) NOT NULL,
	[PackageReference2] [varchar](200) NULL,
	[PackageReference3] [varchar](200) NULL,
	[PackageReference4] [varchar](200) NULL,
	[PackageReference5] [varchar](200) NULL,
	[FilePath] [varchar](max) NULL,
 CONSTRAINT [WorldshipOpenShipment_Index] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC,
	[WarehouseID] ASC,
	[Sku] ASC,
	[Upc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

USE [${Environment}Trees]
GO
/****** Object:  Table [dbo].[temp_SkusToLoad]    Script Date: 12/15/2020 8:09:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temp_SkusToLoad](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Sku] [nvarchar](255) NOT NULL,
	[Brand] [nvarchar](255) NOT NULL,
	[ReconPercentage] [int] NULL,
	[TotalCartons] [int] NULL,
	[Inventory] [int] NULL,
	[Processed] [datetime] NULL,
 CONSTRAINT [PK_temp_SkusToLoad] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_BrontoOrderEmail_SourceRefNum_StoreID]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_BrontoOrderEmail_SourceRefNum_StoreID] ON [dbo].[BrontoOrderEmail]
(
	[SourceRefNum] ASC,
	[SourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BrontoOrderEmailTrackingNumber_OrderEmailID]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_BrontoOrderEmailTrackingNumber_OrderEmailID] ON [dbo].[BrontoOrderEmailTrackingNumber]
(
	[OrderEmailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
/****** Object:  Index [CatalogOrder_Index]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [CatalogOrder_Index] ON [dbo].[CatalogOrder]
(
	[ShippingAddress1] ASC,
	[PostalCode] ASC,
	[City] ASC,
	[State] ASC,
	[Year] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Customer_SourceID_CustomerID]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_Customer_SourceID_CustomerID] ON [dbo].[Customer]
(
	[SourceID] ASC,
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Customer_SourceID_SourceRefNum]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_Customer_SourceID_SourceRefNum] ON [dbo].[Customer]
(
	[SourceID] ASC,
	[SourceRefNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_DeliveredLineItemHistory__SourceID_WarehouseReferenceNumber]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_DeliveredLineItemHistory__SourceID_WarehouseReferenceNumber] ON [dbo].[DeliveredLineItemHistory]
(
	[SourceID] ASC,
	[WarehouseReferenceNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_DeliveredLineItemHistory_SourceRefNum_SourceID]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_DeliveredLineItemHistory_SourceRefNum_SourceID] ON [dbo].[DeliveredLineItemHistory]
(
	[SourceRefNum] ASC,
	[SourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_HybrisNotifyMe_Email]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_HybrisNotifyMe_Email] ON [dbo].[HybrisNotifyMe]
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_MarketplaceOrder_MarketplaceOrderReferenceNumber]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_MarketplaceOrder_MarketplaceOrderReferenceNumber] ON [dbo].[MarketplaceOrder]
(
	[MarketplaceOrderReferenceNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Order__OrderID]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_Order__OrderID] ON [dbo].[Order]
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_SalesForceExtension_ExternalID_InternalIDName_ExternalIDName_StoreID]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_SalesForceExtension_ExternalID_InternalIDName_ExternalIDName_StoreID] ON [dbo].[SalesForceExtension]
(
	[ExternalID] ASC,
	[InternalIDName] ASC,
	[ExternalIDName] ASC,
	[SourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_SalesForceExtension_InternalID_StoreID]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_SalesForceExtension_InternalID_StoreID] ON [dbo].[SalesForceExtension]
(
	[InternalID] ASC,
	[SourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_SalesForceExtension_InternalIDName_InternalID_StoreID]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_SalesForceExtension_InternalIDName_InternalID_StoreID] ON [dbo].[SalesForceExtension]
(
	[InternalIDName] ASC,
	[InternalID] ASC,
	[SourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [uc_InternalExternal]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [uc_InternalExternal] ON [dbo].[SalesForceExtension]
(
	[InternalID] ASC,
	[ExternalID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_SalesForceOrderDetailExtension_OrderDetailID_SalesforceOrderExtensionID]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_SalesForceOrderDetailExtension_OrderDetailID_SalesforceOrderExtensionID] ON [dbo].[SalesForceOrderDetailExtension]
(
	[SalesForceOrderExtensionID] ASC,
	[OrderDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SalesForceOrderDetailExtension_SalesForceOrderExtensionID]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_SalesForceOrderDetailExtension_SalesForceOrderExtensionID] ON [dbo].[SalesForceOrderDetailExtension]
(
	[SalesForceOrderExtensionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_SalesForceOrderDetailExtension_StoreSku_SalesforceOrderExtensionID]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_SalesForceOrderDetailExtension_StoreSku_SalesforceOrderExtensionID] ON [dbo].[SalesForceOrderDetailExtension]
(
	[SalesForceOrderExtensionID] ASC,
	[StoreSku] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_SalesForceOrderExtension_SourceRefNum_StoreID]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_SalesForceOrderExtension_SourceRefNum_StoreID] ON [dbo].[SalesForceOrderExtension]
(
	[SourceRefNum] ASC,
	[SourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_SalesForceOrderExtension_StoreID_SourceRefNum_CustomerID]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_SalesForceOrderExtension_StoreID_SourceRefNum_CustomerID] ON [dbo].[SalesForceOrderExtension]
(
	[SourceID] ASC,
	[SourceRefNum] ASC,
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_SalesforceShippingDetail_SourceRefNum_WarehouseID]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_SalesforceShippingDetail_SourceRefNum_WarehouseID] ON [dbo].[SalesforceShippingDetail]
(
	[SourceRefNum] ASC,
	[WarehouseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Upc_Upc]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_Upc_Upc] ON [dbo].[Upc]
(
	[Upc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_WarehouseFTPSite]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_WarehouseFTPSite] ON [dbo].[WarehouseFTPSite]
(
	[WarehouseID] ASC,
	[FtpSiteCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SourceID_DatePublished]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_SourceID_DatePublished] ON [dbo].[WayfairTrackingNumbersInProcessing]
(
	[SourceID] DESC,
	[DatePublished] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_SourceID_SourceRefNum]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_SourceID_SourceRefNum] ON [dbo].[WayfairTrackingNumbersInProcessing]
(
	[SourceID] DESC,
	[SourceRefNum] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_WayfairTrackingNumbersInProcessing_SourceRefNum]    Script Date: 11/30/2020 11:26:19 AM ******/
CREATE NONCLUSTERED INDEX [IX_WayfairTrackingNumbersInProcessing_SourceRefNum] ON [dbo].[WayfairTrackingNumbersInProcessing]
(
	[SourceRefNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AmazonSettings] ADD  CONSTRAINT [DF_MarketplaceSettings_BypassOrders]  DEFAULT ((0)) FOR [BypassOrders]
GO
ALTER TABLE [dbo].[BatchedHybrisTrackingNumber] ADD  CONSTRAINT [DF_BatchedHybrisTrackingNumber_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[BatchedSalesforceTrackingNumber] ADD  CONSTRAINT [DF_BatchedSalesforceTrackingNumber_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[BrontoApiSettings] ADD  CONSTRAINT [DF_BrontoApiSettings_StoreID]  DEFAULT ((39)) FOR [BrandID]
GO
ALTER TABLE [dbo].[BrontoBrandSkuImage] ADD  CONSTRAINT [DF_BrontoStoreSkuImage_StoreID]  DEFAULT ((39)) FOR [SourceID]
GO
ALTER TABLE [dbo].[BrontoEmailContact] ADD  CONSTRAINT [DF_BrontoEmailContact_StoreID]  DEFAULT ((39)) FOR [SourceID]
GO
ALTER TABLE [dbo].[CatalogOrder] ADD  CONSTRAINT [DF_CatalogOrder_StoreID]  DEFAULT ((0)) FOR [SourceID]
GO
ALTER TABLE [dbo].[CommercialInvoice] ADD  CONSTRAINT [DF_CommercialInvoice_Delivered]  DEFAULT ((0)) FOR [Delivered]
GO
ALTER TABLE [dbo].[CommercialInvoice] ADD  CONSTRAINT [DF_CommercialInvoice_SentViaEmail]  DEFAULT ((0)) FOR [SentViaEmail]
GO
ALTER TABLE [dbo].[CommercialInvoice] ADD  CONSTRAINT [DF_CommercialInvoice_SentViaFTP]  DEFAULT ((0)) FOR [SentViaFTP]
GO
ALTER TABLE [dbo].[DeliveredLineItemHistory] ADD  CONSTRAINT [DF_DeliveredLineItemHistory_IsResend]  DEFAULT ((0)) FOR [IsResend]
GO
ALTER TABLE [dbo].[DeliveredLineItemHistory] ADD  CONSTRAINT [DF_DeliveredLineItemHistory_IsReroute]  DEFAULT ((0)) FOR [IsReroute]
GO
ALTER TABLE [dbo].[DeliveredLineItemHistory] ADD  CONSTRAINT [DF_DeliveredLineItemHistory_IsSuccessful]  DEFAULT ((1)) FOR [IsSuccessful]
GO
ALTER TABLE [dbo].[HybrisNotifyMe] ADD  CONSTRAINT [DF_HybrisNotifyMe_HasBeenSent]  DEFAULT ((0)) FOR [HasBeenSent]
GO
ALTER TABLE [dbo].[InvalidLineItemTrackingNumberDetail] ADD  CONSTRAINT [DF_InvalidLineItemTrackingNumberDetail_IsWarranty]  DEFAULT ((0)) FOR [IsWarranty]
GO
ALTER TABLE [dbo].[InvalidOrder] ADD  CONSTRAINT [DF_InvalidOrder_PlatformID]  DEFAULT ((1)) FOR [PlatformID]
GO
ALTER TABLE [dbo].[InvalidOrderLineItem] ADD  CONSTRAINT [DF_InvalidOrderLineItem_TaxableProduct]  DEFAULT ((0)) FOR [TaxableProduct]
GO
ALTER TABLE [dbo].[InventoryHoldForWarehouse] ADD  CONSTRAINT [DF_InventoryHoldForWarehouse_EffectiveDate]  DEFAULT (getdate()) FOR [EffectiveDate]
GO
ALTER TABLE [dbo].[InventoryHoldForWarehouse] ADD  CONSTRAINT [DF_InventoryHoldForWarehouse_StatusCodeID]  DEFAULT ((-1)) FOR [StatusCodeID]
GO
ALTER TABLE [dbo].[LineItemRequiringTrackingNumber] ADD  CONSTRAINT [DF_UpcForLineItemRequiringTrackingNumber_ShippingMethod]  DEFAULT ('') FOR [ShippingMethod]
GO
ALTER TABLE [dbo].[LoadedUndeliveredLineItem] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[LoadedUndeliveredLineItem] ADD  CONSTRAINT [DF_LoadedUndeliveredLineItem_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[LoadedUndeliveredLineItemWithAllocationDetails] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[LoadedUndeliveredLineItemWithAllocationDetails] ADD  CONSTRAINT [DF_LoadedUndeliveredLineItemWithAllocationDetails_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[Mapping] ADD  CONSTRAINT [DF_Mapping_IsDefault]  DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[Order] ADD  CONSTRAINT [DF_Order_PersonalizationFee]  DEFAULT ((0)) FOR [PersonalizationFee]
GO
ALTER TABLE [dbo].[Order] ADD  CONSTRAINT [DF_Order_Personalized]  DEFAULT ((0)) FOR [Personalized]
GO
ALTER TABLE [dbo].[OrderAmendmentCode] ADD  CONSTRAINT [DF_OrderAmendmentCode_RequiresSku]  DEFAULT ((0)) FOR [RequiresSku]
GO
ALTER TABLE [dbo].[OrderAmendmentCode] ADD  CONSTRAINT [DF_OrderAmendmentCode_RequiresCode]  DEFAULT ((0)) FOR [RequiresCode]
GO
ALTER TABLE [dbo].[OrderAmendmentCode] ADD  CONSTRAINT [DF_OrderAmendmentCode_SendToHybris]  DEFAULT ((0)) FOR [SendToHybris]
GO
ALTER TABLE [dbo].[OrderAmendmentCode] ADD  CONSTRAINT [DF_OrderAmendmentCode_RequiresOrderUpdate]  DEFAULT ((0)) FOR [RequiresOrderUpdate]
GO
ALTER TABLE [dbo].[PendingAmazonOrder] ADD  CONSTRAINT [DF_PendingAmazonOrder_DateEntered]  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[ReconLoadedInventory] ADD  CONSTRAINT [DF_ReconLoadedInventory_Qty]  DEFAULT ((0)) FOR [Qty]
GO
ALTER TABLE [dbo].[ReconLoadedInventory] ADD  CONSTRAINT [DF_ReconLoadedInventory_DateEntered]  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[ReconLoadedInventory] ADD  CONSTRAINT [DF_ReconLoadedInventory_IsReconciled]  DEFAULT ((0)) FOR [IsReconciled]
GO
ALTER TABLE [dbo].[ReconSnapshotDetail] ADD  CONSTRAINT [DF_ReconSnapshotDetail_WarehouseHoldQty]  DEFAULT ((0)) FOR [WarehouseHoldQty]
GO
ALTER TABLE [dbo].[ReconSnapshotDetail] ADD  DEFAULT ((0)) FOR [WarehouseID]
GO
ALTER TABLE [dbo].[SalesForceExtension] ADD  CONSTRAINT [df_SalesForceExtension_DateEntered]  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[SalesForceOrderDetailExtension] ADD  CONSTRAINT [DF_SalesForceOrderDetailExtension_TaxableProduct]  DEFAULT ((0)) FOR [TaxableProduct]
GO
ALTER TABLE [dbo].[SalesForceOrderDetailExtension] ADD  CONSTRAINT [DF_SalesForceOrderDetailExtension_OriginalQuantity]  DEFAULT ((0)) FOR [OriginalQuantity]
GO
ALTER TABLE [dbo].[SalesForceOrderDetailExtension] ADD  CONSTRAINT [DF_SalesForceOrderDetailExtension_CurrentQuantity]  DEFAULT ((0)) FOR [CurrentQuantity]
GO
ALTER TABLE [dbo].[SalesForceOrderDetailExtension] ADD  CONSTRAINT [DF_SalesForceOrderDetailExtension_DateEntered]  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[SalesForceOrderExtension] ADD  CONSTRAINT [DF_SalesForceOrderExtension_TaxExemptOrder]  DEFAULT ((0)) FOR [TaxExemptOrder]
GO
ALTER TABLE [dbo].[ScraperSettings] ADD  CONSTRAINT [DF_OrderScraperSettings_IsUpdate]  DEFAULT ((0)) FOR [IsUpdate]
GO
ALTER TABLE [dbo].[ScraperSettings] ADD  CONSTRAINT [DF_OrderScraperSettings_RunOrder]  DEFAULT ((0)) FOR [RunOrder]
GO
ALTER TABLE [dbo].[ShipMethodFilter] ADD  CONSTRAINT [DF_ShipMethodFilter_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[ShipMethodFilter] ADD  CONSTRAINT [DF_ShipMethodFilter_Active]  DEFAULT ((0)) FOR [Active]
GO
ALTER TABLE [dbo].[SkuPriority] ADD  CONSTRAINT [DF_SkuPriority_Active]  DEFAULT ((0)) FOR [Active]
GO
ALTER TABLE [dbo].[SkuPriority] ADD  CONSTRAINT [DF_SkuPriority_Priority]  DEFAULT ((0)) FOR [Priority]
GO
ALTER TABLE [dbo].[SourceWarehouse] ADD  CONSTRAINT [DF_StoreWarehouse_Active]  DEFAULT ((1)) FOR [Active]
GO
ALTER TABLE [dbo].[Upc] ADD  CONSTRAINT [DF_Upc_IsDropShip]  DEFAULT ((0)) FOR [IsDropShip]
GO
ALTER TABLE [dbo].[Upc] ADD  CONSTRAINT [DF_Upc_IsBackOrdered]  DEFAULT ((0)) FOR [IsBackOrdered]
GO
ALTER TABLE [dbo].[Upc] ADD  CONSTRAINT [DF_Upc_DefaultPrice]  DEFAULT ((10)) FOR [DefaultPrice]
GO
ALTER TABLE [dbo].[Upc] ADD  CONSTRAINT [DF_Upc_IsLTL]  DEFAULT ((0)) FOR [IsLTL]
GO
ALTER TABLE [dbo].[Upc] ADD  CONSTRAINT [DF_Upc_IsTree]  DEFAULT ((0)) FOR [IsTree]
GO
ALTER TABLE [dbo].[Upc] ADD  CONSTRAINT [DF_Upc_CommodityClass]  DEFAULT ((175)) FOR [CommodityClass]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_43] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_43_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_43] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_43] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_44] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_44_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_44] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_44] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_45] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_45_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_45] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_45] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_48] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_48_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_48] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_48] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_58] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_58_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_58] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_58] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_60] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_60_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_60] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_60] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_61] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_61_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_61] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_61] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_63] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_63_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_63] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_63] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_65] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_65_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_65] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_65] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_66] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_66_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_66] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_66] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_67] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_67_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_67] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_67] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_68] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_68_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_68] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_68] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_69] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_69_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_69] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_69] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_70] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_70_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_70] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_70] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_73] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_73_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_73] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_73] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_74] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_74_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_74] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_74] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_76] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_76_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_76] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_76] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_77] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_77_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_77] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_77] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_78] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_78_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_78] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_78] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_79] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_79_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_79] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_79] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_80] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_80_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_80] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_80] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_81] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_81_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_81] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_81] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_82] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_82_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_82] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_82] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_83] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_83_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_83] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_83] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_84] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_84_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_84] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_84] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_85] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_85_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_85] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_85] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_86] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_86_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_86] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_86] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_88] ADD  CONSTRAINT [DF_UpcForLineItemAllocatedToWarehouseID_88_OrderID]  DEFAULT ((0)) FOR [OrderID]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_88] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_88] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_Temp] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_Temp] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_Temp] ADD  DEFAULT ((0)) FOR [TaxableProduct]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_Temp] ADD  DEFAULT ((0)) FOR [OrderTotal]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_Temp1] ADD  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_Temp1] ADD  DEFAULT ((0)) FOR [BeingDelivered]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_Temp1] ADD  DEFAULT ((0)) FOR [TaxableProduct]
GO
ALTER TABLE [dbo].[UpcForLineItemAllocatedToWarehouseID_Temp1] ADD  DEFAULT ((0)) FOR [OrderTotal]
GO
ALTER TABLE [dbo].[UpsHeavyGoodsDailyReturns] ADD  CONSTRAINT [DF_UpsHeavyGoodsDailyReturns_SentToUps]  DEFAULT ((0)) FOR [SentToUps]
GO
ALTER TABLE [dbo].[VolusionSetting] ADD  CONSTRAINT [DF_Store_DiscountPercentage]  DEFAULT ((15.00)) FOR [DiscountPercentage]
GO
ALTER TABLE [dbo].[VolusionSetting] ADD  CONSTRAINT [DF_Store_Active]  DEFAULT ((1)) FOR [Active]
GO
ALTER TABLE [dbo].[VolusionSetting] ADD  CONSTRAINT [DF_Store_PseudoStore]  DEFAULT ((0)) FOR [PseudoStore]
GO
ALTER TABLE [dbo].[VolusionSetting] ADD  CONSTRAINT [DF_Store_IsActiveInOrderLoader]  DEFAULT ((1)) FOR [IsActiveInOrderLoader]
GO
ALTER TABLE [dbo].[VolusionSetting] ADD  CONSTRAINT [DF_Store_RegionID]  DEFAULT ((1)) FOR [RegionID]
GO
ALTER TABLE [dbo].[VolusionSetting] ADD  CONSTRAINT [DF_Store_HasCatalog]  DEFAULT ((0)) FOR [HasCatalog]
GO
ALTER TABLE [dbo].[Warehouse] ADD  CONSTRAINT [DF_Warehouse_Active]  DEFAULT ((1)) FOR [Active]
GO
ALTER TABLE [dbo].[Warehouse] ADD  CONSTRAINT [DF_Warehouse_OutGoingCSV]  DEFAULT ((1)) FOR [GenerateOrderFileCSV]
GO
ALTER TABLE [dbo].[Warehouse] ADD  CONSTRAINT [DF_Warehouse_OutGoingXML]  DEFAULT ((0)) FOR [GenerateOrderFileXML]
GO
ALTER TABLE [dbo].[Warehouse] ADD  CONSTRAINT [DF_Warehouse_SendViaFTP]  DEFAULT ((1)) FOR [SendViaFTP]
GO
ALTER TABLE [dbo].[Warehouse] ADD  CONSTRAINT [DF_Warehouse_SendViaEMAIL]  DEFAULT ((0)) FOR [SendViaEMAIL]
GO
ALTER TABLE [dbo].[Warehouse] ADD  CONSTRAINT [DF_Warehouse_SendViaWebService]  DEFAULT ((0)) FOR [SendViaWebService]
GO
ALTER TABLE [dbo].[Warehouse] ADD  CONSTRAINT [DF_Warehouse_CheckFTPForFile]  DEFAULT ((0)) FOR [CheckFTPForFile]
GO
ALTER TABLE [dbo].[Warehouse] ADD  CONSTRAINT [DF_Warehouse_CutOffTime]  DEFAULT ('10am') FOR [CutOffTime]
GO
ALTER TABLE [dbo].[Warehouse] ADD  CONSTRAINT [DF_Warehouse_SendCommercialInvoicesViaFTP]  DEFAULT ((0)) FOR [SendCommercialInvoicesViaFTP]
GO
ALTER TABLE [dbo].[Warehouse] ADD  CONSTRAINT [DF_Warehouse_SendCommercialInvoicesViaEmail]  DEFAULT ((0)) FOR [SendCommercialInvoicesViaEmail]
GO
ALTER TABLE [dbo].[Warehouse] ADD  CONSTRAINT [DF_Warehouse_FileIteration]  DEFAULT ((0)) FOR [FileIteration]
GO
ALTER TABLE [dbo].[Warehouse] ADD  CONSTRAINT [DF_Warehouse_GenerateWarrantyOrderFileCSV]  DEFAULT ((0)) FOR [GenerateWarrantyOrderFileCSV]
GO
ALTER TABLE [dbo].[Warehouse] ADD  CONSTRAINT [DF_Warehouse_GenerateWarrantyOrderFileXML]  DEFAULT ((0)) FOR [GenerateWarrantyOrderFileXML]
GO
ALTER TABLE [dbo].[Warehouse] ADD  CONSTRAINT [DF_Warehouse_SendNoOrdersNotificationEmail]  DEFAULT ((0)) FOR [SendNoOrdersNotificationEmail]
GO
ALTER TABLE [dbo].[Warehouse] ADD  CONSTRAINT [DF_Warehouse_HandlesTrackingNumbers]  DEFAULT ((1)) FOR [HandlesTrackingNumbers]
GO
ALTER TABLE [dbo].[Warehouse] ADD  CONSTRAINT [DF_Warehouse_IsWarranty]  DEFAULT ((0)) FOR [IsWarranty]
GO
ALTER TABLE [dbo].[Warehouse] ADD  CONSTRAINT [DF_Warehouse_HandlesPersonalization]  DEFAULT ((0)) FOR [HandlesPersonalization]
GO
ALTER TABLE [dbo].[Warehouse] ADD  CONSTRAINT [DF_Warehouse_PersonalizationExclusive]  DEFAULT ((0)) FOR [PersonalizationExclusive]
GO
ALTER TABLE [dbo].[WarehouseApiSettingsForHanover] ADD  CONSTRAINT [DF_WarehouseApiSettingsForHanover_OrderChunkSize]  DEFAULT ((50)) FOR [OrderChunkSize]
GO
ALTER TABLE [dbo].[WarehouseFTPSite] ADD  CONSTRAINT [DF_WarehouseFTPSite_Port]  DEFAULT (NULL) FOR [Port]
GO
ALTER TABLE [dbo].[WarehouseFTPSite] ADD  CONSTRAINT [DF_WarehouseFTPSite_Secure]  DEFAULT ((0)) FOR [Secure]
GO
ALTER TABLE [dbo].[WarehouseFTPSite] ADD  CONSTRAINT [DF_WarehouseFTPSite_IsConnectionModeActive]  DEFAULT ((0)) FOR [IsConnectionModeActive]
GO
ALTER TABLE [dbo].[WarehouseRegexPattern] ADD  CONSTRAINT [DF_WarehouseRegexPattern_TrackingFile]  DEFAULT ((0)) FOR [TrackingFile]
GO
ALTER TABLE [dbo].[WarehouseSchedule] ADD  CONSTRAINT [DF_WarehouseSchedule_Active]  DEFAULT ((1)) FOR [Active]
GO
ALTER TABLE [dbo].[WarehouseSchedule] ADD  CONSTRAINT [DF_WarehouseSchedule_SendEmail]  DEFAULT ((1)) FOR [SendEmail]
GO
ALTER TABLE [dbo].[WarehouseScheduleDetail] ADD  CONSTRAINT [DF_WarehouseScheduleDetail_Monday]  DEFAULT ((0)) FOR [Monday]
GO
ALTER TABLE [dbo].[WarehouseScheduleDetail] ADD  CONSTRAINT [DF_WarehouseScheduleDetail_Tuesday]  DEFAULT ((0)) FOR [Tuesday]
GO
ALTER TABLE [dbo].[WarehouseScheduleDetail] ADD  CONSTRAINT [DF_WarehouseScheduleDetail_Wednesday]  DEFAULT ((0)) FOR [Wednesday]
GO
ALTER TABLE [dbo].[WarehouseScheduleDetail] ADD  CONSTRAINT [DF_WarehouseScheduleDetail_Thursday]  DEFAULT ((0)) FOR [Thursday]
GO
ALTER TABLE [dbo].[WarehouseScheduleDetail] ADD  CONSTRAINT [DF_WarehouseScheduleDetail_Friday]  DEFAULT ((0)) FOR [Friday]
GO
ALTER TABLE [dbo].[WarehouseScheduleDetail] ADD  CONSTRAINT [DF_WarehouseScheduleDetail_Saturday]  DEFAULT ((0)) FOR [Saturday]
GO
ALTER TABLE [dbo].[WarehouseScheduleDetail] ADD  CONSTRAINT [DF_WarehouseScheduleDetail_Sunday]  DEFAULT ((0)) FOR [Sunday]
GO
ALTER TABLE [dbo].[AmazonTrackingNumberInProcessing]  WITH CHECK ADD  CONSTRAINT [FK_MarketplaceTrackingNumberInProcessing_MarketplaceAmazonFeedStatusInProcessingID_MarketplaceAmazonFeedStatusInProcessing_ID] FOREIGN KEY([MarketplaceAmazonFeedStatusInProcessingID])
REFERENCES [dbo].[MarketplaceAmazonFeedStatusInProcessing] ([ID])
GO
ALTER TABLE [dbo].[AmazonTrackingNumberInProcessing] CHECK CONSTRAINT [FK_MarketplaceTrackingNumberInProcessing_MarketplaceAmazonFeedStatusInProcessingID_MarketplaceAmazonFeedStatusInProcessing_ID]
GO
ALTER TABLE [dbo].[AmazonTrackingNumberInProcessing]  WITH CHECK ADD  CONSTRAINT [FK_MarketplaceTrackingNumberInProcessing_MarketplaceOrderLineItemID_MarketplaceOrderLineItem_MarketplaceOrderLineItemID] FOREIGN KEY([MarketplaceOrderLineItemID])
REFERENCES [dbo].[MarketplaceOrderLineItem] ([MarketplaceOrderLineItemID])
GO
ALTER TABLE [dbo].[AmazonTrackingNumberInProcessing] CHECK CONSTRAINT [FK_MarketplaceTrackingNumberInProcessing_MarketplaceOrderLineItemID_MarketplaceOrderLineItem_MarketplaceOrderLineItemID]
GO
ALTER TABLE [dbo].[AmendmentQueue]  WITH CHECK ADD  CONSTRAINT [FK_AmendmentQueue_ID_AmendmentCorrelation_ID] FOREIGN KEY([ID])
REFERENCES [dbo].[AmendmentCorrelation] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AmendmentQueue] CHECK CONSTRAINT [FK_AmendmentQueue_ID_AmendmentCorrelation_ID]
GO
ALTER TABLE [dbo].[AmendmentStagedOrder]  WITH CHECK ADD  CONSTRAINT [FK_AmendmentStagedOrder_AmendmentCorrelationID_AmendmentCorrelation_ID] FOREIGN KEY([AmendmentCorrelationID])
REFERENCES [dbo].[AmendmentCorrelation] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AmendmentStagedOrder] CHECK CONSTRAINT [FK_AmendmentStagedOrder_AmendmentCorrelationID_AmendmentCorrelation_ID]
GO
ALTER TABLE [dbo].[AmendmentStagedOrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_AmendmentStagedOrderDetail_AmendmentCorrelationID_AmendmentCorrelation_ID] FOREIGN KEY([AmendmentCorrelationID])
REFERENCES [dbo].[AmendmentCorrelation] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AmendmentStagedOrderDetail] CHECK CONSTRAINT [FK_AmendmentStagedOrderDetail_AmendmentCorrelationID_AmendmentCorrelation_ID]
GO
ALTER TABLE [dbo].[AmendmentStagedOrderDiscountDetail]  WITH CHECK ADD  CONSTRAINT [FK_AmendmentStagedOrderDiscountDetail_AmendmentCorrelationID_AmendmentCorrelation_ID] FOREIGN KEY([AmendmentCorrelationID])
REFERENCES [dbo].[AmendmentCorrelation] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AmendmentStagedOrderDiscountDetail] CHECK CONSTRAINT [FK_AmendmentStagedOrderDiscountDetail_AmendmentCorrelationID_AmendmentCorrelation_ID]
GO
ALTER TABLE [dbo].[AmendmentStagedOrderTax]  WITH CHECK ADD  CONSTRAINT [FK_AmendmentStagedOrderTax_AmendmentCorrelationID_AmendmentCorrelation_ID] FOREIGN KEY([AmendmentCorrelationID])
REFERENCES [dbo].[AmendmentCorrelation] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AmendmentStagedOrderTax] CHECK CONSTRAINT [FK_AmendmentStagedOrderTax_AmendmentCorrelationID_AmendmentCorrelation_ID]
GO
ALTER TABLE [dbo].[BrandSkuBackOrder]  WITH CHECK ADD  CONSTRAINT [FK_BrandSkuBackOrder_BrandSkuID_BrandSku_ID] FOREIGN KEY([BrandSkuID])
REFERENCES [dbo].[BrandSku] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[BrandSkuBackOrder] CHECK CONSTRAINT [FK_BrandSkuBackOrder_BrandSkuID_BrandSku_ID]
GO
ALTER TABLE [dbo].[BrandSkuFraudItem]  WITH CHECK ADD  CONSTRAINT [FK_BrandSkuFraudItem_BrandSkuID_BrandSku_ID] FOREIGN KEY([BrandSkuID])
REFERENCES [dbo].[BrandSku] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[BrandSkuFraudItem] CHECK CONSTRAINT [FK_BrandSkuFraudItem_BrandSkuID_BrandSku_ID]
GO
ALTER TABLE [dbo].[BrandSkuUpc]  WITH CHECK ADD  CONSTRAINT [FK_BrandSkuUpc_BrandSkuID_BrandSku_ID] FOREIGN KEY([BrandSkuID])
REFERENCES [dbo].[BrandSku] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[BrandSkuUpc] CHECK CONSTRAINT [FK_BrandSkuUpc_BrandSkuID_BrandSku_ID]
GO
ALTER TABLE [dbo].[BrandSkuUpc]  WITH CHECK ADD  CONSTRAINT [FK_BrandSkuUpc_UpcID_Upc_ID] FOREIGN KEY([UpcID])
REFERENCES [dbo].[Upc] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[BrandSkuUpc] CHECK CONSTRAINT [FK_BrandSkuUpc_UpcID_Upc_ID]
GO
ALTER TABLE [dbo].[BrontoEmailTemplateFields]  WITH CHECK ADD  CONSTRAINT [FK_BrontoEmailTemplateFields_TemplateID_BrontoEmailTemplate_ID] FOREIGN KEY([TemplateID])
REFERENCES [dbo].[BrontoEmailTemplate] ([ID])
GO
ALTER TABLE [dbo].[BrontoEmailTemplateFields] CHECK CONSTRAINT [FK_BrontoEmailTemplateFields_TemplateID_BrontoEmailTemplate_ID]
GO
ALTER TABLE [dbo].[BrontoOrderEmail]  WITH CHECK ADD  CONSTRAINT [FK_BrontoOrderEmail_EmailContactID_BrontoEmailContact_ID] FOREIGN KEY([EmailContactID])
REFERENCES [dbo].[BrontoEmailContact] ([ID])
GO
ALTER TABLE [dbo].[BrontoOrderEmail] CHECK CONSTRAINT [FK_BrontoOrderEmail_EmailContactID_BrontoEmailContact_ID]
GO
ALTER TABLE [dbo].[BrontoOrderEmailTrackingNumber]  WITH CHECK ADD  CONSTRAINT [FK_BrontoOrderEmailTrackingNumber_OrderEmailID_BrontoOrderEmail_ID] FOREIGN KEY([OrderEmailID])
REFERENCES [dbo].[BrontoOrderEmail] ([ID])
GO
ALTER TABLE [dbo].[BrontoOrderEmailTrackingNumber] CHECK CONSTRAINT [FK_BrontoOrderEmailTrackingNumber_OrderEmailID_BrontoOrderEmail_ID]
GO
ALTER TABLE [dbo].[BrontoOrderEmailTrackingNumber]  WITH CHECK ADD  CONSTRAINT [FK_BrontoOrderEmailTrackingNumber_StoreSkuImageID_BrontoStoreSkuImage_ID] FOREIGN KEY([StoreSkuImageID])
REFERENCES [dbo].[BrontoBrandSkuImage] ([ID])
GO
ALTER TABLE [dbo].[BrontoOrderEmailTrackingNumber] CHECK CONSTRAINT [FK_BrontoOrderEmailTrackingNumber_StoreSkuImageID_BrontoStoreSkuImage_ID]
GO
ALTER TABLE [dbo].[BrontoOrderEmailTrackingNumber]  WITH CHECK ADD  CONSTRAINT [FK_BrontoOrderEmailTrackingNumber_WarehouseID_Warehouse_WarehouseID] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
GO
ALTER TABLE [dbo].[BrontoOrderEmailTrackingNumber] CHECK CONSTRAINT [FK_BrontoOrderEmailTrackingNumber_WarehouseID_Warehouse_WarehouseID]
GO
ALTER TABLE [dbo].[CountryPriority]  WITH CHECK ADD  CONSTRAINT [FK_CountryPriority_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CountryPriority] CHECK CONSTRAINT [FK_CountryPriority_Warehouse]
GO
ALTER TABLE [dbo].[HybrisNotifyMe]  WITH CHECK ADD  CONSTRAINT [FK_HybrisNotifyMe_BrontoEmailContactID_BrontoEmailContact_ID] FOREIGN KEY([BrontoEmailContactID])
REFERENCES [dbo].[BrontoEmailContact] ([ID])
GO
ALTER TABLE [dbo].[HybrisNotifyMe] CHECK CONSTRAINT [FK_HybrisNotifyMe_BrontoEmailContactID_BrontoEmailContact_ID]
GO
ALTER TABLE [dbo].[HybrisNotifyMe]  WITH CHECK ADD  CONSTRAINT [FK_HybrisNotifyMe_BrontoStoreSkuImageID_BrontoStoreSkuImage_ID] FOREIGN KEY([BrontoStoreSkuImageID])
REFERENCES [dbo].[BrontoBrandSkuImage] ([ID])
GO
ALTER TABLE [dbo].[HybrisNotifyMe] CHECK CONSTRAINT [FK_HybrisNotifyMe_BrontoStoreSkuImageID_BrontoStoreSkuImage_ID]
GO
ALTER TABLE [dbo].[IncompatibleUPC]  WITH CHECK ADD  CONSTRAINT [FK_IncompatibleUpc_IncompatibleUpcID_Upc_ID] FOREIGN KEY([IncompatibleUpcID])
REFERENCES [dbo].[Upc] ([ID])
GO
ALTER TABLE [dbo].[IncompatibleUPC] CHECK CONSTRAINT [FK_IncompatibleUpc_IncompatibleUpcID_Upc_ID]
GO
ALTER TABLE [dbo].[IncompatibleUPC]  WITH CHECK ADD  CONSTRAINT [FK_IncompatibleUpc_UpcID_Upc_ID] FOREIGN KEY([UpcID])
REFERENCES [dbo].[Upc] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[IncompatibleUPC] CHECK CONSTRAINT [FK_IncompatibleUpc_UpcID_Upc_ID]
GO
ALTER TABLE [dbo].[InvalidOrderLineItem]  WITH CHECK ADD  CONSTRAINT [FK_InvalidOrderLineItem_InvalidOrderID_InvalidOrder_ID] FOREIGN KEY([InvalidOrderID])
REFERENCES [dbo].[InvalidOrder] ([Id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvalidOrderLineItem] CHECK CONSTRAINT [FK_InvalidOrderLineItem_InvalidOrderID_InvalidOrder_ID]
GO
ALTER TABLE [dbo].[InvalidOrderLineItemUpcDetail]  WITH CHECK ADD  CONSTRAINT [FK_InvalidOrderLineItemUpcDetail_InvalidOrderLineItemID_InvalidOrderLineItem_ID] FOREIGN KEY([InvalidOrderLineItemID])
REFERENCES [dbo].[InvalidOrderLineItem] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvalidOrderLineItemUpcDetail] CHECK CONSTRAINT [FK_InvalidOrderLineItemUpcDetail_InvalidOrderLineItemID_InvalidOrderLineItem_ID]
GO
ALTER TABLE [dbo].[Inventory]  WITH CHECK ADD  CONSTRAINT [FK_Inventory_UpcID_Upc_ID] FOREIGN KEY([UpcID])
REFERENCES [dbo].[Upc] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Inventory] CHECK CONSTRAINT [FK_Inventory_UpcID_Upc_ID]
GO
ALTER TABLE [dbo].[Inventory]  WITH NOCHECK ADD  CONSTRAINT [FK_Inventory_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Inventory] CHECK CONSTRAINT [FK_Inventory_Warehouse]
GO
ALTER TABLE [dbo].[InventoryHoldForWarehouse]  WITH CHECK ADD  CONSTRAINT [InventoryHoldForWarehouse_UpcID_Upc_ID] FOREIGN KEY([UpcID])
REFERENCES [dbo].[Upc] ([ID])
GO
ALTER TABLE [dbo].[InventoryHoldForWarehouse] CHECK CONSTRAINT [InventoryHoldForWarehouse_UpcID_Upc_ID]
GO
ALTER TABLE [dbo].[InventoryHoldForWarehouse]  WITH CHECK ADD  CONSTRAINT [InventoryHoldForWarehouse_WarehouseID_Warehouse_WarehouseID] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
GO
ALTER TABLE [dbo].[InventoryHoldForWarehouse] CHECK CONSTRAINT [InventoryHoldForWarehouse_WarehouseID_Warehouse_WarehouseID]
GO
ALTER TABLE [dbo].[InventoryThreshold]  WITH CHECK ADD  CONSTRAINT [FK_InventoryThreshold_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InventoryThreshold] CHECK CONSTRAINT [FK_InventoryThreshold_Warehouse]
GO
ALTER TABLE [dbo].[InvPurchaseInvoice]  WITH CHECK ADD  CONSTRAINT [FK_WarehouseInvoice_InvPurchaseReceiptFile] FOREIGN KEY([InvPurchaseReceiptFileID])
REFERENCES [dbo].[InvPurchaseReceiptFile] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvPurchaseInvoice] CHECK CONSTRAINT [FK_WarehouseInvoice_InvPurchaseReceiptFile]
GO
ALTER TABLE [dbo].[InvPurchaseInvoiceProduct]  WITH CHECK ADD  CONSTRAINT [FK_InvPurchaseInvoiceProduct_InvPurchaseInvoice] FOREIGN KEY([InvPurchaseInvoiceID])
REFERENCES [dbo].[InvPurchaseInvoice] ([ID])
GO
ALTER TABLE [dbo].[InvPurchaseInvoiceProduct] CHECK CONSTRAINT [FK_InvPurchaseInvoiceProduct_InvPurchaseInvoice]
GO
ALTER TABLE [dbo].[InvPurchaseInvoiceProduct]  WITH CHECK ADD  CONSTRAINT [FK_InvPurchaseInvoiceProduct_InvPurchaseReceiptProduct] FOREIGN KEY([InvPurchaseReceiptProductID])
REFERENCES [dbo].[InvPurchaseReceiptProduct] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvPurchaseInvoiceProduct] CHECK CONSTRAINT [FK_InvPurchaseInvoiceProduct_InvPurchaseReceiptProduct]
GO
ALTER TABLE [dbo].[InvPurchaseInvoiceProduct]  WITH CHECK ADD  CONSTRAINT [FK_InvPurchaseInvoiceProduct_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvPurchaseInvoiceProduct] CHECK CONSTRAINT [FK_InvPurchaseInvoiceProduct_Warehouse]
GO
ALTER TABLE [dbo].[InvPurchaseProductCarton]  WITH CHECK ADD  CONSTRAINT [FK_InvPurchaseProductCarton_InvPurchaseCarton] FOREIGN KEY([InvPurchaseCartonID])
REFERENCES [dbo].[InvPurchaseCarton] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvPurchaseProductCarton] CHECK CONSTRAINT [FK_InvPurchaseProductCarton_InvPurchaseCarton]
GO
ALTER TABLE [dbo].[InvPurchaseProductCarton]  WITH CHECK ADD  CONSTRAINT [FK_InvPurchaseProductCarton_InvPurchaseProduct] FOREIGN KEY([InvPurchaseProductID])
REFERENCES [dbo].[InvPurchaseProduct] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvPurchaseProductCarton] CHECK CONSTRAINT [FK_InvPurchaseProductCarton_InvPurchaseProduct]
GO
ALTER TABLE [dbo].[InvPurchaseReceiptProduct]  WITH CHECK ADD  CONSTRAINT [FK_InvPurchaseReceiptProduct_InvPurchaseProduct] FOREIGN KEY([InvPurchaseProductID])
REFERENCES [dbo].[InvPurchaseProduct] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvPurchaseReceiptProduct] CHECK CONSTRAINT [FK_InvPurchaseReceiptProduct_InvPurchaseProduct]
GO
ALTER TABLE [dbo].[InvPurchaseReceiptProduct]  WITH CHECK ADD  CONSTRAINT [FK_InvPurchaseReceiptProduct_InvPurchaseReceiptFile] FOREIGN KEY([InvPurchaseReceiptFileID])
REFERENCES [dbo].[InvPurchaseReceiptFile] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvPurchaseReceiptProduct] CHECK CONSTRAINT [FK_InvPurchaseReceiptProduct_InvPurchaseReceiptFile]
GO
ALTER TABLE [dbo].[InvPurchaseReceiptProductStoreAssociation]  WITH CHECK ADD  CONSTRAINT [FK_InvPurchaseReceiptProductStoreAssociation_InvPurchaseReceiptProduct] FOREIGN KEY([InvPurchaseReceiptProductID])
REFERENCES [dbo].[InvPurchaseReceiptProduct] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvPurchaseReceiptProductStoreAssociation] CHECK CONSTRAINT [FK_InvPurchaseReceiptProductStoreAssociation_InvPurchaseReceiptProduct]
GO
ALTER TABLE [dbo].[LineItemRequiringTrackingNumber]  WITH CHECK ADD  CONSTRAINT [FK_CustOrderTracking_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LineItemRequiringTrackingNumber] CHECK CONSTRAINT [FK_CustOrderTracking_Warehouse]
GO
ALTER TABLE [dbo].[LoadedUndeliveredLineItem]  WITH CHECK ADD  CONSTRAINT [FK_LoadedUndeliveredLineItem_BrandSkuID_BrandSku_ID] FOREIGN KEY([BrandSkuID])
REFERENCES [dbo].[BrandSku] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LoadedUndeliveredLineItem] CHECK CONSTRAINT [FK_LoadedUndeliveredLineItem_BrandSkuID_BrandSku_ID]
GO
ALTER TABLE [dbo].[LoadedUndeliveredLineItemWithAllocationDetails]  WITH CHECK ADD  CONSTRAINT [FK_LoadedUndeliveredLineItemWithAllocationDetails_Upc] FOREIGN KEY([UpcID])
REFERENCES [dbo].[Upc] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LoadedUndeliveredLineItemWithAllocationDetails] CHECK CONSTRAINT [FK_LoadedUndeliveredLineItemWithAllocationDetails_Upc]
GO
ALTER TABLE [dbo].[LoadedUndeliveredLineItemWithAllocationDetails]  WITH CHECK ADD  CONSTRAINT [FK_LoadedUndeliveredLineItemWithAllocationDetails_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LoadedUndeliveredLineItemWithAllocationDetails] CHECK CONSTRAINT [FK_LoadedUndeliveredLineItemWithAllocationDetails_Warehouse]
GO
ALTER TABLE [dbo].[Mapping]  WITH CHECK ADD  CONSTRAINT [FK_Mapping_MappingCategory] FOREIGN KEY([MappingCategoryID])
REFERENCES [dbo].[MappingCategory] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Mapping] CHECK CONSTRAINT [FK_Mapping_MappingCategory]
GO
ALTER TABLE [dbo].[Mapping]  WITH CHECK ADD  CONSTRAINT [FK_Mapping_MappingFileCategory] FOREIGN KEY([MappingFileCategoryID])
REFERENCES [dbo].[MappingFileCategory] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Mapping] CHECK CONSTRAINT [FK_Mapping_MappingFileCategory]
GO
ALTER TABLE [dbo].[MappingCategoryField]  WITH CHECK ADD  CONSTRAINT [FK_MappingCategoryField_MappingCategory] FOREIGN KEY([MappingCategoryID])
REFERENCES [dbo].[MappingCategory] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MappingCategoryField] CHECK CONSTRAINT [FK_MappingCategoryField_MappingCategory]
GO
ALTER TABLE [dbo].[MappingCategoryField]  WITH CHECK ADD  CONSTRAINT [FK_MappingCategoryField_MappingCategoryFieldDetail] FOREIGN KEY([MappingCategoryFieldDetailID])
REFERENCES [dbo].[MappingCategoryFieldDetail] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MappingCategoryField] CHECK CONSTRAINT [FK_MappingCategoryField_MappingCategoryFieldDetail]
GO
ALTER TABLE [dbo].[MappingCategoryFieldWarehouse]  WITH CHECK ADD  CONSTRAINT [FK_MappingCategoryFieldWarehouse_MappingCategory] FOREIGN KEY([MappingCategoryID])
REFERENCES [dbo].[MappingCategory] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MappingCategoryFieldWarehouse] CHECK CONSTRAINT [FK_MappingCategoryFieldWarehouse_MappingCategory]
GO
ALTER TABLE [dbo].[MappingCategoryFieldWarehouse]  WITH CHECK ADD  CONSTRAINT [FK_MappingCategoryFieldWarehouse_MappingCategoryFieldDetail] FOREIGN KEY([MappingCategoryFieldDetailID])
REFERENCES [dbo].[MappingCategoryFieldDetail] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MappingCategoryFieldWarehouse] CHECK CONSTRAINT [FK_MappingCategoryFieldWarehouse_MappingCategoryFieldDetail]
GO
ALTER TABLE [dbo].[MappingCategoryFieldWarehouse]  WITH CHECK ADD  CONSTRAINT [FK_MappingCategoryFieldWarehouse_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MappingCategoryFieldWarehouse] CHECK CONSTRAINT [FK_MappingCategoryFieldWarehouse_Warehouse]
GO
ALTER TABLE [dbo].[MappingDetail]  WITH CHECK ADD  CONSTRAINT [FK_MappingDetail_Mapping] FOREIGN KEY([MappingID])
REFERENCES [dbo].[Mapping] ([ID])
GO
ALTER TABLE [dbo].[MappingDetail] CHECK CONSTRAINT [FK_MappingDetail_Mapping]
GO
ALTER TABLE [dbo].[MappingDetail]  WITH CHECK ADD  CONSTRAINT [FK_MappingDetail_MappingCategoryFieldDetail] FOREIGN KEY([MappingCategoryFieldDetailID])
REFERENCES [dbo].[MappingCategoryFieldDetail] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MappingDetail] CHECK CONSTRAINT [FK_MappingDetail_MappingCategoryFieldDetail]
GO
ALTER TABLE [dbo].[MarketplaceOrderLineItem]  WITH CHECK ADD  CONSTRAINT [FK_MarketplaceOrderLineItem_MarketplaceOrderID_MarketplaceOrder_MarketplaceOrderID] FOREIGN KEY([MarketplaceOrderID])
REFERENCES [dbo].[MarketplaceOrder] ([MarketplaceOrderID])
GO
ALTER TABLE [dbo].[MarketplaceOrderLineItem] CHECK CONSTRAINT [FK_MarketplaceOrderLineItem_MarketplaceOrderID_MarketplaceOrder_MarketplaceOrderID]
GO
ALTER TABLE [dbo].[OrderAmendmentCode]  WITH CHECK ADD  CONSTRAINT [FK_OrderAmendmentCode_OrderAmendmentTypeID_OrderAmendmentType_ID] FOREIGN KEY([OrderAmendmentTypeID])
REFERENCES [dbo].[OrderAmendmentType] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[OrderAmendmentCode] CHECK CONSTRAINT [FK_OrderAmendmentCode_OrderAmendmentTypeID_OrderAmendmentType_ID]
GO
ALTER TABLE [dbo].[ProductOptionCategorySkus]  WITH CHECK ADD  CONSTRAINT [FK_ProductOptionCategorySkus_ProductOptionCategoryID_ProductOptionCategory_ID] FOREIGN KEY([ProductOptionCategoryID])
REFERENCES [dbo].[ProductOptionCategory] ([ID])
GO
ALTER TABLE [dbo].[ProductOptionCategorySkus] CHECK CONSTRAINT [FK_ProductOptionCategorySkus_ProductOptionCategoryID_ProductOptionCategory_ID]
GO
ALTER TABLE [dbo].[ProductOptionTemplate]  WITH CHECK ADD  CONSTRAINT [FK_ProductOptionTemplate_TemplateCategoryID_ProductOptionCategory_ID] FOREIGN KEY([TemplateCategoryID])
REFERENCES [dbo].[ProductOptionCategory] ([ID])
GO
ALTER TABLE [dbo].[ProductOptionTemplate] CHECK CONSTRAINT [FK_ProductOptionTemplate_TemplateCategoryID_ProductOptionCategory_ID]
GO
ALTER TABLE [dbo].[ProductOptionTemplateDefaults]  WITH CHECK ADD  CONSTRAINT [FK_ProductOptionTemplateDefaults_ProductOptionCategoryID_ProductOptionCategory_ID] FOREIGN KEY([ProductOptionCategoryID])
REFERENCES [dbo].[ProductOptionCategory] ([ID])
GO
ALTER TABLE [dbo].[ProductOptionTemplateDefaults] CHECK CONSTRAINT [FK_ProductOptionTemplateDefaults_ProductOptionCategoryID_ProductOptionCategory_ID]
GO
ALTER TABLE [dbo].[ProductOptionTemplateDefaults]  WITH CHECK ADD  CONSTRAINT [FK_ProductOptionTemplateDefaults_ProductOptionTemplateID_ProductOptionTemplate_ID] FOREIGN KEY([ProductOptionTemplateID])
REFERENCES [dbo].[ProductOptionTemplate] ([ID])
GO
ALTER TABLE [dbo].[ProductOptionTemplateDefaults] CHECK CONSTRAINT [FK_ProductOptionTemplateDefaults_ProductOptionTemplateID_ProductOptionTemplate_ID]
GO
ALTER TABLE [dbo].[ProductOptionTemplateDefaults]  WITH CHECK ADD  CONSTRAINT [FK_ProductOptionTemplateDefaults_ProductOptionValueID_ProductOptionValue_ID] FOREIGN KEY([ProductOptionValueID])
REFERENCES [dbo].[ProductOptionValue] ([ID])
GO
ALTER TABLE [dbo].[ProductOptionTemplateDefaults] CHECK CONSTRAINT [FK_ProductOptionTemplateDefaults_ProductOptionValueID_ProductOptionValue_ID]
GO
ALTER TABLE [dbo].[ProductOptionValue]  WITH CHECK ADD  CONSTRAINT [FK_ProductOptionValue_ProductOptionTemplateId_ProductOptionTemplate_ID] FOREIGN KEY([ProductOptionTemplateId])
REFERENCES [dbo].[ProductOptionTemplate] ([ID])
GO
ALTER TABLE [dbo].[ProductOptionValue] CHECK CONSTRAINT [FK_ProductOptionValue_ProductOptionTemplateId_ProductOptionTemplate_ID]
GO
ALTER TABLE [dbo].[SalesForceOrderDetailExtension]  WITH CHECK ADD  CONSTRAINT [FK_SalesForceOrderDetailExtension_SalesForceOrderExtensionID_SalesForceOrderExtension_ID] FOREIGN KEY([SalesForceOrderExtensionID])
REFERENCES [dbo].[SalesForceOrderExtension] ([ID])
GO
ALTER TABLE [dbo].[SalesForceOrderDetailExtension] CHECK CONSTRAINT [FK_SalesForceOrderDetailExtension_SalesForceOrderExtensionID_SalesForceOrderExtension_ID]
GO
ALTER TABLE [dbo].[SalesforceOrderPaymentExtension]  WITH CHECK ADD  CONSTRAINT [FK_SalesforceOrderPaymentExtension_SalesForceOrderExtensionID_SalesForceOrderExtension_ID] FOREIGN KEY([SalesForceOrderExtensionID])
REFERENCES [dbo].[SalesForceOrderExtension] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SalesforceOrderPaymentExtension] CHECK CONSTRAINT [FK_SalesforceOrderPaymentExtension_SalesForceOrderExtensionID_SalesForceOrderExtension_ID]
GO
ALTER TABLE [dbo].[SalesforceShippingDetail]  WITH CHECK ADD  CONSTRAINT [FK_SalesforceShippingDetail_SalesforceOrderDetailExtension] FOREIGN KEY([SalesforceOrderDetailExtensionID])
REFERENCES [dbo].[SalesForceOrderDetailExtension] ([ID])
GO
ALTER TABLE [dbo].[SalesforceShippingDetail] CHECK CONSTRAINT [FK_SalesforceShippingDetail_SalesforceOrderDetailExtension]
GO
ALTER TABLE [dbo].[SalesforceTax]  WITH CHECK ADD  CONSTRAINT [FK_SalesforceTax_SalesforceOrderDetailExtensionID_SalesForceOrderDetailExtension_ID] FOREIGN KEY([SalesforceOrderDetailExtensionID])
REFERENCES [dbo].[SalesForceOrderDetailExtension] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SalesforceTax] CHECK CONSTRAINT [FK_SalesforceTax_SalesforceOrderDetailExtensionID_SalesForceOrderDetailExtension_ID]
GO
ALTER TABLE [dbo].[ScraperSettings]  WITH CHECK ADD  CONSTRAINT [FK_ScraperSettings_ScraperSettingsType] FOREIGN KEY([ScraperSettingTypeID])
REFERENCES [dbo].[ScraperSettingsType] ([ScraperSettingTypeID])
GO
ALTER TABLE [dbo].[ScraperSettings] CHECK CONSTRAINT [FK_ScraperSettings_ScraperSettingsType]
GO
ALTER TABLE [dbo].[ShipMethodFilterWarehouseAssociation]  WITH CHECK ADD  CONSTRAINT [FK_ShipMethodFilterWarehouseAssociation_ShipMethodFilter] FOREIGN KEY([ShipMethodFilterID])
REFERENCES [dbo].[ShipMethodFilter] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ShipMethodFilterWarehouseAssociation] CHECK CONSTRAINT [FK_ShipMethodFilterWarehouseAssociation_ShipMethodFilter]
GO
ALTER TABLE [dbo].[ShipMethodFilterWarehouseAssociation]  WITH CHECK ADD  CONSTRAINT [FK_ShipMethodFilterWarehouseAssociation_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ShipMethodFilterWarehouseAssociation] CHECK CONSTRAINT [FK_ShipMethodFilterWarehouseAssociation_Warehouse]
GO
ALTER TABLE [dbo].[ShipZone]  WITH CHECK ADD  CONSTRAINT [FK_ShipZone_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ShipZone] CHECK CONSTRAINT [FK_ShipZone_Warehouse]
GO
ALTER TABLE [dbo].[SkuPriority]  WITH CHECK ADD  CONSTRAINT [FK_SkuPriority_UpcID_Upc_ID] FOREIGN KEY([UpcID])
REFERENCES [dbo].[Upc] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SkuPriority] CHECK CONSTRAINT [FK_SkuPriority_UpcID_Upc_ID]
GO
ALTER TABLE [dbo].[SkuPriority]  WITH CHECK ADD  CONSTRAINT [FK_SkuPriority_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SkuPriority] CHECK CONSTRAINT [FK_SkuPriority_Warehouse]
GO
ALTER TABLE [dbo].[SourceBrandSkuUpcRecon]  WITH CHECK ADD  CONSTRAINT [FK_SourceBrandSkuUpcRecon_BrandSkuUpcID_BrandSkuUpc_ID] FOREIGN KEY([BrandSkuUpcID])
REFERENCES [dbo].[BrandSkuUpc] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SourceBrandSkuUpcRecon] CHECK CONSTRAINT [FK_SourceBrandSkuUpcRecon_BrandSkuUpcID_BrandSkuUpc_ID]
GO
ALTER TABLE [dbo].[SourceWarehouse]  WITH CHECK ADD  CONSTRAINT [FK_StoreWarehouse_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SourceWarehouse] CHECK CONSTRAINT [FK_StoreWarehouse_Warehouse]
GO
ALTER TABLE [dbo].[SourceWarehouseFtpSiteAssociation]  WITH CHECK ADD  CONSTRAINT [FK_StoreWarehouseFtpSiteAssociation_WarehouseFTPSite] FOREIGN KEY([WarehouseFTPSiteID])
REFERENCES [dbo].[WarehouseFTPSite] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SourceWarehouseFtpSiteAssociation] CHECK CONSTRAINT [FK_StoreWarehouseFtpSiteAssociation_WarehouseFTPSite]
GO
ALTER TABLE [dbo].[StoreMappings]  WITH CHECK ADD  CONSTRAINT [FK_StoreMappings_Mapping] FOREIGN KEY([MappingID])
REFERENCES [dbo].[Mapping] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[StoreMappings] CHECK CONSTRAINT [FK_StoreMappings_Mapping]
GO
ALTER TABLE [dbo].[UpcMasterPackAssociations]  WITH CHECK ADD  CONSTRAINT [FK_UpcMasterPackAssociations_InnerPackUpcID_Upc_ID] FOREIGN KEY([InnerPackUpcID])
REFERENCES [dbo].[Upc] ([ID])
GO
ALTER TABLE [dbo].[UpcMasterPackAssociations] CHECK CONSTRAINT [FK_UpcMasterPackAssociations_InnerPackUpcID_Upc_ID]
GO
ALTER TABLE [dbo].[UpcMasterPackAssociations]  WITH CHECK ADD  CONSTRAINT [FK_UpcMasterPackAssociations_MasterPackUpcID_Upc_ID] FOREIGN KEY([MasterPackUpcID])
REFERENCES [dbo].[Upc] ([ID])
GO
ALTER TABLE [dbo].[UpcMasterPackAssociations] CHECK CONSTRAINT [FK_UpcMasterPackAssociations_MasterPackUpcID_Upc_ID]
GO
ALTER TABLE [dbo].[WarehouseCodeLookup]  WITH CHECK ADD  CONSTRAINT [FK_WarehouseCodeLookup_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
GO
ALTER TABLE [dbo].[WarehouseCodeLookup] CHECK CONSTRAINT [FK_WarehouseCodeLookup_Warehouse]
GO
ALTER TABLE [dbo].[WarehouseFTPSite]  WITH NOCHECK ADD  CONSTRAINT [FK_WarehouseFTPSite_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WarehouseFTPSite] CHECK CONSTRAINT [FK_WarehouseFTPSite_Warehouse]
GO
ALTER TABLE [dbo].[WarehouseInventoryMapping]  WITH NOCHECK ADD  CONSTRAINT [FK_WarehouseInventoryMapping_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WarehouseInventoryMapping] CHECK CONSTRAINT [FK_WarehouseInventoryMapping_Warehouse]
GO
ALTER TABLE [dbo].[WarehouseMappings]  WITH CHECK ADD  CONSTRAINT [FK_WarehouseMappings_Mapping] FOREIGN KEY([MappingID])
REFERENCES [dbo].[Mapping] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WarehouseMappings] CHECK CONSTRAINT [FK_WarehouseMappings_Mapping]
GO
ALTER TABLE [dbo].[WarehouseMappings]  WITH CHECK ADD  CONSTRAINT [FK_WarehouseMappings_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WarehouseMappings] CHECK CONSTRAINT [FK_WarehouseMappings_Warehouse]
GO
ALTER TABLE [dbo].[WarehousePostalCodePromotion]  WITH CHECK ADD  CONSTRAINT [FK_WarehousePostalCodePromotion_WarehouseID_Warehouse_WarehouseID] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WarehousePostalCodePromotion] CHECK CONSTRAINT [FK_WarehousePostalCodePromotion_WarehouseID_Warehouse_WarehouseID]
GO
ALTER TABLE [dbo].[WarehouseRegexPatternDetail]  WITH CHECK ADD  CONSTRAINT [FK_Table_1_WarehouseRegexPattern] FOREIGN KEY([WarehouseRegexPatternID])
REFERENCES [dbo].[WarehouseRegexPattern] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WarehouseRegexPatternDetail] CHECK CONSTRAINT [FK_Table_1_WarehouseRegexPattern]
GO
ALTER TABLE [dbo].[WarehouseSchedule]  WITH CHECK ADD  CONSTRAINT [FK_WarehouseSchedule_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WarehouseSchedule] CHECK CONSTRAINT [FK_WarehouseSchedule_Warehouse]
GO
ALTER TABLE [dbo].[WarehouseScheduleDetail]  WITH CHECK ADD  CONSTRAINT [FK_WarehouseScheduleDetail_WarehouseSchedule] FOREIGN KEY([WarehouseScheduleID])
REFERENCES [dbo].[WarehouseSchedule] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WarehouseScheduleDetail] CHECK CONSTRAINT [FK_WarehouseScheduleDetail_WarehouseSchedule]
GO
ALTER TABLE [dbo].[WarehouseWebService]  WITH CHECK ADD  CONSTRAINT [FK_WarehouseWebService_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WarehouseWebService] CHECK CONSTRAINT [FK_WarehouseWebService_Warehouse]
GO
ALTER TABLE [dbo].[WarrantyUpcSection]  WITH CHECK ADD  CONSTRAINT [FK_WarrantyUpcSection_ParentUpcID_Upc_ID] FOREIGN KEY([ParentUpcID])
REFERENCES [dbo].[Upc] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WarrantyUpcSection] CHECK CONSTRAINT [FK_WarrantyUpcSection_ParentUpcID_Upc_ID]
GO
ALTER TABLE [dbo].[WarrantyUpcSection]  WITH CHECK ADD  CONSTRAINT [FK_WarrantyUpcSection_UpcSectionID_Upc_ID] FOREIGN KEY([UpcSectionID])
REFERENCES [dbo].[Upc] ([ID])
GO
ALTER TABLE [dbo].[WarrantyUpcSection] CHECK CONSTRAINT [FK_WarrantyUpcSection_UpcSectionID_Upc_ID]
GO
ALTER TABLE [dbo].[WayfairOrderLineItem]  WITH CHECK ADD  CONSTRAINT [FK_WayfairOrderLineItem_WayfairOrderID_WayfairOrder_ID] FOREIGN KEY([WayfairOrderID])
REFERENCES [dbo].[WayfairOrder] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WayfairOrderLineItem] CHECK CONSTRAINT [FK_WayfairOrderLineItem_WayfairOrderID_WayfairOrder_ID]
GO
/****** Object:  StoredProcedure [dbo].[AddOOSInventoryHold]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

                    CREATE PROCEDURE [dbo].[AddOOSInventoryHold] 
                    @region int,
                    @sku varchar(25),
                    @lotcode int = null
                    AS
                    BEGIN
					/*
                    -- SET NOCOUNT ON added to prevent extra result sets from
                    -- interfering with SELECT statements.*/
                    SET NOCOUNT ON;
                    declare @comment varchar(100) = 'OOS';
                    declare @effectivedate datetime = getdate();
                    declare @expirydate datetime = dateadd(year, 1, getdate());
                    select distinct g.WarehouseID, f.id UpcID
                    into #upcs
                    from BrandSku a with(nolock)
                    join BrandSkuUpc b on a.ID = b.BrandSkuID
                    join SourceBrandSkuUpcRecon c on b.ID = c.BrandSkuUpcID
                    join ${Environment}WarehouseManager..Source d with(nolock) on c.SourceID = d.ID
                    join SourceWarehouse e with(nolock) on d.ID = e.SourceID and e.active = 1	
                    join upc f with(nolock) on b.UpcID = f.ID
                    join inventory g with(nolock) on f.ID = g.UpcID and e.warehouseid = g.warehouseid
                    where a.InternalSku = @sku
                    and d.RegionID = @region
                    and f.lotcode = isnull(@lotcode, f.LotCode)
                    merge InventoryHoldForWarehouse as A
                    using #upcs as B on A.warehouseid = B.warehouseid and A.upcid = B.upcid
                    when matched then
                    update set A.holdqty = 1000, A.EffectiveDate = @effectivedate, A.ExpiryDate = @expirydate, A.[Comment] = @comment
                    when not matched then
                    insert (upcid, warehouseid, holdqty, effectivedate, expirydate, comment) values (B.upcid, B.warehouseid, 1000, @effectivedate, @expirydate, @comment);
                    drop table #upcs;
                    END
GO
/****** Object:  StoredProcedure [dbo].[AddReconSkuWarehousesToDB]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[AddReconSkuWarehousesToDB]
@SkuWarehouse nvarchar(50)
AS
BEGIN
Insert into [dbo].ReconSkuWarehouse Values (@SkuWarehouse, 0)
END

GO
/****** Object:  StoredProcedure [dbo].[AddReconStoreQtiesToDB]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[AddReconStoreQtiesToDB]
@SkuWarehouse nvarchar(50),
@StoreID int,
@SkuStore nvarchar(50),
@Description nvarchar(1000) = null,
@Qty int = null
AS
BEGIN
Insert into [dbo].ReconStoreQty Values (@StoreID,@SkuWarehouse,@SkuStore, @Description, @Qty);
END

GO
/****** Object:  StoredProcedure [dbo].[AddReconStoreQtyDifferenceRecord]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Procedure [dbo].[AddReconStoreQtyDifferenceRecord](@storeID int, @skuStore varchar(100), @skuWarehouse varchar(100), @qty int)
as
BEGIN
insert into ReconStoreQtyDifference values (@storeID, @skuStore, @skuWarehouse, @qty, null)
END 
GO
/****** Object:  StoredProcedure [dbo].[AddReconWarehouseQuantitesToDB]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[AddReconWarehouseQuantitesToDB]
@WarehouseID int,
@SkuWarehouse nvarchar(50),
@Description nvarchar(1000) = null,
@Qty int = null,
@ErrorCode nvarchar(50) = null,
@StatusCode nvarchar(50) = null
AS
BEGIN
Insert into [dbo].ReconWarehouseQty Values (@WarehouseID,@SkuWarehouse, @Description, @Qty, @ErrorCode,@StatusCode);
END

GO
/****** Object:  StoredProcedure [dbo].[DeleteScheduledJob]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
*/
CREATE PROCEDURE [dbo].[DeleteScheduledJob] 
	/*-- Add the parameters for the stored procedure here*/
	@jobid uniqueidentifier
AS
BEGIN
	/*-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.*/
	SET NOCOUNT ON;

	delete from ${Environment}quartz..whm_scheduledjob where jobid = @jobid
	delete from ${Environment}quartz..qrtz_simple_triggers where trigger_name = @jobid
	delete from ${Environment}quartz..qrtz_triggers where trigger_name = @jobid
	delete from ${Environment}quartz..QRTZ_JOB_DETAILS where job_name = @jobid
END
GO

/****** Object:  StoredProcedure [dbo].[GetCurrentWarrantyInventory]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetCurrentWarrantyInventory]
	as
	select
	BrandSku.Sku,
	BrandSkuUpc.GroupNumber,
	BrandSkuUpc.QtyInGroup as QuantityInGroup,
	SectionUpc.IsRTP as IsRtp,
	SectionUpc.IsMasterPack,
	SectionUpc.LotCode,
	Warehouse.Name as WarehouseName,
	ISNULL(Warehouse.WarehouseID, 0) as WarehouseID,
	ISNULL(Inventory.Qty, 0) as Quantity,
	SectionUpc.Upc,
	WarrantyUpcSection.Section,
	cast(0 as bit) as IsEasyPlug,
	cast(0 as bit) as IsException,
	1 as TotalCartonsForUpc,
	Source.RegionID,
	SectionUpc.ID as SectionUpcId,
	SectionUpc.WarrantyLotCode,
	SectionUpc.Upc as RawUpc,
	SectionUpc.CartonNumber,
	Source.ID as SourceID,
	BrandSku.BrandID as BrandID
	from WarrantyUpcSection
	join Upc SectionUpc on WarrantyUpcSection.UpcSectionID = SectionUpc.ID
	join BrandSkuUpc on WarrantyUpcSection.ParentUpcID = BrandSkuUpc.UpcID
	join BrandSku on BrandSkuUpc.BrandSkuID = BrandSku.ID
	join SourceBrandSkuUpcRecon on BrandSkuUpc.ID = SourceBrandSkuUpcRecon.BrandSkuUpcID
	join ${Environment}WarehouseManager..Source on SourceBrandSkuUpcRecon.SourceID = Source.ID
	left join Inventory on WarrantyUpcSection.UpcSectionID = Inventory.UpcID
	left join Warehouse on Inventory.WarehouseID = Warehouse.WarehouseID and Warehouse.Active = 1
	where len(SectionUpc.Upc) >= 17
GO
/****** Object:  StoredProcedure [dbo].[GetDeliveredLineItemHistoryForTrackingNumber]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure[dbo].[GetDeliveredLineItemHistoryForTrackingNumber]
                @tnUpc varchar(100) = null,
	            @whRefNum varchar(100),
	            @whID int,
                @brandID int
            as
                set nocount on;
            select*
                from
                (
                    select
                            dhistoryupc.CartonNumber
                        , dhistoryupc.TotalCartons
                        , dHistory.WarehouseReferenceNumber as warehouserefnum
                        , dHistory.SourceRefNum
                        , dhistory.Upc as OriginalUPC
                        , dHistory.DateDelivered as DateSentToWarehouse
                        , a.LotCode
                        , a.WarrantyLotCode
                        , isnull(receivedUpc.Upc, @tnUpc) as ReceivedUpc
                        , dHistory.ShippingMethodID as shipmethod
                        , dHistory.WarehouseShippingMethodID
                        , case 
                            /*--non - null setting means warehouse is exempt and doesn't provide upcs*/
                            when setting.SettingID is null and(receivedUPc.ID is null or a.ResultCode is null) then
					            case 
                                    when left(right(@tnUpc, 5), 1) = '9' then - 6
						            else -4
                                end
                            when a.ResultCode != 0 then a.ResultCode
                            when(@tnUpc is null and setting.SettingID is not null) or @tnUpc = dhistory.Upc or @tnUpc = a.receivedupc then 1 
				            else -5/*-- unknown*/
                            end ResultCode
                        , isnull(warehouseCodeLookup.WarehouseCode, '') as WarehouseCode
                        , rank() over(partition by dhistory.warehousereferencenumber, dhistory.sourcerefnum order by dhistory.orderid desc) as rowid
                        , dHistory.Sku
                        , source.Name as storeCode
                        , source.ID as SourceID
                        , brand.ID as BrandID
                        , brand.Code
                        , dHistory.PlatformID
                        , dHistory.OrderType
                        , a.QuantityInCarton
                        , a.IsMasterPack
                        , lirtn.ID as LineItemRequiringTrackingNumberID
                        , lirtn.TotalTNs
                        , lirtn.ReceivedTNs
                    from DeliveredLineItemHistory dHistory
                    join ${Environment}WarehouseManager.dbo.Source source on dHistory.SourceID = source.ID and source.BrandID = @brandID
                    join ${Environment}WarehouseManager.dbo.Brand brand on source.BrandID = brand.ID
                    join BrandSku on brand.ID = BrandSku.BrandID and(dHistory.Sku = BrandSku.InternalSku or dHistory.sku = BrandSku.Sku)
                    join upc dhistoryUpc on dhistoryUpc.upc = dhistory.upc
                    left join lineItemRequiringTrackingNumber lirtn on dHistory.SourceID = lirtn.SourceID and dHistory.WarehouseReferenceNumber = lirtn.WarehouseReferenceNumber and dHistory.WarehouseID = lirtn.WarehouseID and dHistory.Sku = lirtn.StoreSku and lirtn.totaltns != lirtn.receivedtns
                    left join warehouseCodeLookup on warehouseCodeLookup.warehouseid = dhistory.warehouseid
                    left join Upc receivedUpc on receivedUpc.upc = @tnUpc
                    left join Setting on setting.name = 'WarehousesExemptedFromLotCodeValidation' and setting.value like '%' + cast(@whID as varchar) + '%'
                    left join(
                        /*--standard UPCs*/
                        select
                            coalesce(upcmasterpackupc.upc, upc.upc, null) as receivedupc,
				            case 				
                                when upc.IsMasterPack = 1 then
						            case 
                                        when upcMasterPack.ID is null then - 1
                                        when upcmasterpackupc.upc IS NULL then - 2
                                        when UpcInnerPackUpc.upc is null then - 3
                                        ELSE 1
                                    end
					            else 1

                            end as ResultCode,
                            BrandSkuUpc.BrandSkuID,
                            upc.LotCode,
                            upc.WarrantyLotCode,
                            upc.CartonNumber,
                            upc.QuantityInCarton,
                            upc.IsMasterPack
                        from upc upc
                        join BrandSkuUpc on upc.id = BrandSkuUpc.UpcID
                        left
                        join UpcMasterPackAssociations upcMasterPack on upc.id = upcMasterPack.MasterPackUpcID and upcMasterPack.WarehouseID = @whID
                        left join upc UpcMasterPackUpc on upcMasterPack.MasterPackUpcID = UpcMasterPackUpc.ID
                        left join upc UpcInnerPackUpc on upcMasterPack.InnerPackUpcID = UpcInnerPackUpc.ID
                        union
                        
                        select
                            upc.upc as receivedupc,
                            1 as ResultCode,
                            BrandSkuUpc.BrandSkuID as BrandSkuID,
                            upc.LotCode,
                            upc.WarrantyLotCode,
                            upc.CartonNumber,
                            upc.QuantityInCarton,
                            upc.IsMasterPack
                        from upc upc
                        join WarrantyUpcSection WUS on WUS.upcsectionid = upc.id
                        join BrandSkuUpc on wus.ParentUpcID = BrandSkuUpc.UpcID
                    ) a on a.receivedupc = isnull(receivedUpc.Upc, dHistoryUpc.Upc) and a.BrandSkuID = BrandSku.ID and a.CartonNumber = isnull(receivedupc.CartonNumber, dhistoryUpc.CartonNumber)
                    where dhistory.SourceID = source.ID and
                            dHistory.PlatformID = source.PlatformID and
                            dHistory.WarehouseID = @whID and
                        (dHistory.WarehouseReferenceNumber = @whRefNum or dHistory.SourceRefNum = @whRefNum) and
                        dhistory.IsSuccessful = 1 and
                        dhistoryupc.CartonNumber = coalesce(a.CartonNumber, receivedUpc.cartonnumber, dhistoryupc.cartonnumber)
		            ) main
               where main.rowid = 1;
GO
/****** Object:  StoredProcedure [dbo].[GetLoadedInventoryWithSku]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetLoadedInventoryWithSku]
                            AS
                          BEGIN
	                        SET NOCOUNT ON;

                          select distinct a.InternalSku, c.upc, d.Qty, c.TotalCartons, c.LotCode, e.WarehouseID, c.CartonNumber, c.IsMasterPack, c.QuantityInCarton
	                        from brandsku a
	                        join brandskuupc b on a.id = b.brandskuid
	                        join upc c on b.upcid = c.id
	                        left join ReconLoadedInventory d on c.upc = d.upc
	                        left join warehouse e on d.warehouseid = e.warehouseid
	                        where (d.IsReconciled = 0 or d.IsReconciled is null)
	                        and (e.active = 1 or e.active is null)
	                        and a.InternalSku not like '%test%'
                        END
GO
/****** Object:  StoredProcedure [dbo].[GetSkusUnavailableOnStoreFronts]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetSkusUnavailableOnStoreFronts]
                            AS
                           SELECT sku, Upc, TotalQtyAvailableForUpc, Code
                           FROM
                            (
                                SELECT rs.sku, rs.Upc, rs.TotalQtyAvailableForUpc, b.code, s.ID
	                                FROM ${Environment}WarehouseManager..Source s	                                
	                                JOIN ${Environment}WarehouseManager..Brand b on b.id = s.brandid
	                                JOIN ReconSnapshotDetail rs on s.ID = rs.SourceID
	                                LEFT JOIN ReconInventoryForHybrisRegion rihr on rs.Sku = rihr.Sku and s.RegionID = rihr.RegionID
                                WHERE s.PlatformID = 3 and rs.NewQty > 0 AND s.HandlesInventoryAllocation = 1 AND rihr.Sku is null 
                                UNION 
                                SELECT rs.sku, rs.Upc, rs.TotalQtyAvailableForUpc, b.code, s.ID
	                                FROM ${Environment}WarehouseManager..Source s
	                                JOIN ${Environment}WarehouseManager..Brand b on b.id = s.brandid	                                
	                                JOIN ReconSnapshotDetail rs ON s.ID = rs.SourceID
	                                LEFT JOIN ReconInventoryForVolusionStore rivr ON rs.Sku = rivr.Sku and s.ID = rivr.SourceID
                                WHERE s.PlatformID = 1 and rs.NewQty > 0 AND s.HandlesInventoryAllocation = 1 AND rivr.Sku IS NULL
                            ) a
                            WHERE Right(SKU, 2) != '_W'
                            AND Left(SKU, 2) != 'P-'
                            and SKU != 'RTP'
GO
/****** Object:  StoredProcedure [dbo].[GetUpcsWithoutSkus]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetUpcsWithoutSkus]
                    AS
                    BEGIN
                        SET NOCOUNT ON;

                      select u.Upc from ReconLoadedInventory r
                      join upc u on u.Upc = r.Upc
                      left join BrandSkuUpc su on su.UpcID = u.ID
                      where su.UpcID is null
                      and r.Qty > 0
                      and u.Upc not like '%[_]%' and u.upc not like '%label%'
                    END
GO
/****** Object:  StoredProcedure [dbo].[IR_SP_AllocateInventory]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[IR_SP_AllocateInventory]
as
declare @useStoreSkuAllocation bit = (select UseStoreSkuAllocation from WMSystem)
select a.SkuWarehouse, min(StatusCode) as SkuStatus, sum(a.Qty) + sum(isnull(b.Qty, 0)) + sum(isnull(c.SkuLinkQty, 0)) as WarehousesTotal, sum(isnull(b.Qty, 0)) as HoldQty, sum(isnull(c.SkuLinkQty, 0)) as SkuLinkQty
into #WarehouseSkuTotals
from ReconWarehouseQty a
left join SkuWarehouseHolds b on (b.WarehouseID = a.WarehouseID and b.SkuWarehouse = a.SkuWarehouse)
left join (
	select OriginalSkuWarehouse, sum(qty) as SkuLinkQty
	from fn_GetReconSkuWarehouseLinks()
	group by OriginalSkuWarehouse
) c on (c.OriginalSkuWarehouse = a.SkuWarehouse)
group by a.SkuWarehouse
select distinct
	a.StoreID, 
	b.Name as StoreName,
	a.SkuWarehouse,
	isnull(c.WarehousesTotal, 0) as WarehousesTotal,
	a.SkuStore,
	isnull(a.Qty, 0) as AvailableStoreInventory,
	isnull(d.Qty, 0) as StoreAdjustments,
	isnull(a.Qty, 0) + d.Qty as TotalStoreInventory,
	a.[Description] as StoreProductDescription,
	coalesce(e.ReconPerc, f.ReconPerc, g.StockAllocation) as AllocationPercentage, 
	case 
		when coalesce(e.ReconPerc, f.ReconPerc, g.StockAllocation, h.[Enable]) is null
			then cast(c.WarehousesTotal / ((select count(*) from ReconStoreQty where SkuWarehouse = a.SkuWarehouse and StoreID != a.StoreID) + 1) as int)
		when coalesce(e.ReconPerc, f.ReconPerc, g.StockAllocation) is null and h.[Enable] is not null 
			then 0
		else 
			cast(c.WarehousesTotal * (coalesce(e.ReconPerc, f.ReconPerc, g.StockAllocation) / 100) as int)
	end as NewStoreAvailable,
	case 
		when e.skuwarehouse is not null then 'Store'
		when f.skuwarehouse is not null then 'StoreOther'
		when coalesce(g.StockAllocation, h.[Enable]) is not null then 'StoreLevel'
		else 'None' 
	end as ShareType,
	c.SkuStatus,
	cast('' as varchar(200)) as ErrorMessage
into #ReconAllocatedInventory
from ReconStoreQty a
join Store b on (b.StoreID = a.Storeid)
left join #WarehouseSkuTotals c on (c.SkuWarehouse = a.SkuWarehouse)
left join (
	select storeid, skustore, sum(isnull(Qty, 0)) as Qty
	from ReconStoreQtyAdjustments 
	group by storeid, skustore
) d on (d.StoreID = a.StoreID and d.SkuStore = a.SkuStore)
left join (
	select SkuWarehouse, StoreID, min(ReconPerc) as ReconPerc
	from SkuSharedStores
	group by skuwarehouse, storeid
	having count(*) = 1
) e on (e.StoreID = a.StoreID and e.SkuWarehouse = a.SkuWarehouse)
outer apply (
	select SkuWarehouse, StoreID, NULL as ReconPerc
	from SkuSharedStores
	where skuwarehouse = a.skuwarehouse and storeid != a.storeid
	group by skuwarehouse, storeid
) f
left join StoreSkuAllocation g on (g.storeid = a.storeid and g.[enable] = 1 and @useStoreSkuAllocation = 1)
left join (
	select max(cast([Enable] as int)) as [Enable] from StoreSkuAllocation
) h on (@useStoreSkuAllocation = 1 and h.[Enable] = 1)
update a
set 
	AllocationPercentage = b.ReconPerc,
	NewStoreAvailable = cast(a.WarehousesTotal * (b.ReconPerc / 100) as int),
	ShareType = 'SKU'
from #ReconAllocatedInventory a
join SkuSharedSkus b on (b.SkuWarehouse = a.SkuWarehouse and b.StoreID = a.Storeid and b.SkuStore = a.SkuStore)
update a
set
	ErrorMessage = case when b.AllocationPercentage = 0 then 'ERROR: The Sku Warehouses need to have allocation percentages set otherwise WM cannot properly update the associate Sku Store' else '' end,
	NewStoreAvailable = case when b.AllocationPercentage != 0 then b.UnallocatedStockRemainder + a.NewStoreAvailable else a.NewStoreAvailable end
from #ReconAllocatedInventory a
join (
	select skuwarehouse, sum(isnull(AllocationPercentage, 0)) as AllocationPercentage, min(WarehousesTotal) - sum(NewStoreAvailable) as UnallocatedStockRemainder, min(WarehousesTotal) as WarehousesTotal
	from #ReconAllocatedInventory
	group by skuwarehouse
	having sum(NewStoreAvailable) != min(WarehousesTotal)
) b on (b.skuwarehouse = a.skuwarehouse)
join (
	select storeid, skuwarehouse, skustore, row_number() over (partition by skuwarehouse order by isnull(allocationpercentage, 0) desc, storeid asc, availablestoreinventory desc) as RowID
	from #ReconAllocatedInventory
) c on (c.storeid = a.storeid and c.skuwarehouse = a.skuwarehouse and c.skustore = a.skustore and c.rowid = 1)
select *
from #ReconAllocatedInventory a
join (
	select x.storeid, skuwarehouse, sum(newstoreavailable) as PseudoStoreSkuWarehouseTotal
	from #ReconAllocatedInventory x
	join store y on (x.storeid = y.StoreID and y.StoreType = (select id from storetype where [type] = 'Pseudo'))
	group by x.storeid, skuwarehouse
	having sum(newstoreavailable) <= min(isnull(y.ReallocationLevelThreshold, 0))
) b on (b.storeid = a.storeid and b.skuwarehouse = a.skuwarehouse)
join (
	select x.storeid, skuwarehouse, skustore, sum(newstoreavailable) as SkuStoreTotal, sum(isnull(allocationpercentage, 0)) as SkuStoreAllocation
	from #ReconAllocatedInventory x
	join store y on (x.storeid = y.StoreID and y.StoreType in (select id from storetype where [type] != 'Pseudo'))
	group by x.storeid, skuwarehouse, skustore
) d on (d.StoreID = a.storeid and d.skuwarehouse = a.SkuWarehouse and d.SkuStore = a.SkuStore)
insert into ReconReconciledInventory
select * from #ReconAllocatedInventory
drop table #WarehouseSkuTotals
drop table #ReconAllocatedInventory

GO
/****** Object:  StoredProcedure [dbo].[IR_SP_HandleNewAndOOSSkus]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[IR_SP_HandleNewAndOOSSkus]
AS
declare @lastArchiveDate datetime = (select Max(DateArchived) from InventoryHistory)
select skuwarehouse, min(stocktype) as stocktype
into #SkuTypes
from
(
	select skuwarehouse, 'New' as stockType
	from reconinventory
	union
	select skuwarehouse, 'OOS' as stockType
	from inventoryhistory
	where datearchived = @lastArchiveDate
) skus
group by skuwarehouse
having count(*) = 1
insert into ReconSkuWarehouse (skuwarehouse, active)
	select a.skuwarehouse, 0
	from #SkuTypes a
	left join reconskuwarehouse b on (a.skuwarehouse = b.skuwarehouse) 
	where b.skuwarehouse is null
insert into reconwarehouseqty (warehouseid, skuwarehouse, [description], qty, errorcode, statuscode)
	select a.warehouseid, b.skuwarehouse, ISNULL(d.[description], ''), 0, '0', c.stocktype
	from warehouse a
	join reconwarehouseqty b on (b.warehouseid = a.warehouseid)
	join #SkuTypes c on (c.skuwarehouse = b.skuwarehouse and c.stocktype = 'OOS')
	left join inventoryhistory d on (d.skuwarehouse = b.skuwarehouse and d.warehouseid = a.warehouseid and d.datearchived = @lastArchiveDate) 
	where a.active = 1
update a
	set a.statuscode = c.stocktype
from reconwarehouseqty a
join warehouse b on (a.warehouseid = b.warehouseid and b.active = 1)
join #SkuTypes c on (c.skuwarehouse = a.skuwarehouse and c.stocktype = 'New')
drop table #SkuTypes

GO
/****** Object:  StoredProcedure [dbo].[IR_SP_PopulateReconTables]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[IR_SP_PopulateReconTables]
(
	@SkusByStore ReconSkusByStore READONLY
)
AS
begin
	truncate table ReconSkuWarehouse;
	truncate table ReconWarehouseQty;
	truncate table ReconStoreQty;
	truncate table ReconStoreQtyBundle
	
	insert into ReconSkuWarehouse (SkuWarehouse, Active)
	select distinct ltrim(rtrim(i.SkuWarehouse)), 0
	from reconInventory i
	join skuwarehouse s on (LTRIM(RTRIM(i.SkuWarehouse)) = s.SkuWarehouse)
	
	insert into ReconWarehouseQty (WarehouseID, SkuWarehouse, [Description], Qty, ErrorCode, StatusCode)
	select 
	 i.WarehouseID, 
	 LTRIM(RTRIM(i.skuwarehouse)), 
	 i.[description], 
	 case when w.WarehouseID IS NULL then 0 else i.qty end,
	 '0',
	 'OK'
	from reconinventory i 
	join skuwarehouse s on (LTRIM(RTRIM(i.SkuWarehouse)) = s.SkuWarehouse)
	left join warehouse w on (w.warehouseid = i.WarehouseID and w.Active = 1)
	where s.dropship = 0;
	insert into ReconWarehouseQty (WarehouseID, SkuWarehouse, Qty)
	select a.warehouseid, a.skuwarehouse, a.qty
	from IR_FN_GetReconSkuWarehouseLinks() a
	left join ReconWarehouseQty b on (a.warehouseid = b.warehouseid and a.skuwarehouse = b.skuwarehouse)
	where b.SkuWarehouse is null
	insert into ReconStoreQty
	select a.StoreID, a.SkuStore, ISNULL(b.SkuWarehouse, a.SkuStore), min(a.[Description]), SUM(a.Quantity)
	from @SkusByStore a
	left join SkuConversion b on (a.skustore = b.skustore and a.storeid = b.storeid)
	group by a.storeid, a.skustore, ISNULL(b.SkuWarehouse, a.SkuStore)
	insert into ReconStoreQtyBundle
	select b.storeid, skubundle, min([description]), min(qty)
	from ReconStoreQty a
	join SkuBundle b on (a.StoreID = b.StoreID and a.SkuWarehouse = b.SkuBundle)
	group by b.storeid, b.SkuBundle
end

GO
/****** Object:  StoredProcedure [dbo].[IR_SP_PopulateWMAdjustments]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[IR_SP_PopulateWMAdjustments]
AS
declare @dateToProcessFrom datetime
declare @useWarehouseCutoffTime bit
select @dateToProcessFrom =
	case datename(dw, getdate())
		when 'Monday' then getdate() - 3
		when 'Sunday' then getdate() - 2
		else getdate() - 1
	end
select @useWarehouseCutoffTime = CASE Value WHEN 'True' THEN 1 ELSE 0 END
from Setting
where Name = 'UseWarehouseCutoffTimes'
insert into ReconWMAdjustments
select a.warehouseid, b.skuwarehouse, sum(a.qty), min(CASE 
		WHEN @useWarehouseCutoffTime = 1 AND w.CutOffTime IS NOT NULL 
			THEN LEFT(CONVERT(varchar, GETDATE(), 120), 10) + ' ' + w.CutOffTime
		ELSE @dateToProcessFrom
	END) OrderedSince
from Warehouse w
join WarehouseManagerWebTreesHistory..CustOrderDetailSkuWarehouse a on (w.WarehouseID = a.WarehouseID)
join WarehouseManagerWebTreesHistory..CustOrderDetailSku b on (a.CustOrderDetailSkuID = b.ID and b.HasBeenUnassigned is null)
join WarehouseManagerWebTreesHistory..CustOrderDetail c on (b.CustOrderDetailID = c.ID)
join WarehouseManagerWebTreesHistory..CustOrder d on (c.CustOrderID = d.ID)
where d.DateLoaded >
	CASE 
		WHEN @useWarehouseCutoffTime = 1 AND w.CutOffTime IS NOT NULL 
			THEN LEFT(CONVERT(varchar, GETDATE(), 120), 10) + ' ' + w.CutOffTime
		ELSE @dateToProcessFrom
	END
group by a.warehouseid, b.skuwarehouse

GO
/****** Object:  StoredProcedure [dbo].[IR_SP_ReconcileInventory]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================*/
CREATE PROCEDURE [dbo].[IR_SP_ReconcileInventory] 
(
	@ReconSkusByStore ReconSkusByStore READONLY
	
)
AS
BEGIN
	EXEC IR_SP_PopulateReconTables @ReconSkusByStore
	EXEC IR_SP_HandleNewAndOOSSkus
	EXEC IR_SP_PopulateWMAdjustments
	EXEC IR_SP_AllocateInventory
	SELECT * FROM IR_FN_GetReconciledInventory()
END

GO
/****** Object:  StoredProcedure [dbo].[RebuildIndexes]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[RebuildIndexes]
AS
BEGIN
	SET NOCOUNT ON; 
    	DECLARE table_cursor CURSOR FOR 
	SELECT 
	    t.NAME 'TableName',
	    i.NAME 'IndexName',
        page_count 'Pages',
        AVG_FRAGMENTATION_IN_PERCENT 'Fragmentation'
	FROM 
	    sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'DETAILED') ips
	INNER JOIN  
	    sys.tables t ON ips.OBJECT_ID = t.Object_ID
	INNER JOIN  
	    sys.indexes i ON ips.index_id = i.index_id AND ips.OBJECT_ID = i.object_id
	WHERE
	    AVG_FRAGMENTATION_IN_PERCENT >= 10
    AND 
	    page_count > 500
	AND
	    i.NAME IS NOT NULL

    DECLARE @tableName VARCHAR(200);
    DECLARE @indexName NVARCHAR(500);
	DECLARE @pages int;
	DECLARE @fragmentation decimal;
    DECLARE @query NVARCHAR(500);

    OPEN table_cursor;
    FETCH NEXT FROM table_cursor INTO @tableName, @indexName, @pages, @fragmentation;

    WHILE @@FETCH_STATUS = 0
    BEGIN
	  declare @maintenanceType varchar(20);
	  set @maintenanceType = 
		  CASE 
			WHEN @fragmentation BETWEEN 10 and 30 THEN
			  'REORGANIZE'
			ELSE
			  'REBUILD'
		  END;
      
	  SET @query = N'ALTER INDEX [' + @indexName + '] ON [' + @tableName + '] ' + @maintenanceType + ';';
	  PRINT @query
      EXEC sp_executesql @query
	  
	  FETCH NEXT FROM table_cursor INTO @tableName, @indexName, @pages, @fragmentation;
    END

    CLOSE table_cursor;
    DEALLOCATE table_cursor;
END
GO
/****** Object:  StoredProcedure [dbo].[spcSkuWarehouseLink]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spcSkuWarehouseLink] 
	@SkuStore VARCHAR(100), 
	@SkuWarehouse VARCHAR(100)
AS
	DECLARE @ParentID INT
	IF EXISTS (SELECT * FROM SkuWarehouse WHERE SkuWarehouse = @SkuWarehouse) 
	AND EXISTS (SELECT * FROM SkuWarehouse WHERE SkuWarehouse = @SkuStore)
		BEGIN
			IF EXISTS (SELECT * FROM SkuWarehouseLink WHERE SkuWarehouse = @SkuWarehouse OR SkuWarehouse = @SkuStore)
				BEGIN
					SELECT 'ALREADY EXISTS!'
				END		
			ELSE
				BEGIN
					INSERT INTO SkuWarehouseLink (SkuWarehouse)
						VALUES (@SkuStore)
					SET @ParentID = (SELECT SCOPE_IDENTITY());					
					INSERT INTO SkuWarehouseLink(SkuWarehouse, Parent)
						VALUES (@SkuWarehouse, @ParentID)
				END			
		END
	ELSE
		BEGIN
			SELECT 'SKUs DO NOT EXIST!'
		END
GO
/****** Object:  StoredProcedure [dbo].[UpcsBeingReportedByWarehouseWithNoSetSkuAssociations]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpcsBeingReportedByWarehouseWithNoSetSkuAssociations]
                        AS
                        BEGIN
                           select a.Upc, a.Qty, a.Name as 'Warehouse', a.RegionName as 'Region'
                            from(
                                select distinct rl.Upc, rl.Qty, w.Name, up.ID as UpcID, r.ID as 'RegionID', r.RegionName, w.WarehouseID
                                from ReconLoadedInventory rl
                                join Upc up on rl.Upc = up.Upc
                                join SourceWarehouse sw on rl.WarehouseID = sw.WarehouseID
                                join Warehouse w on rl.WarehouseID = w.WarehouseID
                                join ${Environment}WarehouseManager..Source s on sw.SourceID = s.id
                                join ${Environment}WarehouseManager..Region r on s.RegionID = r.ID
                                where rl.Qty > 0
                            ) a
                            left join(
                                select distinct rl.Upc, rl.Qty, w.Name, up.ID as UpcID, r2.ID as 'RegionID', r2.RegionName, w.WarehouseID
                                from ReconLoadedInventory rl
                                join Upc up on rl.Upc = up.Upc
                                join Warehouse w on rl.WarehouseID = w.WarehouseID
                                join BrandSkuUpc bsu on up.ID = bsu.UpcID
                                join BrandSku bs on bsu.BrandSkuID = bs.ID
                                join ${Environment}WarehouseManager..Source s2 on bs.BrandID = s2.BrandID
                                join ${Environment}WarehouseManager..Region r2 on s2.RegionID = r2.ID
                                where rl.Qty > 0
                            ) b on a.UpcID = b.UpcID AND a.WarehouseID = b.WarehouseID AND a.RegionID = b.RegionID
                            WHERE 1 = 1
                            AND a.upc not like '%label%'
                            AND CHARINDEX('_', a.upc) = 0
                            AND b.UpcID is null
                        END
GO
/****** Object:  StoredProcedure [dbo].[UpdateBackOrders]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[UpdateBackOrders]
as
BEGIN
select co.id CustOrderId, cod.id CustOrderDetailId, (case when conv.skustore is null then cod.SkuStore else conv.SkuWarehouse end) skuwarehouse
into #convertedSkus
from custorder co
join custorderdetail cod on (co.id = cod.custorderid)
left join skuconversion conv on (conv.skustore = cod.skustore)
update co set co.ProcessStatus = 'BackOrdered', co.Active = 0
from #convertedSkus skus
join custorder co on skus.CustOrderID = co.id
left join [_DenormalizedSkuWarehouseLink] links on (skus.skuwarehouse = links.ParentWarehouseSKU)
left join BackOrderWarehouseSku bo on (bo.WarehouseSku = (case when links.ChildWarehouseSKU is null then skus.skuwarehouse else links.ChildWarehouseSKU end))
where bo.WarehouseSku is not null
drop table #convertedSkus
END
GO
/****** Object:  StoredProcedure [dbo].[UpsertWarrantyInventory]    Script Date: 11/30/2020 11:26:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpsertWarrantyInventory] 
AS
SET XACT_ABORT ON
SET NOCOUNT ON
BEGIN
	BEGIN TRY
		BEGIN TRAN WarrantyInventoryUpdateTrees

		
		insert into upc (upc, vendorpartnumber, description, cartonnumber, quantityincarton, TotalCartons, ismasterpack, isdropship, isbackordered, lotcode, WarrantyLotCode, IsRTP, IsFedExFreight)
		select distinct a.upc, a.upc, '', 1, 1, 1, 0, 0, 0, right(left(a.upc, 17), 2), right(left(a.upc, 17), 2), case when left(a.upc, 4) = '2323' then 1 else 0 end, 0
		from reconloadedinventory a
		join Warehouse wh on a.WarehouseID = wh.WarehouseID
		left join upc b on a.upc = b.upc
		where wh.Active = 1
		and wh.IsWarranty = 1
		and a.upc like '%[_]%'
		and a.qty > 0
		and isnumeric(replace(right(a.upc, 2), '_', '')) = 1
		and len(a.upc) >= 17
		and left(a.upc, 17) not like '%[_]%'
		and b.id is null

		
		insert into upc (upc, vendorpartnumber, description, cartonnumber, quantityincarton, TotalCartons, ismasterpack, isdropship, isbackordered, lotcode, WarrantyLotCode, IsRTP, IsFedExFreight)
		select distinct left(a.upc, 17), left(a.upc, 17), '', left(right(left(a.upc, 17), 4), 2), 1, left(right(left(a.upc, 17), 5), 1), 0, 0, 0, right(left(a.upc, 17), 2), right(left(a.upc, 17), 2), case when left(a.upc, 4) = '2323' then 1 else 0 end, 0
		from reconloadedinventory a
		join Warehouse wh on a.WarehouseID = wh.WarehouseID
		join upc b on a.upc = b.upc
		left join upc c on left(a.upc, 17) = c.upc				
		where wh.Active = 1
		and wh.IsWarranty = 1
		and a.upc like '%[_]%'
		and a.qty > 0
		and isnumeric(replace(right(a.upc, 2), '_', '')) = 1
		and len(a.upc) >= 17
		and left(a.upc, 17) not like '%[_]%'
		and c.id is null

		
		insert into WarrantyUpcSection (parentupcid, upcsectionid, section)
		select c.id, b.id, replace(right(a.upc, 2), '_', '')
		from reconloadedinventory a
		join Warehouse wh on a.WarehouseID = wh.WarehouseID
		join upc b on a.upc = b.upc
		join upc c on left(a.upc, 17) = c.upc
		left join warrantyupcsection d on c.id = d.parentupcid and b.id = d.upcsectionid			
		where wh.Active = 1
		and wh.IsWarranty = 1
		and a.upc like '%[_]%'
		and a.qty > 0
		and isnumeric(replace(right(a.upc, 2), '_', '')) = 1
		and len(a.upc) >= 17
		and left(a.upc, 17) not like '%[_]%'
		and d.id is null		

		
		insert into inventory (warehouseid, upcid, qty, ActualHoldQty)
		select distinct a.warehouseid, b.id, a.qty - isnull(d.HoldQty, 0), 0 as ActualHoldQty
		from reconloadedinventory a
		join Warehouse wh on a.WarehouseID = wh.WarehouseID
		join upc b on a.upc = b.upc
		left join inventory c on a.warehouseid = c.warehouseid and b.id = c.upcid
		left join InventoryHoldForWarehouse d on a.WarehouseID = d.WarehouseID and b.ID = d.UpcID and getdate() between d.EffectiveDate and d.ExpiryDate		
		where wh.Active = 1
		and wh.IsWarranty = 1
		and a.upc like '%[_]%'
		and a.qty > 0
		and isnumeric(replace(right(a.upc, 2), '_', '')) = 1
		and len(a.upc) >= 17
		and left(a.upc, 17) not like '%[_]%'
		and c.UpcID is null

		
		update c
		set c.qty = (a.qty - isnull(d.HoldQty, 0))
		from reconloadedinventory a
		join Warehouse wh on a.WarehouseID = wh.WarehouseID
		join upc b on a.upc = b.upc
		join inventory c on a.warehouseid = c.warehouseid and b.id = c.upcid
		left join InventoryHoldForWarehouse d on a.WarehouseID = d.WarehouseID and b.ID = d.UpcID and getdate() between d.EffectiveDate and d.ExpiryDate
		where wh.Active = 1
		and wh.IsWarranty = 1
		and a.upc like '%[_]%'
		and a.qty - c.qty != 0
				
		COMMIT TRAN WarrantyInventoryUpdateTrees 
		PRINT 'Committed Tran WarrantyInventoryUpdateTrees'
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  
  
		SELECT   
			@ErrorMessage = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState = ERROR_STATE(); 

		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN WarrantyInventoryUpdateTrees 
			PRINT 'Rolledback Tran WarrantyInventoryUpdateTrees'
		END

		/*-- Use RAISERROR inside the CATCH block to return error  
		-- information about the original error that caused  
		-- execution to jump to the CATCH block.*/  
		RAISERROR (@ErrorMessage,   
					@ErrorSeverity,   
					@ErrorState 
					);  
	END CATCH		
END
GO
 
 
 

/**
* Insert or Update UPC
* - UPC must be 17 characters
* - Only requried field is UPC value
*
*/
CREATE PROCEDURE dbo.UpsertUpc
	@upc varchar(30),
	@isTree int = -1,
	@isRtp int = -1,
	@isLtl int = -1,
	@isDropShip int = -1,
	@isFedexFreight int = -1,
	@weight int = -1,
	@height int = -1,
	@length int = -1,
	@width int = -1,
	@description varchar (100) = '',
	@commodityClass int = -1,
	@vendorPartNumber varchar(100) = '',
	@lotCode int = -1,
	@totalCartons varchar(1) = '',
	@carton int = -1,
	@qtyInCarton int = -1,
	@isMasterPack int = -1
AS
BEGIN
	declare @returnID int;
	declare @upcLength int;

	declare @defaultDimValue int = 10;
	declare @defaultCommodityClass int = 175;

	declare @cartonModified bit = 1;
	declare @totalCartonsModified bit = 1;
	declare @qtyInCartonModified bit = 1;
	declare @lotCodeModified bit = 1;

	set @upc = REPLACE(@upc, '_W', '');
	set @upcLength = LEN(@upc);

	IF (@upcLength < 17)
	BEGIN
		return -1
	END

	IF (@lotCode = -1)
	BEGIN
		set  @lotCode = SUBSTRING(@upc, @upcLength - 1, 2);
		set @lotCodeModified = 0;
	END

	IF (@totalCartons = '')
	BEGIN
		set @totalCartons = SUBSTRING(@upc, @upcLength - 4, 1);
		set @totalCartonsModified = 0;
	END

	IF (@carton = -1)
	BEGIN
		set @carton = SUBSTRING(@upc, @upcLength - 2, 1);
		set @cartonModified = 0;
	END

	IF (@isMasterPack = -1)
	BEGIN
		set @isMasterPack = 0;
	END

	IF (@qtyInCarton = -1)
	BEGIN
		set @qtyInCarton = 1;
		set @qtyInCartonModified = 0;
	END

	IF (@totalCartonsModified = 0)
	BEGIN
		IF (@totalCartons = '9')
		BEGIN
			set @isMasterPack = 1;
			set @totalCartons = 1;
			set @carton = 1;
			set @qtyInCarton = SUBSTRING(@upc, @upcLength - 3, 2);
		END
		ELSE IF(@totalCartons = '1')
		BEGIN
			set @isMasterPack = 0;
			set @totalCartons = 1;
			set @carton = 1;
		END
		ELSE IF (@totalCartons = 'P' OR @totalCartons = 'C')
		BEGIN
			set @isMasterPack = 0;
			set @qtyInCarton = 1;
			set @carton = SUBSTRING(@upc, @upcLength - 2, 1);
			set @totalCartons = SUBSTRING(@upc, @upcLength - 3, 1);
		END
		ELSE
		BEGIN
			set @isMasterPack = 0;
			set @qtyInCarton = 1;
			set @carton = SUBSTRING(@upc, @upcLength - 3, 2);
		END
	END
	

	IF (@carton > CAST(@totalCartons as int))
	BEGIN
		return -2
	END

	UPDATE Upc SET 
	@returnID = ID,
	LotCode = case @lotCodeModified WHEN 1 THEN @lotCode ELSE [LotCode] END, 
	WarrantyLotCode = case @lotCodeModified WHEN 1 THEN @lotCode ELSE [LotCode] END,
	CartonNumber = case @cartonModified WHEN 1 THEN @carton ELSE [CartonNumber] END,
	TotalCartons = case @totalCartonsModified WHEN 1 THEN CAST(@totalCartons as int) ELSE [TotalCartons] END, 
	QuantityInCarton = case @qtyInCartonModified WHEN 1 THEN @qtyInCarton ELSE [QuantityInCarton] END,
	CommodityClass = case @commodityClass WHEN -1 THEN  [CommodityClass] ELSE @commodityClass END,
	IsMasterPack = @isMasterPack, 
	[Weight] = case @weight WHEN -1 THEN [Weight] ELSE @weight END, 
	Height = case @height WHEN -1 THEN [Height] ELSE @height END, 
	Width = case @width WHEN -1 THEN [Width] ELSE @width END,
	[Length] = case @length WHEN -1 THEN [Length] ELSE @length END,
	IsTree = case @isTree WHEN -1 THEN [IsTree] ELSE @isTree END,
	IsLTL = case @isLtl WHEN -1 THEN [IsLTL] ELSE  @isLtl END,
	IsFedExFreight = case @isFedexFreight WHEN -1 THEN [IsFedExFreight] ELSE @isFedexFreight END,
	IsRTP = case @isRtp WHEN -1 THEN [IsRTP] ELSE @isRtp END,
	IsDropShip = case @isDropShip WHEN -1 THEN [IsRTP] ELSE @isDropShip END,
	VendorPartNumber = case @vendorPartNumber WHEN '' THEN [VendorPartNumber] ELSE @vendorPartNumber END,
	Description = case @description WHEN '' THEN [Description] ELSE @description END
	WHERE Upc = @upc


	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO Upc (Upc, QuantityInCarton, LotCode, WarrantyLotCode, CartonNumber, TotalCartons, CommodityClass, 
		Height, Width, Length, Weight, IsMasterPack, IsTree, IsRTP, IsFedExFreight, IsLTL,IsDropShip, VendorPartNumber, Description)
		VALUES
		(@upc,
		@qtyInCarton,
		@lotCode,
		@lotCode,
		@carton,
		CAST(@totalCartons as int),
		case @commodityClass WHEN -1 THEN  @defaultCommodityClass ELSE @commodityClass END,
		case @height WHEN -1 THEN @defaultDimValue ELSE @height END,
		case @width WHEN -1 THEN @defaultDimValue ELSE @width END,
		case @length WHEN -1 THEN @defaultDimValue ELSE @length END,
		case @weight WHEN -1 THEN @defaultDimValue ELSE @weight END,
		@isMasterPack,
		case @isTree WHEN -1 THEN 1 ELSE @isTree END,
		case @isRtp WHEN -1 THEN 0 ELSE @isRtp END,
		case @isFedexFreight WHEN -1 THEN 0 ELSE @isFedexFreight END,
		case @isLtl WHEN -1 THEN 0 ELSE @isLtl END,
		case @isDropShip WHEN -1 THEN 0 ELSE @isDropShip END,
		@vendorPartNumber,
		@description)

		SET @returnID = SCOPE_IDENTITY();
	END

	return @returnID;
END
GO

CREATE PROCEDURE [dbo].[UpsertBrandSkuUpc] 
	                @sku varchar(15),
	                @upc varchar(30),
	                @brand varchar(10),
	                @platformID int = 3,
	                @reconPercentage int = 100,
					@allocationThreshold int = null
                AS
                BEGIN
	                declare @skuID int;
	                declare @brandID int;
	                declare @upcID int;
	                declare @brandSkuUpcID int;
	                declare @sourceID int;

	                SET @brandID = (SELECT TOP 1 ID from ${Environment}WarehouseManager..Brand where [Code] = TRIM(@brand));
	                SET @skuID = (SELECT TOP 1 ID FROM BrandSku where Sku = @sku AND BrandID = @brandID);
	                exec @upcID = UpsertUpc @upc

	                IF (@upcID = -1)
	                BEGIN
		                return -1;
	                END

					if (@reconPercentage is null)
					BEGIN
						set @reconPercentage = 100;
					END
		                
	                set @sourceID = (SELECT TOP 1 ID FROM ${Environment}WarehouseManager..Source WHERE BrandID = @brandID AND PlatformID = @platformID);
	                IF NOT EXISTS (SELECT ID FROM BrandSku where Sku = @sku AND BrandID = @brandID)
	                BEGIN
		                INSERT INTO BRandSku (BrandID, SKu, InternalSku, Active) VALuES ( @brandID, @sku, @sku, 1);
		                SET @skuID = SCOPE_IDENTITY();
	                END

					SET @brandSkuUpcID = (SELECT ID  FROM BrandSKuUpc where UpcID = @upcID AND BrandSkuID = @skuID);

	                IF (@brandSkuUpcID is null)
	                BEGIN
		                INSERT INTO BrandSkuUpc (BrandSkuID, UpcID, GroupNumber, QtyInGroup) VALUES (@skuID, @upcID, 1, 1)
		                SET @brandSkuUpcID = SCOPE_IDENTITY();
	                END

					UPDATE SourceBrandSkuUpcRecon SET ReconPercentage = @reconPercentage, AllocationThreshold = @allocationThreshold WHERE SourceID = @sourceID AND BrandSkuUpcID = @brandSkuUpcID

	                IF @@ROWCOUNT = 0
	                BEGIN
		                INSERT INTO SourceBrandSkuUpcRecon(SourceID, BrandSkuUpcID, ReconPercentage, AllocationThreshold) VALUES (@sourceID, @brandSkuUpcID, @reconPercentage, @allocationThreshold)
	                END
                END

GO
CREATE PROCEDURE [dbo].[GenerateSkusInION] AS 
BEGIN
	DECLARE @sku varchar(20), @id int, @brand varchar(20), @reconPercentage int, @totalCartons int, @inventory int;
	DECLARE @generatedUpc varchar(30);
	DECLARE @cartonIteration int;
	DECLARE @totalCartonCount int =1;
	DECLARE @cartonUpcValue varchar(10);
	DECLARE @trimmedBrand varchar(20);
	DECLARE @upcID int;
	DECLARE @warehouseID int;
	declare @defaultInventory int = 1000;

	DECLARE GenerateSkuCursor CURSOR 
	FOR
	SELECT ID, Sku, Brand, ReconPercentage, TotalCartons, Inventory
	FROM temp_SkusToLoad
	WHERE Processed is null

	OPEN GenerateSkuCursor

	FETCH NEXT FROM GenerateSkuCursor  
	INTO @id, @sku, @brand, @reconPercentage, @totalCartons, @inventory

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @cartonIteration = 1;

		IF (@totalCartons is null)
		BEGIN
			set @totalCartonCount = 1;
		END
		ELSE
		BEGIN
			set @totalCartonCount = @totalCartons;
		END

		WHILE (@cartonIteration <= @totalCartonCount)
		BEGIN
			
			IF (@cartonIteration < 10)
			BEGIN
				set @cartonUpcValue = CONCAT('0', CAST(@cartonIteration AS varchar));
			END

			if (@inventory is null)
			BEGIN
				set @inventory  = @defaultInventory;
			END

			set @generatedUpc = CONCAT('1111',
			TRIM(@sku),
			'0',
			@totalCartonCount, 
			@cartonUpcValue, 
			RIGHT(Year(getDate()) +1,2));
			set @trimmedBrand = TRIM(@brand);

			exec @upcID = UpsertUpc @generatedUpc
			exec UpsertBrandSkuUpc @sku, @generatedUpc, @trimmedBrand, 3, @reconPercentage


			INSERT INTO Inventory(UpcID, WarehouseID, Qty,ActualWarehouseQty, ActualHoldQty)
			SELECT @upcID, WarehouseID, @inventory, @inventory, 0 FROM Warehouse

			set @cartonIteration = @cartonIteration + 1;
		END

		UPDATE temp_SkusToLoad set Processed = CURRENT_TIMESTAMP where ID = @id;

		FETCH NEXT FROM GenerateSkuCursor 
		INTO @id, @sku, @brand, @reconPercentage, @totalCartons, @inventory
	END

	CLOSE GenerateSkuCursor
	DEALLOCATE GenerateSkuCursor
END
GO