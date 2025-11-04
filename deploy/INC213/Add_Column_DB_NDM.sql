--DB_NDM
ALTER TABLE stg_test_table ADD CancelDate DATETIME NUll;
ALTER TABLE stg_test_table ADD UnderwritingReturnCumulative INT NULL;
ALTER TABLE stg_test_table ADD TimestampUnderwriting DATETIME NULL;
ALTER TABLE stg_test_table ADD ApproveCancelDate DATETIME NULL;
ALTER TABLE stg_test_table ADD SLAProspectToAssign  varchar(36) NULL;
ALTER TABLE stg_test_table ADD SLAProspectToAssigninSecond  numeric(17,2) NULL;
ALTER TABLE stg_test_table ADD SLA_InputToApprove  varchar(36) NULL;
ALTER TABLE stg_test_table ADD SLA_InputToApproveinSecond  numeric(17,2) NULL;
ALTER TABLE stg_test_table ADD SLA_ApprovalDateToGoliveDate varchar(36) NULL;
ALTER TABLE stg_test_table ADD SLAApprovetoGoliveinSecond  numeric(17,2) NULL;
ALTER TABLE stg_test_table ADD BranchInputTimeZone varchar(5) NULL;
ALTER TABLE stg_test_table ADD BranchSurveyTimeZone varchar(5) NULL;
ALTER TABLE stg_test_table ADD BranchBookingTimeZone varchar(5) NULL;
ALTER TABLE stg_test_table ADD RescoringSurveyor INT NULL;
ALTER TABLE stg_test_table ADD RescoringOperation INT NULL;
