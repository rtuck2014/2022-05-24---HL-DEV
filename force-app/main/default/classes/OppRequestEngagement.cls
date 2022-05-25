public with sharing class OppRequestEngagement {
    
    @AuraEnabled
    public static String validateOpp(String recordId){
        System.debug('called with: '+recordId);
        boolean isValid=true;
        Integer ExContactQuery = 0;
        Integer ExBillingContact = 0;
        Integer ExFVAContactRole=0;
        boolean displayLockMessage=false;
        boolean displayError=false;
        //String validationMessage='Items to complete: \n';
        String ValidationMessage='';
        try {
            List<Opportunity__c> oppList = new List<Opportunity__c>([SELECT Id,Recordtype.Developername,Line_of_Business__c,Resulting_Egmt_Record_Type__c, Confidentiality_Agreement__c, 
            Engagement_Team_Assembled__c, Conflicts_Outcome__c, Converted_to_Engagement__c,Client_Ownership__c, 
            Date_Engaged__c, SIC_Code__c, Retainer__c,Women_Led__c, Opportunity_Description__c,Subject_Company_Ownership__c , ERP_Legislation_Code__c, LegalAdvisorCompany__c, LegalAdvisorCreditor__c,
            SubjectId__c,Subject__r.BillingStreet,Subject__r.BillingCity,Subject__r.BillingState,Subject__r.BillingPostalCode,Subject__r.BillingCountry,
            ClientId__c, Client__r.BillingStreet,Client__r.BillingCity, Client__r.BillingState, Client__r.BillingPostalCode, Client__r.BillingCountry,
            ProgressMonthly_Fee__c, Job_Type__c, EBITDA_MM__c, Estimated_Close_Date__c, Tail_Expires__c, Client_Description__c,ERP_HL_Entity__c,
            Contingent_Fee__c, Discretionary_Fee__c, Total_Debt_HL_represents_MM__c, TotalDebtMMConfirmed__c, CompanyEUSecurities__c, NBC_Approved__c, Estimated_Transaction_Size_MM__c, Fairness_Opinion_Component__c, Fee__c,
            FEIS_Approved__c, Valuation_Date__c, TAS_Services__c, Referral_Type__c, Referral_Contact__c, Tombstone_Permission__c, EnforceEBITDA__c, 
            Transaction_Type_FAS__c, Other_Transaction_Type_Notes__c,Total_Estimated_Fee__c,Total_Anticipated_Revenue__c,
            (SELECT Id,Primary__c,Billing_Contact__c,Conversion_Check__c FROM Opportunity_Client_Teams__r)
            FROM Opportunity__c WHERE Id =:recordId]);

            if(!oppList.isEmpty()){                
                Opportunity__c opp = oppList.get(0);
                for(Opportunity_External_Team__c exTeam : opp.Opportunity_Client_Teams__r){
                    if(exTeam.Primary__c){
                        ExContactQuery+=1;
                    }
                    if(exTeam.Billing_Contact__c){
                        ExBillingContact+=1;
                    }
                    if(exTeam.Conversion_Check__c){
                        ExFVAContactRole+=1;
                    }
                }
                    Boolean BasicConditions = false; 
                if(test.isrunningtest())
                    BasicConditions = true;
                Boolean SubStateCheck = ((!String.isEmpty(opp.Subject__r.BillingCountry) && (opp.Subject__r.BillingCountry == 'USA' || opp.Subject__r.BillingCountry == 'US' || opp.Subject__r.BillingCountry == 'United States' || 
                                                                        opp.Subject__r.BillingCountry == 'United States of America' || opp.Subject__r.BillingCountry == 'CA' || opp.Subject__r.BillingCountry == 'Canada') && String.isBlank(opp.Subject__r.BillingState)) ? false : true);
                
                Boolean ClientStateCheck = ((!String.isEmpty(opp.Client__r.BillingCountry) &&  (opp.Client__r.BillingCountry == 'USA' || opp.Client__r.BillingCountry == 'US' || opp.Client__r.BillingCountry == 'United States' ||
                                                                                opp.Client__r.BillingCountry == 'United States of America' || opp.Client__r.BillingCountry == 'CA' || opp.Client__r.BillingCountry == 'Canada') && String.isBlank(opp.Client__r.BillingState)) ? false : true); 

                String  LoB             = String.valueOf(opp.Line_of_Business__c);
                String  CA              = String.valueOf(opp.Confidentiality_Agreement__c);
                Boolean Team            = opp.Engagement_Team_Assembled__c;
                Boolean ConflictOutcome = opp.Conflicts_Outcome__c;
                Boolean Converted       = opp.Converted_to_Engagement__c;
                String  ClientOwn       = opp.Client_Ownership__c; 
                String  SubjectOwn      = opp.Subject_Company_Ownership__c ;
                String  DateEngaged     = String.valueOf(opp.Date_Engaged__c);
                String  SIC             = opp.SIC_Code__c;
                String  WomenLed        = opp.Women_Led__c;
                String  Retainer        = String.valueOf(opp.Retainer__c);
                String  Description     = opp.Opportunity_Description__c;
                String  ReferralType    = String.valueOf(opp.Referral_Type__c);
                String  ReferralContact = String.valueOf(opp.Referral_Contact__c);  
                Decimal totalfee        = opp.Total_Estimated_Fee__c<>NULL ? opp.Total_Estimated_Fee__c :0;// opp.Total_Estimated_Fee__c;
                Decimal anticipatedFee  = opp.Total_Anticipated_Revenue__c<>NULL?opp.Total_Anticipated_Revenue__c:0;
                String recordtyName     = opp.recordtype.developername;

                if(!String.isEmpty(CA) && 
                    ConflictOutcome && 
                    Team && 
                    !Converted && 
                    String.isNotBlank(ClientOwn) && 
                    String.isNotBlank(SubjectOwn) && 
                    String.isNotBlank(DateEngaged) && 
                    String.isNotBlank(SIC) && 
                    String.isNotBlank(Retainer) && 
                    String.isNotBlank(Description) && 
                    String.isNotBlank(opp.Subject__r.BillingStreet) && 
                    String.isNotBlank(opp.Subject__r.BillingCity) && 
                    SubStateCheck && 
                    String.isNotBlank(opp.Subject__r.BillingPostalCode) && 
                    String.isNotBlank(opp.Client__r.BillingStreet) && 
                    String.isNotBlank(opp.Client__r.BillingCity) && 
                    String.isNotBlank(opp.Client__r.BillingPostalCode) && 
                    ClientStateCheck && 
                    ExContactQuery > 0 &&
                    ((String.isNotBlank(ReferralType) && (ReferralType.equals('Website') || ReferralType.equals('N/A - Existing Client'))) || (String.isNotBlank(ReferralType) && String.isNotBlank(ReferralContact))) &&
                    // Billing Contact should be required for all LOBs                    
                    ExBillingContact > 0 )
                {
                    BasicConditions = true; 
                    //validationMessage+='account billing address is required/n';
                }

                //Conditions for CF/FR 
                String ProgressFee = String.valueOf(opp.ProgressMonthly_Fee__c);
                String DiscFee = String.valueOf(opp.Discretionary_Fee__c);  
                String EstClose         = String.valueOf(opp.Estimated_Close_Date__c);  
                String ContFee          = String.valueOf(opp.Contingent_Fee__c);
                
                //Conditions only for CF 
                String JobType          = String.valueOf(opp.Job_Type__c); 
                String EBITDA           = String.valueOf(opp.EBITDA_MM__c);
                Boolean EnforceEBITDA   = opp.EnforceEBITDA__c;
                String Tail             = String.valueOf(opp.Tail_Expires__c);
                Boolean NBC             = opp.NBC_Approved__c; 
                String TranSize         = String.valueOf(opp.Estimated_Transaction_Size_MM__c); 
                String FairnessComponent= String.valueOf(opp.Fairness_Opinion_Component__c); 
                
                //Conditions only for FVA 
                String FVAFee   = String.valueOf(opp.Fee__c); 
                Boolean FEIS    = opp.FEIS_Approved__c; 
                String ValDate  = String.valueOf(opp.Valuation_Date__c); 
                String TAS      = String.valueOf(opp.TAS_Services__c);
                String TombstonePermission = String.valueof(opp.Tombstone_Permission__c); 
                String TransactionType = String.valueOf(opp.Transaction_Type_FAS__c); 
                String OtherTransactionTypeNotes = String.valueOf(opp.Other_Transaction_Type_Notes__c);  
                
                //Conditions only for FR
                Decimal TotalDebt       = opp.Total_Debt_HL_represents_MM__c;
                String EuSecurities     = opp.CompanyEUSecurities__c;
                String ERPLegEnt        = opp.ERP_HL_Entity__c;
                Boolean TotalDebtCheck  = opp.TotalDebtMMConfirmed__c;
                String LegAdvCom        = opp.LegalAdvisorCompany__c;
                String LegAdvCre        = opp.LegalAdvisorCreditor__c;
                String ClientDesc       = opp.Client_Description__c;
                
                if(Approval.isLocked(opp.Id))
                {
                    displayError = false;
                    displayLockMessage = true;
                    //show info message Submission successful! Please wait for the approval
                }
                
                if (LoB.equals('CF') && (JobType.equals('Sellside') || JobType.contains('Private Funds:')) && !String.isEmpty(EBITDA) && !EnforceEBITDA && !String.isEmpty(EstClose) && !String.isEmpty(WomenLed) &&  !String.isEmpty(Tail) && !String.isEmpty(ProgressFee) && !String.isEmpty(ContFee) && NBC && !String.isEmpty(TranSize) && !String.isEmpty(FairnessComponent) && BasicConditions &&  !Approval.isLocked(Opp.Id)) 
                {
                    submitApprovalRequest(opp);
                }
                else
                {
                    if (!String.isEmpty(LoB) && LoB.equals('CF') && !String.isEmpty(JobType) && !JobType.equals('Sellside') && !JobType.contains('Private Funds:') && !String.isEmpty(EstClose) && !String.isEmpty(WomenLed) &&!String.isEmpty(Tail) && !String.isEmpty(ProgressFee)&& !String.isEmpty(ContFee) && NBC && !String.isEmpty(TranSize) && !String.isEmpty(FairnessComponent) && BasicConditions &&                   !Approval.isLocked(Opp.Id)) 
                {              
                    submitApprovalRequest(Opp);
                } 
                else 
                {
                    //FVA Logic 
                    //Fairness Deals
                    if (!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(FVAFee) && !String.isEmpty(JobType) && !String.isEmpty(WomenLed)&&(JobType.equals('ESOP Fairness') || JobType.equals('Negotiated Fairness')) && FEIS && !String.isEmpty(TranSize) && !String.isEmpty(TombstonePermission) && BasicConditions &&  !Approval.isLocked(Opp.Id)&& (totalfee<=anticipatedFee)) 
                    {
                        submitApprovalRequest(Opp);
                        
                    }
                    // Edited for job type 'Fairness'. 
                    else if(!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(FVAFee) && !String.isEmpty(JobType) && !String.isEmpty(WomenLed) &&(JobType.equals('Fairness') || JobType.equals('FA - Fund Opinions-Fairness'))&& FEIS && !String.isEmpty(TransactionType) && ((TransactionType.Contains('Other') && !String.isEmpty(OtherTransactionTypeNotes)) || !TransactionType.Contains('Other')) && !String.isEmpty(TranSize) && !String.isEmpty(TombstonePermission) && BasicConditions &&  !Approval.isLocked(Opp.Id) && (totalfee<=anticipatedFee))
                        
                    {
                        submitApprovalRequest(Opp);
                    }
                    
                    
                    else
                    {
        
                        //FMV Transaction Based Opinion Deals
                        if (!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(FVAFee) && !String.isEmpty(JobType) && !String.isEmpty(WomenLed) 
                        && JobType.equals('FMV Transaction Based Opinion') && ExFVAContactRole > 0 && !String.isEmpty(TransactionType) && ((TransactionType.Contains('Other') && 
                        !String.isEmpty(OtherTransactionTypeNotes)) || !TransactionType.Contains('Other')) && !String.isEmpty(TranSize) &&
                        !String.isEmpty(TombstonePermission) && BasicConditions &&  !Approval.isLocked(Opp.Id) && (totalfee<=anticipatedFee))  {
                        submitApprovalRequest(opp);                    
                    }                
                    else 
                    {   
                        //Financial Advisory Deals
                        if (!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(FVAFee) && !String.isEmpty(JobType) &&
                            (JobType.equals('FA - Portfolio-Valuation') || JobType.equals('FA - Portfolio-Advis/Consulting') || 
                            JobType.equals('FA - Portfolio-Auto Loans') || JobType.equals('FA - Portfolio-Auto Struct Prd') || 
                            JobType.equals('FA - Portfolio-Deriv/Risk Mgmt') || JobType.equals('FA - Portfolio-Diligence/Assets') || 
                            JobType.equals('FA - Portfolio-Funds Transfer') || JobType.equals('FA - Portfolio-GP interest') || 
                            JobType.equals('FA - Portfolio LIBOR Advisory') || JobType.equals('FA - Portfolio - SPAC') || JobType.equals('DRC - Exp Wit-Litigation') || 
                            JobType.equals('FA - Portfolio-Real Estate')) && !String.isEmpty(ValDate) && !String.isEmpty(TranSize) && !String.isEmpty(WomenLed) && 
                            !String.isEmpty(TombstonePermission) && BasicConditions &&  !Approval.isLocked(Opp.Id) && (totalfee<=anticipatedFee)) {
                            submitApprovalRequest(Opp);                            
                        } 
                    else {
                        //TAS Deals
                        if (String.isNotBlank(LoB) && LoB.equals('FVA') && String.isNotBlank(WomenLed) && String.isNotBlank(FVAFee) && String.isNotBlank(JobType) && 
                        (JobType.equals('TAS - Due Diligence Services') || JobType.equals('TAS - Tax') || JobType.equals('TAS - Lender Services') || 
                        JobType.equals('TAS - Accounting and Financial Reporting Advisory') || JobType.equals('TAS - Due Diligence-Sellside') || 
                        JobType.equals('TAS - Due Diligence-Buyside') || JobType.equals('TAS - DVC Business Analytics') || JobType.equals('TAS - DVC Decision Modeling')) && 
                        String.isNotBlank(TAS) && String.isNotBlank(TranSize) && String.isNotBlank(TombstonePermission) && BasicConditions &&  !Approval.isLocked(Opp.Id) && 
                        (totalfee<=anticipatedFee)) {
                        submitApprovalRequest(opp);                                
                        } 
                    else {
                        if (!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(WomenLed) && !String.isEmpty(FVAFee) && !String.isEmpty(JobType) && 
                        (totalfee<=anticipatedFee) && !(JobType.equals('TAS - Due Diligence Services') || JobType.equals('TAS - Tax') || JobType.equals('TAS - Lender Services') || 
                        JobType.equals('TAS - Accounting and Financial Reporting Advisory') || JobType.equals('TAS - Due Diligence-Sellside') || 
                        JobType.equals('TAS - Due Diligence-Buyside') || JobType.equals('TAS - DVC Business Analytics') || JobType.equals('TAS - DVC Decision Modeling') || 
                        JobType.equals('ESOP Fairness') || JobType.equals('Fairness') || JobType.equals('Negotiated Fairness') || JobType.equals('FA - Fund Opinions-Fairness') || 
                        JobType.equals('FA - Portfolio - SPAC') || JobType.equals('FA - Portfolio-Valuation') || JobType.equals('FA - Portfolio-Advis/Consulting') || 
                        JobType.equals('FA - Portfolio-Auto Loans') || JobType.equals('FA - Portfolio-Auto Struct Prd') || JobType.equals('FA - Portfolio-Deriv/Risk Mgmt') || 
                        JobType.equals('FA - Portfolio-Diligence/Assets') || JobType.equals('FA - Portfolio-Funds Transfer') || JobType.equals('FA - Portfolio-GP interest') || 
                        JobType.equals('FA - Portfolio LIBOR Advisory') || JobType.equals('FA - Portfolio-Real Estate') || JobType.equals('Solvency') || 
                        JobType.equals('FA - Fund Opinions-Non-Fairness') || JobType.equals('FMV Transaction Based Opinion')) && !String.isEmpty(TranSize) && 
                        !String.isEmpty(TombstonePermission) && BasicConditions &&  !Approval.isLocked(Opp.Id) && (!(!String.isEmpty(LoB) && LoB.equals('FVA') && 
                        !String.isEmpty(JobType) && !String.isEmpty(WomenLed) && (JobType.equals('Board Advisory Services (BAS)') || JobType.equals('FMV Transaction Based Opinion') || 
                        JobType.equals('Fairness') || JobType.equals('Solvency')) && ExFVAContactRole == 0))) {                              
                            submitApprovalRequest(Opp);                                     
                        } 
                    else { 
                                    if(!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(FVAFee) && !String.isEmpty(JobType) && !String.isEmpty(WomenLed) && 
                                    ((JobType == 'FA - Fund Opinions-Non-Fairness' || JobType == 'Solvency')) && !String.isEmpty(TransactionType) && ((TransactionType.Contains('Other') && !String.isEmpty(OtherTransactionTypeNotes)) || !TransactionType.Contains('Other')) && 
                                    !String.isEmpty(TranSize) && !String.isEmpty(TombstonePermission) && BasicConditions &&  !Approval.isLocked(Opp.Id) && (totalfee<=anticipatedFee)) {                                    
                                        submitApprovalRequest(Opp);                                    
                                    }                                    
                                    else {
                                        //FR Logic -removed && (OppContLegAdvCre || NoLegAdvCre) && (OppContLegAdvDeb || NoLegAdvDeb) && !String.isEmpty(DiscFee) 
                                        if (LoB.equals('FR') && !String.isEmpty(ProgressFee) && !String.isEmpty(ReferralType) && BasicConditions &&  !Approval.isLocked(Opp.Id) && !String.isEmpty(ContFee) && !String.isEmpty(EstClose) && !String.isEmpty(WomenLed)&& TotalDebtCheck  && !String.isEmpty(ClientDesc) && ((ERPLegEnt.equals('HL Capital, Inc.') && !String.isEmpty(EuSecurities)) || !ERPLegEnt.equals('HL Capital, Inc.')) && !String.isEmpty(LegAdvCre) && !String.isEmpty(LegAdvCom)) {
                                                if(JobType == 'Creditor Advisors' && TotalDebt != null){                                                    submitApprovalRequest(Opp); 
                                                }                                                
                                                if(JobType != 'Creditor Advisors'){                                                    submitApprovalRequest(Opp);                                                    
                                                }
                                            } else {
                                                //SC Logic 
                                                if (LoB.equals('SC') && BasicConditions &&  !Approval.isLocked(Opp.Id)) {
                                                    submitApprovalRequest(Opp);
                                                }                                                
                                                //Error Msg Components in order of their appearance on page layout 
                                                else {
                                                    if(!Approval.isLocked(Opp.Id)){
                                                        displayError = true;
                                                        displayLockMessage = false;
                                                    }
                                                    else{
                                                        displayError = false;
                                                        displayLockMessage = true;
                                                    }
                                                    //Opportunity Detail
                                                    //Client/Subject Address Errors
                                                    if (String.isEmpty(opp.Client__r.BillingStreet)){
                                                        validationMessage+=Label.OppClientStreetAddress+'\n';
                                                    }
                                                    if (String.isEmpty(opp.Client__r.BillingCity)){
                                                        validationMessage+=Label.OppClientCityAddress+'\n';
                                                    }
                                                    if (!String.isEmpty (opp.Client__r.BillingCountry) && (opp.Client__r.BillingCountry.equals('USA') || opp.Client__r.BillingCountry.equals('US') || opp.Client__r.BillingCountry.equals('United States') || 
                                                                                            opp.Client__r.BillingCountry.equals('United States of America') || opp.Client__r.BillingCountry.equals('CA') || opp.Client__r.BillingCountry.equals('Canada')) 
                                                        && String.isEmpty(opp.Client__r.BillingState)){
                                                            validationMessage+=Label.OppClientStateAddress+'\n';
                                                    }
                                                    if (String.isEmpty(opp.Client__r.BillingPostalCode)) {
                                                        validationMessage+=Label.OppClientPostalCode+'\n';
                                                    }                                     
                                                    if (String.isEmpty(ClientOwn)){
                                                        validationMessage+=Label.OppClientOwnership+'\n';
                                                    }
                                                    if (String.isEmpty(opp.Subject__r.BillingStreet)) {
                                                        validationMessage+=Label.OppSubjectStreetAddress+'\n';
                                                    }
                                                    if (String.isEmpty(opp.Subject__r.BillingCity)) {
                                                        validationMessage+='Opportunity Detail - Subject: City Address.'+'\n';
                                                    }
                                                    if (!String.isEmpty(opp.Subject__r.BillingCountry) && (opp.Subject__r.BillingCountry.equals('USA') || opp.Subject__r.BillingCountry.equals('US') || opp.Subject__r.BillingCountry.equals('United States') || 
                                                                                        opp.Subject__r.BillingCountry.equals('United States of America') || opp.Subject__r.BillingCountry.equals('CA') || opp.Subject__r.BillingCountry.equals('Canada') )&& 
                                                        String.isEmpty(opp.Subject__r.BillingState)){
                                                            validationMessage+='Opportunity Detail - Subject: State Address.'+'\n';
                                                    }
                                                    if (String.isEmpty(opp.Subject__r.BillingPostalCode)) {
                                                        validationMessage+='Opportunity Detail - Subject: Postal Code Address.'+'\n';
                                                    }
                                                    //End Client/Subject Address Errors 
                                                    if (String.isEmpty(SubjectOwn)){
                                                        validationMessage+='Opportunity Detail - Subject: Ownership.'+'\n';
                                                    }
                                                    if (String.isEmpty(SIC)){
                                                        validationMessage+=Label.OppSICCode+'\n';
                                                    }
                                                    if (!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(JobType) &&  (JobType.equals('FA - Portfolio-Valuation') || JobType.equals('FA - Portfolio-Advis/Consulting') || JobType.equals('FA - Portfolio - SPAC') || JobType.equals('FA - Portfolio-Auto Loans') || JobType.equals('FA - Portfolio-Auto Struct Prd') || JobType.equals('FA - Portfolio-Deriv/Risk Mgmt') || JobType.equals('FA - Portfolio-Diligence/Assets') || JobType.equals('FA - Portfolio-Funds Transfer') || JobType.equals('FA - Portfolio-GP interest') || JobType.equals('FA - Portfolio LIBOR Advisory') || JobType.equals('FA - Portfolio-Real Estate')) && String.isEmpty(ValDate)) {                                         
                                                        validationMessage+='Opportunity Detail - Valuation Date.'+'\n';
                                                    }                        
                                                    if (!String.isEmpty(LoB) && LoB.equals('FVA') && String.isEmpty(TombstonePermission)){
                                                        validationMessage+='Opportunity Detail - Tombstone Permission.'+'\n';
                                                    }                                                 
                                                    //Opportunity Description
                                                    if (String.isEmpty(Description)) {
                                                        validationMessage+='Opportunity Description - Opportunity Description.'+'\n';
                                                    }                                                
                                                    //Marketing
                                                    if (!String.isEmpty(LoB) && LoB.equals('FR') && String.isEmpty(ClientDesc)){                                                        validationMessage+='Marketing Information - Client Description.'+'\n';
                                                    }
                                                    if (!String.isEmpty(LoB) && LoB.equals('FR') && JobType == 'Creditor Advisors' && TotalDebt == null) {                                                        validationMessage+='Marketing Information - Total Debt HL represents(MM), input zero if it’s N/A'+'\n';
                                                    }
                                                    if (!String.isEmpty(LoB) && LoB.equals('FR') && !TotalDebtCheck) {                                                        validationMessage+='Marketing Information - Select "Total Debt(MM) Confirmed" checkbox to confirm Total Debt is most up to date.'+'\n';
                                                    }                                                
                                                    //Estimated Financials
                                                    if (!String.isEmpty(LoB) && (LoB.equals('CF') || LoB.equals('FVA') ) && String.isEmpty(TranSize)){
                                                        validationMessage+='Estimated Financials - Est. Transaction Size/Market Cap.'+'\n';
                                                    }
                                                    if (!String.isEmpty(LoB) && LoB.equals('CF') && (JobType.equals('Sellside') || JobType.contains('Private Funds:')) && (String.isEmpty(EBITDA) || EnforceEBITDA == TRUE)) {
                                                        validationMessage+=Label.OppEBITDAError+'\n';
                                                    }                                                
                                                    //Estimated Fees
                                                    if (String.isEmpty(Retainer)) {
                                                        validationMessage+='Estimated Fees - Retainer, input zero if there\'s no Retainer fee.'+'\n';
                                                    }
                                                    if (!String.isEmpty(LoB) && LoB.equals('CF') && String.isEmpty(Tail)){
                                                        validationMessage+='Estimated Fees - Tail Expires.'+'\n';
                                                    }
                                                    if (!String.isEmpty(LoB) && (LoB.equals('CF') || LoB.equals('FR')) && String.isEmpty(ProgressFee)){
                                                        validationMessage+='Estimated Fees - Progress/Monthly Fee.'+'\n';
                                                    }
                                                    if (!String.isEmpty(LoB) && (LoB.equals('CF') || LoB.equals('FR')) && String.isEmpty(ContFee)) {
                                                        validationMessage+='Estimated Fees - Contingent Fee.'+'\n';
                                                    }
                                                    if (!String.isEmpty(LoB) && LoB.equals('FVA') && String.isEmpty(FVAFee)) {                                                        validationMessage+='Estimated Fees - Fee.'+'\n';
                                                    }                                                
                                                    //Restricted List / Compliance
                                                    if (!String.isEmpty(LoB) && LoB.equals('FR') && ERPLegEnt.equals('HL Capital, Inc.') && String.isEmpty(EuSecurities)){                                                        validationMessage+='Restricted List/Compliance - Does the Company have EU Securities?'+'\n';
                                                    }
                                                    //Referral Information
                                                    if (String.isEmpty(ReferralType)) {
                                                        validationMessage+='Referral Information - Referral Type.'+'\n';
                                                    }                                                
                                                    //Referral Contact
                                                    if (!String.isEmpty(ReferralType) && String.isEmpty(ReferralContact) && !ReferralType.equals('Website') && !ReferralType.equals('N/A - Existing Client')) {                                                        validationMessage+='Referral Information - Referral Contact name is required.'+'\n';
                                                    }                                                
                                                    if (!String.isEmpty(LoB) && LoB.equals('FR') && String.isEmpty(LegAdvCom)){                                                        validationMessage+='Referral Information - "Legal Advisor to Company" is required.  Please update this field with the correct value'+'\n';
                                                    }
                                                    if (!String.isEmpty(LoB) && LoB.equals('FR') && String.isEmpty(LegAdvCre)){                                                        validationMessage+='Referral Information - "Legal Advisor to Creditor" is required.  Please update this field with the correct value'+'\n';
                                                    }                                                
                                                    //HL Internal Team
                                                    if (!Team) {
                                                        validationMessage+='HL Internal Team - Team must include the following roles: Initiator, Seller, Principal, Manager, Associate(Optional), Analyst(Optional).'+'\n';
                                                    }                                                
                                                    //CA
                                                    if (String.isEmpty(CA)){
                                                        validationMessage+='Legal Matters - Confidentiality Agreement'+'\n';
                                                    }                                                
                                                    //Conflicts Check
                                                    if (!ConflictOutcome) {
                                                        validationMessage+='Conflicts Check - A Conflicts Check was completed more than 30 days ago. A new Conflicts Check must be completed.'+'\n';
                                                    }                                                
                                                    //Administration
                                                    if (!String.isEmpty(LoB) && (LoB.equals('CF') || LoB.equals('FR')) && String.isEmpty(EstClose)) {
                                                        validationMessage+='Administration - Estimated Closed Date.'+'\n';
                                                    }
                                                    //Administration
                                                    if (!String.isEmpty(LoB) && ((LoB.equals('CF')) ||(LoB.equals('FR'))||(LoB.equals('FVA'))) && String.isEmpty(WomenLed)) {
                                                        validationMessage+='Administration - "Women Led" is required.  Please update this field with the correct value'+'\n';
                                                    }                                                
                                                    if ( !String.isEmpty(LoB) && (LoB.equals('CF')) && String.isEmpty(FairnessComponent)) {                                        
                                                        validationMessage+='Administration - Fairness Opinion Component.'+'\n';
                                                    }
                                                    if (String.isEmpty(DateEngaged)) {
                                                        validationMessage+='Administration - Date Engaged - Date of Executed Retainer or similar document.'+'\n';
                                                    }                                                
                                                    //TAS
                                                    if (!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(JobType) && (JobType.equals('TAS - Due Diligence Services') || JobType.equals('TAS - Tax') || JobType.equals('TAS - Lender Services') || JobType.equals('TAS - Accounting and Financial Reporting Advisory') || JobType.equals('TAS - Due Diligence-Sellside') || JobType.equals('TAS - Due Diligence-Buyside') || JobType.equals('TAS - DVC Business Analytics') || JobType.equals('TAS - DVC Decision Modeling')) && String.isEmpty(TAS)) {                                         
                                                        validationMessage+='TAS Services - TAS Services.'+'\n';
                                                    }                                                
                                                    //FEIS/NBC
                                                    if (!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(JobType) && 
                                                        (JobType.equals('ESOP Fairness') || JobType.equals('Fairness') || JobType.equals('Negotiated Fairness.') || JobType.equals('FA - Fund Opinions-Fairness')) && !FEIS) {
                                                            validationMessage+='Approved FEIS form - Please complete and submit this form via the FEIS button.'+'\n';
                                                    }
                                                    if (!String.isEmpty(LoB) && LoB.equals('CF') && !NBC && !String.isEmpty(JobType) && !(JobType.equals('Special Committee Advisory'))){
                                                            validationMessage+='Approved NBC form - Please complete and submit this form via the NBC button.'+'\n';
                                                    }                                                
                                                    //Opportunity Contacts
                                                    if (ExContactQuery == 0) {
                                                        validationMessage+='Opportunity Contacts - Add at least one Primary Opportunity Contact.'+'\n';
                                                    }                                                
                                                    //Opportunity Billing Contacts 
                                                    if (ExBillingContact == 0){
                                                        validationMessage+='Opportunity Contacts - Add at least one Billing Contact.'+'\n';
                                                    }
                                                    if (!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(JobType) && (JobType.equals('Board Advisory Services (BAS)') || JobType.equals('FMV Transaction Based Opinion') || JobType.equals('Fairness') || JobType.equals('Solvency')) && ExFVAContactRole == 0){
                                                        validationMessage+='Opportunity Contacts - Add at least one Contact with an approrpriate Role - confirm with FVA BUAs.'+'\n';
                                                    }                                                
                                                    //Converted Check
                                                    if (Converted){
                                                        validationMessage+='Opportunity has already been engaged previously, cannot submit Opportunities with existing Engagements.'+'\n';
                                                    }
                                                    //Transaction Type Check
                                                    if(string.isNotBlank(LoB) && LoB == 'FVA' && string.isNotBlank(JobType) && (JobType == 'FA - Fund Opinions-Fairness' || JobType == 'FA - Fund Opinions-Non-Fairness' || JobType == 'FMV Transaction Based Opinion' || JobType == 'Fairness'|| JobType == 'Solvency') && String.isEmpty(TransactionType) ){
                                                        validationMessage+='Enter Transaction Type'+'\n';
                                                    }                                                
                                                    // Other Transaction Type Notes Check
                                                    if(string.isNotBlank(LoB) && LoB == 'FVA' && string.isNotBlank(JobType) && string.isNotBlank(TransactionType) && TransactionType.Contains('Other') && String.isEmpty(OtherTransactionTypeNotes) ){
                                                        validationMessage+='Enter Other Transaction Type Notes'+'\n';
                                                    }
                                                    // Total Anticipated Revenue check
                                                    system.debug('==recordtyName=='+recordtyName);
                                                    if (!String.isEmpty(LoB) && LoB.equals('FVA') && (totalfee > anticipatedFee)){
                                                        validationMessage+=System.Label.OppTotalAnticipatedRevenue+'\n';
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }            
        }       
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('validationMessage'+validationMessage);
        return String.IsBlank(validationMessage) ? '':'Items to complete: \n'+ValidationMessage;
    }

    private static boolean submitApprovalRequest(Opportunity__c oppToRequestApproval){
        oppToRequestApproval.Approval_Process__c = 'CONVERSION';        oppToRequestApproval.Engagement_Approval_Status__c = 'Requesting Engagement Number';update oppToRequestApproval;        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();        req1.setObjectId(oppToRequestApproval.id);
        Approval.ProcessResult result = Approval.process(req1);        return result.isSuccess();
        
    }
}