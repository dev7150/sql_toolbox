/****** Script for SelectTopNRows command from SSMS  ******/
SELECT 
      [sql_field_name]
      ,[sql_type]
      ,[LogicalName]
      ,[AttributeType]
      ,[AttributeOf]
      ,[SchemaName]
     
      ,[entity]
      ,[first_display_name]
      ,[first_description]
	  , cv.COLUMN_NAME,
	  cv.TABLE_NAME
      
  FROM [Test].[dbo].[odata_to_sql] od
  full outer join [dbo].[CVMS_col] cv 
  on cv.COLUMN_NAME = od.LogicalName
  and cv.TABLE_NAME = od.entity
  where od.LogicalName is null
  and cv.COLUMN_NAME is not null
  order by  cv.TABLE_NAME,cv.COLUMN_NAME