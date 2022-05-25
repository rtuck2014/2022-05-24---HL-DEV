@isTest
private class Test_HL_AutoCompleteController {
    @isTest 
    private static void TestGetSuggestionsFunctionality(){
        Contact externalContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        Contact employeeContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        externalContactRecord.FirstName = employeeContactRecord.FirstName = 'Test';
        externalContactRecord.LastName = employeeContactRecord.LastName = 'Test';
        insert externalContactRecord;
        insert employeeContactRecord;
        
        Test.startTest();
        
        List<sObject> singleTermExternalResultList = HL_AutoCompleteController.GetSuggestions('Contact','External','Test','Title','',1);
        List<sObject> multiTermExternalResultList = HL_AutoCompleteController.GetSuggestions('Contact','External','Test Test','Title','',1);
        List<sObject> singleTermEmployeeResultList = HL_AutoCompleteController.GetSuggestions('Contact','Employee','Test','Title','',1);
        
        Test.stopTest();
        
        System.assert(singleTermExternalResultList.size() == 1);
        System.assert(multiTermExternalResultList.size() == 1);
        System.assert(singleTermEmployeeResultList.size() == 1);
    }
}