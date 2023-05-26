CREATE SCHEMA cslam_dev

CREATE TABLE [cslam_dev].[Exploded_Audit](
		[auditid] INT not NULL,
		[logicalName] VARCHAR(100),
        [oldValue] VARCHAR(4000),
        [newValue] VARCHAR(4000)
) 

CREATE CLUSTERED INDEX CI_Exploded_Audit
ON [cslam_dev].[Exploded_Audit] (auditid)

CREATE TABLE cslam_dev.exploded_audit_lookup(
	[auditid] INT  PRIMARY KEY CLUSTERED not NULL,
	[transactionid] uniqueidentifier not NULL,
	[createdon] [datetime2](7) NULL,
	[objectid] uniqueidentifier not NULL,
	[objecttypecode] varchar(60) NULL,
	[userid] uniqueidentifier not NULL,
	[operation] [int] not NULL,
	[action] [int] not NULL,
	--[attributemask] nvarchar(max) NULL,
	[versionnumber] [bigint] NULL,
	[batch_number] int not null
)




Go
WITH base AS (
    SELECT top 100  auditid,changedata FROM [dbo].[Early$] --[cslam_cvms].[audits_31_only] 
    WHERE isjson(changedata)=1 
	--and batch_number = ?
)

INSERT INTO [cslam_dev].[Exploded_Audit] (

    auditid, 
    [logicalName], 
    [oldValue], 
    [newValue]
    )
    SELECT 

        t.[auditid],
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