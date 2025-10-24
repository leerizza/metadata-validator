IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stg_git_friday]') AND type = 'U')
BEGIN
  CREATE TABLE [dbo].[stg_git_friday] (
    id INT NOT NULL PRIMARY KEY,
    nama_lengkap VARCHAR(200) NOT NULL,
    email VARCHAR(200) NULL
  );
END;
