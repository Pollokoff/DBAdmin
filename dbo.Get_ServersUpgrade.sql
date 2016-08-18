SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Get_ServersUpgrade]
AS

SELECT ServerID,
       Servername,
       ServerVersion,
	   Upgrade,
	   'New' AS TestColumn
	
FROM dbo.Server_SQL_Details
GO
