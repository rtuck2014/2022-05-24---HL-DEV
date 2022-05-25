@isTest
private class Test_HL_Lookup {
    @isTest private static void TestBasicFunctionality(){
        //Setup Test Data
        Lookup__c l = new Lookup__c(Lookup_Group__c = 'Test');
        insert l;
        
        HL_Lookup lookup = new HL_Lookup(new HL_CompanyHomeController());
        List<Lookup__c> lList = HL_Lookup.GetByGroup('Test');
        System.Assert(lList.size() == 1);
        List<Lookup__c> cList = HL_Lookup.LookupCountry('Test');
        System.Assert(cList.size() == 0);
        
    }	
}