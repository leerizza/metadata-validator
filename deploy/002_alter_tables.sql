-- 002_alter_tables.sql (idempotent)
IF COL_LENGTH('dbo.dim_customer', 'phone') IS NULL
  ALTER TABLE dbo.dim_customer ADD phone VARCHAR(50) NULL;
