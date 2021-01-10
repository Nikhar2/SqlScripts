USE [${Environment}TreesHistory]
GO
SET IDENTITY_INSERT [dbo].[Platform] ON 

INSERT [dbo].[Platform] ([ID], [Name]) VALUES (1, N'Volusion')
INSERT [dbo].[Platform] ([ID], [Name]) VALUES (2, N'Pseudo')
INSERT [dbo].[Platform] ([ID], [Name]) VALUES (3, N'Hybris')
INSERT [dbo].[Platform] ([ID], [Name]) VALUES (5, N'SalesForce')
INSERT [dbo].[Platform] ([ID], [Name]) VALUES (6, N'Amazon')
SET IDENTITY_INSERT [dbo].[Platform] OFF
SET IDENTITY_INSERT [dbo].[Source] ON 

INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (2, 1, 2)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (3, 1, 3)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (4, 1, 4)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (8, 1, 1)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (9, 1, 5)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (11, 5, 2)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (12, 5, 3)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (13, 5, 4)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (16, 3, 1)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (17, 5, 1)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (18, 6, 2)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (19, 6, 3)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (20, 6, 4)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (21, 6, 1)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (22, 3, 11)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (23, 5, 11)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (24, 6, 11)
INSERT [dbo].[Source] ([ID], [PlatformID], [BrandID]) VALUES (25, 9, 4)
SET IDENTITY_INSERT [dbo].[Source] OFF


INSERT INTO Warehouse (WarehouseID, Name) VALUES (83, 'TestWarehouse')
