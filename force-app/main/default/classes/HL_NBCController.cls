/*
Name: HL_NBCController 
*****************************************************************************************
Modified Date           Modified By             Change
21st July 2020         Publicis Sapient         Updated logic to display a warning message if users try to redirect to other pages 
when there are unsaved changes.
26st July 2021         Publicis Sapient         Updated logic to display a error message if users doesnot have sufficent
****************************************************************************************
*/

public with sharing class HL_NBCController {
    public Boolean EnableRequirements{get; set;}
    public Opportunity_Approval__c OpportunityApproval {get; set;}
    public Opportunity_Approval__c oldOpportunityApproval{get;set;}
    public String DelId {get; set;}
    public Boolean validAccess{get; set;}
    public Boolean bool1{get; set;}
    public boolean hideTextAreaboolen{get;set;}
    public List<Financials__c> Financials{get{
        if(financials==null)
            financials=[SELECT Financials__c.Name, Type__c, Year__c, Revenue_MM__c, EBIT_MM__c, EBITDA__c, Pre_Tax_Income__c, Book_Value_MM__c, Assets_Under_Management__c, Interest_and_Fee_Income__c, Face_Value_MM__c, Net_Asset_Value_MM__c, Number_of_Companies__c, Number_of_Loans__c, Number_of_Interests__c, Number_of_Policies__c FROM Financials__c WHERE Related_Approval__c =: OpportunityApproval
                        .Id ORDER BY Year__c DESC];
        return financials;
    }set;}
    
    public Financials__c NewFinancials{
        get{
            if(newFinancials==null)
                newFinancials=new Financials__c(Related_Approval__c=OpportunityApproval.Id);
            return newFinancials;
        }set;
    }
    //Assuming that SysAdmin and CAO's are included as part of OIT Permissions
    public Boolean OnOIT{get{
        if(onOIT == null)
            onOIT = HL_Utility.IsSysAdmin() || (HL_Utility.IsCAO() && HL_SecurityUtility.IsCAOCF()) || HL_OIT.IsActiveOnTeam(OpportunityApproval.Related_Opportunity__c,UserInfo.getUserId()) || HL_SecurityUtility.IsNBCViewGroup();
        return onOIT;
    }set;}   
    //Assuming that SysAdmin and CAO's are included as part of OIT Permissions
    public Boolean OnNBCViewAccess{get{
        if(onNBCViewAccess== null){
            if(HL_OIT.IsActiveOnTeam(OpportunityApproval.Related_Opportunity__c,UserInfo.getUserId())){
                onNBCViewAccess=false;
            }
            else{
                onNBCViewAccess= HL_SecurityUtility.IsNBCViewGroup();
            }
        }
        system.debug('==onNBCViewAccess==='+Opportunity_Approval__c.Real_Estate_Angle__c);
        return onNBCViewAccess;
    }set;}
     
  
    // Boolean value flag variable to disable attach file button before saving record
    public Boolean hasUnsavedChanges{get; set;}
    
    public HL_NBCController(Apexpages.StandardController controller){
        OpportunityApproval = (Opportunity_Approval__c)controller.getRecord();
        oldOpportunityApproval = OpportunityApproval.clone(true,true,true,true);
        hideTextAreaboolen=false;
        //  Overriding the Form_Type__C value with VF page name
        String pageName = ApexPages.currentPage().getUrl().replaceAll('\\?.*', '').replaceAll('/apex/', '');
        If(pageName == 'HL_CNBC')
            OpportunityApproval.Form_Type__c = 'CNBC';
        else
            OpportunityApproval.Form_Type__c = 'NBC';
        
        
        EnableRequirements = false;
        hasUnsavedChanges = false;
        validAccess=accessCheck();
    }
    
    public void RefreshFinancials(){
        Financials = null;
    }
    
    public void SaveNewFinancial(){
        insert NewFinancials;
    }
    
    public PageReference TriggerValidation(){
        EnableRequirements = true;
        return SaveRecord();
    }
    
    private Boolean Save(){
        try{
            update OpportunityApproval;
            return true;
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
        }
        return false;
    }
    
    private Boolean accessCheck(){
        validAccess= HL_Utility.IsSysAdmin() ||(HL_Utility.IsCAO() && HL_SecurityUtility.IsCAOCF()) || HL_OIT.IsActiveOnTeam(OpportunityApproval.Related_Opportunity__c,UserInfo.getUserId()) || HL_SecurityUtility.IsNBCViewGroup();
        if(!validAccess){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.NBCFormNoAccess);
            ApexPages.addMessage(myMsg);
            return false;
            
        } 
        return validAccess;
    }
    
    public PageReference SaveAndReturn(){
        PageReference pf = ApexPages.currentPage();
        try{
            Save();
            pf = new PageReference('/' + OpportunityApproval.Related_Opportunity__c);
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
        }
        return pf;
    }
    
    public PageReference SaveRecord(){    
        PageReference pf = ApexPages.currentPage(); 
        try{
            if(Save()){
                //Redirect to lock them out
                if(String.isNotBlank(OpportunityApproval.Grade__c) && OpportunityApproval.Grade__c <> 'F')
                    pf = new PageReference('/' + OpportunityApproval.Related_Opportunity__c);
                HL_PageUtility.ShowConfirm('Form Saved');
                hasUnsavedChanges = false;
            }
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
        }
        return pf;
    }
    
    public PageReference SubmitForReview(){ 
        //Save the Form - We always want to save the user's progress even if invalid entries are made
        Save();
        //Validate the Form
        if(ValidateForm())
        { 
            return Submit(OpportunityApproval.Form_Type__c);
        }
        else{
            return null;
        } 
    }
    
    public PageReference SubmitToAdmin(){ 
        return Submit(OpportunityApproval.Form_Type__c + '_LOB');
    }
    
    public void CancelSubmission(){
        Save();
        EnableRequirements = false;
    }
    
    private PageReference Submit(string template){
        try{
            if(Save())
                return new PageReference('/apex/HL_SendEmail?retURL=/apex/HL_' + OpportunityApproval.Form_Type__c + '?id=' + OpportunityApproval.Id + '&template=' + template + '&ro=' + OpportunityApproval.Id);
            else
                return null;
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
            return null;
        }
    }
    
    public void DeleteFinancial(){
        if(!String.isBlank(DelId))
        {
            for(Financials__c f : Financials){
                if(f.Id == DelId)
                {
                    delete f;
                    break;
                }
            }
        }
        Financials = null;
    }
    
    public PageReference EUOverride(){
        PageReference pf = new PageReference('/apex/HL_PagePreProcess?opp='+ OpportunityApproval.Related_Opportunity__C + '&action=' + OpportunityApproval.Form_Type__c);
        Save();
        if(OpportunityApproval.EU_Override__c == TRUE)
            OpportunityApproval.EU_Override__c = FALSE;
        else {
            OpportunityApproval.EU_Override__c = TRUE;
        }
        update OpportunityApproval;
        return pf;
    }
    
    public Boolean IsMajoritySaleValid(){
        if(OpportunityApproval.Is_Majority_Sale__c == 'Yes'){
            if(OpportunityApproval.Is_Client_EU__c == 'FALSE'){
                HL_Group hlGroup = new HL_Group('NBC_Public_Deal_Team_Members');
                List<Contact> contactList = hlGroup.GetContacts();
                List<Opportunity_Internal_Team__c> oitList = [SELECT Id FROM Opportunity_Internal_Team__c WHERE Opportunity__c =: OpportunityApproval.Related_Opportunity__c AND Contact__c IN:contactList AND Role__c = 'Public Person' AND End_Date__c = null];
                if(oitList.size() > 0)
                    return true;
                else{
                    String names = GetMajoritySaleContactNames(contactList);
                    HL_PageUtility.ShowError('HL Internal Team: Please add ' + names + ' to the Public role in the HL Internal Team section.');
                    return false;
                }
            }
            if(OpportunityApproval.Is_Client_EU__c == 'TRUE'){
                List<Opportunity_Internal_Team__c> oitPublicList = [SELECT Id FROM Opportunity_Internal_Team__c WHERE Opportunity__c =: OpportunityApproval.Related_Opportunity__c AND Role__c = 'Public Person' AND End_Date__c = null];
                if(oitPublicList.size() > 0)
                    return true;
                else{
                    HL_PageUtility.ShowError('HL Internal Team: Please place an approved staff member in the Public role in the HL Internal Team section.');
                    return false;
                }
            }
        }
        return true;
    }
    
    private Boolean checkEngagementTeamRoles(){
        Boolean hasEngagementTeamAssembled = false;
        List<String> engagementTeamRolesList = new List<String> {'Principal','Manager','Initiator'};
            Set<String> engagementTeamRolesSet = new Set<String>();
        List<Opportunity_Internal_Team__c> oppInternalTeamList = [SELECT Id, Role__c FROM Opportunity_Internal_Team__c WHERE Opportunity__c =: OpportunityApproval.Related_Opportunity__c AND  Staff_Role__r.Name IN : engagementTeamRolesList AND (End_Date__c = null OR End_Date__c > : date.today())];
        for(Opportunity_Internal_Team__c oppInternalTeam : oppInternalTeamList){
            if(!engagementTeamRolesSet.contains(oppInternalTeam.Role__c)){
                engagementTeamRolesSet.add(oppInternalTeam.Role__c);
                if(engagementTeamRolesSet.size() > 2){
                    hasEngagementTeamAssembled = true;
                    break;
                }
            }
        }
        System.debug('opportunity internal team' +oppInternalTeamList);
        return hasEngagementTeamAssembled;
    }
    
    //Validation Related to NBC
    private Boolean ValidateNBCForm(Opportunity_Approval__c oa){
        //Required fields on Submission, they are followed by any additional validation rules to preserve error presentation order
        //--Opportunity Overview
        if(!checkEngagementTeamRoles()){
            HL_PageUtility.ShowError('HL Internal Team - Team must include the following roles: Initiator, Principal, Manager'); 
        }
        if(oa.Client_Ownership__c == null)
            HL_PageUtility.ShowError('Opportunity Overview: Please provide a value for Ownership on the Client\'s Company page.');
        
        if(oa.Company_Ownership_Type__c == null)
            HL_PageUtility.ShowError('Opportunity Overview: Please provide a value for Ownership on the Subject\'s Company page.');
        
        if(oa.Is_Majority_Sale__c == null)
            HL_PageUtility.ShowError('Opportunity Overview: Please answer the Public M&A question.');    
        
        if(!oa.Head_Approval__c)
            HL_PageUtility.ShowError('Opportunity Overview: Please confirm that a group head has approved prior to submitting to the committee.');
        
        //--Overview and Financials
        if(String.isBlank(oa.Transaction_Overview__c))
            HL_PageUtility.ShowError('Overview and Financials: Transaction Overview');  
        
        if(String.isBlank(oa.Current_Status__c))
            HL_PageUtility.ShowError('Overview and Financials: Current Status');
        
        if(String.isBlank(oa.Company_Description__c))
            HL_PageUtility.ShowError('Overview and Financials: Company Description');
        
        if(oa.International_Angle__c==null)
            HL_PageUtility.ShowError('Overview and Financials: Cross-border Angle');
        //If International Angle is 'Yes', Internation Angle Notes are Required
        if(oa.International_Angle__c == 'Yes' && String.isBlank(oa.International_Angle_Notes__c ))
            HL_PageUtility.ShowError('Overview and Financials: Please enter Cross-border Angle notes.');
        
        if(oa.Asia_Angle__c==null)
            HL_PageUtility.ShowError('Overview and Financials: Asia Angle');
        //If Asia Angle is 'Yes', Asia Angle Notes are Required
        if(oa.Asia_Angle__c == 'Yes' && String.isBlank(oa.Asia_Angle_Notes__c ))
            HL_PageUtility.ShowError('Overview and Financials: Please enter Asia Angle notes.');
        
        if(oa.Real_Estate_Angle__c==null)
            HL_PageUtility.ShowError('Overview and Financials: Real Estate Angle');
        
        
        if(oa.Real_Estate_Angle__c == 'Yes' && String.isBlank(oa.Real_Estate_Angle_Notes__c ))
            HL_PageUtility.ShowError('Overview and Financials: Please enter Real Estate Angle notes.');
        
        
        if(String.isBlank(oa.Ownership_and_Capital_Structure__c))
            HL_PageUtility.ShowError('Overview and Financials: Ownership Structure & Capital Structure');        
        
        if(oa.Total_Debt_MM__c==null)
            HL_PageUtility.ShowError('Overview and Financials: Total Debt(MM)');
        
        //If No Financials are Available, an Explanation is Required.
        if(oa.No_Financials__c && String.isBlank(oa.No_Financials_Explanation__c))
            HL_PageUtility.ShowError('Overview and Financials: Please provide an explanation for why Financials are unavailable.');
        
        if(oa.Financials_Subject_to_Audit__c==null && !oa.No_Financials__c)
            HL_PageUtility.ShowError('Overview and Financials: Have the financials been subject to an audit?');
        //If Subject to Edit is 'No', an explanation is required.
        if(oa.Financials_Subject_to_Audit__c=='No' && String.isBlank(oa.Financials_Audit_Notes__c))
            HL_PageUtility.ShowError('Overview and Financials: Please explain why the financials have not been subject to an audit.');
        
        if(oa.Estimated_Valuation__c==null)
            HL_PageUtility.ShowError('Overview and Financials: Estimated Valuation (MM)');
        
        if(String.isBlank(oa.Valuation_Expectations__c))
            HL_PageUtility.ShowError('Overview and Financials: Valuation Expectations');
        
        if(String.isBlank(oa.Risk_Factors__c))
            HL_PageUtility.ShowError('Overview and Financials: Risk Factors');
        
        
        //--Fees
        /*-----------------  This section is commneted because of emoval of min fee and high fee field ---------------------------
if(oa.Estimated_Minimum_Fee__c==null)
HL_PageUtility.ShowError('Fees: Estimated Minimum Fee');

if(oa.Estimated_High_End_Fee__c==null)
HL_PageUtility.ShowError('Fees: Estimated High-End Fee');
*/ 
        // Error msg for new field Estimated_Minimum_Fee__c
        if(oa.Estimated_Minimum_Fee__c==null)
            HL_PageUtility.ShowError('Fees: Estimated Fee (MM)');
        
        if(oa.Estimated_Minimum_Fee__c > 100)
            HL_PageUtility.ShowError('Fees: Estimated Fee (MM) should not be greater than 100 MM');
        
        if(String.isBlank(oa.Fee_Structure__c))
            HL_PageUtility.ShowError('Fees: Fee Structure');
        
        if(oa.Lockups_on_Future_M_A_or_Financing_Work__c==null)
            HL_PageUtility.ShowError('Fees: Lockups on Future M&A or Financing Work');
        
        if(oa.Referral_Fee_Owed__c==null)
            HL_PageUtility.ShowError('Fees: Referral Fee Owed');
        
        
        //--Pre-Pitch
        if(oa.Will_there_be_a_pitch__c == null)
            HL_PageUtility.ShowError('Pre-Pitch: Will there be a pitch?');
        
        if(oa.Existing_or_Repeat_Client__c == null)
            HL_PageUtility.ShowError('Pre-Pitch: Existing or Repeat Client?');
        //Existing or Repeat Client - Listing of Previous Transactions Required
        if(oa.Existing_or_Repeat_Client__c == 'Yes' && 
           String.isBlank(oa.Previous_Transactions__c))
            HL_PageUtility.ShowError('Pre-Pitch: Existing Client, list previous transactions.');
        
        if(String.isBlank(oa.Houlihan_Lokey_Competition__c))
            HL_PageUtility.ShowError('Pre-Pitch: Please identify Houlihan Lokey\'s competition.');
        
        if(oa.Existing_Relationships__c==null)
            HL_PageUtility.ShowError('Pre-Pitch: Have you checked Salesforce for existing relationships?');
        
        if(oa.TAS_Assistance_Benefit__c==null)
            HL_PageUtility.ShowError('Pre-Pitch: Would the Opportunity benefit from TAS Assistance?');
        
        if(String.isBlank(oa.OutsideCouncil__c))
            HL_PageUtility.ShowError('Pre-Pitch: If known, identify the name(s) of the client’s outside counsel and/or other advisors (If any)');
        
        
        //--Financing Checklist
        if(oa.Capital_Markets_Consulted__c==null)
            HL_PageUtility.ShowError('Financing Checklist: Has the Capital Markets Group been consulted regarding financing or capital structure?');
        
        if(String.isBlank(oa.Existing_Financial_Arrangement_Notes__c))
            HL_PageUtility.ShowError('Financing Checklist: Please summarize the existing financial arrangements.');
        
        
        //--Fairness Checklist
        if(oa.Fairness_Opinion_Provided__c==null)
            HL_PageUtility.ShowError('Fairness Checklist: Is there a potential Fairness Opinion component to this assignment?');
        
        if(oa.Fairness_Opinion_Provided__c == 'Yes' && oa.Fairness_Opinion_Publicly_Disclosed__c==null)
            HL_PageUtility.ShowError('Fairness Checklist: Will the Opinion be Publicly Disclosed?');
        
        if(oa.Fairness_Opinion_Provided__c == 'Yes' && oa.Shareholder_Vote__c==null)
            HL_PageUtility.ShowError('Fairness Checklist: Will there be a shareholder vote?');
        
        if(oa.Fairness_Opinion_Provided__c == 'Yes' && String.isBlank(oa.Proposed_Fee_Range__c))
            HL_PageUtility.ShowError('Fairness Checklist: Please provide a Proposed Fee Range.');
        
        if(oa.Fairness_Opinion_Provided__c == 'Yes' && oa.Fairness_Fee_Inclusion__c==null)
            HL_PageUtility.ShowError('Fairness Checklist: Will Fairness fee be included in M&A fee or priced additionally?');
        
        if(oa.Fairness_Opinion_Provided__c == 'Yes' && String.isBlank(oa.Fairness_Opinion_Staffing_Notes__c))
            HL_PageUtility.ShowError('Fairness Checklist: Please provide detail on Fairness staff members and roles if they differ from M&A staffing.');
        
        if(!oa.Form_of_Opinion_Completed__c && oa.Fairness_Opinion_Provided__c == 'Yes')
            HL_PageUtility.ShowError('Fairness Checklist: Form of Opinion, with respect to which of the following are we being asked to opine?');
        
        //If Other Opine Option is Checked, Notes are Required
        if(oa.FEIS_Opine_Option_6__c && String.isBlank(oa.Form_of_Opinion_Notes__c))
            HL_PageUtility.ShowError('Fairness Checklist: Please specify other opines.');
        
        //If a Fairness Opinion was Provided, Related Party Transactions are Required
        if(oa.Fairness_Opinion_Provided__c == 'Yes' && String.isBlank(oa.Related_Party_Transaction__c))
            HL_PageUtility.ShowError('Fairness Checklist: Fairness Opinion was provided, please indicate if this is a Related Party Transaction.');
        
        //If Related Party Transaction is Checked and Fairness Opinion was Provided, Related Party Affiliation Notes are Required
        if(oa.Related_Party_Transaction__c == 'Yes' && oa.Fairness_Opinion_Provided__c == 'Yes' && 
           String.isBlank(oa.Related_Party_Affiliation_Notes__c))
            HL_PageUtility.ShowError('Fairness Checklist: Please provide additional Related Party Affiliation notes.');
        
        
        //--Administrative
        if(oa.Restricted_List__c==null)
            HL_PageUtility.ShowError('Administrative: Restricted List?');
        //If on Restricted List, the Date is Required
        if(oa.Restricted_List__c == 'Yes' && oa.Restricted_List_Date__c == null)
            HL_PageUtility.ShowError('Administrative: Restricted List Date Required.');
        
        //If Conflicts Check Requested Date is Blank
        if(oa.Conflict_Check_Date__c==null && !String.isBlank(oa.Id))
            HL_PageUtility.ShowError('Administrative: Conflicts Check not requested yet - Please return to the Opportunity and request a Conflicts Check.');
        
        //If Conflicts Check is True Conflict
        if(oa.Conflicts_Outcome__c=='True Conflict' && !String.isBlank(oa.Id))
            HL_PageUtility.ShowError('Administrative: Conflicts Check Outcome is True Conflict - Please contact Legal Department.');
        
        //If Conflicts Check is Withdrawn/Dead/Expired
        if((oa.Conflicts_Outcome__c=='Withdrawn' || oa.Conflicts_Outcome__c=='Dead' || oa.Conflicts_Outcome__c=='Expired') && !String.isBlank(oa.Id))
            HL_PageUtility.ShowError('Administrative: Conflicts Check Outcome is Withdrawn/Dead/Expired - Please return to the Opportunity and request a Conflicts Check .');
        
        //if Conflicts is Cleared/Managed and not all the cc questions are answered
        if((oa.Conflicts_2a_Not_Listed__c==null && (oa.Conflicts_Outcome__c == 'Cleared' || oa.Conflicts_Outcome__c == 'Managed')) 
           || oa.Conflicts_3a_Related_to_Transaction__c==null
           || oa.Conflicts_35a_Related_to_Client__c==null
           || oa.Conflicts_4a_Conflict_of_Interest__c==null
           || oa.Conflicts_5a_Other_Conflicts__c==null)
            HL_PageUtility.ShowError('Administrative: Please answer all Conflicts Check Information questions.');
        
        //If Any Conflict Check Questions under Conflicts Check Information are 'Yes', Details in Relevant Areas are Required
        if((oa.Conflicts_2a_Not_Listed__c == 'Yes' && String.isBlank(oa.Conflicts_2b_Not_Listed_TXT__c)) ||
           (oa.Conflicts_3a_Related_to_Transaction__c == 'Yes' && String.isBlank(oa.Conflicts_3b_Related_to_Transaction_TXT__c)) ||
           (oa.Conflicts_35a_Related_to_Client__c == 'Yes' && String.isBlank(oa.Conflicts_35a_Related_to_Client_TXT__c)) ||
           (oa.Conflicts_4a_Conflict_of_Interest__c == 'Yes' && String.isBlank(oa.Conflicts_4b_Conflict_of_Interest_TXT__c)) ||
           (oa.Conflicts_5a_Other_Conflicts__c == 'Yes' && String.isBlank(oa.Conflicts_5b_Other_Conflicts_TXT__c)))
            HL_PageUtility.ShowError('Administrative: If the answers to any of the Conflicts Check Information questions are \'Yes,\' please provide details in the relevant text areas.');
        
        return !ApexPages.hasMessages(ApexPages.severity.ERROR);
    }
    
    private Boolean ValidateCNBCForm(Opportunity_Approval__c oa){
        
        //--Opportunity Overview
        if(!checkEngagementTeamRoles()){
            HL_PageUtility.ShowError('HL Internal Team - Team must include the following roles: Initiator, Principal, Manager'); 
        }
        if(oa.Client_Ownership__c == null)
            HL_PageUtility.ShowError('Opportunity Overview: Please provide a value for Ownership on the Client\'s Company page.');
        
        if(oa.Company_Ownership_Type__c == null)
            HL_PageUtility.ShowError('Opportunity Overview: Please provide a value for Ownership on the Subject\'s Company page.');
        
        if(!oa.Head_Approval__c)
            HL_PageUtility.ShowError('Opportunity Overview: Please confirm that a group head has approved prior to submitting to the committee.');
        
        if(oa.Existing_or_Repeat_Client__c == null)
            HL_PageUtility.ShowError('Opportunity Overview: Existing or Repeat Client?');
        //Existing or Repeat Client - Listing of Previous Transactions Required
        if(oa.Existing_or_Repeat_Client__c == 'Yes' && 
           String.isBlank(oa.Previous_Transactions__c))
            HL_PageUtility.ShowError('Opportunity Overview: Existing Client, list previous transactions.');
        
        if(String.isBlank(oa.Houlihan_Lokey_Competition__c))
            HL_PageUtility.ShowError('Opportunity Overview: Please identify Houlihan Lokey\'s competition.');
        
        if(oa.Use_of_Proceeds__c == null)
            HL_PageUtility.ShowError('Opportunity Overview: Use of Proceeds.');
        //On CNBC forms, if Other Use of Proceeds is indicated, Use of Proceeds Details are Required
        if(oa.Use_of_Proceeds__c != null && oa.Use_of_Proceeds__c.contains('Other') && String.isBlank(oa.Use_of_Proceeds_Detail__c))
            HL_PageUtility.ShowError('Opportunity Overview: Please describe Other Use of Proceeds.');
        
        if(oa.Existing_Relationships__c==null)
            HL_PageUtility.ShowError('Opportunity Overview: Have you checked Salesforce for existing relationships?');
        
        
        //--Overview and Financials
        if(String.isBlank(oa.Transaction_Overview__c))
            HL_PageUtility.ShowError('Overview and Financials: Transaction Overview');  
        
        if(String.isBlank(oa.Current_Status__c))
            HL_PageUtility.ShowError('Overview and Financials: Current Status');
        
        if(oa.International_Angle__c==null)
            HL_PageUtility.ShowError('Overview and Financials: Cross-border Angle');
        //If International Angle is 'Yes', Internation Angle Notes are Required
        if(oa.International_Angle__c == 'Yes' && String.isBlank(oa.International_Angle_Notes__c ))
            HL_PageUtility.ShowError('Overview and Financials: Please enter Cross-border Angle notes.');
        
        if(oa.Asia_Angle__c==null)
            HL_PageUtility.ShowError('Overview and Financials: Asia Angle');
        //If Asia Angle is 'Yes', Asia Angle Notes are Required
        if(oa.Asia_Angle__c == 'Yes' && String.isBlank(oa.Asia_Angle_Notes__c ))
            HL_PageUtility.ShowError('Overview and Financials: Please enter Asia Angle notes.'); 
        
        
        if(oa.Real_Estate_Angle__c==null)
            HL_PageUtility.ShowError('Overview and Financials: Real Estate Angle');
        
        
        if(oa.Real_Estate_Angle__c == 'Yes' && String.isBlank(oa.Real_Estate_Angle_Notes__c ))
            HL_PageUtility.ShowError('Overview and Financials: Please enter Real Estate Angle notes.');
        
        if(String.isBlank(oa.Ownership_and_Capital_Structure__c))
            HL_PageUtility.ShowError('Overview and Financials: Ownership Structure & Capital Structure');
        
        if(oa.Total_Debt_MM__c==null)
            HL_PageUtility.ShowError('Overview and Financials: Total Debt(MM)');     
        
        //If No Financials are Available, an Explanation is Required.
        if(oa.No_Financials__c && String.isBlank(oa.No_Financials_Explanation__c))
            HL_PageUtility.ShowError('Overview and Financials: Please provide an explanation for why Financials are unavailable.');
        
        if(oa.Financials_Subject_to_Audit__c==null && !oa.No_Financials__c)
            HL_PageUtility.ShowError('Overview and Financials: Have the financials been subject to an audit?');
        //If Subject to Edit is 'No', an explanation is required.
        if(oa.Financials_Subject_to_Audit__c=='No' && String.isBlank(oa.Financials_Audit_Notes__c))
            HL_PageUtility.ShowError('Overview and Financials: Please explain why the financials have not been subject to an audit.');
        
        if(oa.Capital_Raise__c==null)
            HL_PageUtility.ShowError('Overview and Financials: Capital Raise (MM)');
        
        if(String.isBlank(oa.Structure_and_Pricing_Expectations__c))
            HL_PageUtility.ShowError('Overview and Financials: Structure and Pricing Expectations.');
        
        if(String.isBlank(oa.Risk_Factors__c))
            HL_PageUtility.ShowError('Overview and Financials: Risk Factors');  
        
        
        //--Fees    
        /*-----------------  This section is commneted because of removal of min fee and high fee field ---------------------------
if(oa.Estimated_Minimum_Fee__c==null)
HL_PageUtility.ShowError('Fees: Estimated Minimum Fee');

if(oa.Estimated_High_End_Fee__c==null)
HL_PageUtility.ShowError('Fees: Estimated High-End Fee');
*/ 
        // Error msg for new field Estimated_Minimum_Fee__c
        if(oa.Estimated_Minimum_Fee__c==null)
            HL_PageUtility.ShowError('Fees: Estimated Fee (MM)');
        
        if(oa.Estimated_Minimum_Fee__c > 100)
            HL_PageUtility.ShowError('Fees: Estimated Fee (MM) should not be greater than 100 MM');
        
        if(String.isBlank(oa.Fee_Structure__c))
            HL_PageUtility.ShowError('Fees: Fee Structure');
        
        if(oa.Lockups_on_Future_M_A_or_Financing_Work__c==null)
            HL_PageUtility.ShowError('Fees: Lockups on Future M&A or Financing Work');
        
        if(oa.Referral_Fee_Owed__c==null)
            HL_PageUtility.ShowError('Fees: Referral Fee Owed');
        
        //--Administrative
        if(oa.Restricted_List__c==null)
            HL_PageUtility.ShowError('Administrative: Restricted List?.');
        //If on Restricted List, the Date is Required
        if(oa.Restricted_List__c == 'Yes' && oa.Restricted_List_Date__c == null)
            HL_PageUtility.ShowError('Administrative: Restricted List Date Required.');
        
        //If Conflicts Check Requested Date is Blank, Explanation is Required
        if(oa.Conflict_Check_Date__c == null && !String.isBlank(oa.Id))
            HL_PageUtility.ShowError('Administrative: No Conflicts Check Requested Date - Please return to the Opportunity and request a Conflicts Check.');
        
        //If Conflicts Check is True Conflict
        if(oa.Conflicts_Outcome__c=='True Conflict' && !String.isBlank(oa.Id))
            HL_PageUtility.ShowError('Administrative: Conflicts Check Outcome is True Conflict - Please contact Legal Department.');
        
        //If Conflicts Check is Withdrawn/Dead/Expired
        if((oa.Conflicts_Outcome__c=='Withdrawn' || oa.Conflicts_Outcome__c=='Dead' || oa.Conflicts_Outcome__c=='Expired') && !String.isBlank(oa.Id))
            HL_PageUtility.ShowError('Administrative: Conflicts Check Outcome is Withdrawn/Dead/Expired - Please return to the Opportunity and request a Conflicts Check again.');
        
        return !ApexPages.hasMessages(ApexPages.severity.ERROR);
    }
    
    private Boolean ValidateForm(){
        Opportunity_Approval__c oa = HL_OpportunityApproval.GetById(OpportunityApproval.Id);
        
        if(oa.Form_Type__c == 'NBC')
            ValidateNBCForm(oa);
        else if(oa.Form_Type__c == 'CNBC')
            ValidateCNBCForm(oa);
        
        //Used by All
        IsMajoritySaleValid(); 
        
        return !ApexPages.hasMessages(ApexPages.severity.ERROR);
    }
    
    private String GetMajoritySaleContactNames(List<Contact> cList){
        String names = '';
        if(cList.size() > 2){
            for(Integer i = 0; i<cList.size(); i++){
                Contact c = cList[i];
                if(i < cList.size() - 1)
                    names += c.Name + ', ';
                else
                {
                    names = names.left(names.length() - 2);
                    names += ', or ' + c.Name;
                }
            }
        }
        else
        {
            names = cList[0].Name + ' or ' + cList[1].Name;
        }
        return names;
    }
    
    public Pagereference renderTextArea(){
        bool1 = true;
        return null;
    } 
    // function to set Flag Variable according to onchange event
    public Pagereference onchangeFlagSet(){
        hasUnsavedChanges = true;
        return null;
    }
}