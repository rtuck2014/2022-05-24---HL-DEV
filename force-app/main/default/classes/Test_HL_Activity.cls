@isTest
private class Test_HL_Activity {
    @isTest 
    private static void TestBasicFunctionality(){
        Contact contactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        contactRecord.FirstName = 'Test';
        contactRecord.LastName = 'Contact';
        insert contactRecord;
        List<Event> eventList = (List<Event>)HL_TestFactory.CreateSObjectList('Event', false, 2);
        for(Event eventRecord : eventList){
            eventRecord.StartDateTime = System.now();
            eventRecord.EndDateTime = eventRecord.StartDateTime;
            eventRecord.Start_Date__c = System.today();
            eventRecord.Start_Time__c = '12:00 AM';
            eventRecord.End_Date__c = System.today();
            eventRecord.End_Time__c = '12:00 AM';
            eventRecord.DurationInMinutes = 0;
            eventRecord.isFollowup__c = true;
            eventRecord.Followup_Start_Date__c = System.today();
            eventRecord.Followup_Start_Time__c = '12:00 AM';
            eventRecord.Followup_End_Date__c = System.today();
            eventRecord.Followup_End_Time__c = '12:00 AM';
            eventRecord.WhoId = contactRecord.Id;
        }        
        
        Test.startTest();
        
        HL_Activity activity = new HL_Activity();
        
        //Test Properties
        activity.LinkId = eventList[0].Id;
        activity.PrimaryAttendee = contactRecord.Name;
        activity.ModifyAccess = false;
        activity.ViewAccess = false;
        activity.PrimaryContact = contactRecord.Name;
        activity.PrimaryContactId = contactRecord.Id;
        
        //Test Other Class Methods
        activity.Activity = eventList[0];
        activity.Activity.ActivityDate = Date.today();
        String formattedStart = activity.FormattedStart;
        String formattedEnd = activity.FormattedEnd;
        
        //Verify the sort/compare is working
        HL_Activity activityToCompare = new HL_Activity();
        activityToCompare.Activity = activity.Activity;
        activityToCompare.Activity.ActivityDate = activity.Activity.ActivityDate.addDays(1);
        
        Test.stopTest();
        
        //Validate the Properties
        System.assertEquals(contactRecord.Name, activity.PrimaryAttendee);
        System.assertEquals(false, activity.ModifyAccess);
        System.assertEquals(contactRecord.Name, activity.PrimaryContact);
        System.assertEquals(contactRecord.Id, activity.PrimaryContactId);
        System.assertEquals(eventList[0].Id, activity.LinkId);
        System.assertEquals(-1, activity.compareTo(activityToCompare));
    }
}