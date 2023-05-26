SELECT  [odata_field_name]
      ,[sql_field_name]
      ,[sql_type]
	  ,case 
		WHEN [sql_type] = 'nvarchar(max)' THEN 'nvarchar(max)'
		WHEN CHARINDEX('(', [sql_type]) > 0 AND CHARINDEX(')', [sql_type]) > CHARINDEX('(', [sql_type]) AND CAST(SUBSTRING([sql_type], CHARINDEX('(', [sql_type]) + 1, CHARINDEX(')', [sql_type]) - CHARINDEX('(', [sql_type]) - 1) AS INT) > 4000
        THEN 'nvarchar(max)'
		when odata_field_name like 'is%' and sql_type is NULL then 'bit'
		when odata_field_name like 'can%' and sql_type is NULL then 'bit'
		when sql_type is NULL then 'nvarchar(max)' 
		else sql_type end
		AS proposed_sql_type
      ,[LogicalName]
      ,[AttributeType]
      ,[AttributeOf]
      ,[SchemaName]
      ,[Targets]
      ,[entity]
      ,[first_display_name]
      ,[first_description]
      ,[IsPrimaryId]
      ,[MetadataId]
INTO  [cslam_dev].[entity_odata_to_sql_map]
  FROM [cslam_cvms].[vw_entity_odata_to_sql_map];
  GO
--  order by proposed_sql_field_name,sql_type