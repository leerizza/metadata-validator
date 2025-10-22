IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stg_actioncode]') AND type = 'U')
BEGIN
CREATE TABLE [dbo].[stg_actioncode](
	[ActionCode] [varchar](50) NULL,
	[Name] [varchar](80) NULL,

END;



