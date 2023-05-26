/****** Script for SelectTopNRows command from SSMS  ******/


Select ae.new_value,count(*)
from [cslam_cvms].[audit_expanded] ae
join [cslam_dev].[auditid_translation] aut
on aut.auditid = ae.audit_id
join [cslam_cvms].[audits_raw_2] b 
on aut.aduitid_guid = b.auditid
where b.objecttypecode = 'ms_clientresponse'
and field_name = 'ms_vaccinationepisode'
group by ae.new_value


