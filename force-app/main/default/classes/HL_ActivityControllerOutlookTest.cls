@isTest
private class HL_ActivityControllerOutlookTest {
    @testSetup
    private static void SetupEventData(){
        Contact employeeContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        employeeContactRecord.User__c = UserInfo.getUserId();
        insert employeeContactRecord; 
        
        Contact additionalEmployeeContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        insert additionalEmployeeContactRecord; 
        
        Account accountRecord = (Account)HL_TestFactory.CreateSObject('Account', false);
        accountRecord.Name = 'Test Account 01';
        insert accountRecord;
        
        Contact externalContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        externalContactRecord.AccountId = accountRecord.Id;
        insert externalContactRecord;
        
        Opportunity__c opportunityRecord = (Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c', false);
        insert opportunityRecord;

        Engagement__c engagementRecord = (Engagement__c)HL_TestFactory.CreateSObject('Engagement__c', false);
        engagementRecord.Name = 'Hardcode Name';
        insert engagementRecord;
        
        /*Campaign campaignRecord = (Campaign)HL_TestFactory.CreateSObject('Campaign', false);
    campaignRecord.Name = 'testName'; //we're hardcoding this line to help with deployment errors -AYU 2/27/2017         
        insert campaignRecord;*/
        
        List<Event> eventList = (List<Event>)HL_TestFactory.CreateSObjectList('Event', false, 6);
        for(Event eventRecord : eventList){
            eventRecord.Subject = 'Event';
            eventRecord.StartDateTime = System.now().addDays(eventList.size());
            eventRecord.EndDateTime = eventRecord.StartDateTime;
            eventRecord.Start_Date__c = System.today().addDays(eventList.size());
            eventRecord.Start_Time__c = '12:00 AM';
            eventRecord.End_Date__c = System.today().addDays(eventList.size());
            eventRecord.End_Time__c = '12:00 AM';
            eventRecord.Primary_External_Contact_Id__c = externalContactRecord.Id;
            eventRecord.Primary_Attendee_Id__c = employeeContactRecord.Id;
        }
        
        Event eventParentRecord = eventList[0];
        eventParentRecord.Type = 'Meeting';
        eventParentRecord.WhoId = employeeContactRecord.Id;
        insert eventParentRecord;

        Event eventChildEmployeeRecord = eventList[1];
        eventChildEmployeeRecord.Type = 'Meeting';
        eventChildEmployeeRecord.WhoId = employeeContactRecord.Id;
        eventChildEmployeeRecord.ParentId__c = eventParentRecord.Id;
        insert eventChildEmployeeRecord;

        Event eventChildExternalRecord = eventList[2];
        eventChildExternalRecord.Type = 'Meeting';
        eventChildExternalRecord.WhoId = externalContactRecord.Id;
        eventChildExternalRecord.ParentId__c = eventParentRecord.Id;
        insert eventChildExternalRecord;

        Event eventChildAccountRecord = eventList[3];
        eventChildAccountRecord.Type = 'Meeting';
        eventChildAccountRecord.WhatId = accountRecord.Id;
        eventChildAccountRecord.ParentId__c = eventParentRecord.Id;
        insert eventChildAccountRecord;

        Event eventChildOpportunityRecord = eventList[4];
        eventChildOpportunityRecord.Type = 'Meeting';
        eventChildOpportunityRecord.WhatId = opportunityRecord.Id;
        insert eventChildOpportunityRecord;

        Event eventChildEngagementRecord = eventList[5];
        eventChildEngagementRecord.Type = 'Meeting';
        eventChildEngagementRecord.WhatId = engagementRecord.Id;
        insert eventChildEngagementRecord;
        
        /*Id internalEventRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Event eventInternalParentRecord = eventList[6];
        eventInternalParentRecord.Type = 'Internal';
        eventInternalParentRecord.WhoId = employeeContactRecord.Id;
        eventInternalParentRecord.RecordTypeId = internalEventRecordTypeId;
        insert eventInternalParentRecord;
        Event eventInternalChildEmployeeRecord = eventList[7];
        eventInternalChildEmployeeRecord.Type = 'Internal';
        eventInternalChildEmployeeRecord.WhoId = employeeContactRecord.Id;
        eventInternalChildEmployeeRecord.RecordTypeId = internalEventRecordTypeId;
        insert eventInternalChildEmployeeRecord;
        Event eventInternalChildExternalRecord = eventList[8]; 
        eventInternalChildExternalRecord.Type = 'Internal';
        eventInternalChildExternalRecord.WhoId = additionalEmployeeContactRecord.Id;
        eventInternalChildExternalRecord.RecordTypeId = internalEventRecordTypeId;
        insert eventInternalChildExternalRecord;
        Event eventInternalMemberChildExternalRecord = eventList[9]; 
        eventInternalMemberChildExternalRecord.Type = 'Internal Mentor Meeting';
        eventInternalMemberChildExternalRecord.WhoId = additionalEmployeeContactRecord.Id;
        eventInternalMemberChildExternalRecord.RecordTypeId = internalEventRecordTypeId;
        insert eventInternalMemberChildExternalRecord; */
        
    }
    
    @isTest 
    private static void TestExternalContactEventInitialization(){
        Contact contactRecord = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'External_Contact' LIMIT 1];
        
        Test.setCurrentPageReference(Page.HL_ActivityEventView);
        ApexPages.currentPage().getParameters().put('Id',contactRecord.Id);
        
        Test.startTest();
        
        HL_ActivityControllerOutlook activityController = new HL_ActivityControllerOutlook();
        activityController.Activity.StartDateTime = System.now();
        activityController.Activity.EndDateTime = System.now();
        Id userContactId = activityController.UserContactRecord.Id;
        string entityId = activityController.EntityId;
        string entityType = activityController.EntityType;
        string returnEntity = activityController.RetEntity;
        string formattedStart = activityController.FormattedStart;
        string formattedEnd = activityController.FormattedEnd;
        Activity_Supplement__c activitySupplement = activityController.ActivitySupplement;
        
        Test.stopTest();
        
        //Validate the Property Initializations
        System.assert(!String.isBlank(userContactId));
        System.assertEquals(contactRecord.Id, entityId);
        System.assertEquals('Contact', entityType);
        System.assertEquals(contactRecord.Id, returnEntity);
        System.assert(!String.isBlank(formattedStart));
        System.assert(!String.isBlank(formattedEnd));
        System.assert(activitySupplement != null);
    }
    
    @isTest 
    private static void TestAccountEventInitialization(){
        Account accountRecord = [SELECT Id FROM Account LIMIT 1];
        
        Test.setCurrentPageReference(Page.HL_ActivityEventView);
        ApexPages.currentPage().getParameters().put('Id',accountRecord.Id);
        
        Test.startTest();
        
        HL_ActivityControllerOutlook activityController = new HL_ActivityControllerOutlook();
        activityController.Activity.StartDateTime = System.now();
        activityController.Activity.EndDateTime = System.now();
        Id userContactId = activityController.UserContactRecord.Id;
        string entityId = activityController.EntityId;
        string entityType = activityController.EntityType;
        string returnEntity = activityController.RetEntity;
        string formattedStart = activityController.FormattedStart;
        string formattedEnd = activityController.FormattedEnd;
        Activity_Supplement__c activitySupplement = activityController.ActivitySupplement;
        
        Test.stopTest();
        
        //Validate the Property Initializations
        System.assert(!String.isBlank(userContactId));
        System.assertEquals(accountRecord.Id, entityId);
        System.assertEquals('Account', entityType);
        System.assertEquals(accountRecord.Id, returnEntity);
        System.assert(!String.isBlank(formattedStart));
        System.assert(!String.isBlank(formattedEnd));
        System.assert(activitySupplement != null);
    }
    
    @isTest
    private static void TestEventCreation(){
        Contact contactRecord = [SELECT Name FROM Contact WHERE RecordType.DeveloperName = 'External_Contact' LIMIT 1];
        Contact employeeRecord = [SELECT Name FROM Contact WHERE RecordType.DeveloperName = 'Houlihan_Employee' AND User__c =: UserInfo.getUserId() LIMIT 1];
        Account accountRecord = [SELECT Name FROM Account LIMIT 1];
        //Campaign campaignRecord = [SELECT Name FROM Campaign LIMIT 1];
        Opportunity__c opportunityRecord = [SELECT Name FROM Opportunity__c LIMIT 1];
        Engagement__c engagementRecord = [SELECT Name, Id FROM Engagement__c LIMIT 1];
        Contact newExternalContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        insert newExternalContactRecord;
        
        Test.setCurrentPageReference(Page.HL_ActivityEvent);
        ApexPages.currentPage().getParameters().put('related_Id',contactRecord.Id);
        ApexPages.currentPage().getParameters().put('retURL',contactRecord.Id);
        
        Test.startTest();
        
        HL_ActivityControllerOutlook activityController = new HL_ActivityControllerOutlook();
        List<String> activityTypes = HL_ActivityControllerOutlook.GetActivityTypes();
        List<String> followupTypes = HL_ActivityControllerOutlook.GetFollowupTypes();
        
        activityController.Activity.Type = activityTypes[0];
        
        activityController.OnActivityTypeChanged();
        
        //Add HL Employee Record
        activityController.SelectedEmployeeId = employeeRecord.Id;
        activityController.AddEmployee();
        
        //Add a New External Contact Record
        activityController.SelectedContactId = newExternalContactRecord.Id;
        activityController.AddContact();
        
        //Associate a Company/Account Record
        activityController.SelectedAccountId = accountRecord.Id;
        activityController.AddCompany();
        
        //Associate an Opportunity Record
        activityController.SelectedOpportunityId = opportunityRecord.Id;
        activityController.AddOpportunity();

        //Associate an Engagement Record
        activityController.SelectedEngagementId = engagementRecord.Id;
        activityController.AddEngagement();
        
        PageReference saveResult = activityController.SaveRecord();
        PageReference saveResult1 = activityController.saveRec();
        
        boolean hasViewAccess = activityController.HasViewAccess;
        boolean hasLimitedModifyAccess = activityController.HasLimitedModifyAccess;
        boolean hasModifyAccess = activityController.HasModifyAccess;
        List<Event> existingRelatedEvents = activityController.ExistingRelatedEvents;
        
        Test.stopTest();
        
        System.assert(saveResult.getUrl().containsIgnoreCase(contactRecord.Id));
    }
    
    
    @isTest
    private static void TestEventCreation2(){
        Contact contactRecord = [SELECT Name FROM Contact WHERE RecordType.DeveloperName = 'External_Contact' LIMIT 1];
        Contact employeeRecord = [SELECT Name FROM Contact WHERE RecordType.DeveloperName = 'Houlihan_Employee' AND User__c =: UserInfo.getUserId() LIMIT 1];
        Account accountRecord = [SELECT Name FROM Account LIMIT 1];
        //Campaign campaignRecord = [SELECT Name FROM Campaign LIMIT 1];
        Opportunity__c opportunityRecord = [SELECT Name FROM Opportunity__c LIMIT 1];
        Engagement__c engagementRecord = [SELECT Name, Id FROM Engagement__c LIMIT 1];
        Contact newExternalContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        insert newExternalContactRecord;
        
        Test.setCurrentPageReference(Page.HL_ActivityEvent);
        ApexPages.currentPage().getParameters().put('related_Id',contactRecord.Id);
        ApexPages.currentPage().getParameters().put('retURL',contactRecord.Id);
        
        Test.startTest();
        
        HL_ActivityControllerOutlook activityController = new HL_ActivityControllerOutlook();
        List<String> activityTypes = HL_ActivityControllerOutlook.GetActivityTypes();
        List<String> followupTypes = HL_ActivityControllerOutlook.GetFollowupTypes();
        
        activityController.Activity.Type = 'Internal Mentor Meeting';
        
        activityController.OnActivityTypeChanged();
        
        //Add HL Employee Record
        activityController.SelectedEmployeeId = employeeRecord.Id;
        activityController.AddEmployee();
        
        //Add a New External Contact Record
        activityController.SelectedContactId = newExternalContactRecord.Id;
        activityController.AddContact();
        
        //Associate a Company/Account Record
        activityController.SelectedAccountId = accountRecord.Id;
        activityController.AddCompany();
        
        //Associate an Opportunity Record
        activityController.SelectedOpportunityId = opportunityRecord.Id;
        activityController.AddOpportunity();

        //Associate an Engagement Record
        activityController.SelectedEngagementId = engagementRecord.Id;
        activityController.AddEngagement();
        
        PageReference saveResult = activityController.SaveRecord();
        PageReference saveResult1 = activityController.saveRec();
        
        activityController.Activity.Type = 'Internal Mentor Meeting';
        activityController.Activity.DurationInMinutes = 10;
       activityController.Activity.ActivityDateTime = System.Now();
         insert activityController.Activity;
        
        boolean hasViewAccess = activityController.HasViewAccess;
        boolean hasLimitedModifyAccess = activityController.HasLimitedModifyAccess;
        boolean hasModifyAccess = activityController.HasModifyAccess;
        List<Event> existingRelatedEvents = activityController.ExistingRelatedEvents;
        
        Test.stopTest();
        
        System.assert(saveResult.getUrl().containsIgnoreCase(contactRecord.Id));
    }
    
    @isTest
    private static void TestEventRelatedListRemovals(){
        Contact contactRecord = [SELECT Name FROM Contact WHERE RecordType.DeveloperName = 'External_Contact' LIMIT 1];
        Contact employeeRecord = [SELECT Name FROM Contact WHERE RecordType.DeveloperName = 'Houlihan_Employee' AND User__c =: UserInfo.getUserId() LIMIT 1];
        Account accountRecord = [SELECT Name FROM Account LIMIT 1];
        Opportunity__c opportunityRecord = [SELECT Name FROM Opportunity__c LIMIT 1];
        Engagement__c engagementRecord = [SELECT Name, Id FROM Engagement__c LIMIT 1];
        Contact newExternalContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        insert newExternalContactRecord;
        Event eventRecord = [SELECT WhoId, Type, Subject, StartDateTime, EndDateTime, Start_Date__c, Start_Time__c, 
                             End_Date__c, End_Time__c, IsFollowup__c, Followup_Type__c, Followup_Start_Date__c,
                             Followup_Start_Time__c, Followup_End_Date__c, Followup_End_Time__c,Primary_External_Contact_Company_Id__c,Primary_External_Contact_Company__c,
                             PFG__c,ParentId__c,Private__c,Is_Complete__c,Primary_Attendee_Id__c,Primary_External_Contact_Id__c,Followup_Sync_To_Outlook__c        
                             FROM Event 
                             WHERE ParentId__c = null AND Type = 'Meeting'
                             LIMIT 1];
        
        Test.setCurrentPageReference(Page.HL_ActivityEventOutlook);
        ApexPages.currentPage().getParameters().put('id', eventRecord.Id);
        ApexPages.currentPage().getParameters().put('related_id',contactRecord.Id);
        ApexPages.currentPage().getParameters().put('retURL',contactRecord.Id);
        ApexPages.StandardController standardController = new ApexPages.StandardController(eventRecord);
        HL_ActivityControllerOutlook activityController = new HL_ActivityControllerOutlook(standardController);
        List<String> activityTypes = HL_ActivityControllerOutlook.GetActivityTypes();
        List<String> followupTypes = HL_ActivityControllerOutlook.GetFollowupTypes();
        
        activityController.Activity.Type = activityTypes[0];
        
        //Add HL Employee Record
        activityController.SelectedEmployeeId = employeeRecord.Id;
        activityController.AddEmployee();
        
        //Add a New External Contact Record
        activityController.SelectedContactId = newExternalContactRecord.Id;
        activityController.AddContact();
        
        //Associate a Company/Account Record
        activityController.SelectedAccountId = accountRecord.Id;
        activityController.AddCompany();
        
        //Associate an Opportunity Record
        activityController.SelectedOpportunityId = opportunityRecord.Id;
        activityController.AddOpportunity();

        //Associate an Engagement Record
        activityController.SelectedEngagementId = engagementRecord.Id;
        activityController.AddEngagement();
        
        Test.startTest();
        
        List<HL_ActivityControllerOutlook.SelectedEmployee> employeeContactOriginalList = activityController.HLEmployees;
        activityController.DelId = employeeRecord.Id;
        activityController.RemoveEmployee();
        List<HL_ActivityControllerOutlook.SelectedEmployee> employeeContactFinalList = activityController.HLEmployees;
        
        List<HL_ActivityControllerOutlook.SelectedContact> externalContactOriginalList = activityController.RelatedContacts;
        activityController.DelId = newExternalContactRecord.Id;
        activityController.RemoveExternal();
        List<HL_ActivityControllerOutlook.SelectedContact> externalContactFinalList = activityController.RelatedContacts;
        
        List<Account> accountOriginalList = activityController.RelatedCompanies;
        activityController.DelId = accountRecord.Id;
        activityController.RemoveCompany();
        List<Account> accountFinalList = activityController.RelatedCompanies;
        
        List<Opportunity__c> opportunityOriginalList = activityController.RelatedOpportunities;
        activityController.DelId = opportunityRecord.Id;
        activityController.RemoveOpp();
        List<Opportunity__c> opportunityFinalList = activityController.RelatedOpportunities;

        List<Engagement__c> engagementOriginalList = activityController.RelatedEngagements;
        activityController.DelId = engagementRecord.Id;
        activityController.RemoveEng();
        List<Engagement__c> engagementFinalList = activityController.RelatedEngagements;
        
        Test.stopTest();
        
        //Employee and Attendee Count should remain the same as must have at least one Staff Member
        System.assertEquals(employeeContactOriginalList.size(), employeeContactFinalList.size()); 
        System.assertEquals(externalContactOriginalList.size(), externalContactFinalList.size());
        System.assertEquals(accountOriginalList.size(), accountFinalList.size());
        System.assertEquals(opportunityOriginalList.size(), opportunityFinalList.size());
        System.assertEquals(engagementOriginalList.size(), engagementFinalList.size());
    }
    
    @isTest
    private static void TestEventDeletion(){
        Contact newExternalContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        insert newExternalContactRecord;
        List<Event> eventList = (List<Event>)HL_TestFactory.CreateSObjectList('Event', false, 2);
        for(Event eventRecord : eventList){
            eventRecord.WhoId = newExternalContactRecord.Id;
            eventRecord.Subject = 'Event';
            eventRecord.StartDateTime = System.now().addDays(eventList.size());
            eventRecord.EndDateTime = eventRecord.StartDateTime;
            eventRecord.Start_Date__c = System.today().addDays(eventList.size());
            eventRecord.Start_Time__c = '12:00 AM';
            eventRecord.End_Date__c = System.today().addDays(eventList.size());
            eventRecord.End_Time__c = '12:00 AM';
        }
        insert eventList;
        
        Test.setCurrentPageReference(Page.HL_ActivityEventViewOutlook);
        ApexPages.currentPage().getParameters().put('Id',eventList[1].Id);
        ApexPages.currentPage().getParameters().put('retURL',newExternalContactRecord.Id);
        
        Test.startTest();
        
        //Delete through Static Method
        HL_ActivityControllerOutlook.DeleteRecord(eventList[0].Id);
        
        //Delete through Page
        HL_ActivityControllerOutlook activityController = new HL_ActivityControllerOutlook();
        PageReference deletePageReference = activityController.DeleteRecord(); 
        
        Test.stopTest();
        
        System.assert([SELECT Id FROM Event WHERE Id=:eventList[0].Id].size() == 0);
        System.assert([SELECT Id FROM Event WHERE Id=:eventList[1].Id].size() == 0);
    }
    
    @isTest
    private static void TestEventCancel(){
        Event eventRecord = [SELECT Id FROM Event WHERE ParentId__c = null AND Type = 'Meeting' LIMIT 1];
        
        Test.setCurrentPageReference(Page.HL_ActivityEventOutlook);
        ApexPages.currentPage().getParameters().put('Id',eventRecord.Id);
        ApexPages.StandardController standardController = new ApexPages.StandardController(eventRecord);
        
        Test.startTest();
        
        HL_ActivityControllerOutlook activityController = new HL_ActivityControllerOutlook(standardController);
        PageReference cancelPageReference = activityController.CancelRecord();
        
        Test.stopTest();
    }
    
    @isTest
    private static void TestEventFollowupCreation(){
        Contact contactRecord = [SELECT Name FROM Contact WHERE RecordType.DeveloperName = 'External_Contact' LIMIT 1];
        Default_Owner__c defaultOwner = new Default_Owner__c(Id__c = UserInfo.getUserId());
        insert defaultOwner;
        Event eventRecord = [SELECT WhoId, Type, Subject, StartDateTime, EndDateTime, Start_Date__c, Start_Time__c, 
                             End_Date__c, End_Time__c, IsFollowup__c, Followup_Type__c, Followup_Start_Date__c,
                             Followup_Start_Time__c, Followup_End_Date__c, Followup_End_Time__c,
                             Primary_External_Contact_Id__c, Primary_Attendee_Id__c,Primary_External_Contact_Company__c,
                             PFG__c,ParentId__c,Private__c,Is_Complete__c,No_External_Contact__c,Followup_Comments__c,Followup_Sync_To_Outlook__c,
                             Followup_Parent__c,Notify_Coverage_Team__c,Description,Sync_To_Outlook__c
                             FROM Event 
                             WHERE ParentId__c = null AND Type = 'Meeting'
                             LIMIT 1];
        Test.setCurrentPageReference(Page.HL_ActivityEvent);
        ApexPages.currentPage().getParameters().put('id',eventRecord.Id);
        ApexPages.currentPage().getParameters().put('retURL',contactRecord.Id);
        ApexPages.StandardController standardController = new ApexPages.StandardController(eventRecord);
        
        Test.startTest();
        
        HL_ActivityControllerOutlook activityController = new HL_ActivityControllerOutlook(standardController);
        String eventsId = activityController.eventsId;
        //String SelectedCampaignId = activityController.SelectedCampaignId;
        //String SelectedCampaignName = activityController.SelectedCampaignName;
        activityController.RelatedContacts[0].Primary = true;
        eventRecord.isFollowUp__c = true;
        eventRecord.Followup_Type__c = 'Follow-up External';
        eventRecord.Followup_Start_Date__c = eventRecord.Start_Date__c;
        eventRecord.Followup_Start_Time__c = eventRecord.Start_Time__c;
        eventRecord.Followup_End_Time__c = eventRecord.End_Time__c;
        activityController.Activity = eventRecord;
        
        String s = activityController.formattedStartDate;
        s = activityController.formattedEndDate;
        
        PageReference saveResult = activityController.SaveRecord();
        PageReference saveResult1 = activityController.saveRec();
        Test.stopTest();
        
       
    }
    
    @isTest
    private static void TestSaveEventFromJSON(){
        Contact employeeRecord = [SELECT Name FROM Contact WHERE RecordType.DeveloperName = 'Houlihan_Employee' AND User__c =: UserInfo.getUserId() LIMIT 1];
        Event eventRecord = [SELECT WhoId, Type, Subject, StartDateTime, EndDateTime, Start_Date__c, Start_Time__c, 
                             End_Date__c, End_Time__c, IsFollowup__c, Followup_Type__c, Followup_Start_Date__c,
                             Followup_Start_Time__c, Followup_End_Date__c, Followup_End_Time__c
                             FROM Event 
                             WHERE ParentId__c = null AND Type = 'Meeting'
                             LIMIT 1];
        Contact externalRecord = [SELECT Name FROM Contact WHERE RecordType.DeveloperName = 'External_Contact' LIMIT 1];
        Account accountRecord = [SELECT Name FROM Account LIMIT 1];
        Opportunity__c opportunityRecord = [SELECT Name FROM Opportunity__c LIMIT 1];
        Engagement__c engagementRecord = [SELECT Name, Id FROM Engagement__c LIMIT 1];
        //Campaign campaignRecord = [SELECT Name,Id FROM Campaign LIMIT 1];
        
        Test.startTest();
        
        List<Contact> defaultContact = HL_ActivityControllerOutlook.GetDefaultContact();
        List<Contact> defaultAttendee = HL_ActivityControllerOutlook.GetDefaultAttendee(externalRecord.Id);
        Event event = HL_ActivityControllerOutlook.GetById(eventRecord.Id);
        List<Contact> attendeeList = HL_ActivityControllerOutlook.GetAttendees(eventRecord.Id);
        List<Contact> employeeList = HL_ActivityControllerOutlook.GetEmployees(eventRecord.Id);
        List<Account> companyList = HL_ActivityControllerOutlook.GetComps(eventRecord.Id);
        List<Opportunity__c> opportunityList = HL_ActivityControllerOutlook.GetOpps(eventRecord.Id);
        List<Engagement__c> engagementList = HL_ActivityControllerOutlook.GetEngs(eventRecord.Id);
        //List<Campaign> campaignList = HL_ActivityControllerOutlook.GetCamp(eventRecord.Id);
        
        String attendeeJSON = '[{"sobjectType":"Contact","id":"' + externalRecord.Id + '"}]';
        String employeeJSON = '[{"sobjectType":"Contact","id":"' + employeeRecord.Id + '"}]';
        String compJSON = '[{"sobjectType":"Account","id":"' + accountRecord.Id + '"}]';
        String oppJSON = '[{"sobjectType":"Opportunity__c","id":"' + opportunityRecord.Id + '"}]';
        String engJSON = '[{"sobjectType":"Engagement__c","id":"' + engagementRecord.Id + '"}]';
        //String campJSON = '[{"sobjectType":"Campaign","id":"' + campaignRecord.Id + '"}]';
        try{
        HL_ActivityControllerOutlook.Save(null, 'Call', 'Test', 'Test Activity', 'Test Notes', String.valueOf(Date.today()), '12:00 AM', String.valueOf(Date.today()), '12:30 AM', 
                                   false, false, false, false, true, 'External', 
                                   String.valueOf(Date.today()), '01:00 AM', String.valueOf(Date.today()), '01:30 AM', false, 'Follow up', externalRecord.Id, employeeRecord.Id,
                                   attendeeJSON, employeeJSON, compJSON, oppJSON, engJSON,false,null,null,false);
        }Catch(Exception ex){
             System.assertNotEquals(0, defaultContact.size());  
        }
        Event eventResult = HL_ActivityControllerOutlook.GetById(eventRecord.Id);
        Activity_Supplement__c supplementRecord = HL_ActivityControllerOutlook.GetActivitySupplement(eventRecord.Id);
        
        boolean hasDelegateRights = HL_ActivityControllerOutlook.HasDeleteRights(eventRecord.Id);
        boolean hasInternalTypeAccess = HL_ActivityControllerOutlook.HasInternalTypeAccess();
        
        Test.stopTest();
        
        //Validate the default contact was returned appropriately
        System.assertEquals(1, defaultContact.size());  
        System.assertEquals(employeeRecord.Id, defaultContact[0].Id);
        //Validate the Returned Event is our Created Event
        System.assertEquals(eventRecord.Id, eventResult.Id);

    }
}