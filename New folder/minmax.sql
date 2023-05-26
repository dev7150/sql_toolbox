/****** Script for SelectTopNRows command from SSMS  ******/
declare @tableName varchar(200) = 'RapidAntigenKit';
declare @schemaName varchar(200) = 'dbo'; 

declare @sql nvarchar(max);
PRINT @sql;
declare @stmnt varchar(max) = 'SELECT ''{COL_NAME}''  [column_name], min({COL_NAME}) [min],  max({COL_NAME}) [max]';
with query as(
select  
	CONCAT(replace(@stmnt, '{COL_NAME}', [column_name]), ' FROM [', @schemaName, '].[', @tableName,'] ') [sql]
	from INFORMATION_SCHEMA.COLUMNS
	where TABLE_NAME = @tableName and TABLE_SCHEMA = @schemaName and not [column_name] like 'dl_%' 
	and DATA_TYPE in ('datetime2')
)
select @sql = COALESCE(@sql + ' UNION ','') + [sql] 
from query;
--PRINT @sql;
exec sp_executesql @sql;