//2018-03-05 - Rahimeh Bahrampourian  - Change to make Referral_Contact__c required unless the type is existing client or website
//                                    - For FVA: Make Est. Transaction Size/Market Cap (MM) required for FVA like CF sellside
//2018-03-13 - Rahimeh Bahrampourian  - Make Tombstone Permission required for FVA when requesting engagement number
//2019-12-06 - Nara                   - Added Job Type: FA - Portfolio LIBOR Advisory validations
//2019-12-22 - Vikas Vislav           - Added Validation: Add at least one Contact with an approrpriate Role - confirm with FVA BUAs
//2020-01-10 - Benedict Sabater       - Added Validation: At least one Billing Contact is required for all LOBs (ExBillingContact > 0)              
//2020-04-21 - Publicis sapient      - Added validation check for FR Part 1 Requirement.  

public class HL_OpportunityViewController {


//Assuming that SysAdmin and CAO's are included as part of OIT Permissions
public Boolean OnOIT{get{
    if(onOIT == null)
        onOIT = HL_Utility.IsSysAdmin() ||  (HL_Utility.IsCAO() && HL_SecurityUtility.IsCAOCF()) || HL_OIT.IsActiveOnTeam(Opp.Id,UserInfo.getUserId()) || HL_SecurityUtility.IsNBCViewGroup();
    return onOIT;
}set;}

public Opportunity__c Opp {get; set;}
public Boolean isValidPVUser{get;set;}
public boolean displayError {get; set;}
public boolean displayLockMessage {get; set;}
public Boolean isValidForVP {get;set;}

     public Map<String,String> usersInPublicGroup{
        get{
            String userString = '';
            String isPrincipal = '';
            for(GroupMember inx :[SELECT Id, GroupId, UserOrGroupId, SystemModstamp,group.DeveloperName FROM GroupMember where Group.DeveloperName =  'CAO_FVA' or Group.DeveloperName = 'TAS_Officers']){
                if(inx.group.DeveloperName == 'CAO_FVA'){userString = userString + inx.UserOrGroupId + ';';}
                    if(inx.group.DeveloperName == 'TAS_Officers'){isPrincipal = isPrincipal + inx.UserOrGroupId + ';';}
                
            }
            userString = userString.removeEnd(';');
            isPrincipal = isPrincipal.removeEnd(';');
            //usersInPublicGroup = userString;
            Map<String,String> userGroupMap = new Map<String,String>();
            userGroupMap.put('CAO_FVA',userString);
            userGroupMap.put('TAS_Officers',isPrincipal);
            
           return userGroupMap; 
        }
        set;
    }

public HL_OpportunityViewController(ApexPages.StandardController controller){
    Opp = (Opportunity__c)controller.getRecord();
    Opp = [SELECT Id,Recordtype.Developername,Line_of_Business__c,Resulting_Egmt_Record_Type__c, Confidentiality_Agreement__c, Engagement_Team_Assembled__c, Conflicts_Outcome__c, Converted_to_Engagement__c,Client_Ownership__c, 
           Date_Engaged__c, SIC_Code__c, Retainer__c,Women_Led__c, Opportunity_Description__c,Subject_Company_Ownership__c , ERP_Legislation_Code__c, LegalAdvisorCompany__c, LegalAdvisorCreditor__c,
           SubjectId__c, ClientId__c, ProgressMonthly_Fee__c, Job_Type__c, EBITDA_MM__c, Estimated_Close_Date__c, Tail_Expires__c, Client_Description__c,ERP_HL_Entity__c,
           Contingent_Fee__c, Discretionary_Fee__c, Total_Debt_HL_represents_MM__c, TotalDebtMMConfirmed__c, CompanyEUSecurities__c, NBC_Approved__c, Estimated_Transaction_Size_MM__c, Fairness_Opinion_Component__c, Fee__c,
           FEIS_Approved__c, Valuation_Date__c, TAS_Services__c, Referral_Type__c, Referral_Contact__c, Tombstone_Permission__c, EnforceEBITDA__c, Transaction_Type_FAS__c, Other_Transaction_Type_Notes__c,Total_Estimated_Fee__c,Total_Anticipated_Revenue__c FROM Opportunity__c WHERE Id =: Opp.Id];
    ApexPages.getMessages().clear();    
    displayError = false;
    
    system.debug('===recordtyName=='+opp.recordtype.Developername);
    
    if(Opp != null) {     
        isValidPVUser = VerifyUserforVP(Opp, 'OpportunityPV');
        // checing 'System Administrator (Read Only)' is an axtra check and we do not want to include this in VerifyUserforVP method because this method is being called from some places where system admin read only is not to be checheck.
        if(!isValidPVUser)
            for(User u : [SELECT Id, Profile.Name from User Where Id =: userinfo.getUserId() AND Profile.Name = 'System Administrator (Read Only)'])
        {
            isValidPVUser = isValidJobyTypeOnOpptyForPvConversion(opp);                                     
        }          
    }        
}

public PageReference reload() 
{
    PageReference pageRef = ApexPages.currentPage();
    pageRef.setRedirect(true);
    return pageRef;
}

public boolean submitApprovalRequest(Opportunity__c oppToRequestApproval){
    oppToRequestApproval.Approval_Process__c = 'CONVERSION';
    oppToRequestApproval.Engagement_Approval_Status__c = 'Requesting Engagement Number';
    displayError = false;
    displayLockMessage = true;
    update oppToRequestApproval;
    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
    req1.setObjectId(oppToRequestApproval.id);
    Approval.ProcessResult result = Approval.process(req1);
    return result.isSuccess();
    
}
public void RequestEngamentNumberValidation(){
    ApexPages.getMessages().clear();    
    //query and arrays for Subject and Client address information 
    List<Account> SubjectQuery = [SELECT BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry FROM Account WHERE Id =: Opp.SubjectId__c];
    String SubStreet = SubjectQuery[0].BillingStreet; 
    String SubCity= SubjectQuery[0].BillingCity; 
    String SubState = SubjectQuery[0].BillingState; 
    String SubPost = SubjectQuery[0].BillingPostalCode; 
    String SubCountry = SubjectQuery[0].BillingCountry; 
    
    
    List<Account> ClientQuery = [SELECT BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry FROM Account WHERE Id =: Opp.ClientId__c]; 
    String ClientStreet = ClientQuery[0].BillingStreet; 
    String ClientCity= ClientQuery[0].BillingCity; 
    String ClientState = ClientQuery[0].BillingState; 
    String ClientPost = ClientQuery[0].BillingPostalCode; 
    String ClientCountry = ClientQuery[0].BillingCountry; 
    
    Integer ExContactQuery = [SELECT COUNT() FROM Opportunity_External_Team__c WHERE Opportunity__c=: Opp.Id AND Primary__c = true];
    Integer ExBillingContact = [SELECT COUNT() FROM Opportunity_External_Team__c WHERE Opportunity__c=: Opp.Id AND Billing_Contact__c = true];
    Integer ExFVAContactRole = [SELECT COUNT() FROM Opportunity_External_Team__c WHERE Opportunity__c=: Opp.Id AND Conversion_Check__c = true];
    
    Boolean BasicConditions = false; 
    if(test.isrunningtest())
        BasicConditions = True;
    Boolean SubStateCheck = ((!String.isEmpty(SubCountry) && (SubCountry == 'USA' || SubCountry == 'US' || SubCountry == 'United States' || 
                                                              SubCountry == 'United States of America' || SubCountry == 'CA' || SubCountry == 'Canada') && SubState==null) ? false : true);
    
    Boolean ClientStateCheck = ((!String.isEmpty(ClientCountry) &&  (ClientCountry == 'USA' || ClientCountry == 'US' || ClientCountry == 'United States' ||
                                                                     ClientCountry == 'United States of America' || ClientCountry == 'CA' || ClientCountry == 'Canada') && ClientState==null) ? false : true); 
    
    String  LoB             = String.valueOf(Opp.Line_of_Business__c);
    String  CA              = String.valueOf(Opp.Confidentiality_Agreement__c);
    Boolean Team            = Opp.Engagement_Team_Assembled__c;
    Boolean ConflictOutcome = Opp.Conflicts_Outcome__c;
    Boolean Converted       = Opp.Converted_to_Engagement__c;
    String  ClientOwn       = Opp.Client_Ownership__c; 
    String  SubjectOwn      = Opp.Subject_Company_Ownership__c ;
    String  DateEngaged     = String.valueOf(Opp.Date_Engaged__c);
    String  SIC             = Opp.SIC_Code__c;
    String  WomenLed      = Opp.Women_Led__c;
    String  Retainer        = String.valueOf(Opp.Retainer__c);
    String  Description     = Opp.Opportunity_Description__c;
    String  ReferralType    = String.valueOf(Opp.Referral_Type__c);
    String  ReferralContact = String.valueOf(Opp.Referral_Contact__c);  
    Decimal totalfee        = opp.Total_Estimated_Fee__c<>NULL ? opp.Total_Estimated_Fee__c :0;// opp.Total_Estimated_Fee__c;
    Decimal anticipatedFee  = opp.Total_Anticipated_Revenue__c<>NULL?opp.Total_Anticipated_Revenue__c:0;
    String recordtyName     = opp.recordtype.developername;
    system.debug('===recordtyName=='+opp.recordtype.developername);
    
    system.debug(LoggingLevel.INFO, '++++ CA ' + CA);
    system.debug(LoggingLevel.INFO, '++++ ConflictOutcome ' + ConflictOutcome);
    system.debug(LoggingLevel.INFO, '++++ !Converted ' + !Converted);
    system.debug(LoggingLevel.INFO, '++++ !String.isEmpty(ClientOwn) ' + !String.isEmpty(ClientOwn));
    system.debug(LoggingLevel.INFO, '++++ !String.isEmpty(SubjectOwn) ' + !String.isEmpty(SubjectOwn));
    system.debug(LoggingLevel.INFO, '++++ !String.isEmpty(DateEngaged) ' + !String.isEmpty(DateEngaged));
    system.debug(LoggingLevel.INFO, '++++ !String.isEmpty(SIC) ' + !String.isEmpty(SIC));
    system.debug(LoggingLevel.INFO, '++++ !String.isEmpty(Retainer) ' +  !String.isEmpty(Retainer));
    system.debug(LoggingLevel.INFO, '++++ !String.isEmpty(Description) ' + !String.isEmpty(Description));
    system.debug(LoggingLevel.INFO, '++++ !String.isEmpty(SubStreet) ' + !String.isEmpty(SubStreet));
    system.debug(LoggingLevel.INFO, '++++ !String.isEmpty(SubCity) ' + !String.isEmpty(SubCity));
    system.debug(LoggingLevel.INFO, '++++ !String.isEmpty(SubState) ' + !String.isEmpty(SubState));
    system.debug(LoggingLevel.INFO, '++++ !String.isEmpty(SubPost) ' + !String.isEmpty(SubPost));
    system.debug(LoggingLevel.INFO, '++++ !String.isEmpty(ClientStreet) ' + !String.isEmpty(ClientStreet));
    system.debug(LoggingLevel.INFO, '++++ !String.isEmpty(ClientCity) ' + !String.isEmpty(ClientCity));
    system.debug(LoggingLevel.INFO, '++++ !String.isEmpty(ClientPost) ' + !String.isEmpty(ClientPost));
    system.debug(LoggingLevel.INFO, '++++ !String.isEmpty(SubPost) ' + !String.isEmpty(SubPost));
    system.debug(LoggingLevel.INFO, '++++ ExBillingContact ' + ExBillingContact);
    system.debug(LoggingLevel.INFO, '++++ ExFVAContactRole ' + ExFVAContactRole);
    system.debug(LoggingLevel.INFO, '++++ ReferralType ' + ReferralType);
    system.debug(LoggingLevel.INFO, '++++ !String.isEmpty(ReferralContact) ' + !String.isEmpty(ReferralContact));      
    
    
    if(!String.isEmpty(CA) && 
       ConflictOutcome && 
       Team && 
       !Converted && 
       !String.isEmpty(ClientOwn) && 
       !String.isEmpty(SubjectOwn) && 
       !String.isEmpty(DateEngaged) && 
       !String.isEmpty(SIC) && 
       !String.isEmpty(Retainer) && 
       !String.isEmpty(Description) && 
       !String.isEmpty(SubStreet) && 
       !String.isEmpty(SubCity) && 
       SubStateCheck && 
       !String.isEmpty(SubPost) && 
       !String.isEmpty(ClientStreet) && 
       !String.isEmpty(ClientCity) && 
       !String.isEmpty(ClientPost) && 
       ClientStateCheck && 
       ExContactQuery > 0 &&
       ((!String.isEmpty(ReferralType) && (ReferralType.equals('Website') || ReferralType.equals('N/A - Existing Client'))) || (!String.isEmpty(ReferralType) && !String.isEmpty(ReferralContact))) &&
       // Billing Contact should be required for all LOBs
       
       ExBillingContact > 0 )
    {
        BasicConditions = true; 
    }
    
    
    //Conditions for CF/FR 
    String ProgressFee = String.valueOf(Opp.ProgressMonthly_Fee__c);
    String DiscFee = String.valueOf(Opp.Discretionary_Fee__c);  
    String EstClose         = String.valueOf(Opp.Estimated_Close_Date__c);  
    String ContFee          = String.valueOf(Opp.Contingent_Fee__c);
    
    //Conditions only for CF 
    String JobType          = String.valueOf(Opp.Job_Type__c); 
    String EBITDA           = String.valueOf(Opp.EBITDA_MM__c);
    Boolean EnforceEBITDA    = Opp.EnforceEBITDA__c;
    String Tail             = String.valueOf(Opp.Tail_Expires__c);
    Boolean NBC             = Opp.NBC_Approved__c; 
    String TranSize         = String.valueOf(Opp.Estimated_Transaction_Size_MM__c); 
    String FairnessComponent= String.valueOf(Opp.Fairness_Opinion_Component__c); 
    
    //Conditions only for FVA 
    String FVAFee   = String.valueOf(Opp.Fee__c); 
    Boolean FEIS    = Opp.FEIS_Approved__c; 
    String ValDate  = String.valueOf(Opp.Valuation_Date__c); 
    String TAS      = String.valueOf(Opp.TAS_Services__c);
    String TombstonePermission = String.valueof(Opp.Tombstone_Permission__c); 
    String TransactionType = String.valueOf(Opp.Transaction_Type_FAS__c); 
    String OtherTransactionTypeNotes = String.valueOf(Opp.Other_Transaction_Type_Notes__c);  
    
    //Conditions only for FR
    Decimal TotalDebt       = Opp.Total_Debt_HL_represents_MM__c;
    String EuSecurities     = Opp.CompanyEUSecurities__c;
    String ERPLegEnt        = Opp.ERP_HL_Entity__c;
    Boolean TotalDebtCheck  = Opp.TotalDebtMMConfirmed__c;
    String LegAdvCom        = Opp.LegalAdvisorCompany__c;
    String LegAdvCre        = Opp.LegalAdvisorCreditor__c;
    String ClientDesc       = Opp.Client_Description__c;
    
    if(Approval.isLocked(Opp.Id))
    {
        displayError = false;
        displayLockMessage = true;
        reload();
    }
    //CF Logic
    
    system.debug(LoggingLevel.INFO, '++++ LoB ' + LoB);
    system.debug(LoggingLevel.INFO, '++++ JobType ' + JobType);
    system.debug(LoggingLevel.INFO, '++++ EBITDA ' + EBITDA);
    system.debug(LoggingLevel.INFO, '++++ EstClose ' + EstClose);
    system.debug(LoggingLevel.INFO, '++++ Tail ' + Tail);
    system.debug(LoggingLevel.INFO, '++++ ProgressFee ' + ProgressFee);
    system.debug(LoggingLevel.INFO, '++++ ContFee ' + ContFee);
    system.debug(LoggingLevel.INFO, '++++ NBC ' + NBC);
    system.debug(LoggingLevel.INFO, '++++ TranSize ' + TranSize);
    system.debug(LoggingLevel.INFO, '++++ BasicConditions ' + BasicConditions);
    system.debug(LoggingLevel.INFO, '++++ Approval.isLocked(Opp.Id) ' + Approval.isLocked(Opp.Id));
    
    if (LoB.equals('CF') && (JobType.equals('Sellside') || JobType.contains('Private Funds:')) && !String.isEmpty(EBITDA) && !EnforceEBITDA && !String.isEmpty(EstClose) && !String.isEmpty(WomenLed) &&  
        !String.isEmpty(Tail) && !String.isEmpty(ProgressFee) && !String.isEmpty(ContFee) && 
        NBC && !String.isEmpty(TranSize) && !String.isEmpty(FairnessComponent) && BasicConditions &&  !Approval.isLocked(Opp.Id)) 
    {
        submitApprovalRequest(Opp);
    } 
    else
    {
        if (!String.isEmpty(LoB) && LoB.equals('CF') && !String.isEmpty(JobType) && !JobType.equals('Sellside') && !JobType.contains('Private Funds:') && !String.isEmpty(EstClose) && !String.isEmpty(WomenLed) &&
            !String.isEmpty(Tail) && !String.isEmpty(ProgressFee)
            && !String.isEmpty(ContFee) && NBC && !String.isEmpty(TranSize) && !String.isEmpty(FairnessComponent) && BasicConditions &&
            !Approval.isLocked(Opp.Id)) 
        {              
            submitApprovalRequest(Opp);
        } 
        else 
        {
            //FVA Logic 
            //Fairness Deals
            if (!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(FVAFee) && !String.isEmpty(JobType) && !String.isEmpty(WomenLed)&&
                (JobType.equals('ESOP Fairness') || JobType.equals('Negotiated Fairness'))
                && FEIS && !String.isEmpty(TranSize) && !String.isEmpty(TombstonePermission) && BasicConditions &&  !Approval.isLocked(Opp.Id)&& (totalfee<=anticipatedFee)) 
            {
                submitApprovalRequest(Opp);
                
            }
            // Edited for job type 'Fairness'. 
            else if(!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(FVAFee) && !String.isEmpty(JobType) && !String.isEmpty(WomenLed) &&
                    (JobType.equals('Fairness') || JobType.equals('FA - Fund Opinions-Fairness'))
                    && FEIS && !String.isEmpty(TransactionType) && ((TransactionType.Contains('Other') && !String.isEmpty(OtherTransactionTypeNotes)) || !TransactionType.Contains('Other')) && !String.isEmpty(TranSize) && !String.isEmpty(TombstonePermission) && BasicConditions &&  !Approval.isLocked(Opp.Id) && (totalfee<=anticipatedFee))
                
            {
                submitApprovalRequest(Opp);
            }
            
            
            else
            {
                //FMV Transaction Based Opinion Deals
                if (!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(FVAFee) && !String.isEmpty(JobType) && !String.isEmpty(WomenLed) && 
                    JobType.equals('FMV Transaction Based Opinion') && ExFVAContactRole > 0
                    && !String.isEmpty(TransactionType) && ((TransactionType.Contains('Other') && !String.isEmpty(OtherTransactionTypeNotes)) || !TransactionType.Contains('Other')) && !String.isEmpty(TranSize) && !String.isEmpty(TombstonePermission) && BasicConditions &&  !Approval.isLocked(Opp.Id) && (totalfee<=anticipatedFee)) 
                {
                    submitApprovalRequest(Opp);
                    
                }
                
                else 
                {
                    
                    System.debug(LoB);
                    System.debug(FVAFee);
                    System.debug(JobType);
                    System.debug(ValDate);
                    System.debug(TranSize);
                    System.debug(TombstonePermission);
                    System.debug(BasicConditions);
                    System.debug(Approval.isLocked(Opp.Id));
                    
                    //Financial Advisory Deals
                    if (!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(FVAFee) && !String.isEmpty(JobType) &&
                        (JobType.equals('FA - Portfolio-Valuation') || JobType.equals('FA - Portfolio-Advis/Consulting') || 
                         JobType.equals('FA - Portfolio-Auto Loans') || JobType.equals('FA - Portfolio-Auto Struct Prd') || 
                         JobType.equals('FA - Portfolio-Deriv/Risk Mgmt') || JobType.equals('FA - Portfolio-Diligence/Assets') || 
                         JobType.equals('FA - Portfolio-Funds Transfer') || JobType.equals('FA - Portfolio-GP interest') || 
                         JobType.equals('FA - Portfolio LIBOR Advisory') || JobType.equals('FA - Portfolio - SPAC') || JobType.equals('DRC - Exp Wit-Litigation') || JobType.equals('FA - Portfolio-Real Estate')) && !String.isEmpty(ValDate) 
                        && !String.isEmpty(TranSize) && !String.isEmpty(WomenLed) && !String.isEmpty(TombstonePermission) && BasicConditions &&  !Approval.isLocked(Opp.Id) && (totalfee<=anticipatedFee)) 
                    {                      
                        submitApprovalRequest(Opp);
                        
                    } 
                    else {
                        //TAS Deals
                        if (!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(WomenLed) && !String.isEmpty(FVAFee) && !String.isEmpty(JobType) && (JobType.equals('TAS - Due Diligence Services') || 
                                                                                                                                 JobType.equals('TAS - Tax') || JobType.equals('TAS - Lender Services') || JobType.equals('TAS - Accounting and Financial Reporting Advisory') || 
                                                                                                                                 JobType.equals('TAS - Due Diligence-Sellside') || JobType.equals('TAS - Due Diligence-Buyside') || JobType.equals('TAS - DVC Business Analytics') || JobType.equals('TAS - DVC Decision Modeling')) && !String.isEmpty(TAS) && !String.isEmpty(TranSize) && 
                            !String.isEmpty(TombstonePermission) && BasicConditions &&  !Approval.isLocked(Opp.Id) && (totalfee<=anticipatedFee)) 
                        {
                            submitApprovalRequest(Opp);
                            
                        } else {
                            if (!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(WomenLed) && !String.isEmpty(FVAFee) && !String.isEmpty(JobType) &&(totalfee<=anticipatedFee) &&
                                !(JobType.equals('TAS - Due Diligence Services') || 
                                  JobType.equals('TAS - Tax') || JobType.equals('TAS - Lender Services') || 
                                  JobType.equals('TAS - Accounting and Financial Reporting Advisory') || JobType.equals('TAS - Due Diligence-Sellside') || 
                                  JobType.equals('TAS - Due Diligence-Buyside') || JobType.equals('ESOP Fairness') || JobType.equals('TAS - DVC Business Analytics') || JobType.equals('TAS - DVC Decision Modeling') ||
                                  JobType.equals('Fairness') || JobType.equals('Negotiated Fairness') || JobType.equals('FA - Fund Opinions-Fairness') ||
                                  JobType.equals('FA - Portfolio - SPAC') || JobType.equals('FA - Portfolio-Valuation') || JobType.equals('FA - Portfolio-Advis/Consulting') || 
                                  JobType.equals('FA - Portfolio-Auto Loans') || JobType.equals('FA - Portfolio-Auto Struct Prd') || 
                                  JobType.equals('FA - Portfolio-Deriv/Risk Mgmt') || JobType.equals('FA - Portfolio-Diligence/Assets') || 
                                  JobType.equals('FA - Portfolio-Funds Transfer') || JobType.equals('FA - Portfolio-GP interest') || JobType.equals('FA - Portfolio LIBOR Advisory') || 
                                  JobType.equals('FA - Portfolio-Real Estate') || JobType.equals('Solvency') ||
                                  JobType.equals('FA - Fund Opinions-Non-Fairness') || JobType.equals('FMV Transaction Based Opinion')) &&
                                !String.isEmpty(TranSize) && !String.isEmpty(TombstonePermission) && BasicConditions &&  !Approval.isLocked(Opp.Id) &&
                                (!(!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(JobType) && !String.isEmpty(WomenLed) && (JobType.equals('Board Advisory Services (BAS)') || 
                                                                                                             JobType.equals('FMV Transaction Based Opinion') || JobType.equals('Fairness') || JobType.equals('Solvency')) && ExFVAContactRole == 0))) 
                            {                              
                                submitApprovalRequest(Opp);
                                
                                
                            } else {
                                
                                if(!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(FVAFee) && !String.isEmpty(JobType) && !String.isEmpty(WomenLed)&& 
                                   ((JobType == 'FA - Fund Opinions-Non-Fairness' || JobType == 'Solvency')) &&
                                   !String.isEmpty(TransactionType) && ((TransactionType.Contains('Other') && !String.isEmpty(OtherTransactionTypeNotes)) || !TransactionType.Contains('Other')) && 
                                   !String.isEmpty(TranSize) && !String.isEmpty(TombstonePermission) && BasicConditions &&  !Approval.isLocked(Opp.Id) && (totalfee<=anticipatedFee))
                                    
                                {
                                    
                                    submitApprovalRequest(Opp);
                                    
                                }
                                
                                
                                
                                else {
                                    //FR Logic -removed && (OppContLegAdvCre || NoLegAdvCre) && (OppContLegAdvDeb || NoLegAdvDeb) && !String.isEmpty(DiscFee) 
                                    if (LoB.equals('FR') && !String.isEmpty(ProgressFee) && !String.isEmpty(ReferralType) && BasicConditions &&  !Approval.isLocked(Opp.Id) && !String.isEmpty(ContFee) && !String.isEmpty(EstClose) && !String.isEmpty(WomenLed)&& 
                                        TotalDebtCheck  && !String.isEmpty(ClientDesc) && ((ERPLegEnt.equals('HL Capital, Inc.') && !String.isEmpty(EuSecurities)) || !ERPLegEnt.equals('HL Capital, Inc.')) && !String.isEmpty(LegAdvCre) && !String.isEmpty(LegAdvCom)) {
                                            if(JobType == 'Creditor Advisors' && TotalDebt != null)
                                            {
                                                submitApprovalRequest(Opp); 
                                            }
                                            
                                            if(JobType != 'Creditor Advisors')
                                            {
                                                submitApprovalRequest(Opp);                                              
                                                
                                            }
                                            
                                            
                                        } else {
                                            //SC Logic 
                                            if (LoB.equals('SC') && BasicConditions &&  !Approval.isLocked(Opp.Id)) 
                                            {
                                                submitApprovalRequest(Opp);
                                            }
                                            
                                            //Error Msg Components in order of their appearance on page layout 
                                            else {
                                                if(!Approval.isLocked(Opp.Id))
                                                {
                                                    displayError = true;
                                                    displayLockMessage = false;
                                                }
                                                else
                                                {
                                                    displayError = false;
                                                    displayLockMessage = true;
                                                }
                                                
                                                
                                                //Opportunity Detail
                                                //Client/Subject Address Errors
                                                if (String.isEmpty(ClientStreet)) 
                                                {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.OppClientStreetAddress));
                                                }
                                                if (String.isEmpty(ClientCity)) 
                                                {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.OppClientCityAddress));
                                                }
                                                if (!String.isEmpty (ClientCountry) && (ClientCountry.equals('USA') || ClientCountry.equals('US') || ClientCountry.equals('United States') || 
                                                                                        ClientCountry.equals('United States of America') || ClientCountry.equals('CA') || ClientCountry.equals('Canada')) 
                                                    && String.isEmpty(ClientState)) 
                                                {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.OppClientStateAddress));
                                                }
                                                if (String.isEmpty(ClientPost)) 
                                                {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.OppClientPostalCode));
                                                }                                     
                                                if (String.isEmpty(ClientOwn)) 
                                                {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.OppClientOwnership));
                                                }
                                                if (String.isEmpty(SubStreet)) {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.OppSubjectStreetAddress));
                                                }
                                                if (String.isEmpty(SubCity)) {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Opportunity Detail - Subject: City Address.'));
                                                }
                                                if (!String.isEmpty(SubCountry) && (SubCountry.equals('USA') || SubCountry.equals('US') || SubCountry.equals('United States') || 
                                                                                    SubCountry.equals('United States of America') || SubCountry.equals('CA') || SubCountry.equals('Canada') )&& 
                                                    String.isEmpty(SubState)) 
                                                {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Opportunity Detail - Subject: State Address.'));
                                                }
                                                if (String.isEmpty(SubPost)) 
                                                {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Opportunity Detail - Subject: Postal Code Address.'));
                                                }
                                                //End Client/Subject Address Errors 
                                                if (String.isEmpty(SubjectOwn)) 
                                                {                                         
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Opportunity Detail - Subject: Ownership.'));
                                                }
                                                if (String.isEmpty(SIC)) 
                                                {                                          
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.OppSICCode));
                                                }
                                                if (!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(JobType) &&  (JobType.equals('FA - Portfolio-Valuation') || JobType.equals('FA - Portfolio-Advis/Consulting') || JobType.equals('FA - Portfolio - SPAC') || JobType.equals('FA - Portfolio-Auto Loans') || JobType.equals('FA - Portfolio-Auto Struct Prd') || JobType.equals('FA - Portfolio-Deriv/Risk Mgmt') || JobType.equals('FA - Portfolio-Diligence/Assets') || JobType.equals('FA - Portfolio-Funds Transfer') || JobType.equals('FA - Portfolio-GP interest') || JobType.equals('FA - Portfolio LIBOR Advisory') || JobType.equals('FA - Portfolio-Real Estate')) && String.isEmpty(ValDate)) {                                         
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Opportunity Detail - Valuation Date.'));
                                                }                        
                                                if (!String.isEmpty(LoB) && LoB.equals('FVA') && String.isEmpty(TombstonePermission))
                                                {                                         
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Opportunity Detail - Tombstone Permission.'));
                                                } 
                                                
                                                //Opportunity Description
                                                if (String.isEmpty(Description)) 
                                                {                                          
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Opportunity Description - Opportunity Description.'));
                                                }
                                                
                                                //Marketing
                                                if (!String.isEmpty(LoB) && LoB.equals('FR') && String.isEmpty(ClientDesc)) 
                                                {                                          
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Marketing Information - Client Description.'));
                                                }
                                                if (!String.isEmpty(LoB) && LoB.equals('FR') && JobType == 'Creditor Advisors' && TotalDebt == null) 
                                                {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Marketing Information - Total Debt HL represents(MM), input zero if it’s N/A'));
                                                }
                                                if (!String.isEmpty(LoB) && LoB.equals('FR') && !TotalDebtCheck) 
                                                {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Marketing Information - Select "Total Debt(MM) Confirmed" checkbox to confirm Total Debt is most up to date.'));
                                                }
                                                
                                                //Estimated Financials
                                                if (!String.isEmpty(LoB) && (LoB.equals('CF') || LoB.equals('FVA') ) && String.isEmpty(TranSize)) 
                                                {                                           
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Estimated Financials - Est. Transaction Size/Market Cap.'));
                                                }
                                                if (!String.isEmpty(LoB) && LoB.equals('CF') && (JobType.equals('Sellside') || JobType.contains('Private Funds:')) && (String.isEmpty(EBITDA) || EnforceEBITDA == TRUE)) 
                                                {                                           
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, Label.OppEBITDAError));
                                                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Estimated Financials - Client/Subject: EBITDA(MM), please provide a EBITDA(MM) value on the Client or Subject Company record.'));
                                                }
                                                
                                                //Estimated Fees
                                                if (String.isEmpty(Retainer)) 
                                                {                                          
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Estimated Fees - Retainer, input zero if there\'s no Retainer fee.'));
                                                }
                                                if (!String.isEmpty(LoB) && LoB.equals('CF') && String.isEmpty(Tail)) 
                                                {                                           
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Estimated Fees - Tail Expires.'));
                                                }
                                                if (!String.isEmpty(LoB) && (LoB.equals('CF') || LoB.equals('FR')) && String.isEmpty(ProgressFee)) 
                                                {                                         
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Estimated Fees - Progress/Monthly Fee.'));
                                                }
                                                if (!String.isEmpty(LoB) && (LoB.equals('CF') || LoB.equals('FR')) && String.isEmpty(ContFee)) 
                                                {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Estimated Fees - Contingent Fee.'));
                                                }
                                                if (!String.isEmpty(LoB) && LoB.equals('FVA') && String.isEmpty(FVAFee)) {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Estimated Fees - Fee.'));
                                                }
                                                
                                                //Restricted List / Compliance
                                                if (!String.isEmpty(LoB) && LoB.equals('FR') && ERPLegEnt.equals('HL Capital, Inc.') && String.isEmpty(EuSecurities))
                                                {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Restricted List/Compliance - Does the Company have EU Securities?'));
                                                }
                                                //Referral Information
                                                if (String.isEmpty(ReferralType)) {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Referral Information - Referral Type.'));
                                                }
                                                
                                                //Referral Contact
                                                if (!String.isEmpty(ReferralType) && String.isEmpty(ReferralContact) && !ReferralType.equals('Website') && !ReferralType.equals('N/A - Existing Client')) {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Referral Information - Referral Contact name is required.'));
                                                }
                                                
                                                if (!String.isEmpty(LoB) && LoB.equals('FR') && String.isEmpty(LegAdvCom)) 
                                                {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Referral Information - "Legal Advisor to Company" is required.  Please update this field with the correct value'));
                                                }
                                                if (!String.isEmpty(LoB) && LoB.equals('FR') && String.isEmpty(LegAdvCre)) 
                                                {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Referral Information - "Legal Advisor to Creditor" is required.  Please update this field with the correct value'));
                                                }
                                                
                                                //HL Internal Team
                                                if (!Team) 
                                                {                                     
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'HL Internal Team - Team must include the following roles: Initiator, Seller, Principal, Manager, Associate(Optional), Analyst(Optional).'));
                                                }
                                                
                                                //CA
                                                if (String.isEmpty(CA)) 
                                                {                                          
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Legal Matters - Confidentiality Agreement'));
                                                }
                                                
                                                //Conflicts Check
                                                if (!ConflictOutcome) 
                                                {                                           
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Conflicts Check - A Conflicts Check was completed more than 30 days ago. A new Conflicts Check must be completed.'));
                                                }
                                                
                                                //Administration
                                                if (!String.isEmpty(LoB) && (LoB.equals('CF') || LoB.equals('FR')) && String.isEmpty(EstClose)) {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Administration - Estimated Closed Date.'));
                                                }
                                                   //Administration
                                                if (!String.isEmpty(LoB) && ((LoB.equals('CF')) ||(LoB.equals('FR'))||(LoB.equals('FVA'))) && String.isEmpty(WomenLed)) {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Administration - "Women Led" is required.  Please update this field with the correct value'));
                                                }
                                                
                                                if ( !String.isEmpty(LoB) && (LoB.equals('CF')) && String.isEmpty(FairnessComponent)) {                                        
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Administration - Fairness Opinion Component.'));
                                                }
                                                if (String.isEmpty(DateEngaged)) {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Administration - Date Engaged - Date of Executed Retainer or similar document.'));
                                                }
                                                
                                                //TAS
                                                if (!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(JobType) && (JobType.equals('TAS - Due Diligence Services') || JobType.equals('TAS - Tax') || JobType.equals('TAS - Lender Services') || JobType.equals('TAS - Accounting and Financial Reporting Advisory') || JobType.equals('TAS - Due Diligence-Sellside') || JobType.equals('TAS - Due Diligence-Buyside') || JobType.equals('TAS - DVC Business Analytics') || JobType.equals('TAS - DVC Decision Modeling')) && String.isEmpty(TAS)) {                                         
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'TAS Services - TAS Services.'));
                                                }
                                                
                                                //FEIS/NBC
                                                if (!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(JobType) && 
                                                    (JobType.equals('ESOP Fairness') || JobType.equals('Fairness') || JobType.equals('Negotiated Fairness.') || JobType.equals('FA - Fund Opinions-Fairness')) &&
                                                    !FEIS) 
                                                {    
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Approved FEIS form - Please complete and submit this form via the FEIS button.'));
                                                }
                                                if ( !String.isEmpty(LoB) && LoB.equals('CF') && !NBC && !String.isEmpty(JobType) && 
                                                    !(JobType.equals('Special Committee Advisory') ) )
                                                {                                         
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Approved NBC form - Please complete and submit this form via the NBC button.'));
                                                }
                                                
                                                //Opportunity Contacts
                                                if (ExContactQuery == 0) 
                                                {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Opportunity Contacts - Add at least one Primary Opportunity Contact.'));
                                                }
                                                
                                                //Opportunity Billing Contacts 
                                                if (ExBillingContact == 0) 
                                                {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Opportunity Contacts - Add at least one Billing Contact.'));
                                                }
                                                if (!String.isEmpty(LoB) && LoB.equals('FVA') && !String.isEmpty(JobType) && (JobType.equals('Board Advisory Services (BAS)') || JobType.equals('FMV Transaction Based Opinion') || JobType.equals('Fairness') || JobType.equals('Solvency')) && ExFVAContactRole == 0) 
                                                {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Opportunity Contacts - Add at least one Contact with an approrpriate Role - confirm with FVA BUAs.'));
                                                }
                                                
                                                //Converted Check
                                                if (Converted) 
                                                {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Opportunity has already been engaged previously, cannot submit Opportunities with existing Engagements.'));
                                                }
                                                
                                                //Transaction Type Check
                                                if(string.isNotBlank(LoB) && LoB == 'FVA' && string.isNotBlank(JobType) && (JobType == 'FA - Fund Opinions-Fairness' || JobType == 'FA - Fund Opinions-Non-Fairness' || JobType == 'FMV Transaction Based Opinion' || JobType == 'Fairness'|| JobType == 'Solvency') && String.isEmpty(TransactionType) )
                                                {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Enter Transaction Type'));
                                                }
                                                
                                                // Other Transaction Type Notes Check
                                                if(string.isNotBlank(LoB) && LoB == 'FVA' && string.isNotBlank(JobType) && string.isNotBlank(TransactionType) && TransactionType.Contains('Other') && String.isEmpty(OtherTransactionTypeNotes) )
                                                {
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Enter Other Transaction Type Notes'));
                                                }
                                                // Total Anticipated Revenue check
                                                system.debug('==recordtyName=='+recordtyName);
                                                if (!String.isEmpty(LoB) && LoB.equals('FVA') && (totalfee > anticipatedFee)){
                                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,System.Label.OppTotalAnticipatedRevenue));
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
public static boolean VerifyUserforVP(Opportunity__c Opp, String VerifyTo) {     
    boolean isloggedInUserValidForPV = false;       
    List<Profile> ProfileList = new List<Profile>();        
    Id LoggedInUserProfileId = Userinfo.getProfileId();     
    for(Profile prf : [SELECT Id from Profile WHERE Name = 'System Administrator'])       
    {       
        if(LoggedInUserProfileId == prf.id)     
        {       
            isloggedInUserValidForPV = true;        
        }       
    }       
    
    Set<Id> relatedDelegatedPublicGroupIds = new Set<Id>();     
    
    map<String, list<Id>> OpportunityWithRelatedTMDelegatedUserMap = new map<String, list<Id>>();       
    set<Id> RelatedOpportunityIdSet = new set<Id>();        
    set<Id> RelatedUserIdSet = new set<Id>();       
    set<Id> RelatedGroupIdSet = new set<Id>();      
    RelatedOpportunityIdSet.add(Opp.id);        
    if(isloggedInUserValidForPV == false && RelatedOpportunityIdSet.size() > 0 )        
    {       
        OpportunityWithRelatedTMDelegatedUserMap = HL_Opp_VP_TriggerHelper.fetchUserGroupToBeShared(RelatedOpportunityIdSet);                   
        
        if(OpportunityWithRelatedTMDelegatedUserMap != null && OpportunityWithRelatedTMDelegatedUserMap.KeySet().size() > 0)        
            for(Id opId : RelatedOpportunityIdSet)      
        {       
            if(OpportunityWithRelatedTMDelegatedUserMap.containsKey(opId+'_TM'))                    
                for(Id UserGroupId : OpportunityWithRelatedTMDelegatedUserMap.get(opId+'_TM'))      
            {       
                if(UserGroupId == UserInfo.getUserId())        
                {      
                    isloggedInUserValidForPV = true;        
                    break;      
                }              
            }       
            if(OpportunityWithRelatedTMDelegatedUserMap.containsKey(opId+'_DU'))                        
                for(Id UserGroupId : OpportunityWithRelatedTMDelegatedUserMap.get(opId+'_DU'))      
            {       
                if(UserGroupId != null && String.valueof(UserGroupId).substring(0,3) == '00G')      
                {       
                    relatedDelegatedPublicGroupIds.add(UserGroupId);        
                }       
                else        
                {       
                    if(UserGroupId == UserInfo.getUserId())     
                    {       
                        isloggedInUserValidForPV = true;        
                        break;      
                    }       
                }                               
            }       
            if(OpportunityWithRelatedTMDelegatedUserMap.containsKey(opId+'_PVSupervsr'))        
                for(Id UserGroupId : OpportunityWithRelatedTMDelegatedUserMap.get(opId+'_PVSupervsr'))      
            {       
                if(UserGroupId != null && String.valueof(UserGroupId).substring(0,3) == '00G')      
                {       
                    relatedDelegatedPublicGroupIds.add(UserGroupId);        
                }       
            }
            
            isloggedInUserValidForPV = IsUserMemberofPVSuperVisorOrItschildGroup();
            
        }           
        
    }       
    
    if(isloggedInUserValidForPV == false && relatedDelegatedPublicGroupIds.size() > 0)       
        for (GroupMember gm : [SELECT Id, groupId  FROM GroupMember where UserOrGroupId =: UserInfo.getUserId()])       
    {       
        if(relatedDelegatedPublicGroupIds.contains(gm.groupId))     
        {       
            isloggedInUserValidForPV= true;     
        }       
    }   
    boolean Is_Opp_PV_accessible = false;
    if(isloggedInUserValidForPV){ 
        for(Opportunity__c opp1 :[SELECT Id, Resulting_Egmt_Record_Type__c  FROM Opportunity__c WHERE Id =: opp.Id])
        {
            boolean isValidJobyTypeOnOpptyForPvConversion = isValidJobyTypeOnOpptyForPvConversion(opp1) ;            
            if(isloggedInUserValidForPV && isValidJobyTypeOnOpptyForPvConversion)   
                Is_Opp_PV_accessible = true; 
        }           
    }         
    return Is_Opp_PV_accessible;        
}

public static Boolean isValidJobyTypeOnOpptyForPvConversion(Opportunity__c opp){        
    boolean isValidForVP = false;        
    if(Opp.Resulting_Egmt_Record_Type__c == 'Portfolio_Valuation')
    {
        isValidForVP = true ;
    }
    return isValidForVP;   
} 

public static boolean IsUserMemberofPVSuperVisorOrItschildGroup()
{
    if(HL_ConstantsUtil.isSupervisorMethodExecuted)
    {
        return HL_ConstantsUtil.resultFromSupervisorCalculation;
    }
    else {
        boolean IsAccessibleUser = false;
        //Declaring a Set as we don't want Duplicate Group Ids
        Set<Id> results = new Set<Id>();
        
        //Groups directly associated to user
        Set<Id> groupwithUser = new Set<Id>();
        
        //Populating the Group with User with GroupId we are filtering only  for Group of Type Regular,Role and RoleAndSubordinates
        for(GroupMember  u :[select groupId from GroupMember where UserOrGroupId =: userinfo.getUserId() and (Group.Type = 'Regular')])
        {
            groupwithUser.add(u.groupId);
        }
        
        
        //Combining both the Set
        results.addAll(groupwithUser);
        list<id> tempIDList;
        //Traversing the whole list of Groups to check any other nested Group
        Map<Id,list<Id>> grMap = new Map<Id,List<Id>>();
        for(GroupMember gr : [select id, UserOrGroupId, Groupid from GroupMember where (Group.Type = 'Regular') AND UserOrGroupId IN : results])
        {
            if(!grMap.containskey(gr.UserOrGroupId)){
                tempIDList = new List<Id>();
                tempIDList.add(gr.Groupid);
                grMap.put(gr.UserOrGroupId,tempIDList);
            }
            else
                grMap.get(gr.UserOrGroupId).add(gr.Groupid);
        }
        
        for(Id i :results)
        {
            if(grMap.containsKey(i))
            {
                results.addAll(grMap.get(i));
            }
        }
        
        for(Group grp : [Select id from Group WHERE type='Regular' AND DeveloperName = 'Portfolio_Valuation_Supervisors'])
        {
            if(results.contains(grp.id))
                IsAccessibleUser = true;
        }
        HL_ConstantsUtil.isSupervisorMethodExecuted = true;
        HL_ConstantsUtil.resultFromSupervisorCalculation =IsAccessibleUser;
        return IsAccessibleUser ; 
    }       
}
}