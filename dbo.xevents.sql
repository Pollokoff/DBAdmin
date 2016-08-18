CREATE TABLE [dbo].[xevents]
(
[event_time] [datetime2] NULL,
[event_type] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[query_hash] [decimal] (38, 0) NULL,
[event_data] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
