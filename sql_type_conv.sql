


  select distinct sql_type 
  from [dbo].[odata_to_sql]
  order by 1

  UPDATE [table_name]
SET [sql_type] = 'nvarchar(max)'

Select * from [dbo].[odata_to_sql]
WHERE CAST(SUBSTRING([sql_type], CHARINDEX('(', [sql_type]) + 1, CHARINDEX(')', [sql_type]) - CHARINDEX('(', [sql_type]) - 1) AS INT) > 8000

UPDATE [table_name]
Select * from [dbo].[odata_to_sql]
SET [sql_type] = CASE
    WHEN CHARINDEX('(', [sql_type]) > 0 AND CHARINDEX(')', [sql_type]) > CHARINDEX('(', [sql_type]) AND CAST(SUBSTRING([sql_type], CHARINDEX('(', [sql_type]) + 1, CHARINDEX(')', [sql_type]) - CHARINDEX('(', [sql_type]) - 1) AS INT) > 8000
        THEN 'nvarchar(max)'
    ELSE [column_name]
    END


	UPDATE [dbo].[odata_to_sql]
SET [sql_type] 
= CASE
    WHEN CHARINDEX('(', [sql_type]) > 0 AND CHARINDEX(')', [sql_type]) > CHARINDEX('(', [sql_type]) AND CAST(SUBSTRING([sql_type], CHARINDEX('(', [sql_type]) + 1, CHARINDEX(')', [sql_type]) - CHARINDEX('(', [sql_type]) - 1) AS INT) > 8000
        THEN 'nvarchar(max)'
    ELSE [sql_type]
    END


	SELECT distinct
    CASE
        WHEN [sql_type] = 'nvarchar(max)' THEN 'nvarchar(max)'
        WHEN CHARINDEX('(', [sql_type]) > 0 AND CHARINDEX(')', [sql_type]) > CHARINDEX('(', [sql_type]) AND CAST(SUBSTRING([sql_type], CHARINDEX('(', [sql_type]) + 1, CHARINDEX(')', [sql_type]) - CHARINDEX('(', [sql_type]) - 1) AS INT) > 4000
        THEN 'nvarchar(max)'
        ELSE [sql_type]
    END AS [updated_sql_type]
FROM  [dbo].[odata_to_sql]
order by 1


---------------------------------------------------------------------------------------------------

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





