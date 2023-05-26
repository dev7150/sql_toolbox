WITH base AS (
    SELECT top 100 * FROM  [cslam_cvms].[audits_31_only] WHERE isjson(changedata)=1 
	--and batch_number = ?
	)

INSERT INTO [cslam_dev].[Exploded_Audit]
    ([objectid], 
    [userid], 
   [versionnumber], 
    [operation], 
    [createdon], 
    auditid, 
	[logicalName], 
    [oldValue], 
    [newValue],
    [action], 
    objecttypecode, 
    transactionid, 
	batch_number   
    )



    SELECT 
        t.[objectid], 
        t.[userid], 
        t.[versionnumber], 
        t.[operation], 
        t.[createdon], 
        t.[auditid],
		j.[logicalName],
        j.[oldValue],
        j.[newValue],
        t.[action], 
        t.[objecttypecode], 
        t.[transactionid], 
        t.[batch_number]
        
    FROM base t
    CROSS APPLY OPENJSON(t.[changedata], '$.changedAttributes')
    WITH (
        [logicalName] NVARCHAR(100) '$.logicalName',
        [oldValue] NVARCHAR(MAX) '$.oldValue',
        [newValue] NVARCHAR(MAX) '$.newValue'
    ) j





--DROP TABLE new_table_name


