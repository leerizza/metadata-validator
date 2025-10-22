-- 001_create_tables.sql (idempotent)
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dim_customer_testting_git]') AND type = 'U')
BEGIN
  CREATE TABLE [dbo].[dim_customer_testting_git] (
    id INT NOT NULL PRIMARY KEY,
    full_name VARCHAR(200) NOT NULL,
    email VARCHAR(200) NULL
  );
END;
