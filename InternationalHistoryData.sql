USE [${Environment}InternationalHistory]
GO
SET IDENTITY_INSERT [dbo].[Platform] ON 

INSERT [dbo].[Platform] ([ID], [Name]) VALUES (1, N'Volusion')
INSERT [dbo].[Platform] ([ID], [Name]) VALUES (2, N'Pseudo')
INSERT [dbo].[Platform] ([ID], [Name]) VALUES (3, N'Hybris')
INSERT [dbo].[Platform] ([ID], [Name]) VALUES (5, N'SalesForce')
SET IDENTITY_INSERT [dbo].[Platform] OFF
SET IDENTITY_INSERT [dbo].[Source] ON 

INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (1, 1, 6)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (2, 1, 7)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (3, 1, 8)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (4, 1, 10)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (5, 1, 9)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (8, 5, 7)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (9, 5, 8)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (11, 5, 9)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (12, 3, 6)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (13, 5, 6)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (16, 3, 10)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (18, 5, 10)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (19, 3, 7)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (20, 3, 8)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (21, 6, 11)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (22, 9, 4)
SET IDENTITY_INSERT [dbo].[Source] OFF

INSERT INTO Warehouse (WarehouseID, Name) VALUES (4, 'TestWarehouse')