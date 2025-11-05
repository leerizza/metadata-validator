/* === DDL changes (aman diulang) === */
IF OBJECT_ID(N'dbo.stg_test_table', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.stg_test_table', 'FullName') IS NOT NULL
        ALTER TABLE dbo.stg_test_table ALTER COLUMN FullName NVARCHAR(100) NULL; -- pakai NVARCHAR, bukan VARCHAR(MAX)

    IF COL_LENGTH('dbo.stg_test_table', 'ValueA') IS NULL
        ALTER TABLE dbo.stg_test_table ADD ValueA NVARCHAR(100) NULL;            -- tambah kolom hanya jika belum ada
END
GO

/* === VIEW (idempotent) === */
CREATE OR ALTER VIEW dbo.vw_test_table
AS
SELECT *
FROM dbo.stg_test_table WITH (NOLOCK);   -- kalau kamu mau enforce NOLOCK
GO

/* === Stored procedure 1 (idempotent & rename agar tidak bentrok) === */
CREATE OR ALTER PROCEDURE dbo.usp_test_table
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.stg_test_table WITH (NOLOCK);
END
GO

/* === Stored procedure 2: temp table === */
CREATE OR ALTER PROCEDURE dbo.usp_test_table2
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    INTO #TempTable
    FROM dbo.stg_test_table WITH (NOLOCK);
END
GO

/* === Stored procedure 3: CTE === */
CREATE OR ALTER PROCEDURE dbo.usp_test_table3
AS
BEGIN
    SET NOCOUNT ON;

    WITH cte AS
    (
        SELECT *
        FROM dbo.stg_test_table WITH (NOLOCK)
    )
    SELECT * FROM cte;
END
GO
