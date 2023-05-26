DECLARE @sql_statement nvarchar(max);
DECLARE cursor_name CURSOR FOR
SELECT 'CREATE TABLE ' + entity + ' (' +
       (SELECT [LogicalName] + ' ' + [proposed_sql_type] + ', ' AS [text()]
        FROM [dbo].[Sheet1$] s
        WHERE s.entity = e.entity
        ORDER BY [LogicalName]
        FOR XML PATH('')) +
       ')'
FROM [dbo].[Sheet1$] e
GROUP BY entity;

OPEN cursor_name;


FETCH NEXT FROM cursor_name INTO @sql_statement;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC sp_executesql @sql_statement;
  
    FETCH NEXT FROM cursor_name INTO @sql_statement;
END

CLOSE cursor_name;
DEALLOCATE cursor_name;

