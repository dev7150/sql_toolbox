-- create clustered index on auditid
CREATE CLUSTERED INDEX ix_auditid ON big_sample(auditid);

-- create non-clustered index on objecttypecode
CREATE NONCLUSTERED INDEX ix_objecttypecode ON big_sample(objecttypecode);


-- Create clustered columnstore index on the main table
CREATE CLUSTERED COLUMNSTORE INDEX cs_main_table ON big_sample;

-- Create temp table with columnstore index
CREATE TABLE #temp_table (
    [_objectid_value] [nvarchar](255) NULL,
    [_userid_value] [nvarchar](255) NULL,
    [versionnumber] [float] NULL,
    [operation] [float] NULL,
    [createdon] [datetime] NULL,
    [auditid] [nvarchar](255) NULL,
    [changedata] [nvarchar](max) NULL,
    [attributemask] [nvarchar](max) NULL,
    [action] [float] NULL,
    [objecttypecode] [nvarchar](255) NULL,
    [transactionid] [nvarchar](255) NULL,
    [_regardingobjectid_value] [nvarchar](255) NULL,
    [useradditionalinfo] [nvarchar](255) NULL,
    [_callinguserid_value] [nvarchar](255) NULL,
    [cs_fetch_batch] [nvarchar](255) NULL,
    [cs_batch_number] [float] NULL) ;

-- Insert data in chunks
DECLARE @chunk_size INT = 100000
DECLARE @offset INT = 0

WHILE @offset < (21100000)
BEGIN
	TRUNCATE TABLE #temp_table
    INSERT INTO #temp_table WITH (TABLOCKX)
    SELECT *
    FROM big_sample WITH (INDEX(ix_objecttypecode))
    WHERE [objecttypecode] = 'systemuser' -- replace with the actual value
    --AND [auditid] NOT IN (SELECT [auditid] FROM [dbo].[new_table_adx_webrole])
    ORDER BY [auditid]
    OFFSET @offset ROWS
    FETCH NEXT @chunk_size ROWS ONLY

    INSERT INTO [dbo].[new_table_systemuser]
    SELECT *
    FROM #temp_table
    ORDER BY [auditid]

    SET @offset = @offset + @chunk_size
	PRINT @offset
END

-- Drop temp table
DROP TABLE #temp_table;
