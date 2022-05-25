public with sharing class HL_LookupAccountController {
    
    //Variables For Duplicate Management 
    private List<Account> duplicateRecords = new List<Account>();
    public List<Account> getDuplicateRecords(){
        return duplicateRecords;
    }
    public boolean hasDuplicateResult{
        get{if(duplicateRecords.isEmpty()){
            return FALSE;
        } else {
            return TRUE;
        } 
           }
        set;}
    public String errorDuplicateText{get;set;}      
    
    public Account Account {get;set;} // new account to create  
    public List<aAccount> SearchResults{get;set;} 
    public String PrimaryEntityId {get; set;}
    public String SecondaryEntityId {get; set;}
    public String SearchString{get;set;} 
    public String SearchOption {get{
        if(String.isBlank(searchOption))
            searchOption = SearchOptions[0].getValue();
        return searchOption;
    } set;}
    public List<SelectOption> SearchOptions{get{
        List<SelectOption> searchOptions = new List<SelectOption>();
        searchOptions.add(new SelectOption('Starts With','Starts With'));
        searchOptions.add(new SelectOption('Contains', 'Contains'));
        return searchOptions;
    }}
    public Integer LookupAction{get; set;}
    public Account NewAccount {get; set;}
    public String NewSort {get; set;}
    public String SortField {get{return sortField == null ? 'Name' : sortField;} set{
        toggleDirection(value);
        SortField = value;
    }}
    public String SortDirection {get{return sortDirection == null ? 'ASC' : sortDirection;} set;}
    
    //Added as part of State/Country Picklist
    public List<SelectOption> countryOptions = new List<SelectOption>();
    public List<SelectOption> stateOptions = new List<SelectOption>();
    public Map<String,List<HL_PickListUtil.dependentPicklistWrapper>> countryStateMap = new Map<String,List<HL_PickListUtil.dependentPicklistWrapper>>();
    public Boolean executePostalCodeLookup{get;set;}
    public String jsonMap{get;set;}
    
    public ApexPages.StandardSetController setCon {
        get{
            String raw = String.escapeSingleQuotes(SearchString.remove(',').remove('*'));
            String search = '%' + raw  + '%';
            String startsSearch = raw + '%';
            
            if(setCon == null)
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    'SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Client_Number__c, BillingStateCode, BillingCountryCode ' +  
                    'FROM Account ' +
                    'WHERE ' + (SearchOption == 'Contains' ? 'Name LIKE \'' + search + '\' '  : 'Name LIKE \'' + startsSearch + '\' ') 
                    + (LookupAction == 3 ? ' AND RecordType.DeveloperName IN (\'Capital_Provider\', \'Operating_company\', \'Conflicts_Check_LDCCR\') ' : '') +
                    'ORDER BY ' + SortField + ' ' + SortDirection + ' LIMIT 1000'
                ));
            setCon.setPageSize(1000);
            return setCon;
        }
        set;
    }
    public enum AccountLookupAction{
        AddDebtStructureLender, //0
            AddPreTransactionEquityHolder, //1
            AddPostTransactionEquityHolder, //2
            SingleSelectOrNewAccount, //3
            AddOpportunityPEFirm, //4
            AddPreTransactionLender, //5
            AddPostTransactionLender, //6
            AddOpportunityAdditionalClient, //7
            AddOpportunityAdditionalSubject, //8
            AddEngagementAdditionalClient, //9
            AddEngagementAdditionalSubject, //10
            AddActivityCompany //11
            }
    public HL_LookupAccountController() {
        Map<String, String> q = ApexPages.currentPage().getParameters();
        account = new Account();
        if(q.containsKey('action'))
            LookupAction = Integer.valueOf(q.get('action'));
        if(q.containsKey('entity'))
            PrimaryEntityId = q.get('entity');
        if(q.containsKey('secondary'))
            SecondaryEntityId = q.get('secondary');        
        
        this.duplicateRecords = new List<Account>();
        this.hasDuplicateResult = false;  
        
        //Added as part of State/Country Picklist
        Schema.DescribeFieldResult controllingFieldDescribe = Schema.Account.BillingCountryCode.getDescribe();
        Schema.sObjectField countryField = controllingFieldDescribe.getSObjectField();
        
        Schema.DescribeFieldResult dependentFieldDescribe = Schema.Account.BillingStateCode.getDescribe();
        Schema.sObjectField stateField = dependentFieldDescribe.getSObjectField();        
        this.countryStateMap = HL_PicklistUtil.getDependentOptionsImpl(stateField, countryField);
        jsonMap=JSON.serialize(countryStateMap); 
        executePostalCodeLookup = [SELECT DeveloperName, Enabled__c FROM Trigger_Setting__mdt WHERE DeveloperName = 'Postal_Code_Lookup'].Enabled__c;
    }
    
    public PageReference Search() {
        setCon = null;
        RunSearch();
        return null;
    }
    
    private void RunSearch() {
        SearchResults = PerformSearch(SearchString);               
    } 
    
    private List<aAccount> PerformSearch(string search) {
        List<Account> results = setCon.getRecords();
        List<aAccount> aResults = new List<aAccount>();
        for(Account a : results)
            aResults.Add(new aAccount(a));
        return aResults; 
    }
    
    // save the new account record
    public PageReference saveAccount() {
        NewAccount = account;
        Database.SaveResult saveResult = Database.insert(NewAccount, false);        
        if (!saveResult.isSuccess()) {            
            for (Database.Error error : saveResult.getErrors()) {                
                if (error instanceof Database.DuplicateError) {                    
                    Database.DuplicateError duplicateError = (Database.DuplicateError)error;
                    Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                    
                    // Display duplicate error message as defined in the duplicate rule
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate Error: ' + duplicateResult.getErrorMessage());
                    ApexPages.addMessage(errorMessage);
                    
                    // Get duplicate records
                    this.duplicateRecords = new List<sObject>();
                    
                    // Return only match results of matching rules that 
                    //  find duplicate records
                    Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
                    
                    // Just grab first match result (which contains the 
                    //   duplicate record found and other match info)
                    Datacloud.MatchResult matchResult = matchResults[0];
                    
                    Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
                    
                    // Add matched record to the duplicate records variable
                    for (Datacloud.MatchRecord matchRecord : matchRecords) {
                        this.duplicateRecords.add((Account)matchRecord.getRecord());
                    }
                    this.hasDuplicateResult = !this.duplicateRecords.isEmpty();
                    errorDuplicateText =this.duplicateRecords.size() +' Possible Duplicate Records Found.<br/>' + duplicateResult.getErrorMessage();                    
                }
            }                        
        }
        
        // if additional client or subject, insert the record
        AccountLookupAction action = AccountLookupAction.values()[LookupAction];
        if(action == AccountLookupAction.AddOpportunityAdditionalClient || action == AccountLookupAction.AddOpportunityAdditionalSubject){
            SearchResults = new List<aAccount>();
            SearchResults.add(new aAccount(Account,true));
            SaveSelected('Company Added To ' + (action == AccountLookupAction.AddOpportunityAdditionalClient ? 'Additional Clients' : 'Additional Subjects'));
        }
        if(action == AccountLookupAction.AddPreTransactionEquityHolder || action == AccountLookupAction.AddPostTransactionEquityHolder){
            SearchResults = new List<aAccount>();
            SearchResults.add(new aAccount(Account,true));
            SaveSelected('Company Added To Equity Holders');
        }
        //return (new ApexPages.StandardController(NewAccount)).view();
        // reset the account
        //Account = new Account();      
        return null;
    }  
    
    public void SaveSelected(String saveMsg){
		Map<String,Schema.RecordTypeInfo> opprtMap = Schema.SObjectType.Opportunity_Client_Subject__c.getRecordTypeInfosByDeveloperName();
        Id oppSubjectRT = opprtMap.get('Subject').getRecordTypeId();
        Id oppClientRT = opprtMap.get('Client').getRecordTypeId();
        Id oppPEFirmRT = opprtMap.get('PE_Firm').getRecordTypeId();
        Map<String,Schema.RecordTypeInfo> engrtMap = Schema.SObjectType.Engagement_Client_Subject__c.getRecordTypeInfosByDeveloperName();
        Id engKeyCreditorRT = engrtMap.get('Key_Creditor').getRecordTypeId();
        Id engEquityHolderRT = engrtMap.get('Equity_Holder').getRecordTypeId();
               
        AccountLookupAction action = AccountLookupAction.values()[LookupAction];
        if(action == AccountLookupAction.AddOpportunityAdditionalClient || action == AccountLookupAction.AddOpportunityAdditionalSubject)
        {
            saveMsg = 'Company Added To ' + (action == AccountLookupAction.AddOpportunityAdditionalClient ? 'Additional Clients' : 'Additional Subjects');
        }
        else if(action == AccountLookupAction.AddPreTransactionEquityHolder || action == AccountLookupAction.AddPostTransactionEquityHolder)
        {
            saveMsg = 'Company Added To Equity Holders';                          
        }
        Set<Id> selectedAccounts = new Set<Id>();
        Map<Id,Decimal> ownershipPercentMap = new Map<Id, Decimal>();
        if(SearchResults <> null)
        {
            for(aAccount a : SearchResults)
            {
                if(a.Selected)
                {                
                    selectedAccounts.Add(a.Account.Id);
                    ownershipPercentMap.put(a.Account.Id, a.PercentOwnership);
                }
            }
            
            if(selectedAccounts.size() > 0)
            {
                if(action == AccountLookupAction.AddDebtStructureLender)
                {
                    List<Engagement_Client_Subject__c> lendersToInsert = new List<Engagement_Client_Subject__c>();
                    for(String a : selectedAccounts)
                        lendersToInsert.add(new Engagement_Client_Subject__c(RecordTypeId = engKeyCreditorRT, Client_Subject__c = a, Engagement__c = PrimaryEntityId, Other_Related_Object_Id__c = SecondaryEntityId, Role__c='Lender', Type__c = 'Key Creditor'));
                    
                    InsertRecords(lendersToInsert, saveMsg);
                }
                
                if(action == AccountLookupAction.AddPreTransactionEquityHolder){
                    List<Engagement_Client_Subject__c> ehToInsert = new List<Engagement_Client_Subject__c>();
                    for(String a : selectedAccounts)
                        ehToInsert.add(new Engagement_Client_Subject__c(RecordTypeId = engEquityHolderRT, Client_Subject__c = a, Engagement__c = PrimaryEntityId, Percent_Ownership__c = (ownershipPercentMap.get(a) <> null ? (Decimal)ownershipPercentMap.get(a) : 0.0), Role__c = 'Pre-Transaction', Type__c = 'Equity Holder'));  
                    
                    InsertRecords(ehToInsert, saveMsg);
                } 
                
                if(action == AccountLookupAction.AddPostTransactionEquityHolder){
                    List<Engagement_Client_Subject__c> ehToInsert = new List<Engagement_Client_Subject__c>();
                    for(String a : selectedAccounts)
                        ehToInsert.add(new Engagement_Client_Subject__c(RecordTypeId = engEquityHolderRT, Client_Subject__c = a, Engagement__c = PrimaryEntityId, Percent_Ownership__c = (ownershipPercentMap.get(a) <> null ? (Decimal)ownershipPercentMap.get(a) : 0.0), Role__c = 'Post-Transaction', Type__c = 'Equity Holder'));  
                    
                    InsertRecords(ehToInsert, saveMsg);
                }
                
                if(action == AccountLookupAction.AddOpportunityPEFirm){
                    List<Opportunity_Client_Subject__c> peToInsert = new List<Opportunity_Client_Subject__c>();
                    for(String a : selectedAccounts)
                        peToInsert.add(new Opportunity_Client_Subject__c(RecordTypeId = oppPEFirmRT, Client_Subject__c = a, Opportunity__c = PrimaryEntityId, Other_Related_Object_Id__c = SecondaryEntityId, Private_Equity_Ownership__c = (ownershipPercentMap.get(a) <> null ? (Decimal)ownershipPercentMap.get(a) : 0.0), Type__c = 'PE Firm'));  
                    
                    InsertRecords(peToInsert, saveMsg);
                }
                
                if(action == AccountLookupAction.AddPreTransactionLender){
                    List<Engagement_Client_Subject__c> lToInsert = new List<Engagement_Client_Subject__c>();
                    for(String a : selectedAccounts)
                        lToInsert.add(new Engagement_Client_Subject__c(RecordTypeId = engKeyCreditorRT, Client_Subject__c = a, Engagement__c = PrimaryEntityId, Other_Related_Object_Id__c = SecondaryEntityId, Loan_Amount__c = (ownershipPercentMap.get(a) <> null ? (Decimal)ownershipPercentMap.get(a) : 0.0), Type__c = 'Key Creditor'));  
                    
                    InsertRecords(lToInsert, saveMsg);
                }
                
                if(action == AccountLookupAction.AddPostTransactionLender){
                    List<Engagement_Client_Subject__c> lToInsert = new List<Engagement_Client_Subject__c>();
                    for(String a : selectedAccounts)
                        lToInsert.add(new Engagement_Client_Subject__c(RecordTypeId = engKeyCreditorRT, Client_Subject__c = a, Engagement__c = PrimaryEntityId, Other_Related_Object_Id__c = SecondaryEntityId, Loan_Amount__c = (ownershipPercentMap.get(a) <> null ? (Decimal)ownershipPercentMap.get(a) : 0.0), Type__c = 'Key Creditor'));  
                    
                    InsertRecords(lToInsert, saveMsg);
                }
                
                if(action == AccountLookupAction.AddOpportunityAdditionalClient){
                    List<Opportunity_Client_Subject__c> oToInsert = new List<Opportunity_Client_Subject__c>();
                    for(String a : selectedAccounts)
                        oToInsert.add(new Opportunity_Client_Subject__c(RecordTypeId = oppClientRT, Client_Subject__c = a, Opportunity__c = PrimaryEntityId, Type__c = 'Client'));  
                    
                    InsertRecords(oToInsert, saveMsg);
                }
                
                if(action == AccountLookupAction.AddOpportunityAdditionalSubject){
                    List<Opportunity_Client_Subject__c> oToInsert = new List<Opportunity_Client_Subject__c>();
                    for(String a : selectedAccounts)
                        oToInsert.add(new Opportunity_Client_Subject__c(RecordTypeId = oppSubjectRT, Client_Subject__c = a, Opportunity__c = PrimaryEntityId, Type__c = 'Subject'));  
                    
                    InsertRecords(oToInsert, saveMsg);
                }
            }
            else
                HL_PageUtility.ShowError('No Company Selected');
        }
        else
            HL_PageUtility.ShowError('No Company Selected');
    }
    public void SaveSelected(){
        SaveSelected('Selections Saved');
    }
    
    private void InsertRecords(List<SObject> recordsToInsert, String saveMsg){
        try
        {         
            insert recordsToInsert;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, saveMsg));
            SearchString = '';
            SearchResults = new List<aAccount>();
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
        }   
    }
    public class aAccount{
        public Account Account {get; set;}
        public Boolean Selected {get; set;}
        public Decimal PercentOwnership {get; set;}
        public aAccount(Account a)
        {
            this(a,false);
        }
        public aAccount(Account a, Boolean isSelected){
            Account = a;
            Selected = isSelected;
        }
    }
    
    // used by the visualforce page to send the link to the right dom element
    public string getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }
    
    // used by the visualforce page to send the link to the right dom element for the text box
    public string getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
    }
    
    public void ApplySort()
    {
        setCon = null;
        this.SortField = NewSort;
        RunSearch();
    }
    public void toggleDirection(string newSort){
        sortDirection = (SortField == newSort) ? (sortDirection == 'DESC' ? 'ASC' : 'DESC') : 'ASC';
    }
    
    
    public PageReference SaveAndIgnore(){
        try{
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;        
            NewAccount = Account;//(Account)Con.getRecord();                        
            Database.SaveResult sr2 = Database.insert(NewAccount, dml);
            return null;//(new ApexPages.StandardController(NewAccount)).view();
        }catch(DmlException ex){            
            HL_PageUtility.ShowError(ex);
            return null;
        }
    }
    
    //Added as part of State/Country Picklist
    public List<SelectOption> getCountries(){    
        Schema.DescribeFieldResult fieldResult = Schema.Account.BillingCountrycode.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();        
        countryOptions = new List<SelectOption>();
        countryOptions.add(new SelectOption('', '--None--'));
        for( Schema.PicklistEntry picklistEntry : picklistEntries)
        {
            countryOptions.add(new SelectOption( picklistEntry.getValue(), picklistEntry.getLabel()));
        }       
        return countryOptions;
    }
    
    //Added as part of State/Country Picklist
    public List<SelectOption> getStates(){
        Schema.DescribeFieldResult fieldResult = Schema.Account.BillingStateCode.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();        
        stateOptions = new List<SelectOption>();
        stateOptions.add(new SelectOption('', '--None--'));
        for( Schema.PicklistEntry picklistEntry : picklistEntries)
        {
            stateOptions.add(new SelectOption( picklistEntry.getValue(), picklistEntry.getLabel()));
        }
        return stateOptions;
    }
    
        //Added as part of State/Country Picklist
}