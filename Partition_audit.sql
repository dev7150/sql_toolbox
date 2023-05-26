/****** Script for Partitioning from SSMS  ******/

/* STEP 1 Add the entity and objectid in the expanded version of audit */
ALTER TABLE cslam_cvms.audit_expanded add objecttypecode varchar(60);
ALTER TABLE cslam_cvms.audit_expanded add objectid uniqueidentifier;


UPDATE ae
SET objecttypecode = coalesce(ar.objecttypecode, arr.objecttypecode)
FROM [cslam_cvms].[audit_expanded] ae
LEFT JOIN cslam_dev.auditid_translation att ON ae.audit_id = att.auditid
LEFT JOIN cslam_cvms.audits_raw ar ON att.aduitid_guid = ar.auditid
LEFT JOIN cslam_cvms.audits_raw_2 arr ON att.aduitid_guid = arr.auditid;

UPDATE ae
SET objectid = coalesce(ar.objectid, arr.objectid)
FROM [cslam_cvms].[audit_expanded] ae
LEFT JOIN cslam_dev.auditid_translation att ON ae.audit_id = att.auditid
LEFT JOIN cslam_cvms.audits_raw ar ON att.aduitid_guid = ar.auditid
LEFT JOIN cslam_cvms.audits_raw_2 arr ON att.aduitid_guid = arr.auditid;


/* STEP 2 Add a column to define a partition function */

ALTER TABLE cslam_cvms.audit_expanded add parkey int;
UPDATE ae
SET parkey = CASE 
    WHEN ae.objecttypecode = 'ms_clientresponse' THEN 1
    WHEN ae.objecttypecode = 'ms_vaccination' THEN 2 
    WHEN ae.objecttypecode = 'sytemuser' THEN 3
	WHEN ae.objecttypecode = 'contact' THEN 4
	WHEN ae.objecttypecode = 'bookableresourcebooking' THEN 5
	WHEN ae.objecttypecode = 'appointment' THEN 6
	WHEN ae.objecttypecode = 'ms_sms' THEN 7
	WHEN ae.objecttypecode = 'ms_vaccinationregistration' THEN 8
	WHEN ae.objecttypecode = 'ms_prescreeningquestion' THEN 9
	WHEN ae.objecttypecode = 'adx_webrole' THEN 10
	WHEN ae.objecttypecode = 'ms_postvaccinationquestionnaire' THEN 11
	WHEN ae.objecttypecode = 'ms_consent' THEN 12
	WHEN ae.objecttypecode = 'ms_vaccinevialactivity' THEN 13
	WHEN ae.objecttypecode = 'ms_vial' THEN 14
	WHEN ae.objecttypecode = 'ms_vaccineinventorylevel' THEN 15
    ELSE 16 
    END
FROM [cslam_cvms].[audit_expanded] ae

/* STEP 3 Partition based on parkey */

CREATE PARTITION FUNCTION myparPF (int)
AS RANGE RIGHT FOR VALUES (2,3,4,5,6,7,8,9,10,11,12,13,14,15)
GO
CREATE PARTITION SCHEME myPartitionScheme 
AS PARTITION myparPF ALL TO ([PRIMARY]) 

CREATE CLUSTERED INDEX IX_audit_expanded_parkey ON [cslam_cvms].[audit_expanded] (parkey)
  WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
        ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
  ON myPartitionScheme(parkey)
GO


/************** See the details of the partition ****************
SELECT * FROM sys.partitions
WHERE object_id = OBJECT_ID('[cslam_cvms].[audit_expanded]')

--see rows of a partition
SELECT * FROM [cslam_cvms].[audit_expanded]
WHERE $PARTITION.myparPF(parkey) = ?

--See partitionfunctionname, boundaryid, scheme and values
SELECT ps.name,pf.name,boundary_id,value
FROM sys.partition_schemes ps
INNER JOIN sys.partition_functions pf ON pf.function_id=ps.function_id
INNER JOIN sys.partition_range_values prf ON pf.function_id=prf.function_id
*/

