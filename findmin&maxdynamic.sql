/****** Script for SelectTopNRows command from SSMS  ******/
declare @tableName varchar(200) = 'AdminDataImport';
declare @schemaName varchar(200) = 'dbo'; 

declare @sql nvarchar(max);
PRINT @sql;
declare @stmnt varchar(max) = 'SELECT ''{COL_NAME}''  [column_name], min({COL_NAME}) [min],  max({COL_NAME}) [max]';
with query as(
select  
	CONCAT(replace(@stmnt, '{COL_NAME}', [column_name]), ' FROM [', @schemaName, '].[', @tableName,'] ') [sql]
	from INFORMATION_SCHEMA.COLUMNS
	where TABLE_NAME = @tableName and TABLE_SCHEMA = @schemaName and not [column_name] like 'dl_%' and DATA_TYPE in ('datetime2')
)
select @sql = COALESCE(@sql + ' UNION ','') + [sql] 
from query;
--PRINT @sql;
exec sp_executesql @sql;

--------------------------------------------------------------------------------------------------------------------
DECLARE @schemaName VARCHAR(200) = 'cvms_synapse_v3';
DECLARE @sql NVARCHAR(MAX);
DECLARE @stmnt VARCHAR(MAX) = 'INSERT INTO cvms_admin.createon_min_max_mismatched_rows (table_name, column_name, [min], [max]) SELECT ''{TABLE_NAME}'', ''{COL_NAME}'', MIN({COL_NAME}), MAX({COL_NAME}) FROM cvms_synapse_v3.{TABLE_NAME}';

WITH query AS (
    SELECT  
        REPLACE(REPLACE(@stmnt, '{TABLE_NAME}', TABLE_NAME), '{COL_NAME}', COLUMN_NAME) AS [sql]
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @schemaName
        AND DATA_TYPE IN ('datetimeoffset')
        AND TABLE_NAME IN (
            'activityparty',
            'adx_webrole_contact',
            'email',
            'principalobjectaccess',
            'attributeimageconfig',
            'attributemap',
            'entityanalyticsconfig',
            'entityimageconfig',
            'entitymap',
            'fileattachment',
            'ms_prodab2bdevice',
            'msdyn_analysiscomponent',
            'msdyn_analysisjob',
            'msdyn_analysisresult',
            'offlinecommanddefinition',
            'organizationdatasyncstate',
            'privilege',
            'privilegeobjecttypecodes',
            'queue',
            'roleprivileges',
            'savedquery',
            'solution',
            'stringmap',
            'systemform',
            'timezonerule'
        )
)
SELECT @sql = COALESCE(@sql + ';', '') + [sql] 
FROM query;

-- Create the output table if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'cvms_admin.createon_min_max_mismatched_rows')
BEGIN
    CREATE TABLE cvms_admin.createon_min_max_mismatched_rows (
        table_name NVARCHAR(200),
        column_name NVARCHAR(200),
        [min] DATETIMEOFFSET,
        [max] DATETIMEOFFSET
    );
END;

-- Execute the dynamic SQL statement
EXEC sp_executesql @sql;
-------------------------------------------------------------------------------
<fetch mapping="logical" aggregate="true" returntotalrecordcount="true">
  <entity name="attributemap">
    <attribute name="attributemapid" alias="recordcount" aggregate="count" />
    <filter>
      <condition attribute="createdon" operator="le" value="2023-05-07 12:29:12" />
    </filter>
  </entity>
</fetch>