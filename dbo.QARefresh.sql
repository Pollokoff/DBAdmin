CREATE TABLE [dbo].[QARefresh]
(
[SourceServer] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceDB] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DestServer] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DestDB] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DaysOld] [int] NULL
) ON [PRIMARY]
GO
