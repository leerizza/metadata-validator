ALTER TABLE dbo.stg_test_table 
ALTER COLUMN full_name VARCHAR(200);

EXEC sp_rename 'dbo.stg_test_table.full_name', 'FullName', 'COLUMN';