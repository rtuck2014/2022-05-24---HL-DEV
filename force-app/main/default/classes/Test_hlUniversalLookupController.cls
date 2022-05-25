@isTest
private class Test_hlUniversalLookupController {
    @isTest static void hlBasicTest(){
        Account a = SL_TestSetupUtils.CreateAccount('Test_Houlihan', 1)[0];
        a.Ownership = 'Private';
        insert a;
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('Test_Houlihan', 1)[0];
        e.RecordTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Sellside').getRecordTypeId();
        e.Client__c = a.Id;
        e.Subject__c = a.Id;
        insert e;
        system.debug('Engagement__c-e' + e);
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = e.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        Test.startTest();
            String objectApi = 'Engagement__c'; 
            String filter = 'Test_Houlihan0'; 
            List<String> fields = new List<String>{'Id','Name'};
            String sortField = 'Name';
            String sortDirection = 'ASC';
            List<SObject> lookupData = hlUniversalLookupController.getLookupSearch(objectApi,filter,fields,sortField,sortDirection,'5');
            system.debug('lookupData1' + lookupData.size());
        Test.stopTest();
        //System.assert(lookupData.size() > 0);
    }
}