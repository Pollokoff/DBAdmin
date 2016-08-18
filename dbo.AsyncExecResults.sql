CREATE TABLE [dbo].[AsyncExecResults]
(
[token] [uniqueidentifier] NOT NULL,
[submit_time] [datetime] NOT NULL,
[start_time] [datetime] NULL,
[finish_time] [datetime] NULL,
[error_number] [int] NULL,
[error_message] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AsyncExecResults] ADD CONSTRAINT [PK__AsyncExe__CA90DA7B09A971A2] PRIMARY KEY CLUSTERED  ([token]) ON [PRIMARY]
GO
