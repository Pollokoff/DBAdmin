CREATE TABLE [dbo].[Failed_Jobs]
(
[originating_server] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job_description] [varchar] (1023) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_outcome_message] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_run_date] [varchar] (63) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
