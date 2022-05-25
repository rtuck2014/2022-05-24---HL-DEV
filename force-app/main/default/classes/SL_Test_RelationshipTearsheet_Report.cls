@isTest
private class SL_Test_RelationshipTearsheet_Report 
{
    @testSetup
    private static void SetupReportData(){
        Integer i = 0;    
        Profile objProfile = [SELECT Name 
                              FROM Profile
                              WHERE Name = 'System Administrator'];
        
        List<User> userList = new List<User>();
        
        for(User userRecord : (List<User>)HL_TestFactory.CreateSObjectList('User', false, 1))
        {
            userRecord.Lastname = 'User';
            userRecord.Email = 'tuser@yahoo.in';
            userRecord.Username = 'test@hl2.com';
            userRecord.ProfileId = objProfile.Id;
            userRecord.Alias = 'tuser';
            userRecord.TimeZoneSidKey = 'GMT';
            userRecord.LocaleSidKey = 'en_US';
            userRecord.EmailEncodingKey = 'ISO-8859-1';
            userRecord.LanguageLocaleKey = 'en_US';
            userRecord.Has_Delegates__c = false;
            userList.add(userRecord);
        }
        insert userList;
        
        List<Delegate_Public_Group__c> delegatePublicGroupList = new List<Delegate_Public_Group__c>();
        for(Delegate_Public_Group__c delegatePublicGroupRecord : (List<Delegate_Public_Group__c>)HL_TestFactory.CreateSObjectList('Delegate_Public_Group__c', false, 1))
        {
            delegatePublicGroupRecord.Banker__c = userList[0].Id;
            delegatePublicGroupList.add(delegatePublicGroupRecord);
        }
        insert delegatePublicGroupList;
        
        List<Account> accountList = new List<Account>();
        for(Account accountRecord : (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 1))
        {
            accountRecord.Name = 'Abc';
            accountRecord.EBITDA_MM__c = 54545;
            accountRecord.Total_Debt_MM__c = 4500;
            accountRecord.AnnualRevenue = 78754;
            accountList.add(accountRecord);                            
        }
        insert accountList;
        
        List<Contact> AllContacts = new List<Contact>();
        Contact externalContact = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        //insert externalContact;
        AllContacts.add(externalContact);
        
        List<Contact> hlContactList = new List<Contact>();
        for(Contact contactRecord : HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.Houlihan_Employee, false, 1))
        {
            contactRecord.AccountId = accountList[0].Id;
            contactRecord.Title = 'Title-1';
            contactRecord.Phone = '989898989';
            contactRecord.MobilePhone = '989898989';
            contactRecord.Email = 'abc@silverlinecrm.com';      
            contactRecord.AssistantName = 'TestAsst.-1';
            contactRecord.AssistantPhone = '9875487884';
            contactRecord.User__c = userList[0].Id;
            hlContactList.add(contactRecord);
        }
        AllContacts.addAll(hlContactList);
        //insert hlContactList;
        insert AllContacts;
        
        List<Affiliation__c> affiliationList = new List<Affiliation__c>();
        for(Affiliation__c affiliationRecord : (List<Affiliation__c>)HL_TestFactory.CreateSObjectList('Affiliation__c', false, 7))
        {
            affiliationRecord.Account__c = accountList[0].Id;
            affiliationRecord.Contact__c = hlContactList[0].Id;
            affiliationRecord.End_Date__c = Date.today();
            affiliationRecord.Status__c = 'Former';
            affiliationRecord.End_Date__c = Date.today().addDays(5);
            affiliationRecord.Type__c = 'Outside Board Member';
            affiliationList.add(affiliationRecord);
        }
        
        for(Affiliation__c affiliationRecord : (List<Affiliation__c>)HL_TestFactory.CreateSObjectList('Affiliation__c', false, 7))
        {
            affiliationRecord.Account__c = accountList[0].Id;
            affiliationRecord.Contact__c = hlContactList[0].Id;
            affiliationRecord.End_Date__c = Date.today();
            affiliationRecord.Status__c = 'Current';
            affiliationRecord.End_Date__c = Date.today().addDays(5);
            affiliationRecord.Type__c = 'Parent';
            affiliationList.add(affiliationRecord);
        }
        insert affiliationList;
        
        List<Event> eventList = new List<Event>();
        for(Event eventRecord : (List<Event>)HL_TestFactory.CreateSObjectList('Event', false, 5))
        {
            eventRecord.StartDateTime = datetime.now();
            eventRecord.EndDateTime = datetime.now().addHours(2);
            eventRecord.ActivityDate = date.Today().addDays(-1);
            eventRecord.OwnerId = Userinfo.getUserId();
            eventRecord.WhoId = hlContactList[0].Id;
            eventList.add(eventRecord);
        }
        
        for(Event eventRecord : (List<Event>)HL_TestFactory.CreateSObjectList('Event', false, 5))
        {
            eventRecord.StartDateTime = datetime.now();
            eventRecord.EndDateTime = datetime.now();
            eventRecord.ActivityDate = date.Today().addDays(-1);
            eventRecord.OwnerId = Userinfo.getUserId();
            eventRecord.WhoId = hlContactList[0].Id;
            eventList.add(eventRecord);
        }
        
        for(Event eventRecord : (List<Event>)HL_TestFactory.CreateSObjectList('Event', false, 5))
        {
            eventRecord.StartDateTime = datetime.now();
            eventRecord.EndDateTime = datetime.now();
            eventRecord.ActivityDate = date.Today().addYears(-2);
            eventRecord.OwnerId = Userinfo.getUserId();
            eventRecord.WhoId = hlContactList[0].Id;
            eventList.add(eventRecord);
        }
        insert eventList;
        
        List<Engagement__c> engagementList = new List<Engagement__c>();
        for(Engagement__c engagementRecord : HL_TestFactory.CreateEngagementList(false, 10))
        {
            engagementRecord.Client__c = accountList[0].Id;
            engagementRecord.Subject__c = accountList[0].Id;
            engagementRecord.ProgressMonthly_Fee__c = 1500.0;
            engagementRecord.Close_Date__c = Date.today().addYears(5);
            engagementRecord.Referral_Contact__c = hlContactList[0].Id;
            engagementList.add(engagementRecord);
        }
        insert engagementList;
        
        i = 0;
        /*List<Engagement_External_Team__c> engagementExternalTeamList = new List<Engagement_External_Team__c>();
        for(Engagement_External_Team__c externalTeamRecord : (List<Engagement_External_Team__c>)HL_TestFactory.CreateSObjectList('Engagement_External_Team__c', false, 10))
        {
            externalTeamRecord.Contact__c = externalContact.Id;
            externalTeamRecord.Engagement__c = engagementList[i].Id;
            externalTeamRecord.Type__c ='Referral';
            engagementExternalTeamList.add(externalTeamRecord);
            i++;
        }
        insert engagementExternalTeamList;*/
        
        List<Engagement_Counterparty__c> engagementCounterpartyList = new  List<Engagement_Counterparty__c>();
        for(Engagement_Counterparty__c counterpartyRecord : (List<Engagement_Counterparty__c>)HL_TestFactory.CreateSObjectList('Engagement_Counterparty__c', false, 5))
        {
            counterpartyRecord.Company__c = accountList[0].Id;
            counterpartyRecord.Engagement__c = engagementList[0].Id;
            counterpartyRecord.Coverage_Officer__c = hlContactList[0].Id;
            engagementCounterpartyList.add(counterpartyRecord);
        }
        insert engagementCounterpartyList;
        
        i = 0;
        /*List<Engagement_Counterparty_Contact__c> counterpartyContactList = new List<Engagement_Counterparty_Contact__c>();
        for(Engagement_Counterparty_Contact__c counterpartyContactRecord : (List<Engagement_Counterparty_Contact__c>)HL_TestFactory.CreateSObjectList('Engagement_Counterparty_Contact__c', false, 5))
        {
            counterpartyContactRecord.Contact__c = externalContact.Id;
            counterpartyContactRecord.Counterparty__c = engagementCounterpartyList[i].Id;
            counterpartyContactList.add(counterpartyContactRecord);
            i++;
        }
        insert counterpartyContactList;*/
        
        i = 0;
        Date dtStartDate = Date.today().addDays(5);
        List<Campaign> campaignList = new List<Campaign>();
        for(Campaign campaignRecord : (List<Campaign>)HL_TestFactory.CreateSObjectList('Campaign', false, 5))
        {
            campaignRecord.Name = 'Campaign ' + campaignList.size();
            campaignRecord.Engagement__c = engagementList[i].Id;
            campaignRecord.StartDate = dtStartDate;
            campaignRecord.Type = 'Conference';
            campaignList.add(campaignRecord);
            i++;
            if(i > 2)
                dtStartDate = Date.today().addDays(-5);
        }
        insert campaignList;
        
        i = 0;
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        for(CampaignMember campaignMemberRecord : (List<CampaignMember>)HL_TestFactory.CreateSObjectList('CampaignMember', false, 5))
        {
            campaignMemberRecord.CampaignId = campaignList[i].Id;
            campaignMemberRecord.ContactId = hlContactList[0].Id;
            campaignMemberList.add(campaignMemberRecord);
            i++;
        }
        insert campaignMemberList;
        
        List<Opportunity__c> opportunityList = new List<Opportunity__c>();
        for(Opportunity__c opportunityRecord : (List<Opportunity__c>)HL_TestFactory.CreateSObjectList('Opportunity__c', false, 10))
        {
            opportunityRecord.Client__c = accountList[0].Id;
            opportunityRecord.Estimated_Engagement_Date__c = Date.today();
            opportunityList.add(opportunityRecord);
        }
        insert opportunityList;
        
        /*List<Opportunity_External_Team__c> opportunityExternalTeamList = new List<Opportunity_External_Team__c>();
        for(Opportunity_External_Team__c opportunityExternalTeamRecord : (List<Opportunity_External_Team__c>)HL_TestFactory.CreateSObjectList('Opportunity_External_Team__c', false, 1))
        {
            opportunityExternalTeamRecord.Opportunity__c = opportunityList[0].Id;
            opportunityExternalTeamRecord.Contact__c = externalContact.Id;
            opportunityExternalTeamList.add(opportunityExternalTeamRecord);
        }
        insert opportunityExternalTeamList;*/
        
        /*List<Opportunity_Internal_Team__c> opportunityInternalTeamList = new List<Opportunity_Internal_Team__c>();
        for(Opportunity_Internal_Team__c opportunityInternalTeamRecord : (List<Opportunity_Internal_Team__c>)HL_TestFactory.CreateSObjectList('Opportunity_Internal_Team__c', false, 1))
        {
            opportunityInternalTeamRecord.Opportunity__c = opportunityList[0].Id;
            opportunityInternalTeamRecord.Contact__c = hlContactList[0].Id;
            opportunityInternalTeamList.add(opportunityInternalTeamRecord);
        }
        insert opportunityInternalTeamList;*/
        
        i = 0;
        List<Relationship__c> relationshipList = new List<Relationship__c>();
        for(Relationship__c relationshipRecord : (List<Relationship__c>)HL_TestFactory.CreateSObjectList('Relationship__c', false, 1))
        {
            relationshipList.add(new Relationship__c(External_Contact__c = externalContact.Id, 
                                                     HL_Contact__c = hlContactList[0].Id,
                                                     Strength_Rating__c = '2',
                                                     Number_of_Activities_LTM__c = 3, 
                                                     Last_Activity_Date__c = Date.today()));
            i++;                                                    
        }
        insert relationshipList;
        
    }
    
    @isTest
    private static void TestRelationshipTearsheetReport() 
    {       
        List<Contact> hlContactList = [SELECT User__c FROM Contact WHERE RecordType.DeveloperName = 'Houlihan_Employee'];                
        Test.startTest();
        
        System.currentPageReference().getParameters().put('Id','' + hlContactList[0].Id);
        SL_RelationshipTearsheet_Report objRTP = new SL_RelationshipTearsheet_Report();
        objRTP.GetReportData();
        objRTP.GetMostActiveHLRelationship();
        objRTP.GetMostRecentActivities();
        objRTP.GetEngagementHistory();
        objRTP.GetOpenOpportunities();
        objRTP.GetReferralFeesHistory();
        objRTP.GetDealsShown();
        objRTP.GetConferenceAttendance();
        objRTP.GetCareerInformation();
        objRTP.GetBoardInformation();
        
        Test.stopTest();
        
        System.assert(!ApexPages.hasMessages(ApexPages.severity.ERROR));
    }
}