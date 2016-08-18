CREATE TABLE [dbo].[QueuedProcess]
(
[QueuedProcess_ID] [int] NOT NULL,
[insertionDate] [datetime] NOT NULL,
[CompletionDate] [datetime] NULL,
[Process] [int] NOT NULL,
[Comment/error] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
