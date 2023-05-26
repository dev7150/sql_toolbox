/****** Script for SelectTopNRows command from SSMS  ******/
SELECT  
		[odata_field_name],
     [sql_field_name]
     -- ,[sql_type]
     -- ,[LogicalName]
     -- ,[AttributeType]
      --,[AttributeOf]
     -- ,[SchemaName]
      --,[Targets]
      ,[entity]
	  ,count(*)
      --,[first_display_name]
      --,[first_description]
      --,[IsPrimaryId]
      --,[MetadataId]
  FROM [cslam_cvms].[vw_entity_odata_to_sql_map]
  where entity = 'msdyncrm_marketingpage'
  group by 	[odata_field_name]
      ,[sql_field_name]
     -- ,[sql_type]
     -- ,[LogicalName]
     -- ,[AttributeType]
      --,[AttributeOf]
     -- ,[SchemaName]
      --,[Targets]
      ,[entity]
	  order by count(*) desc,entity,sql_field_name