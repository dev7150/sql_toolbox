
--Explicit Access (Login Mapped to Database User):
SELECT sp.name AS 'Login', dp.name AS 'User'
FROM sys.database_principals dp
  JOIN sys.server_principals sp
    ON dp.sid = sp.sid
ORDER BY sp.name, dp.name;



--Implicit Access (Member of Sysadmin Fixed Server Role):
SELECT sp.name
FROM sys.server_role_members srm
INNER JOIN sys.server_principals sp
     ON srm.member_principal_id = sp.principal_id
WHERE srm.role_principal_id = (
     SELECT principal_id
     FROM sys.server_principals 
    WHERE [Name] = 'sysadmin')

--Implicit Access (CONTROL SERVER permission - SQL Server 2005/2008):
SELECT sp.name 'Login' 
FROM sys.server_principals sp
   JOIN sys.server_permissions perms
     ON sp.principal_id = perms.grantee_principal_id
WHERE perms.type = 'CL'     
  AND perms.state = 'G';

--Implicit Access (Database Owner):
  SELECT db.name AS 'Database', sp.name AS 'Owner'
FROM sys.databases   LEFT JOIN sys.server_principals sp
    ON db.owner_sid = sp.sid
ORDER BY db.name;

--Implicit Access (Guest User Is Enabled):
SELECT dp.name, CASE perms.class WHEN 0 THEN 'Yes' ELSE 'No' END AS 'Enabled'
FROM sys.database_principals dp
  LEFT JOIN (SELECT grantee_principal_id, class FROM sys.database_permissions 
              WHERE class = 0 AND type = 'CO' AND state = 'G') AS perms
    ON dp.principal_id = perms.grantee_principal_id
WHERE dp.name = 'guest'; 