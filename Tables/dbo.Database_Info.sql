CREATE TABLE [dbo].[Database_Info]
(
[Server] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[File_Status] [int] NULL,
[Name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Filename] [nvarchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Updateability] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[User_Access] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Recovery] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
