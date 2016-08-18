CREATE TABLE [dbo].[Email_Addresses]
(
[Email_Address] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[alert_function] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  CREATE TRIGGER [dbo].[tr_emailaddress] ON [dbo].[Email_Addresses]
  FOR INSERT
	as
		SELECT * FROM INSERTED
        
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  CREATE TRIGGER [dbo].[tru_emailaddress] ON [dbo].[Email_Addresses]
  FOR update
	as
   DECLARE @sql AS NVARCHAR(1024);
    SET @sql = ''
    SELECT  @sql = COALESCE(@sql + ','
                            + QUOTENAME(column_name),
                            QUOTENAME(column_name))
    FROM    INFORMATION_SCHEMA.COLUMNS
    WHERE   SUBSTRING(COLUMNS_UPDATED(),
                      ORDINAL_POSITION
                      / 8 + 1, 1) & POWER(2,
                                          -1
                                          + ORDINAL_POSITION % 8) > 0
            AND table_name = 'Email_Addresses'

			SELECT @sql
GO
