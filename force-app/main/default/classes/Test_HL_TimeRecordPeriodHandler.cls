@isTest
private class Test_HL_TimeRecordPeriodHandler {
    @isTest 
    private static void TestAfterInsertCreationOfTimeRecordPeriodStaffMemberRecords(){
        Time_Record_Period__c periodRecord = (Time_Record_Period__c)HL_TestFactory.CreateSObject('Time_Record_Period__c', false);
        periodRecord.Start_Date__c = Date.today();
        periodRecord.End_Date__c = Date.today().addDays(6);
        periodRecord.Period_Category__c = 'Litigation';

        Test.startTest();

        insert periodRecord;

        Test.stopTest();

        //Validate the any staff members in the group now have a time record period staff member record
        Time_Record_Period__c periodResult = [SELECT Public_Group__c FROM Time_Record_Period__c WHERE Id=:periodRecord.Id];
        HL_Group groupRecord = new HL_Group(periodResult.Public_Group__c);
		List<Contact> staffMemberList = groupRecord.GetContacts();
        List<Time_Record_Period_Staff_Member__c> periodStaffMemberList = [SELECT Id FROM Time_Record_Period_Staff_Member__c WHERE Time_Record_Period__c =: periodResult.Id];
        System.assertEquals(staffMemberList.size(), periodStaffMemberList.size());
    }
}