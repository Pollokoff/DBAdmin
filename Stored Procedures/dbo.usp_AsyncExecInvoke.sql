SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Invocation wrapper. Accepts arbitrary
-- named parameetrs to be passed to the
-- background procedure
create procedure [dbo].[usp_AsyncExecInvoke]
    @procedureName sysname
    , @p1 sql_variant = NULL, @n1 sysname = NULL
    , @p2 sql_variant = NULL, @n2 sysname = NULL
    , @p3 sql_variant = NULL, @n3 sysname = NULL
    , @p4 sql_variant = NULL, @n4 sysname = NULL
    , @p5 sql_variant = NULL, @n5 sysname = NULL
    , @token uniqueidentifier output
as
begin
    declare @h uniqueidentifier
     , @xmlBody xml
        , @trancount int;
    set nocount on;

 set @trancount = @@trancount;
    if @trancount = 0
        begin transaction
    else
        save transaction usp_AsyncExecInvoke;
    begin try
        begin dialog conversation @h
            from service [AsyncExecService]
            to service N'AsyncExecService', 'current database'
            with encryption = off;
        select @token = [conversation_id]
            from sys.conversation_endpoints
            where [conversation_handle] = @h;

        select @xmlBody = (
            select @procedureName as [name]
            , (select * from (
                select [dbo].[fn_DescribeSqlVariant] (@p1, @n1) AS [*]
                    WHERE @p1 IS NOT NULL
                union all select [dbo].[fn_DescribeSqlVariant] (@p2, @n2) AS [*]
                    WHERE @p2 IS NOT NULL
                union all select [dbo].[fn_DescribeSqlVariant] (@p3, @n3) AS [*]
                    WHERE @p3 IS NOT NULL
                union all select [dbo].[fn_DescribeSqlVariant] (@p4, @n4) AS [*]
                    WHERE @p4 IS NOT NULL
                union all select [dbo].[fn_DescribeSqlVariant] (@p5, @n5) AS [*]
                    WHERE @p5 IS NOT NULL
                ) as p for xml path(''), type
            ) as [parameters]
            for xml path('procedure'), type);
        send on conversation @h (@xmlBody);
        insert into [AsyncExecResults]
            ([token], [submit_time])
            values
            (@token, getutcdate());
    if @trancount = 0
        commit;
    end try
    begin catch
        declare @error int
            , @message nvarchar(2048)
            , @xactState smallint;
        select @error = ERROR_NUMBER()
            , @message = ERROR_MESSAGE()
            , @xactState = XACT_STATE();
        if @xactState = -1
            rollback;
        if @xactState = 1 and @trancount = 0
            rollback
        if @xactState = 1 and @trancount > 0
            rollback transaction usp_my_procedure_name;

        raiserror(N'Error: %i, %s', 16, 1, @error, @message);
    end catch
end
GO
