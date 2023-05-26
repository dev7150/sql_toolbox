WITH base AS (
    SELECT * FROM [dbo].[Early$] WHERE isjson(changedata)=1 
)
--INSERT INTO [dbo].[audit1hr_ms_postvaccinationquestionnaire_explodedjson] (
--    jd.[_objectid_value], 
--    jd.[_userid_value], 
--    jd.[versionnumber], 
--    jd.[operation], 
--    jd.[createdon], 
--    jd.auditid, 
--    jd.action, 
--    jd.objecttypecode, 
--    jd.transactionid, 
--    jd._regardingobjectid_value, 
--    jd.useradditionalinfo, 
--    jd.[_callinguserid_value],  
--    jd.[logicalName], 
--    jd.[oldValue], 
--    jd.[newValue]
--)
SELECT 
    j.[_objectid_value], 
    j.[_userid_value], 
    j.[versionnumber], 
    j.[operation], 
    j.[createdon], 
    j.[auditid], 
    j.[action], 
    j.[objecttypecode], 
    j.[transactionid], 
    j.[_regardingobjectid_value], 
    j.[useradditionalinfo], 
    j.[_callinguserid_value], 
    j.[logicalName],
    j.[oldValue],
    j.[newValue]
FROM base 
CROSS APPLY OPENJSON(base.[changedata], '$.changedAttributes')
WITH (
    [_objectid_value] UNIQUEIDENTIFIER '$._objectid_value',
    [_userid_value] UNIQUEIDENTIFIER '$._userid_value',
    [versionnumber] INT '$.versionnumber',
    [operation] INT '$.operation',
    [createdon] DATETIME2 '$.createdon',
    [auditid] UNIQUEIDENTIFIER '$.auditid',
    [action] INT '$.action',
    [objecttypecode] INT '$.objecttypecode',
    [transactionid] UNIQUEIDENTIFIER '$.transactionid',
    [_regardingobjectid_value] UNIQUEIDENTIFIER '$._regardingobjectid_value',
    [useradditionalinfo] NVARCHAR(MAX) '$.useradditionalinfo',
    [_callinguserid_value] UNIQUEIDENTIFIER '$._callinguserid_value',
    [logicalName] NVARCHAR(100) '$.logicalName',
    [oldValue] NVARCHAR(MAX) '$.oldValue',
    [newValue] NVARCHAR(MAX) '$.newValue'
) j;
