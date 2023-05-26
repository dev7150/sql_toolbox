exec usp_DataProfiling 1,dbo,Recent$,'','','','',''


CREATE OR ALTER PROCEDURE usp_DataProfiling
 @Report TINYINT ,  --1 = 'ColumnDataProfiling', 2 = 'ColumnUniqueValues'
 @SchemaName NVARCHAR(MAX) = N'',
 @ObjectlisttoSearch NVARCHAR(MAX),
 @ExcludeTables NVARCHAR(MAX) = N'',
 @ExcludeColumns NVARCHAR(MAX) = N'',
 @ExcludeDataType NVARCHAR(100) = N'',
 @RestrictCharlength INT,
 @RestrictNoOfUniqueValues INT
AS
 
 BEGIN
 
 
 SET NOCOUNT ON;
 SET ANSI_WARNINGS OFF;
 SET ANSI_NULLS ON;
 
 SELECT @RestrictCharlength = IIF(@RestrictCharlength IS NULL OR @RestrictCharlength = '',100,@RestrictCharlength)
 SELECT @RestrictNoOfUniqueValues = IIF(@RestrictNoOfUniqueValues IS NULL OR @RestrictNoOfUniqueValues = '',50,@RestrictNoOfUniqueValues)
     
DECLARE @TableColList TABLE (Id INT IDENTITY(1,1),Tbl NVARCHAR(128),colname NVARCHAR(200),ColType NVARCHAR(150))
 
 IF ISNULL(@SchemaName,'') <> ''  OR ISNULL(@ObjectlisttoSearch,'') <> ''
 BEGIN
    
INSERT @TableColList
SELECT    DISTINCT CONCAT(SCHEMA_NAME(T.SCHEMA_ID),'.',T.name) TableName
         ,C.name
         ,CASE WHEN TY.is_user_defined = 1 THEN (SELECT name FROM sys.types
                                                 WHERE system_type_id = user_type_id
                                                    AND  system_type_id =  TY.system_type_id)
                                            ELSE TY.name
          END
FROM Sys.tables T
JOIN sys.columns C
    ON T.object_id = C.object_id
JOIN sys.types TY
    ON C.[user_type_id] = TY.[user_type_id]
-- Ignore the datatypes that are not required
WHERE TY.name NOT IN ('geography','varbinary','binary','text', 'ntext', 'image', 'hierarchyid', 'xml', 'sql_variant')
    AND (Schema_name(T.schema_id) IN (SELECT value FROM STRING_SPLIT(@SchemaName, ','))
    OR CONCAT(SCHEMA_NAME(T.SCHEMA_ID),'.',T.name) IN (SELECT value FROM STRING_SPLIT(@ObjectlisttoSearch, ',')))
    AND (TY.name NOT IN (SELECT value FROM STRING_SPLIT(@ExcludeDataType, ','))
    AND TY.name = TY.name)
    AND (C.name NOT IN (SELECT value FROM STRING_SPLIT(@ExcludeColumns, ','))
    AND C.name = C.name)
    AND (CONCAT(SCHEMA_NAME(T.SCHEMA_ID),'.',T.name) NOT IN (SELECT value FROM STRING_SPLIT(@ExcludeTables, ','))
    AND CONCAT(SCHEMA_NAME(T.SCHEMA_ID),'.',T.name) = CONCAT(SCHEMA_NAME(T.SCHEMA_ID),'.',T.name))
 
 END ELSE
   
 BEGIN
   
 INSERT @TableColList
SELECT    DISTINCT CONCAT(SCHEMA_NAME(T.SCHEMA_ID),'.',T.name) TableName
          ,C.name
          ,CASE WHEN TY.is_user_defined = 1 THEN (SELECT name FROM sys.types
                                                 WHERE system_type_id = user_type_id
                                                    AND  system_type_id =  TY.system_type_id)
                                            ELSE TY.name
          END
FROM Sys.tables T
JOIN sys.columns C
    ON T.object_id = C.object_id
JOIN sys.types TY
    ON C.[user_type_id] = TY.[user_type_id]
-- Ignore the datatypes that are not required
WHERE TY.name NOT IN ('geography','varbinary','binary','text', 'ntext', 'image', 'hierarchyid', 'xml', 'sql_variant')
    AND (TY.name NOT IN (SELECT value FROM STRING_SPLIT(@ExcludeDataType, ','))
    AND TY.name = TY.name)
    AND (C.name NOT IN (SELECT value FROM STRING_SPLIT(@ExcludeColumns, ','))
    AND C.name = C.name)
    AND (CONCAT(SCHEMA_NAME(T.SCHEMA_ID),'.',T.name) NOT IN (SELECT value FROM STRING_SPLIT(@ExcludeTables, ','))
    AND CONCAT(SCHEMA_NAME(T.SCHEMA_ID),'.',T.name) = CONCAT(SCHEMA_NAME(T.SCHEMA_ID),'.',T.name))
   
 END
 
DROP TABLE IF EXISTS #Final
CREATE TABLE #Final (Id BIGINT IDENTITY(1,1),TableName NVARCHAR(128),ColumnName NVARCHAR(200),ColumnType NVARCHAR(150),ColumnUniqueValues NVARCHAR(MAX),UniqueValueOccurance BIGINT,MissingDataRowCount BIGINT,MinValue NVARCHAR(MAX),MaxValue NVARCHAR(MAX),SpecialCharacters BIGINT,LeadingTrailingSpaces BIGINT,MinFieldValueLen BIGINT,MaxFieldValueLen BIGINT,Comment NVARCHAR(MAX))
 
DROP TABLE IF EXISTS  #temp
CREATE TABLE #temp (Id BIGINT IDENTITY(1,1),TableName NVARCHAR(128),ColumnName NVARCHAR(200),Cnt BIGINT,MaxLen BIGINT,MinLen BIGINT,MissingDataCount BIGINT,MinValue NVARCHAR(MAX),MaxValue NVARCHAR(MAX),SpecialCharacters BIGINT,LeadingTrailingSpaces BIGINT)
 
DECLARE @I                        INT = 1
       ,@SQL                      NVARCHAR(MAX) = N''
       ,@tblname                  NVARCHAR(128)
       ,@Colname                  NVARCHAR(200)
       ,@ColType                  NVARCHAR(150)
       ,@Cnt                      BIGINT
       ,@MaxLen                   BIGINT
       ,@MinLen                   BIGINT
       ,@MissingData              BIGINT
       ,@MaxVal                   NVARCHAR(MAX) = N''
       ,@MinVal                   NVARCHAR(MAX) = N''
       ,@MinMAxSQL                NVARCHAR(MAX) = N''
       ,@SpecialCharacters        BIGINT
       ,@LeadingTrailingSpaces    BIGINT
 
  WHILE @I <= (SELECT MAX(Id) FROM @TableColList)
  BEGIN
 
 
 
  SELECT @Colname = QUOTENAME(colname),@tblname = Tbl,@ColType = ColType  FROM @TableColList
  WHERE Id = @I
 
SELECT @MinMAxSQL = CASE WHEN @ColType IN ('date','datetime','datetime2','datetimeoffset','time','timestamp')
                         THEN CONCAT(' FORMAT (MIN(',@Colname,'), ''yyyy-MM-dd,hh:mm:ss'') MinValue,FORMAT (MAX(',@Colname,'), ''yyyy-MM-dd,hh:mm:ss'') MAXValue')
                         WHEN @ColType = 'bit'
                         THEN '0 AS MinValue,1 AS MaxValue'
                         ELSE CONCAT('CASE WHEN EXISTS (SELECT 1 FROM ',@tblname,' WHERE ISNUMERIC(',@Colname,') = 0)','THEN NULL ELSE MIN(',@Colname,')   END MinValue
                             ,CASE WHEN EXISTS (SELECT 1 FROM ',@tblname,' WHERE ISNUMERIC(',@Colname,') = 0)','THEN NULL ELSE MAX(',@Colname,')   END MAXValue')
                     END
 
EXEC (';WITH CTE AS (
        SELECT   COUNT_BIG(DISTINCT '+@Colname+') Cnt
                ,MAX(LEN('+@Colname+')) MaxLen
                ,MIN(LEN('+@Colname+')) MinLen
                ,SUM(CASE WHEN '+@Colname+' IS NULL OR CAST('+@Colname+' AS VARCHAR(MAX)) = '''' THEN 1 ELSE 0 END) MissingData
                ,'+@MinMAxSQL+'
                ,CASE WHEN '''+@ColType+''' IN (''nvarchar'',''varchar'',''nchar'',''char'')
                      THEN SUM(CASE WHEN '+@Colname+' LIKE ''%[^a-zA-Z0-9 ]%'' THEN 1 ELSE 0 END)
                      ELSE NULL END SpecialCharacters
                ,CASE WHEN '''+@ColType+''' IN (''nvarchar'',''varchar'',''nchar'',''char'')
                      THEN SUM(CASE WHEN ISNULL(DATALENGTH('+@Colname+'),'''') = ISNULL(DATALENGTH(RTRIM(LTRIM('+@Colname+'))),'''') THEN 0 ELSE 1 END)
                      ELSE NULL END LeadingTrailingSpaces
        FROM '+@tblname+' )
        INSERT #temp(TableName,ColumnName,Cnt,MaxLen,MinLen,MissingDataCount,MinValue,MaxValue,SpecialCharacters,LeadingTrailingSpaces)
        SELECT '''+@tblname+''','''+@Colname+''',Cnt,ISNULL(MaxLen,0) MaxLen,ISNULL(MinLen,0) MinLen,ISNULL(MissingData,0) MissingData,MinValue,MAXValue
        ,ISNULL(SpecialCharacters,0) SpecialCharacters,ISNULL(LeadingTrailingSpaces,0) LeadingTrailingSpaces FROM CTE')
   
  SELECT @Cnt = Cnt,@MaxLen = MaxLen,@MinLen = MinLen,@MissingData = MissingDataCount,@MinVal=MinValue,@MaxVal=MAXValue
        ,@SpecialCharacters = SpecialCharacters  ,@LeadingTrailingSpaces = LeadingTrailingSpaces 
  FROM #temp
  WHERE Id = @I AND TableName = @tblname AND ColumnName = @Colname
 
  IF ISNULL(@MaxLen,'') < @RestrictCharlength AND ISNULL(@Cnt,'') < @RestrictNoOfUniqueValues  
      BEGIN
       
      SET @SQL = CONCAT('SELECT ''',@tblname,''',''',@Colname,''',''',@ColType,''',',@Colname,',COUNT_BIG(',@Colname,'),',@MissingData,',''',@MinVal,''',''',@MaxVal,''',',@SpecialCharacters,',',@LeadingTrailingSpaces,',',@MinLen,',',@MaxLen,',','''','This field has Unique values = ',@Cnt,'''',' FROM ',@tblname,' GROUP BY ',@Colname)
      INSERT #Final (TableName,ColumnName,ColumnType,ColumnUniqueValues,UniqueValueOccurance,MissingDataRowCount,MinValue,MaxValue,SpecialCharacters,LeadingTrailingSpaces,MinFieldValueLen,MaxFieldValueLen,Comment)
      EXEC(@SQL)
 
      END
 
  ELSE
      BEGIN
 
      INSERT #Final (TableName,ColumnName,ColumnType,MissingDataRowCount,MinValue,MaxValue,SpecialCharacters,LeadingTrailingSpaces,MinFieldValueLen,MaxFieldValueLen,Comment)
      SELECT @tblname,@Colname,@ColType,@MissingData,@MinVal,@MaxVal,@SpecialCharacters,@LeadingTrailingSpaces,@MinLen,@MaxLen,CONCAT('This field has Unique values = ',@Cnt)
      END
 
  SET @I = @I + 1
  END
 
  IF @Report = 1
  BEGIN
 
  SELECT DISTINCT   TableName,ColumnName,ColumnType,MissingDataRowCount,MinValue,MaxValue,SpecialCharacters
                    ,LeadingTrailingSpaces,MinFieldValueLen,MaxFieldValueLen,Comment
  FROM #Final
  ORDER BY TableName,ColumnName
 
  END
   
 IF @Report = 2
 BEGIN
 
  SELECT TableName,ColumnName,ColumnUniqueValues,UniqueValueOccurance,Comment
  FROM #Final
  ORDER BY TableName,ColumnName
 
 END
 
  END


--CREATE OR ALTER PROCEDURE usp_DataProfiling_Metadata
-- @Report TINYINT ,  --1 = 'TableStats', 2 = 'TableColumnMetadata'
-- @SchemaName NVARCHAR(MAX) = N'',
-- @ObjectlisttoSearch NVARCHAR(MAX) = N''
--AS
 
-- BEGIN
-- SET NOCOUNT ON;
 
--DROP TABLE IF EXISTS  #TblList
--CREATE TABLE #TblList(Id INT IDENTITY(1,1),TableName NVARCHAR(200) )
 
--DROP TABLE IF EXISTS  #Tblstats
--CREATE TABLE #Tblstats (TableName NVARCHAR(200),NoOfRows NVARCHAR(100),ReservedSpace NVARCHAR(100)
--                       ,DataSpace NVARCHAR(100),IndexSize NVARCHAR(100),UnusedSpace NVARCHAR(100)
--                       ,LastUserUpdate DATETIME)
 
-- IF ISNULL(@SchemaName,'') <> ''  OR ISNULL(@ObjectlisttoSearch,'') <> ''
-- BEGIN
 
--INSERT #TblList (TableName)
--SELECT CONCAT(SCHEMA_NAME(SCHEMA_ID),'.',name) TableName 
--FROM Sys.tables
--WHERE (Schema_name(schema_id) IN (SELECT value FROM STRING_SPLIT(@SchemaName, ','))
--    OR CONCAT(SCHEMA_NAME(SCHEMA_ID),'.',name) IN (SELECT value FROM STRING_SPLIT(@ObjectlisttoSearch, ',')))
 
-- END ELSE
-- BEGIN
 
--INSERT #TblList (TableName)
--SELECT CONCAT(SCHEMA_NAME(SCHEMA_ID),'.',name) TableName 
--FROM Sys.tables
 
-- END
 
--DECLARE @Tblstats TABLE(TableName NVARCHAR(200),NoOfRows NVARCHAR(100),ReservedSpace NVARCHAR(100)
--                       ,DataSpace NVARCHAR(100),IndexSize NVARCHAR(100),UnusedSpace NVARCHAR(100)
--                       )
 
--DECLARE @I                        INT = 1
--       ,@tblname                  NVARCHAR(128) = N''
--       ,@last_user_update         DATETIME
 
--WHILE @I <= (SELECT COUNT(1) FROM #TblList)
--BEGIN
 
--SELECT @tblname=TableName FROM #TblList WHERE Id = @I
 
--INSERT @Tblstats
--EXEC sp_spaceused @tblname; 
 
--SELECT TOP 1 @last_user_update=last_user_update
--FROM sys.dm_db_index_usage_stats  
--WHERE object_id = OBJECT_ID(@tblname)
--ORDER BY   last_user_update DESC
 
--INSERT #Tblstats(TableName,NoOfRows,ReservedSpace,DataSpace,IndexSize,UnusedSpace,LastUserUpdate)
--SELECT @tblname,NoOfRows,ReservedSpace,DataSpace,IndexSize,UnusedSpace,@last_user_update 
--FROM @Tblstats
 
--DELETE FROM @Tblstats
 
--SET @I = @I + 1
--END
 
--  IF @Report = 1
--  BEGIN
 
-- ;WITH Systbl
-- AS
-- (
--  SELECT DISTINCT CONCAT(SCHEMA_NAME(SCHEMA_ID),'.',name) TableName
--        ,modify_date TableSchema_LastModifyDate
--        ,CASE WHEN is_replicated = 1 THEN 'Yes' ELSE 'No' END AS IsReplicated
--        ,CASE WHEN is_filetable = 1 THEN 'Yes' ELSE 'No' END AS IsFileTable
--        ,CASE WHEN is_memory_optimized = 1 THEN 'Yes' ELSE 'No' END AS IsMemoryOptimized
--        ,temporal_type_desc TemporalTypeDesc
--        ,CASE WHEN is_remote_data_archive_enabled = 1 THEN 'Yes' ELSE 'No' END AS IsStretchEnabled
--        ,CASE WHEN is_external = 1 THEN 'Yes' ELSE 'No' END AS IsExternal
--        ,CASE WHEN is_node = 1 OR is_edge = 1 THEN 'Yes' ELSE 'No' END IsGraphTable
-- FROM sys.tables ST
-- JOIN #TblList T
-- ON CONCAT(SCHEMA_NAME(SCHEMA_ID),'.',name) COLLATE DATABASE_DEFAULT = T.TableName COLLATE DATABASE_DEFAULT
-- )
--SELECT B.*,A.TableSchema_LastModifyDate
--,A.IsMemoryOptimized
--,A.IsExternal
--,A.IsStretchEnabled
--,A.IsFileTable
--,A.IsGraphTable
--,A.IsReplicated
--,A.TemporalTypeDesc
--FROM Systbl A
--JOIN #Tblstats B
--ON A.TableName COLLATE DATABASE_DEFAULT = B.TableName COLLATE DATABASE_DEFAULT
 
 
--  END
   
-- IF @Report = 2
-- BEGIN
 
--  SELECT  DISTINCT CONCAT(SCHEMA_NAME(T.SCHEMA_ID),'.',T.name) TableName
--         ,C.name ColumnName
--         ,CASE WHEN TY.is_user_defined = 1 THEN (SELECT name FROM sys.types
--                                                 WHERE system_type_id = user_type_id
--                                                    AND  system_type_id =  TY.system_type_id)
--                                            ELSE TY.name
--          END AS DataType
--          ,C.max_length
--          ,C.precision
--          ,C.scale
--          ,C.collation_name
--          ,CASE WHEN C.is_nullable = 1 THEN 'Yes' ELSE 'No' END AS IsNullable
--          ,CASE WHEN C.is_identity = 1 THEN 'Yes' ELSE 'No' END AS IsIdentity
--          ,CASE WHEN C.is_masked = 1 THEN 'Yes' ELSE 'No' END AS IsMasked
--          ,CASE WHEN C.is_hidden = 1 THEN 'Yes' ELSE 'No' END AS IsHidden
--          ,CASE WHEN C.is_computed = 1 THEN 'Yes' ELSE 'No' END AS IsComputed
--          ,CASE WHEN C.is_filestream = 1 THEN 'Yes' ELSE 'No' END AS IsFileStream
--          ,CASE WHEN C.is_sparse = 1 THEN 'Yes' ELSE 'No' END AS IsSparse
--          ,C.encryption_type_desc  EncryptionTypeDesc
--FROM Sys.tables T
--JOIN sys.columns C
--    ON T.object_id = C.object_id
--JOIN sys.types TY
--    ON C.[user_type_id] = TY.[user_type_id]
--WHERE (Schema_name(T.schema_id) IN (SELECT value FROM STRING_SPLIT(@SchemaName, ','))
--    OR CONCAT(SCHEMA_NAME(T.SCHEMA_ID),'.',T.name) IN (SELECT value FROM STRING_SPLIT(@ObjectlisttoSearch, ',')))
 
-- END
 
--  END