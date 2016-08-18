CREATE TABLE [dbo].[SQLServers]
(
[ServerName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InstanceName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IP] [varchar] (2050) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GUID] [uniqueidentifier] NULL,
[PROD] [bit] NOT NULL,
[DateLastLogErrorImported] [datetime] NULL,
[DOMAIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Purpose] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Version] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationID] [int] NULL,
[DMZ] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
