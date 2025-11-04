--DB_NDM
ALTER TABLE DatamartDashboardSurveyBravo ADD CancelDate DATETIME NUll;
ALTER TABLE DatamartDashboardSurveyBravo ADD UnderwritingReturnCumulative INT NULL;
ALTER TABLE DatamartDashboardSurveyBravo ADD TimestampUnderwriting DATETIME NULL;
ALTER TABLE DatamartDashboardSurveyBravo ADD ApproveCancelDate DATETIME NULL;
ALTER TABLE DatamartDashboardSurveyBravo ADD SLAProspectToAssign  varchar(36) NULL;
ALTER TABLE DatamartDashboardSurveyBravo ADD SLAProspectToAssigninSecond  numeric(17,2) NULL;
ALTER TABLE DatamartDashboardSurveyBravo ADD SLA_InputToApprove  varchar(36) NULL;
ALTER TABLE DatamartDashboardSurveyBravo ADD SLA_InputToApproveinSecond  numeric(17,2) NULL;
ALTER TABLE DatamartDashboardSurveyBravo ADD SLA_ApprovalDateToGoliveDate varchar(36) NULL;
ALTER TABLE DatamartDashboardSurveyBravo ADD SLAApprovetoGoliveinSecond  numeric(17,2) NULL;
ALTER TABLE DatamartDashboardSurveyBravo ADD BranchInputTimeZone varchar(5) NULL;
ALTER TABLE DatamartDashboardSurveyBravo ADD BranchSurveyTimeZone varchar(5) NULL;
ALTER TABLE DatamartDashboardSurveyBravo ADD BranchBookingTimeZone varchar(5) NULL;
ALTER TABLE DatamartDashboardSurveyBravo ADD RescoringSurveyor INT NULL;
ALTER TABLE DatamartDashboardSurveyBravo ADD RescoringOperation INT NULL;

ALTER TABLE DatamartDashboardSurveyBravoHistory ADD CancelDate DATETIME NUll;
ALTER TABLE DatamartDashboardSurveyBravoHistory ADD UnderwritingReturnCumulative INT NULL;
ALTER TABLE DatamartDashboardSurveyBravoHistory ADD TimestampUnderwriting DATETIME NULL;
ALTER TABLE DatamartDashboardSurveyBravoHistory ADD ApproveCancelDate DATETIME NULL;
ALTER TABLE DatamartDashboardSurveyBravoHistory ADD SLAProspectToAssign  varchar(36) NULL;
ALTER TABLE DatamartDashboardSurveyBravoHistory ADD SLAProspectToAssigninSecond  numeric(17,2) NULL;
ALTER TABLE DatamartDashboardSurveyBravoHistory ADD SLA_InputToApprove varchar(36) NULL;
ALTER TABLE DatamartDashboardSurveyBravoHistory ADD SLA_InputToApproveinSecond numeric(17,2) NULL;
ALTER TABLE DatamartDashboardSurveyBravoHistory ADD SLA_ApprovalDateToGoliveDate  varchar(36) NULL;
ALTER TABLE DatamartDashboardSurveyBravoHistory ADD SLAApprovetoGoliveinSecond  numeric(17,2) NULL;
ALTER TABLE DatamartDashboardSurveyBravoHistory ADD BranchInputTimeZone varchar(5) NULL;
ALTER TABLE DatamartDashboardSurveyBravoHistory ADD BranchSurveyTimeZone varchar(5) NULL;
ALTER TABLE DatamartDashboardSurveyBravoHistory ADD BranchBookingTimeZone varchar(5) NULL;
ALTER TABLE DatamartDashboardSurveyBravoHistory ADD RescoringSurveyor INT NULL;
ALTER TABLE DatamartDashboardSurveyBravoHistory ADD RescoringOperation INT NULL;


ALTER TABLE DatamartDashboardSurveyBravo2Monthly ADD CancelDate DATETIME NUll;
ALTER TABLE DatamartDashboardSurveyBravo2Monthly ADD UnderwritingReturnCumulative INT NULL;
ALTER TABLE DatamartDashboardSurveyBravo2Monthly ADD TimestampUnderwriting DATETIME NULL;
ALTER TABLE DatamartDashboardSurveyBravo2Monthly ADD ApproveCancelDate DATETIME NULL;
ALTER TABLE DatamartDashboardSurveyBravo2Monthly ADD SLAProspectToAssign  varchar(36) NULL;
ALTER TABLE DatamartDashboardSurveyBravo2Monthly ADD SLAProspectToAssigninSecond  numeric(17,2) NULL;
ALTER TABLE DatamartDashboardSurveyBravo2Monthly ADD SLA_InputToApprove  varchar(36) NULL;
ALTER TABLE DatamartDashboardSurveyBravo2Monthly ADD SLA_InputToApproveinSecond  numeric(17,2) NULL;
ALTER TABLE DatamartDashboardSurveyBravo2Monthly ADD SLA_ApprovalDateToGoliveDate  varchar(36) NULL;
ALTER TABLE DatamartDashboardSurveyBravo2Monthly ADD SLAApprovetoGoliveinSecond  numeric(17,2) NULL;
ALTER TABLE DatamartDashboardSurveyBravo2Monthly ADD BranchInputTimeZone varchar(5) NULL;
ALTER TABLE DatamartDashboardSurveyBravo2Monthly ADD BranchSurveyTimeZone varchar(5) NULL;
ALTER TABLE DatamartDashboardSurveyBravo2Monthly ADD BranchBookingTimeZone varchar(5) NULL;
ALTER TABLE DatamartDashboardSurveyBravo2Monthly ADD RescoringSurveyor INT NULL;
ALTER TABLE DatamartDashboardSurveyBravo2Monthly ADD RescoringOperation INT NULL;


ALTER TABLE DatamartDashboardSurveyBravo ALTER COLUMN golivedate datetime NULL;
ALTER TABLE DatamartDashboardSurveyBravo ALTER COLUMN NewAppDate datetime NULL;

ALTER TABLE DatamartDashboardSurveyBravoHistory ALTER COLUMN golivedate datetime NULL;
ALTER TABLE DatamartDashboardSurveyBravoHistory ALTER COLUMN NewAppDate datetime NULL;

ALTER TABLE DatamartDashboardSurveyBravo2Monthly ALTER COLUMN golivedate datetime NULL;
ALTER TABLE DatamartDashboardSurveyBravo2Monthly ALTER COLUMN NewAppDate datetime NULL;