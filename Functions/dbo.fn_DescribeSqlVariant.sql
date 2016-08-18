SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Helper function to create the XML element
-- for a passed in parameter
create function [dbo].[fn_DescribeSqlVariant] (
 @p sql_variant
 , @n sysname)
returns xml
with schemabinding
as
begin
 return (
 select @n as [@Name]
  , sql_variant_property(@p, 'BaseType') as [@BaseType]
  , sql_variant_property(@p, 'Precision') as [@Precision]
  , sql_variant_property(@p, 'Scale') as [@Scale]
  , sql_variant_property(@p, 'MaxLength') as [@MaxLength]
  , @p
  for xml path('parameter'), type)
end
GO
