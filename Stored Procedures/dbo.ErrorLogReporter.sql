SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[ErrorLogReporter]
AS /*  PROCESS ERROR LOG TABLE */

    DECLARE @searchForKeyword VARCHAR(255) ,
        @cmd VARCHAR(8000) ,
        @ForceKeyword VARCHAR(255)

    CREATE TABLE #ERRORSHold
        (
          [ServerName] [varchar](50) NULL ,
          [LogDate] [datetime] NULL ,
          [ProcessInfo] [varchar](100) NULL ,
          [Text] [varchar](MAX) NULL
        )


INSERT SQLLogInfo_BAK
SELECT * FROM dbo.SQLLogInfo


--   HOLD line with KEYWORDS TO Force Include
    SELECT  @cmd = 'insert #ErrorsHOLD select * from SQLLogInfo where '
    DECLARE KW_cursorH CURSOR
    FOR
        SELECT  Forcekeyword
        FROM    ErrorlogForceInclude
    OPEN KW_cursorH
    FETCH KW_cursorH INTO @searchForKeyword
    IF @searchForKeyword != 'sa' 
        BEGIN
            SELECT  @ForceKeyword = '''% ' + @searchForKeyword + '%'''
        END
    ELSE 
        BEGIN
            SELECT  @ForceKeyword = '''% ' + @searchForKeyword + ' %'''
        END


    SELECT  @cmd = @cmd + ' Text LIKE ' + @ForceKeyword
    FETCH KW_cursorH INTO @searchForKeyword
    WHILE @@fetch_status = 0 
        BEGIN 
            IF @searchForKeyword != 'sa' 
                SELECT  @ForceKeyword = '''% ' + @searchForKeyword + '%'''
            ELSE 
                SELECT  @ForceKeyword = '''% ' + @searchForKeyword + ' %'''
     
            SELECT  @cmd = @cmd + ' or Text LIKE ' + @ForceKeyword
            FETCH KW_cursorH INTO @searchForKeyword
        END
    CLOSE KW_cursorH
    DEALLOCATE KW_cursorH 
--    PRINT @cmd
    EXEC ( @cmd
    )

--  KEYWORDS TO SCAN FOR
    SELECT  @cmd = 'delete SQLLogInfo from SQLLogInfo eTmp where ' 
    DECLARE KW_cursor CURSOR
    FOR
        SELECT  '''%' + keyword + '%'''
        FROM    ErrorlogScanKeyword
    OPEN KW_cursor
    FETCH KW_cursor INTO @searchForKeyword
    SELECT  @cmd = @cmd + ' Text not LIKE ' + @searchForKeyword
    WHILE @@fetch_status = 0 
        BEGIN
            SELECT  @cmd = @cmd + ' and Text not LIKE ' + @searchForKeyword
            FETCH KW_cursor INTO @searchForKeyword
        END
    CLOSE KW_cursor
    DEALLOCATE KW_cursor 
--    PRINT @cmd
    EXEC ( @cmd
    )

--    KEYWORDS TO EXCLUDE    
    SELECT  @cmd = 'delete SQLLogInfo from SQLLogInfo eTmp where ' 
    DECLARE KW_cursor CURSOR
    FOR
        SELECT  '''%' + Excludekeyword + '%'''
        FROM    ErrorlogScanExclude
    OPEN KW_cursor
    FETCH KW_cursor INTO @searchForKeyword
    SELECT  @cmd = @cmd + ' Text  LIKE ' + @searchForKeyword
    WHILE @@fetch_status = 0 
        BEGIN
            SELECT  @cmd = @cmd + ' or Text  LIKE ' + @searchForKeyword
            FETCH KW_cursor INTO @searchForKeyword
        END
    CLOSE KW_cursor
    DEALLOCATE KW_cursor 
--    PRINT @cmd
    EXEC ( @cmd
    )

    SELECT  *
    FROM    #ErrorsHOLD

    INSERT  SQLLogInfo
            SELECT  *
            FROM    #ErrorsHOLD

    DROP TABLE #ERRORSHold

/*  PREPARE EMAIL */
 
    DECLARE @vXML_String AS NVARCHAR(MAX)
    DECLARE @vWarning AS NVARCHAR(MAX)
    DECLARE @vBody AS NVARCHAR(MAX)
    DECLARE @vSQL_String AS NVARCHAR(MAX)
    DECLARE @ErrCount INT
    SET @vXML_String = ''
    SET @vWarning = ''
    SET @vBody = ''

    IF EXISTS ( SELECT  1
                FROM    dbo.SQLLogInfo ) 
        BEGIN
            SET @vBody = '
		
		
			<table border=1 cellpadding=2>
				<tr>
					<th>Server</th>
					<th>LogDate</th>
					<th>Message</th>
				</tr>
	'
	
			
            SET @vXML_String = CONVERT (NVARCHAR(MAX), ( SELECT TOP 100
                                                              '' ,
                                                              X.ServerName AS 'td' ,
                                                              '' ,
                                                              X.LogDate AS 'td' ,
                                                              '' ,
                                                              X.Text AS 'td'
                                                         FROM SQLLogInfo X
                                                         ORDER BY ServerName ,
                                                              LogDate
                                                       FOR
                                                         XML PATH('tr')
                                                       ))
                 
            SELECT  @ErrCount = COUNT(1)
            FROM    SQLLogInfo
            IF @ErrCount > 100 
                BEGIN
                    SET @vWarning = '<H3>TOP 100 Errors listed.  There may be more errors not included in this report.</H3><BR>'
				
                END                                                       
            SET @vBody = @vBody + @vXML_String + '	</table>
	'
            SET @vBody = '
		<html>
			<body>
			<style type="text/css">
				table {font-size:8.0pt;font-family:Arial;text-align:left;}
				tr {text-align:left;}
			</style>
			<h3>Server Error Logs</h3><BR>
	' + @vWarning + @vBody + '
			</body>
		</html>
	'
            SET @vBody = REPLACE(@vBody, '<td>right_align',
                                 '<td align="right">')


            PRINT 'Send Mail'
--            PRINT @vBody

            EXEC msdb.dbo.sp_send_dbmail @recipients = 'SQLDBA@laureate-inc.com',
                @subject = 'Error Log Report', @body = @vBody,
                @body_format = 'HTML', @profile_name = 'DBA'

        END
    PRINT @vBody
GO
