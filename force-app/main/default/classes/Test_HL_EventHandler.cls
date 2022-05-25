@isTest
private class Test_HL_EventHandler {
    @testSetup
    private static void CreateData() {
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        insert c;
    }

    @isTest private static void TestAfterInsert() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        List<Event> eList = SL_TestSetupUtils.CreateEvent('', 2);

        for (Event e : eList) {
            e.StartDateTime = System.now();
            e.EndDateTime = e.StartDateTime;
            e.Start_Date__c = System.today();
            e.Start_Time__c = '12:00 AM';
            e.End_Date__c = System.today();
            e.End_Time__c = '12:00 AM';
            e.DurationInMinutes = 0;
            e.isFollowup__c = true;
            e.Followup_Start_Date__c = System.today();
            e.Followup_Start_Time__c = '12:00 AM';
            e.Followup_End_Date__c = System.today();
            e.Followup_End_Time__c = '12:00 AM';
            e.WhoId = c.Id;
        }

        Test.startTest();

        insert eList;

        Test.stopTest();

        //Verify the Events were Inserted
        System.assertEquals(2, [SELECT Id FROM Event].size());
    }

    @isTest private static void TestAfterDelete() {
        //Setup test data
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        List<Event> eList = SL_TestSetupUtils.CreateEvent('', 2);

        for (Event e : eList) {
            e.StartDateTime = System.now();
            e.EndDateTime = e.StartDateTime;
            e.Start_Date__c = System.today();
            e.Start_Time__c = '12:00 AM';
            e.End_Date__c = System.today();
            e.End_Time__c = '12:00 AM';
            e.DurationInMinutes = 0;
            e.isFollowup__c = true;
            e.Followup_Start_Date__c = System.today();
            e.Followup_Start_Time__c = '12:00 AM';
            e.Followup_End_Date__c = System.today();
            e.Followup_End_Time__c = '12:00 AM';
            e.WhoId = c.Id;
        }
        insert eList;

        Test.startTest();

        delete eList;

        Test.stopTest();

        //Verify the Events were Deleted
        System.assertEquals(0, [SELECT Id FROM Event].size());
    }
}