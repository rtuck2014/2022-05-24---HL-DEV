public with sharing class HL_FEISController {
    public Boolean EnableRequirements{get; set;}
    public Opportunity_Approval__c OpportunityApproval {get; set;}
    public String DelId {get; set;}
    public List<Opportunity_Client_Subject__c> ClientsSubjects {get{
        if(clientsSubjects == null)
            clientsSubjects = [SELECT Client_Subject__r.Name, Ownership__c, Private_Equity_Ownership__c, Market_Cap_MM__c, ESOP__c, NFP__c, Insiders__c, Outside_Counsel__c, Financial_Advisors__c, Other_Financial_Advisor_Services__c, Public_Or_Private__c FROM Opportunity_Client_Subject__c WHERE Opportunity__c =: OpportunityApproval.Related_Opportunity__c AND (Type__c =: 'Subject' AND Primary__c =: false) ORDER BY Client_Subject__r.Name];
        return clientsSubjects;
    } set;}
    public List<Opportunity_Client_Subject__c> Counterparties {get{
        if(counterparties == null)
            counterparties = [SELECT Client_Subject__r.Name, Ownership__c, Private_Equity_Ownership__c, Market_Cap_MM__c, ESOP__c, NFP__c, Insiders__c, Outside_Counsel__c, Financial_Advisors__c, Other_Financial_Advisor_Services__c, Public_Or_Private__c FROM Opportunity_Client_Subject__c WHERE Opportunity__c =: OpportunityApproval.Related_Opportunity__c AND Type__c =: 'Contra' ORDER BY Client_Subject__r.Name];
        return counterparties;
    } set;}
    public List<Opportunity_Client_Subject__c> ShareholderCompanies{get{
        if(shareholderCompanies == null)
            shareholderCompanies = [SELECT Client_Subject__r.Name, Shareholder_Vote__c FROM Opportunity_Client_Subject__c WHERE Opportunity__c =: OpportunityApproval.Related_Opportunity__c AND Primary__c =: false AND (Type__c =: 'Contra' OR Type__c =: 'Subject') ORDER BY Client_Subject__r.Name];
        return shareholderCompanies;
    }set;}
    //Assuming that SysAdmin and CAO's are included as part of OIT Permissions
    public Boolean OnOIT{get{
        if(onOIT == null)
            onOIT = HL_Utility.IsSysAdmin() || HL_Utility.IsCAO() || HL_OIT.IsActiveOnTeam(OpportunityApproval.Related_Opportunity__c,UserInfo.getUserId());
        return onOIT;
    }set;}
    
    public HL_FEISController(Apexpages.StandardController controller){
        OpportunityApproval = (Opportunity_Approval__c)controller.getRecord();
     // Overriding the Form_Type__C value with VF page name
     String pageName = Test.isRunningTest() ? 'HL_FEIS' : ApexPages.currentPage().getUrl().replaceAll('\\?.*', '').replaceAll('/apex/', '');
       If(pageName == 'HL_FEIS')
            OpportunityApproval.Form_Type__c = 'FEIS';
           
        EnableRequirements = false;
    }
    public void RefreshClientsSubjects(){
        ClientsSubjects = null;
        ShareholderCompanies = null;
        
    }
    public void RefreshCounterparties(){
        Counterparties = null;
        ShareholderCompanies = null;
    }
    
    public PageReference SaveAndReturn(){
        PageReference pf = ApexPages.currentPage(); 
        try{
            if(!OpportunityApproval.Locked__c)
                Save();
            pf = new PageReference('/' + OpportunityApproval.Related_Opportunity__c);
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
        }
        return pf;
    }
    
    public PageReference TriggerValidation(){
        EnableRequirements = true;
        return SaveRecord();
    }
    public PageReference SaveRecord(){
        PageReference pf = ApexPages.currentPage(); 
        try{
           Save();
           //Redirect to lock them out
           if(OpportunityApproval.Reviewed__c)
                pf = new PageReference('/' + OpportunityApproval.Related_Opportunity__c);
           
           HL_PageUtility.ShowConfirm('FEIS Saved');
        }
        catch(DmlException ex){
           ApexPages.addMessages(ex);
        }
        return pf;
    }
    public PageReference SubmitForm(){ 
        try{
            Save();
            if(ValidateForm()){
                List<Opportunity__c> oppList = [SELECT Job_Type__c,Line_of_Business__c FROM Opportunity__c WHERE Id =: OpportunityApproval.Related_Opportunity__c LIMIT 1];
                if(oppList[0].Line_of_Business__c == 'CF'){
                    return new PageReference('/apex/HL_SendEmail?retURL=/apex/HL_FEIS?id=' + OpportunityApproval.Id + '&template=CF_FEIS&ro=' + OpportunityApproval.Id);
                }else {
                    return new PageReference('/apex/HL_SendEmail?retURL=/apex/HL_FEIS?id=' + OpportunityApproval.Id + '&template=FEIS&ro=' + OpportunityApproval.Id);
                    
                }      
            }
            else
                return null;
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
            return null;
        }
    }
    public void CancelSubmission(){
        EnableRequirements = false;
    }
    private void Save(){
         update OpportunityApproval;
         update ShareholderCompanies;
    }
    
    public void DeleteClientSubject(){
        if(!String.isBlank(DelId))
        {
            for(Opportunity_Client_Subject__c ocs : ClientsSubjects){
                if(ocs.Id == DelId)
                {
                    delete ocs;
                    break;
                }
            }
        }
        ClientsSubjects = null;
        ShareholderCompanies = null;
    }
    
    public void DeleteCounterparty(){
        if(!String.isBlank(DelId))
        {
            for(Opportunity_Client_Subject__c ocs : Counterparties){
                if(ocs.Id == DelId)
                {
                    delete ocs;
                    break;
                }
            }
        }
        Counterparties = null;
        ShareholderCompanies = null;
    }

    public Boolean FairnessAdditionalOfficers(){
        List<Opportunity_Internal_Team__c> oitList = [SELECT Id FROM Opportunity_Internal_Team__c WHERE Opportunity__c =: OpportunityApproval.Related_Opportunity__c AND Role__c = 'Fairness' AND End_Date__c = null];
        if(oitList.size() > 0)
            return true;
        else {
            return false;
        }
    }

    //Validation Related to FEIS
    private Boolean ValidateFEISForm(Opportunity_Approval__c oa){
        //--Background on Transaction
        if(String.isBlank(oa.Transaction_Overview__c))
            HL_PageUtility.ShowError('Background on Transaction: Please enter a Transaction Overview.');
        if(oa.Transaction_Type__c==null)
            HL_PageUtility.ShowError('Background on Transaction: Please select a Transaction Type.');
        //If Other Transaction Type is Indicated, Other Job Type Description is Required
        if(oa.Transaction_Type__c == 'Other' && String.isBlank(oa.FEIS_Other_Job_Type_Desc__c))
            HL_PageUtility.ShowError('Background on Transaction: Please describe other Transaction Type(s).');
        if(oa.Legal_Structure__c==null)
            HL_PageUtility.ShowError('Background on Transaction: Please select a Legal Structure.');
        //If Other Legal Structure is Selected, Description of them is Required
        if(oa.Legal_Structure__c == 'Other' && String.isBlank(oa.FEIS_Other_Legal_Structure_Desc__c))
            HL_PageUtility.ShowError('Background on Transaction: Please describe other Legal Structure(s).');

        //--Form and Amount of Consideration
        if(oa.Estimated_Transaction_Size_MM__c==null)
            HL_PageUtility.ShowError('Form and Amount of Consideration: Please enter a Transaction Size (EV) (MM).');
        if(oa.Form_of_Consideration__c==null)
            HL_PageUtility.ShowError('Form and Amount of Consideration: Please select at least one Form of Consideration.');
        //When 'Other' Form of Consideration is Selected, Other Form(s) of Consideration is required.
        if(!String.isBlank(oa.Form_of_Consideration__c) && oa.Form_of_Consideration__c.contains('Other') && String.isBlank(oa.FEIS_Other_Forms_of_Consid_Desc__c))
            HL_PageUtility.ShowError('Form and Amount of Consideration: Please describe other Form(s) of Consideration.');

        //--Affiliated Parties Information
         if(oa.Opinion_Parties_Affiliated__c==null)
            HL_PageUtility.ShowError('Affiliated Parties Information: Are any of the parties to the transaction affiliated with each other?');
        //If Opinion Parties Affiliated is Checked, Description is Required
        if(oa.Opinion_Parties_Affiliated__c == 'Yes' && String.isBlank(oa.Opinion_Affiliated_Parties_Summary__c))
            HL_PageUtility.ShowError('Affiliated Parties Information: Please identify parties and describe the affiliation.');

        //--Form of Opinion
        //If Opine Other Option is Checked, Notes are Required
        if(oa.FEIS_Opine_Option_6__c && String.isBlank(oa.Form_of_Opinion_Notes__c))
            HL_PageUtility.ShowError('Form of Opinion: Please provide Other Form of Opinion Description.');

        //--Legal Review Criteria
        if(oa.Fairness_Opinion_Publicly_Disclosed__c==null)
            HL_PageUtility.ShowError('Legal Review Criteria: Question 1.');
         //If Fairness Opinion Publicly Disclosed is Yes and this is an FEIS form, the Disclosure Document is Required
        if(oa.Fairness_Opinion_Publicly_Disclosed__c == 'Yes' && oa.Form_Type__c == 'FEIS' && oa.Fairness_Disclosure_Document__c==null)
            HL_PageUtility.ShowError('Legal Review Criteria: In what disclosure document will the opinion (or reference to the opinion) appear?');
        if(oa.Fairness_Opinion_Publicly_Disclosed__c == 'Yes' && oa.Form_Type__c == 'FEIS' && oa.Fairness_Disclosure_Document__c == 'Other' && String.isBlank(oa.Fairness_Disclosure_Document_Other__c))
            HL_PageUtility.ShowError('Legal Review Criteria: Please describe the disclosure document.');
        //If Fairness Opinion Publicly Disclosed is Yes and this is an FEIS form, the Disclosure Analysis is Required
        if(oa.Fairness_Opinion_Publicly_Disclosed__c == 'Yes' && oa.Form_Type__c == 'FEIS' && oa.Fairness_Disclose_Analyses__c==null)
            HL_PageUtility.ShowError('Legal Review Criteria: Will a description of the opinion and underlying analyses be required to be disclosed with the opinion?');    
        //If Fairness in Addition is Yes, Describe Servies and Fees or Fee Schedule
        if(oa.Fairness_In_Addition__c == 'Yes' && String.isBlank(oa.Fairness_Services_and_Fees__c))
            HL_PageUtility.ShowError('Legal Review Criteria: Please describe services and fees or fee schedule.');
        //If Fairness in Addition is Yes, Addtional Officers required
        if(oa.Fairness_In_Addition__c == 'Yes' && oa.Fairness_Additional_Officers__c==null)
            HL_PageUtility.ShowError('Legal Review Criteria: Are there any additional officers providing these services that are not identified in the staff roles list below?');
        if(oa.Fairness_Additional_Officers__c == 'Yes' && !FairnessAdditionalOfficers())
            HL_PageUtility.ShowError('Legal Review Criteria - Additional Officers: Please add additional officers providing other services.');
        //Question 4
        if(oa.Fairness_Relative_Fairness__c==null)
            HL_PageUtility.ShowError('Legal Review Criteria: Question 4.');
        //Question 5
        if(oa.Fairness_Fairness_or_Terms__c==null)
            HL_PageUtility.ShowError('Legal Review Criteria: Question 5.');
        //Question 6
        if(oa.Fairness_Multiple_Conclusions__c==null)
            HL_PageUtility.ShowError('Legal Review Criteria: Question 6.');
        //Question 7
            if(oa.Fairness_Committee_or_Trustee__c==null)
            HL_PageUtility.ShowError('Legal Review Criteria: Question 7.');
        //Question 8
        if(oa.Fairness_Unusual_Opinion__c==null)
            HL_PageUtility.ShowError('Legal Review Criteria: Question 8.');

        //--Relationship Questions
        //if Conflicts is Cleared/Managed and not all the cc questions are answered
        if(oa.Conflicts_3a_Related_to_Transaction__c==null
            || oa.Conflicts_35a_Related_to_Client__c==null
            || oa.Conflicts_4a_Conflict_of_Interest__c==null
            || oa.Conflicts_5a_Other_Conflicts__c==null)
            HL_PageUtility.ShowError('Relationship Questions: Please answer all Relationship Questions.');
         //If Any Conflict Check Questions under Conflicts Check Information are 'Yes', Details in Relevant Areas are Required
        if((oa.Conflicts_3a_Related_to_Transaction__c == 'Yes' && String.isBlank(oa.Conflicts_3b_Related_to_Transaction_TXT__c)) ||
           (oa.Conflicts_35a_Related_to_Client__c == 'Yes' && String.isBlank(oa.Conflicts_35a_Related_to_Client_TXT__c)) ||
           (oa.Conflicts_4a_Conflict_of_Interest__c == 'Yes' && String.isBlank(oa.Conflicts_4b_Conflict_of_Interest_TXT__c)) ||
           (oa.Conflicts_5a_Other_Conflicts__c == 'Yes' && String.isBlank(oa.Conflicts_5b_Other_Conflicts_TXT__c)))
            HL_PageUtility.ShowError('Relationship Questions: If the answers to any of the Relationship Questions are \'Yes,\' please provide details in the relevant text areas.');

        //--Other Opinion Information
        if(oa.Shareholder_Vote__c==null)
            HL_PageUtility.ShowError('Other Opinion Information: Will there be a shareholder vote in connection with the transaction?');
        //loop through client subjects to find out if any are checked 
        Boolean isShareholderChecked = false;
        for(Opportunity_Client_Subject__c ocs: ShareholderCompanies){
                if(ocs.Shareholder_Vote__c)
                    isShareholderChecked = true;
                    break;
            }
        //If Shareholders is Yes, check the above boolean and the Other Shareholders boolean for at least one selection
        if(oa.Shareholder_Vote__c == 'Yes' && !isShareholderChecked && !oa.Has_Other_Shareholders__c)
            HL_PageUtility.ShowError('Other Opinion Information: Please select which company(ies) have a shareholder vote in connection with the transaction.');

        //If Has Other Shareholders is Checked, Other Shareholders is Required
        if(oa.Has_Other_Shareholders__c && String.isBlank(oa.Other_Shareholders__c))
            HL_PageUtility.ShowError('Other Opinion Information: Please describe other shareholder(s).');
        if(oa.Opinion_Special_Committee__c==null)
            HL_PageUtility.ShowError('Other Opinion Information: Will the opinion be addressed to a special committee?');

        return !ApexPages.hasMessages(ApexPages.severity.ERROR);
    }
    
    private Boolean ValidateForm(){
        Opportunity_Approval__c oa = OpportunityApproval;

        ValidateFEISForm(oa);
        //FairnessAdditionalOfficers();

        return !ApexPages.hasMessages(ApexPages.severity.ERROR);
    }
}