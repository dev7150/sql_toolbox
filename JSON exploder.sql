WITH base AS (
    SELECT * FROM [Test].[dbo].[Recent$] --WHERE [changedata] is not null
), json_data AS (
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
)
SELECT 
    jd.[_objectid_value],jd.[_userid_value],jd.[versionnumber],jd.[operation],jd.[createdon],jd.auditid,jd.action,jd.objecttypecode,jd.transactionid,jd._regardingobjectid_value,jd.useradditionalinfo,
	jd.[_callinguserid_value],jd.[cs_fetch_batch], jd.[cs_batch_number],
	  jd.[logicalName],
        jd.[oldValue],
        jd.[newValue],
    s.value AS attributemask
	,jd.attributemask
	--,jd.attributemask_index
FROM json_data jd

CROSS APPLY (
    SELECT value, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS attributemask_index
    FROM STRING_SPLIT(jd.attributemask, ',')
) s
WHERE s.attributemask_index = jd.attributemask_index

and jd.auditid in ('18217644-D91D-ED11-AE83-0003FF14886E')
ORDER BY jd.auditid, jd.attributemask_index;

Select * from 
 [Test].[dbo].[Recent$]
 where auditid = '18217644-D91D-ED11-AE83-0003FF14886E'

 --{"changedAttributes":[{"logicalName":"ms_responseenabled","oldValue":null,"newValue":"False"},
 --{"logicalName":"ms_question","oldValue":null,"newValue":"* Pfizer or Moderna are the preferred v
 --accine for people in these groups but if not available, AstraZeneca can be considered if the ben
 --efits of vaccination outweigh the risks. "},
 --{"logicalName":"ms_vaccinationepisode","oldValue":null,"newValue":"ms_vaccination,8e0cdf3d-
 --d91d-ed11-b83d-00224817f6df"},{"logicalName":"statecode","oldValue":null,"newValue":"0"},
 --{"logicalName":"ms_bolded","oldValue":null,"newValue":"False"},
 --{"logicalName":"statuscode","oldValue":null,"newValue":"1"},
 --{"logicalName":"ms_underlined","oldValue":null,"newValue":"False"},
 --{"logicalName":"ms_responserequired","oldValue":null,"newValue":"False"},
 --{"logicalName":"ownerid","oldValue":null,"newValue":"systemuser,6d0e4fac-006d-eb
 --11-a812-000d3acb9b26"},{"logicalName":"ms_name","oldValue":null,"newValue":
 --"2022-17-08-134479111"},{"logicalName":"ms_order","oldValue":null,"newValue
 --":"210"},{"logicalName":"ms_italicized","oldValue":null,"newValue":"True"},
 --{"logicalName":"ms_isupdated","oldValue":null,"newValue":"False"}]}


