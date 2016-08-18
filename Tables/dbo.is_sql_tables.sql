CREATE TABLE [dbo].[is_sql_tables]
(
[is_identity] [int] NOT NULL IDENTITY(1, 1),
[is_sqlserver] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[is_database_name] [varchar] (160) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[is_name] [varchar] (160) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[is_date_stamp] [date] NOT NULL,
[is_rows] [decimal] (15, 0) NULL,
[is_data_space_used] [decimal] (15, 0) NULL,
[is_index_space_used] [decimal] (15, 0) NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_is_sql_tables] ON [dbo].[is_sql_tables] ([is_date_stamp], [is_identity]) ON [PRIMARY]
GO
