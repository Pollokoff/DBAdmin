CREATE TABLE [dbo].[Server_SQL_Details_Save]
(
[ServerID] [int] NOT NULL,
[Servername] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ServerVersion] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [bit] NULL,
[Upgrade] [int] NULL
) ON [PRIMARY]
GO
