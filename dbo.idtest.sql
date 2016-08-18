CREATE TABLE [dbo].[idtest]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[string] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[idtest] ADD CONSTRAINT [PK_idtest] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
