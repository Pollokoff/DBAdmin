SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[usp_AsyncExecActivated]
as
begin
    set nocount on;
    declare @h uniqueidentifier
        , @messageTypeName sysname
        , @messageBody varbinary(max)
        , @xmlBody xml
        , @startTime datetime
        , @finishTime datetime
        , @execErrorNumber int
        , @execErrorMessage nvarchar(2048)
        , @xactState smallint
        , @token uniqueidentifier;

    begin transaction;
    begin try;
        receive top(1)
            @h = [conversation_handle]
            , @messageTypeName = [message_type_name]
            , @messageBody = [message_body]
            from [AsyncExecQueue];
        if (@h is not null)
        begin
            if (@messageTypeName = N'DEFAULT')
            begin
                -- The DEFAULT message type is a procedure invocation.
                --
                select @xmlBody = CAST(@messageBody as xml);

                save transaction usp_AsyncExec_procedure;
                select @startTime = GETUTCDATE();
                begin try
                    exec [usp_procedureInvokeHelper] @xmlBody;
                end try
                begin catch
                -- This catch block tries to deal with failures of the procedure execution
                -- If possible it rolls back to the savepoint created earlier, allowing
                -- the activated procedure to continue. If the executed procedure
                -- raises an error with severity 16 or higher, it will doom the transaction
                -- and thus rollback the RECEIVE. Such case will be a poison message,
                -- resulting in the queue disabling.
                --
                select @execErrorNumber = ERROR_NUMBER(),
                    @execErrorMessage = ERROR_MESSAGE(),
                    @xactState = XACT_STATE();
                if (@xactState = -1)
                begin
                    rollback;
                    raiserror(N'Unrecoverable error in procedure: %i: %s', 16, 10,
                        @execErrorNumber, @execErrorMessage);
                end
                else if (@xactState = 1)
                begin
                    rollback transaction usp_AsyncExec_procedure;
                end
                end catch

                select @finishTime = GETUTCDATE();
                select @token = [conversation_id]
                    from sys.conversation_endpoints
                    where [conversation_handle] = @h;
                if (@token is null)
                begin
                    raiserror(N'Internal consistency error: conversation not found', 16, 20);
                end
                update [AsyncExecResults] set
                    [start_time] = @starttime
                    , [finish_time] = @finishTime
                    , [error_number] = @execErrorNumber
                    , [error_message] = @execErrorMessage
                    where [token] = @token;
                if (0 = @@ROWCOUNT)
                begin
                    raiserror(N'Internal consistency error: token not found', 16, 30);
                end
                end conversation @h;
            end
            else if (@messageTypeName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog')
            begin
                end conversation @h;
            end
            else if (@messageTypeName = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error')
            begin
                declare @errorNumber int
                    , @errorMessage nvarchar(4000);
                select @xmlBody = CAST(@messageBody as xml);
                with xmlnamespaces (DEFAULT N'http://schemas.microsoft.com/SQL/ServiceBroker/Error')
                select @errorNumber = @xmlBody.value ('(/Error/Code)[1]', 'INT'),
                    @errorMessage = @xmlBody.value ('(/Error/Description)[1]', 'NVARCHAR(4000)');
                -- Update the request with the received error
                select @token = [conversation_id]
                    from sys.conversation_endpoints
                    where [conversation_handle] = @h;
                update [AsyncExecResults] set
                    [error_number] = @errorNumber
                    , [error_message] = @errorMessage
                    where [token] = @token;
                end conversation @h;
             end
           else
           begin
                raiserror(N'Received unexpected message type: %s', 16, 50, @messageTypeName);
           end
        end
        commit;
    end try
    begin catch
        declare @error int
         , @message nvarchar(2048);
        select @error = ERROR_NUMBER()
            , @message = ERROR_MESSAGE()
            , @xactState = XACT_STATE();
        if (@xactState <> 0)
        begin
         rollback;
        end;
        raiserror(N'Error: %i, %s', 1, 60,  @error, @message) with log;
    end catch
end
GO
