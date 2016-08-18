CREATE TABLE [dbo].[Jobs]
(
[Server] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job_id] [uniqueidentifier] NOT NULL,
[name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Job_Enabled] [tinyint] NOT NULL,
[description] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notify_level_eventlog] [int] NOT NULL,
[notify_level_email] [int] NOT NULL,
[notify_level_netsend] [int] NOT NULL,
[notify_level_page] [int] NOT NULL,
[notify_email_operator_id] [int] NOT NULL,
[date_created] [datetime] NOT NULL,
[date_modified] [datetime] NULL,
[Category_Name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[next_run_date] [int] NULL,
[next_run_time] [int] NULL,
[last_run_outcome] [tinyint] NULL,
[last_outcome_message] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_run_date] [int] NULL,
[last_run_time] [int] NULL,
[last_run_duration] [int] NULL,
[Notify_Operator] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_address] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Package_run_date] [datetime] NULL
) ON [PRIMARY]
GO
