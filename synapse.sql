Select * from 

[cvms_admin].[rows_test_extract]
order by 1

ALTER TABLE [cvms_admin].[rows_test_extract]
ADD  synapse nvarchar(max)




UPDATE [cvms_admin].[rows_test_extract]
SET sql_statement = CONCAT('SELECT ', aggregated_keys, ' FROM ', 'cvms_synapse_v3.',table_name, ' WHERE ', CONCAT(table_name, 'id'), ' = ''', id_value, '''',' for json auto')

Delete 
 [cvms_admin].[rows_test_extract]
where table_name is null
-------------------------------------------------------------------


DECLARE @sql NVARCHAR(MAX);
DECLARE @sqlStatement NVARCHAR(MAX);
--DECLARE @synapse NVARCHAR(MAX);
Declare @id_value nvarchar(max);

DECLARE cursorName CURSOR FOR
SELECT  sql_statement,id_value
FROM [cvms_admin].[rows_test_extract];

OPEN cursorName;

FETCH NEXT FROM cursorName INTO  @sqlStatement,@id_value;
Select @sqlStatement,@id_value
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'UPDATE [cvms_admin].[rows_test_extract] SET synapse'  + ' = (' + @sqlStatement + ')' + 'where id_value=''' + @id_value + '''';
	PRINT @sql;
    EXEC sp_executesql @sql;

    FETCH NEXT FROM cursorName INTO  @sqlStatement,@id_value;
END;

CLOSE cursorName;
DEALLOCATE cursorName;

