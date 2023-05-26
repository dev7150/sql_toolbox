
CREATE INDEX idx_objecttypecode
ON [Test].[dbo].[Recent$](objecttypecode);

SELECT DISTINCT objecttypecode INTO #temp_objecttypecode FROM [Test].[dbo].[Recent$];

--Select * from #temp_objecttypecode

DECLARE @objecttypecode VARCHAR(255);
DECLARE @sql NVARCHAR(MAX);

DECLARE objecttypecode_cursor CURSOR FOR
SELECT DISTINCT objecttypecode FROM [Test].[dbo].[Recent$];

OPEN objecttypecode_cursor;

FETCH NEXT FROM objecttypecode_cursor INTO @objecttypecode;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'SELECT * INTO new_table_' + @objecttypecode + N' FROM [Test].[dbo].[Recent$] WHERE objecttypecode = ''' + @objecttypecode + N'''';
    EXEC sp_executesql @sql;
    FETCH NEXT FROM objecttypecode_cursor INTO @objecttypecode;
END

CLOSE objecttypecode_cursor;
DEALLOCATE objecttypecode_cursor;




/*
-- Step 1: Create a temporary table to store distinct objecttypecode values
SELECT DISTINCT objecttypecode
INTO #temp_objecttypecode
FROM [Test].[dbo].[Recent$];

-- Step 2: Build a comma-separated list of new table names
DECLARE @cols NVARCHAR(MAX);
SELECT @cols = COALESCE(@cols + ',', '') + 'new_table_' + CAST(objecttypecode AS VARCHAR)
FROM #temp_objecttypecode;

-- Step 3: Build the SELECT INTO statement with the IN clause to select all relevant rows at once
DECLARE @sql NVARCHAR(MAX);
SET @sql = N'SELECT * INTO ' + @cols + N' FROM your_table WHERE objecttypecode IN (SELECT objecttypecode FROM #temp_objecttypecode)';

-- Step 4: Execute the SELECT INTO statement
EXEC sp_executesql @sql;

-- Step 5: Drop the temporary table
DROP TABLE #temp_objecttypecode;

*/


SELECT DISTINCT objecttypecode
INTO #temp_objecttypecode
FROM [Test].[dbo].[Recent$];

Select * from #temp_objecttypecode

-- Step 2: Build a comma-separated list of new table names
DECLARE @cols NVARCHAR(MAX);
SELECT @cols = COALESCE(@cols + ',', '') + 'new_table_' + CAST(objecttypecode AS VARCHAR)
FROM #temp_objecttypecode;
-- PRINT @cols;


DROP TABLE #temp_objecttypecode;





-- Step 1: Create a temporary table to store distinct objecttypecode values
SELECT DISTINCT objecttypecode
INTO #temp_objecttypecode
FROM [Test].[dbo].[Recent$];

-- Step 2: Build a comma-separated list of new table names
DECLARE @cols NVARCHAR(MAX);
SELECT @cols = COALESCE(@cols + ',', '') + 'new_table_' + CAST(objecttypecode AS VARCHAR)
FROM #temp_objecttypecode;
PRINT @cols;

-- Step 3: Build the SELECT INTO statement with the IN clause to select all relevant rows at once
DECLARE @sql NVARCHAR(MAX)='';
SET @sql = N'SELECT * INTO ' + @cols + N' FROM your_table WHERE objecttypecode IN (SELECT objecttypecode FROM #temp_objecttypecode)';

-- Step 4: Execute the SELECT INTO statement
PRINT @sql
EXEC sp_executesql @sql;

-- Step 5: Drop the temporary table
DROP TABLE #temp_objecttypecode;




--BATCHING

-- Step 1: Create a temporary table to store distinct objecttypecode values
SELECT DISTINCT objecttypecode
INTO #temp_objecttypecode
FROM [Test].[dbo].[Recent$];

-- Step 2: Build a comma-separated list of new table names
DECLARE @cols NVARCHAR(MAX);
SELECT @cols = COALESCE(@cols + ',', '') + 'new_table_' + CAST(objecttypecode AS VARCHAR)
FROM #temp_objecttypecode;

-- Step 3: Initialize variables
DECLARE @batch_size INT = 10000; -- modify as needed
DECLARE @current_row INT = 1;
DECLARE @max_row INT = (SELECT MAX(id) FROM [Test].[dbo].[Recent$]);
DECLARE @sql NVARCHAR(MAX);

-- Step 4: Loop through the table in batches and insert into new tables
WHILE @current_row <= @max_row
BEGIN
    SET @sql = N'';
    SELECT @sql = N'SELECT * INTO ' + @cols + N' FROM [Test].[dbo].[Recent$] WHERE id BETWEEN ' 
	+ CAST(@current_row AS VARCHAR) + ' AND ' + CAST(@current_row + @batch_size - 1 AS VARCHAR) + ' AND objecttypecode IN (SELECT objecttypecode FROM #temp_objecttypecode)';
    EXEC sp_executesql @sql);
    SET @current_row = @current_row + @batch_size;
END

-- Step 5: Drop the temporary table
DROP TABLE #temp_objecttypecode;

