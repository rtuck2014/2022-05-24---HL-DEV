@isTest
private class Test_HL_SpecialProject {
    @isTest private static void TestDataRetrieval(){
        final integer SPECIAL_PROJECT_RECORDS = 10;
        List<Special_Project__c> spInsertList = SL_TestSetupUtils.CreateSpecialProject('',SPECIAL_PROJECT_RECORDS);
        string timeRecordCategory = HL_TimeRecordController.GetCategory();
        if(String.isBlank(timeRecordCategory))
            timeRecordCategory = 'FR';
        Id spRecordTypeId = Schema.sObjectType.Special_Project__c.getRecordTypeInfosByName().get(timeRecordCategory).getRecordTypeId();
        for(Special_Project__c sp : spInsertList)
            sp.RecordTypeId = spRecordTypeId;
        insert spInsertList;
        Id recordTypeId = Schema.SObjectType.Special_Project__c.getRecordTypeInfosByName().get(timeRecordCategory).getRecordTypeId();
        
        Test.startTest();
        	List<Special_Project__c> getAllResults = HL_SpecialProject.GetAll();
        	List<Special_Project__c> getByRecordTypeIdResults = HL_SpecialProject.GetByRecordTypeId(recordTypeId);
        Test.stopTest();
        
        //Validate the results returned
        System.assertEquals(SPECIAL_PROJECT_RECORDS, getAllResults.size());
        System.assertEquals(SPECIAL_PROJECT_RECORDS, getByRecordTypeIdResults.size());
    }
}