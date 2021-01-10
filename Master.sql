USE [${Environment}WarehouseManager]
GO
/****** Object:  Table [dbo].[ApiVendor]    Script Date: 11/30/2020 11:23:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApiVendor](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Key] [uniqueidentifier] NOT NULL,
	[VendorName] [varchar](255) NOT NULL,
	[Active] [bit] NOT NULL,
 CONSTRAINT [PK_WHM_ApiVendor] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ApiVendorSession]    Script Date: 11/30/2020 11:23:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApiVendorSession](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ApiVendorID] [int] NOT NULL,
	[Token] [uniqueidentifier] NOT NULL,
	[IssuedDate] [datetime] NOT NULL,
	[ExpiryDate] [datetime] NOT NULL,
 CONSTRAINT [PK_WHM_ApiVendorSession] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetPermission]    Script Date: 11/30/2020 11:23:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetPermission](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[PermissionGroupID] [int] NULL,
 CONSTRAINT [PK_AspNetPermission] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetPermissionGroup]    Script Date: 11/30/2020 11:23:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetPermissionGroup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_AspNetPermissionGroup] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetPermissionRoleAssociation]    Script Date: 11/30/2020 11:23:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetPermissionRoleAssociation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PermissionID] [int] NOT NULL,
	[RoleID] [varchar](255) NOT NULL,
	[Active] [bit] NOT NULL,
 CONSTRAINT [PK_AspNetPermissionRoleAssociation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetRoleClaims]    Script Date: 11/30/2020 11:23:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetRoleClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
	[RoleId] [nvarchar](450) NOT NULL,
 CONSTRAINT [PK_AspNetRoleClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetRoles]    Script Date: 11/30/2020 11:23:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetRoles](
	[Id] [nvarchar](450) NOT NULL,
	[ConcurrencyStamp] [nvarchar](max) NULL,
	[Name] [nvarchar](256) NULL,
	[NormalizedName] [nvarchar](256) NULL,
 CONSTRAINT [PK_AspNetRoles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUserClaims]    Script Date: 11/30/2020 11:23:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
	[UserId] [nvarchar](450) NOT NULL,
 CONSTRAINT [PK_AspNetUserClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUserLogins]    Script Date: 11/30/2020 11:23:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserLogins](
	[LoginProvider] [nvarchar](450) NOT NULL,
	[ProviderKey] [nvarchar](450) NOT NULL,
	[ProviderDisplayName] [nvarchar](max) NULL,
	[UserId] [nvarchar](450) NOT NULL,
 CONSTRAINT [PK_AspNetUserLogins] PRIMARY KEY CLUSTERED 
(
	[LoginProvider] ASC,
	[ProviderKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUserRoles]    Script Date: 11/30/2020 11:23:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserRoles](
	[UserId] [nvarchar](450) NOT NULL,
	[RoleId] [nvarchar](450) NOT NULL,
 CONSTRAINT [PK_AspNetUserRoles] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUsers]    Script Date: 11/30/2020 11:23:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUsers](
	[Id] [nvarchar](450) NOT NULL,
	[AccessFailedCount] [int] NOT NULL,
	[ConcurrencyStamp] [nvarchar](max) NULL,
	[Email] [nvarchar](256) NULL,
	[EmailConfirmed] [bit] NOT NULL,
	[LockoutEnabled] [bit] NOT NULL,
	[LockoutEnd] [datetimeoffset](7) NULL,
	[NormalizedEmail] [nvarchar](256) NULL,
	[NormalizedUserName] [nvarchar](256) NULL,
	[PasswordHash] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](max) NULL,
	[PhoneNumberConfirmed] [bit] NOT NULL,
	[SecurityStamp] [nvarchar](max) NULL,
	[TwoFactorEnabled] [bit] NOT NULL,
	[UserName] [nvarchar](256) NULL,
 CONSTRAINT [PK_AspNetUsers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUserTokens]    Script Date: 11/30/2020 11:23:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserTokens](
	[UserId] [nvarchar](450) NOT NULL,
	[LoginProvider] [nvarchar](450) NOT NULL,
	[Name] [nvarchar](450) NOT NULL,
	[Value] [nvarchar](max) NULL,
 CONSTRAINT [PK_AspNetUserTokens] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[LoginProvider] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Brand]    Script Date: 11/30/2020 11:23:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Brand](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](50) NOT NULL,
	[Context] [varchar](20) NOT NULL,
	[BrandCodeForWHM] [varchar](100) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[EIN] [varchar](50) NULL,
	[CommercialInvoiceDirectory] [varchar](max) NOT NULL,
	[SalesforceAccountID] [nvarchar](50) NULL,
	[Country] [varchar](100) NOT NULL,
	[BrontoName] [varchar](100) NULL,
	[NarvarURL] [varchar](255) NULL,
 CONSTRAINT [PK_Brand] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Carrier]    Script Date: 11/30/2020 11:23:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Carrier](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CarrierName] [varchar](255) NOT NULL,
	[NarvarCarrier] [varchar](255) NULL,
	[CarrierCode] [varchar](255) NULL,
	[Active] [bit] NULL,
	[RegionID] [int] NULL,
	[ProshipEnabled] [bit] NULL,
	[PeakStart] [date] NULL,
	[PeakEnd] [date] NULL,
	[PeakFee] [float] NULL,
 CONSTRAINT [PK_Carrier] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CarrierDestination]    Script Date: 11/30/2020 11:23:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CarrierDestination](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CarrierID] [int] NOT NULL,
	[DestinationType] [int] NOT NULL,
 CONSTRAINT [PK_CarrierDestination] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CarrierShipMethod]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CarrierShipMethod](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ShipMethodID] [int] NOT NULL,
	[Operator] [int] NOT NULL,
	[Threshold] [float] NULL,
	[DimmedDivisor] [int] NULL,
	[SCAC] [varchar](255) NULL,
	[CarrierID] [int] NOT NULL,
 CONSTRAINT [PK_CarrierShipMethod] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CarrierShipZone]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CarrierShipZone](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CarrierID] [int] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[Zone] [varchar](255) NOT NULL,
 CONSTRAINT [PK_CarrierShipZone] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CarrierTrackingNumber]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CarrierTrackingNumber](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CarrierID] [int] NOT NULL,
	[Pattern] [varchar](255) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
 CONSTRAINT [PK_CarrierTrackingNumber] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CarrierUpc]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CarrierUpc](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Upc] [varchar](255) NOT NULL,
	[CarrierID] [int] NOT NULL,
 CONSTRAINT [PK_CarrierUpc] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CarrierWarehouse]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CarrierWarehouse](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[CarrierID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[CarrierWarehouseCode] [nvarchar](255) NULL,
	[Priority] [int] NOT NULL,
 CONSTRAINT [PK_CarrierWarehouse] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CarrierWarehouseShipMethod]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CarrierWarehouseShipMethod](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ShipMethodID] [int] NOT NULL,
	[CarrierWarehouseID] [int] NOT NULL,
	[Operator] [int] NOT NULL,
	[Threshold] [float] NULL,
	[DimmedDivisor] [int] NULL,
 CONSTRAINT [PK_CarrierWarehouseShipMethod] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CategoryStatusCode]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CategoryStatusCode](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StatusCodeID] [int] NOT NULL,
	[StatusCategoryID] [int] NOT NULL,
 CONSTRAINT [PK_CategoryStatusCode] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CountryCode_LU]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryCode_LU](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Country] [varchar](200) NOT NULL,
	[CountryCode] [varchar](50) NOT NULL,
	[CurrencyCode] [varchar](50) NOT NULL,
	[Primary] [bit] NOT NULL,
	[CountryCodeA3] [varchar](50) NOT NULL,
	[IsISOStandard] [bit] NOT NULL,
	[WHMCurrencyCode] [varchar](10) NOT NULL,
	[IsHybris] [bit] NULL,
 CONSTRAINT [PK_CountryCode_LU] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DestinationType]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DestinationType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](255) NOT NULL,
	[Description] [varchar](255) NULL,
 CONSTRAINT [PK_DestinationType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HybrisRouted]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HybrisRouted](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceRefNum] [varchar](200) NULL,
	[HybrisVirtualHostID] [int] NOT NULL,
	[MessageType] [varchar](100) NOT NULL,
 CONSTRAINT [PK_HybrisRouted] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HybrisVirtualHost]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HybrisVirtualHost](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](max) NOT NULL,
	[URI] [varchar](max) NULL,
	[Active] [bit] NOT NULL,
	[Default] [bit] NOT NULL,
	[Username] [varchar](200) NULL,
	[Password] [varchar](200) NULL,
	[Reserved] [bit] NOT NULL,
 CONSTRAINT [PK_HybrisVirtualHost] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HybrisWarehouse]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HybrisWarehouse](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WarehouseCode] [varchar](500) NOT NULL,
	[RegionID] [int] NOT NULL,
 CONSTRAINT [PK_HybrisWarehouse] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InternationalSource]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InternationalSource](
	[ID] [int] NOT NULL,
	[StoreID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[BrandID] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InternationalSourceOrderLineItem]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InternationalSourceOrderLineItem](
	[ID] [int] NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[ShippingMethodID] [varchar](255) NOT NULL,
	[ShipFirstName] [varchar](100) NOT NULL,
	[ShipLastName] [varchar](100) NOT NULL,
	[ShipPhoneNumber] [varchar](100) NOT NULL,
	[ShipCompanyName] [varchar](100) NOT NULL,
	[ShipAddress1] [varchar](200) NOT NULL,
	[ShipAddress2] [varchar](200) NOT NULL,
	[ShipCity] [varchar](100) NOT NULL,
	[ShipState] [varchar](100) NOT NULL,
	[ShipPostalCode] [varchar](100) NOT NULL,
	[ShipCountry] [varchar](100) NOT NULL,
	[ShipResidential] [varchar](100) NOT NULL,
	[OrderDate] [varchar](100) NOT NULL,
	[DeletedOn] [smalldatetime] NULL,
	[DeletedBy] [varchar](100) NULL,
	[GST] [decimal](19, 5) NULL,
	[PST] [decimal](19, 5) NULL,
	[HST] [decimal](19, 5) NULL,
	[OrderStatus] [varchar](50) NULL,
	[DateLoaded] [smalldatetime] NULL,
	[Sku] [varchar](100) NOT NULL,
	[Qty] [int] NOT NULL,
	[Price] [money] NOT NULL,
	[LastModified] [smalldatetime] NULL,
	[OrderID] [int] NOT NULL,
	[IsReroute] [bit] NULL,
	[IsResend] [bit] NULL,
	[Options] [varchar](max) NULL,
	[CustomerID] [varchar](50) NULL,
	[PreferredShipDate] [smalldatetime] NULL,
	[SendToWarehouseDate] [smalldatetime] NULL,
	[OrderType] [varchar](50) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryDiscrepancy]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryDiscrepancy](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RegionID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Upc] [varchar](200) NOT NULL,
	[Qty] [int] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[Comments] [varchar](max) NULL,
	[Action] [varchar](100) NULL,
	[ApprovedBy] [varchar](200) NULL,
	[DateApproved] [datetime] NULL,
	[Archived] [bit] NOT NULL,
	[IncludedInStoreUpdate] [datetime] NULL,
	[StatusCodeID] [int] NULL,
	[ExpectedQty] [int] NOT NULL,
	[ActualQty] [int] NOT NULL,
	[IncludedInIR] [datetime] NULL,
 CONSTRAINT [PK_InventoryDiscrepancy] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryExpectedReceipt]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryExpectedReceipt](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RegionID] [int] NOT NULL,
	[Sku] [varchar](100) NOT NULL,
	[Qty] [int] NOT NULL,
	[InventoryPackingListSummaryID] [int] NOT NULL,
	[BackupQty] [int] NULL,
	[DateExpected] [datetime] NULL,
	[DateModified] [datetime] NULL,
 CONSTRAINT [PK_InventoryExpectedReceipt] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryLedger]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryLedger](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BrandID] [int] NULL,
	[PlatformID] [int] NULL,
	[SourceID] [int] NULL,
	[RegionID] [int] NULL,
	[WarehouseID] [int] NOT NULL,
	[Event] [varchar](100) NOT NULL,
	[SourceRefNum] [varchar](100) NULL,
	[Sku] [varchar](100) NULL,
	[Upc] [varchar](100) NOT NULL,
	[Qty] [int] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[Notes] [varchar](max) NULL,
 CONSTRAINT [PK_InventoryLedger] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryPackingList]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryPackingList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StoreSku] [varchar](100) NOT NULL,
	[Upc] [varchar](100) NOT NULL,
	[Qty] [int] NOT NULL,
	[Weight] [varchar](50) NULL,
	[CBM] [decimal](19, 5) NULL,
	[CartonNumber] [varchar](50) NOT NULL,
	[UnitCost] [decimal](19, 5) NULL,
	[ProductDescription] [varchar](255) NOT NULL,
	[Length] [varchar](50) NULL,
	[Width] [varchar](50) NULL,
	[Height] [varchar](50) NULL,
	[InvoiceID] [varchar](100) NOT NULL,
	[InvoiceDate] [datetime] NOT NULL,
	[Vessel] [varchar](100) NULL,
	[OriginPort] [varchar](2000) NOT NULL,
	[DestinationPort] [varchar](2000) NOT NULL,
	[VoyageID] [varchar](100) NOT NULL,
	[DepartureDate] [datetime] NOT NULL,
	[CargoReceivedDate] [datetime] NOT NULL,
	[Notes] [varchar](500) NULL,
	[Vendor] [varchar](2000) NOT NULL,
	[BillOfLading] [varchar](100) NOT NULL,
	[TransportMode] [varchar](50) NULL,
	[ContainerNumber] [varchar](100) NOT NULL,
	[SealNumber] [varchar](100) NULL,
	[SO_Number] [varchar](100) NULL,
	[WarehouseID] [int] NULL,
	[PreviousWarehouseID] [int] NULL,
	[RerouteDate] [datetime] NULL,
	[InventoryReleaseID] [int] NOT NULL,
	[InventoryPackingListSummaryID] [int] NOT NULL,
 CONSTRAINT [PK_InventoryPackingList] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryPackingListHistory]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryPackingListHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StoreSku] [varchar](100) NOT NULL,
	[Upc] [varchar](100) NOT NULL,
	[Qty] [int] NOT NULL,
	[Weight] [varchar](50) NULL,
	[CBM] [decimal](19, 5) NULL,
	[CartonNumber] [varchar](50) NOT NULL,
	[UnitCost] [decimal](19, 5) NULL,
	[ProductDescription] [varchar](255) NOT NULL,
	[Length] [varchar](50) NULL,
	[Width] [varchar](50) NULL,
	[Height] [varchar](50) NULL,
	[InvoiceID] [varchar](100) NOT NULL,
	[InvoiceDate] [datetime] NOT NULL,
	[Vessel] [varchar](100) NULL,
	[OriginPort] [varchar](2000) NOT NULL,
	[DestinationPort] [varchar](2000) NOT NULL,
	[VoyageID] [varchar](100) NOT NULL,
	[DepartureDate] [datetime] NOT NULL,
	[CargoReceivedDate] [datetime] NOT NULL,
	[Notes] [varchar](500) NULL,
	[Vendor] [varchar](2000) NOT NULL,
	[BillOfLading] [varchar](100) NOT NULL,
	[TransportMode] [varchar](50) NULL,
	[ContainerNumber] [varchar](100) NOT NULL,
	[SealNumber] [varchar](100) NULL,
	[SO_Number] [varchar](100) NULL,
	[WarehouseID] [int] NULL,
	[PreviousWarehouseID] [int] NULL,
	[RerouteDate] [datetime] NULL,
	[InventoryReleaseID] [int] NOT NULL,
	[InventoryPackingListSummaryID] [int] NOT NULL,
	[LengthInInches]  AS (case when [Length] IS NOT NULL then CONVERT([float],[Length])/(2.54) else (0.00) end),
	[WidthInInches]  AS (case when [Width] IS NOT NULL then CONVERT([float],[Width])/(2.54) else (0.00) end),
	[HeightInInches]  AS (case when [Height] IS NOT NULL then CONVERT([float],[Height])/(2.54) else (0.00) end),
	[WeightInPounds]  AS (case when [Weight] IS NOT NULL then CONVERT([float],[Weight])*(2.2046) else (0.00) end)
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryPackingListSummary]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryPackingListSummary](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[File] [varchar](max) NOT NULL,
	[InvoiceID] [varchar](100) NOT NULL,
	[InvoiceDate] [datetime] NOT NULL,
	[DateLoaded] [datetime] NOT NULL,
	[InventoryReleaseID] [int] NOT NULL,
	[DeletedDate] [datetime] NULL,
	[Notes] [varchar](2000) NULL,
 CONSTRAINT [PK_InventoryPackingListSummary] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryRelease]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryRelease](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DateLoaded] [datetime] NOT NULL,
	[User] [varchar](200) NULL,
	[Name] [varchar](255) NOT NULL,
	[SourcingCategoryID] [int] NULL,
	[Notes] [varchar](200) NULL,
 CONSTRAINT [PK_InventorySourcingFile] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryWarehouseReceipt]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryWarehouseReceipt](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DateReceived] [datetime] NULL,
	[WarehouseID] [int] NOT NULL,
	[InventoryReleaseID] [int] NOT NULL,
	[InventoryPackingListSummaryID] [int] NOT NULL,
	[ContainerNumber] [varchar](100) NOT NULL,
 CONSTRAINT [PK_InventoryWarehouseReceipt] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryWarehouseReceiptDetail]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryWarehouseReceiptDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Upc] [varchar](100) NOT NULL,
	[ExpectedQty] [int] NOT NULL,
	[ReceivedQty] [int] NULL,
	[InventoryWarehouseReceiptID] [int] NOT NULL,
	[DiscrepancyReason] [varchar](max) NULL,
	[PackingListID] [int] NULL,
	[IncludedInIR] [datetime] NULL,
 CONSTRAINT [PK_InventoryWarehouseReceiptDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryWarehouseReceiptPendingReconciliation]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryWarehouseReceiptPendingReconciliation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RegionID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Sku] [varchar](200) NULL,
	[Upc] [varchar](200) NOT NULL,
	[Qty] [int] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[InventoryWarehouseReceiptDetailID] [int] NULL,
	[PendingInventoryType] [int] NULL,
	[IncludedInIR] [datetime] NULL,
 CONSTRAINT [PK_InventoryWarehouseReceiptPendingReconciliation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryWatermark]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryWatermark](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UPC] [varchar](255) NOT NULL,
	[Qty] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[RegionID] [int] NOT NULL,
	[WatermarkDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InventoryWatermark] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Mapping]    Script Date: 11/30/2020 11:23:28 AM ******/
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
/****** Object:  Table [dbo].[MappingCategory]    Script Date: 11/30/2020 11:23:28 AM ******/
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
/****** Object:  Table [dbo].[MappingCategoryField]    Script Date: 11/30/2020 11:23:28 AM ******/
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
/****** Object:  Table [dbo].[MappingCategoryFieldDetail]    Script Date: 11/30/2020 11:23:28 AM ******/
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
/****** Object:  Table [dbo].[MappingDetail]    Script Date: 11/30/2020 11:23:28 AM ******/
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
/****** Object:  Table [dbo].[MappingFileCategory]    Script Date: 11/30/2020 11:23:28 AM ******/
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
/****** Object:  Table [dbo].[NarvarShipMethod]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NarvarShipMethod](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](255) NOT NULL,
	[Description] [varchar](255) NULL,
 CONSTRAINT [PK_NarvarShipMethod] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NextInternalCustomerID]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NextInternalCustomerID](
	[CustomerID] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NextInternalOrderDetailID]    Script Date: 11/30/2020 11:23:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NextInternalOrderDetailID](
	[OrderDetailID] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NextInternalOrderID]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NextInternalOrderID](
	[OrderID] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NextInternalTrackingNumberID]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NextInternalTrackingNumberID](
	[TrackingNumberID] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderException]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderException](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[SourceRefNum] [varchar](100) NOT NULL,
	[Exception] [varchar](max) NOT NULL,
	[StackTrace] [varchar](max) NOT NULL,
 CONSTRAINT [PK_OrderException] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Platform]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Platform](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[LoadInventoryFromPlatform] [bit] NOT NULL,
	[LoadOrdersFromPlatform] [bit] NULL,
	[LoadCustomersFromPlatform] [bit] NULL,
 CONSTRAINT [PK_WHM_Platform] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RabbitPayload]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RabbitPayload](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MessageID] [uniqueidentifier] NOT NULL,
	[CorrelationID] [uniqueidentifier] NOT NULL,
	[Queue] [varchar](200) NOT NULL,
	[Type] [varchar](50) NOT NULL,
	[Consumer] [varchar](max) NOT NULL,
	[MessagePayload] [text] NOT NULL,
	[Message] [text] NULL,
	[Log] [varchar](max) NULL,
	[Source] [varchar](1000) NULL,
	[DateEntered] [datetime] NOT NULL,
	[AmendmentCorrelationID] [uniqueidentifier] NULL,
	[SourceRefNum] [varchar](200) NOT NULL,
 CONSTRAINT [PK_RabbitPayload] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Region]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Region](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RegionName] [varchar](255) NOT NULL,
	[Context] [varchar](255) NOT NULL,
 CONSTRAINT [PK_WHM_Region] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ShipMethod]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShipMethod](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DomesticDispatch] [bit] NOT NULL,
	[Code] [varchar](255) NOT NULL,
	[DeliveryPriority] [int] NULL,
	[InternationalDispatch] [bit] NULL,
 CONSTRAINT [PK_ShipMethod] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ShippingHoliday]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShippingHoliday](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Date] [date] NOT NULL,
	[Description] [varchar](255) NOT NULL,
 CONSTRAINT [PK_ShippingHoliday] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SkuCustomsInformation]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SkuCustomsInformation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Sku] [varchar](255) NOT NULL,
	[ProductDescription] [varchar](500) NOT NULL,
	[HTSCode] [nvarchar](max) NOT NULL,
	[CountryOfOrigin] [varchar](255) NOT NULL,
	[CountryOfManufacture] [varchar](255) NULL,
	[BrandID] [int] NOT NULL,
 CONSTRAINT [PK_SkuCustomsInformation] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Source]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Source](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[RegionID] [int] NOT NULL,
	[BrandCodeForPlatform] [varchar](50) NOT NULL,
	[Timezone] [varchar](50) NULL,
	[HasCatalog] [bit] NOT NULL,
	[HandlesOrders] [bit] NOT NULL,
	[HandlesTrackingNumbers] [bit] NOT NULL,
	[HandlesInventoryAllocation] [bit] NOT NULL,
	[UsesBronto] [bit] NOT NULL,
 CONSTRAINT [PK_Source] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SourcePayload]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SourcePayload](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BrandID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SourceRefNum] [varchar](50) NOT NULL,
	[Type] [varchar](100) NOT NULL,
	[Payload] [varchar](max) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[PayloadOriginPlatformID] [int] NOT NULL,
 CONSTRAINT [PK_SourcePayload] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SourceShipMethodConversion]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SourceShipMethodConversion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceCode] [varchar](255) NOT NULL,
	[Description] [varchar](255) NULL,
	[SourceID] [int] NOT NULL,
	[ShipMethodID] [int] NOT NULL,
	[DestinationTypeID] [int] NULL,
	[Archived] [bit] NOT NULL,
	[Default] [bit] NOT NULL,
 CONSTRAINT [PK_SourceShipMethodConversion] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SourceStore]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SourceStore](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [int] NOT NULL,
	[StoreID] [int] NOT NULL,
	[Active] [bit] NULL,
 CONSTRAINT [PK_SourceStore] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SourceWarehouse]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SourceWarehouse](
	[ID] [int] NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[RegionID] [int] NOT NULL,
 CONSTRAINT [PK_SourceWarehouse] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SourcingCategory]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SourcingCategory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
 CONSTRAINT [PK_SourcingCategory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StatusCategory]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StatusCategory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
 CONSTRAINT [PK_StatusCategory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StatusCode]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StatusCode](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[Description] [varchar](255) NULL,
	[Archived] [bit] NULL,
 CONSTRAINT [PK_StatusCode] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[temp_HistoricalOrdersToProcess]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temp_HistoricalOrdersToProcess](
	[SourceRefNum] [nvarchar](50) NOT NULL,
	[OrderDate] [datetime] NULL,
	[Processed] [bit] NOT NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ContainsDsc] [bit] NULL,
	[SourceID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TmsRateGroup]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TmsRateGroup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RateGroup] [varchar](255) NOT NULL,
	[ShipMethodID] [int] NOT NULL,
	[CommitmentDays] [int] NULL,
	[DestinationTypeID] [int] NOT NULL,
 CONSTRAINT [PK_TmsRateGroup] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TmsRestrictedShipMethod]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TmsRestrictedShipMethod](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DestinationTypeID] [int] NOT NULL,
	[ShipMethodID] [int] NOT NULL,
 CONSTRAINT [PK_TmsRestrictedShipMethod] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TmsShipMethod]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TmsShipMethod](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](255) NOT NULL,
	[Description] [varchar](255) NULL,
	[CarrierID] [int] NOT NULL,
	[Internal] [bit] NOT NULL,
	[NarvarShipMethodID] [int] NULL,
	[PriorityRank] [int] NULL,
 CONSTRAINT [PK_TmsShipMethod] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TmsWarehouse]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TmsWarehouse](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[Enabled] [bit] NOT NULL,
	[ShipperSymbol] [varchar](255) NOT NULL,
	[FedexShipperSymbol] [varchar](255) NULL,
	[AllocationEnabled] [bit] NULL,
 CONSTRAINT [PK_TmsWarehouse] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VersionInfo]    Script Date: 11/30/2020 11:23:29 AM ******/
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
/****** Object:  Table [dbo].[WarehouseBrand_CountryPriority]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseBrand_CountryPriority](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BrandID] [int] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[CountryCode_LookUpID] [int] NOT NULL,
	[Priority] [int] NULL,
 CONSTRAINT [PK_WarehouseBrand_CountryPriority] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseCountryExclusion]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseCountryExclusion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Country] [varchar](255) NOT NULL,
	[WarehouseID] [int] NOT NULL,
 CONSTRAINT [PK_WarehouseCountryExclusion] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseLedger]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseLedger](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BrandID] [int] NULL,
	[PlatformID] [int] NULL,
	[SourceID] [int] NULL,
	[RegionID] [int] NULL,
	[WarehouseID] [int] NOT NULL,
	[Event] [varchar](100) NOT NULL,
	[Sku] [varchar](100) NULL,
	[Upc] [varchar](100) NOT NULL,
	[Qty] [int] NOT NULL,
	[DateEntered] [datetime] NOT NULL,
 CONSTRAINT [PK_WarehouseLedger] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseRateGroup]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseRateGroup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DateEntered] [datetime] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[ShipMethodID] [int] NOT NULL,
	[RateGroup] [varchar](255) NOT NULL,
	[CommitmentDays] [int] NULL,
	[DestinationTypeID] [int] NULL,
 CONSTRAINT [PK_WarehouseRateGroup] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseShipMethod]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseShipMethod](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Active] [bit] NOT NULL,
	[WarehouseID] [int] NOT NULL,
	[ShipMethodID] [int] NOT NULL,
 CONSTRAINT [PK_WarehouseShipMethod] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WarehouseTMSShipMethodConversion]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WarehouseTMSShipMethodConversion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](255) NOT NULL,
	[Description] [varchar](255) NULL,
	[WarehouseID] [int] NOT NULL,
	[TmsShipMethodID] [int] NOT NULL,
	[DestinationTypeID] [int] NULL,
	[CarrierNameOverride] [varchar](255) NULL,
 CONSTRAINT [PK_WarehouseTMSShipMethodConversion] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HybrisVirtualHost] ADD  CONSTRAINT [DF_HybrisVirtualHost_Reserved]  DEFAULT ((0)) FOR [Reserved]
GO
ALTER TABLE [dbo].[InventoryPackingList] ADD  DEFAULT ('') FOR [InvoiceID]
GO
ALTER TABLE [dbo].[InventoryPackingList] ADD  DEFAULT (getdate()) FOR [InvoiceDate]
GO
ALTER TABLE [dbo].[InventoryPackingList] ADD  DEFAULT ('') FOR [OriginPort]
GO
ALTER TABLE [dbo].[InventoryPackingList] ADD  DEFAULT ('') FOR [DestinationPort]
GO
ALTER TABLE [dbo].[InventoryPackingList] ADD  DEFAULT ('') FOR [VoyageID]
GO
ALTER TABLE [dbo].[InventoryPackingList] ADD  DEFAULT (getdate()) FOR [DepartureDate]
GO
ALTER TABLE [dbo].[InventoryPackingList] ADD  DEFAULT (getdate()) FOR [CargoReceivedDate]
GO
ALTER TABLE [dbo].[InventoryPackingList] ADD  DEFAULT ('') FOR [BillOfLading]
GO
ALTER TABLE [dbo].[InventoryPackingList] ADD  DEFAULT ('') FOR [ContainerNumber]
GO
ALTER TABLE [dbo].[InventoryPackingList] ADD  DEFAULT ((0)) FOR [InventoryReleaseID]
GO
ALTER TABLE [dbo].[InventoryPackingList] ADD  DEFAULT ((0)) FOR [InventoryPackingListSummaryID]
GO
ALTER TABLE [dbo].[InventoryWarehouseReceipt] ADD  DEFAULT ((0)) FOR [InventoryPackingListSummaryID]
GO
ALTER TABLE [dbo].[InventoryWarehouseReceipt] ADD  DEFAULT ('') FOR [ContainerNumber]
GO
ALTER TABLE [dbo].[Mapping] ADD  CONSTRAINT [DF_Mapping_IsDefault]  DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[Platform] ADD  CONSTRAINT [DF_Platform_LoadInventoryFromPlatform]  DEFAULT ((0)) FOR [LoadInventoryFromPlatform]
GO
ALTER TABLE [dbo].[ShipMethod] ADD  CONSTRAINT [DF_ShipMethod_DeliveryPriority]  DEFAULT ((99)) FOR [DeliveryPriority]
GO
ALTER TABLE [dbo].[SourceShipMethodConversion] ADD  CONSTRAINT [DF_SourceShipMethodConversion_Default]  DEFAULT ((0)) FOR [Default]
GO
ALTER TABLE [dbo].[SourceWarehouse] ADD  CONSTRAINT [DF_SourceWarehouse_RegionID]  DEFAULT ((0)) FOR [RegionID]
GO
ALTER TABLE [dbo].[StatusCode] ADD  CONSTRAINT [DF_StatusCode_Archived]  DEFAULT ((0)) FOR [Archived]
GO
ALTER TABLE [dbo].[TmsShipMethod] ADD  CONSTRAINT [DF_TmsShipMethod_Internal]  DEFAULT ((0)) FOR [Internal]
GO
ALTER TABLE [dbo].[ApiVendorSession]  WITH CHECK ADD FOREIGN KEY([ApiVendorID])
REFERENCES [dbo].[ApiVendor] ([ID])
GO
ALTER TABLE [dbo].[AspNetPermission]  WITH CHECK ADD  CONSTRAINT [FK_AspNetPermission_PermissionGroupID_AspNetPermissionGroup_ID] FOREIGN KEY([PermissionGroupID])
REFERENCES [dbo].[AspNetPermissionGroup] ([ID])
GO
ALTER TABLE [dbo].[AspNetPermission] CHECK CONSTRAINT [FK_AspNetPermission_PermissionGroupID_AspNetPermissionGroup_ID]
GO
ALTER TABLE [dbo].[AspNetPermissionRoleAssociation]  WITH CHECK ADD  CONSTRAINT [FK_AspNetPermissionRoleAssociation_PermissionID_AspNetPermission_ID] FOREIGN KEY([PermissionID])
REFERENCES [dbo].[AspNetPermission] ([ID])
GO
ALTER TABLE [dbo].[AspNetPermissionRoleAssociation] CHECK CONSTRAINT [FK_AspNetPermissionRoleAssociation_PermissionID_AspNetPermission_ID]
GO
ALTER TABLE [dbo].[AspNetRoleClaims]  WITH CHECK ADD  CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetRoleClaims] CHECK CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId]
GO
ALTER TABLE [dbo].[AspNetUserClaims]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserClaims] CHECK CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserLogins]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserLogins] CHECK CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserTokens]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserTokens] CHECK CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[CarrierDestination]  WITH CHECK ADD  CONSTRAINT [FK_CarrierRestriction_Carrier] FOREIGN KEY([CarrierID])
REFERENCES [dbo].[Carrier] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CarrierDestination] CHECK CONSTRAINT [FK_CarrierRestriction_Carrier]
GO
ALTER TABLE [dbo].[CarrierShipMethod]  WITH CHECK ADD  CONSTRAINT [FK_CarrierShipMethodRestriction_Carrier] FOREIGN KEY([CarrierID])
REFERENCES [dbo].[Carrier] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CarrierShipMethod] CHECK CONSTRAINT [FK_CarrierShipMethodRestriction_Carrier]
GO
ALTER TABLE [dbo].[CarrierShipZone]  WITH CHECK ADD  CONSTRAINT [FK_CarrierShipZone_Carrier] FOREIGN KEY([CarrierID])
REFERENCES [dbo].[Carrier] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CarrierShipZone] CHECK CONSTRAINT [FK_CarrierShipZone_Carrier]
GO
ALTER TABLE [dbo].[CarrierTrackingNumber]  WITH CHECK ADD  CONSTRAINT [FK_CarrierTrackingNumber_CarrierID_Carrier_ID] FOREIGN KEY([CarrierID])
REFERENCES [dbo].[Carrier] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CarrierTrackingNumber] CHECK CONSTRAINT [FK_CarrierTrackingNumber_CarrierID_Carrier_ID]
GO
ALTER TABLE [dbo].[CarrierUpc]  WITH CHECK ADD  CONSTRAINT [FK_CarrierUpc_Carrier] FOREIGN KEY([CarrierID])
REFERENCES [dbo].[Carrier] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CarrierUpc] CHECK CONSTRAINT [FK_CarrierUpc_Carrier]
GO
ALTER TABLE [dbo].[CarrierWarehouseShipMethod]  WITH CHECK ADD  CONSTRAINT [FK_CarrierWarehouseShipMethod_CarrierWarehouse] FOREIGN KEY([CarrierWarehouseID])
REFERENCES [dbo].[CarrierWarehouse] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CarrierWarehouseShipMethod] CHECK CONSTRAINT [FK_CarrierWarehouseShipMethod_CarrierWarehouse]
GO
ALTER TABLE [dbo].[HybrisRouted]  WITH CHECK ADD  CONSTRAINT [FK_HybrisRouted_HybrisVirtualHostID_HybrisVirtualHost_ID] FOREIGN KEY([HybrisVirtualHostID])
REFERENCES [dbo].[HybrisVirtualHost] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[HybrisRouted] CHECK CONSTRAINT [FK_HybrisRouted_HybrisVirtualHostID_HybrisVirtualHost_ID]
GO
ALTER TABLE [dbo].[HybrisWarehouse]  WITH CHECK ADD  CONSTRAINT [FK_HybrisWarehouse_Region] FOREIGN KEY([RegionID])
REFERENCES [dbo].[Region] ([ID])
GO
ALTER TABLE [dbo].[HybrisWarehouse] CHECK CONSTRAINT [FK_HybrisWarehouse_Region]
GO
ALTER TABLE [dbo].[InventoryPackingList]  WITH CHECK ADD  CONSTRAINT [FK_InventoryPackingList_InventoryPackingListSummaryID_InventoryPackingListSummary_ID] FOREIGN KEY([InventoryPackingListSummaryID])
REFERENCES [dbo].[InventoryPackingListSummary] ([ID])
GO
ALTER TABLE [dbo].[InventoryPackingList] CHECK CONSTRAINT [FK_InventoryPackingList_InventoryPackingListSummaryID_InventoryPackingListSummary_ID]
GO
ALTER TABLE [dbo].[InventoryPackingList]  WITH CHECK ADD  CONSTRAINT [FK_InventoryPackingList_InventoryReleaseID_InventoryRelease_ID] FOREIGN KEY([InventoryReleaseID])
REFERENCES [dbo].[InventoryRelease] ([ID])
GO
ALTER TABLE [dbo].[InventoryPackingList] CHECK CONSTRAINT [FK_InventoryPackingList_InventoryReleaseID_InventoryRelease_ID]
GO
ALTER TABLE [dbo].[InventoryPackingList]  WITH CHECK ADD  CONSTRAINT [FK_InventoryPackingListContainerDetail_PreviousWarehouseID_SourceWarehouse_ID] FOREIGN KEY([PreviousWarehouseID])
REFERENCES [dbo].[SourceWarehouse] ([ID])
GO
ALTER TABLE [dbo].[InventoryPackingList] CHECK CONSTRAINT [FK_InventoryPackingListContainerDetail_PreviousWarehouseID_SourceWarehouse_ID]
GO
ALTER TABLE [dbo].[InventoryPackingList]  WITH CHECK ADD  CONSTRAINT [FK_InventoryPackingListContainerDetail_WarehouseID_SourceWarehouse_ID] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[SourceWarehouse] ([ID])
GO
ALTER TABLE [dbo].[InventoryPackingList] CHECK CONSTRAINT [FK_InventoryPackingListContainerDetail_WarehouseID_SourceWarehouse_ID]
GO
ALTER TABLE [dbo].[InventoryRelease]  WITH CHECK ADD  CONSTRAINT [FK_InventorySourcingFile_SourcingCategoryID_SourcingCategory_ID] FOREIGN KEY([SourcingCategoryID])
REFERENCES [dbo].[SourcingCategory] ([ID])
GO
ALTER TABLE [dbo].[InventoryRelease] CHECK CONSTRAINT [FK_InventorySourcingFile_SourcingCategoryID_SourcingCategory_ID]
GO
ALTER TABLE [dbo].[InventoryWarehouseReceipt]  WITH CHECK ADD  CONSTRAINT [FK_InventoryWarehouseReceipt_InventoryPackingListSummaryID_InventoryPackingListSummary_ID] FOREIGN KEY([InventoryPackingListSummaryID])
REFERENCES [dbo].[InventoryPackingListSummary] ([ID])
GO
ALTER TABLE [dbo].[InventoryWarehouseReceipt] CHECK CONSTRAINT [FK_InventoryWarehouseReceipt_InventoryPackingListSummaryID_InventoryPackingListSummary_ID]
GO
ALTER TABLE [dbo].[InventoryWarehouseReceipt]  WITH CHECK ADD  CONSTRAINT [FK_InventoryWarehouseReceipt_WarehouseID_SourceWarehouse_ID] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[SourceWarehouse] ([ID])
GO
ALTER TABLE [dbo].[InventoryWarehouseReceipt] CHECK CONSTRAINT [FK_InventoryWarehouseReceipt_WarehouseID_SourceWarehouse_ID]
GO
ALTER TABLE [dbo].[InventoryWarehouseReceiptDetail]  WITH CHECK ADD  CONSTRAINT [FK_InventoryWarehouseReceipt_PackingListID_InventoryPackingListContainerDetail_ID] FOREIGN KEY([PackingListID])
REFERENCES [dbo].[InventoryPackingList] ([ID])
GO
ALTER TABLE [dbo].[InventoryWarehouseReceiptDetail] CHECK CONSTRAINT [FK_InventoryWarehouseReceipt_PackingListID_InventoryPackingListContainerDetail_ID]
GO
ALTER TABLE [dbo].[InventoryWarehouseReceiptDetail]  WITH CHECK ADD  CONSTRAINT [FK_InventoryWarehouseReceiptDetail_InventoryWarehouseReceiptID_InventoryWarehouseReceipt_ID] FOREIGN KEY([InventoryWarehouseReceiptID])
REFERENCES [dbo].[InventoryWarehouseReceipt] ([ID])
GO
ALTER TABLE [dbo].[InventoryWarehouseReceiptDetail] CHECK CONSTRAINT [FK_InventoryWarehouseReceiptDetail_InventoryWarehouseReceiptID_InventoryWarehouseReceipt_ID]
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
ALTER TABLE [dbo].[Source]  WITH CHECK ADD  CONSTRAINT [FK_Source_BrandID_Brand_ID] FOREIGN KEY([BrandID])
REFERENCES [dbo].[Brand] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Source] CHECK CONSTRAINT [FK_Source_BrandID_Brand_ID]
GO
ALTER TABLE [dbo].[Source]  WITH CHECK ADD  CONSTRAINT [FK_Source_PlatformID_Platform_ID] FOREIGN KEY([PlatformID])
REFERENCES [dbo].[Platform] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Source] CHECK CONSTRAINT [FK_Source_PlatformID_Platform_ID]
GO
ALTER TABLE [dbo].[Source]  WITH CHECK ADD  CONSTRAINT [FK_Source_RegionID_Region_ID] FOREIGN KEY([RegionID])
REFERENCES [dbo].[Region] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Source] CHECK CONSTRAINT [FK_Source_RegionID_Region_ID]
GO
ALTER TABLE [dbo].[SourceStore]  WITH CHECK ADD  CONSTRAINT [FK_SourceStore_SourceID_Source_ID] FOREIGN KEY([SourceID])
REFERENCES [dbo].[Source] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SourceStore] CHECK CONSTRAINT [FK_SourceStore_SourceID_Source_ID]
GO
ALTER TABLE [dbo].[TmsShipMethod]  WITH CHECK ADD  CONSTRAINT [FK_TmsShipMethod_CarrierID_Carrier_ID] FOREIGN KEY([CarrierID])
REFERENCES [dbo].[Carrier] ([ID])
GO
ALTER TABLE [dbo].[TmsShipMethod] CHECK CONSTRAINT [FK_TmsShipMethod_CarrierID_Carrier_ID]
GO
ALTER TABLE [dbo].[WarehouseBrand_CountryPriority]  WITH CHECK ADD  CONSTRAINT [FK_WarehouseBrand_CountryPriority_BrandID_Brand_ID] FOREIGN KEY([BrandID])
REFERENCES [dbo].[Brand] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WarehouseBrand_CountryPriority] CHECK CONSTRAINT [FK_WarehouseBrand_CountryPriority_BrandID_Brand_ID]
GO
ALTER TABLE [dbo].[WarehouseBrand_CountryPriority]  WITH CHECK ADD  CONSTRAINT [FK_WarehouseBrand_CountryPriority_CountryCode_LookUpID_CountryCode_LU_ID] FOREIGN KEY([CountryCode_LookUpID])
REFERENCES [dbo].[CountryCode_LU] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WarehouseBrand_CountryPriority] CHECK CONSTRAINT [FK_WarehouseBrand_CountryPriority_CountryCode_LookUpID_CountryCode_LU_ID]
GO
ALTER TABLE [dbo].[WarehouseBrand_CountryPriority]  WITH CHECK ADD  CONSTRAINT [FK_WarehouseBrand_CountryPriority_WarehouseID_SourceWarehouse_ID] FOREIGN KEY([WarehouseID])
REFERENCES [dbo].[SourceWarehouse] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WarehouseBrand_CountryPriority] CHECK CONSTRAINT [FK_WarehouseBrand_CountryPriority_WarehouseID_SourceWarehouse_ID]
GO
ALTER TABLE [dbo].[WarehouseTMSShipMethodConversion]  WITH CHECK ADD  CONSTRAINT [FK_WarehouseTMSShipMethodConversion_TmsShipMethodID_TmsShipMethod_ID] FOREIGN KEY([TmsShipMethodID])
REFERENCES [dbo].[TmsShipMethod] ([ID])
GO
ALTER TABLE [dbo].[WarehouseTMSShipMethodConversion] CHECK CONSTRAINT [FK_WarehouseTMSShipMethodConversion_TmsShipMethodID_TmsShipMethod_ID]
GO
/****** Object:  StoredProcedure [dbo].[CreateTestProductWithInventory]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Creates a test sku with inventory information if needed
Environment = Dev, Staging, Integration, Training or Production
*/
CREATE procedure [dbo].[CreateTestProductWithInventory] @BrandID int, @SKU varchar(50), @Qty int = 1000, @WarehouseID int = null, @UPC varchar(50) = null, @Environment varchar(20) = 'Dev'
as
begin

	set @Environment = 
		case 
			when @Environment in ('Dev', 'Production') then ''
			else @Environment
		end;

	set @UPC = isnull(@upc, @sku);

	declare @context varchar(30) = (select context from brand where id = @brandid);
	declare @skuID int;
	declare @upcid int;
	declare @brandskuupcid int;
	declare @sourcebrandskuupcreconexists bit;
	declare @inventoryexists bit;
	declare @actualHoldQty int;

	declare @sql nvarchar(500);
	declare @params nvarchar(500);

	set @actualHoldQty = 0;

	set @sql = N'select @skuid_x = id from [' + @Environment + @context + ']..brandsku where sku = ''' + @sku + '''';
	set @params = N'@skuid_x varchar(50) OUTPUT';
	exec sp_executesql @sql, @params, @skuid_x=@skuid OUTPUT;

	if (@skuid is null)
	begin
		set @sql = N'insert into [' + @Environment + @context + ']..brandsku values (' + cast(@brandID as varchar) + ', ''' + @sku + ''', null, null, null, 1, ''' + @sku + '''); select @identity_x = @@IDENTITY;';
		set @params = N'@identity_x int OUTPUT';
		exec sp_executesql @sql, @params, @identity_x=@skuid OUTPUT;
	end

	set @sql = N'select @upcid_x = id from [' + @Environment + @context + ']..upc where upc = ''' + @upc + '''';
	set @params = N'@upcid_x int OUTPUT';
	exec sp_executesql @sql, @params, @upcid_x=@upcid OUTPUT;

	if (@upcid is null)
	begin
		set @sql = N'insert into [' + @Environment + @context + ']..upc values (''' + @upc + ''', ''' + @upc + ''', '''', 1, 1, 1, 0, null, null, null, null, null, null, null, null, null, null, right(year(getdate()), 2), 0, 0, 10, null, right(year(getdate()), 2), 0, 1, 0, 0); select @identity_x = @@IDENTITY;';
		set @params = N'@identity_x int OUTPUT';
		exec sp_executesql @sql, @params, @identity_x=@upcid OUTPUT;
	end

	set @sql = N'select @brandskuupcid_x = id from [' + @Environment + @context + ']..brandskuupc where brandskuid = ' + cast(@skuid as varchar) + ' and upcid = ' + cast(@upcid as varchar);
	set @params = N'@brandskuupcid_x int OUTPUT';
	exec sp_executesql @sql, @params, @brandskuupcid_x=@brandskuupcid OUTPUT;

	if (@brandskuupcid is null)
	begin
		set @sql = N'insert into [' + @Environment + @context + ']..brandskuupc values (' + cast(@skuID as varchar) + ', ' + cast(@upcid as varchar) + ', 1, 1); select @identity_x = @@IDENTITY;';
		set @params = N'@identity_x int OUTPUT';
		exec sp_executesql @sql, @params, @identity_x=@brandskuupcid OUTPUT;
	end

	set @sql = N'select @exists_x = 1 from [' + @Environment + @context + ']..sourcebrandskuupcrecon where brandskuupcid = ' + cast(@brandskuupcid as varchar);
	set @params = N'@exists_x int OUTPUT';
	exec sp_executesql @sql, @params, @exists_x=@sourcebrandskuupcreconexists OUTPUT;

	if (isnull(@sourcebrandskuupcreconexists, 0) = 0)
	begin
		declare @sourceid int = (select id from source where BrandID = @BrandID and PlatformID = 3);
		set @sql = N'insert into [' + @Environment + @context + ']..sourcebrandskuupcrecon values (' + cast(@sourceid as varchar) + ', ' + cast(@brandskuupcid as varchar) + ', 100,null);';
		exec sp_executesql @sql;
	end

	if (@WarehouseID is null)
	begin
		set @sql = N'select @warehouseid_x = warehouseid from [' + @Environment + @context + ']..warehousecodelookup where warehousecode = ''TestWarehouse''';
		set @params = N'@warehouseid_x int OUTPUT';
		exec sp_executesql @sql, @params, @warehouseid_x=@WarehouseID OUTPUT;
	end

	set @sql = N'select @exists_x = 1 from [' + @Environment + @context + ']..inventory where warehouseid = ' + cast(@warehouseid as varchar) + ' and upcid = ' + cast(@upcid as varchar);
	set @params = N'@exists_x int OUTPUT';
	exec sp_executesql @sql, @params, @exists_x=@inventoryexists OUTPUT;

	if (isnull(@inventoryexists, 0) = 0)
	begin
		set @sql = 'insert into [' + @Environment + @context + ']..inventory (warehouseid, qty, upcid, actualHoldQty) values (' + cast(@warehouseid as varchar) + ', ' + cast(@Qty as varchar) + ', ' + cast(@upcid as varchar) + ',' + cast(@actualHoldQty as varchar) + ');';
		exec sp_executesql @sql;
	end
	else
	begin
		set @sql = N'update [' + @Environment + @context + ']..inventory set qty = ' + cast(@Qty as varchar) + ' where warehouseid = ' + cast(@WarehouseID as varchar) + ' and upcid = ' + cast(@upcid as varchar);
		exec sp_executesql @sql;
	end
end
GO
/****** Object:  StoredProcedure [dbo].[GetNextCustomerID]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetNextCustomerID]
	@CustomerID INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON; -- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	BEGIN TRY
		BEGIN TRAN
			UPDATE NextInternalCustomerID SET CustomerID = CustomerID + 1;
			SELECT @CustomerID = CustomerID FROM NextInternalCustomerID;
		COMMIT TRAN -- Transaction Success!
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
			ROLLBACK TRAN --RollBack in case of Error
		-- Use RAISERROR inside the CATCH block to return error  
		-- information about the original error that caused  
		-- execution to jump to the CATCH block.  
		RAISERROR (@ErrorMessage, -- Message text.  
				   @ErrorSeverity, -- Severity.  
				   @ErrorState -- State.  
				   );  
	END CATCH		
END

GO
/****** Object:  StoredProcedure [dbo].[GetNextInternalOrderDetailID]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetNextInternalOrderDetailID]
	@OrderDetailID INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON; -- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	BEGIN TRY
		BEGIN TRAN
			UPDATE NextInternalOrderDetailID SET OrderDetailID = OrderDetailID + 1;
			SELECT @OrderDetailID = OrderDetailID FROM NextInternalOrderDetailID;
		COMMIT TRAN -- Transaction Success!
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
			ROLLBACK TRAN --RollBack in case of Error
		-- Use RAISERROR inside the CATCH block to return error  
		-- information about the original error that caused  
		-- execution to jump to the CATCH block.  
		RAISERROR (@ErrorMessage, -- Message text.  
				   @ErrorSeverity, -- Severity.  
				   @ErrorState -- State.  
				   );  
	END CATCH		
END

GO
/****** Object:  StoredProcedure [dbo].[GetNextInternalOrderID]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetNextInternalOrderID]
	@OrderID INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON; -- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.

	BEGIN TRY
		BEGIN TRAN

			UPDATE NextInternalOrderID SET OrderID = OrderID + 1;
			SELECT @OrderID = OrderID FROM NextInternalOrderID;

		COMMIT TRAN -- Transaction Success!
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
			ROLLBACK TRAN --RollBack in case of Error

		-- Use RAISERROR inside the CATCH block to return error  
		-- information about the original error that caused  
		-- execution to jump to the CATCH block.  
		RAISERROR (@ErrorMessage, -- Message text.  
				   @ErrorSeverity, -- Severity.  
				   @ErrorState -- State.  
				   );  
	END CATCH		
END
GO
/****** Object:  StoredProcedure [dbo].[GetNextInternalTrackingNumberID]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetNextInternalTrackingNumberID]
	@TrackingNumberID INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON; -- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.

	BEGIN TRY
		BEGIN TRAN

			UPDATE NextInternalTrackingNumberID SET TrackingNumberID = TrackingNumberID + 1;
			SELECT @TrackingNumberID = TrackingNumberID FROM NextInternalTrackingNumberID;

		COMMIT TRAN -- Transaction Success!
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
			ROLLBACK TRAN --RollBack in case of Error

		-- Use RAISERROR inside the CATCH block to return error  
		-- information about the original error that caused  
		-- execution to jump to the CATCH block.  
		RAISERROR (@ErrorMessage, -- Message text.  
				   @ErrorSeverity, -- Severity.  
				   @ErrorState -- State.  
				   );  
	END CATCH		
END
GO
/****** Object:  StoredProcedure [dbo].[GetUniqueOrderSourceRefNums]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

                    CREATE PROCEDURE [dbo].[GetUniqueOrderSourceRefNums]
                    @daysAgo INT,
                    @origin INT
                    AS
                    BEGIN
                    -- SET NOCOUNT ON added to prevent extra result sets from
                    -- interfering with SELECT statements.
                    SET NOCOUNT ON;
                    SELECT DISTINCT SourceRefNum FROM SourcePayload with(nolock) 
                    WHERE PayloadOriginPlatformID = @origin
                    AND [Type] = 'Order'
                    AND DateEntered > DATEADD(DAY, @daysAgo, GETDATE())
                    END
GO
/****** Object:  StoredProcedure [dbo].[GetWarehouseReceiptDetailsExport]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                        CREATE procedure [dbo].[GetWarehouseReceiptDetailsExport]
                                                @ReleaseID int,
                                                @PoNumber varchar(100)
                                                as
                                                    set nocount on;
                                                    select distinct
								                        iwrd.Upc,
								                        pl.StoreSku as ProductCodeStore, 
								                        pl.ProductDescription,
								                        pl.CartonNumber,
								                        pl.Length,
								                        pl.Width,
								                        pl.Height,
								                        pl.Weight, 
								                        case 
									                        when pl.CartonNumber = 'Master' 
									                        then 0 
									                        else pl.UnitCost
								                        end
								                        as UnitCost,
								                        iwrd.ExpectedQty,
								                        iwrd.ReceivedQty,
								                        case
									                        when pl.CartonNumber = 'Master'
									                        then 0
									                        else (pl.UnitCost*iwrd.ExpectedQty) 
								                        end
								                        as ExtendedCost,
								                        pl.DestinationPort as DestinationWarehouse,
								                        pl.ContainerNumber,
								                        pl.SealNumber,
								                        pl.InvoiceID,
								                        pl.DepartureDate,
								                        iwr.DateReceived
							                        from InventoryWarehouseReceipt iwr
							                        join InventoryWarehouseReceiptDetail iwrd on iwrd.InventoryWarehouseReceiptID = iwr.ID
							                        join InventoryPackingList pl on pl.ID = iwrd.PackingListID
							                        where pl.InventoryReleaseID = @ReleaseID
							                        and iwrd.ReceivedQty is not null
							                        --and wipl.Brand != 'AMZ' // commenting out 6/13/2017 by MT; not sure if it's needed
							                        and pl.InvoiceID = @PoNumber;

GO
/****** Object:  StoredProcedure [dbo].[RemoveAmazonSchedules]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RemoveAmazonSchedules] AS
                        BEGIN
                        declare amz_tns CURSOR for select job_name from ${Environment}quartz..qrtz_triggers where job_group in ('LoadOrdersFromAmazon', 'LoadTrackingNumbersToAmazon', 'CheckAmazonForPendingOrders')
                        open amz_tns
                        ​
                        declare @jobid uniqueidentifier
                        FETCH NEXT FROM amz_tns INTO @jobid
                        ​
                        while @@fetch_status = 0
                        begin
                            exec ${Environment}quartz..deletejob @jobid
                            fetch next from amz_tns into @jobid;
                                    end;
                        ​
                             close amz_tns
                        deallocate amz_tns;
                    END
GO
/****** Object:  StoredProcedure [dbo].[RunSqlAudit]    Script Date: 11/30/2020 11:23:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[RunSqlAudit]
						AS
						BEGIN
							IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'SqlAudit')
							BEGIN
								CREATE TABLE [SqlAudit] (
									SnapshotID DateTime,
									SPID int,
									Status varchar(MAX),
									Login varchar(MAX),
									HostName varchar(MAX),
									BlkBy varchar(MAX),
									DBName varchar(MAX),
									Command varchar(MAX),
									CPUTime int,
									DiskIO int,
									LastBatch varchar(MAX),
									ProgramName varchar(MAX)
								);	
								END

							Declare @SnapshotID DateTime
							set @SnapshotID = GETDate()

							INSERT INTO [SqlAudit]
							SELECT  
									@SnapshotID,
									spid,
									sp.[status],
									loginame [Login],
									hostname, 
									blocked BlkBy,
									sd.name DBName, 
									cmd Command,
									cpu CPUTime,
									physical_io DiskIO,
									last_batch LastBatch,
									[program_name] ProgramName   
							FROM master.dbo.sysprocesses sp 
							JOIN master.dbo.sysdatabases sd ON sp.dbid = sd.dbid	
						End
GO
