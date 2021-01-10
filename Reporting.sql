USE [${Environment}Reporting]
GO
/****** Object:  Table [dbo].[BrontoArchiveDataPull]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoArchiveDataPull](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[created_date] [datetimeoffset](7) NOT NULL,
	[source_id] [int] NOT NULL,
	[object_name] [varchar](255) NOT NULL,
	[start_date] [datetimeoffset](7) NOT NULL,
	[end_date] [datetimeoffset](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BrontoActivity]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoActivity](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[created_date] [datetimeoffset](7) NOT NULL,
	[source_id] [int] NOT NULL,
	[contact_id] [int] NULL,
	[list_id] [int] NULL,
	[segment_id] [int] NULL,
	[message_id] [int] NULL,
	[delivery_id] [int] NULL,
	[activity_type] [varchar](255) NOT NULL,
	[contact_status] [varchar](255) NULL,
	[archive_data_pull_id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ArchivePullInfo]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ArchivePullInfo] AS

SELECT
	p.id [pull_id], 
	p.created_date [pull_date],
	p.start_date [pull_start],
	p.end_date [pull_end],
	p.source_id [source_id],
	p.object_name [data_object],
	count(*) [activity_records_pulled]
FROM BrontoArchiveDataPull p
	LEFT JOIN BrontoActivity a ON a.archive_data_pull_id = p.id
GROUP BY p.id, p.created_date, p.start_date, p.end_date, p.source_id, p.object_name;
GO
/****** Object:  Table [dbo].[BrontoList]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[created_date] [datetimeoffset](7) NOT NULL,
	[list_id] [varchar](255) NULL,
	[list_name] [varchar](max) NULL,
	[list_label] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BrontoSegment]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoSegment](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[created_date] [datetimeoffset](7) NOT NULL,
	[segment_id] [varchar](255) NULL,
	[segment_name] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BrontoContact]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoContact](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[created_date] [datetimeoffset](7) NOT NULL,
	[contact_id] [varchar](255) NULL,
	[email_address] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BrontoDelivery]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoDelivery](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[created_date] [datetimeoffset](7) NOT NULL,
	[delivery_id] [varchar](255) NULL,
	[delivery_start] [datetimeoffset](7) NULL,
	[delivery_type] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BrontoMessage]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoMessage](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[created_date] [datetimeoffset](7) NOT NULL,
	[message_id] [varchar](255) NULL,
	[message_name] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[ActivityView]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ActivityView] AS
SELECT
	a.id [activity_id],
	a.created_date,
	a.source_id,
	a.activity_type,
	a.contact_status,
	l.list_name,
	l.list_label,
	s.segment_name,
	c.email_address,
	m.message_name,
	d.delivery_start,
	d.delivery_type
FROM BrontoActivity a
LEFT JOIN BrontoContact c ON c.id = a.contact_id
LEFT JOIN BrontoMessage m ON m.id = a.message_id
LEFT JOIN BrontoDelivery d ON d.id = a.delivery_id
LEFT JOIN BrontoList l ON l.id = a.list_id
LEFT JOIN BrontoSegment s ON s.id = a.segment_id;
GO
/****** Object:  Table [dbo].[BrontoBounce]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoBounce](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[activity_id] [int] NULL,
	[bounce_type] [varchar](255) NULL,
	[bounce_reason] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[BounceView]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BounceView] AS
SELECT
	av.activity_id,
	av.created_date,
	av.source_id,
	av.activity_type,
	b.bounce_type,
	b.bounce_reason,
	av.contact_status,
	av.list_name,
	av.list_label,
	av.segment_name,
	av.email_address,
	av.message_name,
	av.delivery_start,
	av.delivery_type
FROM BrontoBounce b
JOIN ActivityView av ON av.activity_id = b.activity_id;
GO
/****** Object:  Table [dbo].[BrontoClick]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoClick](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[activity_id] [int] NULL,
	[link_name] [varchar](max) NULL,
	[link_url] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[ClickView]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ClickView] AS
SELECT
	av.activity_id,
	av.created_date,
	av.source_id,
	av.activity_type,
	c.link_name,
	c.link_url,
	av.contact_status,
	av.list_name,
	av.list_label,
	av.segment_name,
	av.email_address,
	av.message_name,
	av.delivery_start,
	av.delivery_type
FROM BrontoClick c
JOIN ActivityView av ON av.activity_id = c.activity_id;
GO
/****** Object:  Table [dbo].[BrontoConversion]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoConversion](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[activity_id] [int] NULL,
	[order_id] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ConversionView]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ConversionView] AS
SELECT
	av.activity_id,
	av.created_date,
	av.source_id,
	av.activity_type,
	c.order_id,
	av.contact_status,
	av.list_name,
	av.list_label,
	av.segment_name,
	av.email_address,
	av.message_name,
	av.delivery_start,
	av.delivery_type
FROM BrontoConversion c
JOIN ActivityView av ON av.activity_id = c.activity_id;
GO
/****** Object:  Table [dbo].[BrontoUnsubscribe]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoUnsubscribe](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[activity_id] [int] NULL,
	[unsubscribe_method] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[UnsubscribeView]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UnsubscribeView] AS
SELECT
	av.activity_id,
	av.created_date,
	av.source_id,
	av.activity_type,
	u.unsubscribe_method,
	av.contact_status,
	av.list_name,
	av.list_label,
	av.segment_name,
	av.email_address,
	av.message_name,
	av.delivery_start,
	av.delivery_type
FROM BrontoUnsubscribe u
JOIN ActivityView av ON av.activity_id = u.activity_id;
GO
/****** Object:  Table [dbo].[BrontoWebform]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrontoWebform](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[activity_id] [int] NULL,
	[webform_id] [varchar](255) NULL,
	[webform_action] [varchar](255) NULL,
	[webform_name] [varchar](max) NULL,
	[webform_type] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[WebformView]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WebformView] AS
SELECT
	av.activity_id,
	av.created_date,
	av.source_id,
	av.activity_type,
	w.webform_action,
	w.webform_name,
	w.webform_type,
	av.contact_status,
	av.list_name,
	av.list_label,
	av.segment_name,
	av.email_address,
	av.message_name,
	av.delivery_start,
	av.delivery_type
FROM BrontoWebform w
JOIN ActivityView av ON av.activity_id = w.activity_id;
GO
/****** Object:  Table [dbo].[AmendmentCorrelationHistory]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AmendmentCorrelationHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](200) NOT NULL,
	[CorrelationHistoryID] [int] NOT NULL,
	[WhmCorrelationID] [uniqueidentifier] NOT NULL,
	[ExternalCorrelationID] [varchar](1000) NULL,
 CONSTRAINT [PK_AmendmentCorrelationHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AWRKeywordRankingSnapshot]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AWRKeywordRankingSnapshot](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Date] [datetimeoffset](7) NOT NULL,
	[Project] [nvarchar](64) NOT NULL,
	[Keyword] [nvarchar](256) NOT NULL,
	[SearchEngine] [nvarchar](64) NOT NULL,
	[Depth] [int] NULL,
	[Competition] [nvarchar](64) NULL,
	[Location] [nvarchar](64) NULL,
 CONSTRAINT [PK_AWRKeywordRankingSnapshot] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AWRRankData]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AWRRankData](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AWRKeywordRankingSnapshot_ID] [int] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Position] [int] NOT NULL,
	[Page] [int] NULL,
	[Title] [nvarchar](max) NULL,
	[Type] [nvarchar](16) NULL,
	[TypeDescription] [nvarchar](max) NULL,
	[LandingPageUrl] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_AWRRankData] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Brand]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Brand](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](100) NULL,
	[Context] [varchar](100) NULL,
	[BrandCodeForWHM] [varchar](50) NULL,
 CONSTRAINT [PK_Brand] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CorrelationHistory]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CorrelationHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](200) NULL,
	[CorrelationID] [uniqueidentifier] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustomerHistory]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](255) NULL,
	[CustomerID] [int] NOT NULL,
	[TaxExempt] [bit] NOT NULL,
	[CatalogSubscriber] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DiscountHistory]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DiscountHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](50) NULL,
	[Origin] [varchar](100) NULL,
	[PaymentTransactionID] [varchar](200) NULL,
	[PaymentTransactionDate] [datetime] NULL,
	[CorrelationID] [int] NOT NULL,
	[Category] [varchar](25) NULL,
	[Level] [varchar](25) NULL,
	[Name] [varchar](1000) NULL,
	[Code] [varchar](1000) NULL,
	[Sku] [varchar](100) NULL,
	[Amount] [decimal](19, 5) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[Personalization] [varchar](500) NULL,
	[DiscountCode] [varchar](1000) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ExchangeRate]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExchangeRate](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[GBP_to_USD] [decimal](19, 6) NULL,
	[EUR_to_USD] [decimal](19, 6) NULL,
	[EUR_to_GBP] [decimal](19, 6) NULL,
	[AUD_to_USD] [decimal](19, 6) NULL,
	[PublishDate] [datetime] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[DateModified] [datetime] NULL,
 CONSTRAINT [PK_ExchangeRate] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FeeHistory]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeeHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](50) NULL,
	[Origin] [varchar](100) NULL,
	[PaymentTransactionID] [varchar](200) NULL,
	[PaymentTransactionDate] [datetime] NULL,
	[CorrelationID] [int] NOT NULL,
	[Category] [varchar](25) NULL,
	[Level] [varchar](25) NULL,
	[Name] [varchar](1000) NULL,
	[Code] [varchar](1000) NULL,
	[Qty] [int] NOT NULL,
	[Sku] [varchar](100) NULL,
	[Amount] [decimal](19, 5) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[Personalization] [varchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HybrisReportingError]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HybrisReportingError](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [nvarchar](100) NULL,
	[Error] [nvarchar](max) NULL,
	[Payload] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventorySnapshot]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventorySnapshot](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SnapshotID] [varchar](255) NOT NULL,
	[BrandID] [int] NOT NULL,
	[RegionID] [int] NOT NULL,
	[Sku] [varchar](255) NULL,
	[TotalQuantity] [int] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
 CONSTRAINT [PK_InventorySnapshot] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventorySnapshotByWarehouse]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventorySnapshotByWarehouse](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SnapshotID] [varchar](255) NOT NULL,
	[BrandID] [int] NOT NULL,
	[RegionID] [int] NOT NULL,
	[Sku] [varchar](255) NULL,
	[TotalQuantity] [int] NOT NULL,
	[Warehouse] [varchar](255) NULL,
	[WarehouseQuantity] [int] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[WarehouseActive] [bit] NOT NULL,
 CONSTRAINT [PK_InventorySnapshotByWarehouse] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[missingHybrisOrders]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[missingHybrisOrders](
	[Payment Date] [datetime] NULL,
	[OrderNum] [nvarchar](255) NULL,
	[email address] [nvarchar](255) NULL,
	[Trans ID] [nvarchar](255) NULL,
	[Pay Amount] [money] NULL,
	[F6] [nvarchar](255) NULL,
	[Payment Method] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderAllocationDetailHistory]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderAllocationDetailHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NULL,
	[Origin] [varchar](100) NULL,
	[WarehouseRefNum] [varchar](100) NULL,
	[Category] [varchar](25) NULL,
	[Level] [varchar](25) NULL,
	[PaymentTransactionID] [varchar](200) NULL,
	[PaymentTransactionDate] [datetime] NULL,
	[CorrelationID] [int] NOT NULL,
	[Sku] [varchar](100) NULL,
	[Upc] [varchar](100) NULL,
	[WarehouseID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[DateDelivered] [datetime] NULL,
	[DateAllocated] [datetime] NULL,
	[Status] [varchar](50) NULL,
	[ShippingMethodID] [varchar](100) NOT NULL,
	[Options] [varchar](255) NULL,
	[WarehouseShipMethod] [varchar](100) NOT NULL,
	[CarrierCode] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderDetailHistory]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderDetailHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NULL,
	[Origin] [varchar](100) NULL,
	[DateEntered] [datetime] NOT NULL,
	[Category] [varchar](25) NULL,
	[Level] [varchar](25) NULL,
	[PaymentTransactionID] [varchar](200) NULL,
	[PaymentTransactionDate] [datetime] NULL,
	[CorrelationID] [int] NOT NULL,
	[Sku] [varchar](100) NULL,
	[Quantity] [int] NOT NULL,
	[ProductPrice] [decimal](19, 5) NOT NULL,
	[TotalPriceOfProductOrdered] [decimal](19, 5) NULL,
	[ProductName] [varchar](1000) NULL,
	[TaxableProduct] [bit] NOT NULL,
	[Personalization] [varchar](max) NULL,
	[Status] [varchar](50) NULL,
	[PersonalizationFee] [decimal](19, 5) NULL,
	[ProductType] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderExchangeRate]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderExchangeRate](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NULL,
	[CorrelationID] [int] NOT NULL,
	[ExchangeRateID] [int] NOT NULL,
 CONSTRAINT [PK_OrderExchangeRate] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderHistory]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[StoreCode] [varchar](20) NULL,
	[SourceRefNum] [varchar](200) NULL,
	[Origin] [varchar](100) NULL,
	[Category] [varchar](100) NULL,
	[Level] [varchar](25) NULL,
	[CustomerID] [varchar](255) NULL,
	[DateEntered] [datetime] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[OrderType] [varchar](50) NULL,
	[ShippingMethodID] [varchar](100) NOT NULL,
	[BillingFirstName] [varchar](100) NULL,
	[BillingLastName] [varchar](100) NULL,
	[BillingPhoneNumber] [varchar](100) NULL,
	[BillingAddress1] [varchar](200) NULL,
	[BillingAddress2] [varchar](200) NULL,
	[BillingCity] [varchar](100) NULL,
	[BillingState] [varchar](100) NULL,
	[BillingPostalCode] [varchar](1000) NULL,
	[BillingCountry] [varchar](100) NULL,
	[BillingCompanyName] [varchar](200) NULL,
	[BillingResidential] [bit] NOT NULL,
	[ShipFirstName] [varchar](100) NULL,
	[ShipLastName] [varchar](100) NULL,
	[ShipPhoneNumber] [varchar](100) NULL,
	[ShipAddress1] [varchar](200) NULL,
	[ShipAddress2] [varchar](200) NULL,
	[ShipCity] [varchar](100) NULL,
	[ShipState] [varchar](100) NULL,
	[ShipPostalCode] [varchar](1000) NULL,
	[ShipCountry] [varchar](100) NULL,
	[ShipCompanyName] [varchar](200) NULL,
	[ShipResidential] [bit] NOT NULL,
	[PaymentTransactionID] [varchar](200) NULL,
	[PaymentTransactionDate] [datetime] NULL,
	[CorrelationID] [int] NOT NULL,
	[TotalShippingCost] [decimal](19, 5) NULL,
	[PaymentAmount] [decimal](19, 5) NULL,
	[Total_Payment_Authorized] [decimal](19, 5) NULL,
	[Total_Payment_Received] [decimal](19, 5) NULL,
	[TaxExempt] [bit] NOT NULL,
	[Currency] [varchar](50) NULL,
	[OrderNotes] [varchar](max) NULL,
	[OrderStatus] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[OriginalOrderNumber] [varchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderStatus]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderStatus](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](255) NULL,
	[CurrentOrderStatus] [varchar](255) NULL,
	[CurrentSalesforceStatus] [varchar](255) NULL,
	[DateEntered] [datetime] NOT NULL,
	[DateModified] [datetime] NULL,
 CONSTRAINT [PK_OrderStatus] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PaymentLogHistory]    Script Date: 11/30/2020 11:32:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PaymentLogHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NULL,
	[CorrelationID] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
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
	[CC_Last4] [varchar](100) NULL,
	[LastModifiedDate] [datetime] NULL,
	[Currency] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Platform]    Script Date: 11/30/2020 11:32:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Platform](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NULL,
 CONSTRAINT [PK_Platform] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReconSnapshotDetail]    Script Date: 11/30/2020 11:32:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReconSnapshotDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ReconciliationID] [datetime] NOT NULL,
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[RegionID] [int] NOT NULL,
	[Sku] [nvarchar](255) NOT NULL,
	[NewQty] [int] NOT NULL,
	[WHMAdjustmentForSku] [int] NOT NULL,
	[GroupNumber] [int] NOT NULL,
	[QtyAvailableForGroup] [int] NOT NULL,
	[Lot] [int] NOT NULL,
	[QtyAvailableForLot] [int] NOT NULL,
	[Upc] [nvarchar](255) NOT NULL,
	[AllocationPercentageForSku] [int] NOT NULL,
	[TotalQtyAvailableForUpc] [int] NOT NULL,
	[WarehouseWHMAdjustmentsForUpc] [int] NOT NULL,
	[QtyToAllocateToSku] [int] NOT NULL,
	[Warehouse] [nvarchar](255) NOT NULL,
	[WarehouseQty] [int] NOT NULL,
	[WarehouseHoldQty] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[WarehouseActualHoldQty] [int] NOT NULL,
	[WarehouseActualQty] [int] NOT NULL,
 CONSTRAINT [PK_ReconSnapshotDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReconSnapshotSummary]    Script Date: 11/30/2020 11:32:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReconSnapshotSummary](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ReconciliationID] [datetime] NOT NULL,
	[SourceID] [int] NOT NULL,
	[BrandID] [int] NOT NULL,
	[RegionID] [int] NOT NULL,
	[Sku] [nvarchar](255) NOT NULL,
	[NewQty] [int] NOT NULL,
	[OldQty] [int] NOT NULL,
	[WHMAdjustments] [int] NOT NULL,
	[StoreAdjustments] [int] NOT NULL,
 CONSTRAINT [PK_ReconSnapshotSummary] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Source]    Script Date: 11/30/2020 11:32:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Source](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PlatformID] [int] NOT NULL,
	[Name] [varchar](100) NULL,
	[BrandID] [int] NOT NULL,
 CONSTRAINT [PK_Source] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StagedOffset]    Script Date: 11/30/2020 11:32:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StagedOffset](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](200) NULL,
	[Origin] [varchar](100) NULL,
	[Category] [varchar](50) NULL,
	[Level] [varchar](50) NULL,
	[Code] [varchar](1000) NULL,
	[Name] [varchar](1000) NULL,
	[Amount] [decimal](19, 5) NOT NULL,
	[Qty] [int] NOT NULL,
	[Sku] [varchar](50) NULL,
	[DateEntered] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[stagedOffsetBackUp]    Script Date: 11/30/2020 11:32:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stagedOffsetBackUp](
	[ID] [int] NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](200) NULL,
	[Origin] [varchar](100) NULL,
	[Category] [varchar](50) NULL,
	[Level] [varchar](50) NULL,
	[Code] [varchar](1000) NULL,
	[Name] [varchar](1000) NULL,
	[Amount] [decimal](19, 5) NOT NULL,
	[Qty] [int] NOT NULL,
	[Sku] [varchar](50) NULL,
	[DateEntered] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StagedPaymentLogHistory]    Script Date: 11/30/2020 11:32:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StagedPaymentLogHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[PaymentID] [varchar](100) NULL,
	[TransactionID] [varchar](255) NULL,
	[PaymentMethodID] [varchar](100) NULL,
	[AuthorizationCode] [varchar](255) NULL,
	[PaymentType] [varchar](255) NULL,
	[AVS_Response] [varchar](255) NULL,
	[CVV2_Response] [varchar](255) NULL,
	[PaymentAmount] [money] NOT NULL,
	[PaymentDetails] [varchar](255) NULL,
	[IsDeleted] [bit] NOT NULL,
	[PaymentDate] [datetime] NOT NULL,
	[ParentTransactionID] [varchar](255) NULL,
	[CC_Last4] [varchar](100) NULL,
	[Currency] [varchar](50) NULL,
 CONSTRAINT [PK_StagedPaymentLogHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TaxHistory]    Script Date: 11/30/2020 11:32:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaxHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](50) NULL,
	[Origin] [varchar](100) NULL,
	[Category] [varchar](25) NULL,
	[Level] [varchar](25) NULL,
	[PaymentTransactionID] [varchar](200) NULL,
	[PaymentTransactionDate] [datetime] NULL,
	[CorrelationID] [int] NOT NULL,
	[Name] [varchar](250) NULL,
	[TotalAmount] [decimal](19, 5) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[Code] [varchar](50) NULL,
	[Personalization] [varchar](500) NULL,
	[Quantity] [int] NOT NULL,
	[Amount] [decimal](19, 5) NOT NULL,
	[IsOffset] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tempStagedOffset]    Script Date: 11/30/2020 11:32:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempStagedOffset](
	[ID] [int] NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](200) NULL,
	[Origin] [varchar](100) NULL,
	[Category] [varchar](50) NULL,
	[Level] [varchar](50) NULL,
	[Code] [varchar](1000) NULL,
	[Name] [varchar](1000) NULL,
	[Amount] [decimal](19, 5) NOT NULL,
	[Qty] [int] NOT NULL,
	[Sku] [varchar](50) NULL,
	[DateEntered] [datetime] NOT NULL,
	[SequenceID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TmsRateRequest]    Script Date: 11/30/2020 11:32:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TmsRateRequest](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](200) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Upc] [varchar](200) NOT NULL,
	[Qty] [int] NOT NULL,
	[IonShippingMethod] [varchar](100) NOT NULL,
	[ProShipShippingMethod] [varchar](200) NOT NULL,
	[ShippingTotal] [decimal](19, 5) NOT NULL,
	[Surcharge] [decimal](19, 5) NOT NULL,
	[ListCost] [decimal](19, 5) NOT NULL,
	[Discount] [decimal](19, 5) NOT NULL,
	[CommitmentTime] [int] NOT NULL,
	[Height] [float] NULL,
	[Width] [float] NULL,
	[Length] [float] NULL,
	[Weight] [float] NULL,
	[RateGroup] [varchar](255) NULL,
	[ResidentialFlag] [varchar](255) NULL,
	[CreatedAt] [datetime] NULL,
	[OrderID] [int] NULL,
	[ProshipRequest] [bit] NULL,
 CONSTRAINT [PK_ProShipRateRequest] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TrackingNumberHistory]    Script Date: 11/30/2020 11:32:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrackingNumberHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NULL,
	[WarehouseRefNum] [varchar](100) NULL,
	[WarehouseID] [int] NOT NULL,
	[Upc] [varchar](100) NULL,
	[TrackingNumber] [varchar](100) NULL,
	[DateShipped] [datetime] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[ShippingMethodID] [varchar](50) NULL,
 CONSTRAINT [PK_TrackingNumberHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VersionInfo]    Script Date: 11/30/2020 11:32:31 AM ******/
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
/****** Object:  Index [UC_Version]    Script Date: 11/30/2020 11:32:31 AM ******/
CREATE UNIQUE CLUSTERED INDEX [UC_Version] ON [dbo].[VersionInfo]
(
	[Version] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PaymentLogHistory] ADD  CONSTRAINT [DF_PaymentLogHistory_DateEntered]  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[StagedPaymentLogHistory] ADD  CONSTRAINT [DF_StagedPaymentLogHistory_DateEntered]  DEFAULT (getdate()) FOR [DateEntered]
GO
ALTER TABLE [dbo].[AWRRankData]  WITH CHECK ADD  CONSTRAINT [FK_AWRRankData_AWRKeywordRankingSnapshot_ID_AWRKeywordRankingSnapshot_ID] FOREIGN KEY([AWRKeywordRankingSnapshot_ID])
REFERENCES [dbo].[AWRKeywordRankingSnapshot] ([ID])
GO
ALTER TABLE [dbo].[AWRRankData] CHECK CONSTRAINT [FK_AWRRankData_AWRKeywordRankingSnapshot_ID_AWRKeywordRankingSnapshot_ID]
GO
ALTER TABLE [dbo].[BrontoActivity]  WITH CHECK ADD FOREIGN KEY([archive_data_pull_id])
REFERENCES [dbo].[BrontoArchiveDataPull] ([id])
GO
ALTER TABLE [dbo].[BrontoActivity]  WITH CHECK ADD FOREIGN KEY([contact_id])
REFERENCES [dbo].[BrontoContact] ([id])
GO
ALTER TABLE [dbo].[BrontoActivity]  WITH CHECK ADD FOREIGN KEY([delivery_id])
REFERENCES [dbo].[BrontoDelivery] ([id])
GO
ALTER TABLE [dbo].[BrontoActivity]  WITH CHECK ADD FOREIGN KEY([list_id])
REFERENCES [dbo].[BrontoList] ([id])
GO
ALTER TABLE [dbo].[BrontoActivity]  WITH CHECK ADD FOREIGN KEY([message_id])
REFERENCES [dbo].[BrontoMessage] ([id])
GO
ALTER TABLE [dbo].[BrontoActivity]  WITH CHECK ADD FOREIGN KEY([segment_id])
REFERENCES [dbo].[BrontoSegment] ([id])
GO
ALTER TABLE [dbo].[BrontoBounce]  WITH CHECK ADD FOREIGN KEY([activity_id])
REFERENCES [dbo].[BrontoActivity] ([id])
GO
ALTER TABLE [dbo].[BrontoClick]  WITH CHECK ADD FOREIGN KEY([activity_id])
REFERENCES [dbo].[BrontoActivity] ([id])
GO
ALTER TABLE [dbo].[BrontoConversion]  WITH CHECK ADD FOREIGN KEY([activity_id])
REFERENCES [dbo].[BrontoActivity] ([id])
GO
ALTER TABLE [dbo].[BrontoUnsubscribe]  WITH CHECK ADD FOREIGN KEY([activity_id])
REFERENCES [dbo].[BrontoActivity] ([id])
GO
ALTER TABLE [dbo].[BrontoWebform]  WITH CHECK ADD FOREIGN KEY([activity_id])
REFERENCES [dbo].[BrontoActivity] ([id])
GO
/****** Object:  StoredProcedure [dbo].[RunOrderBalanceDetailReport]    Script Date: 11/30/2020 11:32:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[RunOrderBalanceDetailReport]
	-- Add the parameters for the stored procedure here
	@sourceRefNum varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    select *
	from
	(
		select 1 identifier, id, storecode, sourcerefnum, CorrelationID,'Shipping' recordtype,case when category = 'Processing' then '' else category end category, level,'' code, '' as sku, null quantity, null Price, TotalShippingCost Total, dateentered datetoorderby from OrderHistory
		union
		select 2 identifier, a.id,'' storecode, a.sourcerefnum, a.CorrelationID,'LineItem', case when a.category = 'Processing' then '' else a.category end, a.level,'', a.sku, a.quantity, case when b.amount is null then productprice else ProductPrice - b.amount end price, a.quantity * case when b.amount is null then productprice else ProductPrice - b.amount end total, a.dateentered datetoorderby
		from OrderDetailHistory a
		left join TaxHistory b on a.CorrelationID = b.CorrelationID and a.sku = b.Code and a.personalization = b.personalization and b.SourceID in (26) and b.isoffset = case when a.Category in ('offset', 'return') then 1 else b.isoffset end and b.category = case when a.category in ('offset', 'return') then 'processing' else a.category end
		union
		select 3 identifier, id,'' storecode, sourcerefnum, CorrelationID,'Tax' + case when isoffset = 1 then ' Offset' else '' end, case when category = 'Processing' then '' else category end, level, name, Code, quantity, null productprice, quantity * amount, DateEntered datetoorderby from TaxHistory
		union
		select 4 identifier, id,'' storecode, sourcerefnum, CorrelationID,'Discount', case when category = 'Processing' then '' else category end, level, code, sku, 1 quantity, null productprice, amount, DateEntered datetoorderby from DiscountHistory
		union
		select 5 identifier, id,'' storecode, sourcerefnum, CorrelationID,'Fee', case when category = 'Processing' then '' else category end, level, code, sku, qty, amount, (qty * amount), DateEntered datetoorderby from FeeHistory
		union
		select 6 identifier, id,'' storecode, sourcerefnum, CorrelationID,'PaymentLog','', '' level, '', '' sku, null quantity, null productprice, -paymentamount, DateEntered datetoorderby from paymentlogHistory
	) a
	where a.SourceRefNum = @sourceRefNum
	order by a.sourcerefnum, a.correlationid, a.identifier, a.id
END
GO
/****** Object:  StoredProcedure [dbo].[RunOrderBalanceSummaryReport]    Script Date: 11/30/2020 11:32:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[RunOrderBalanceSummaryReport]
	-- Add the parameters for the stored procedure here
	@sourceRefNum varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    select SourceRefNum, sum(total) Balance
	from
	(
		select *
		from
		(
			select 1 identifier, id, storecode, sourcerefnum, CorrelationID,'Shipping' recordtype,case when category = 'Processing' then '' else category end category, level,'' code, '' as sku, null quantity, null Price, TotalShippingCost Total, dateentered datetoorderby from OrderHistory
			union
			select 2 identifier, a.id,'' storecode, a.sourcerefnum, a.CorrelationID,'LineItem', case when a.category = 'Processing' then '' else a.category end, a.level,'', a.sku, a.quantity, case when b.amount is null then productprice else ProductPrice - b.amount end price, a.quantity * case when b.amount is null then productprice else ProductPrice - b.amount end total, a.dateentered datetoorderby
			from OrderDetailHistory a
			left join TaxHistory b on a.CorrelationID = b.CorrelationID and a.sku = b.Code and a.personalization = b.personalization and b.SourceID in (26) and b.isoffset = case when a.Category in ('offset', 'return') then 1 else b.isoffset end and b.category = case when a.category in ('offset', 'return') then 'processing' else a.category end
			union
			select 3 identifier, id,'' storecode, sourcerefnum, CorrelationID,'Tax' + case when isoffset = 1 then ' Offset' else '' end, case when category = 'Processing' then '' else category end, level, name, Code, quantity, null productprice, quantity * amount, DateEntered datetoorderby from TaxHistory
			union
			select 4 identifier, id,'' storecode, sourcerefnum, CorrelationID,'Discount', case when category = 'Processing' then '' else category end, level, code, sku, 1 quantity, null productprice, amount, DateEntered datetoorderby from DiscountHistory
			union
			select 5 identifier, id,'' storecode, sourcerefnum, CorrelationID,'Fee', case when category = 'Processing' then '' else category end, level, code, sku, qty, amount, (qty * amount), DateEntered datetoorderby from FeeHistory
			union
			select 6 identifier, id,'' storecode, sourcerefnum, CorrelationID,'PaymentLog','', '' level, '', '' sku, null quantity, null productprice, -paymentamount, DateEntered datetoorderby from paymentlogHistory
	   ) a
	) b
	where b.CorrelationID in (select id from CorrelationHistory where sourcerefnum = @sourceRefNum)
	group by b.SourceRefNum
END
GO