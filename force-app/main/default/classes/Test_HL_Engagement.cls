@isTest
private class Test_HL_Engagement {
    @testSetup
    static void SetupEngagementData(){
        Contact contactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        contactRecord.User__c = UserInfo.getUserId();      
        insert contactRecord;
        
        Engagement__c engagementRecord = HL_TestFactory.CreateEngagement(false);
        engagementRecord.Stage__c = 'Closed';
        engagementRecord.Close_Date__c = Date.today().AddMonths(-1);
        List<String> teamRoleList = new List<String> {'Principal','Seller','Manager','Associate','Initiator'};
        List<Engagement_Internal_Team__c> engagementTeamList = (List<Engagement_Internal_Team__c>)HL_TestFactory.CreateSObjectList('Engagement_Internal_Team__c', false, teamRoleList.size());
        List<Staff_Role__c> staffRoleList = new List<Staff_Role__c>();
        insert engagementRecord;
  
        for(Integer i = 0; i<teamRoleList.size(); i++)
            staffRoleList.add(new Staff_Role__c(Name=teamRoleList[i], Display_Name__c = teamRoleList[i], CF__c = true, FAS__c = true));
        
        insert staffRoleList;
        for(Integer i = 0; i<teamRoleList.size(); i++)
        {
            engagementTeamList[i].Engagement__c = engagementRecord.Id;
            engagementTeamList[i].Staff_Role__c = staffRoleList[i].Id;
            engagementTeamList[i].Contact__c = contactRecord.Id;
            engagementTeamList[i].Start_Date__c = Date.today().AddMonths(-2);
        }

        insert engagementTeamList;
    }
    
    @isTest 
    private static void TestGetByUser(){
        Test.startTest();
        
        List<Engagement__c> engByUserList = HL_Engagement.GetByUser(UserInfo.getUserId(), new Set<String>{'Active','Closed', 'Hold'});
        List<Engagement__c> engByUserWithDateList = HL_Engagement.GetByUser(UserInfo.getUserId(), new Set<String>{'Closed'}, Date.today().addMonths(-2));
        List<Engagement__c> engByUserPointInTimeList = HL_Engagement.GetByUserAtPointInTime(UserInfo.getUserId(), Date.today().addMonths(-2), Date.today(), Date.today().addMonths(-2));
        //Confirm no results if there is no data
        List<Engagement__c> engByUserWithDateNoResultList = HL_Engagement.GetByUser(UserInfo.getUserId(), new Set<String>{'Active','Closed', 'Hold'}, Date.today());
        //Test with Null User
        List<Engagement__c> engByUserNullUserList = HL_Engagement.GetByUser(null, new Set<String>{'Active','Closed', 'Hold'});
        List<Engagement__c> engByUserWithDateNullUserList = HL_Engagement.GetByUser(null, new Set<String>{'Closed'}, Date.today().addMonths(-2));
        List<Engagement__c> engByUserPointInTimeNullUserList = HL_Engagement.GetByUserAtPointInTime(null, Date.today().addMonths(-2), Date.today(), Date.today().addMonths(-2));
        
        Test.stopTest();
        
        System.assert(engByUserList.size() > 0);
        System.assert(engByUserWithDateList.size() > 0);
        System.assert(engByUserPointInTimeList.size() > 0);
        System.assert(engByUserWithDateNoResultList.size() == 0);
        System.assert(engByUserNullUserList.size() > 0);
        System.assert(engByUserWithDateNullUserList.size() > 0);
        System.assert(engByUserPointInTimeNullUserList.size() > 0);
    }
    
    @isTest 
    private static void TestGetEngagementMapByContacts(){
        List<Contact> contactList = [SELECT Id FROM Contact];
        
        Test.startTest();
        
        Map<Id, Set<Id>> engagementMap = HL_Engagement.GetEngagementMapByContacts(new Set<Id> {contactList[0].Id}, new Set<String>{'Active','Closed', 'Hold'});
        
        Test.stopTest();
        
        System.assert(engagementMap.size() > 0);
    }

    @isTest 
    private static void TestMailMerge(){
        Engagement__c engagementRecord = (Engagement__c)HL_TestFactory.CreateSObject('Engagement__c', false);
        engagementRecord.Name = 'Test Engagement';
        engagementRecord.Engagement_Number__c = '123456';
        insert engagementRecord;
        
        Test.startTest();
        
        Engagement__c eMailMerge = HL_Engagement.GetMailMerge(engagementRecord.Id);
        
        Test.stopTest();
        
        System.assertEquals(eMailMerge.Id, engagementRecord.Id);
    }
}