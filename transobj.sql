/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [_objectid_value]
      ,[_userid_value]
      ,[versionnumber]
      ,[operation]
      ,[createdon]
      ,[auditid]
      ,[changedata]
      ,[attributemask]
      ,[action]
      ,[objecttypecode]
      ,[transactionid]
      ,[_regardingobjectid_value]
      ,[useradditionalinfo]
      ,[_callinguserid_value]
      ,[cs_fetch_batch]
      ,[cs_batch_number]
  FROM [Test].[dbo].[Recent$]
  with base as (Select * from [Test].[dbo].[Recent$] where isjson(changedata) = 1)
  SELECT  objecttypecode,
       JSON_VALUE(ca.value, '$.logicalName') AS logicalName
FROM base
CROSS APPLY OPENJSON(changedata, '$.changedAttributes') AS ca
GROUP BY objecttypecode,
 JSON_VALUE(ca.value, '$.logicalName')

SELECT DATABASEPROPERTYEX('db1', 'MaxSizeInBytes') AS DatabaseDataMaxSizeInBytes


with base as 
(Select distinct transactionid, objecttypecode from [dbo].[Recent$] )
SELECT t1.transactionid, STRING_AGG( t1.objecttypecode,',') as objecttypecodes
FROM base t1
JOIN base t2 ON t1.transactionid = t2.transactionid AND t1.objecttypecode <> t2.objecttypecode
GROUP BY t1.transactionid
HAVING COUNT(DISTINCT t1.objecttypecode) > 1


  --"logicalName":"ms_bolded","oldValue":null,"newValue":"True"},{"logicalName":"statuscode","oldValue":null,"newValue":"1"},{"logicalName":"ms_underlined","oldValue":null,"newValue":"False"},{"logicalName":"ms_responserequired","oldValue":null,"newValue":"False"},{"logicalName":"ownerid","oldValue":null,"newValue":"systemuser,6d0e4fac-006d-eb11-a812-000d3acb9b26"},{"logicalName":"ms_name","oldValue":null,"newValue":"2022-17-08-134480205"},{"logicalName":"ms_order","oldValue":null,"newValue":"230"},{"logicalName":"ms_italicized","oldValue":null,"newValue":"True"},{"logicalName":"ms_isupdated","oldValue":null,"newValue":"False"}]}