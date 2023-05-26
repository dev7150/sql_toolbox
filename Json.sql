/****** Script for SelectTopNRows command from SSMS  ******/
with base as 
(Select * from [Test].[dbo].[Recent$] where [changedata] <> 'NULL')

SELECT
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


with base as 
(Select * from [Test].[dbo].[Recent$] where [changedata] <> 'NULL' 
and objecttypecode = 'ms_clientresponse' and action = 2 
)

SELECT t.*,
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





with base as 
(Select * from [Test].[dbo].[Recent$] where [changedata] <> 'NULL')

SELECT
    j.[logicalName],
    j.[oldValue],
    j.[newValue],
    c.[value] AS [commaSeparatedValue]
FROM base t
CROSS APPLY OPENJSON(t.[changedata], '$.changedAttributes')
WITH (
    [logicalName] NVARCHAR(100) '$.logicalName',
    [oldValue] NVARCHAR(MAX) '$.oldValue',
    [newValue] NVARCHAR(MAX) '$.newValue'
) j
CROSS APPLY (
    SELECT value
    FROM STRING_SPLIT(t.[commaSeparatedColumn], ',')
    WHERE j.[logicalName] = JSON_VALUE(t.[changedata], CONCAT('$.changedAttributes[', c.rn - 1, '].logicalName'))

) c
WHERE j.[logicalName] = JSON_VALUE(t.[changedata], CONCAT('$.changedAttributes[', c.rn - 1, '].logicalName'))
