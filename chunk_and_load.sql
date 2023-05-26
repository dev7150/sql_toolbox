DECLARE @chunk_size INT = 100000
DECLARE @offset INT = 0

WHILE @offset < (Select count(*) from big_sample)
BEGIN
    SELECT *
    INTO #temp_table
    FROM (
        SELECT *
        FROM big_sample
        ORDER BY [objecttypecode]
        OFFSET @offset ROWS
        FETCH NEXT @chunk_size ROWS ONLY
    ) AS t

    INSERT INTO [dbo].[new_table_adx_webrole]
    SELECT *
    FROM #temp_table
    WHERE [objecttypecode] = 'adx_webrole' -- replace with the actual value

    --TRUNCATE TABLE #temp_table
    DROP TABLE #temp_table

    SET @offset = @offset + @chunk_size
END