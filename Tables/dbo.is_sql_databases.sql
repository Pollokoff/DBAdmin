CREATE TABLE [dbo].[is_sql_databases]
(
[is_identity] [int] NOT NULL IDENTITY(1, 1),
[is_sqlserver] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[is_name] [varchar] (160) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[is_date_stamp] [date] NOT NULL,
[is_size] [real] NULL,
[is_available] [real] NULL,
[is_indexsize] [real] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_is_sql_databases] ON [dbo].[is_sql_databases] ([is_date_stamp], [is_identity]) ON [PRIMARY]
GO
