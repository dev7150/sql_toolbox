/*
Just an example of how to produce a dynamic query based on a set table and schama name. This can be automated to produce a report for all tables within a given schema.
*/

declare @tableName varchar(200) = 'Case';
declare @schemaName varchar(200) = 'Canonical'; 

declare @sql nvarchar(max);
declare @stmnt varchar(max) = 'SELECT ''{COL_NAME}'' [column_name], sum(IIF([{COL_NAME}] <> '''', 1, 0)) [total_values_found], count(1) [total_rows]';
with query as(
select  
	CONCAT(replace(@stmnt, '{COL_NAME}', [column_name]), ' FROM [', @schemaName, '].[', @tableName,']') [sql]
	from INFORMATION_SCHEMA.COLUMNS
	where TABLE_NAME = @tableName and TABLE_SCHEMA = @schemaName and not [column_name] like 'dl_%'
)
select @sql = COALESCE(@sql + ' UNION ','') + [sql] 
from query;
--select @sql;
exec sp_executesql @sql;