CREATE TABLE mytable (
  id INT NOT NULL,
  name VARCHAR(50) NOT NULL,
  category VARCHAR(50) NOT NULL,
  value INT NOT NULL,
  PRIMARY KEY (id, category)
)
PARTITION BY LIST (category) (
  PARTITION p1 VALUES IN ('Category1', 'Category2'),
  PARTITION p2 VALUES IN ('Category3', 'Category4'),
  PARTITION p3 VALUES IN (DEFAULT)
);


-- Create the partition function and partition scheme
CREATE PARTITION FUNCTION mytable_category_fn (varchar(50))
AS RANGE LEFT FOR VALUES ('Category1', 'Category2', 'Category3', 'Category4', DEFAULT);

CREATE PARTITION SCHEME mytable_category_ps
AS PARTITION mytable_category_fn
TO (
    [PRIMARY],
    [Partition1],
    [Partition2],
    [Partition3],
    [Partition4],
    [DEFAULT]
);

-- Add a new partition to the existing table
ALTER TABLE mytable
ADD CONSTRAINT PK_mytable_Partition4 PRIMARY KEY NONCLUSTERED (id, category)
ON mytable_category_ps(category)
    SCHEMABINDING;

ALTER TABLE mytable
SWITCH PARTITION 1 TO Partition1;
ALTER TABLE mytable
SWITCH PARTITION 2 TO Partition2;
ALTER TABLE mytable
SWITCH PARTITION 3 TO Partition3;
ALTER TABLE mytable
SWITCH PARTITION 4 TO Partition4;
ALTER TABLE mytable
SWITCH PARTITION 5 TO DEFAULT;

