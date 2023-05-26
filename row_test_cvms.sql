/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [table_name]
      ,[id_value]
      ,[dataverse]
      ,[aggregated_keys]
      ,[sql_statement]
      ,[synapse]
      ,[SYNAPSE_UPPER]
      ,[DATAVERSE_UPPER]
      ,[match]
  FROM [cvms_admin].[vw_test_row_synapse_vs_fetchxml]


with base as (SELECT table_name,id_value,j.*
FROM cvms_admin.vw_test_row_synapse_vs_fetchxml a
CROSS APPLY OPENJSON(dataverse)  j)

Select * from cvms_admin.row_test_cvms

ALTER TABLE cvms_admin.row_test_cvms
ADD synapse_data nvarchar(max)

UPDATE [cvms_admin].[row_test_cvms]
SET sql_statement = CONCAT('SELECT ',[key], ' FROM ', 'cvms_synapse_v3.',table_name, ' WHERE ', CONCAT(table_name, 'id'), ' = ''', id_value, '''')
---------------------------------------------------------------------------------------------------
DECLARE @sql NVARCHAR(MAX);
DECLARE @sqlStatement NVARCHAR(MAX);
--DECLARE @synapse NVARCHAR(MAX);
Declare @id_value nvarchar(max);

DECLARE cursorName CURSOR FOR
SELECT  sql_statement,id_value
FROM [cvms_admin].[row_test_cvms];

OPEN cursorName;

FETCH NEXT FROM cursorName INTO  @sqlStatement,@id_value;
Select @sqlStatement,@id_value
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'UPDATE [cvms_admin].[row_test_cvms] SET synapse_data'  + ' = (' + @sqlStatement + ')' + 'where id_value=''' + @id_value + '''';
	PRINT @sql;
    EXEC sp_executesql @sql;

    FETCH NEXT FROM cursorName INTO  @sqlStatement,@id_value;
END;

CLOSE cursorName;
DEALLOCATE cursorName;

 "\nupdate [cvms_admin].[row_test_cvms]\nSET synapse_data = (SELECT top 1 ownerid FROM cvms_synapse_v3.bookableresourcebooking where bookableresourcebookingid=82204a5e-8e60-ed11-9561-000d3a791e24)\n\nselect 'success'",

"\nupdate [cvms_admin].[row_test_cvms]\nSET synapse_data = (SELECT top 1 msdyn_worklocation FROM cvms_synapse_v3.bookableresourcebooking where bookableresourcebookingid='82204a5e-8e60-ed11-9561-000d3a791e24')\nwhere bookableresourcebookingid='82204a5e-8e60-ed11-9561-000d3a791e24\n\n\nselect 'success'",