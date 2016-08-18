SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bernie Diaz
-- Create date: 10/28/2012
-- Description:	print month calendar info
-- =============================================
CREATE FUNCTION [dbo].[myCalendar] ( @DATE DATETIME )
RETURNS VARCHAR(MAX)
AS
    BEGIN
	-- Declare the return variable here
        DECLARE @todayDate DATETIME
          , @lastDayDate DATETIME
          , @firstDayDate DATETIME
          , @c_Date DATETIME
          , @c_day INT
          , @today INT
          , @month INT
          , @weeDay INT
          , @str VARCHAR(MAX)
          , @i INT
          , @hdr VARCHAR(MAX)
          , @monthN VARCHAR(MAX)
          , @pr INT
          , @po INT

        SELECT  @todayDate = @DATE --DATEADD(MONTH,-9,GETDATE())
        SET @i = 1


        SELECT  @firstDayDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), DATEADD(DAY,
                                            1,
                                            DATEADD(s, -1,
                                            DATEADD(mm,
                                            DATEDIFF(m, 0,
                                            DATEADD(MONTH,
                                            -1, @todayDate))
                                            + 1, 0))), 112))
              , @lastDayDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), DATEADD(s,
                                            -1,
                                            DATEADD(mm,
                                            DATEDIFF(m, 0,
                                            @todayDate) + 1,
                                            0)), 112))
              , @month = MONTH(@todayDate)
              , @today = DAY(@todayDate)
              , @monthN = DATENAME(MONTH, @todayDate)
        SELECT  @weeDay = DATEPART(dw, @firstDayDate)
	
        SET @pr = ( 11 - LEN(@monthN) ) / 2;
        IF @pr = 0
            SET @pr = 1;
        SET @po = ( 11 - LEN(@monthN) ) - @pr;
        IF @po = 0
            SET @po = 1;
        SET @hdr = ' <<' + REPLICATE(' ', @pr) + @monthN
            + ' ' + RTRIM(CAST(YEAR(@todayDate) AS CHAR))
            + REPLICATE(' ', @po) + '>>' + CHAR(13)
            + ' Su Mo Tu We Th Fr Sa';

        WHILE @i < @weeDay
            BEGIN
                SELECT  @str = COALESCE(@str, '')
                        + REPLICATE(' ', 3)
                SET @i = @i + 1
            END


        SET @c_Date = @firstDayDate

        WHILE @c_Date <= @lastDayDate
            BEGIN

                SET @c_day = DAY(@c_Date)
                SELECT  @str = COALESCE(@str, '')
                        + REPLICATE(' ', 3 - LEN(@c_day))
                        + RTRIM(CAST(@c_day AS CHAR))
		
                IF @i = 7
                    BEGIN
                        SET @str = COALESCE(@str, '')
                            + CHAR(13);
                        SET @i = 1
                    END
                ELSE
                    BEGIN
                        SET @i = @i + 1
                    END

                SET @c_Date = DATEADD(DAY, 1, @c_Date)
            END

	--print @hdr+CHAR(13)+@str


	-- Return the result of the function
        RETURN @hdr+CHAR(13)+@str

    END

GO
