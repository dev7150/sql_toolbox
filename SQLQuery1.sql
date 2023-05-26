WITH last_query_by_db (dbid, Last_query) 

AS (select dbid, max(last_execution_time) 'Last_query'

from sys.dm_exec_query_stats 
cross apply 
sys.dm_exec_sql_text(plan_handle)
group by
dbid
)

select d.name, Last_query

from 
sys.databases d
left outer join
last_query_by_db q on q.dbid = d.database_id

where d.name not in ('master','msdb','model','tempdb')