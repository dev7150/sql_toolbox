--==================================================================================
-- Remove the SDU_Tools Schema
-- Copyright Dr Greg Low
-- Version 23.0
--==================================================================================
--
-- What are the SDU Tools? 
--
-- This script removes an existing installation of SDU_Tools

USE tempdb; -- set to tempdb first in case the database hasn't been correctly set
GO          -- in the next step

USE DATABASE_NAME_HERE; -- set the database here
GO

--==================================================================================
-- Disclaimer and License
--==================================================================================
--
-- We try our hardest to make these tools as useful and bug free as possible, but like
-- any software, we can never guarantee that there won't be any issues. We hope you'll
-- decide to use the tools but all liability for using them is with you, not us.
--
-- You are free to download and use for these tools for personal, educational, and 
-- internal corporate purposes, as long as this header is retained, as long
-- as they are kept in the SDU_Tools schema as a single set of tools, and as long as 
-- this notice is kept in any script file copies of the tools. 
--
-- You may not repurpose them, redistribute, or resell them without written consent
-- from the author. We hope you'll find them really useful.
--

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @SQL nvarchar(max);
DECLARE @SchemaID int = SCHEMA_ID('SDU_Tools');

IF @SchemaID IS NOT NULL
BEGIN
    DECLARE @ObjectCounter as int = 1;
    DECLARE @ObjectName sysname;
    DECLARE @TableName sysname;
    DECLARE @ObjectTypeCode varchar(10);
    DECLARE @IsExternalTable bit;
    DECLARE @IsVersionWithExternalTables bit 
      = CASE WHEN CAST(REPLACE(SUBSTRING(CAST(SERVERPROPERTY('ProductVersion') AS varchar(20)), 1, 2), '.', '') AS int) >= 13
             THEN 1
             ELSE 0
        END;

    DECLARE @ObjectsToRemove TABLE
    ( 
        ObjectRemovalOrder int IDENTITY(1,1) NOT NULL,
        ObjectTypeCode varchar(10) NOT NULL,
        ObjectName sysname NOT NULL,
        TableName sysname NULL,
        IsExternalTable bit
    );
    
    SET @SQL = N'
    SELECT o.[type], COALESCE(tt.[name], o.[name]), t.[name]'
    + CASE WHEN @IsVersionWithExternalTables <> 0 
           THEN N', COALESCE(tab.is_external, 0) '
           ELSE N', 0 '
      END + N'
    FROM sys.objects AS o 
    LEFT OUTER JOIN sys.objects AS t
        ON o.parent_object_id = t.[object_id]
    LEFT OUTER JOIN sys.table_types AS tt
        ON tt.type_table_object_id = o.object_id 
    LEFT OUTER JOIN sys.tables AS tab 
        ON tab.object_id = o.object_id 
    WHERE COALESCE(tt.[schema_id], o.[schema_id]) = ' + CAST(@SchemaID AS nvarchar(10)) + N'
    AND NOT (o.[type] IN (''PK'', ''UQ'', ''C'', ''F'') AND t.[type] <> ''U'') -- don''t want constraints on table types etc
    ORDER BY CASE o.[type] WHEN ''V'' THEN 1    -- view
                           WHEN ''P'' THEN 2    -- stored procedure
                           WHEN ''PC'' THEN 3   -- clr stored procedure
                           WHEN ''FN'' THEN 4   -- scalar function
                           WHEN ''FS'' THEN 5   -- clr scalar function
                           WHEN ''AF'' THEN 6   -- clr aggregate
                           WHEN ''FT'' THEN 7   -- clr table-valued function
                           WHEN ''TF'' THEN 8   -- table-valued function
                           WHEN ''IF'' THEN 9   -- inline table-valued function
                           WHEN ''TR'' THEN 10  -- trigger
                           WHEN ''TA'' THEN 11  -- clr trigger
                           WHEN ''F'' THEN 12   -- foreign key constraint
                           WHEN ''D'' THEN 13   -- default
                           WHEN ''C'' THEN 14   -- check constraint
                           WHEN ''UQ'' THEN 15  -- unique constraint
                           WHEN ''PK'' THEN 16  -- primary key constraint
                           WHEN ''U'' THEN 17   -- table
                           WHEN ''TT'' THEN 18  -- table type
                           WHEN ''SO'' THEN 19  -- sequence
                           WHEN ''SN'' THEN 20  -- synonym
             END;';

    INSERT @ObjectsToRemove (ObjectTypeCode, ObjectName, TableName, IsExternalTable)
    EXEC (@SQL);    
    
    WHILE @ObjectCounter <= (SELECT MAX(ObjectRemovalOrder) FROM @ObjectsToRemove)
    BEGIN
        SELECT @ObjectTypeCode = otr.ObjectTypeCode,
               @ObjectName = otr.ObjectName,
               @TableName = otr.TableName,
               @IsExternalTable = otr.IsExternalTable 
        FROM @ObjectsToRemove AS otr 
        WHERE otr.ObjectRemovalOrder = @ObjectCounter;

        SET @SQL = CASE WHEN @ObjectTypeCode = 'V' 
                        THEN N'DROP VIEW SDU_Tools.' + QUOTENAME(@ObjectName) + N';'
                        WHEN @ObjectTypeCode IN ('P' , 'PC')
                        THEN N'DROP PROCEDURE SDU_Tools.' + QUOTENAME(@ObjectName) + N';'
                        WHEN @ObjectTypeCode IN ('FN', 'FS', 'FT', 'TF', 'IF')
                        THEN N'DROP FUNCTION SDU_Tools.' + QUOTENAME(@ObjectName) + N';'
                        WHEN @ObjectTypeCode IN ('TR', 'TA')
                        THEN N'DROP TRIGGER SDU_Tools.' + QUOTENAME(@ObjectName) + N';'
                        WHEN @ObjectTypeCode IN ('C', 'D', 'F', 'PK', 'UQ')
                        THEN N'ALTER TABLE SDU_Tools.' + QUOTENAME(@TableName) 
                             + N' DROP CONSTRAINT ' + QUOTENAME(@ObjectName) + N';'
                        WHEN @ObjectTypeCode = 'U' AND @IsExternalTable = 0
                        THEN N'DROP TABLE SDU_Tools.' + QUOTENAME(@ObjectName) + N';'
                        WHEN @ObjectTypeCode = 'U' AND @IsExternalTable <> 0
                        THEN N'DROP EXTERNAL TABLE SDU_Tools.' + QUOTENAME(@ObjectName) + N';'
                        WHEN @ObjectTypeCode = 'AF'
                        THEN N'DROP AGGREGATE SDU_Tools.' + QUOTENAME(@ObjectName) + N';'
                        WHEN @ObjectTypeCode = 'TT'
                        THEN N'DROP TYPE SDU_Tools.' + QUOTENAME(@ObjectName) + N';'
                        WHEN @ObjectTypeCode = 'SO'
                        THEN N'DROP SEQUENCE SDU_Tools.' + QUOTENAME(@ObjectName) + N';'
                        WHEN @ObjectTypeCode = 'SN'
                        THEN N'DROP SYNONYM SDU_Tools.' + QUOTENAME(@ObjectName) + N';'
                   END;

            IF @SQL IS NOT NULL
            BEGIN
                EXECUTE(@SQL);
            END;

        SET @ObjectCounter += 1;
    END;
    DROP SCHEMA SDU_Tools;
END; -- of if the schema already exists
GO
