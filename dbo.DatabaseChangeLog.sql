CREATE TABLE [dbo].[DatabaseChangeLog]
(
[DatabaseName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ObjectName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ObjectType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TSQLCommand] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoginName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
