CREATE TABLE [dbo].[dba_server_database_sizetrend]
(
[report_date] [date] NULL,
[servername] [nchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbname] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[size] [numeric] (18, 0) NULL,
[dataspaceusage] [numeric] (18, 0) NULL,
[indexspaceusage] [numeric] (18, 0) NULL,
[spaceavailable] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
