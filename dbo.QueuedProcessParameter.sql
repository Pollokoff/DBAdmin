CREATE TABLE [dbo].[QueuedProcessParameter]
(
[QueuedProcessParameter_ID] [int] NOT NULL,
[QueuedProcess_ID] [int] NOT NULL,
[parameter] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[value] [sql_variant] NULL
) ON [PRIMARY]
GO
