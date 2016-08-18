CREATE TABLE [dbo].[Products]
(
[ProductCode] [int] NOT NULL,
[ShippingWeight] [float] NOT NULL,
[ShippingLength] [float] NOT NULL,
[ShippingWidth] [float] NOT NULL,
[ShippingHeight] [float] NOT NULL,
[UnitCost] [float] NOT NULL,
[PerOrder] [tinyint] NOT NULL,
[UserName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
