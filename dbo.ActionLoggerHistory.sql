CREATE TABLE [dbo].[ActionLoggerHistory]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[LoggedRowInsertedOn] [datetime] NULL CONSTRAINT [DF__ActionLog__Logge__014935CB] DEFAULT (getutcdate()),
[ExecutedBy] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComputerName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocumentCaption] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExecutedOn] [datetime] NULL,
[QueryText] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ActionLoggerHistory] ADD CONSTRAINT [PK__ActionLo__3214EC077F60ED59] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
