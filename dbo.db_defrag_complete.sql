CREATE TABLE [dbo].[db_defrag_complete]
(
[TableOwner] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableName] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableIndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[avg_fragmentation_in_percent] [float] NULL,
[ROWS] [bigint] NOT NULL,
[TIMESTAMP] [datetime] NULL
) ON [PRIMARY]
GO
