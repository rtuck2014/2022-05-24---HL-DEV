public class HL_CompanyNewController {
    
    public boolean hasDuplicateResult{get;set;}
    public String errorDuplicateText{get;set;}
    public Account NewAccount {get;set;}
    public List<Account> duplicateRecords;        
    public ApexPages.StandardController Con {get; set;}
    //Added as part of State/Country Picklist
    public List<SelectOption> countryOptions = new List<SelectOption>();
    public List<SelectOption> stateOptions = new List<SelectOption>();
    public  Map<String,List<HL_PickListUtil.dependentPicklistWrapper>> countryStateMap = new Map<String,List<HL_PickListUtil.dependentPicklistWrapper>>();
    public string selectedCountry{get;set;}
    public Boolean executePostalCodeLookup{get;set;}
    public String jsonMap{get;set;}
    //Added as part of State/Country Picklist
    
    
    public HL_CompanyNewController(ApexPages.StandardController controller){
        if(controller.getRecord() <> null)
        {            
            NewAccount = (Account)controller.getRecord();
        }
        Con = controller;
        this.duplicateRecords = new List<Account>();
        this.hasDuplicateResult = false; 
        
        //Added as part of State/Country Picklist
        Schema.DescribeFieldResult controllingFieldDescribe = Account.BillingCountryCode.getDescribe();
        Schema.sObjectField countryField = controllingFieldDescribe.getSObjectField();
        Schema.DescribeFieldResult dependentFieldDescribe = Account.BillingStateCode.getDescribe();
        Schema.sObjectField stateField = dependentFieldDescribe.getSObjectField();        
        countryStateMap = HL_PicklistUtil.getDependentOptionsImpl(stateField, countryField);
        jsonMap=JSON.serialize(countryStateMap); 
        executePostalCodeLookup = [SELECT DeveloperName, Enabled__c FROM Trigger_Setting__mdt WHERE DeveloperName = 'Postal_Code_Lookup'].Enabled__c;
        
    }
    
    public List<Account> getDuplicateRecords() {
        
        system.debug('Data in duplicateRecords' + duplicateRecords);
        return this.duplicateRecords;
    }
    
    public PageReference SaveAndIgnore(){
        try{
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;        
            NewAccount = (Account)Con.getRecord();                        
            Database.SaveResult sr2 = Database.insert(NewAccount, dml);
            return (new ApexPages.StandardController(NewAccount)).view();
        }catch(DmlException ex){            
            HL_PageUtility.ShowError(ex);
            return null;
        }
        
        return null;
    }
    
    public PageReference saveAndNew() {        
        try{
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;        
            NewAccount = (Account)Con.getRecord();
            Database.SaveResult sr2 = Database.insert(NewAccount, dml);
            string s = '/' + ('' + NewAccount.get('Id')).subString(0, 3) + '/e?';            
            return new Pagereference(s);             
        }catch(DmlException ex){            
            HL_PageUtility.ShowError(ex);
            return null;
        }
        
        return null;
    }
    
    
    public PageReference SaveRecord() {
        system.debug(Con.getRecord());
        
        NewAccount = (Account)Con.getRecord();
        Database.SaveResult saveResult = Database.insert(NewAccount, false);
        
        system.debug('Data in duplicateRecords' + duplicateRecords);
        
        if (!saveResult.isSuccess()) {
            system.debug('IS NOT SUCCESS');
            for (Database.Error error : saveResult.getErrors()) {                
                if (error instanceof Database.DuplicateError) {                    
                    Database.DuplicateError duplicateError = 
                        (Database.DuplicateError)error;
                    Datacloud.DuplicateResult duplicateResult = 
                        duplicateError.getDuplicateResult();
                    
                    // Display duplicate error message as defined in the duplicate rule
                    ApexPages.Message errorMessage = new ApexPages.Message(
                        ApexPages.Severity.ERROR, 'Duplicate Error: ' + 
                        duplicateResult.getErrorMessage());
                    ApexPages.addMessage(errorMessage);
                    
                    // Get duplicate records
                    this.duplicateRecords = new List<sObject>();
                    
                    // Return only match results of matching rules that 
                    //  find duplicate records
                    Datacloud.MatchResult[] matchResults = 
                        duplicateResult.getMatchResults();
                    
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
            //If there’s a duplicate record, stay on the page
            return null;
        }
        
        //  After save, navigate to the view page:
        return (new ApexPages.StandardController(NewAccount)).view();
    }
    
    //Added as part of State/Country Picklist
    public List<SelectOption> getCountries(){    
        Schema.DescribeFieldResult fieldResult = Account.BillingCountrycode.getDescribe();
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
        Schema.DescribeFieldResult fieldResult = Account.BillingStateCode.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();        
        stateOptions = new List<SelectOption>();
        stateOptions.add(new SelectOption('', '--None--'));
        for( Schema.PicklistEntry picklistEntry : picklistEntries)
        {
            stateOptions.add(new SelectOption( picklistEntry.getValue(), picklistEntry.getLabel()));
        }
        return stateOptions;
    }
    
    
}