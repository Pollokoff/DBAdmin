CREATE TABLE [dbo].[DisplayToID]
(
[GUID] [uniqueidentifier] NOT NULL,
[RunID] [int] NULL,
[DisplayString] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LogStartTime] [char] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogStopTime] [char] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumberOfRecords] [int] NULL,
[MinutesToUTC] [int] NULL,
[TimeZoneName] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
