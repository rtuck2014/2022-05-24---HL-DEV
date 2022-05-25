@isTest
public class Test_HL_ActivitySearchController {
    @isTest 
    private static void TestInitialization(){
        Integer page;
        
        Test.startTest();
        
        HL_ActivitySearchController activityListController = new HL_ActivitySearchController();
        
        //Test Page Methods
        page = activityListController.Page;
        activityListController.gonextPage();
        activityListController.PreviousPage();
        
        //Test Sort Methods
        activityListController.NewSort = 'Id';
        activityListController.ToggleDirection(activityListController.NewSort);
        activityListController.ApplySort();
        
        Test.stopTest();
        
        //Validate the initialization of the properties
        System.assertEquals(userInfo.getUserId(), activityListController.EntityId);
        System.assertEquals(0, activityListController.TotalPages);
        System.assertEquals(false, activityListController.HasNext);
        System.assertEquals(false, activityListController.HasPrevious);
        System.assertEquals(0, activityListController.TotalRecords);
        System.assert(!String.isBlank(activityListController.FilterText));
        System.assert(!String.isBlank(activityListController.SortDirection));
        System.assertEquals(1, activityListController.Page);
    }
    
    @isTest 
    private static void TestGetMyActivities(){
        Contact contactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        contactRecord.User__c = UserInfo.getUserId();
        insert contactRecord; 
        List<Task> taskList = new List<Task>();
        List<Event> eventList = (List<Event>)HL_TestFactory.CreateSObjectList('Event', false, 2);
        for(Event eventRecord : eventList)
        {
            eventRecord.WhoId = contactRecord.Id;
            eventRecord.ActivityDate = System.today();
            eventRecord.StartDateTime = System.now();
            eventRecord.EndDateTime = eventRecord.StartDateTime;
            eventRecord.Start_Date__c = System.today();
            eventRecord.Start_Time__c = '12:00 AM';
            eventRecord.End_Date__c = System.today();
            eventRecord.End_Time__c = '12:00 AM';
        }
        insert eventList;
        for(integer i=0;i<=3;i++)
        {
            Task taskRecord= new Task();
            taskRecord.WhoId = contactRecord.Id;
            taskRecord.status='Completed';
            taskRecord.Priority='low';
            taskRecord.subject=' has not completed the task within 1 day';
            taskList.add(taskRecord);
        }
        insert taskList;
        
        Test.startTest();
        
       
        Test.stopTest();
        
       
    }
    
    @isTest 
    private static void TestWithEventController(){
        Contact contactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        contactRecord.User__c = UserInfo.getUserId();
        insert contactRecord; 
        List<Task> taskList = new List<Task>();
        Opportunity__c opportunityRecord = (Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c', false);
        insert opportunityRecord;
        List<Event> eventList = (List<Event>)HL_TestFactory.CreateSObjectList('Event', false, 2);
        for(Event eventRecord : eventList)
        {
            eventRecord.WhoId = contactRecord.Id;
            eventRecord.StartDateTime = System.now();
            eventRecord.EndDateTime = eventRecord.StartDateTime;
            eventRecord.Start_Date__c = System.today();
            eventRecord.Start_Time__c = '12:00 AM';
            eventRecord.End_Date__c = System.today();
            eventRecord.End_Time__c = '12:00 AM';
            eventRecord.Type='Email';
        }
        insert eventList;
        eventList[0].ParentId__c = eventList[1].Id;
        eventList[1].ParentId__c = eventList[0].Id;
        update eventList;
        Event eventRecord = eventList[0]; 
        for(integer i=0;i<=3;i++)
        {
            Task taskRecord= new Task();
            taskRecord.WhoId = contactRecord.Id;
            taskRecord.status='Completed';
            taskRecord.Priority='low';
            taskRecord.subject=' has not completed the task within 1 day';
            taskList.add(taskRecord);
        }
        insert taskList;
        
        
        
        Test.startTest();
         HL_ActivitySearchController activityListController1 = new HL_ActivitySearchController();
        HL_ActivitySearchController activityListController = new HL_ActivitySearchController(new ApexPages.StandardController(eventRecord));
        //List<HL_Activity> activityList = activityListController.GetActivities();
        activityListController.FilterAll();
        activityListController.FilterToday();
        activityListController.FilterUpcoming();
        activityListController.selectedTypevalue='Email';
        activityListController.datesearchKey=NULL;
        //activityListController.fetchActivities();
        activityListController.getTypeList();
        activityListController.getTypedropdownList();
        activityListController.PreviousPage();
        activityListController.gonextPage();
        Test.stopTest();
        
        //System.assertEquals(1, activityList.size());
    }
    @isTest 
    private static void TestWithEventOppController(){
        Contact contactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        contactRecord.User__c = UserInfo.getUserId();
        insert contactRecord; 
        List<Task> taskList = new List<Task>();
        Opportunity__c opportunityRecord = (Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c', false);
        insert opportunityRecord;
        List<Event> eventList = (List<Event>)HL_TestFactory.CreateSObjectList('Event', false, 2);
        for(Event eventRecord : eventList)
        {
            eventRecord.WhoId = contactRecord.Id;
            eventRecord.StartDateTime = System.now();
            eventRecord.EndDateTime = eventRecord.StartDateTime;
            eventRecord.Start_Date__c = System.today();
            eventRecord.Start_Time__c = '12:00 AM';
            eventRecord.End_Date__c = System.today();
            eventRecord.End_Time__c = '12:00 AM';
            eventRecord.Type='Email';
        }
        insert eventList;
        eventList[0].ParentId__c = eventList[1].Id;
        eventList[1].ParentId__c = eventList[0].Id;
        update eventList;
        Event eventRecord = eventList[0]; 
        for(integer i=0;i<=3;i++)
        {
            Task taskRecord= new Task();
            taskRecord.WhoId = contactRecord.Id;
            taskRecord.status='Completed';
            taskRecord.Priority='low';
            taskRecord.subject=' has not completed the task within 1 day';
            taskList.add(taskRecord);
        }
        insert taskList;
        
        
        
        Test.startTest();
        PageReference myVfPage = Page.HL_ContactView;
        Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',opportunityRecord.Id);
        HL_ActivitySearchController activityListController = new HL_ActivitySearchController(new ApexPages.StandardController(eventRecord));
        activityListController.TotalRecords=2;
        activityListController.getActivityList('Email',NULL);
        activityListController.FilterAll();
        activityListController.FilterToday();
        activityListController.FilterUpcoming();
        
        Test.stopTest();
        
        //System.assertEquals(1, activityList.size());
    }
    @isTest 
    private static void TestWithEventContactController(){
        Contact contactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        contactRecord.User__c = UserInfo.getUserId();
        insert contactRecord; 
        List<Task> taskList = new List<Task>();
        Opportunity__c opportunityRecord = (Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c', false);
        insert opportunityRecord;
        List<Event> eventList = (List<Event>)HL_TestFactory.CreateSObjectList('Event', false, 2);
        for(Event eventRecord : eventList)
        {
            eventRecord.WhoId = contactRecord.Id;
            eventRecord.StartDateTime = System.now();
            eventRecord.EndDateTime = eventRecord.StartDateTime;
            eventRecord.Start_Date__c = System.today();
            eventRecord.Start_Time__c = '12:00 AM';
            eventRecord.End_Date__c = System.today();
            eventRecord.End_Time__c = '12:00 AM';
            eventRecord.Type='Call';
        }
        insert eventList;
        eventList[0].ParentId__c = eventList[1].Id;
        eventList[1].ParentId__c = eventList[0].Id;
        update eventList;
        Event eventRecord = eventList[0]; 
        for(integer i=0;i<=3;i++)
        {
            Task taskRecord= new Task();
            taskRecord.WhoId = contactRecord.Id;
            taskRecord.status='Completed';
            taskRecord.Priority='low';
            taskRecord.subject=' has not completed the task within 1 day';
            taskList.add(taskRecord);
        }
        insert taskList;
        
        
        
        Test.startTest();
        PageReference myVfPage = Page.HL_ContactView;
        Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',contactRecord.Id);
        HL_ActivitySearchController activityListController = new HL_ActivitySearchController(new ApexPages.StandardController(eventRecord));
        //HL_ActivitySearchController.pageSize=10;
        activityListController.TotalRecords=2;
        activityListController.fetchActivities();
        //activityListController.GetActivityList('Test');
        activityListController.getActivityList('Call',NULL);
        activityListController.FilterAll();
        activityListController.FilterToday();
        activityListController.FilterUpcoming();
        activityListController.getTypeList();
        //activityListController.GetInternalFilterClause();
        activityListController.redirectToContact();
        Test.stopTest();
        
        //System.assertEquals(1, activityList.size());
    }
}