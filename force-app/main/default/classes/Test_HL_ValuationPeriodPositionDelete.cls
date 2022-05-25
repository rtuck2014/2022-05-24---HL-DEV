@isTest
Private class Test_HL_ValuationPeriodPositionDelete {
    
    @testSetup 
    static void setup() {
        
        
        List<Account> accountList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 2);        
        for(integer i = 0; i < accountList.size(); i++){
            accountList[i].Name = 'Test_Account' +i;        
            accountList[i].BillingCountry = 'United States';
            accountList[i].BillingState = 'California';
            accountList[i].ShippingCountry = accountList[i].BillingCountry;
            accountList[i].ShippingState = accountList[i].BillingState;
        }
        
        insert accountList;
        
        List<Contact> CList = (List<Contact>)HL_TestFactory.CreateSObjectList('Contact', false, 2);        
        for(integer i = 0; i < CList.size(); i++){
            CList[i].FirstName = 'TestFirst' +i;
            CList[i].LastName = 'TestLast' +i;
            CList[i].AccountId = accountList[0].id;
        }
        Insert CList; 
        
        Engagement__c Engagement =(Engagement__c)HL_TestFactory.CreateSObject('Engagement__c',false);        
        Engagement.Name='Test_Engagement';
        Engagement.Client__c = accountList[0].Id;
        Engagement.Subject__c = accountList[0].Id;
        Engagement.Stage__c = 'Pitched';
        Engagement.Line_of_Business__c = 'CF';
        Engagement.Job_Type__c = 'Financing';
        Engagement.Primary_Office__c = 'AT';
        insert Engagement;
        
        List<Eng_VP__c> EngVPList = (List<Eng_VP__c>)HL_TestFactory.CreateSObjectList('Eng_VP__c',false,2);
        for(integer i = 0; i < EngVPList.size(); i++){
            EngVPList[i].Name='Test_Engagement_VP'+i;        
            EngVPList[i].Engagement__c=Engagement.id;
            EngVPList[i].Valuation_Date__c=System.Today();
            EngVPList[i].CurrencyIsoCode='USD';    
        }
        Insert EngVPList; 
        
        
        List<Eng_VP_Position__c> EngVPPosList = (List<Eng_VP_Position__c>)HL_TestFactory.CreateSObjectList('Eng_VP_Position__c',false,2);
        for(integer i = 0; i < EngVPPosList.size(); i++){
            EngVPPosList[i].Report_Fee__c=100;
            EngVPPosList[i].Asset_Classes__c='Debt';
            EngVPPosList[i].CurrencyIsoCode='USD';
            EngVPPosList[i].Engagement_VP__c=EngVPList[i].Id;
            EngVPPosList[i].Company__c=accountList[i].Id;
        }
        insert EngVPPosList; 
    }
    
    @isTest
    static void testBackAndDelete() {
        
        List<Eng_VP_Position__c> EngVPPosList = [select id, Name from Eng_VP_Position__c];
        List<Eng_VP__c> EngVPList = [select id, Name from Eng_VP__c];
        System.currentPageReference().getParameters().put('id',EngVPPosList[0].id) ;
        System.currentPageReference().getParameters().put('sObjectName', 'Eng_VP_Position__c');
        System.currentPageReference().getParameters().put('ReturnID', EngVPList[0].id);
        
        HL_ValuationPeriodPositionDeleteClass  clsObj = new HL_ValuationPeriodPositionDeleteClass();
        clsObj.Back();
        clsObj.onDelete();
    }
}