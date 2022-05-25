public with sharing class HL_CapIQCloneController {
    public Id capIQId;
    public CapIQ_Company__c capIQData {get; set;}
    public List<Account> relatedAccounts;
    public Account newAcc{get; set;}
    
    //constructor to overwrite Account fields for prefill
    public HL_CapIQCloneController (ApexPages.StandardController controller){
        newAcc =  new Account();
       	capIQId = Apexpages.currentPage().getParameters().get('capiqId'); //capiqId is passed in via the URL button
       	capIQData = [SELECT Id, Name, Street_Address__c, StreetAddress_2__c, StreetAddress3__c, StreetAddress4__c, City__c, State__c, Postal_Code__c, 
                		Country__c, Phone__c, Fax__c, Website__c, Business_Description__c, Ticker_Symbol__c
               		FROM CapIQ_Company__c WHERE Id = :capIQId];

       	//small list and loop to handle null string concatenation
        String accAddress = '';
        List<String> addressParts = new List<String>{capIQData.Street_Address__c, capIQData.StreetAddress_2__c, capIQData.StreetAddress3__c, capIQData.StreetAddress4__c};

        for(String s : addressParts){
            if(s != null){
                accAddress += s + ' ';
            }
        }

        newAcc.Name = capIQData.Name;
        newAcc.BillingStreet = accAddress.trim(); //final string used here, trim leading and trialing space chars
        newAcc.BillingCity = capIQData.City__c;
        newAcc.BillingState = capIQData.State__c;
        newAcc.BillingPostalCode = capIQData.Postal_Code__c;
        newAcc.BillingCountry = capIQData.Country__c;
        newAcc.Phone = capIQData.Phone__c;
        newAcc.Fax = capIQData.Fax__c;
        newAcc.Website = capIQData.Website__c;
        newAcc.Description = capIQData.Business_Description__c;
        newAcc.TickerSymbol = capIQData.Ticker_Symbol__c;
        newAcc.CapIQ_Company__c = capIQData.Id;
        newAcc.RecordTypeId = '012i0000000tEhFAAU'; //I don't like this because it's hardcoded, but this is an easy way to set default selection as Capital Provider
    }
    
    //get all Account Record Types to display as picklist values
    public List<SelectOption> getRecordTypes(){
        List<SelectOption> options = new List<SelectOption>();
        for(RecordType r : [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Account' AND (Name = 'Capital Provider' OR Name = 'Operating Company')]){
            options.add(new SelectOption(r.Id, r.Name));
        }
        return options;
    }

    //Cancel and back functionality
    public PageReference cancel(){
        PageReference p = new PageReference('/' + capIQId);
        return p;
    }

    public PageReference save(){
        insert newAcc;
        PageReference p = new PageReference('/' + newAcc.Id);
        return p;
    }
    
    //match and return possible Accounts for User review
    public List<Account> getrelatedAccounts(){
    	return [SELECT Id, Name, RecordType.Name, CapIQ_Company__c, CapIQ_ID__c, Company_Name_URL__c, BillingStreet, BillingCity, BillingState, BillingCountry 
                FROM Account 
                WHERE CapIQ_Company__c = :capIQId AND Name = :capIQData.Name
                ORDER BY Name];
    }
}