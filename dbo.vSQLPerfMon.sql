CREATE TABLE [dbo].[vSQLPerfMon]
(
[MachineName] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ObjectName] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CounterName] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InstanceName] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CounterDateTime] [char] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CONVERTEDDATE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CounterDate] [smalldatetime] NULL,
[CounterYear] [int] NULL,
[CounterMonth] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CounterWeek] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CounterWeekDay] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CounterDay] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CounterTime] [varchar] (62) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CounterValue] [float] NOT NULL
) ON [PRIMARY]
GO
