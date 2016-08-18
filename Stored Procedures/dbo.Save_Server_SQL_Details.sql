SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Save_Server_SQL_Details]
AS
TRUNCATE TABLE Server_SQL_Details_Save

INSERT dbo.Server_SQL_Details_Save
(ServerID,
 Servername,
 ServerVersion,
 Upgrade
 )
SELECT ServerID,
       Servername,
       ServerVersion,
       Upgrade
FROM Server_SQL_Details
GO
