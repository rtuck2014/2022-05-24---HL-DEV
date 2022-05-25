public class HL_ContactNewController {
    public Integer Action{get; set;}
    public enum NewAction{
        Standard,
        Quick
    }
    
    // Initialize a variable to hold the contact record you're processing
    private final Contact contact;    
    public String errorDuplicateText{get;set;}
    
    // Initialize a list to hold any duplicate records
    public List<sObject> duplicateRecords;    
    // Define variable that’s true if there are duplicate records
    public boolean hasDuplicateResult{get;set;}
    
    public ApexPages.StandardController Con {get; set;}
    public Account ExistingAccount {get; set;}
    public Contact NewContact {get; set;}
    
    //Added as part of State/Country Picklist
    public List<SelectOption> countryOptions = new List<SelectOption>();
    public List<SelectOption> stateOptions = new List<SelectOption>();
    public Map<String,List<HL_PickListUtil.dependentPicklistWrapper>> countryStateMap = new Map<String,List<HL_PickListUtil.dependentPicklistWrapper>>();
    public string selectedCountry{get;set;}
    public String jsonMap{get;set;}
    public Boolean executePostalCodeLookup{get;set;}
     
    public HL_ContactNewController(ApexPages.StandardController controller){
        
        Map<String, String> q = ApexPages.currentPage().getParameters();
        if(q.containsKey('accId'))
                ExistingAccount = HL_Company.GetById(q.get('accId'));
                system.debug('existingAccount>>>>'+ExistingAccount);
        if(q.containsKey('action'))
          Action = Integer.valueOf(q.get('action'));
        if(controller.getRecord() <> null)
            NewContact = (Contact)controller.getRecord();
        Con = controller; 
        
        this.duplicateRecords = new List<sObject>();
        this.hasDuplicateResult = false;        
        
        //Added as part of State/Country Picklist
        Schema.DescribeFieldResult controllingFieldDescribe = Account.BillingCountryCode.getDescribe();
        Schema.sObjectField countryField = controllingFieldDescribe.getSObjectField();
        
        Schema.DescribeFieldResult dependentFieldDescribe = Account.BillingStateCode.getDescribe();
        Schema.sObjectField stateField = dependentFieldDescribe.getSObjectField();        
        this.countryStateMap = HL_PicklistUtil.getDependentOptionsImpl(stateField, countryField);
        jsonMap=JSON.serialize(countryStateMap); 
        executePostalCodeLookup = [SELECT DeveloperName, Enabled__c FROM Trigger_Setting__mdt WHERE DeveloperName = 'Postal_Code_Lookup'].Enabled__c;
        //Added as part of State/Country Picklist
    }
    
    
    public List<sObject> getDuplicateRecords() {
        return this.duplicateRecords;
    }
    
    public PageReference SaveAndView(){
        if(SaveRecord())
                return Action <> 1 ? new PageReference('/' + NewContact.Id) : null;
        else
            return null;
    }
    public PageReference SaveAndIgnore(){
        try{
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;        
            NewContact = (Contact)Con.getRecord();                        
            Database.SaveResult sr2 = Database.insert(NewContact, dml);
            return Action <> 1 ? new PageReference('/' + NewContact.Id) : null;        
        }catch(DmlException ex){            
             HL_PageUtility.ShowError(ex);
             return null;
         }
      
    }
    
    public PageReference saveAndNew() {        
         try{
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;        
            NewContact = (Contact)Con.getRecord();                        
            Database.SaveResult sr2 = Database.insert(NewContact, dml);
            string s = '/' + ('' + NewContact.get('Id')).subString(0, 3) + '/e?';            
            return new Pagereference(s);             
        }catch(DmlException ex){            
             HL_PageUtility.ShowError(ex);
             return null;
         }
    
        return null;
    }
    public Boolean SaveRecord(){       
        NewContact = (Contact)Con.getRecord();
        Database.SaveResult saveResult = Database.insert(NewContact, false);

        if (!saveResult.isSuccess()) {
            for (Database.Error error : saveResult.getErrors()) {
                // If there are duplicates, an error occurs
                // Process only duplicates and not other errors 
                //   (e.g., validation errors)
                if (error instanceof Database.DuplicateError) {
                    // Handle the duplicate error by first casting it as a 
                    //   DuplicateError class
                    // This lets you use methods of that class 
                    //  (e.g., getDuplicateResult())
                    Database.DuplicateError duplicateError = 
                            (Database.DuplicateError)error;
                    Datacloud.DuplicateResult duplicateResult = 
                            duplicateError.getDuplicateResult();
                    
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
                        this.duplicateRecords.add(matchRecord.getRecord());                        
                    }
                    // Display duplicate error message as defined in the duplicate rule                    
                    errorDuplicateText = this.duplicateRecords.size() +' Possible Duplicate Records Found.<br/>' + duplicateResult.getErrorMessage();
                    this.hasDuplicateResult = !this.duplicateRecords.isEmpty();
                    
                    //duplicateRecords.get
                    //SObjectType  ax = duplicateRecords.getSObjectType(); //Schema.getGlobalDescribe().get(duplicateRecords);
                    //Map<String,Schema.SObjectField> mfields = ax.getDescribe().fields.getMap();
                    //for(Id key: mfields.keySet()){
                    //    errorDuplicateText = errorDuplicateText + mfields.get(key);
                    //}
                }
            }
            
            //If there’s a duplicate record, stay on the page
            return false;
        }
        
        //  After save, navigate to the view page:
        return  true;//(new ApexPages.StandardController(NewContact)).view();
        
    }
    public PageReference RedirectCheck(){
        Map<String, String> q = ApexPages.currentPage().getParameters();
        if(q.containsKey('RecordType') && q.get('RecordType') == HL_Utility.GetRecordTypeId('Houlihan Employee'))
            return null;
        else 
            return null;
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