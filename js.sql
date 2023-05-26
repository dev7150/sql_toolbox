/****** Script for SelectTopNRows command from SSMS  ******/
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

Select * from [Test].[dbo].[Recent$] order by operation
where auditid = '21019F7C-DD1D-ED11-AE83-0003FF14886E'


Select distinct operation from [Test].[dbo].[Recent$]



with base as 
(Select * from [Test].[dbo].[Recent$] where [changedata] <> 'NULL')
Select * from OPENJSON(changedata,'$.changedAttributes') 


{"changedAttributes":[{"logicalName":"ms_lifestyleoptionset","oldValue":null,"newValue":"717660001"},
{"logicalName":"ms_eligiblevaccine","oldValue":null,"newValue":"717660003"},
{"logicalName":"ms_covidvac_allergy","oldValue":null,"newValue":"717660001"},
{"logicalName":"ms_covid_pos_treatment","oldValue":null,"newValue":"717660001"},
{"logicalName":"ms_vaccinedose","oldValue":null,"newValue":"717660000"},
{"logicalName":"ms_haschronicillness","oldValue":null,"newValue":"717660001"},
{"logicalName":"ms_hasspleenissue","oldValue":null,"newValue":"717660001"},
{"logicalName":"ms_planningtraveloptionset","oldValue":null,"newValue":"717660001"},
{"logicalName":"ownerid","oldValue":null,"newValue":"systemuser,cd54a763-3d6f-ec11-8f8e-002248159b7a"},
{"logicalName":"ms_othervac_allergy","oldValue":null,"newValue":"717660001"},
{"logicalName":"ms_atsioptionset","oldValue":null,"newValue":"717660001"},
{"logicalName":"ms_reservationcodeavailable","oldValue":null,"newValue":"717660001"},
{"logicalName":"ms_otherallergy","oldValue":null,"newValue":"717660001"},
{"logicalName":"ms_client","oldValue":null,"newValue":"contact,912d954a-dd1d-ed11-b83d-0022481438cf"},
{"logicalName":"statecode","oldValue":null,"newValue":"0"},
{"logicalName":"statuscode","oldValue":null,"newValue":"1"}]}