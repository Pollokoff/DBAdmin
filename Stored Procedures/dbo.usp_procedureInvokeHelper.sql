SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Dynamic SQL helper procedure
-- Extracts the parameters from the message body
-- Creates the invocation Transact-SQL batch
-- Invokes the dynmic SQL batch
create procedure [dbo].[usp_procedureInvokeHelper] (@x xml)
as
begin
    set nocount on;

    declare @stmt nvarchar(max)
        , @stmtDeclarations nvarchar(max)
        , @stmtValues nvarchar(max)
        , @i int
        , @countParams int
        , @namedParams nvarchar(max)
        , @paramName sysname
        , @paramType sysname
        , @paramPrecision int
        , @paramScale int
        , @paramLength int
        , @paramTypeFull nvarchar(300)
        , @comma nchar(1)

    select @i = 0
        , @stmtDeclarations = N''
        , @stmtValues = N''
        , @namedParams = N''
        , @comma = N''

    declare crsParam cursor forward_only static read_only for
        select x.value(N'@Name', N'sysname')
            , x.value(N'@BaseType', N'sysname')
            , x.value(N'@Precision', N'int')
            , x.value(N'@Scale', N'int')
            , x.value(N'@MaxLength', N'int')
        from @x.nodes(N'//procedure/parameters/parameter') t(x);
    open crsParam;

    fetch next from crsParam into @paramName
        , @paramType
        , @paramPrecision
        , @paramScale
        , @paramLength;
    while (@@fetch_status = 0)
    begin
        select @i = @i + 1;

        select @paramTypeFull = @paramType +
            case
            when @paramType in (N'varchar'
                , N'nvarchar'
                , N'varbinary'
                , N'char'
                , N'nchar'
                , N'binary') then
                N'(' + cast(@paramLength as nvarchar(5)) + N')'
            when @paramType in (N'numeric') then
                N'(' + cast(@paramPrecision as nvarchar(10)) + N',' +
                cast(@paramScale as nvarchar(10))+ N')'
            else N''
            end;

        -- Some basic sanity check on the input XML
        if (@paramName is NULL
            or @paramType is NULL
            or @paramTypeFull is NULL
            or charindex(N'''', @paramName) > 0
            or charindex(N'''', @paramTypeFull) > 0)
            raiserror(N'Incorrect parameter attributes %i: %s:%s %i:%i:%i'
                , 16, 10, @i, @paramName, @paramType
                , @paramPrecision, @paramScale, @paramLength);

        select @stmtDeclarations = @stmtDeclarations + N'
declare @pt' + cast(@i as varchar(3)) + N' ' + @paramTypeFull
            , @stmtValues = @stmtValues + N'
select @pt' + cast(@i as varchar(3)) + N'=@x.value(
    N''(//procedure/parameters/parameter)[' + cast(@i as varchar(3))
                + N']'', N''' + @paramTypeFull + ''');'
            , @namedParams = @namedParams + @comma + @paramName
                + N'=@pt' + cast(@i as varchar(3));

        select @comma = N',';

        fetch next from crsParam into @paramName
            , @paramType
            , @paramPrecision
            , @paramScale
            , @paramLength;
    end

    close crsParam;
    deallocate crsParam;        

    select @stmt = @stmtDeclarations + @stmtValues + N'
exec ' + quotename(@x.value(N'(//procedure/name)[1]', N'sysname'));

    if (@namedParams != N'')
        select @stmt = @stmt + N' ' + @namedParams;

    exec sp_executesql @stmt, N'@x xml', @x;
end
GO
