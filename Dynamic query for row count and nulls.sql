declare @tableName varchar(200) = 'Action';
declare @schemaName varchar(200) = 'dbo'; 

declare @sql nvarchar(max);
select @sql
declare @stmnt varchar(max) = 'SELECT ''{COL_NAME}'' [column_name], sum(IIF(LEN([{COL_NAME}]) > 0, 1, 0)) [total_values_found], count(1) [total_rows]';
with query as(
select  
	CONCAT(replace(@stmnt, '{COL_NAME}', [column_name]), ' FROM [', @schemaName, '].[', @tableName,']') [sql]
	from INFORMATION_SCHEMA.COLUMNS
	where TABLE_NAME = @tableName and TABLE_SCHEMA = @schemaName and not [column_name] like 'dl_%'
)
select @sql = COALESCE(@sql + ' UNION ','') + [sql] 
from query;
select @sql;
exec sp_executesql @sql;