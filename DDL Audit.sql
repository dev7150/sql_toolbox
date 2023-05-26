

CREATE TABLE [cslam_dev].[Exploded_Audit](
	[objectid] [nvarchar](255) NULL,
	[userid] [nvarchar](255) NULL,
	[versionnumber] [float] NULL,
	[operation] [float] NULL,
	[createdon] [datetime] NULL,
	[auditid] [nvarchar](255) NULL,
	--[changedata] [nvarchar](max) NULL,
	--[attributemask] [nvarchar](max) NULL,
	[logicalName] NVARCHAR(100),
    [oldValue] NVARCHAR(MAX),
    [newValue] NVARCHAR(MAX), 
	[action] [float] NULL,
	[objecttypecode] [nvarchar](255) NULL,
	[transactionid] [nvarchar](255) NULL,
	[batch_number] [int] NULL
) 
