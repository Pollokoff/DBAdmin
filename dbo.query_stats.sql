CREATE TABLE [dbo].[query_stats]
(
[event_time] [datetime2] NULL,
[event_interval] [datetime2] NULL,
[query_hash] [decimal] (38, 0) NULL,
[query_plan_hash] [decimal] (38, 0) NULL,
[session_id] [int] NULL,
[client_hostname] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[database_name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[statement] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[duration_ms] [int] NULL,
[cpu_time_ms] [int] NULL,
[physical_reads] [int] NULL,
[logical_reads] [int] NULL,
[writes] [int] NULL,
[row_count] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
