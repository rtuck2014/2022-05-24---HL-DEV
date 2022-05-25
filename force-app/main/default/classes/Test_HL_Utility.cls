@isTest
private class Test_HL_Utility {
    @isTest private static void TestGetPicklistValues(){
        Test.startTest();
        	List<String> picklistValueList = HL_Utility.GetPicklistValues('Contact', 'Office__c');
        	List<String> picklistValueListByRecordType = HL_Utility.GetPicklistValues('Contact', 'Office__c','HL Employee'); 
        Test.stopTest();
        
        //Validate the picklist values are returned
        System.assert(picklistValueList.size() > 0);
        System.assert(picklistValueListByRecordType.size() > 0);
    }
}