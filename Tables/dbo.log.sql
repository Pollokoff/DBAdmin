CREATE TABLE [dbo].[log]
(
[log_ID] [int] NOT NULL,
[type] [int] NOT NULL,
[LogString] [varchar] (7000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InsertionDate] [datetime] NOT NULL,
[User_ID] [int] NULL,
[CurrentUser] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SPid] [int] NOT NULL,
[LoginName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Comment] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
