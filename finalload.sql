WITH base AS (
    SELECT * FROM  [cslam_cvms].[audits_1hr] WHERE isjson(changedata)=1)

INSERT INTO [cslam_dev].[exploded_audits]
    ([_objectid_value], 
    [_userid_value], 
   [versionnumber], 
    [operation], 
    [createdon], 
    auditid, 
    action, 
    objecttypecode, 
    transactionid, 
    _regardingobjectid_value, 
    useradditionalinfo, 
    [_callinguserid_value], 
    [cs_fetch_batch], 
    [cs_batch_number], 
    [logicalName], 
    [oldValue], 
    [newValue])



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





--DROP TABLE new_table_name


