CREATE TABLE [dbo].[SQLLogInfo]
(
[ServerName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogDate] [datetime] NULL,
[ProcessInfo] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Text] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
