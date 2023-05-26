

SELECT 'CREATE TABLE ' + entity + ' (' +
       STRING_AGG([sql_field_name] + ' ' + [sql_type], ', ') WITHIN GROUP (ORDER BY entity) +
       ')'
FROM [cslam_cvms].[vw_entity_odata_to_sql_map]
GROUP BY entity;


DECLARE @sql_statement nvarchar(max);

SET @sql_statement = (
    SELECT STRING_AGG('CREATE TABLE ' + entity + ' (' +
                      column_list + ')', ';')
    FROM (
        SELECT entity, STRING_AGG([sql_field_name] + ' ' + [sql_type], ', ') WITHIN GROUP (ORDER BY [sql_field_name]) AS column_list
        FROM [cslam_cvms].[vw_entity_odata_to_sql_map]
        GROUP BY entity
    ) t
);



PRINT @sql_statement;
EXEC sp_executesql @sql_statement;

-----------------------------------------------------------------------------------------
DECLARE @sql_statement nvarchar(max);

SET @sql_statement = (
    SELECT STRING_AGG('CREATE TABLE ' + entity + ' (' + CHAR(13) + CHAR(10) +
                      column_list + ')' + CHAR(13) + CHAR(10) + ';', CHAR(13) + CHAR(10))
    FROM (
        SELECT entity, STRING_AGG([sql_field_name] + ' ' + [sql_type], ', ' + CHAR(13) + CHAR(10)) WITHIN GROUP (ORDER BY [sql_field_name]) AS column_list
        FROM [cslam_cvms].[vw_entity_odata_to_sql_map]
        GROUP BY entity
    ) t
);

PRINT @sql_statement; -- Print the SQL statement before executing it

EXEC sp_executesql @sql_statement;
GO
--------------------------------------------------------------------


DECLARE @sql_statement nvarchar(max);

DECLARE cursor_name CURSOR FOR
SELECT 'CREATE TABLE ' + entity + ' (' +
       STRING_AGG([sql_field_name] + ' ' + [sql_type], ', ') WITHIN GROUP (ORDER BY [sql_field_name]) +
       ')'
FROM [cslam_cvms].[vw_entity_odata_to_sql_map]
GROUP BY entity;

OPEN cursor_name;

FETCH NEXT FROM cursor_name INTO @sql_statement;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC sp_executesql @sql_statement;
	--PRINT @sql_statement
    FETCH NEXT FROM cursor_name INTO @sql_statement;
END

CLOSE cursor_name;
DEALLOCATE cursor_name;







