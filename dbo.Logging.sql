CREATE TABLE [dbo].[Logging]
(
[LoggingID] [int] NOT NULL,
[EventTime] [datetime] NULL,
[EventType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoginName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HostName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NTUserName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NTDomainName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Success] [int] NULL,
[FullLog] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
