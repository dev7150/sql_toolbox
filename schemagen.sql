DECLARE @table_name NVARCHAR(256) = '[dbo].[Early$]';
DECLARE @sql_statement NVARCHAR(MAX);

SELECT @sql_statement = 'SELECT * FROM ' + @table_name + ' WHERE ' +
    STRING_AGG(COLUMN_NAME + ' != CAST(' + QUOTENAME(COLUMN_NAME) + ' AS VARCHAR(4))', ' AND ')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @table_name;

-- Output the generated query
RAISERROR('%s', 0, 1, @sql_statement) WITH NOWAIT;

-- Execute the query
EXEC sp_executesql @sql_statement;


create table create_sta
(statement nvarchar(max))

INSERT INTO create_sta 
values('CREATE TABLE bookableresourcecharacteristic ([status_reason] bigint, [currency] uniqueidentifier, [modified_on] datetime2(7), [process_id] uniqueidentifier, [modified_by_(delegate)] uniqueidentifier, [name] nvarchar(100), [import_sequence_number] integer, [modified_by] uniqueidentifier, [bookable_resource_characteristic] uniqueidentifier, [version_number] bigint, [created_on] datetime2(7), [created_by] uniqueidentifier, [characteristic] uniqueidentifier, [(deprecated)_stage_id] uniqueidentifier, [record_created_on] datetime2(7), [exchangerate] decimal, [owning_user] uniqueidentifier, [owning_business_unit] uniqueidentifier, [time_zone_rule_version_number] integer, [rating_value] uniqueidentifier, [owning_team] uniqueidentifier, [(deprecated)_traversed_path] nvarchar(1250), [created_by_(delegate)] uniqueidentifier, [status] bigint, [owner] uniqueidentifier, [resource] uniqueidentifier, [utc_conversion_time_zone_code] integer)')

select * from create_sta

DECLARE @sql NVARCHAR(MAX);

SELECT @sql = (Select *
FROM create_sta);

EXEC sp_executesql @sql;

----------------------------------------------------------------
DECLARE @sql_statement nvarchar(max);
DECLARE cursor_name CURSOR FOR
SELECT 'CREATE TABLE ' + entity + ' (' +
       (SELECT [sql_field_name] + ' ' + [proposed_sql_type] + ', ' AS [text()]
        FROM [dbo].[Sheet1$] s
        WHERE s.entity = e.entity
        ORDER BY [sql_field_name]
        FOR XML PATH('')) +
       ')'
FROM [dbo].[Sheet1$] e
GROUP BY entity;

OPEN cursor_name;

FETCH NEXT FROM cursor_name INTO @sql_statement;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC sp_executesql @sql_statement;
    PRINT @sql_statement;
    FETCH NEXT FROM cursor_name INTO @sql_statement;
END

CLOSE cursor_name;
