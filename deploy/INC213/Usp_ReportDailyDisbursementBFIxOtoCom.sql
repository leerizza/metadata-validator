CREATE procedure [dbo].[Usp_ReportDailyDisbursementBFIxOtoCom]                 
 @RunStartDt Varchar(10),                 
 @RunEndDt Varchar(10)                
as                
                
                
declare @RunStart date = cast(@RunStartDt as date);                
declare @RunEnd date = cast(@RunEndDt as date);                
declare @TanggalHariIni DATETIME;                
select  @TanggalHariIni =   max(BI_RUN_DATE) from DWBIBFI2_DWH..BI_RUN_TIME with (nolock)                   
declare @agingDate date = dateadd(day,-1,getdate())                    
--select @agingDate                
                
DROP TABLE IF EXISTS DB_Temp..Temp_InsuranceAssetHeader;                
DROP TABLE IF EXISTS MainDailyDisbursement;                
DROP TABLE IF EXISTS MainDailyDisbursement2;                
DROP TABLE IF EXISTS MainDailyDisbursement3;                
DROP TABLE IF EXISTS MainDailyDisbursement4;                
DROP TABLE IF EXISTS MainDailyDisbursement5;                
DROP TABLE IF EXISTS MainDailyDisbursement6;                
DROP TABLE IF EXISTS db_temp..Temp_MainDailyDisbursement                
                
                
select                 
 ApplicationID, CapitalizedAmount, TotalPremiumToCust, StampDutyFeeToCust, AdminFeeToCust, InsSequenceNo                
 into DB_Temp..Temp_InsuranceAssetHeader                
From                
 (                
 select ApplicationID, CapitalizedAmount, TotalPremiumToCust, StampDutyFeeToCust, AdminFeeToCust, InsSequenceNo,                
 ROW_NUMBER() OVER (PARTITION BY ApplicationID ORDER BY InsSequenceNo desc)RowNum                
 from dbo.STG_InsuranceAssetHeader with (nolock)                
 ) x                
where RowNum = '1';                
                
                
select                 
 FORMAT( ag.GoLiveDate, 'MMM-yy') GoliveMonth                
 , ag.GoLiveDate                
 , cus.Name CustomerName                
 , po.PONo                
 , ag.AgreementNo                 
 , case when pof.ProductID is not null then 'UCFS'                  
   when pdf.Product_Asset_Condition is not null then 'UCF'                
  else null                
  end Business                
 , TotalOTR OTR                
 , DownPayment DownPaymentNett                
 , isnull(case when iah.CapitalizedAmount <> 0 or ag.InsAssetCapitalized <> 0 then iah.TotalPremiumToCust else 0 end ,0)  CarInsuranceAmount_ONLOAN                
 , isnull(case when iah.CapitalizedAmount = 0 or ag.InsAssetCapitalized = 0 then iah.TotalPremiumToCust else 0 end,0) CarInsuranceAmount_ONCASH                
 , isnull(case when iah.CapitalizedAmount <> 0 or ag.InsAssetCapitalized <> 0 then fee.PolAdminFee else 0 end,0)  PolisAdminFee_ONLOAN                 
 , isnull(case when iah.CapitalizedAmount = 0 or ag.InsAssetCapitalized = 0 then fee.PolAdminFee else 0 end,0)  PolisAdminFee_ONCASH                
 , isnull(case when iah.CapitalizedAmount <> 0 or ag.InsAssetCapitalized <> 0 then ag.LifeInsurancePremium else 0 end,0)  LifeInsuranceAmount_ONLOAN                
 , isnull(case when iah.CapitalizedAmount = 0 or ag.InsAssetCapitalized = 0 then ag.LifeInsurancePremium else 0 end,0) LifeInsuranceAmount_ONCASH                
 , isnull(case when iah.CapitalizedAmount <> 0 or ag.InsAssetCapitalized <> 0 then ag.AdminFee else 0 end,0) AdminFee_ONLOAN                
 , isnull(case when iah.CapitalizedAmount = 0 or ag.InsAssetCapitalized = 0 then ag.AdminFee else 0 end,0)  AdminFee_ONCASH                
 , isnull(case when sp.SupplierID = 'S240614094' then 0 when iah.CapitalizedAmount <> 0 or ag.InsAssetCapitalized <> 0 then 1000000  else 0 end,0) WarrantiPremi_ONLOAN                
 , isnull(case when sp.SupplierID = 'S240614094' then 0 when iah.CapitalizedAmount = 0 or ag.InsAssetCapitalized = 0 then 1000000  else 0 end,0) WarrantiPremi_ONCASH                
 , isnull(case when iah.CapitalizedAmount <> 0 or ag.InsAssetCapitalized <> 0 then ag.ProvisionFee else 0 end,0)  ProvisionFee_ONLOAN                
 , isnull(case when iah.CapitalizedAmount = 0 or ag.InsAssetCapitalized = 0 then ag.ProvisionFee else 0 end,0)  ProvisionFee_ONCASH                
 , isnull(case when iah.CapitalizedAmount <> 0 or ag.InsAssetCapitalized <> 0 then ag.FiduciaFee else 0 end,0)  FiduciaFee_ONLOAN                
 , isnull(case when iah.CapitalizedAmount = 0 or ag.InsAssetCapitalized = 0 then ag.FiduciaFee else 0 end,0)  FiduciaFee_ONCASH                
 , isnull(case when iah.CapitalizedAmount <> 0 or ag.InsAssetCapitalized <> 0 then ag.AddAdminFee else 0 end,0) AdditionalAdminFee_ONLOAN                
 , isnull(case when iah.CapitalizedAmount = 0 or ag.InsAssetCapitalized = 0 then ag.AddAdminFee else 0 end,0) AdditionalAdminFee_ONCASH                
 , isnull(case when iah.CapitalizedAmount <> 0 or ag.InsAssetCapitalized <> 0 then ag.SurveyFee else 0 end,0) SurveyFees_ONLOAN                
 , isnull(case when iah.CapitalizedAmount = 0 or ag.InsAssetCapitalized = 0 then ag.SurveyFee else 0 end,0) SurveyFees_ONCASH                
 , isnull(case when iah.CapitalizedAmount <> 0 or ag.InsAssetCapitalized <> 0 then ag.OtherFee else 0 end,0) SantunanDuka_ONLOAN                
 , isnull(case when iah.CapitalizedAmount = 0 or ag.InsAssetCapitalized = 0 then ag.OtherFee else 0 end,0) SantunanDuka_ONCASH                
 , isnull(case when iah.CapitalizedAmount <> 0 or ag.InsAssetCapitalized <> 0 then ag.NotaryFee else 0 end,0) AnyOtherFees_ONLOAN                
 , isnull(case when iah.CapitalizedAmount = 0 or ag.InsAssetCapitalized = 0 then ag.NotaryFee else 0 end,0) AnyOtherFees_ONCASH                
 , TotalOTR-DownPayment LoanAmount                
 , case when sp.SupplierID = 'S240614094' then ag.FlatRate else  ag.SupplierFlatRate end [FlatInterestRate(%)]                
 , ag.EffectiveRate [EffectiveInterestRate(%)] --ag.SupplierRate [EffectiveInterestRate(%)]                 
 , ag.Tenor                
 , case when ag.FirstInstallment ='AR' then 'ADDB'                
  when ag.FirstInstallment ='AD' then 'ADDM'                
  else null                
  end [InstallmentType(Addm/Addb)]                
 , ag.InstallmentAmount Installment                
 --, ag.TDP TotalDownPayment /* DMD 977 Change Logic Req by user */                
 , apt.POTotal ApAmount                
 , aan.ApAmountnet ApAmountNett                
 , ap.APstatusdate DisbursalDate                
 , FORMAT( ap.APstatusdate, 'MMM-yy') DisbMonth                
 , firtins.DueDate FirstInstallmentDate                
 , 13.5 HurdleRate                
 , sp.SupplierID                 
 , ag.EffectiveRate / 100 AS EffectiveInterestRatePMT                
 , 13.5 / 100 AS HurdleRatePMT                
 , ag.ApplicationID --dmd 977                
 , ag.BranchID --dmd 977                
 --dmd 1013 Stefanus            
 ,ag.RRDDate ActualLoanClosureDate           
 --end         
INTO MainDailyDisbursement                 
from DWBIBFI2_STG.dbo.STG_Agreement ag with (nolock)                
left join dbo.STG_Customer  cus with (nolock) on ag.CustomerID = cus.CustomerID                
left join dbo.STG_PurchaseOrder po with (nolock) on ag.ApplicationID = po.ApplicationID                
 and IsMainPO =1                
left join STG_ProductOffering pof with (nolock)on ag.ProductID = pof.ProductID                
 and ag.BranchID = pof.BranchID                
 and ag.ProductOfferingID = pof.ProductOfferingID                
 and pof.Description like '%My car%'                
left join                 
 (                
 select fc.ID_Application,Product_Asset_Condition                 
 from DWBIBFI2_DWH..Fact_Contract fc with (nolock)                
 left join DWBIBFI2_DWH..VW_Dim_Product_Asset_Condition pac with (nolock)                
  on fc.SK_Product_Asset_Condition = pac.SK_Product_Asset_Condition                
 where pac.SK_Product_Asset_Condition =5                
 ) pdf                
 on ag.ApplicationID = pdf.ID_Application                
left join dbo.STG_Supplier sp with (nolock) on ag.SupplierID = sp.SupplierID                
/* DMD 963 difixing agar data tdk double untuk product Shariah */                
Left Join DB_Temp..Temp_InsuranceAssetHeader iah with (nolock) on ag.ApplicationID = iah.ApplicationID                
--left join STG_InsuranceAssetHeader iah with (nolock) on ag.ApplicationID = iah.ApplicationID                 
left join                 
 (                
 select poall.ApplicationID, isnull(sum(POTotal)-nfd.POnfd,sum(POTotal)) ApAmountnet                  
 from STG_PurchaseOrder poall with (nolock)                
 left join                 
  (                
   select ApplicationID,sum(POTotal) POnfd                 
   from STG_PurchaseOrder with (nolock)                 
  where SplitPOID <> 'FD' group by ApplicationID                
  )nfd                
  on poall.ApplicationID = nfd.ApplicationID                
 group by poall.ApplicationID,nfd.POnfd                 
 )aan                
 on ag.ApplicationID = aan.ApplicationID                
left join                 
 (                
 SELECT aa.ApplicationID, aa.APStatusDate                 
 FROM                
  (                
  SELECT                 
   b.ApplicationID,                 
   b.APStatusDate,                 
   a.SplitPOID,                
   ROW_NUMBER() OVER                 
    (PARTITION BY a.ApplicationID ORDER BY                 
    CASE WHEN a.SplitPOID = 'FD' THEN 1 WHEN a.SplitPOID IS NULL THEN 2 ELSE 3 END                
    ) AS rn                
  FROM stg_purchaseorder  a WITH (NOLOCK)                
  left JOIN  stg_accountpayable b WITH (NOLOCK)                
   ON a.ApplicationID = b.ApplicationID                 
   AND a.BranchID = b.BranchID                 
   AND a.AccountPayableNo = b.AccountPayableNo                
   and b.Status = 'P' --DMD 977 req user untuk mengambil yg status = paid                
  )aa                
 WHERE aa.rn = 1                
 )ap                
 on ap.ApplicationID = po.ApplicationID                
left join                 
 (                
 select isc.ApplicationID,isc.DueDate                 
 from DWBIBFI2_ODS.dbo.ODS_InstallmentSchedule  isc with (nolock)                
 inner join                 
  (select ApplicationID,min(InsSeqNo)InsSeqNo                 
  from DWBIBFI2_ODS.dbo.ODS_InstallmentSchedule  with (nolock)                 
  group  by ApplicationID                
  )iscm                
  on isc.ApplicationID =  iscm.ApplicationID                
  and isc.InsSeqNo = iscm.InsSeqNo                
 )firtins                
 on ag.ApplicationID = firtins.ApplicationID                
left join                 
 (                
 select ApplicationID, StampDutyFeeToCust+AdminFeeToCust PolAdminFee                
 from DB_Temp..Temp_InsuranceAssetHeader with (nolock)                
 )fee                
 on ag.ApplicationID = fee.ApplicationID                
left join                 
 (                
 select ApplicationID, sum(POTotal) POTotal                 
 from STG_PurchaseOrder with (nolock)                
 group by ApplicationID                
 )apt                
 on ag.ApplicationID = apt.ApplicationID                
where cast(ag.GoLiveDate as date) between @RunStart and @RunEnd                
and ApplicationStep = 'GLV'                
and (sp.SupplierName like '%NIM OTO COM%' or sp.SupplierID = 'S240614094');                
                
                
                
select                  
 md.GoliveMonth                
 , md.GoLiveDate                
 , md.CustomerName                
 , md.PONo                
 , md.AgreementNo                 
 , md.Business                
 , md.OTR                
 , md.DownPaymentNett                
 , md.CarInsuranceAmount_ONLOAN                
 , md.CarInsuranceAmount_ONCASH                
 , md.PolisAdminFee_ONLOAN                
 , md.PolisAdminFee_ONCASH                
 , md.LifeInsuranceAmount_ONLOAN                
 , md.LifeInsuranceAmount_ONCASH                
 , case when md.SupplierID = 'S240614094' then md.AdminFee_ONLOAN else md.AdminFee_ONLOAN - md.WarrantiPremi_ONLOAN end  AdminFee_ONLOAN                
 , case when md.SupplierID = 'S240614094' then md.AdminFee_ONCASH else md.AdminFee_ONCASH - md.WarrantiPremi_ONCASH end  AdminFee_ONCASH                
 , md.WarrantiPremi_ONLOAN                
 , md.WarrantiPremi_ONCASH                
 , md.ProvisionFee_ONLOAN                
, md.ProvisionFee_ONCASH                
 , md.FiduciaFee_ONLOAN                
 , md.FiduciaFee_ONCASH                
 , md.AdditionalAdminFee_ONLOAN                
 , md.AdditionalAdminFee_ONCASH                
 , md.SurveyFees_ONLOAN                
 , md.SurveyFees_ONCASH                
 , md.SantunanDuka_ONLOAN                
 , md.SantunanDuka_ONCASH                
 , md.AnyOtherFees_ONLOAN                
 , md.AnyOtherFees_ONCASH                
 , md.LoanAmount                
 , md.[FlatInterestRate(%)]                
 , md.[EffectiveInterestRate(%)]                
 , md.Tenor                
 , md.[InstallmentType(Addm/Addb)]                
 , md.Installment                
 , md.ApAmount                
 , case when md.SupplierID = 'S240614094' then md.ApAmount else ApAmountNett end ApAmountNett                
 , md.DisbursalDate                
 , md.DisbMonth                
 , md.FirstInstallmentDate                
 --dmd 1013 stefanus          
 --, md.HurdleRate                
,case when  cast(md.GoLiveDate as date) >= '2025-01-01' then (case when [EffectiveInterestRate(%)]>18.0 then 13.5+ 0.75*([EffectiveInterestRate(%)]-18.0)  else 13.5 end ) else md.HurdleRate end as HurdleRate          
 --END dmd 1013        
 --          
 , md.SupplierID                
 , md.EffectiveInterestRatePMT                
 , md.HurdleRatePMT                
 ,CASE a.ProductType                
  WHEN 'DEMotor' THEN ISNULL(a.DPmValue, 0)                  
  ELSE ISNULL(s.DPAmount,ISNULL(b.DPAmount, 0))                 
 END DownPayment                 
 ,(CASE a.FirstInstallment                
  WHEN 'AD' THEN a.InstallmentAmount                
  ELSE 0                
 END ) AS InstallmentAmount                
 ,a.AdminFee                
    ,CASE a.ProductType                
        WHEN 'DEMotor' THEN ins.PaidAmountByCustomer                
        ELSE a.InsAssetReceivedinAdv                
    END InsAssetReceivedinAdv                
 ,ISNULL(a.lifeinsurancepremium, '0') as lifeinsurancepremium                
 ,(a.FiduciaFee + a.ProvisionFee + a.NotaryFee + a.SurveyFee + a.OtherFee)  as OtherFee                
 ,a.TDP                
 --dmd 1013     stefanus          
  ,md.ActualLoanClosureDate          
  --end dmd 1013        
INTO MainDailyDisbursement2                
from MainDailyDisbursement md with (nolock)                
/* DMD 977 add logic changes for TDP */                
LEFT JOIN DWBIBFI2_STG..STG_Agreement a WITH (NOLOCK) on a.BranchID = md.BranchID and a.ApplicationID = md.ApplicationID                
INNER JOIN DWBIBFI2_STG..STG_AgreementAsset b WITH (NOLOCK) ON a.BranchID = b.BranchID AND a.ApplicationID = b.ApplicationID                
LEFT Join DWBIBFI2_STG..STG_AgreementAssetSupplier s With (nolock) On b.BranchID = s.BranchID And b.ApplicationID = s.ApplicationID And b.AssetSeqNo = s.AssetSeqNo                
LEFT JOIN                 
 (                
 select sum(i.PaidAmountByCustomer) as PaidAmountByCustomer,                 
  i.ApplicationID,                 
  i.BranchID                
 from DWBIBFI2_STG..STG_InsuranceAssetHeader i with (nolock)                 
 group by i.ApplicationID, i.BranchID                
 ) ins on ins.BranchId = a.BranchID and ins.ApplicationID = a.ApplicationID;                
                
                
                
select                 
 GoliveMonth                
 , GoLiveDate                
 , CustomerName                
 , PONo                
 , AgreementNo                 
 , Business                
 , OTR                
 , DownPaymentNett                
 , CarInsuranceAmount_ONLOAN                
 , CarInsuranceAmount_ONCASH                
 , PolisAdminFee_ONLOAN                
 , PolisAdminFee_ONCASH                
 , LifeInsuranceAmount_ONLOAN                
 , LifeInsuranceAmount_ONCASH                
 , AdminFee_ONLOAN                
 , AdminFee_ONCASH                
 , WarrantiPremi_ONLOAN                
 , WarrantiPremi_ONCASH                
 , ProvisionFee_ONLOAN                
 , ProvisionFee_ONCASH                
 , FiduciaFee_ONLOAN                
 , FiduciaFee_ONCASH                
 , AdditionalAdminFee_ONLOAN                
 , AdditionalAdminFee_ONCASH                
 , SurveyFees_ONLOAN                
 , SurveyFees_ONCASH                
 , SantunanDuka_ONLOAN                
 , SantunanDuka_ONCASH                
 , AnyOtherFees_ONLOAN                
 , AnyOtherFees_ONCASH                
 , (CarInsuranceAmount_ONLOAN+PolisAdminFee_ONLOAN+LifeInsuranceAmount_ONLOAN+AdminFee_ONLOAN+WarrantiPremi_ONLOAN                
   + ProvisionFee_ONLOAN+FiduciaFee_ONLOAN+AdditionalAdminFee_ONLOAN+SurveyFees_ONLOAN+SantunanDuka_ONLOAN+AnyOtherFees_ONLOAN)TotalFeeChargedToCustomer_ONLOAN                
 , (CarInsuranceAmount_ONCASH+PolisAdminFee_ONCASH+LifeInsuranceAmount_ONCASH+AdminFee_ONCASH+WarrantiPremi_ONCASH                 
   + ProvisionFee_ONCASH+FiduciaFee_ONCASH+AdditionalAdminFee_ONCASH+SurveyFees_ONCASH+SantunanDuka_ONCASH+AnyOtherFees_ONCASH) TotalFeeChargedToCustomer_ONCASH                
 , (CarInsuranceAmount_ONLOAN+CarInsuranceAmount_ONCASH)* 0.25 CarInsuranceIncome                
 , case when SupplierID = 'S240614094' then (WarrantiPremi_ONLOAN + WarrantiPremi_ONCASH) else (WarrantiPremi_ONLOAN + WarrantiPremi_ONCASH) - 825000 end WarrantyIncome                
 , LoanAmount                
 , [FlatInterestRate(%)]                
 , [EffectiveInterestRate(%)]                
 , Tenor                
 , [InstallmentType(Addm/Addb)]                
 , Installment                
 , Case when Business = 'UCF'                 
  then DownPayment + InstallmentAmount + AdminFee + InsAssetReceivedinAdv + lifeinsurancepremium + OtherFee                 
  else TDP                
  end as TotalDownPayment                
 , ApAmount                
 , ApAmountNett                
 , DisbursalDate                
 , DisbMonth                
 , FirstInstallmentDate                
 , HurdleRate                
 , NULL DealerAgentRefundAsPerFinanciersScheme                 
 , EffectiveInterestRatePMT                
 , HurdleRatePMT                
 --dmd 1013     stefanus          
 ,ActualLoanClosureDate            
 ,([EffectiveInterestRate(%)]-HurdleRate)[Oto Share%]          
 --end dmd 1013        
 into MainDailyDisbursement3                
from MainDailyDisbursement2 with (nolock);                
                
                
select                 
 GoliveMonth                
 , GoLiveDate                
 --, ApplicationID                
 , CustomerName                
 , PONo                
 , AgreementNo                 
 , Business                
 , OTR                
 , DownPaymentNett                
 , CarInsuranceAmount_ONLOAN                
 , CarInsuranceAmount_ONCASH                
 , PolisAdminFee_ONLOAN                
 , PolisAdminFee_ONCASH                
 , LifeInsuranceAmount_ONLOAN                
 , LifeInsuranceAmount_ONCASH                
 , AdminFee_ONLOAN                
 , AdminFee_ONCASH                
 , WarrantiPremi_ONLOAN                
 , WarrantiPremi_ONCASH                
 , ProvisionFee_ONLOAN                
 , ProvisionFee_ONCASH                
 , FiduciaFee_ONLOAN                
 , FiduciaFee_ONCASH                
 , AdditionalAdminFee_ONLOAN                
 , AdditionalAdminFee_ONCASH                
 , SurveyFees_ONLOAN                
 , SurveyFees_ONCASH                
 , SantunanDuka_ONLOAN                
 , SantunanDuka_ONCASH                
 , AnyOtherFees_ONLOAN                
 , AnyOtherFees_ONCASH                
 , TotalFeeChargedToCustomer_ONLOAN                
 , TotalFeeChargedToCustomer_ONCASH                
 , CarInsuranceIncome                
 , WarrantyIncome                
 , (AdminFee_ONLOAN+AdminFee_ONCASH+ProvisionFee_ONLOAN+ProvisionFee_ONCASH+CarInsuranceIncome+WarrantyIncome)*0.50 TotalFeeIncomeToBeShared                
 , LoanAmount                
 , LoanAmount+TotalFeeChargedToCustomer_ONLOAN GrossLoanAmount                
 , [FlatInterestRate(%)]                
 , [EffectiveInterestRate(%)]                
 , Tenor                
 , [InstallmentType(Addm/Addb)]                
 , Installment                
 , TotalDownPayment                
 , ApAmount                
 , ApAmountNett                
 , DisbursalDate                
 , DisbMonth                
 , FirstInstallmentDate                
 , HurdleRate          
 , DealerAgentRefundAsPerFinanciersScheme                
 , EffectiveInterestRatePMT                
 , HurdleRatePMT          
 --dmd 1013   Stefanus          
 ,ActualLoanClosureDate            
 ,[Oto Share%]          
 --end dmd 1013        
into MainDailyDisbursement4                
from MainDailyDisbursement3 with (nolock);                
                
                
select                 
  GoliveMonth                
  , GoLiveDate                
  , CustomerName                
  , PONo                
  , AgreementNo                 
  , Business                
  , OTR                
  , DownPaymentNett                
  , CarInsuranceAmount_ONLOAN                
  , CarInsuranceAmount_ONCASH                
  , PolisAdminFee_ONLOAN                
  , PolisAdminFee_ONCASH                
  , LifeInsuranceAmount_ONLOAN                
  , LifeInsuranceAmount_ONCASH                
  , AdminFee_ONLOAN                
  , AdminFee_ONCASH                
  , WarrantiPremi_ONLOAN                
  , WarrantiPremi_ONCASH                
  , ProvisionFee_ONLOAN                
  , ProvisionFee_ONCASH                
  , FiduciaFee_ONLOAN                
  , FiduciaFee_ONCASH                
  , AdditionalAdminFee_ONLOAN                
  , AdditionalAdminFee_ONCASH                
  , SurveyFees_ONLOAN                
  , SurveyFees_ONCASH                
  , SantunanDuka_ONLOAN                
  , SantunanDuka_ONCASH                
  , AnyOtherFees_ONLOAN                
  , AnyOtherFees_ONCASH                
  , TotalFeeChargedToCustomer_ONLOAN                
  , TotalFeeChargedToCustomer_ONCASH                
  , CarInsuranceIncome                
  , WarrantyIncome                
  , round(TotalFeeIncomeToBeShared,0)TotalFeeIncomeToBeShared                
  , LoanAmount                
  , GrossLoanAmount                
, [FlatInterestRate(%)]                
  , [EffectiveInterestRate(%)]                
  , Tenor                
  , [InstallmentType(Addm/Addb)]                
  , Installment                
  , TotalDownPayment                
  , ApAmount                
  , ApAmountNett                
  , DisbursalDate                
  , DisbMonth                
  , FirstInstallmentDate                
  , HurdleRate                
  , DealerAgentRefundAsPerFinanciersScheme                
  , EffectiveInterestRatePMT                
  , HurdleRatePMT                
  , EffectiveInterestRatePMT / 12 AS MonthlyInterestRate                
        , (GrossLoanAmount * (EffectiveInterestRatePMT / 12)) / (1 - POWER(1 + (EffectiveInterestRatePMT / 12), -Tenor)) AS MonthlyPayment                
  , ((GrossLoanAmount * (EffectiveInterestRatePMT / 12)) / (1 - POWER(1 + (EffectiveInterestRatePMT / 12), -Tenor))* Tenor - GrossLoanAmount) AS CumulativeInterest                
  --dmd 1013 Stefanus          
 , ActualLoanClosureDate              
  ,[Oto Share%]          
  --end dmd 1013        
into MainDailyDisbursement5                
from MainDailyDisbursement4 with (nolock);                
                
          
select                 
  GoliveMonth                
  , GoLiveDate                
  , CustomerName                
  , PONo                
  , AgreementNo                 
  , Business        
  , OTR                
  , DownPaymentNett                
  , CarInsuranceAmount_ONLOAN                
  , CarInsuranceAmount_ONCASH                
  , PolisAdminFee_ONLOAN                
  , PolisAdminFee_ONCASH                
  , LifeInsuranceAmount_ONLOAN                
  , LifeInsuranceAmount_ONCASH                
  , AdminFee_ONLOAN                
  , AdminFee_ONCASH                
  , WarrantiPremi_ONLOAN                
  , WarrantiPremi_ONCASH                
  , ProvisionFee_ONLOAN                
  , ProvisionFee_ONCASH                
  , FiduciaFee_ONLOAN                
  , FiduciaFee_ONCASH                
  , AdditionalAdminFee_ONLOAN                
  , AdditionalAdminFee_ONCASH                
  , SurveyFees_ONLOAN                
  , SurveyFees_ONCASH                
  , SantunanDuka_ONLOAN                
  , SantunanDuka_ONCASH                
  , AnyOtherFees_ONLOAN                
  , AnyOtherFees_ONCASH                
  , TotalFeeChargedToCustomer_ONLOAN                
  , TotalFeeChargedToCustomer_ONCASH                
  , CarInsuranceIncome                
  , WarrantyIncome                
  , TotalFeeIncomeToBeShared                
  , round(TotalFeeIncomeToBeShared/1.11,0) DppBeforePpn                
  , LoanAmount                
  , GrossLoanAmount                
  , [FlatInterestRate(%)]                
  , [EffectiveInterestRate(%)]                
  , Tenor                
  , [InstallmentType(Addm/Addb)]             
  , Installment                
  , TotalDownPayment                
  , ApAmount                
  , ApAmountNett                
  , DisbursalDate                
  , DisbMonth                
  , FirstInstallmentDate                
  , HurdleRate                
  , DealerAgentRefundAsPerFinanciersScheme                
  , EffectiveInterestRatePMT                
  , HurdleRatePMT                
  , MonthlyInterestRate                
        , MonthlyPayment                
  , CumulativeInterest                
   --dmd 1013 Stefanus          
 , ActualLoanClosureDate              
  ,[Oto Share%]          
  --end dmd 1013        
into MainDailyDisbursement6                
from MainDailyDisbursement5 with (nolock);                
                
                
                
                
select                 
  a.GoliveMonth                
  , a.GoLiveDate                
  , a.CustomerName                
  , a.PONo                
  , a.AgreementNo                 
  , a.Business                
  , a.OTR                
  , a.DownPaymentNett                
  , a.CarInsuranceAmount_ONLOAN                
  , a.CarInsuranceAmount_ONCASH                
  , a.PolisAdminFee_ONLOAN                
  , a.PolisAdminFee_ONCASH                
  , a.LifeInsuranceAmount_ONLOAN                
  , a.LifeInsuranceAmount_ONCASH                
  , a.AdminFee_ONLOAN                
  , a.AdminFee_ONCASH                
  , a.WarrantiPremi_ONLOAN                
  , a.WarrantiPremi_ONCASH                
  , a.ProvisionFee_ONLOAN                
  , a.ProvisionFee_ONCASH                
  , a.FiduciaFee_ONLOAN                
  , a.FiduciaFee_ONCASH                
  , a.AdditionalAdminFee_ONLOAN                
  , a.AdditionalAdminFee_ONCASH                
  , a.SurveyFees_ONLOAN                
  , a.SurveyFees_ONCASH                
  , a.SantunanDuka_ONLOAN            , a.SantunanDuka_ONCASH                
  , a.AnyOtherFees_ONLOAN                
  , a.AnyOtherFees_ONCASH                
  , a.TotalFeeChargedToCustomer_ONLOAN                
  , a.TotalFeeChargedToCustomer_ONCASH                
  , a.CarInsuranceIncome                
  , a.WarrantyIncome                
  , a.TotalFeeIncomeToBeShared                
  , a.DppBeforePpn                
  , round(a.DppBeforePpn*0.11,0) Ppn                
  , round(a.DppBeforePpn*0.0,0) Wht                
  , round(a.TotalFeeIncomeToBeShared/1.11+a.DppBeforePpn*0.11-a.DppBeforePpn*0.0,0) FeeIncomeSharedNet_NETT                
  , a.LoanAmount                
  , a.GrossLoanAmount           
  , a.[FlatInterestRate(%)]                
  , a.[EffectiveInterestRate(%)]                
  , a.Tenor                
  , a.[InstallmentType(Addm/Addb)]                
  , a.Installment                
  , a.TotalDownPayment                
  , a.ApAmount                
  , a.ApAmountNett                
  , a.DisbursalDate                
  , a.DisbMonth                
  , a.FirstInstallmentDate                
  , cast(round(a.HurdleRate,2,4) as numeric(17,2))  HurdleRate                  
  , a.DealerAgentRefundAsPerFinanciersScheme                
  , a.EffectiveInterestRatePMT                
  , case when  cast(a.GoLiveDate as date) >= '2025-01-01' then cast(round(a.HurdleRate,2,4) as numeric(17,2))/100 else a.HurdleRatePMT end as HurdleRatePMT                    
  , a.MonthlyInterestRate                
  , a.MonthlyPayment                
  , a.CumulativeInterest                
   --dmd 1013 Stefanus          
  ,a.ActualLoanClosureDate              
  ,a.[Oto Share%]              
  ,x.InsSeqNo TotalInstalmentReceived              
  ,case when x.PaidAmount <> x.InstallmentAmount  then 0  else x.InstallmentAmount  end as AmountReceive                
  ,case when x.PaidAmount <> x.InstallmentAmount then null else x.PaidDate end as  DatePaymentReceive              
  ,b.MaturityDate                  
  ,isnull(x.DaysOverdue,0) DPDDays      
  ,case when  x.PaidDate is not null and x.PaidAmount = x.InstallmentAmount then 'Active'           
         else 'Not Active'            
   end as LoanStatus            
  --end dmd 1013             
into db_temp..Temp_MainDailyDisbursement                
from MainDailyDisbursement6 a with (nolock)             
--Add stefanus dmd 1013        
inner join DWBIBFI2_STG..STG_Agreement b with (nolock) on a.AgreementNo = b.AgreementNo                  
LEFT join (            
   select a.ApplicationID, a.InsSeqNo ,x.DaysOverdue, a.PaidDate       ,a.DueDate   ,PaidAmount , InstallmentAmount               
   from DWBIBFI2_ODS.dbo.ODS_InstallmentSchedule a with(nolock)         
   LEFT JOIN       
   (      
   select AgingDate,ApplicationID,DaysOverdue,InstallmentNo from DWBIBFI2_ODS.dbo.ODS_DailyAging a       
   where cast(a.AgingDate as date) =  cast(GETDATE()-1 as date)         
   union       
   select AgingDate,ApplicationID,DaysOverdue,InstallmentNo from DWBIBFI2_ODS.dbo.ODS_DailyAging_Archieve_Daily b       
   where cast(b.AgingDate as date) =  cast(GETDATE()-1 as date)        
   ) x on a.ApplicationID = x.ApplicationID and x.InstallmentNo = a.InsSeqNo      
   where a.PaidDate  is not null      
) x on x.ApplicationID = b.ApplicationID        
--end stefanus dmd 1013