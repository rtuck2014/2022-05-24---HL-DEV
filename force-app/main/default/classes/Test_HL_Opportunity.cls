@isTest
private class Test_HL_Opportunity {
    @testSetup
    static void SetupOpportunityData(){
        Contact contactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        contactRecord.User__c = UserInfo.getUserId();      
        insert contactRecord;
        
        Opportunity__c opportunityRecord = (Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c', false);
        opportunityRecord.Stage__c = 'Engaged';
        opportunityRecord.Date_Engaged__c = Date.today().AddMonths(-1);
        List<String> teamRoleList = new List<String> {'Principal','Seller','Manager','Associate','Initiator'};
        List<Opportunity_Internal_Team__c> opportunityTeamList = (List<Opportunity_Internal_Team__c>)HL_TestFactory.CreateSObjectList('Opportunity_Internal_Team__c', false, teamRoleList.size());
        List<Staff_Role__c> staffRoleList = new List<Staff_Role__c>();
        insert opportunityRecord;
  
        for(Integer i = 0; i<teamRoleList.size(); i++)
            staffRoleList.add(new Staff_Role__c(Name=teamRoleList[i], Display_Name__c = teamRoleList[i], CF__c = true, FAS__c = true));
        
        insert staffRoleList;
        for(Integer i = 0; i<teamRoleList.size(); i++)
        {
            opportunityTeamList[i].Opportunity__c = opportunityRecord.Id;
            opportunityTeamList[i].Staff_Role__c = staffRoleList[i].Id;
            opportunityTeamList[i].Contact__c = contactRecord.Id;
        }

        insert opportunityTeamList;
    }

    @isTest 
    private static void TestGetByUser(){
        Test.startTest();
        
        List<Opportunity__c> oppByUserList = HL_Opportunity.GetByUser(UserInfo.getUserId(), new Set<String>{'Active','Engaged', 'Hold'});
        List<Opportunity__c> oppByUserWithDateList = HL_Opportunity.GetByUser(UserInfo.getUserId(), new Set<String>{'Engaged'}, Date.today().addMonths(-2));
        //Confirm no results if there is no data
        List<Opportunity__c> oppByUserWithDateNoResultList = HL_Opportunity.GetByUser(UserInfo.getUserId(), new Set<String>{'Active','Engaged', 'Hold'}, Date.today());
        //Test with Null User
        List<Opportunity__c> oppByUserNullUserList = HL_Opportunity.GetByUser(null, new Set<String>{'Active','Engaged', 'Hold'});
        List<Opportunity__c> oppByUserWithDateNullUserList = HL_Opportunity.GetByUser(null, new Set<String>{'Engaged'}, Date.today().addMonths(-2));
        
        Test.stopTest();
        
        System.assert(oppByUserList.size() > 0);
        System.assert(oppByUserWithDateList.size() > 0);
        System.assert(oppByUserWithDateNoResultList.size() == 0);
        System.assert(oppByUserNullUserList.size() > 0);
        System.assert(oppByUserWithDateNullUserList.size() > 0);
    }
    
    @isTest 
    private static void TestGetOpportunityMapByContacts(){
        List<Contact> contactList = [SELECT Id FROM Contact];
        
        Test.startTest();
        
        Map<Id, Set<Id>> opportunityMap = HL_Opportunity.GetOpportunityMapByContacts(new Set<Id> {contactList[0].Id}, new Set<String>{'Active','Engaged', 'Hold'});
        
        Test.stopTest();
        
        System.assert(opportunityMap.size() > 0);
    }
}