WITH base AS (
    SELECT  top 100 * FROM  [dbo].[Early$] WHERE isjson(changedata)=1)

SELECT 
    jd.[_objectid_value], 
    jd.[_userid_value], 
    jd.[versionnumber], 
    jd.[operation], 
    jd.[createdon], 
    jd.auditid, 
    jd.action, 
    jd.objecttypecode, 
    jd.transactionid, 
    jd._regardingobjectid_value, 
    jd.useradditionalinfo, 
    jd.[_callinguserid_value], 
    jd.[cs_fetch_batch], 
    jd.[cs_batch_number], 
    jd.[logicalName], 
    jd.[oldValue], 
    jd.[newValue]
    --,jd.attributemask as amask
INTO [dbo].[audit1hr_ms_postvaccinationquestionnaire_explodedjsona]
FROM (
    SELECT 
        t.[_objectid_value], 
        t.[_userid_value], 
        t.[versionnumber], 
        t.[operation], 
        t.[createdon], 
        t.[auditid], 
        t.[action], 
        t.[objecttypecode], 
        t.[transactionid], 
        t.[_regardingobjectid_value], 
        t.[useradditionalinfo], 
        t.[_callinguserid_value], 
        t.[cs_fetch_batch], 
        t.[cs_batch_number],
        j.[logicalName],
        j.[oldValue],
        j.[newValue]
    FROM base t
    CROSS APPLY OPENJSON(t.[changedata], '$.changedAttributes')
    WITH (
        [logicalName] NVARCHAR(100) '$.logicalName',
        [oldValue] NVARCHAR(MAX) '$.oldValue',
        [newValue] NVARCHAR(MAX) '$.newValue'
    ) j
) jd




--DROP TABLE new_table_name


