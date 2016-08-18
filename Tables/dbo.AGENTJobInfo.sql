CREATE TABLE [dbo].[AGENTJobInfo]
(
[JobName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Category] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JobEnabled] [tinyint] NOT NULL,
[ScheduleEnabled] [int] NULL,
[freq_interval] [int] NULL,
[freq_recurrence_factor] [int] NULL,
[freq_relative_interval] [int] NULL,
[freq_subday_interval] [int] NULL,
[freq_subday_type] [int] NULL,
[freq_type] [int] NULL
) ON [PRIMARY]
GO
