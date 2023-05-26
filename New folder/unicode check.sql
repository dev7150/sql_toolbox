select 
   *
from [dbo].[xplode]
   
where 
  newvalue != cast(newvalue as varchar(4000))