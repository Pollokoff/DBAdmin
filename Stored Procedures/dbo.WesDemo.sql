SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
ALTER PROC [dbo].[WesDemo]
AS

SELECT 
ServerName,
InstanceName,
IP,
GUID,
PROD,
DateLastLogErrorImported,
DOMAIN,
Purpose,
Version
FROM dbo.SQLServers
GO
