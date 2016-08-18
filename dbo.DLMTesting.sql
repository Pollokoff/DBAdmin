CREATE TABLE [dbo].[DLMTesting]
(
[TestID] [int] NOT NULL IDENTITY(1, 1),
[TestName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BuildName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
