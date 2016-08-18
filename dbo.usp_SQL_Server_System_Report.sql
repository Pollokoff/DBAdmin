SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-----------------------------------------------------------------------------------------------------------------------------
--	Stored Procedure Details: Listing Of Standard Details Related To The Stored Procedure
-----------------------------------------------------------------------------------------------------------------------------

--	Purpose: SQL Server System Report
--	Create Date (MM/DD/YYYY): 05/12/2010
--	Developer: Sean Smith (s.smith.sql AT gmail DOT com)
--	Additional Notes: N/A


-----------------------------------------------------------------------------------------------------------------------------
--	Modification History: Listing Of All Modifications Since Original Implementation
-----------------------------------------------------------------------------------------------------------------------------

--	Description: Added "@Output_Mode" And "@Unused_Index_Days" Input Parameters, Code Restructuring For Better Query Performance, Minor Changes To Code Style
--	Date (MM/DD/YYYY): 12/22/2011
--	Developer: Sean Smith (s.smith.sql AT gmail DOT com)
--	Additional Notes: N/A


--	Description: Added "connections", "first_day_of_week", "is_clustered", And "windows_version" To "Server Instance Property Information" Section
--	Date (MM/DD/YYYY): 12/23/2011
--	Developer: Sean Smith (s.smith.sql AT gmail DOT com)
--	Additional Notes: N/A


--	Description: Added "create_date" And "file_name" To "Database Recovery Model / Compatibility / Size (Detailed) / Growth Stats" Section
--	Date (MM/DD/YYYY): 01/03/2012
--	Developer: Sean Smith (s.smith.sql AT gmail DOT com)
--	Additional Notes: N/A


--	Description: Added "backup_finish_date", "database_version", "machine_name", And "server_name" To "Last Backup Set Details" Section
--	Date (MM/DD/YYYY): 01/04/2012
--	Developer: Sean Smith (s.smith.sql AT gmail DOT com)
--	Additional Notes: N/A


--	Description: "Last Backup Set Details" Section Now Only Shows Information For Databases Currently On The Instance
--	Date (MM/DD/YYYY): 01/17/2012
--	Developer: Sean Smith (s.smith.sql AT gmail DOT com)
--	Additional Notes: N/A


--	Description: Added "schema_name" To "Unused Indexes" Section, Extended "CONVERT" Character Length To Deal With "Msg 234" Error, Rewrote Time Calculation Logic
--	Date (MM/DD/YYYY): 01/20/2012
--	Developer: Sean Smith (s.smith.sql AT gmail DOT com)
--	Additional Notes: N/A


--	Description: Added Additional Input Parameters, Reformatted Code, Bug Fixes, Added New Sections (Server Settings, Index Fragmentation, Missing Indexes)
--	Date (MM/DD/YYYY): 09/20/2013
--	Developer: Sean Smith (s.smith.sql AT gmail DOT com)
--	Additional Notes: N/A
--usp_SQL_Server_System_Report @Output_Mode='E',@Recipients='gordon.pollokoff@laureate.net'

-----------------------------------------------------------------------------------------------------------------------------
--	Main Query: Create Procedure
-----------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[usp_SQL_Server_System_Report]

	 @Output_Mode AS CHAR (1) = NULL
	,@Unused_Index_Days AS INT = 7
	,@Recipients AS VARCHAR (MAX) = NULL
	,@Copy_Recipients AS VARCHAR (MAX) = NULL
	,@Server_Instance AS BIT = 1
	,@Server_Settings AS BIT = 1
	,@Drives_Space AS BIT = 1
	,@Database_Summary AS BIT = 1
	,@Database_Details AS BIT = 1
	,@Last_Backup AS BIT = 1
	,@Agent_Jobs AS BIT = 1
	,@Fragmentation AS BIT = 1
	,@Missing_Indexes AS BIT = 1
	,@Unused_Indexes AS BIT = 1

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
SET ANSI_WARNINGS OFF
SET ARITHABORT OFF
SET ARITHIGNORE ON
SET TEXTSIZE 2147483647


DECLARE @Body AS NVARCHAR (MAX)
DECLARE @Database_ID AS INT
DECLARE @Database_Name_Loop AS NVARCHAR (500)
DECLARE @Date_24_Hours_Ago AS DATETIME
DECLARE @Date_Now AS DATETIME
DECLARE @SQL_Server_Start_Time AS DATETIME
DECLARE @SQL_String AS NVARCHAR (MAX)
DECLARE @Subject AS NVARCHAR (255)
DECLARE @XML_String AS NVARCHAR (MAX)


DECLARE @Database_Names AS TABLE

	(
		database_name SYSNAME PRIMARY KEY CLUSTERED
	)


DECLARE @Fixed_Drives_Free_Space AS TABLE

	(
		 drive_letter VARCHAR (5) PRIMARY KEY CLUSTERED
		,free_space_mb BIGINT
	)


SET @Body = N''
SET @Date_24_Hours_Ago = GETDATE () - 1
SET @Date_Now = @Date_24_Hours_Ago + 1
SET @Subject = N'SQL Server System Report: ' + @@SERVERNAME
SET @XML_String = N''


IF (@Server_Instance = 1 OR @Unused_Indexes = 1)
BEGIN

	SET @SQL_Server_Start_Time =

		(
			SELECT
				DB.create_date
			FROM
				master.sys.databases DB
			WHERE
				DB.name = N'tempdb'
		)

END


INSERT INTO @Database_Names

	(
		database_name
	)

SELECT
	DB.name AS database_name
FROM
	master.sys.databases DB
WHERE
	DB.[state] = 0
	AND DB.is_read_only = 0
	AND DB.is_in_standby = 0
	AND DB.source_database_id IS NULL


-----------------------------------------------------------------------------------------------------------------------------
--	Error Trapping: Check If Temp Table(s) Already Exist(s) And Drop If Applicable
-----------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_instance_property', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_instance_property

END


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_server_settings', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_server_settings

END


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_database_size_distribution_stats', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_database_size_distribution_stats

END


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_model_compatibility_size_growth', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_model_compatibility_size_growth

END


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_last_backup_set', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_last_backup_set

END


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_agent_jobs', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_agent_jobs

END


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_index_fragmentation', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_index_fragmentation

END


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_missing_indexes', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_missing_indexes

END


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_unused_indexes', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_unused_indexes

END


-----------------------------------------------------------------------------------------------------------------------------
--	Main Query I: Server Instance Property Information
-----------------------------------------------------------------------------------------------------------------------------

IF @Server_Instance = 0
BEGIN

	GOTO Skip_Instance_Property

END


SELECT
	 SERVERPROPERTY (N'ComputerNamePhysicalNetBIOS') AS netbios_name
	,@@SERVERNAME AS server_name
	,REPLACE (CONVERT (NVARCHAR (128), SERVERPROPERTY (N'Edition')), ' Edition', '') AS edition
	,SERVERPROPERTY (N'ProductVersion') AS [version]
	,SERVERPROPERTY (N'ProductLevel') AS [level]
	,(CASE SERVERPROPERTY (N'IsClustered')
		WHEN 0 THEN 'No'
		WHEN 1 THEN 'Yes'
		ELSE 'N/A'
		END) AS is_clustered
	,CONVERT (NVARCHAR (19), @SQL_Server_Start_Time, 120) AS online_since
	,(CASE
		WHEN oaDSR.total_days = 0 THEN '_'
		ELSE oaDSR.total_days
		END) + ' Day(s) ' + (CASE
								WHEN oaDSR.seconds_remaining = 0 THEN '__:__:__'
								WHEN oaDSR.seconds_remaining < 60 THEN '__:__:' + RIGHT (oaDSR.total_seconds, 2)
								WHEN oaDSR.seconds_remaining < 3600 THEN '__:' + RIGHT (oaDSR.total_seconds, 5)
								ELSE oaDSR.total_seconds
								END) AS uptime
	,SERVERPROPERTY (N'ProcessID') AS process_id
	,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, @@CONNECTIONS), 1)), 4, 23)) AS connections
	,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, @@TOTAL_READ), 1)), 4, 23)) AS reads
	,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, @@TOTAL_WRITE), 1)), 4, 23)) AS writes
	,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, DOSI.cpu_count), 1)), 4, 23)) AS logical_cpu_count
	,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, DOSI.cpu_count / DOSI.hyperthread_ratio), 1)), 4, 23)) AS physical_cpu_count
	,REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (RIGHT (@@VERSION, CHARINDEX (REVERSE (' on Windows '), REVERSE (@@VERSION)) - 1), 'Service Pack ', 'SP'), '(', ''), ')', ''), '<', '('), '>', ')') AS windows_version
INTO
	dbo.#temp_sssr_instance_property
FROM
	master.sys.dm_os_sys_info DOSI
	CROSS JOIN

		(
			SELECT
				DATEDIFF (SECOND, @SQL_Server_Start_Time, GETDATE ()) AS uptime_seconds
		) sqUTS

	OUTER APPLY

		(
			SELECT
				 CONVERT (VARCHAR (5), sqUTS.uptime_seconds / 86400) AS total_days
				,CONVERT (CHAR (8), DATEADD (SECOND, sqUTS.uptime_seconds % 86400, 0), 108) AS total_seconds
				,sqUTS.uptime_seconds % 86400 AS seconds_remaining
		) oaDSR


IF @@ROWCOUNT = 0
BEGIN

	GOTO Skip_Instance_Property

END


IF @Output_Mode = 'E'
BEGIN

	SET @XML_String =

		CONVERT (NVARCHAR (MAX),
			(
				SELECT
					 '',X.netbios_name AS 'td'
					,'',X.server_name AS 'td'
					,'',X.edition AS 'td'
					,'',X.[version] AS 'td'
					,'',X.[level] AS 'td'
					,'',X.is_clustered AS 'td'
					,'',X.online_since AS 'td'
					,'',X.uptime AS 'td'
					,'',X.process_id AS 'td'
					,'','right_align' + X.connections AS 'td'
					,'','right_align' + X.reads AS 'td'
					,'','right_align' + X.writes AS 'td'
					,'','right_align' + X.logical_cpu_count AS 'td'
					,'','right_align' + X.physical_cpu_count AS 'td'
					,'',X.windows_version AS 'td'
				FROM
					dbo.#temp_sssr_instance_property X
				FOR
					XML PATH ('tr')
			)
		)


	SET @Body = @Body +

		N'
			<h3><center>Server Instance Property Information</center></h3>
			<center>
				<table border=1 cellpadding=2>
					<tr>
						<th>NetBIOS Name</th>
						<th>Server Name</th>
						<th>Edition</th>
						<th>Version</th>
						<th>Level</th>
						<th>Clustered</th>
						<th>Online Since</th>
						<th>Uptime</th>
						<th>Process ID</th>
						<th>Connections</th>
						<th>Reads</th>
						<th>Writes</th>
						<th>Logical CPU Count</th>
						<th>Physical CPU Count</th>
						<th>Windows Version</th>
					</tr>
		 '


	SET @Body = @Body + @XML_String +

		N'
				</table>
			</center>
		 '

END
ELSE BEGIN

	SELECT
		 X.netbios_name
		,X.server_name
		,X.edition
		,X.[version]
		,X.[level]
		,X.is_clustered AS [clustered]
		,X.online_since
		,X.uptime
		,X.process_id
		,X.connections
		,X.reads
		,X.writes
		,X.logical_cpu_count
		,X.physical_cpu_count
		,X.windows_version
	FROM
		dbo.#temp_sssr_instance_property X

END


Skip_Instance_Property:


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_instance_property', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_instance_property

END


-----------------------------------------------------------------------------------------------------------------------------
--	Main Query II: Server Settings
-----------------------------------------------------------------------------------------------------------------------------

IF @Server_Settings = 0
BEGIN

	GOTO Skip_Server_Settings

END


SELECT
	 (CASE @@DATEFIRST
		WHEN 1 THEN 'Monday'
		WHEN 2 THEN 'Tuesday'
		WHEN 3 THEN 'Wednesday'
		WHEN 4 THEN 'Thursday'
		WHEN 5 THEN 'Friday'
		WHEN 6 THEN 'Saturday'
		WHEN 7 THEN 'Sunday'
		ELSE 'N/A'
		END) AS first_day_of_week
	,SERVERPROPERTY (N'Collation') AS collation
	,(CASE
		WHEN 'a' = 'A' THEN 'No'
		ELSE 'Yes'
		END) AS is_case_sensitive
	,(CASE SERVERPROPERTY (N'IsFullTextInstalled')
		WHEN 0 THEN 'No'
		WHEN 1 THEN 'Yes'
		ELSE 'N/A'
		END) AS is_full_text_installed
	,(CASE sqCFG.is_show_advanced_options_enabled
		WHEN 0 THEN 'No'
		WHEN 1 THEN 'Yes'
		ELSE 'N/A'
		END) AS is_show_advanced_options_enabled
	,(CASE sqCFG.is_clr_enabled
		WHEN 0 THEN 'No'
		WHEN 1 THEN 'Yes'
		ELSE 'N/A'
		END) AS is_clr_enabled
	,(CASE sqCFG.is_xp_cmdshell_enabled
		WHEN 0 THEN 'No'
		WHEN 1 THEN 'Yes'
		ELSE 'N/A'
		END) AS is_xp_cmdshell_enabled
	,(CASE sqCFG.is_database_mail_enabled
		WHEN 0 THEN 'No'
		WHEN 1 THEN 'Yes'
		ELSE 'N/A'
		END) AS is_database_mail_enabled
	,(CASE sqCFG.is_default_trace_enabled
		WHEN 0 THEN 'No'
		WHEN 1 THEN 'Yes'
		ELSE 'N/A'
		END) AS is_default_trace_enabled
	,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, sqCFG.min_server_memory_mb), 1)), 4, 23)) AS min_server_memory_mb
	,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, sqCFG.max_server_memory_mb), 1)), 4, 23)) AS max_server_memory_mb
INTO
	dbo.#temp_sssr_server_settings
FROM

	(
		SELECT
			 MAX (CASE
					WHEN CFG.configuration_id = 518 THEN CFG.value
					END) AS is_show_advanced_options_enabled
			,MAX (CASE
					WHEN CFG.configuration_id = 1562 THEN CFG.value
					END) AS is_clr_enabled
			,MAX (CASE
					WHEN CFG.configuration_id = 16390 THEN CFG.value
					END) AS is_xp_cmdshell_enabled
			,MAX (CASE
					WHEN CFG.configuration_id = 16386 THEN CFG.value
					END) AS is_database_mail_enabled
			,MAX (CASE
					WHEN CFG.configuration_id = 1568 THEN CFG.value
					END) AS is_default_trace_enabled
			,MAX (CASE
					WHEN CFG.configuration_id = 1543 THEN CFG.value
					END) AS min_server_memory_mb
			,MAX (CASE
					WHEN CFG.configuration_id = 1544 THEN CFG.value
					END) AS max_server_memory_mb
		FROM
			sys.configurations CFG
		WHERE
			CFG.configuration_id IN (518, 1543, 1544, 1562, 1568, 16386, 16390)
	) sqCFG


IF @@ROWCOUNT = 0
BEGIN

	GOTO Skip_Server_Settings

END


IF @Output_Mode = 'E'
BEGIN

	SET @XML_String =

		CONVERT (NVARCHAR (MAX),
			(
				SELECT
					 '',X.first_day_of_week AS 'td'
					,'',X.collation AS 'td'
					,'',X.is_case_sensitive AS 'td'
					,'',X.is_full_text_installed AS 'td'
					,'',X.is_show_advanced_options_enabled AS 'td'
					,'',X.is_clr_enabled AS 'td'
					,'',X.is_xp_cmdshell_enabled AS 'td'
					,'',X.is_database_mail_enabled AS 'td'
					,'',X.is_default_trace_enabled AS 'td'
					,'','right_align' + X.min_server_memory_mb AS 'td'
					,'','right_align' + X.max_server_memory_mb AS 'td'
				FROM
					dbo.#temp_sssr_server_settings X
				FOR
					XML PATH ('tr')
			)
		)


	SET @Body = @Body +

		N'
			<h3><center>Server Settings</center></h3>
			<center>
				<table border=1 cellpadding=2>
					<tr>
						<th>First Day Of Week</th>
						<th>Collation</th>
						<th>Case Sensitive</th>
						<th>Full-Text Installed</th>
						<th>Advanced Options Enabled</th>
						<th>CLR Enabled</th>
						<th>Command Shell Enabled</th>
						<th>Database Mail Enabled</th>
						<th>Default Trace Enabled</th>
						<th>Minimum Memory (MB)</th>
						<th>Maximum Memory (MB)</th>
					</tr>
		 '


	SET @Body = @Body + @XML_String +

		N'
				</table>
			</center>
		 '

END
ELSE BEGIN

	SELECT
		 X.first_day_of_week
		,X.collation
		,X.is_case_sensitive AS case_sensitive
		,X.is_full_text_installed AS full_text_installed
		,X.is_show_advanced_options_enabled AS advanced_options_enabled
		,X.is_clr_enabled AS clr_enabled
		,X.is_xp_cmdshell_enabled AS command_shell_enabled
		,X.is_database_mail_enabled AS database_mail_enabled
		,X.is_default_trace_enabled AS default_trace_enabled
		,X.min_server_memory_mb AS minimum_memory_mb
		,X.max_server_memory_mb AS maximum_memory_mb
	FROM
		dbo.#temp_sssr_server_settings X

END


Skip_Server_Settings:


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_server_settings', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_server_settings

END


-----------------------------------------------------------------------------------------------------------------------------
--	Main Query III: Fixed Drives Free Space
-----------------------------------------------------------------------------------------------------------------------------

IF @Drives_Space = 0
BEGIN

	GOTO Skip_Fixed_Drives_Free_Space

END


INSERT INTO @Fixed_Drives_Free_Space

	(
		 drive_letter
		,free_space_mb
	)

EXECUTE master.dbo.xp_fixeddrives


IF @@ROWCOUNT = 0
BEGIN

	GOTO Skip_Fixed_Drives_Free_Space

END


IF @Output_Mode = 'E'
BEGIN

	SET @XML_String =

		CONVERT (NVARCHAR (MAX),
			(
				SELECT
					 '',X.drive_letter + ':' AS 'td'
					,'','right_align' + REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, X.free_space_mb), 1)), 4, 23)) AS 'td'
				FROM
					@Fixed_Drives_Free_Space X
				ORDER BY
					X.drive_letter
				FOR
					XML PATH ('tr')
			)
		)


	SET @Body = @Body +

		N'
			<br><br>
			<h3><center>Fixed Drives Free Space</center></h3>
			<center>
				<table border=1 cellpadding=2>
					<tr>
						<th>Drive Letter</th>
						<th>Free Space (MB)</th>
					</tr>
		 '


	SET @Body = @Body + @XML_String +

		N'
				</table>
			</center>
		 '

END
ELSE BEGIN

	SELECT
		 X.drive_letter + ':' AS drive_letter
		,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, X.free_space_mb), 1)), 4, 23)) AS free_space_mb
	FROM
		@Fixed_Drives_Free_Space X
	ORDER BY
		X.drive_letter

END


Skip_Fixed_Drives_Free_Space:


-----------------------------------------------------------------------------------------------------------------------------
--	Main Query IV: Database Size (Summary) / Distribution Stats
-----------------------------------------------------------------------------------------------------------------------------

IF @Database_Summary = 0
BEGIN

	GOTO Skip_Database_Size_Distribution_Stats

END


CREATE TABLE dbo.#temp_sssr_database_size_distribution_stats

	(
		 database_name NVARCHAR (500)
		,total_size_mb VARCHAR (15)
		,unallocated_mb VARCHAR (15)
		,reserved_mb VARCHAR (15)
		,data_mb VARCHAR (15)
		,index_mb VARCHAR (15)
		,unused_mb VARCHAR (15)
	)


SET @Database_Name_Loop =

	(
		SELECT TOP (1)
			tvDBN.database_name
		FROM
			@Database_Names tvDBN
		ORDER BY
			tvDBN.database_name
	)


WHILE @Database_Name_Loop IS NOT NULL
BEGIN

	SET @SQL_String =

		N'
			USE [' + @Database_Name_Loop + N'];


			INSERT INTO dbo.#temp_sssr_database_size_distribution_stats

				(
					 database_name
					,total_size_mb
					,unallocated_mb
					,reserved_mb
					,data_mb
					,index_mb
					,unused_mb
				)

			SELECT
				 DB_NAME () AS database_name
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND ((sqDBF.total_size * CONVERT (BIGINT, 8192)) / 1048576.0, 0)), 1)), 4, 23)) AS total_size_mb
				,(CASE
					WHEN sqDBF.database_size >= cjPGS.total_pages THEN REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND (((sqDBF.database_size - cjPGS.total_pages) * CONVERT (BIGINT, 8192)) / 1048576.0, 0)), 1)), 4, 23))
					ELSE ''0''
					END) AS unallocated_mb
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND ((cjPGS.total_pages * CONVERT (BIGINT, 8192)) / 1048576.0, 0)), 1)), 4, 23)) AS reserved_mb
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND ((cjPGS.pages * CONVERT (BIGINT, 8192)) / 1048576.0, 0)), 1)), 4, 23)) AS data_mb
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND (((cjPGS.used_pages - cjPGS.pages) * CONVERT (BIGINT, 8192)) / 1048576.0, 0)), 1)), 4, 23)) AS index_mb
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND (((cjPGS.total_pages - cjPGS.used_pages) * CONVERT (BIGINT, 8192)) / 1048576.0, 0)), 1)), 4, 23)) AS unused_mb
			FROM

				(
					SELECT
						 SUM (CASE
								WHEN DBF.[type] = 0 THEN DBF.size
								ELSE 0
								END) AS database_size
						,SUM (DBF.size) AS total_size
					FROM
						sys.database_files AS DBF
					WHERE
						DBF.[type] IN (0, 1)
				) sqDBF

				CROSS JOIN

					(
						SELECT
							 SUM (AU.total_pages) AS total_pages
							,SUM (AU.used_pages) AS used_pages
							,SUM (CASE
									WHEN IT.internal_type IN (202, 204) THEN 0
									WHEN AU.[type] <> 1 THEN AU.used_pages
									WHEN P.index_id <= 1 THEN AU.data_pages
									ELSE 0
									END) AS pages
						FROM
							sys.partitions P
							INNER JOIN sys.allocation_units AU ON AU.container_id = P.partition_id
							LEFT JOIN sys.internal_tables IT ON IT.[object_id] = P.[object_id]
					) cjPGS
		 '


	EXECUTE (@SQL_String)


	SET @Database_Name_Loop =

		(
			SELECT TOP (1)
				tvDBN.database_name
			FROM
				@Database_Names tvDBN
			WHERE
				tvDBN.database_name > @Database_Name_Loop
			ORDER BY
				tvDBN.database_name
		)

END


IF NOT EXISTS (SELECT * FROM dbo.#temp_sssr_database_size_distribution_stats X)
BEGIN

	GOTO Skip_Database_Size_Distribution_Stats

END


IF @Output_Mode = 'E'
BEGIN

	SET @XML_String =

		CONVERT (NVARCHAR (MAX),
			(
				SELECT
					 '',X.database_name AS 'td'
					,'','right_align' + X.total_size_mb AS 'td'
					,'','right_align' + X.unallocated_mb AS 'td'
					,'','right_align' + X.reserved_mb AS 'td'
					,'','right_align' + X.data_mb AS 'td'
					,'','right_align' + X.index_mb AS 'td'
					,'','right_align' + X.unused_mb AS 'td'
				FROM
					dbo.#temp_sssr_database_size_distribution_stats X
				ORDER BY
					X.database_name
				FOR
					XML PATH ('tr')
			)
		)


	SET @Body = @Body +

		N'
			<br><br>
			<h3><center>Database Size (Summary) / Distribution Stats</center></h3>
			<center>
				<table border=1 cellpadding=2>
					<tr>
						<th>Database Name</th>
						<th>Total Size (MB)</th>
						<th>Unallocated (MB)</th>
						<th>Reserved (MB)</th>
						<th>Data (MB)</th>
						<th>Index (MB)</th>
						<th>Unused (MB)</th>
					</tr>
		 '


	SET @Body = @Body + @XML_String +

		N'
				</table>
			</center>
		 '

END
ELSE BEGIN

	SELECT
		 X.database_name
		,X.total_size_mb
		,X.unallocated_mb
		,X.reserved_mb
		,X.data_mb
		,X.index_mb
		,X.unused_mb
	FROM
		dbo.#temp_sssr_database_size_distribution_stats X
	ORDER BY
		X.database_name

END


Skip_Database_Size_Distribution_Stats:


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_database_size_distribution_stats', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_database_size_distribution_stats

END


-----------------------------------------------------------------------------------------------------------------------------
--	Main Query V: Database Recovery Model / Compatibility / Size (Detailed) / Growth Stats
-----------------------------------------------------------------------------------------------------------------------------

IF @Database_Details = 0
BEGIN

	GOTO Skip_Model_Compatibility_Size_Growth

END


SELECT
	 DB_NAME (MF.database_id) AS database_name
	,DB.recovery_model_desc
	,DB.[compatibility_level]
	,CONVERT (NVARCHAR (10), LEFT (UPPER (MF.type_desc), 1) + LOWER (SUBSTRING (MF.type_desc, 2, 250))) AS file_type
	,MF.name AS [file_name]
	,CONVERT (NVARCHAR (19), DB.create_date, 120) AS create_date
	,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND ((MF.size * CONVERT (BIGINT, 8192)) / 1048576.0, 0)), 1)), 4, 23)) AS file_size_mb
	,RIGHT ((CASE
				WHEN MF.growth = 0 THEN 'Fixed Size'
				WHEN MF.max_size = -1 THEN 'Unrestricted'
				WHEN MF.max_size = 0 THEN 'None'
				WHEN MF.max_size = 268435456 THEN '2 TB'
				ELSE REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND ((MF.max_size * CONVERT (BIGINT, 8192)) / 1048576.0, 0)), 1)), 4, 23)) + ' MB'
				END), 15) AS max_size
	,RIGHT ((CASE
				WHEN MF.growth = 0 THEN 'N/A'
				WHEN MF.is_percent_growth = 1 THEN REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, MF.growth), 1)), 4, 23)) + ' %'
				ELSE REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND ((MF.growth * CONVERT (BIGINT, 8192)) / 1048576.0, 0)), 1)), 4, 23)) + ' MB'
				END), 15) AS growth_increment
	,ROW_NUMBER () OVER
						(
							PARTITION BY
								MF.database_id
							ORDER BY
								 MF.[type]
								,(CASE
									WHEN MF.[file_id] = 1 THEN 10
									ELSE 99
									END)
								,MF.name
						) AS database_filter_id
INTO
	dbo.#temp_sssr_model_compatibility_size_growth
FROM
	master.sys.master_files MF
	INNER JOIN master.sys.databases DB ON DB.database_id = MF.database_id


IF @@ROWCOUNT = 0
BEGIN

	GOTO Skip_Model_Compatibility_Size_Growth

END


IF @Output_Mode = 'E'
BEGIN

	SET @XML_String =

		CONVERT (NVARCHAR (MAX),
			(
				SELECT
					 '',(CASE
							WHEN X.database_filter_id = 1 THEN X.database_name
							ELSE ''
							END) AS 'td'
					,'',(CASE
							WHEN X.database_filter_id = 1 THEN X.recovery_model_desc
							ELSE ''
							END) AS 'td'
					,'',(CASE
							WHEN X.database_filter_id = 1 THEN ISNULL (CONVERT (VARCHAR (5), X.[compatibility_level]), 'N/A')
							ELSE ''
							END) AS 'td'
					,'',X.file_type AS 'td'
					,'',X.[file_name] AS 'td'
					,'',X.create_date AS 'td'
					,'','right_align' + X.file_size_mb AS 'td'
					,'','right_align' + X.max_size AS 'td'
					,'','right_align' + X.growth_increment AS 'td'
				FROM
					dbo.#temp_sssr_model_compatibility_size_growth X
				ORDER BY
					 X.database_name
					,X.database_filter_id
				FOR
					XML PATH ('tr')
			)
		)


	SET @Body = @Body +

		N'
			<br><br>
			<h3><center>Database Recovery Model / Compatibility / Size (Detailed) / Growth Stats</center></h3>
			<center>
				<table border=1 cellpadding=2>
					<tr>
						<th>Database Name</th>
						<th>Recovery Model</th>
						<th>Compatibility</th>
						<th>File Type</th>
						<th>File Name</th>
						<th>Create Date</th>
						<th>File Size (MB)</th>
						<th>Max Size</th>
						<th>Growth Increment</th>
					</tr>
		 '


	SET @Body = @Body + @XML_String +

		N'
				</table>
			</center>
		 '

END
ELSE BEGIN

	SELECT
		 (CASE
			WHEN X.database_filter_id = 1 THEN X.database_name
			ELSE ''
			END) AS database_name
		,(CASE
			WHEN X.database_filter_id = 1 THEN X.recovery_model_desc
			ELSE ''
			END) AS recovery_model
		,(CASE
			WHEN X.database_filter_id = 1 THEN ISNULL (CONVERT (VARCHAR (5), X.[compatibility_level]), 'N/A')
			ELSE ''
			END) AS compatibility
		,X.file_type
		,X.[file_name]
		,X.create_date
		,X.file_size_mb
		,X.max_size
		,X.growth_increment
	FROM
		dbo.#temp_sssr_model_compatibility_size_growth X
	ORDER BY
		 X.database_name
		,X.database_filter_id

END


Skip_Model_Compatibility_Size_Growth:


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_model_compatibility_size_growth', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_model_compatibility_size_growth

END


-----------------------------------------------------------------------------------------------------------------------------
--	Main Query VI: Last Backup Set Details
-----------------------------------------------------------------------------------------------------------------------------

IF @Last_Backup = 0
BEGIN

	GOTO Skip_Last_Backup_Set

END


SELECT
	 DB.name AS database_name
	,ISNULL (CONVERT (VARCHAR (10), sqBS.backup_set_id), 'NONE') AS backup_set_id
	,(CASE sqBS.[type]
		WHEN 'D' THEN 'Database'
		WHEN 'F' THEN 'File Or Filegroup'
		WHEN 'G' THEN 'Differential File'
		WHEN 'I' THEN 'Differential Database'
		WHEN 'L' THEN 'Log'
		WHEN 'P' THEN 'Partial'
		WHEN 'Q' THEN 'Differential Partial'
		ELSE 'N/A'
		END) AS backup_type
	,ISNULL (CONVERT (VARCHAR (10), sqBS.database_version), 'N/A') AS database_version
	,ISNULL (sqBS.server_name, 'N/A') AS server_name
	,ISNULL (sqBS.machine_name, 'N/A') AS machine_name
	,ISNULL (CONVERT (VARCHAR (34), sqBS.backup_start_date, 120), 'N/A') AS backup_start_date
	,ISNULL (CONVERT (VARCHAR (34), sqBS.backup_finish_date, 120), 'N/A') AS backup_finish_date
	,ISNULL ((CASE
				WHEN sqBS.total_days = 0 THEN REPLICATE ('_', sqBS.day_length_max)
				ELSE REPLICATE ('0', sqBS.day_length_max - LEN (sqBS.total_days)) + sqBS.total_days
				END) + ' Day(s) ' + (CASE
										WHEN sqBS.seconds_remaining = 0 THEN '__:__:__'
										WHEN sqBS.seconds_remaining < 60 THEN '__:__:'+RIGHT (sqBS.total_seconds, 2)
										WHEN sqBS.seconds_remaining < 3600 THEN '__:'+RIGHT (sqBS.total_seconds, 5)
										ELSE sqBS.total_seconds
										END), 'N/A') AS duration
	,ISNULL (REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ROUND (sqBS.backup_size / 1048576.0, 0)), 1)), 4, 23)), 'N/A') AS backup_size_mb
	,ISNULL (REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, DATEDIFF (DAY, sqBS.backup_start_date, GETDATE ())), 1)), 4, 23)), 'N/A') AS days_ago
	,ROW_NUMBER () OVER
						(
							PARTITION BY
								DB.name
							ORDER BY
								sqBS.[type]
						) AS database_filter_id
INTO
	dbo.#temp_sssr_last_backup_set
FROM
	master.sys.databases DB
	LEFT JOIN

		(
			SELECT
				 BS.database_name
				,BS.backup_set_id
				,BS.[type]
				,BS.database_version
				,BS.server_name
				,BS.machine_name
				,BS.backup_start_date
				,BS.backup_finish_date
				,BS.backup_size
				,cjDLM.day_length_max
				,oaDSR.seconds_remaining
				,oaDSR.total_days
				,oaDSR.total_seconds
			FROM
				msdb.dbo.backupset BS
				INNER JOIN

					(
						SELECT
							MAX (XBS.backup_set_id) AS backup_set_id_max
						FROM
							msdb.dbo.backupset XBS
						GROUP BY
							 XBS.database_name
							,XBS.[type]
					) sqMBS ON sqMBS.backup_set_id_max = BS.backup_set_id

				CROSS JOIN

					(
						SELECT
							MAX (LEN (DATEDIFF (DAY, YBS.backup_start_date, YBS.backup_finish_date))) AS day_length_max
						FROM
							msdb.dbo.backupset YBS
					) cjDLM

				OUTER APPLY

					(
						SELECT
							DATEDIFF (SECOND, BS.backup_start_date, BS.backup_finish_date) AS duration_seconds
					) oaDS

				OUTER APPLY

					(
						SELECT
							 CONVERT (VARCHAR (5), oaDS.duration_seconds / 86400) AS total_days
							,CONVERT (CHAR (8), DATEADD (SECOND, oaDS.duration_seconds % 86400, 0), 108) AS total_seconds
							,oaDS.duration_seconds % 86400 AS seconds_remaining
					) oaDSR

		) sqBS ON sqBS.database_name = DB.name

WHERE
	DB.name <> N'tempdb'


IF @@ROWCOUNT = 0
BEGIN

	GOTO Skip_Last_Backup_Set

END


IF EXISTS (SELECT * FROM dbo.#temp_sssr_last_backup_set X WHERE X.backup_set_id = 'NONE')
BEGIN

	UPDATE
		dbo.#temp_sssr_last_backup_set
	SET
		 backup_type = REPLICATE ('.', backup_type_length_max * 2)
		,database_version = REPLICATE ('.', database_version_length_max * 2)
		,server_name = REPLICATE ('.', server_name_length_max * 2)
		,machine_name = REPLICATE ('.', machine_name_length_max * 2)
		,backup_start_date = REPLICATE ('.', 34)
		,backup_finish_date = REPLICATE ('.', 34)
		,duration = REPLICATE ('.', (duration_length_max * 2) - 4)
		,backup_size_mb = REPLICATE ('.', backup_size_mb_length_max * 2)
	FROM

		(
			SELECT
				 MAX (LEN (X.backup_type)) AS backup_type_length_max
				,MAX (LEN (X.database_version)) AS database_version_length_max
				,MAX (LEN (X.server_name)) AS server_name_length_max
				,MAX (LEN (X.machine_name)) AS machine_name_length_max
				,MAX (LEN (X.duration)) AS duration_length_max
				,MAX (LEN (X.backup_size_mb)) AS backup_size_mb_length_max
			FROM
				dbo.#temp_sssr_last_backup_set X
		) sqX

	WHERE
		dbo.#temp_sssr_last_backup_set.backup_set_id = 'NONE'

END


IF @Output_Mode = 'E'
BEGIN

	SET @XML_String =

		CONVERT (NVARCHAR (MAX),
			(
				SELECT
					 '',(CASE
							WHEN X.database_filter_id = 1 THEN X.database_name
							ELSE ''
							END) AS 'td'
					,'',X.backup_set_id AS 'td'
					,'',X.backup_type AS 'td'
					,'',X.database_version AS 'td'
					,'',X.server_name AS 'td'
					,'',X.machine_name AS 'td'
					,'',X.backup_start_date AS 'td'
					,'',X.backup_finish_date AS 'td'
					,'',X.duration AS 'td'
					,'','right_align' + X.backup_size_mb AS 'td'
					,'','right_align' + X.days_ago AS 'td'
				FROM
					dbo.#temp_sssr_last_backup_set X
				ORDER BY
					 X.database_name
					,X.database_filter_id
				FOR
					XML PATH ('tr')
			)
		)


	SET @Body = @Body +

		N'
			<br><br>
			<h3><center>Last Backup Set Details</center></h3>
			<center>
				<table border=1 cellpadding=2>
					<tr>
						<th>Database Name</th>
						<th>Backup Set ID</th>
						<th>Backup Type</th>
						<th>Database Version</th>
						<th>Server Name</th>
						<th>Machine Name</th>
						<th>Backup Start Date</th>
						<th>Backup Finish Date</th>
						<th>Duration</th>
						<th>Backup Size (MB)</th>
						<th>Days Ago</th>
					</tr>
		 '


	SET @Body = @Body + @XML_String +

		N'
				</table>
			</center>
		 '

END
ELSE BEGIN

	SELECT
		 (CASE
			WHEN X.database_filter_id = 1 THEN X.database_name
			ELSE ''
			END) AS database_name
		,X.backup_set_id
		,X.backup_type
		,X.database_version
		,X.server_name
		,X.machine_name
		,X.backup_start_date
		,X.backup_finish_date
		,X.duration
		,X.backup_size_mb
		,X.days_ago
	FROM
		dbo.#temp_sssr_last_backup_set X
	ORDER BY
		 X.database_name
		,X.database_filter_id

END


Skip_Last_Backup_Set:


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_last_backup_set', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_last_backup_set

END


-----------------------------------------------------------------------------------------------------------------------------
--	Main Query VII: SQL Server Agent Jobs (Last 24 Hours)
-----------------------------------------------------------------------------------------------------------------------------

IF @Agent_Jobs = 0
BEGIN

	GOTO Skip_Agent_Jobs

END


SELECT
	 SJ.name AS job_name
	,CONVERT (VARCHAR (19), caLRDT.last_run_date_time, 120) AS last_run_date_time
	,(CASE SJH.run_status
		WHEN 0 THEN 'Failed'
		WHEN 1 THEN 'Succeeded'
		WHEN 2 THEN 'Retry'
		WHEN 3 THEN 'Canceled'
		WHEN 4 THEN 'In Progress'
		END) AS last_status
	,(CASE
		WHEN SJH.run_duration = 0 THEN '__:__:__'
		WHEN LEN (SJH.run_duration) <= 2 THEN '__:__:' + RIGHT ('0' + CONVERT (VARCHAR (2), SJH.run_duration), 2)
		WHEN LEN (SJH.run_duration) <= 4 THEN '__:' + STUFF (RIGHT ('0' + CONVERT (VARCHAR (4), SJH.run_duration), 4), 3, 0, ':')
		ELSE STUFF (STUFF (RIGHT ('0' + CONVERT (VARCHAR (6), SJH.run_duration), 6), 5, 0, ':'), 3, 0, ':')
		END) AS duration
	,ISNULL ((CASE
				WHEN SJ.[enabled] = 1 THEN CONVERT (VARCHAR (19), sqNRDT.next_run_date_time, 120)
				END), '___________________') AS next_run_date_time
	,ISNULL ((CASE
				WHEN SJ.[enabled] = 1 THEN REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, DATEDIFF (DAY, GETDATE (), sqNRDT.next_run_date_time)), 1)), 4, 23))
				END), 'N/A') AS days_away
INTO
	dbo.#temp_sssr_agent_jobs
FROM
	msdb.dbo.sysjobs SJ
	INNER JOIN msdb.dbo.sysjobhistory SJH ON SJH.job_id = SJ.job_id
	INNER JOIN

		(
			SELECT
				MAX (XSJ.instance_id) AS instance_id_max
			FROM
				msdb.dbo.sysjobhistory XSJ
			GROUP BY
				XSJ.job_id
		) sqIIM ON sqIIM.instance_id_max = SJH.instance_id

	LEFT JOIN

		(
			SELECT
				 SJS.job_id
				,MIN (CONVERT (DATETIME, CONVERT (VARCHAR (8), SJS.next_run_date) + ' ' + STUFF (STUFF (RIGHT ('000000' + CONVERT (VARCHAR (6), SJS.next_run_time), 6), 5, 0, ':'), 3, 0, ':'))) AS next_run_date_time
			FROM
				msdb.dbo.sysjobschedules SJS
				INNER JOIN msdb.dbo.sysschedules SS ON SS.schedule_id = SJS.schedule_id
					AND SS.[enabled] = 1
			WHERE
				SJS.next_run_date > 0
			GROUP BY
				SJS.job_id
		) sqNRDT ON sqNRDT.job_id = SJ.job_id

	CROSS APPLY

		(
			SELECT
				CONVERT (DATETIME, CONVERT (VARCHAR (8), SJH.run_date) + ' ' + STUFF (STUFF (RIGHT ('000000' + CONVERT (VARCHAR (6), SJH.run_time), 6), 5, 0, ':'), 3, 0, ':')) AS last_run_date_time
		) caLRDT

WHERE
	caLRDT.last_run_date_time >= @Date_24_Hours_Ago


IF @@ROWCOUNT = 0
BEGIN

	GOTO Skip_Agent_Jobs

END


IF @Output_Mode = 'E'
BEGIN

	SET @XML_String =

		CONVERT (NVARCHAR (MAX),
			(
				SELECT
					 '',X.job_name AS 'td'
					,'',X.last_run_date_time AS 'td'
					,'',X.last_status AS 'td'
					,'',X.duration AS 'td'
					,'',X.next_run_date_time AS 'td'
					,'','right_align' + X.days_away AS 'td'
				FROM
					dbo.#temp_sssr_agent_jobs X
				ORDER BY
					X.job_name
				FOR
					XML PATH ('tr')
			)
		)


	SET @Body = @Body +

		N'
			<br><br>
			<h3><center>SQL Server Agent Jobs (Last 24 Hours)</center></h3>
			<center>
				<table border=1 cellpadding=2>
					<tr>
						<th>Job Name</th>
						<th>Last Run Date / Time</th>
						<th>Last Status</th>
						<th>Duration</th>
						<th>Next Run Date / Time</th>
						<th>Days Away</th>
					</tr>
		 '


	SET @Body = @Body + @XML_String +

		N'
				</table>
			</center>
		 '

END
ELSE BEGIN

	SELECT
		 X.job_name
		,X.last_run_date_time
		,X.last_status
		,X.duration
		,X.next_run_date_time
		,X.days_away
	FROM
		dbo.#temp_sssr_agent_jobs X
	ORDER BY
		X.job_name

END


Skip_Agent_Jobs:


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_agent_jobs', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_agent_jobs

END


-----------------------------------------------------------------------------------------------------------------------------
--	Main Query VIII: Index Fragmentation
-----------------------------------------------------------------------------------------------------------------------------

IF @Fragmentation = 0
BEGIN

	GOTO Skip_Index_Fragmentation

END


CREATE TABLE dbo.#temp_sssr_index_fragmentation

	(
		 database_name NVARCHAR (512)
		,[schema_name] SYSNAME
		,[object_name] SYSNAME
		,column_name SYSNAME
		,index_name SYSNAME
		,fragmentation VARCHAR (23)
		,index_type NVARCHAR (120)
		,is_pk VARCHAR (3)
		,is_unique VARCHAR (3)
		,recommendation VARCHAR (10)
		,alter_index_statement NVARCHAR (4000)
	)


SET @Database_Name_Loop =

	(
		SELECT TOP (1)
			tvDBN.database_name
		FROM
			@Database_Names tvDBN
		ORDER BY
			tvDBN.database_name
	)


WHILE @Database_Name_Loop IS NOT NULL
BEGIN

	SET @Database_ID = DB_ID (@Database_Name_Loop)


	SET @SQL_String =

		N'
			USE [' + @Database_Name_Loop + N'];


			INSERT INTO dbo.#temp_sssr_index_fragmentation

				(
					 database_name
					,[schema_name]
					,[object_name]
					,column_name
					,index_name
					,fragmentation
					,index_type
					,is_pk
					,is_unique
					,recommendation
					,alter_index_statement
				)


			SELECT
				 DB_NAME () AS database_name
				,SCHEMA_NAME (sqIF.[schema_id]) AS [schema_name]
				,sqIF.[object_name]
				,sqIF.column_name
				,sqIF.index_name
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, sqIF.avg_fragmentation_in_percent), 1)), 1, 23)) AS fragmentation
				,sqIF.type_desc AS index_type
				,(CASE sqIF.is_primary_key
					WHEN 0 THEN ''No''
					WHEN 1 THEN ''Yes''
					ELSE ''N/A''
					END) AS is_pk
				,(CASE sqIF.is_unique
					WHEN 0 THEN ''No''
					WHEN 1 THEN ''Yes''
					ELSE ''N/A''
					END) AS is_unique
				,caREC.recommendation
				,N''USE ['' + DB_NAME () + N'']; ALTER INDEX ['' + sqIF.index_name + ''] ON ['' + SCHEMA_NAME (sqIF.[schema_id]) + ''].['' + sqIF.[object_name] + ''] '' + (CASE caREC.recommendation
																																												WHEN ''REBUILD'' THEN caREC.recommendation + '' WITH (MAXDOP = 1)''
																																												ELSE caREC.recommendation
																																												END) + '';'' AS alter_index_statement
			FROM

				(
					SELECT
						 O.[schema_id]
						,O.name AS [object_name]
						,C.name AS column_name
						,I.name AS index_name
						,DDIPS.avg_fragmentation_in_percent
						,I.type_desc
						,I.is_primary_key
						,I.is_unique
						,ROW_NUMBER () OVER
										(
											PARTITION BY
												I.name
											ORDER BY
												DDIPS.avg_fragmentation_in_percent DESC
										) AS row_number_id
					FROM
						sys.dm_db_index_physical_stats (' + CONVERT (VARCHAR (11), @Database_ID) + ', NULL, NULL, NULL, N''LIMITED'') DDIPS
						INNER JOIN sys.objects O ON O.[object_id] = DDIPS.[object_id]
							AND O.is_ms_shipped = 0
						INNER JOIN sys.indexes I ON I.[object_id] = DDIPS.[object_id]
							AND I.index_id = DDIPS.index_id
							AND I.is_disabled <> 1
							AND I.is_hypothetical <> 1
						INNER JOIN sys.index_columns IC ON IC.[object_id] = DDIPS.[object_id]
							AND IC.index_id = DDIPS.index_id
						INNER JOIN sys.columns C ON C.[object_id] = DDIPS.[object_id]
							AND C.column_id = IC.column_id
					WHERE
						DDIPS.index_id <> 0
						AND DDIPS.avg_fragmentation_in_percent > 5
				) sqIF

				CROSS APPLY

					(
						SELECT
							(CASE
								WHEN sqIF.avg_fragmentation_in_percent <= 30.0 THEN ''REORGANIZE''
								ELSE ''REBUILD''
								END) AS recommendation
					) caREC

			WHERE
				sqIF.row_number_id = 1
		 '


	EXECUTE (@SQL_String)


	SET @Database_Name_Loop =

		(
			SELECT TOP (1)
				tvDBN.database_name
			FROM
				@Database_Names tvDBN
			WHERE
				tvDBN.database_name > @Database_Name_Loop
			ORDER BY
				tvDBN.database_name
		)

END


IF NOT EXISTS (SELECT * FROM dbo.#temp_sssr_index_fragmentation X)
BEGIN

	GOTO Skip_Index_Fragmentation

END


IF @Output_Mode = 'E'
BEGIN

	SET @XML_String =

		CONVERT (NVARCHAR (MAX),
			(
				SELECT
					 '',X.database_name AS 'td'
					,'',X.[schema_name] AS 'td'
					,'',X.[object_name] AS 'td'
					,'',X.column_name AS 'td'
					,'',X.index_name AS 'td'
					,'','right_align' + X.fragmentation AS 'td'
					,'',X.index_type AS 'td'
					,'',X.is_pk AS 'td'
					,'',X.is_unique AS 'td'
					,'',X.recommendation AS 'td'
					,'',X.alter_index_statement AS 'td'
				FROM
					dbo.#temp_sssr_index_fragmentation X
				ORDER BY
					 X.database_name
					,X.[schema_name]
					,X.[object_name]
					,X.column_name
					,X.index_name
				FOR
					XML PATH ('tr')
			)
		)


	SET @Body = @Body +

		N'
			<br><br>
			<h3><center>Index Fragmentation</center></h3>
			<center>
				<table border=1 cellpadding=2>
					<tr>
						<th>Database Name</th>
						<th>Schema Name</th>
						<th>Object Name</th>
						<th>Column Name</th>
						<th>Index Name</th>
						<th>Fragmentation</th>
						<th>Index Type</th>
						<th>PK</th>
						<th>Unique</th>
						<th>Recommendation</th>
						<th>Alter Index Statement</th>
					</tr>
		 '


	SET @Body = @Body + @XML_String +

		N'
				</table>
			</center>
		 '

END
ELSE BEGIN

	SELECT
		 X.database_name
		,X.[schema_name]
		,X.[object_name]
		,X.column_name
		,X.index_name
		,X.fragmentation
		,X.index_type
		,X.is_pk AS pk
		,X.is_unique AS [unique]
		,X.recommendation
		,X.alter_index_statement
	FROM
		dbo.#temp_sssr_index_fragmentation X
	ORDER BY
		 X.database_name
		,X.[schema_name]
		,X.[object_name]
		,X.column_name
		,X.index_name

END


Skip_Index_Fragmentation:


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_index_fragmentation', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_index_fragmentation

END


-----------------------------------------------------------------------------------------------------------------------------
--	Main Query IX: Missing Indexes
-----------------------------------------------------------------------------------------------------------------------------

IF @Missing_Indexes = 0
BEGIN

	GOTO Skip_Missing_Indexes

END


CREATE TABLE dbo.#temp_sssr_missing_indexes

	(
		 database_name NVARCHAR (512)
		,[schema_name] SYSNAME
		,[object_name] SYSNAME
		,unique_compiles VARCHAR (23)
		,user_seeks VARCHAR (23)
		,user_scans VARCHAR (23)
		,avg_total_user_cost VARCHAR (23)
		,avg_user_impact VARCHAR (23)
		,overall_impact VARCHAR (23)
		,impact_rank VARCHAR (23)
		,[index_columns] NVARCHAR (MAX)
		,included_columns NVARCHAR (MAX)
		,table_column_count VARCHAR (23)
		,index_column_count VARCHAR (23)
		,include_column_count VARCHAR (23)
		,index_pct_of_columns VARCHAR (23)
		,include_pct_of_columns VARCHAR (23)
		,total_pct_of_columns VARCHAR (23)
		,create_index_statement NVARCHAR (MAX)
	)


SET @Database_Name_Loop =

	(
		SELECT TOP (1)
			tvDBN.database_name
		FROM
			@Database_Names tvDBN
		ORDER BY
			tvDBN.database_name
	)


WHILE @Database_Name_Loop IS NOT NULL
BEGIN

	SET @SQL_String =

		N'
			USE [' + @Database_Name_Loop + N'];


			INSERT INTO dbo.#temp_sssr_missing_indexes

				(
					 database_name
					,[schema_name]
					,[object_name]
					,unique_compiles
					,user_seeks
					,user_scans
					,avg_total_user_cost
					,avg_user_impact
					,overall_impact
					,impact_rank
					,[index_columns]
					,included_columns
					,table_column_count
					,index_column_count
					,include_column_count
					,index_pct_of_columns
					,include_pct_of_columns
					,total_pct_of_columns
					,create_index_statement
				)


			SELECT
				 DB_NAME () AS database_name
				,SCHEMA_NAME (T.[schema_id]) AS [schema_name]
				,T.name AS [object_name]
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, DDMIGS.unique_compiles), 1)), 4, 23)) AS unique_compiles
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, DDMIGS.user_seeks), 1)), 4, 23)) AS user_seeks
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, DDMIGS.user_scans), 1)), 4, 23)) AS user_scans
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, DDMIGS.avg_total_user_cost), 1)), 1, 23)) AS avg_total_user_cost
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, DDMIGS.avg_user_impact), 1)), 1, 23)) AS avg_user_impact
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, caIC.overall_impact), 1)), 1, 23)) AS overall_impact
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, DENSE_RANK () OVER
																										(
																											ORDER BY
																												caIC.overall_impact DESC
																										)), 1)), 4, 23)) AS impact_rank
				,ISNULL (DDMID.equality_columns + caIC.comma_or_not, '''') + ISNULL (DDMID.inequality_columns, '''') AS [index_columns]
				,ISNULL (DDMID.included_columns, '''') AS included_columns
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, sqCC.table_column_count), 1)), 4, 23)) AS table_column_count
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, caIC.index_column_count), 1)), 4, 23)) AS index_column_count
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, caIC.include_column_count), 1)), 4, 23)) AS include_column_count
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, (caIC.index_column_count / sqCC.table_column_count) * 100), 1)), 1, 23)) AS index_pct_of_columns
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, (caIC.include_column_count / sqCC.table_column_count) * 100), 1)), 1, 23)) AS include_pct_of_columns
				,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (23), CONVERT (MONEY, ((caIC.index_column_count + caIC.include_column_count) / sqCC.table_column_count) * 100), 1)), 1, 23)) AS total_pct_of_columns
				,caCIS.create_index_statement
			FROM
				sys.tables T
				INNER JOIN sys.dm_db_missing_index_details DDMID ON DDMID.[object_id] = T.[object_id]
					AND DDMID.database_id = DB_ID ()
				INNER JOIN sys.dm_db_missing_index_groups DDMIG ON DDMIG.index_handle = DDMID.index_handle
				INNER JOIN sys.dm_db_missing_index_group_stats DDMIGS ON DDMIGS.group_handle = DDMIG.index_group_handle
				INNER JOIN

					(
						SELECT
							 C.[object_id]
							,COUNT (*) + .0 AS table_column_count
						FROM
							sys.columns C
						GROUP BY
							C.[object_id]
					) sqCC ON sqCC.[object_id] = T.[object_id]

				CROSS APPLY

					(
						SELECT
							 CONVERT (DECIMAL (18, 2), (DDMIGS.user_seeks + DDMIGS.user_scans) * (DDMIGS.avg_total_user_cost * DDMIGS.avg_user_impact)) AS overall_impact
							,ISNULL ((LEN (DDMID.equality_columns) - LEN (REPLACE (DDMID.equality_columns, '','', ''''))) + 1, 0) + ISNULL ((LEN (DDMID.inequality_columns) - LEN (REPLACE (DDMID.inequality_columns, '','', ''''))) + 1, 0) AS index_column_count
							,ISNULL ((LEN (DDMID.included_columns) - LEN (REPLACE (DDMID.included_columns, '','', ''''))) + 1, 0) AS include_column_count
							,(CASE
								WHEN DDMID.inequality_columns IS NOT NULL THEN '', ''
								ELSE ''''
								END) AS comma_or_not
							, ''IX_''
							+ T.name
							+ ''_''
							+ ISNULL (REPLACE (SUBSTRING (SUBSTRING (DDMID.equality_columns, 1, LEN (DDMID.equality_columns) - 1), 2, LEN (DDMID.equality_columns) - 1), ''], ['', ''_'')
							+ (CASE
									WHEN DDMID.inequality_columns IS NOT NULL THEN ''_''
									ELSE ''''
									END), '''')
							+ ISNULL (REPLACE (SUBSTRING (SUBSTRING (DDMID.inequality_columns, 1, LEN (DDMID.inequality_columns) - 1), 2, LEN (DDMID.inequality_columns) - 1), ''], ['', ''_''), '''')
							+ ISNULL (''_i_'' + REPLACE (SUBSTRING (SUBSTRING (DDMID.included_columns, 1, LEN (DDMID.included_columns) - 1), 2, LEN (DDMID.included_columns) - 1), ''], ['', ''_''), '''') AS index_base_string
					) caIC

				CROSS APPLY

					(
						SELECT
							  ''CREATE NONCLUSTERED INDEX ''
							+ (CASE
									WHEN LEN (caIC.index_base_string COLLATE DATABASE_DEFAULT) > 128 THEN ''<INDEX NAME>''
									ELSE ''['' + caIC.index_base_string + '']''
									END)
							+ '' ON ''
							+ ''[''
							+ DB_NAME ()
							+ '']''
							+ ''.''
							+ ''[''
							+ SCHEMA_NAME (T.[schema_id])
							+ '']''
							+ ''.''
							+ ''[''
							+ T.name
							+ '']''
							+ '' (''
							+ ISNULL (DDMID.equality_columns + caIC.comma_or_not, '''')
							+ ISNULL (DDMID.inequality_columns, '''')
							+ '')''
							+ ISNULL ('' INCLUDE ('' + DDMID.included_columns + '')'', '''')
							+ '';'' AS create_index_statement
					) caCIS
		 '


	EXECUTE (@SQL_String)


	SET @Database_Name_Loop =

		(
			SELECT TOP (1)
				tvDBN.database_name
			FROM
				@Database_Names tvDBN
			WHERE
				tvDBN.database_name > @Database_Name_Loop
			ORDER BY
				tvDBN.database_name
		)

END


IF NOT EXISTS (SELECT * FROM dbo.#temp_sssr_missing_indexes X)
BEGIN

	GOTO Skip_Missing_Indexes

END


IF @Output_Mode = 'E'
BEGIN

	SET @XML_String =

		CONVERT (NVARCHAR (MAX),
			(
				SELECT
					 '',X.database_name AS 'td'
					,'',X.[schema_name] AS 'td'
					,'',X.[object_name] AS 'td'
					,'','right_align' + X.unique_compiles AS 'td'
					,'','right_align' + X.user_seeks AS 'td'
					,'','right_align' + X.user_scans AS 'td'
					,'','right_align' + X.avg_total_user_cost AS 'td'
					,'','right_align' + X.avg_user_impact AS 'td'
					,'','right_align' + X.overall_impact AS 'td'
					,'','right_align' + X.impact_rank AS 'td'
					,'',X.[index_columns] AS 'td'
					,'',X.included_columns AS 'td'
					,'','right_align' + X.table_column_count AS 'td'
					,'','right_align' + X.index_column_count AS 'td'
					,'','right_align' + X.include_column_count AS 'td'
					,'','right_align' + X.index_pct_of_columns AS 'td'
					,'','right_align' + X.include_pct_of_columns AS 'td'
					,'','right_align' + X.total_pct_of_columns AS 'td'
					,'',X.create_index_statement AS 'td'
				FROM
					dbo.#temp_sssr_missing_indexes X
				ORDER BY
					 X.database_name
					,X.[schema_name]
					,X.[object_name]
					,X.impact_rank
					,X.[index_columns]
					,X.included_columns
				FOR
					XML PATH ('tr')
			)
		)


	SET @Body = @Body +

		N'
			<br><br>
			<h3><center>Missing Indexes</center></h3>
			<center>
				<table border=1 cellpadding=2>
					<tr>
						<th>Database Name</th>
						<th>Schema Name</th>
						<th>Object Name</th>
						<th>Unique Compiles</th>
						<th>User Seeks</th>
						<th>User Scans</th>
						<th>Avg User Cost</th>
						<th>Avg User Impact</th>
						<th>Overall Impact</th>
						<th>Impact Rank</th>
						<th>Index Column(s)</th>
						<th>Include Column(s)</th>
						<th>Table Column Count</th>
						<th>Index Column Count</th>
						<th>Include Column Count</th>
						<th>Index % Of Columns</th>
						<th>Include % Of Columns</th>
						<th>Total % Of Columns</th>
						<th>Create Index Statement</th>
					</tr>
		 '


	SET @Body = @Body + @XML_String +

		N'
				</table>
			</center>
		 '

END
ELSE BEGIN

	SELECT
		 X.database_name
		,X.[schema_name]
		,X.[object_name]
		,X.unique_compiles
		,X.user_seeks
		,X.user_scans
		,X.avg_total_user_cost AS avg_user_cost
		,X.avg_user_impact
		,X.overall_impact
		,X.impact_rank
		,X.[index_columns]
		,X.included_columns AS include_columns
		,X.table_column_count
		,X.index_column_count
		,X.include_column_count
		,X.index_pct_of_columns
		,X.include_pct_of_columns
		,X.total_pct_of_columns
		,X.create_index_statement
	FROM
		dbo.#temp_sssr_missing_indexes X
	ORDER BY
		 X.database_name
		,X.[schema_name]
		,X.[object_name]
		,X.impact_rank
		,X.[index_columns]
		,X.included_columns

END


Skip_Missing_Indexes:


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_missing_indexes', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_missing_indexes

END


-----------------------------------------------------------------------------------------------------------------------------
--	Main Query X: Unused Indexes
-----------------------------------------------------------------------------------------------------------------------------

IF (@Unused_Indexes = 0 OR DATEDIFF (SECOND, @SQL_Server_Start_Time, GETDATE ()) < (@Unused_Index_Days * 86400))
BEGIN

	GOTO Skip_Unused_Indexes

END


CREATE TABLE dbo.#temp_sssr_unused_indexes

	(
		 database_name NVARCHAR (512)
		,[schema_name] SYSNAME
		,[object_name] SYSNAME
		,column_name SYSNAME
		,index_name SYSNAME
		,[disabled] VARCHAR (3)
		,hypothetical VARCHAR (3)
		,drop_index_statement NVARCHAR (4000)
	)


SET @Database_Name_Loop =

	(
		SELECT TOP (1)
			tvDBN.database_name
		FROM
			@Database_Names tvDBN
		ORDER BY
			tvDBN.database_name
	)


WHILE @Database_Name_Loop IS NOT NULL
BEGIN

	SET @SQL_String =

		N'
			USE [' + @Database_Name_Loop + N'];


			INSERT INTO dbo.#temp_sssr_unused_indexes

				(
					 database_name
					,[schema_name]
					,[object_name]
					,column_name
					,index_name
					,[disabled]
					,hypothetical
					,drop_index_statement
				)

			SELECT
				 DB_NAME () AS database_name
				,S.name AS [schema_name]
				,O.name AS [object_name]
				,C.name AS column_name
				,I.name AS index_name
				,(CASE
					WHEN I.is_disabled = 1 THEN ''Yes''
					ELSE ''No''
					END) AS [disabled]
				,(CASE
					WHEN I.is_hypothetical = 1 THEN ''Yes''
					ELSE ''No''
					END) AS hypothetical
				,N''USE ['' + DB_NAME () + N'']; IF EXISTS (SELECT * FROM sys.indexes I WHERE I.[object_id] = '' + CONVERT (VARCHAR (11), I.[object_id]) + '' AND I.index_id = '' + CONVERT (VARCHAR (11), I.index_id) + '') BEGIN DROP INDEX ['' + I.name + ''] ON ['' + S.name + N''].['' + O.name + N''] END;'' AS drop_index_statement
			FROM
				sys.indexes I
				INNER JOIN sys.objects O ON O.[object_id] = I.[object_id]
					AND O.[type] = ''U''
					AND O.is_ms_shipped = 0
					AND O.name <> ''sysdiagrams''
				INNER JOIN sys.tables T ON T.[object_id] = I.[object_id]
				INNER JOIN sys.schemas S ON S.[schema_id] = T.[schema_id]
				INNER JOIN sys.index_columns IC ON IC.[object_id] = I.[object_id]
					AND IC.index_id = I.index_id
				INNER JOIN sys.columns C ON C.[object_id] = IC.[object_id]
					AND C.column_id = IC.column_id
			WHERE
				I.[type] > 0
				AND I.is_primary_key = 0
				AND I.is_unique_constraint = 0
				AND NOT EXISTS

					(
						SELECT
							*
						FROM
							sys.index_columns XIC
							INNER JOIN sys.foreign_key_columns FKC ON FKC.parent_object_id = XIC.[object_id]
								AND FKC.parent_column_id = XIC.column_id
						WHERE
							XIC.[object_id] = I.[object_id]
							AND XIC.index_id = I.index_id
					)

				AND NOT EXISTS

					(
						SELECT
							*
						FROM
							master.sys.dm_db_index_usage_stats DDIUS
						WHERE
							DDIUS.database_id = DB_ID (DB_NAME ())
							AND DDIUS.[object_id] = I.[object_id]
							AND DDIUS.index_id = I.index_id
					)
		 '


	EXECUTE (@SQL_String)


	SET @Database_Name_Loop =

		(
			SELECT TOP (1)
				tvDBN.database_name
			FROM
				@Database_Names tvDBN
			WHERE
				tvDBN.database_name > @Database_Name_Loop
			ORDER BY
				tvDBN.database_name
		)

END


IF NOT EXISTS (SELECT * FROM dbo.#temp_sssr_unused_indexes X)
BEGIN

	GOTO Skip_Unused_Indexes

END


IF @Output_Mode = 'E'
BEGIN

	SET @XML_String =

		CONVERT (NVARCHAR (MAX),
			(
				SELECT
					 '',X.database_name AS 'td'
					,'',X.[schema_name] AS 'td'
					,'',X.[object_name] AS 'td'
					,'',X.column_name AS 'td'
					,'',X.index_name AS 'td'
					,'',X.[disabled] AS 'td'
					,'',X.hypothetical AS 'td'
					,'',X.drop_index_statement AS 'td'
				FROM
					dbo.#temp_sssr_unused_indexes X
				ORDER BY
					 X.database_name
					,X.[schema_name]
					,X.[object_name]
					,X.column_name
					,X.index_name
				FOR
					XML PATH ('tr')
			)
		)


	SET @Body = @Body +

		N'
			<br><br>
			<h3><center>Unused Indexes</center></h3>
			<center>
				<table border=1 cellpadding=2>
					<tr>
						<th>Database Name</th>
						<th>Schema Name</th>
						<th>Object Name</th>
						<th>Column Name</th>
						<th>Index Name</th>
						<th>Disabled</th>
						<th>Hypothetical</th>
						<th>Drop Index Statement</th>
					</tr>
		 '


	SET @Body = @Body + @XML_String +

		N'
				</table>
			</center>
		 '

END
ELSE BEGIN

	SELECT
		 X.database_name
		,X.[schema_name]
		,X.[object_name]
		,X.column_name
		,X.index_name
		,X.[disabled]
		,X.hypothetical
		,X.drop_index_statement
	FROM
		dbo.#temp_sssr_unused_indexes X
	ORDER BY
		 X.database_name
		,X.[schema_name]
		,X.[object_name]
		,X.column_name
		,X.index_name

END


Skip_Unused_Indexes:


IF OBJECT_ID (N'tempdb.dbo.#temp_sssr_unused_indexes', N'U') IS NOT NULL
BEGIN

	DROP TABLE dbo.#temp_sssr_unused_indexes

END


-----------------------------------------------------------------------------------------------------------------------------
--	Variable Update: Finalize @Body Variable Contents
-----------------------------------------------------------------------------------------------------------------------------

IF @Output_Mode = 'E'
BEGIN

	SET @Body =

		N'
			<html>
				<body>
				<style type="text/css">
					table {font-size:8.0pt;font-family:Arial;text-align:left;}
					tr {text-align:left;}
				</style>
		 '

		+ @Body +

		N'
				</body>
			</html>
		 '


	SET @Body = REPLACE (@Body, N'<td>right_align', N'<td align="right">')

END


-----------------------------------------------------------------------------------------------------------------------------
--	sp_send_dbmail: Deliver Results / Notification To End User(s)
-----------------------------------------------------------------------------------------------------------------------------

IF @Output_Mode = 'E'
BEGIN

	EXECUTE msdb.dbo.sp_send_dbmail

		 @recipients = @Recipients
		,@profile_name='DBA'
		,@copy_recipients = @Copy_Recipients
		,@subject = @Subject
		,@body = @Body
		,@body_format = 'HTML'

END
GO
