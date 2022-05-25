@isTest
private class Test_HL_TimeRecordPeriodSMController {
    @isTest private static void TestGetCurrentRecord(){
        Time_Record__c tr = SL_TestSetupUtils.CreateTimeRecordsWithRelated(1, 'Litigation')[0];
        
        Test.startTest();
        	Time_Record_Period_Staff_Member__c trpsm = HL_TimeRecordPeriodStaffMemberController.GetCurrentRecord('Litigation');
        Test.stopTest();
        
        //Validate the result
        System.assertEquals(tr.Time_Record_Period_Staff_Member__c, trpsm.Id);
    }
    
    @isTest private static void TestGetByPeriod(){
        Time_Record__c tr = SL_TestSetupUtils.CreateTimeRecordsWithRelated(1, 'Litigation')[0];

        Test.startTest();
        	List<Time_Record_Period_Staff_Member__c> trpsm = HL_TimeRecordPeriodStaffMemberController.GetByPeriod('Litigation', tr.Time_Record_Period_Staff_Member__r.Time_Record_Period__c);
        	List<Time_Record_Period_Staff_Member__c> trpsmNoPeriod = HL_TimeRecordPeriodStaffMemberController.GetByPeriod('Litigation', null);
        Test.stopTest();
        
        //Validate results are returned
        System.assert(trpsm != null);
        System.assert(trpsmNoPeriod != null);
    }

    @isTest private static void TestGetCategory(){
        Test.startTest();
        	String category = HL_TimeRecordPeriodStaffMemberController.GetCategory();
        Test.stopTest();
        
        //Validate a category is returned or blank if user is not assigned
        System.assert(category != null);
    }
}