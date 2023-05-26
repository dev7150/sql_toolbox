CREATE TABLE #temp (
  query NVARCHAR(MAX)
);

DECLARE @sql NVARCHAR(MAX) = '';

SELECT @sql = @sql + 'SELECT ' + QUOTENAME(c.TABLE_SCHEMA, '''') + ' AS schema_name, ' + QUOTENAME(c.TABLE_NAME, '''') + ' AS table_name,'+QUOTENAME(c.COLUMN_NAME, '''') + ' [column_name], SUM(IIF(DATALENGTH(' + QUOTENAME(c.COLUMN_NAME) + ') > 0, 1, 0)) [total_values_found], COUNT(1) [total_rows] ' +
    'FROM ' + QUOTENAME(c.TABLE_SCHEMA, '[') + '.' + QUOTENAME(c.TABLE_NAME, '[') + ' AS t UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.COLUMN_NAME NOT LIKE 'dl_%';

DECLARE @start INT = 1, @end INT = CHARINDEX('UNION ALL', @sql);
DECLARE @select NVARCHAR(MAX);

WHILE @start < LEN(@sql) + 1
BEGIN
  IF @end = 0 SET @end = LEN(@sql) + 1;

  SET @select = SUBSTRING(@sql, @start, @end - @start);
  SET @start = @end + LEN('UNION ALL');
  SET @end = CHARINDEX('UNION ALL', @sql, @start);

  INSERT INTO #temp (query) VALUES (@select);
END

SELECT * FROM #temp;

CREATE TABLE #results (
  [schema_name] nvarchar(max),
  [table_name] nvarchar(max),
  column_name NVARCHAR(MAX),
  total_values_found INT,
  total_rows INT
);

DECLARE @query NVARCHAR(MAX);

DECLARE cursor_name CURSOR FOR
SELECT query FROM #temp;

OPEN cursor_name;

FETCH NEXT FROM cursor_name INTO @query;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #results ([schema_name],table_name,column_name, total_values_found, total_rows)
    EXEC sp_executesql @query;

    FETCH NEXT FROM cursor_name INTO @query;
END;

CLOSE cursor_name;
DEALLOCATE cursor_name;

SELECT * FROM #results;

DROP TABLE #results;
DROP TABLE #temp;
