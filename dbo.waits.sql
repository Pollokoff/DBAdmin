CREATE TABLE [dbo].[waits]
(
[event_time] [datetime2] NULL,
[event_interval] [datetime2] NULL,
[query_hash] [decimal] (38, 0) NULL,
[query_plan_hash] [decimal] (38, 0) NULL,
[session_id] [int] NULL,
[client_hostname] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[database_name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[statement] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wait_type] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[duration_ms] [int] NULL,
[signal_duration_ms] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
