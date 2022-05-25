@isTest
private class Test_HL_Batch_OffsiteTemplateArchive {
    @isTest private static void TestArchiveRecords(){
        //Setup Test Data
        HL_General__c hl = new HL_General__c();
        hl.Offsite_Archive_Date__c = Date.today();
        insert hl;
        List<Offsite_Template__c> otList = SL_TestSetupUtils.CreateOffsiteTemplateDataWithRelated(1,5);
        Id recordTypeId = otList[0].RecordTypeId;
        otList[0].FYE_Date__c = Date.today().addYears(-2);
        update otList;
        System.Debug(otList[0].Archive__c);
        Test.startTest();
        	HL_Batch_OffsiteTemplateArchive batch = new HL_Batch_OffsiteTemplateArchive();
        	Database.executeBatch(batch, 200); 
        Test.stopTest();
        System.assertNotEquals([SELECT RecordTypeId FROM Offsite_Template__c WHERE Id =: otList[0].Id].RecordTypeId, recordTypeId);
    }
}