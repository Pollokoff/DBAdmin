CREATE TABLE [dbo].[SecureTest]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[VALUE] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[SecureTest] TO [SecureTableOnly]
GO
GRANT DELETE ON  [dbo].[SecureTest] TO [SecureTableOnly]
GO
GRANT UPDATE ON  [dbo].[SecureTest] TO [SecureTableOnly]
GO
