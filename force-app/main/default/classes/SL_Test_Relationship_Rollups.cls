/**  
* \arg ClassName      : SL_Test_Relationship_Rollups
* \arg JIRATicket     : HL-15
* \arg CreatedOn      : 30/MAY/2014
* \arg LastModifiedOn : 6/NOV/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : Edward Rivera
* \arg Description    : Test class for batch and scheduler
*/
@isTest()
public with sharing class SL_Test_Relationship_Rollups 
{
    Static List<Account> lstAccount ;
    Static List<Contact> lstContactHL ;
    Static List<Contact> lstContactEX ;
    Static List<Event> lstEvent;
    Static Event yesterdayParentEvent;
    Static Event yesterdayChildEvent;
    Static Event nowParentEvent;
    Static Event nowChildEvent;
    Static Event oldParentEvent;
    Static Event oldChildEvent;
    Static List<Opportunity__c> lstOpportunity;
    Static List<Opportunity_Internal_Team__c> lstOIT;
    Static List<Opportunity_External_Team__c> lstOET;
    Static List<Relationship__c> lstRelationship;
    Static List<Engagement__c> lstEngagement;
    Static List<Engagement_Internal_Team__c> lstEIT;
    Static List<Engagement_External_Team__c> lstEET;
    Static List<Engagement_Counterparty__c> lstEC;
    Static List<Engagement_Counterparty_Contact__c> lstECC;
    Static Set<Id> setEngagementIds = new Set<Id>();
    Static List<Engagement_Internal_Team__c> objEit ;
    Static Engagement__c eng ;

    private static User createTestUser(Id profID, String fName, String lName) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
       
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName, lastName = lName,
                                email = uniqueName + '@test' + orgId + '.org',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US', ProfileId = profId,IsActive = true,
                                Contact_Move_Rights__c = true
                             );
        return tuser;
    }

    static void test_Batch_Relationship_Setup()
    {   
        // create a test account
        lstAccount = new List<Account>();
        for(Account objAcc : SL_TestSetupUtils.CreateAccount('Account', 1)){
            lstAccount.add(objAcc);
        }
        insert lstAccount;
        
        // insert a HL contact into that account
        lstContactHL = new List<Contact>();
        List<Contact> allcontactList = new List<Contact>();
        for(Contact objCon : SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE))
        {
            objCon.User__c = Userinfo.getUserId();
            lstContactHL.add(objCon);
        }
        allcontactList.addAll(lstContactHL);
        
        // create a set of external contacts
        lstContactEX = new List<Contact>();
        for(Contact objContact : SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT))
        {
            objContact.AccountId = lstAccount[0].Id;
            lstContactEX.add(objContact);
        }
        allcontactList.addAll(lstContactEX);
        insert allcontactList;
    }
    
    static void test_Relationship_Event_Method() {
        test_Batch_Relationship_Setup();
        // add an event that took place yesterday
        lstEvent = new List<Event>();        
        yesterdayParentEvent = new Event(StartDateTime = datetime.now().addDays(-1),
                                         EndDateTime = datetime.now().addDays(-1),  
                                         ActivityDate = date.today().addDays(-1),
                                         OwnerId = Userinfo.getUserId(),
                                         WhoId = lstContactHL[0].Id);
        insert yesterdayParentEvent;
        
        yesterdayChildEvent = yesterdayParentEvent.clone();
        yesterdayChildEvent.ParentId__c = yesterdayParentEvent.Id;
        insert yesterdayChildEvent;
        
        // create multiple events taking place yesterday
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 1))
        {
            objEvent.StartDateTime = datetime.now().addDays(-1);
            objEvent.EndDateTime = datetime.now().addDays(-1);
            objEvent.ActivityDate = date.Today().addDays(-1);
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.WhoId = lstContactEX[0].Id;
            objEvent.ParentId__c = yesterdayParentEvent.Id;
            lstEvent.add(objEvent);     
        }
        
        // create multiple events taking place now
        nowParentEvent = new Event(ActivityDate = date.Today(),
                                   IsAllDayEvent = true,
                                   OwnerId = Userinfo.getUserId(),
                                   WhoId = lstContactHL[0].Id);
        insert nowParentEvent;
        
        nowChildEvent = nowParentEvent.clone();
        nowChildEvent.ParentId__c = nowParentEvent.Id;
        insert nowChildEvent;
        
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 1))
        {
            objEvent.ActivityDate = date.Today();
            objEvent.IsAllDayEvent = true;
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.WhoId = lstContactEX[0].Id;
            objEvent.ParentId__c = nowParentEvent.Id;
            lstEvent.add(objEvent);
        }
        
        // create multiple events taking place half a year ago
        oldParentEvent = new Event(StartDateTime = datetime.now().addDays(-180),
                                   EndDateTime = datetime.now().addDays(-180),
                                   ActivityDate = date.Today().addDays(-180),
                                   OwnerId = Userinfo.getUserId(),
                                   WhoId = lstContactHL[0].Id);
        insert oldParentEvent;
        
        oldChildEvent = oldParentEvent.clone();        
        oldChildEvent.ParentId__c = oldParentEvent.Id;
        insert oldChildEvent;
        
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 1))
        {
            objEvent.StartDateTime = datetime.now().addDays(-180);
            objEvent.EndDateTime = datetime.now().addDays(-180);
            objEvent.ActivityDate = date.Today().addDays(-180);
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.WhoId = lstContactEX[0].Id;
            lstEvent.add(objEvent);
        }
        insert lstEvent;
    }
    
    static void test_Relationship_Opportunity_Method(){
        //  test_Batch_Relationship_Setup();
        // create an open and closed opportunity
        lstOpportunity = new List<Opportunity__c>();        
        lstOpportunity.add(new Opportunity__c(Client__c = lstAccount[0].Id,Stage__c ='Evaluating Prospect',Beneficial_Owner_Control_Person_form__c = 'No'));
        lstOpportunity.add(new Opportunity__c(Client__c = lstAccount[0].Id,Stage__c ='Engaged',Beneficial_Owner_Control_Person_form__c = 'No')); 
        insert lstOpportunity;
        system.debug('1>>>'+Limits.getQueries());
        
        // add internal teams to those opportunity
        lstOIT = new List<Opportunity_Internal_Team__c>();
        for(Opportunity_Internal_Team__c objOIT : SL_TestSetupUtils.CreateOIT('Opportunity_Internal_Team__c', 1))
        {
            objOIT.Opportunity__c = lstOpportunity[0].Id;
            objOIT.Contact__c = lstContactHL[0].Id;
            lstOIT.add(objOIT);
        }
        insert lstOIT;
        
        // add external teams to those opportunities, half closed, half opened
        lstOET = new List<Opportunity_External_Team__c>();
        for(Opportunity_External_Team__c objOET : SL_TestSetupUtils.CreateOET('Opportunity_External_Team__c', 1))
        {
            objOET.Opportunity__c = lstOpportunity[0].Id;
            objOET.Contact__c = lstContactEX[0].Id;
            lstOET.add(objOET);
        }
        insert lstOET;
        
        // create relationships between each external contact and the internal contact
        lstRelationship = new List<Relationship__c>();
        for(Relationship__c objRelationship : SL_TestSetupUtils.CreateRelationship('Relationship__c', 1))
        {
            lstRelationship.add(new Relationship__c(External_Contact__c = lstContactEX[0].Id, HL_Contact__c = lstContactHL[0].Id));
        }
        insert lstRelationship;
    }       
    
    Static void test_Relationship_Engagement_Method(){   
        test_Batch_Relationship_Setup();
        
        lstEngagement = SL_TestSetupUtils.CreateEngagement('Engagement__c', 2);
        for(integer i = 0; i < lstEngagement.size(); i++){
            lstEngagement[0].Client__c = lstAccount[0].Id;
            lstEngagement[0].Subject__c = lstAccount[0].Id;
            lstEngagement[0].Stage__c ='Closed';
        }
        insert lstEngagement;       
        
        eng = new Engagement__c(Client__c = lstAccount[0].Id, Subject__c = lstAccount[0].Id, Stage__c ='In Market');
        insert eng;
        
        lstEIT = new List<Engagement_Internal_Team__c>();
        for(Engagement_Internal_Team__c objEIT1 : SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c', 1))
        {
            objEIT1.Contact__c = lstContactHL[0].Id;
            objEIT1.Engagement__c = lstEngagement[0].Id;
            objEIT1.Start_Date__c = System.Today();
            objEIT1.End_Date__c = System.Today();
            lstEIT.add(objEIT1); 
            setEngagementIds.add(objEIT1.Engagement__c);       
        }
        insert lstEIT;
        
        Engagement_Internal_Team__c obj = new Engagement_Internal_Team__c (Contact__c = lstContactHL[0].Id,Engagement__c =eng.Id,Start_Date__c = System.Today().addDays(-1),End_Date__c = System.Today().addDays(2));
        insert obj;
        
        lstEET = new List<Engagement_External_Team__c>();
        for(Engagement_External_Team__c objEET : SL_TestSetupUtils.CreateEET('Engagement_External_Team__c', 1))
        {
            objEET.Contact__c = lstContactEX[0].Id;
            objEET.Engagement__c = lstEngagement[0].Id;
            lstEET.add(objEET);
        }
        insert lstEET; 
        
        // add a counterparty to engagement
        lstEC = new  List<Engagement_Counterparty__c>();        
        for(Engagement_Counterparty__c objEC : SL_TestSetupUtils.CreateEC('Engagement_Counterparty__c',1))
        {
            objEC.Company__c = lstAccount[0].Id;
            objEC.Engagement__c = lstEngagement[0].Id;
            lstEC.add(objEC);
        }
        insert lstEC;
        
        // assign external contact to counterparty      
        lstECC = new List<Engagement_Counterparty_Contact__c>();
        for(Engagement_Counterparty_Contact__c objECC : SL_TestSetupUtils.CreateECC('Engagement_Counterparty_Contact__c', 1))
        {
            objECC.Counterparty__c = lstEC[0].Id;
            objECC.Contact__c = lstContactEX[0].Id;
            lstECC.add(objECC);
        }
        insert lstECC;
    }   
    
    @isTest()
    static void testRelationship1() 
    {   
        Profile pf1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = createTestUser(pf1.Id, 'Test FirstName1', 'Test LastName');        
        insert user1;

        //SL_RelationshipHandler.ENABLED = false;

        System.runAs(user1) {
            test_Batch_Relationship_Setup();  
            system.debug('1>>>>'+Limits.getQueries());
            Test.startTest(); 
            system.debug('2>>>>'+Limits.getQueries());
            test_Relationship_Opportunity_Method();
            SL_Batch_Relationship_Rollups batch = new SL_Batch_Relationship_Rollups();
            Database.executeBatch(batch, 200); 
            system.debug('3>>>>'+Limits.getQueries());
            Test.stopTest();
            system.debug('4>>>>'+Limits.getQueries());
        }
    }
    
    Static Relationship__c relObj;
    @isTest()
    static void testRelationship2()     
    {   
        Profile pf1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = createTestUser(pf1.Id, 'Test FirstName1', 'Test LastName');        
        insert user1;

        //SL_RelationshipHandler.ENABLED = false;

        System.runAs(user1) {
            test_Batch_Relationship_Setup(); 
            test_Relationship_Event_Method();   
            relObj = new Relationship__c(
                HL_Contact__c = lstContactHL[0].Id,
                External_Contact__c = lstContactEX[0].Id,
                Last_Activity_Date__c = System.Today().AddDays(-1),
                Next_Activity_Date__c = System.Today().AddDays(1),
                Number_of_Activities_LTM__c = 2,
                Number_of_Deals_on_Client_External_Team__c = 2,
                Number_of_Deals_Shown__c = 1,
                Share_Active_Deal__c = true,
                Share_Open_Opp__c = true,
                Strength_Rating__c ='High');        
            insert relObj;   
            Test.startTest();         
            SL_Batch_Relationship_Rollups batch = new SL_Batch_Relationship_Rollups();
            Database.executeBatch(batch, 200); 
            Test.stopTest(); 
        }
    }   
    
    @isTest()
    static void testRelationship3() 
    {   
        Profile pf1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = createTestUser(pf1.Id, 'Test FirstName1', 'Test LastName');        
        insert user1;

        //SL_RelationshipHandler.ENABLED = false;

        System.runAs(user1) {
            test_Relationship_Engagement_Method();
            Test.startTest();
            SL_Batch_Relationship_Rollups batch = new SL_Batch_Relationship_Rollups();
            Database.executeBatch(batch, 200); 
            Test.stopTest();
        }
    }
    
    @isTest()
    static void testRelationship4()    
    {  
        Profile pf1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = createTestUser(pf1.Id, 'Test FirstName1', 'Test LastName');        
        insert user1;

        //SL_RelationshipHandler.ENABLED = false;

        /*System.runAs(user1) {
            test_Batch_Relationship_Setup();
            system.debug('11>>>>'+Limits.getQueries());
            Test.startTest(); 
            system.debug('21>>>>'+Limits.getQueries());
            test_Relationship_Opportunity_Method();
            system.debug('31>>>>'+Limits.getQueries());       
            
            String CRON_EXP = '0 0 0 15 3 ? 2022';
            String jobId = System.schedule('testRelationship4',CRON_EXP,new SL_Scheduler_Relationship_Rollups());
            system.debug('41>>>>'+Limits.getQueries());       
            Test.stopTest();
            system.debug('51>>>>'+Limits.getQueries());       
        }*/
    }
}