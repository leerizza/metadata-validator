-- ALTER TABLE dbo.stg_test_table
-- ADD full_name VARCHAR(100) NOT NULL;



ALTER TABLE dbo.stg_test_table
ALTER COLUMN full_name TYPE VARCHAR(MAX);