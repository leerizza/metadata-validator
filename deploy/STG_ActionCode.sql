IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[STG_ActionCode]') AND type = 'U')
BEGIN
CREATE TABLE [dbo].[STG_ActionCode](
	[ActionID] [int] NULL,
	[ActionCode] [varchar](50) NULL,
	[Name] [varchar](80) NULL,
	[ActionGroupID] [int] NULL,
	[IsEnabled] [bit] NULL,
	[IsSystemAction] [bit] NULL,
	[ActionState] [varchar](50) NULL,
	[StatusWeight] [int] NULL,
	[Priority] [int] NULL
) ON [PRIMARY]
GO


