IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stg_actioncode_git3]') AND type = 'U')
BEGIN
CREATE TABLE [dbo].[stg_actioncode_git3](
	actioncode varchar(50) NULL,
	name varchar(80) NULL
);
END;

