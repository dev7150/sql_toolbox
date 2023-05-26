CREATE PARTITION FUNCTION myDateRangePF (nvarchar(255))
AS RANGE RIGHT FOR VALUES ('appointment', 'zzzzzzzzz')
GO
CREATE PARTITION SCHEME myPartitionScheme 
AS PARTITION myDateRangePF ALL TO ([PRIMARY]) 


ALTER TABLE [dbo].[Early$] --DROP CONSTRAINT PK_TABLE1
GO
ALTER TABLE [dbo].[Early$] ADD CONSTRAINT PK_TABLE1 PRIMARY KEY NONCLUSTERED  (auditid)
   WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
         ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX IX_TABLE1_partitioncol ON [dbo].[Early$] (objecttypecode)
  WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
        ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
  ON myPartitionScheme(objecttypecode)
GO


ALTER TABLE [dbo].[Early$] ALTER COLUMN auditid varchar(255) NOT NULL

--see 
SELECT * FROM sys.partitions
WHERE object_id = OBJECT_ID('Early$')

--see rows of a partition
SELECT * FROM dbo.Early$ 
WHERE $PARTITION.myDateRangePF(objecttypecode) = 2

--See partitionfunctionname, boundaryid, scheme and values
SELECT ps.name,pf.name,boundary_id,value
FROM sys.partition_schemes ps
INNER JOIN sys.partition_functions pf ON pf.function_id=ps.function_id
INNER JOIN sys.partition_range_values prf ON pf.function_id=prf.function_id