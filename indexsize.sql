 (SELECT 
    t.NAME AS TableName,
    s.Name AS SchemaName,
    p.rows AS RowCounts,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    CAST(ROUND(((SUM(a.total_pages) * 8) / (1024.00)), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
	INTO #tablesize
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id

WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, s.Name, p.Rows
)

DECLARE @tableName nvarchar(256)
DECLARE @schemaName nvarchar(256)

CREATE TABLE #spaceusage
(
    name nvarchar(256),
    rows bigint,
    reserved varchar(50),
    data varchar(50),
    index_size varchar(50),
    unused varchar(50)
)

DECLARE tableCursor CURSOR FOR
SELECT s.name AS SchemaName, t.name AS TableName
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id

OPEN tableCursor

FETCH NEXT FROM tableCursor INTO @schemaName, @tableName

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @sql nvarchar(500)
    SET @sql = CONCAT(N'INSERT INTO #spaceusage EXEC sp_spaceused ''[', @schemaName, '].[', @tableName, ']''')

    EXEC sp_executesql @sql

    FETCH NEXT FROM tableCursor INTO @schemaName, @tableName
END

CLOSE tableCursor
DEALLOCATE tableCursor

SELECT SchemaName,TableName,rows,data,index_size,reserved FROM #spaceusage
join #tablesize on #tablesize.TableName = #spaceusage.name
and #tablesize.RowCounts = #spaceusage.rows
order by name

DROP TABLE #tablesize,#spaceusage
