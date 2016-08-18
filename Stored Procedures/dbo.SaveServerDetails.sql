SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SaveServerDetails]
	@servername VARCHAR(100),
	@instance VARCHAR(100),
	@IP VARCHAR(20),
	@Prod BIT,
	@Domain VARCHAR(50),
	@Purpose NVARCHAR(MAX),
	@Version VARCHAR(5)
AS
BEGIN

	IF EXISTS (SELECT 1 FROM sqlservers WHERE ServerName = @servername)
	BEGIN
	
	
		UPDATE dbo.SQLServers
		SET InstanceName = @instance,
			IP = @IP,
			PROD = @Prod,
			DOMAIN = @Domain,
			LocationID = CASE 
							WHEN @Domain = 'LOE' THEN 1
							WHEN @Domain = 'LAUREATE' THEN 3
							WHEN @Domain = 'USA' THEN 5
							ELSE 0 END,
			DMZ = 0,
			Purpose = @Purpose,
			Version = @Version
		WHERE ServerName = @servername
	END
	ELSE
	BEGIN
		INSERT SQLServers(ServerName,InstanceName,IP,PROD,DOMAIN,LocationID,DMZ,Purpose,[Version])
		SELECT @servername,
				@instance,
			 @IP,
			@Prod,
			@Domain,
			CASE 
							WHEN @Domain = 'LOE' THEN 1
							WHEN @Domain = 'LAUREATE' THEN 3
							WHEN @Domain = 'USA' THEN 5
							ELSE 0 END,
			0,
			@Purpose,
			@Version

	END
END
GO
