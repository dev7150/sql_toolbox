WITH base AS (
    SELECT top 100 * FROM [cslam_cvms].[audits_12hr] WHERE [changedata] <> 'NULL' and isjson(changedata)=1 and objecttypecode = 'ms_clientresponse'
	UNION ALL Select top 100 * from [cslam_cvms].[audits_1hr] WHERE [changedata] <> 'NULL' and isjson(changedata)=1 and objecttypecode = 'ms_clientresponse' )
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
    jd.[newValue],
    s.value AS attributemask
    --,jd.attributemask as amask
INTO cslam_dev.ms_clientresponse_json_exploded_sample
FROM (
    SELECT
        t.[_objectid_value],
        t.[_userid_value],
        t.[versionnumber],
        t.[operation],
        t.[createdon],
        t.[auditid],
        t.[attributemask],
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
        j.[newValue],
        ROW_NUMBER() OVER (PARTITION BY t.auditid ORDER BY (Select NULL)) AS attributemask_index
    FROM base t
    CROSS APPLY OPENJSON(t.[changedata], '$.changedAttributes')
    WITH (
        [logicalName] NVARCHAR(100) '$.logicalName',
        [oldValue] NVARCHAR(MAX) '$.oldValue',
        [newValue] NVARCHAR(MAX) '$.newValue'
    ) j
) jd
CROSS APPLY (
    SELECT value, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS attributemask_index
    FROM STRING_SPLIT(jd.attributemask, ',')
) s
WHERE s.attributemask_index = jd.attributemask_index