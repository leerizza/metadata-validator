-- --Create table with varchar(max) , need validasi

USE [DQ_DEV]
GO

/****** Object:  Table [dbo].[stg_test_table]    Script Date: 11/5/2025 10:10:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[stg_test_table_20251105]( 
	[ID] [int] NOT NULL,
	[FullName] [varchar](max) NULL,
	[CancelDate] [datetime] NULL,
	[UnderwritingReturnCumulative] [int] NULL,
	[TimestampUnderwriting] [datetime] NULL,
	[ApproveCancelDate] [datetime] NULL,
	[SLAProspectToAssign] [varchar](36) NULL,
	[SLAProspectToAssigninSecond] [numeric](17, 2) NULL,
	[SLA_InputToApprove] [varchar](36) NULL,
	[SLA_InputToApproveinSecond] [numeric](17, 2) NULL,
	[SLA_ApprovalDateToGoliveDate] [varchar](36) NULL,
	[SLAApprovetoGoliveinSecond] [numeric](17, 2) NULL,
	[BranchInputTimeZone] [varchar](5) NULL,
	[BranchSurveyTimeZone] [varchar](5) NULL,
	[BranchBookingTimeZone] [varchar](5) NULL,
	[RescoringSurveyor] [int] NULL,
	[RescoringOperation] [int] NULL
) ON [PRIMARY]
GO



  ALTER TABLE stg_test_table ALTER COLUMN FullName VARCHAR(100) NULL; -- using VARCHAR(max) , need validasi
  ALTER TABLE stg_test_table add ValueA VARCHAR(100) NULL; --using VARCHAR(max) , need validasi

  Create view test_table  as  --view without nolock , need validasi
  select * from stg_test_table 


  Create procedure test_table    --Procedure without nolock , need validasi
  as 
  begin 
  select * from stg_test_table 
  end 

  Create procedure test_table2    --Procedure with #TempTable , need validasi
  as 
  begin 
  select * 
  INTO #TempTable
  from stg_test_table 
  end 


  Create procedure test_table3    --Procedure with CTE , need validasi
  as 
  begin 

  with test_table as
  (
  select * 
  from stg_test_table 
  )

  select * from test_table
  end 