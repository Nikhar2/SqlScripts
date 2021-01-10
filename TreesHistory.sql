/****** Object:  UserDefinedFunction [dbo].[fn_LsnSegmentToHexa]    Script Date: 11/30/2020 11:28:16 AM ******/
USE [${Environment}TreesHistory]
GO

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
/****** Object:  UserDefinedFunction [dbo].[fn_NumericLsnToHexa]    Script Date: 11/30/2020 11:28:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_NumericLsnToHexa](@numeric25Lsn numeric(25,0)) returns varchar(32)
 AS
 BEGIN
-- In order to avoid form sign overflow problems - declare the LSN segments 
-- to be one 'type' larger than the intendent target type.
-- For example, convert(smallint, convert(numeric(25,0),65535)) will fail 
-- but convert(binary(2), convert(int,convert(numeric(25,0),65535))) will give the 
-- expected result of 0xffff.

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
/****** Object:  Table [dbo].[AmwareOrdersWithTNs]    Script Date: 11/30/2020 11:28:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AmwareOrdersWithTNs](
	[OrderNum] [varchar](50) NULL,
	[TRACKINGNUM] [varchar](50) NULL,
	[SHIPDATE] [varchar](50) NULL,
	[ShippingMethod] [varchar](50) NULL,
	[UPC] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[awsdms_truncation_safeguard]    Script Date: 11/30/2020 11:28:16 AM ******/
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
/****** Object:  Table [dbo].[CommercialInvoice]    Script Date: 11/30/2020 11:28:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CommercialInvoice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OrderRefNum] [varchar](100) NULL,
	[WarehouseID] [int] NOT NULL,
	[FileName] [varchar](max) NULL,
	[DateSent] [datetime] NULL,
	[SentViaEmail] [bit] NOT NULL,
	[SentViaFTP] [bit] NOT NULL,
 CONSTRAINT [PK_CommercialInvoices_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CoordinateLookupByPostalCode]    Script Date: 11/30/2020 11:28:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoordinateLookupByPostalCode](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Country] [nvarchar](510) NULL,
	[PostalCode] [nvarchar](62) NULL,
	[Latitude] [float] NOT NULL,
	[Longitude] [float] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustOrder]    Script Date: 11/30/2020 11:28:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustOrder](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustOrderStoreFileID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[ShippingMethodID] [int] NULL,
	[OrderComments] [varchar](max) NULL,
	[EmailAddress] [varchar](100) NULL,
	[ShipPhoneNumber] [varchar](100) NULL,
	[ShipFirstName] [varchar](100) NULL,
	[ShipLastName] [varchar](100) NULL,
	[ShipCompanyName] [varchar](100) NULL,
	[ShipAddress1] [varchar](200) NULL,
	[ShipAddress2] [varchar](200) NULL,
	[ShipCity] [varchar](100) NULL,
	[ShipState] [varchar](100) NULL,
	[ShipPostalCode] [varchar](100) NULL,
	[ShipCountry] [varchar](100) NULL,
	[ShipResidential] [varchar](100) NULL,
	[OrderNotes] [varchar](max) NULL,
	[DeferredShipDate] [datetime] NULL,
	[DateLoaded] [datetime] NULL,
	[OrderDate] [datetime] NOT NULL,
	[OrderStatus] [varchar](100) NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](100) NULL,
	[OrderType] [varchar](100) NULL,
	[OrderReferenceNumberIndex] [int] NULL,
 CONSTRAINT [PK_CustOrder] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustOrderDetail]    Script Date: 11/30/2020 11:28:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustOrderDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustOrderID] [int] NOT NULL,
	[OrderDetailID] [int] NOT NULL,
	[SkuStore] [varchar](max) NULL,
	[Qty] [int] NULL,
	[Price] [money] NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](100) NULL,
 CONSTRAINT [PK_CustOrderDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustOrderDetailSku]    Script Date: 11/30/2020 11:28:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustOrderDetailSku](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustOrderDetailID] [int] NOT NULL,
	[SkuWarehouse] [varchar](100) NOT NULL,
	[HasBeenUnassigned] [bit] NULL,
 CONSTRAINT [PK_CustOrderDetailSku] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustOrderDetailSkuWarehouse]    Script Date: 11/30/2020 11:28:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustOrderDetailSkuWarehouse](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustOrderDetailSkuID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Qty] [int] NOT NULL,
	[DateAssigned] [datetime] NOT NULL,
 CONSTRAINT [PK_CustOrderDetailWarehouse_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustOrderDetailSkuWarehouseAssociation]    Script Date: 11/30/2020 11:28:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustOrderDetailSkuWarehouseAssociation](
	[CustOrderDetailSkuID] [int] NOT NULL,
	[CustOrderWarehouseFileID] [int] NOT NULL,
 CONSTRAINT [PK_CustOrderDetailWarehouseFile] PRIMARY KEY CLUSTERED 
(
	[CustOrderDetailSkuID] ASC,
	[CustOrderWarehouseFileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustOrderDuplicates]    Script Date: 11/30/2020 11:28:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustOrderDuplicates](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NOT NULL,
	[CustOrderStoreFileID] [int] NOT NULL,
 CONSTRAINT [PK_CustOrderDuplicates] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustOrderError]    Script Date: 11/30/2020 11:28:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustOrderError](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StoreID] [int] NULL,
	[OrderID] [int] NULL,
	[Error] [varchar](max) NULL,
 CONSTRAINT [PK_CustOrderError] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustOrderExclusion]    Script Date: 11/30/2020 11:28:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustOrderExclusion](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[StoreID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[ExclusionReason] [nvarchar](255) NULL,
 CONSTRAINT [PK_CustOrderExclusion] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustOrderExtension]    Script Date: 11/30/2020 11:28:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustOrderExtension](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustOrderID] [int] NOT NULL,
	[StoreID] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Value] [varchar](1000) NULL,
 CONSTRAINT [PK_CustOrderExtension] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustOrderStoreFile]    Script Date: 11/30/2020 11:28:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustOrderStoreFile](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StoreID] [int] NOT NULL,
	[FileName] [varchar](1000) NULL,
	[DateLoaded] [datetime] NOT NULL,
	[LoadSuccessful] [bit] NOT NULL,
	[ManualLoaded] [bit] NOT NULL,
 CONSTRAINT [PK_CustOrderStoreFile] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustOrderTracking]    Script Date: 11/30/2020 11:28:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustOrderTracking](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustOrderID] [int] NOT NULL,
	[TrackingNumber] [varchar](100) NULL,
	[Cost] [varchar](100) NULL,
	[Gateway] [varchar](100) NULL,
	[ShipMethod] [int] NULL,
	[DateEntered] [datetime] NOT NULL,
	[ShipDate] [datetime] NULL,
	[UPC] [varchar](100) NULL,
	[SkuWarehouse] [varchar](100) NULL,
 CONSTRAINT [PK_CustOrderDetailSummaryTracking] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustOrderTrackingFile]    Script Date: 11/30/2020 11:28:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustOrderTrackingFile](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StoreID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[FileName] [varchar](1000) NULL,
	[DateLoaded] [datetime] NOT NULL,
	[LoadSucessful] [bit] NOT NULL,
 CONSTRAINT [PK_TrackingNumberHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustOrderTrackingFileAssociation]    Script Date: 11/30/2020 11:28:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustOrderTrackingFileAssociation](
	[CustOrderTrackingID] [int] NOT NULL,
	[CustOrderTrackingFileID] [int] NOT NULL,
 CONSTRAINT [PK_CustOrderDetailTrackingFile] PRIMARY KEY CLUSTERED 
(
	[CustOrderTrackingID] ASC,
	[CustOrderTrackingFileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DeliveredFile]    Script Date: 11/30/2020 11:28:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeliveredFile](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[FileName] [varchar](1000) NULL,
	[DateSent] [datetime] NULL,
	[SentViaFTP] [bit] NOT NULL,
	[SentViaEmail] [bit] NOT NULL,
	[SentViaAPI] [bit] NOT NULL,
 CONSTRAINT [PK_CustOrderWarehouseFile] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DeliveredLTLLineItem]    Script Date: 11/30/2020 11:28:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeliveredLTLLineItem](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StoreID] [int] NOT NULL,
	[SourceRefNum] [varchar](255) NULL,
	[Sku] [varchar](255) NULL,
	[Qty] [varchar](255) NULL,
	[PickUpWarehouse] [varchar](255) NULL,
	[DropLocation] [varchar](255) NULL,
	[DateDelivered] [datetime] NOT NULL,
 CONSTRAINT [PK_DeliveredLTLLineItem] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HybrisCustomer]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HybrisCustomer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BillingFirstName] [varchar](100) NULL,
	[BillingLastName] [varchar](100) NULL,
	[BillingAddress1] [varchar](100) NULL,
	[BillingAddress2] [varchar](100) NULL,
	[BillingPostalCode] [varchar](50) NULL,
	[BillingCity] [varchar](100) NULL,
	[BillingState] [varchar](50) NULL,
	[BillingCountry] [varchar](100) NULL,
	[BillingPhoneNumber] [varchar](50) NULL,
	[BillingFaxNumber] [varchar](50) NULL,
	[BillingCompanyName] [varchar](100) NULL,
	[CustomerID] [varchar](100) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[CatalogSubscriber] [bit] NOT NULL,
	[CustomerType] [varchar](100) NULL,
	[Customer_IsAnonymous] [bit] NOT NULL,
	[Email] [varchar](100) NULL,
	[EmailSubscriber] [bit] NOT NULL,
	[StoreCode] [varchar](25) NULL,
	[TaxExempt] [bit] NOT NULL,
	[Title] [varchar](100) NULL,
	[FirstName] [varchar](100) NULL,
	[LastName] [varchar](100) NULL,
	[Action] [varchar](50) NULL,
	[LastModified] [datetime] NULL,
	[Customer_IsAnonymousDateUpdated] [datetime] NULL,
 CONSTRAINT [PK_HybrisCustomer] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HybrisNotifyMe]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HybrisNotifyMe](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Email] [varchar](255) NULL,
	[Sku] [varchar](255) NULL,
	[DateSent] [datetime] NOT NULL,
	[DateSubscribed] [datetime] NOT NULL,
 CONSTRAINT [PK_HybrisNotifyMe] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HybrisOrder]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HybrisOrder](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[StoreCode] [varchar](20) NULL,
	[SourceRefNum] [varchar](50) NULL,
	[OrderID] [int] NOT NULL,
	[HybrisAction] [varchar](50) NULL,
	[HybrisCustomerID] [int] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[DateReceived] [datetime] NOT NULL,
	[OrderStatus] [varchar](50) NULL,
	[ShippingMethodID] [varchar](100) NOT NULL,
	[ShipFirstName] [varchar](100) NULL,
	[ShipLastName] [varchar](100) NULL,
	[ShipAddress1] [varchar](100) NULL,
	[ShipAddress2] [varchar](100) NULL,
	[ShipPostalCode] [varchar](50) NULL,
	[ShipCity] [varchar](100) NULL,
	[ShipState] [varchar](100) NULL,
	[ShipCountry] [varchar](100) NULL,
	[ShipCompanyName] [varchar](100) NULL,
	[ShipPhoneNumber] [varchar](50) NULL,
	[ShipResidential] [varchar](2) NOT NULL,
	[EmailAddress] [varchar](100) NULL,
	[OrderComments] [varchar](max) NULL,
	[OrderNotes] [varchar](max) NULL,
	[SalesRep_CustomerID] [varchar](100) NULL,
	[AVS] [varchar](100) NULL,
	[CC_Last4] [varchar](5) NULL,
	[CVV2_Response] [varchar](100) NULL,
	[TotalShippingCost] [decimal](19, 5) NOT NULL,
	[PaymentAmount] [varchar](25) NULL,
	[Total_Payment_Authorized] [varchar](25) NULL,
	[Total_Payment_Received] [varchar](25) NULL,
	[TaxExempt] [bit] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[PaymentTransactionID] [varchar](200) NULL,
	[Currency] [varchar](50) NULL,
	[RiskStatus] [varchar](50) NOT NULL,
 CONSTRAINT [PK_HybrisOrder] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HybrisOrderDiscount]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HybrisOrderDiscount](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DiscountName] [varchar](max) NULL,
	[DiscountAmount] [decimal](19, 5) NOT NULL,
	[DiscountCode] [varchar](max) NULL,
	[FiredMessage] [varchar](max) NULL,
	[DateEntered] [datetime] NOT NULL,
	[SourceRefNum] [varchar](50) NULL,
	[SourceID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
 CONSTRAINT [PK_HybrisOrderDiscount] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HybrisOrderFee]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HybrisOrderFee](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](200) NULL,
	[Amount] [decimal](19, 5) NOT NULL,
	[AmountType] [varchar](50) NULL,
	[DateEntered] [datetime] NOT NULL,
	[SourceRefNum] [varchar](50) NULL,
	[SourceID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[TotalAmount] [decimal](19, 5) NOT NULL,
 CONSTRAINT [PK_HybrisOrderFee] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HybrisOrderLineItem]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HybrisOrderLineItem](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Sku] [varchar](100) NULL,
	[Quantity] [int] NOT NULL,
	[ProductPrice] [decimal](19, 5) NOT NULL,
	[TotalPriceOfProductOrdered] [decimal](19, 5) NOT NULL,
	[TaxableProduct] [bit] NOT NULL,
	[Options] [varchar](max) NULL,
	[DateEntered] [datetime] NOT NULL,
	[SourceRefNum] [varchar](50) NULL,
	[SourceID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[PersonalizationFee] [decimal](19, 5) NULL,
	[ProductName] [varchar](1000) NULL,
	[ProductType] [varchar](50) NULL,
 CONSTRAINT [PK_HybrisOrderLineItem] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HybrisOrderLineItemDiscount]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HybrisOrderLineItemDiscount](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DiscountName] [varchar](max) NULL,
	[DiscountAmount] [decimal](19, 5) NOT NULL,
	[DiscountCode] [varchar](max) NULL,
	[FiredMessage] [varchar](max) NULL,
	[DateEntered] [datetime] NOT NULL,
	[Sku] [varchar](200) NULL,
	[SourceRefNum] [varchar](50) NULL,
	[SourceID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
 CONSTRAINT [PK_HybrisOrderLineItemDiscount] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HybrisOrderLineItemIncludedItem]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HybrisOrderLineItemIncludedItem](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](100) NULL,
	[Description] [varchar](max) NULL,
	[DateEntered] [datetime] NOT NULL,
	[Sku] [varchar](200) NULL,
	[SourceRefNum] [varchar](50) NULL,
	[SourceID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
 CONSTRAINT [PK_HybrisOrderLineItemIncludedItem] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HybrisOrderLineItemTax]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HybrisOrderLineItemTax](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TaxName] [varchar](250) NULL,
	[TaxAmount] [decimal](19, 5) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[Sku] [varchar](200) NULL,
	[SourceRefNum] [varchar](50) NULL,
	[SourceID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[PaymentTransactionID] [varchar](200) NULL,
 CONSTRAINT [PK_HybrisOrderLineItemTax] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HybrisOrderPostDiscount]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HybrisOrderPostDiscount](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](200) NULL,
	[Amount] [decimal](19, 5) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[SourceRefNum] [varchar](50) NULL,
	[SourceID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[TotalAmount] [decimal](19, 5) NOT NULL,
 CONSTRAINT [PK_HybrisOrderPostDiscount] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HybrisOrderPostTax]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HybrisOrderPostTax](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](50) NOT NULL,
	[OrderID] [int] NOT NULL,
	[PaymentTransactionID] [varchar](200) NULL,
	[Category] [varchar](50) NOT NULL,
	[Code] [varchar](200) NOT NULL,
	[TaxName] [varchar](250) NOT NULL,
	[TaxAmount] [decimal](19, 5) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
 CONSTRAINT [PK_HybrisOrderPostTax] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HybrisOrderTax]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HybrisOrderTax](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TaxName] [varchar](250) NULL,
	[TaxAmount] [decimal](19, 5) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[SourceRefNum] [varchar](50) NULL,
	[SourceID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[PaymentTransactionID] [varchar](200) NULL,
 CONSTRAINT [PK_HybrisOrderTax] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryHistory]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Upc] [varchar](100) NULL,
	[Qty] [int] NULL,
	[StoreSKU] [varchar](255) NULL,
	[Date] [datetime] NOT NULL,
 CONSTRAINT [PK_InventoryHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryReconciliationHistory]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryReconciliationHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Reconciled] [bit] NULL,
	[TimeStamp] [datetime] NOT NULL,
 CONSTRAINT [PK_InventoryReconciliationHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NewsletterSubscription]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NewsletterSubscription](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StoreCode] [varchar](50) NULL,
	[Email] [varchar](255) NULL,
 CONSTRAINT [PK_NewsletterSubscription] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OffsetInventoryLedger]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OffsetInventoryLedger](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Username] [varchar](30) NULL,
	[Upc] [varchar](30) NULL,
	[Qty] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[SourceRefNum] [varchar](30) NULL,
	[DateOccurred] [datetime] NOT NULL,
	[Comments] [varchar](500) NULL,
	[OffSetReasonCode] [varchar](255) NULL,
	[PlatformID] [int] NULL,
	[BrandID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderInformation]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderInformation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceCustomerID] [int] NOT NULL,
	[SourceOrderID] [int] NOT NULL,
	[SourceLineItemID] [int] NOT NULL,
	[StoreID] [int] NOT NULL,
	[OrderRefNum] [varchar](100) NULL,
	[WarehouseID] [int] NOT NULL,
	[WarehouseRefNum] [varchar](100) NULL,
	[Upc] [varchar](100) NULL,
	[Qty] [int] NOT NULL,
	[DateDelivered] [datetime] NULL,
	[DeliveredFilePath] [varchar](max) NULL,
	[DateAllocated] [datetime] NULL,
	[OrderComments] [varchar](max) NULL,
	[OrderNotes] [varchar](max) NULL,
	[CancelledBy] [varchar](50) NULL,
	[CancelledOn] [datetime] NULL,
	[ShippingMethodID] [varchar](255) NULL,
	[OrderSurrogateKey] [uniqueidentifier] NULL,
 CONSTRAINT [PK_OrderInformation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderInformation_WithSourceOrderLineItemID]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderInformation_WithSourceOrderLineItemID](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceOrderLineItemID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NULL,
	[WarehouseID] [int] NOT NULL,
	[WarehouseRefNum] [varchar](100) NULL,
	[Upc] [varchar](100) NULL,
	[Qty] [int] NOT NULL,
	[DateDelivered] [datetime] NULL,
	[DeliveredFilePath] [varchar](max) NULL,
	[DateAllocated] [datetime] NULL,
	[OrderComments] [varchar](max) NULL,
	[OrderNotes] [varchar](max) NULL,
	[CancelledBy] [varchar](50) NULL,
	[CancelledOn] [datetime] NULL,
	[ShippingMethodID] [varchar](255) NULL,
	[OrderID] [int] NOT NULL,
	[Rerouted] [bit] NOT NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[PreferredShipDate] [datetime] NULL,
	[SuccessfullyDelivered] [bit] NULL,
	[Resent] [bit] NULL,
	[Returned] [datetime] NULL,
	[IssuedReturn] [varchar](200) NULL,
	[Options] [varchar](255) NULL,
	[IsDispatch] [bit] NOT NULL,
	[WarehouseShipMethod] [varchar](100) NOT NULL,
	[CarrierCode] [varchar](255) NULL,
 CONSTRAINT [PK_OrderInformation_WithSourceOrderLineItemID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrdersWithErrors]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrdersWithErrors](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SourceRefNum] [varchar](50) NULL,
	[Sku] [varchar](255) NULL,
	[Error] [varchar](255) NULL,
	[DateEntered] [datetime] NOT NULL,
	[SourceID] [int] NOT NULL,
 CONSTRAINT [PK_OrdersWithErrors] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PaymentLog]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PaymentLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceRefNum] [varchar](100) NULL,
	[PaymentID] [varchar](100) NOT NULL,
	[TransactionID] [varchar](255) NOT NULL,
	[PaymentMethodID] [varchar](100) NOT NULL,
	[AuthorizationCode] [varchar](255) NULL,
	[PaymentType] [varchar](255) NULL,
	[AVS_Response] [varchar](255) NULL,
	[CVV2_Response] [varchar](255) NULL,
	[PaymentAmount] [money] NOT NULL,
	[PaymentDetails] [varchar](255) NULL,
	[IsDeleted] [bit] NOT NULL,
	[PaymentDate] [datetime] NOT NULL,
	[ParentTransactionID] [varchar](255) NOT NULL,
	[OrderID] [int] NOT NULL,
	[CC_Last4] [varchar](100) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[LastModifiedDate] [datetime] NULL,
	[SourceID] [int] NOT NULL,
	[Currency] [varchar](50) NULL,
 CONSTRAINT [PK_VolusionPaymentLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Platform]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Platform](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Platform] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReconStoreSkuUpdate]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReconStoreSkuUpdate](
	[Store] [varchar](100) NOT NULL,
	[SkuStore] [varchar](100) NOT NULL,
	[Date] [datetime] NOT NULL,
	[SkuWarehouse] [varchar](100) NOT NULL,
	[VolusionInventoryBefore] [int] NULL,
	[VolusionInventoryAfter] [int] NULL,
	[AdjustmentQty] [int] NULL,
	[Description] [varchar](200) NULL,
 CONSTRAINT [PK_ReconStoreSkuUpdate] PRIMARY KEY CLUSTERED 
(
	[Store] ASC,
	[SkuStore] ASC,
	[Date] ASC,
	[SkuWarehouse] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalesForceExtension]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesForceExtension](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ObjectType] [nvarchar](510) NULL,
	[InternalIDName] [nvarchar](255) NOT NULL,
	[InternalID] [int] NOT NULL,
	[ExternalIDName] [nvarchar](255) NOT NULL,
	[ExternalID] [nvarchar](255) NOT NULL,
	[StoreID] [int] NOT NULL,
 CONSTRAINT [PK_SalesForceExtension] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalesforceOrder]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesforceOrder](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Action] [varchar](50) NULL,
	[Brand] [varchar](50) NULL,
	[BrandOrderId] [varchar](200) NOT NULL,
	[FlowType] [varchar](50) NULL,
	[SalesforceOrderID] [varchar](100) NOT NULL,
	[OrderID] [varchar](50) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[OrderStatus] [varchar](50) NULL,
	[BrandCustomerID] [varchar](100) NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[OrderType] [varchar](50) NULL,
	[EmailAddress] [varchar](100) NULL,
	[SalesRepID] [varchar](100) NULL,
	[BillingFirstName] [varchar](100) NULL,
	[BillingLastName] [varchar](100) NULL,
	[BillingPhone] [varchar](50) NULL,
	[BillingCountry] [varchar](50) NULL,
	[BillingState] [varchar](50) NULL,
	[BillingAddress1] [varchar](200) NULL,
	[BillingAddress2] [varchar](200) NULL,
	[BillingPostalCode] [varchar](50) NULL,
	[ShipFirstName] [varchar](100) NULL,
	[ShipLastName] [varchar](100) NULL,
	[ShipPhone] [varchar](50) NULL,
	[ShipCountry] [varchar](50) NULL,
	[ShipState] [varchar](50) NULL,
	[ShipAddress1] [varchar](200) NULL,
	[ShipAddress2] [varchar](200) NULL,
	[ShipPostalCode] [varchar](50) NULL,
	[ShipCompanyName] [varchar](100) NULL,
	[PrivateNotes] [varchar](max) NULL,
	[OrderNotes] [varchar](max) NULL,
	[ShipMethodID] [varchar](100) NULL,
	[TaxExemptOrder] [bit] NOT NULL,
 CONSTRAINT [PK_SalesforceOrder] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalesForceOrderDetailExtension]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesForceOrderDetailExtension](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SalesForceOrderExtensionID] [int] NOT NULL,
	[OrderDetailID] [int] NOT NULL,
	[ProductName] [varchar](1000) NULL,
	[StoreSku] [nvarchar](510) NULL,
	[TaxableProduct] [bit] NOT NULL,
	[ProductType] [varchar](50) NULL,
 CONSTRAINT [PK_SalesForceOrderDetailExtension] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalesForceOrderExtension]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesForceOrderExtension](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StoreID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[CVV2_Response] [nvarchar](255) NULL,
	[AVS] [nvarchar](255) NULL,
	[Total_Payment_Authorized] [money] NULL,
	[Total_Payment_Received] [money] NULL,
	[SalesTax1] [nvarchar](255) NULL,
	[SalesTax2] [nvarchar](255) NULL,
	[SalesTax3] [nvarchar](255) NULL,
	[SalesTaxRate] [nvarchar](255) NULL,
	[SalesTaxRate1] [nvarchar](255) NULL,
	[SalesTaxRate2] [nvarchar](255) NULL,
	[SalesTaxRate3] [nvarchar](255) NULL,
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
	[SalesRep_CustomerID] [int] NULL,
	[UploadedDate] [datetime] NULL,
 CONSTRAINT [PK_SalesForceOrderExtension] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalesforceOrderLineItem]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesforceOrderLineItem](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BrandOrderItemID] [varchar](100) NOT NULL,
	[OrderID] [varchar](50) NOT NULL,
	[SkuStore] [varchar](100) NOT NULL,
	[Quantity] [int] NOT NULL,
	[ProductPrice] [float] NOT NULL,
	[ProductName] [varchar](1000) NULL,
	[UPC_Section] [varchar](100) NULL,
 CONSTRAINT [PK_SalesforceOrderLineItem] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalesforceOrderLineItemDiscount]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesforceOrderLineItemDiscount](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BrandDiscountId] [varchar](100) NOT NULL,
	[OrderID] [varchar](50) NOT NULL,
	[CreatedDate] [datetime] NULL,
	[DiscountName] [varchar](200) NULL,
	[DiscountCode] [varchar](200) NULL,
	[DiscountValue] [varchar](50) NULL,
	[Quantity] [int] NOT NULL,
 CONSTRAINT [PK_SalesforceOrderLineItemDiscount] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ShippingPromotion]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShippingPromotion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceRefNum] [varchar](50) NULL,
	[OldShippingMethodID] [varchar](255) NOT NULL,
	[NewPromoShippingMethodID] [varchar](255) NOT NULL,
	[Promotion] [varchar](1000) NULL,
	[Zone] [int] NULL,
	[SourceID] [int] NULL,
	[WarehouseID] [int] NULL,
 CONSTRAINT [PK_CustOrderPromo] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ShrinkQty]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShrinkQty](
	[SkuWarehouse] [varchar](200) NOT NULL,
	[Date] [datetime] NOT NULL,
	[ShrinkQty] [int] NOT NULL,
	[WarehouseID] [int] NULL,
 CONSTRAINT [PK_ShrinkQty] PRIMARY KEY CLUSTERED 
(
	[SkuWarehouse] ASC,
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SkuHistory]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SkuHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PlatformID] [int] NULL,
	[SourceID] [int] NULL,
	[Sku] [varchar](50) NULL,
	[Source] [varchar](50) NULL,
	[SourceRefNum] [varchar](255) NULL,
	[Qty] [int] NOT NULL,
	[Before] [int] NOT NULL,
	[After] [int] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[RegionID] [int] NULL,
	[EventDate] [datetime] NULL,
 CONSTRAINT [PK_SkuHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SkuUpcAuditTrail]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SkuUpcAuditTrail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[Upc] [varchar](255) NULL,
	[ActionAt] [datetime] NOT NULL,
	[ActionBy] [varchar](255) NOT NULL,
	[Action] [varchar](255) NOT NULL,
 CONSTRAINT [PK_SkuUpcAuditTrail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Source]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Source](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PlatformID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
 CONSTRAINT [PK_Source] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SourceCustomer]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SourceCustomer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NULL,
 CONSTRAINT [PK_SourceCustomer] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SourceLineItem]    Script Date: 11/30/2020 11:28:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SourceLineItem](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceOrderID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NULL,
	[Sku] [varchar](100) NULL,
	[Qty] [int] NOT NULL,
	[Price] [money] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](100) NULL,
 CONSTRAINT [PK_SourceLineItem] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SourceOrder]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SourceOrder](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NULL,
	[ShippingMethodID] [varchar](255) NOT NULL,
	[ShipFirstName] [varchar](100) NULL,
	[ShipLastName] [varchar](100) NULL,
	[ShipPhoneNumber] [varchar](100) NULL,
	[ShipCompanyName] [varchar](100) NULL,
	[ShipAddress1] [varchar](200) NULL,
	[ShipAddress2] [varchar](200) NULL,
	[ShipCity] [varchar](100) NULL,
	[ShipState] [varchar](100) NULL,
	[ShipPostalCode] [varchar](100) NULL,
	[ShipCountry] [varchar](100) NULL,
	[ShipResidential] [varchar](100) NOT NULL,
	[OrderDate] [varchar](100) NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](100) NULL,
	[GST] [decimal](19, 5) NULL,
	[PST] [decimal](19, 5) NULL,
	[HST] [decimal](19, 5) NULL,
	[OrderStatus] [varchar](50) NULL,
	[DateLoaded] [datetime] NULL,
 CONSTRAINT [PK_SourceOrder] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SourceOrderLineItem]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SourceOrderLineItem](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NULL,
	[ShippingMethodID] [varchar](255) NOT NULL,
	[ShipFirstName] [varchar](100) NULL,
	[ShipLastName] [varchar](100) NULL,
	[ShipPhoneNumber] [varchar](100) NULL,
	[ShipCompanyName] [varchar](100) NULL,
	[ShipAddress1] [varchar](200) NULL,
	[ShipAddress2] [varchar](200) NULL,
	[ShipCity] [varchar](100) NULL,
	[ShipState] [varchar](100) NULL,
	[ShipPostalCode] [varchar](100) NULL,
	[ShipCountry] [varchar](100) NULL,
	[ShipResidential] [varchar](100) NOT NULL,
	[OrderDate] [varchar](100) NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](100) NULL,
	[GST] [decimal](19, 5) NULL,
	[PST] [decimal](19, 5) NULL,
	[HST] [decimal](19, 5) NULL,
	[OrderStatus] [varchar](50) NULL,
	[DateLoaded] [datetime] NULL,
	[Sku] [varchar](100) NULL,
	[Qty] [int] NOT NULL,
	[Price] [money] NOT NULL,
	[LastModified] [datetime] NULL,
	[OrderID] [int] NOT NULL,
	[IsReroute] [bit] NULL,
	[IsResend] [bit] NULL,
	[Options] [varchar](max) NULL,
	[CustomerID] [varchar](50) NULL,
	[PreferredShipDate] [datetime] NULL,
	[SendToWarehouseDate] [datetime] NULL,
	[OrderType] [varchar](50) NULL,
	[IsDispatch] [bit] NOT NULL,
 CONSTRAINT [PK_SourceOrderLineItem] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StatusLog]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StatusLog](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[Timestamp] [datetime] NULL,
	[Category] [varchar](100) NULL,
	[LogLevel] [varchar](100) NULL,
	[Msg] [varchar](max) NULL,
 CONSTRAINT [PK_StatusLog] PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Store]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Store](
	[SourceID] [int] NOT NULL,
	[Name] [varchar](200) NOT NULL,
	[SalesForceAccountID] [nvarchar](50) NULL,
 CONSTRAINT [PK_Store] PRIMARY KEY CLUSTERED 
(
	[SourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StoreSku]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StoreSku](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StoreID] [int] NOT NULL,
	[Sku] [varchar](50) NULL,
 CONSTRAINT [PK_StoreSku] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TrackingNumber]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrackingNumber](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[WarehouseRefNum] [varchar](100) NULL,
	[SourceID] [int] NOT NULL,
	[Upc] [varchar](100) NULL,
	[TrackingNumber] [varchar](100) NULL,
	[DateShipped] [datetime] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[ShippingMethodID] [varchar](50) NULL,
	[SourceRefNum] [varchar](50) NULL,
	[IsWarranty] [bit] NOT NULL,
	[WarehouseShipMethod] [varchar](255) NULL,
	[ReceivedWarehouseShipMethod] [varchar](255) NULL,
 CONSTRAINT [PK_TrackingNumber] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UpcHistory]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UpcHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](50) NULL,
	[Sku] [varchar](255) NULL,
	[Upc] [varchar](100) NULL,
	[WarehouseID] [int] NOT NULL,
	[Qty] [int] NOT NULL,
 CONSTRAINT [PK_UpcHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VersionInfo]    Script Date: 11/30/2020 11:28:18 AM ******/
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
/****** Object:  Index [UC_Version]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE UNIQUE CLUSTERED INDEX [UC_Version] ON [dbo].[VersionInfo]
(
	[Version] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VolusionOrder]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VolusionOrder](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SourceRefNum] [varchar](50) NULL,
	[ShippingMethodID] [int] NOT NULL,
	[OrderComments] [varchar](max) NULL,
	[EmailAddress] [varchar](100) NULL,
	[ShipFirstName] [varchar](100) NULL,
	[ShipLastName] [varchar](100) NULL,
	[ShipPhoneNumber] [varchar](100) NULL,
	[ShipCompanyName] [varchar](100) NULL,
	[ShipAddress1] [varchar](200) NULL,
	[ShipAddress2] [varchar](200) NULL,
	[ShipCity] [varchar](100) NULL,
	[ShipState] [varchar](100) NULL,
	[ShipPostalCode] [varchar](100) NULL,
	[ShipCountry] [varchar](100) NULL,
	[ShipResidential] [varchar](100) NOT NULL,
	[OrderStatus] [varchar](100) NULL,
	[OrderNotes] [varchar](max) NULL,
	[DateLoaded] [datetime] NOT NULL,
	[OrderDate] [varchar](100) NULL,
	[SourceID] [int] NOT NULL,
	[LastModified] [datetime] NULL,
	[TaxableProduct] [varchar](255) NULL,
	[OrderID] [int] NULL,
 CONSTRAINT [PK_VolusionOrder] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VolusionOrderFile]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VolusionOrderFile](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceRefNum] [varchar](50) NULL,
	[Path] [varchar](max) NULL,
	[DateEntered] [datetime] NOT NULL,
	[SourceID] [int] NOT NULL,
 CONSTRAINT [PK_VolusionOrderFile] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VolusionPromo]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VolusionPromo](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceOrderID] [int] NOT NULL,
	[OldShippingMethodID] [int] NOT NULL,
	[NewPromoShippingMethodID] [int] NOT NULL,
	[ShippingPromotion] [varchar](max) NULL,
	[Zone] [int] NOT NULL,
 CONSTRAINT [PK_VolusionPromo] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VolusionTrackingNumbersTempTable]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VolusionTrackingNumbersTempTable](
	[ID] [int] NOT NULL,
	[OrderID] [varchar](255) NOT NULL,
	[StoreID] [int] NOT NULL,
	[StoreName] [varchar](255) NULL,
	[TrackingNumber] [varchar](255) NULL,
	[ShippingMethodID] [int] NULL,
	[Gateway] [varchar](255) NULL,
	[Cost] [decimal](18, 0) NOT NULL,
	[Upc] [varchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Warehouse]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Warehouse](
	[WarehouseID] [int] NOT NULL,
	[Name] [varchar](200) NULL,
 CONSTRAINT [PK_Warehouse] PRIMARY KEY CLUSTERED 
(
	[WarehouseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseInventoryFile]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseInventoryFile](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FileName] [varchar](1000) NULL,
	[UserName] [varchar](100) NULL,
	[DateLoaded] [datetime] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Previewed] [bit] NOT NULL,
 CONSTRAINT [PK_WarehouseInventoryFile] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseInventoryLoaded]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseInventoryLoaded](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Upc] [varchar](100) NULL,
	[Qty] [varchar](100) NULL,
	[Date] [datetime] NOT NULL,
	[BrandSku] [varchar](100) NULL,
 CONSTRAINT [PK_WarehouseInventoryLoaded] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorldshipTNs]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorldshipTNs](
	[TN] [varchar](50) NULL,
	[Type] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_CustOrderDetailSku_CustOrderDetailID, dbo.TreesHistory]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_CustOrderDetailSku_CustOrderDetailID, dbo.${Environment}TreesHistory] ON [dbo].[CustOrderDetailSku]
(
	[CustOrderDetailID] ASC
)
INCLUDE ( 	[ID],
	[SkuWarehouse],
	[HasBeenUnassigned]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_HybrisCustomer__CustomerID]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_HybrisCustomer__CustomerID] ON [dbo].[HybrisCustomer]
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [HybrisOrder_OrderDate]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [HybrisOrder_OrderDate] ON [dbo].[HybrisOrder]
(
	[OrderDate] ASC
)
INCLUDE ( 	[OrderID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [HybrisOrderLineItemTax_Sku_SourceRefNum_OrderID]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [HybrisOrderLineItemTax_Sku_SourceRefNum_OrderID] ON [dbo].[HybrisOrderLineItemTax]
(
	[Sku] ASC,
	[SourceRefNum] ASC,
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [HybrisOrderTax_OrderID]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [HybrisOrderTax_OrderID] ON [dbo].[HybrisOrderTax]
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_InventoryHistory_Date]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_InventoryHistory_Date] ON [dbo].[InventoryHistory]
(
	[Date] DESC,
	[WarehouseID] ASC,
	[Upc] ASC,
	[Qty] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_InventoryHistory_Upc]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_InventoryHistory_Upc] ON [dbo].[InventoryHistory]
(
	[Upc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_InventoryHistory_WarehouseID]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_InventoryHistory_WarehouseID] ON [dbo].[InventoryHistory]
(
	[WarehouseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_OffsetInventoryLedger_Upc]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [ix_OffsetInventoryLedger_Upc] ON [dbo].[OffsetInventoryLedger]
(
	[Upc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrderInformation_WithSourceOrderLineItemID__OrderID]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_OrderInformation_WithSourceOrderLineItemID__OrderID] ON [dbo].[OrderInformation_WithSourceOrderLineItemID]
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrderInformation_WithSourceOrderLineItemID__SourceOrderLineItemID]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_OrderInformation_WithSourceOrderLineItemID__SourceOrderLineItemID] ON [dbo].[OrderInformation_WithSourceOrderLineItemID]
(
	[SourceOrderLineItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [PaymentLog_PaymentDate]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [PaymentLog_PaymentDate] ON [dbo].[PaymentLog]
(
	[PaymentDate] ASC
)
INCLUDE ( 	[SourceRefNum],
	[TransactionID],
	[PaymentType],
	[PaymentAmount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [PaymentLog_SourceID_PaymentDate_SourceRefNum_TransactionID]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [PaymentLog_SourceID_PaymentDate_SourceRefNum_TransactionID] ON [dbo].[PaymentLog]
(
	[SourceID] ASC,
	[PaymentDate] ASC
)
INCLUDE ( 	[SourceRefNum],
	[TransactionID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [PaymentLog_TransactionID]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [PaymentLog_TransactionID] ON [dbo].[PaymentLog]
(
	[SourceRefNum] ASC,
	[TransactionID] ASC
)
INCLUDE ( 	[PaymentMethodID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [uc_InternalExternal]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [uc_InternalExternal] ON [dbo].[SalesForceExtension]
(
	[InternalID] ASC,
	[ExternalID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [SalesForceOrder_OrderID_OrderStatus_OrderDate]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [SalesForceOrder_OrderID_OrderStatus_OrderDate] ON [dbo].[SalesforceOrder]
(
	[OrderID] ASC
)
INCLUDE ( 	[BrandOrderId],
	[OrderStatus],
	[OrderDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SalesForceOrderDetailExtension_OrderDetailID]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_SalesForceOrderDetailExtension_OrderDetailID] ON [dbo].[SalesForceOrderDetailExtension]
(
	[OrderDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SalesForceOrderExtension_OrderID_CustomerID_StoreID]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_SalesForceOrderExtension_OrderID_CustomerID_StoreID] ON [dbo].[SalesForceOrderExtension]
(
	[OrderID] ASC,
	[CustomerID] ASC,
	[StoreID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [SkuHistory_Index]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [SkuHistory_Index] ON [dbo].[SkuHistory]
(
	[SourceID] ASC,
	[RegionID] ASC,
	[Sku] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_SourceCustomer_SourceRefNum_SourceID]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_SourceCustomer_SourceRefNum_SourceID] ON [dbo].[SourceCustomer]
(
	[SourceRefNum] ASC,
	[SourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SourceOrderLineItem__OrderID]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_SourceOrderLineItem__OrderID] ON [dbo].[SourceOrderLineItem]
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_SourceOrderLineItem__SourceID_SourceRefNum]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_SourceOrderLineItem__SourceID_SourceRefNum] ON [dbo].[SourceOrderLineItem]
(
	[SourceID] ASC,
	[SourceRefNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_TrackingNumber__StoreID_SourceRefNum]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_TrackingNumber__StoreID_SourceRefNum] ON [dbo].[TrackingNumber]
(
	[SourceID] ASC,
	[SourceRefNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_TrackingNumber__StoreID_WarehouseRefNum]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_TrackingNumber__StoreID_WarehouseRefNum] ON [dbo].[TrackingNumber]
(
	[SourceID] ASC,
	[WarehouseRefNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_WarehouseInventoryLoaded_Date]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_WarehouseInventoryLoaded_Date] ON [dbo].[WarehouseInventoryLoaded]
(
	[Date] DESC,
	[WarehouseID] ASC,
	[Upc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_WarehouseInventoryLoaded_Upc]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_WarehouseInventoryLoaded_Upc] ON [dbo].[WarehouseInventoryLoaded]
(
	[Upc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_WarehouseInventoryLoaded_WarehouseID]    Script Date: 11/30/2020 11:28:18 AM ******/
CREATE NONCLUSTERED INDEX [IX_WarehouseInventoryLoaded_WarehouseID] ON [dbo].[WarehouseInventoryLoaded]
(
	[WarehouseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CommercialInvoice] ADD  CONSTRAINT [DF_CommercialInvoices_SentViaEmail]  DEFAULT ((0)) FOR [SentViaEmail]
GO
ALTER TABLE [dbo].[CommercialInvoice] ADD  CONSTRAINT [DF_CommercialInvoices_SentViaFTP]  DEFAULT ((0)) FOR [SentViaFTP]
GO
ALTER TABLE [dbo].[CustOrder] ADD  CONSTRAINT [DF_CustOrder_OrderDate]  DEFAULT (((1900)-(1))-(1)) FOR [OrderDate]
GO
ALTER TABLE [dbo].[CustOrder] ADD  CONSTRAINT [DF_CustOrder_DeletedOn_1]  DEFAULT (getdate()) FOR [DeletedOn]
GO
ALTER TABLE [dbo].[CustOrderDetail] ADD  CONSTRAINT [DF_CustOrderDetail_DeletedOn]  DEFAULT (getdate()) FOR [DeletedOn]
GO
ALTER TABLE [dbo].[CustOrderDetailSkuWarehouse] ADD  CONSTRAINT [DF_CustOrderDetailWarehouse_Qty]  DEFAULT ((0)) FOR [Qty]
GO
ALTER TABLE [dbo].[CustOrderExtension] ADD  CONSTRAINT [DF_CustOrderExtension_DateAssigned]  DEFAULT (getdate()) FOR [Value]
GO
ALTER TABLE [dbo].[CustOrderStoreFile] ADD  CONSTRAINT [DF_CustOrderStoreFile_DateLoaded]  DEFAULT (getdate()) FOR [DateLoaded]
GO
ALTER TABLE [dbo].[CustOrderStoreFile] ADD  CONSTRAINT [DF_CustOrderStoreFile_LoadSuccessful]  DEFAULT ((0)) FOR [LoadSuccessful]
GO
ALTER TABLE [dbo].[CustOrderStoreFile] ADD  CONSTRAINT [DF_CustOrderStoreFile_ManualLoaded_1]  DEFAULT ((1)) FOR [ManualLoaded]
GO
ALTER TABLE [dbo].[CustOrderTrackingFile] ADD  CONSTRAINT [DF_CustOrderTrackingFile_LoadSucessful]  DEFAULT ((0)) FOR [LoadSucessful]
GO
ALTER TABLE [dbo].[DeliveredFile] ADD  CONSTRAINT [DF_CustOrderWarehouseFile_SentViaFTP]  DEFAULT ((0)) FOR [SentViaFTP]
GO
ALTER TABLE [dbo].[DeliveredFile] ADD  CONSTRAINT [DF_CustOrderWarehouseFile_SentViaEmail]  DEFAULT ((0)) FOR [SentViaEmail]
GO
ALTER TABLE [dbo].[DeliveredFile] ADD  CONSTRAINT [DF_CustOrderWarehouseFile_SentViaAPI]  DEFAULT ((0)) FOR [SentViaAPI]
GO
ALTER TABLE [dbo].[OrderInformation_WithSourceOrderLineItemID] ADD  CONSTRAINT [DF_OrderInformation_WithSourceOrderLineItemID_Rerouted]  DEFAULT ((0)) FOR [Rerouted]
GO
ALTER TABLE [dbo].[SalesforceOrder] ADD  CONSTRAINT [DF_SalesForceOrder_TaxExemptOrder]  DEFAULT ((0)) FOR [TaxExemptOrder]
GO
ALTER TABLE [dbo].[SalesForceOrderDetailExtension] ADD  CONSTRAINT [DF_SalesForceOrderDetailExtension_TaxableProduct]  DEFAULT ((0)) FOR [TaxableProduct]
GO
ALTER TABLE [dbo].[TrackingNumber] ADD  CONSTRAINT [DF_TrackingNumber_IsWarranty]  DEFAULT ((0)) FOR [IsWarranty]
GO
ALTER TABLE [dbo].[CustOrder]  WITH CHECK ADD  CONSTRAINT [FK_CustOrder_CustOrderStoreFile] FOREIGN KEY([CustOrderStoreFileID])
REFERENCES [dbo].[CustOrderStoreFile] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustOrder] CHECK CONSTRAINT [FK_CustOrder_CustOrderStoreFile]
GO
ALTER TABLE [dbo].[CustOrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_CustOrderDetail_CustOrder] FOREIGN KEY([CustOrderID])
REFERENCES [dbo].[CustOrder] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustOrderDetail] CHECK CONSTRAINT [FK_CustOrderDetail_CustOrder]
GO
ALTER TABLE [dbo].[CustOrderDetailSku]  WITH CHECK ADD  CONSTRAINT [FK_CustOrderDetailSku_CustOrderDetail] FOREIGN KEY([CustOrderDetailID])
REFERENCES [dbo].[CustOrderDetail] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustOrderDetailSku] CHECK CONSTRAINT [FK_CustOrderDetailSku_CustOrderDetail]
GO
ALTER TABLE [dbo].[CustOrderDetailSkuWarehouse]  WITH CHECK ADD  CONSTRAINT [FK_CustOrderDetailWarehouse_CustOrderDetail] FOREIGN KEY([CustOrderDetailSkuID])
REFERENCES [dbo].[CustOrderDetailSku] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustOrderDetailSkuWarehouse] CHECK CONSTRAINT [FK_CustOrderDetailWarehouse_CustOrderDetail]
GO
ALTER TABLE [dbo].[CustOrderDetailSkuWarehouse]  WITH CHECK ADD  CONSTRAINT [FK_CustOrderDetailWarehouse_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustOrderDetailSkuWarehouse] CHECK CONSTRAINT [FK_CustOrderDetailWarehouse_Warehouse]
GO
ALTER TABLE [dbo].[CustOrderDetailSkuWarehouseAssociation]  WITH CHECK ADD  CONSTRAINT [FK_CustOrderDetailSkuWarehouseAssociation_CustOrderDetailSku] FOREIGN KEY([CustOrderDetailSkuID])
REFERENCES [dbo].[CustOrderDetailSku] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustOrderDetailSkuWarehouseAssociation] CHECK CONSTRAINT [FK_CustOrderDetailSkuWarehouseAssociation_CustOrderDetailSku]
GO
ALTER TABLE [dbo].[CustOrderDetailSkuWarehouseAssociation]  WITH CHECK ADD  CONSTRAINT [FK_CustOrderDetailWarehouseFile_CustOrderWarehouseFile] FOREIGN KEY([CustOrderWarehouseFileID])
REFERENCES [dbo].[DeliveredFile] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustOrderDetailSkuWarehouseAssociation] CHECK CONSTRAINT [FK_CustOrderDetailWarehouseFile_CustOrderWarehouseFile]
GO
ALTER TABLE [dbo].[CustOrderDuplicates]  WITH CHECK ADD  CONSTRAINT [FK_CustOrderDuplicates_CustOrderWarehouseFile] FOREIGN KEY([CustOrderStoreFileID])
REFERENCES [dbo].[CustOrderStoreFile] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustOrderDuplicates] CHECK CONSTRAINT [FK_CustOrderDuplicates_CustOrderWarehouseFile]
GO
ALTER TABLE [dbo].[CustOrderExtension]  WITH CHECK ADD  CONSTRAINT [FK_CustOrderExtension_CustOrder] FOREIGN KEY([CustOrderID])
REFERENCES [dbo].[CustOrder] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustOrderExtension] CHECK CONSTRAINT [FK_CustOrderExtension_CustOrder]
GO
ALTER TABLE [dbo].[CustOrderExtension]  WITH CHECK ADD  CONSTRAINT [FK_CustOrderExtension_Store] FOREIGN KEY([StoreID])
REFERENCES [dbo].[Store] ([SourceID])
GO
ALTER TABLE [dbo].[CustOrderExtension] CHECK CONSTRAINT [FK_CustOrderExtension_Store]
GO
ALTER TABLE [dbo].[CustOrderStoreFile]  WITH CHECK ADD  CONSTRAINT [FK_CustOrderStoreFile_Store] FOREIGN KEY([StoreID])
REFERENCES [dbo].[Store] ([SourceID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustOrderStoreFile] CHECK CONSTRAINT [FK_CustOrderStoreFile_Store]
GO
ALTER TABLE [dbo].[CustOrderTracking]  WITH CHECK ADD  CONSTRAINT [FK_CustOrderTracking_CustOrder] FOREIGN KEY([CustOrderID])
REFERENCES [dbo].[CustOrder] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustOrderTracking] CHECK CONSTRAINT [FK_CustOrderTracking_CustOrder]
GO
ALTER TABLE [dbo].[CustOrderTrackingFile]  WITH CHECK ADD  CONSTRAINT [FK_CustOrderTrackingFile_Store] FOREIGN KEY([StoreID])
REFERENCES [dbo].[Store] ([SourceID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustOrderTrackingFile] CHECK CONSTRAINT [FK_CustOrderTrackingFile_Store]
GO
ALTER TABLE [dbo].[CustOrderTrackingFile]  WITH CHECK ADD  CONSTRAINT [FK_CustOrderTrackingFile_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustOrderTrackingFile] CHECK CONSTRAINT [FK_CustOrderTrackingFile_Warehouse]
GO
ALTER TABLE [dbo].[CustOrderTrackingFileAssociation]  WITH CHECK ADD  CONSTRAINT [FK_CustOrderDetailTrackingFile_CustOrderSummaryTracking] FOREIGN KEY([CustOrderTrackingID])
REFERENCES [dbo].[CustOrderTracking] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustOrderTrackingFileAssociation] CHECK CONSTRAINT [FK_CustOrderDetailTrackingFile_CustOrderSummaryTracking]
GO
ALTER TABLE [dbo].[CustOrderTrackingFileAssociation]  WITH CHECK ADD  CONSTRAINT [FK_CustOrderTrackingFileAssociation_CustOrderTrackingFile] FOREIGN KEY([CustOrderTrackingFileID])
REFERENCES [dbo].[CustOrderTrackingFile] ([ID])
GO
ALTER TABLE [dbo].[CustOrderTrackingFileAssociation] CHECK CONSTRAINT [FK_CustOrderTrackingFileAssociation_CustOrderTrackingFile]
GO
ALTER TABLE [dbo].[DeliveredFile]  WITH CHECK ADD  CONSTRAINT [FK_CustOrderWarehouseFile_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
GO
ALTER TABLE [dbo].[DeliveredFile] CHECK CONSTRAINT [FK_CustOrderWarehouseFile_Warehouse]
GO
ALTER TABLE [dbo].[OffsetInventoryLedger]  WITH CHECK ADD  CONSTRAINT [FK_OffsetInventoryLedger_WarehouseID_Warehouse_WarehouseID] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
GO
ALTER TABLE [dbo].[OffsetInventoryLedger] CHECK CONSTRAINT [FK_OffsetInventoryLedger_WarehouseID_Warehouse_WarehouseID]
GO
ALTER TABLE [dbo].[OrdersWithErrors]  WITH CHECK ADD  CONSTRAINT [FK_OrdersWithErrors_SourceID_Source_ID] FOREIGN KEY([SourceID])
REFERENCES [dbo].[Source] ([ID])
GO
ALTER TABLE [dbo].[OrdersWithErrors] CHECK CONSTRAINT [FK_OrdersWithErrors_SourceID_Source_ID]
GO
ALTER TABLE [dbo].[PaymentLog]  WITH CHECK ADD  CONSTRAINT [FK_PaymentLog_SourceID_Source_ID] FOREIGN KEY([SourceID])
REFERENCES [dbo].[Source] ([ID])
GO
ALTER TABLE [dbo].[PaymentLog] CHECK CONSTRAINT [FK_PaymentLog_SourceID_Source_ID]
GO
ALTER TABLE [dbo].[SalesForceOrderDetailExtension]  WITH CHECK ADD  CONSTRAINT [FK_SalesForceOrderDetailExtension_SalesForceOrderExtensionID_SalesForceOrderExtension_ID] FOREIGN KEY([SalesForceOrderExtensionID])
REFERENCES [dbo].[SalesForceOrderExtension] ([ID])
GO
ALTER TABLE [dbo].[SalesForceOrderDetailExtension] CHECK CONSTRAINT [FK_SalesForceOrderDetailExtension_SalesForceOrderExtensionID_SalesForceOrderExtension_ID]
GO
ALTER TABLE [dbo].[SalesForceOrderExtension]  WITH CHECK ADD  CONSTRAINT [FK_SalesForceOrderExtension_StoreID_Store_StoreID] FOREIGN KEY([StoreID])
REFERENCES [dbo].[Store] ([SourceID])
GO
ALTER TABLE [dbo].[SalesForceOrderExtension] CHECK CONSTRAINT [FK_SalesForceOrderExtension_StoreID_Store_StoreID]
GO
ALTER TABLE [dbo].[ShrinkQty]  WITH CHECK ADD  CONSTRAINT [FK_ShrinkQty_Warehouse] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[Warehouse] ([WarehouseID])
GO
ALTER TABLE [dbo].[ShrinkQty] CHECK CONSTRAINT [FK_ShrinkQty_Warehouse]
GO
/****** Object:  StoredProcedure [dbo].[GetLoadedSalesforceOrders]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[GetLoadedSalesforceOrders]
                        @prefix varchar(50),
                        @platformID int
                        as
	                    set nocount on;

                        declare @latestSourceRefNum BIGINT;
                        SELECT @latestSourceRefNum = MAX(CAST(REPLACE(SourceRefNum, @prefix + '_', '') AS BIGINT))
				        from (
					        select a.SourceRefNum, b.PlatformID, a.DateLoaded
                            FROM ${Environment}TreesHistory..SourceOrderLineItem a
                            JOIN Source b ON a.SourceID = b.ID                    
					        union all
					        select ai.SourceRefNum, bi.PlatformID, ai.DateLoaded
					        FROM ${Environment}InternationalHistory..SourceOrderLineItem ai
                            JOIN ${Environment}InternationalHistory..Source bi ON ai.SourceID = bi.ID
					        ) merged
                            WHERE merged.SourceRefNum LIKE '%'+@prefix+'%'
					        AND merged.DateLoaded < (select DATEADD(day,-1,SYSDATETIME()))
                            AND merged.PlatformID = @platformID;

                        declare @resultTable Table (sourceRefNum bigint, dateLoaded datetime)
                        insert into @resultTable
	                    select di.sourcerefnum, di.dateloaded from
		                    (
			                    SELECT CAST(REPLACE(a.SourceRefNum, @prefix + '_', '') AS BIGINT) SourceRefNum, a.DateLoaded
			                    FROM ${Environment}TreesHistory..SourceOrderLineItem a
			                    JOIN Source b ON a.SourceID = b.ID
			                    WHERE a.SourceRefNum LIKE '%'+@prefix+'%'
			                    AND b.PlatformID = @platformID
			                    AND CASE WHEN ISNUMERIC(REPLACE(a.SourceRefNum, @prefix + '_', '')) = 1 THEN CAST(REPLACE(a.SourceRefNum, @prefix + '_', '') AS BIGINT) ELSE -1 END >= @latestSourceRefNum
			                    union all
			                    SELECT CAST(REPLACE(ai.SourceRefNum, @prefix + '_', '') AS BIGINT) SourceRefNum, ai.DateLoaded
			                    FROM ${Environment}InternationalHistory..SourceOrderLineItem ai
			                    JOIN ${Environment}InternationalHistory..Source bi ON ai.SourceID = bi.ID
			                    WHERE ai.SourceRefNum LIKE '%'+@prefix+'%'
			                    AND bi.PlatformID = @platformID
			                    AND CASE WHEN ISNUMERIC(REPLACE(ai.SourceRefNum, @prefix + '_', '')) = 1 THEN CAST(REPLACE(ai.SourceRefNum, @prefix + '_', '') AS BIGINT) ELSE -1 END >= @latestSourceRefNum
		                    ) di
		                    order by di.dateloaded;
                            select sourceRefNum from @resultTable
                            group by SourceRefNum;
GO
/****** Object:  StoredProcedure [dbo].[GetOrderHistory]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[GetOrderHistory](@StoreID int, @OrderID int, @OnlyProcessing bit = 1, @IncludeUnassigned bit = 1)
as

declare @CustOrderID INT;

declare order_cursor CURSOR FOR
select a.id from custorder a
join custorderstorefile b on (a.CustOrderStoreFileID = b.id)
where orderid = @OrderID
and b.storeid = @StoreID
and a.OrderStatus = (case when @OnlyProcessing = 1 then 'processing' else a.OrderStatus end);

open order_cursor;

fetch next from order_cursor
into @CustOrderID;

while @@fetch_status = 0
begin

select 'Cust Order ID: ' + CAST(@CustOrderID as varchar)

select * from custorder where id = @CustOrderID
select * from custorderdetail where custorderid = @CustOrderID
select * from custorderdetailsku where custorderdetailid in (select id from custorderdetail where custorderid = @CustOrderID) and ((HasBeenUnassigned IS NULL and @IncludeUnassigned = 0) OR @IncludeUnassigned = 1)
select * from custorderdetailskuwarehouse where custorderdetailskuid in (select id from custorderdetailsku where custorderdetailid in (select id from custorderdetail where custorderid = @CustOrderID)  and ((HasBeenUnassigned IS NULL and @IncludeUnassigned = 0) OR @IncludeUnassigned = 1)) 
select * from deliveredfile where id in (select custorderwarehousefileid from CustOrderDetailSkuWarehouseAssociation where custorderdetailskuid in (select id from custorderdetailsku where custorderdetailid in (select id from custorderdetail where custorderid = @CustOrderID)))

fetch next from order_cursor
into @CustOrderID;

end

close order_cursor;
deallocate order_cursor;
GO
/****** Object:  StoredProcedure [dbo].[RebuildIndexes]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[RebuildIndexes]
AS
BEGIN
	SET NOCOUNT ON; -- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
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

/****** Object:  StoredProcedure [dbo].[TN_SP_GetExistingOrders]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[TN_SP_GetExistingOrders] 
(
@StoreID int,
@XML xml
)
as
BEGIN
select x.CustOrderID,x.StoreID, x.OrderID from (
select co.ID as CustOrderID,cosf.StoreID,co.OrderID,row_number() over (partition by co.OrderID order by co.ID DESC) as PART 
from custorder co
join CustOrderStoreFile cosf on co.CustOrderStoreFileID = cosf.ID
join @XML.nodes('ArrayOfInt/int') WarehouseOrderIDs(OrderID) on co.OrderID = WarehouseOrderIDs.OrderID.value('.','int')
where cosf.StoreID = @StoreID
) x
where x.part = 1
END

GO
/****** Object:  StoredProcedure [dbo].[TN_SP_GetOrdersAndAssignmentDetails]    Script Date: 11/30/2020 11:28:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[TN_SP_GetOrdersAndAssignmentDetails] 
(
	@StoreID int,
	@XML xml
)
AS
BEGIN
	DECLARE @tempTable TABLE
	(
		CustOrderID int,
		StoreID int,
		OrderID int
	)
	INSERT INTO @tempTable
	EXEC TN_SP_GetExistingOrders @StoreID, @XML
	SELECT OrderID, WarehouseID, DateAssigned
	FROM @tempTable co
	JOIN CustOrderDetail cod ON (cod.CustOrderID = co.CustOrderID)
	JOIN CustOrderDetailSku cods ON (cods.CustOrderDetailID = cod.ID AND cods.HasBeenUnassigned is null)
	JOIN CustOrderDetailSkuWarehouse codsw ON (codsw.CustOrderDetailSkuID = cods.ID)
	GROUP BY OrderID, WarehouseID, DateAssigned
END