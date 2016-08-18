SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[WesDemo]
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
Version,
LocationID,
DMZ
FROM dbo.SQLServers
GO
