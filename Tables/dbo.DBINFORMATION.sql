CREATE TABLE [dbo].[DBINFORMATION]
(
[ServerName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DatabaseName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LogicalFileName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PhysicalFileName] [nvarchar] (520) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileSizeMB] [int] NULL,
[Status] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecoveryMode] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FreeSpaceMB] [int] NULL,
[FreeSpacePct] [int] NULL,
[Dateandtime] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
