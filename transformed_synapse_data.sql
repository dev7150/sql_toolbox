UPDATE [cvms_admin].[row_test_cvms]
SET synapse_data_transformed = 
  CASE  
    WHEN synapse_data is null THEN synapse_data
	WHEN [key] IN ('createdon','msdynmkt_journeycount_date','ms_datesubmitted','ms_endtime','msdyn_endtime','msdyn_starttime','msdyncrm_lastevaluationtime',
	'ms_dateofservice','birthdate','ms_airlastretrievaldate','ms_dateofservice','birthdate','msdyncrm_lastpublisheddate','msdyn_fromdate','ms_breachendtime',
	'ms_airdateofbirth','ms_starttime','changedon','msdyn_lastaccesstime','msdyn_eventtime','overriddencreatedon', 'publishedon','endtime','ms_breachstarttime',
	'starttime', 'modifiedon', 'ms_sessionstartdateonly', 'enteredon', 'ms_agelastupdatedon', 'ms_reconciliationdate','ms_nextbirthday','msdyn_lastreportrefreshtime'
	,'adx_date','ms_administeredon','ms_checkintime','ms_airvaccinationdate') 
	THEN concat(LEFT(synapse_data, 10),'T', SUBSTRING(synapse_data, CHARINDEX(' ', synapse_data) + 1, 8))
    WHEN [value] = 'True' AND synapse_data = '1' THEN 'True'
    WHEN [value] = 'False' AND synapse_data = '0' THEN 'False'
    ELSE synapse_data
  END;
  
  
