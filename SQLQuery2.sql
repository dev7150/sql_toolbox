SELECT HOSTNAME, PROGRAM_NAME, STATUS, SPID 


FROM    MASTER..SYSPROCESSES 

WHERE DBID= DB_ID('TestDB')

                AND SPID != @@SPID