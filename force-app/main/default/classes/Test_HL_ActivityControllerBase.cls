@isTest
private class Test_HL_ActivityControllerBase {
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
        //Engagement__c engagementRecord = (Engagement__c)HL_TestFactory.CreateSObject('Engagement__c', false);
        //insert engagementRecord;
        //Campaign campaignRecord = (Campaign)HL_TestFactory.CreateSObject('Campaign', false);
        //campaignRecord.Name = 'testName'; //we're hardcoding this line to help with deployment errors -AYU 2/27/2017         
        //insert campaignRecord;
        List<Task> taskList = new List<Task>();
        List<Event> eventList = (List<Event>)HL_TestFactory.CreateSObjectList('Event', false, 9);
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

        //Event eventChildEngagementRecord = eventList[5];
        //eventChildEngagementRecord.Type = 'Meeting';
        //eventChildEngagementRecord.WhatId = engagementRecord.Id;
        //insert eventChildEngagementRecord;
        
        Id internalEventRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Event eventInternalParentRecord = eventList[5];
        eventInternalParentRecord.Type = 'Internal';
        eventInternalParentRecord.WhoId = employeeContactRecord.Id;
        eventInternalParentRecord.RecordTypeId = internalEventRecordTypeId;
        insert eventInternalParentRecord;
        Event eventInternalChildEmployeeRecord = eventList[6];
        eventInternalChildEmployeeRecord.Type = 'Internal';
        eventInternalChildEmployeeRecord.WhoId = employeeContactRecord.Id;
        eventInternalChildEmployeeRecord.RecordTypeId = internalEventRecordTypeId;
        insert eventInternalChildEmployeeRecord;
        Event eventInternalChildExternalRecord = eventList[7]; 
        eventInternalChildExternalRecord.Type = 'Internal';
        eventInternalChildExternalRecord.WhoId = additionalEmployeeContactRecord.Id;
        eventInternalChildExternalRecord.RecordTypeId = internalEventRecordTypeId;
        insert eventInternalChildExternalRecord;
        
        Event eventInternalMemberChildExternalRecord = eventList[8]; 
        eventInternalMemberChildExternalRecord.Type = 'Internal Mentor Meeting';
        eventInternalMemberChildExternalRecord.WhoId = additionalEmployeeContactRecord.Id;
        eventInternalMemberChildExternalRecord.RecordTypeId = internalEventRecordTypeId;
        insert eventInternalMemberChildExternalRecord;
        for(integer i=0;i<=3;i++)
        {
            Task taskRecord= new Task();
            taskRecord.WhoId = externalContactRecord.Id;
            taskRecord.status='Completed';
            taskRecord.Priority='low';
            taskRecord.subject=' has not completed the task within 1 day';
            taskList.add(taskRecord);
        }
        insert taskList;
    }
    
    @isTest 
    private static void TestExternalContactEventInitialization(){
        HL_ActivityControllerBase objBase = new HL_ActivityControllerBase();
        
        Contact userCon = objBase.UserContactRecord;
        boolean HasInternalSupervisorAccess = objBase.HasInternalSupervisorAccess;
        boolean HasInternalAccess = objBase.HasInternalAccess;
        boolean hasMentorActivityAccess = objBase.hasMentorActivityAccess;
        Id EntityId = objBase.EntityId;
        String EntityType = objBase.EntityType;
        Set<Id> Supervisors = objBase.Supervisors;
        PageReference pg = objBase.NewActivity();
        PageReference pgEdit = objBase.EditRecord();
        String RetEntity = objBase.RetEntity;
        Map<Id, Contact> objMap = new Map<Id, Contact>();
        Event e = new Event();
        e.StartDateTime=system.today();
        Map<Id,String> mapActivityWithEmailDesc =new Map<Id,String>();
        
        HL_Activity objActivity = objBase.CreateActivityFromEvent(null,null,null,e,objMap,null,null);
        list<task> taskList=[SELECT AccountId,Id,Createddate,Start_Date__c,Who.name,TaskSubtype,Subject,ActivityDate,Type,WhatId,Description,CreatedBy.Name,Primary_External_Contact__c,Primary_External_Contact_Id__c,Primary_Attendee__c,WhoId FROM Task];
        mapActivityWithEmailDesc.put(taskList[0].Id,'testing');
        mapActivityWithEmailDesc.put(taskList[1].Id,'testing');
        EmailMessage emailMessage = new EmailMessage(); 
        emailMessage.MessageDate=system.today();
        emailMessage.status = '3'; // email was sent 
        emailMessage.fromName = 'Magulan Duraipandian'; // from name 
        emailMessage.subject = 'This is the Subject!'; // email subject 
        emailMessage.htmlBody = '<html><body><b>Hello</b></body></html>'; // email body 
        //Lead Id 
        String[] toIds = new String[]{ taskList[0].Id };  
            emailMessage.toIds = toIds; 
        emailMessage.FromAddress='testing@test.com';
        emailMessage.ToAddress='testing@hl.com';
        // additional recipients who don’t have a corresponding contact, lead or user id in the Salesforce org (optional) 
        //emailMessage.toAddress = 'emailnotinsalesforce@toexample.com, anotherone@toexample.com'; 
        insert emailMessage; // insert 
        string userurl=objBase.RetEntity;
        set<Id> userIds=objBase.Supervisors;
        objBase.NewActivity();
        objBase.CreateActivityFromTask(taskList[0]);
        objBase.CreateActivityFromEmailMessage(emailMessage,null);
        objBase.CreateActivityFromActivityHistory(emailMessage,taskList[0],null,mapActivityWithEmailDesc,null);
        objBase.CreateActivityFromOpenActivity(emailMessage,taskList[1],null,mapActivityWithEmailDesc,null);
    }
}