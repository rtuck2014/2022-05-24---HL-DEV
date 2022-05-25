@isTest
private class Test_HL_MyObjectComponentController{
    private static final integer MobileSearchResultDefault =10;
    private static final integer MobileSearchResultLimit =20;
  @isTest
    private static void TestRetrievalOfCustomLimitSettings(){
        HL_General__c customSettings = new HL_General__c(Mobile_Search_Result_Default__c = MobileSearchResultDefault,
                                                    Mobile_Search_Result_Limit__c = MobileSearchResultLimit);
        insert customSettings;

        Test.startTest();

        integer mobileSearchResultsDefault = HL_MyObjectComponentController.GetMobileSearchResultDefault();
        integer mobileSearchResultsLimit = HL_MyObjectComponentController.GetMobileSearchResultLimit();

        Test.stopTest();

        System.assertEquals(customSettings.Mobile_Search_Result_Default__c, mobileSearchResultsDefault);
        System.assertEquals(customSettings.Mobile_Search_Result_Limit__c, mobileSearchResultsLimit);
    }

    @isTest
    private static void TestFindContactByName(){
        Contact contactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact,false);
        insert contactRecord;

        Test.startTest();

        Test.setFixedSearchResults(new List<Id>{contactRecord.Id});

        List<Contact> contactResultsList = HL_MyObjectComponentController.FindByName('Contact', 'Test', false, MobileSearchResultDefault);

        Test.stopTest();

        System.assertEquals(1, contactResultsList.size());
    }

    @isTest
    private static void TestFindContactByNameNoResults(){
        Contact contactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact,false);
        insert contactRecord;

        Test.startTest();

        List<Contact> contactResultsList = HL_MyObjectComponentController.FindByName('Contact', 'ZZ', false, MobileSearchResultDefault);

        Test.stopTest();

        System.assertEquals(0, contactResultsList.size());
    }

    @isTest
    private static void TestFindContactByNameUsingMultipleNameParts(){
        Contact contactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact,false);
        contactRecord.FirstName = 'Jack';
        contactRecord.LastName = 'Banker';
        insert contactRecord;

        Test.startTest();

        Test.setFixedSearchResults(new List<Id>{contactRecord.Id});

        List<Contact> contactResultsList = HL_MyObjectComponentController.FindByName('Contact', 'Jack Banker', false, MobileSearchResultDefault);

        Test.stopTest();

        System.assertEquals(1, contactResultsList.size());
    }

    @isTest
    private static void TestFindMyContactByName(){
        Contact houlihanContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        houlihanContactRecord.User__c = UserInfo.getUserId();
        insert houlihanContactRecord;
        Contact externalContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact,false);
        insert externalContactRecord;
        Relationship__c relationshipRecord = (Relationship__c)HL_TestFactory.CreateSObject('Relationship__c',false);
        relationshipRecord.External_Contact__c = externalContactRecord.Id;
        relationshipRecord.HL_Contact__c = houlihanContactRecord.Id;
        insert relationshipRecord;

        Test.startTest();

        List<Contact> contactResultsList = HL_MyObjectComponentController.FindByName('Contact', 'Test', true, MobileSearchResultDefault);

        Test.stopTest();

        System.assertEquals(1, contactResultsList.size());
    }

    @isTest
    private static void TestFindMyContactsDefaultResults(){
        Contact houlihanContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        houlihanContactRecord.User__c = UserInfo.getUserId();
        insert houlihanContactRecord;
        List<Contact> externalContactList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.External_Contact, false, MobileSearchResultLimit);
        insert externalContactList;
        List<Relationship__c> relationshipList = (List<Relationship__c>)HL_TestFactory.CreateSObjectList('Relationship__c', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++){
            relationshipList[index].External_Contact__c = externalContactList[index].Id;
            relationshipList[index].HL_Contact__c = houlihanContactRecord.Id;
        }
        insert relationshipList;

        Test.startTest();

        List<Contact> contactResultList = HL_MyObjectComponentController.FindByName('Contact', 'Test', true, MobileSearchResultDefault);

        Test.stopTest();

        System.assertEquals(MobileSearchResultDefault, contactResultList.size());
    }

    @isTest
    private static void TestFindMyContactsShowMoreResults(){
        Contact houlihanContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        houlihanContactRecord.User__c = UserInfo.getUserId();
        insert houlihanContactRecord;
        List<Contact> externalContactList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.External_Contact, false, MobileSearchResultLimit);
        insert externalContactList;
        List<Relationship__c> relationshipList = (List<Relationship__c>)HL_TestFactory.CreateSObjectList('Relationship__c', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++){
            relationshipList[index].External_Contact__c = externalContactList[index].Id;
            relationshipList[index].HL_Contact__c = houlihanContactRecord.Id;
        }
        insert relationshipList;

        Test.startTest();
    
        List<Contact> contactResultList = HL_MyObjectComponentController.FindByName('Contact', 'Test', true, MobileSearchResultLimit);

        Test.stopTest();

        System.assertEquals(MobileSearchResultLimit, contactResultList.size());
    }

    @isTest
    private static void TestFindContactsDefaultResults(){
        Contact houlihanContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        houlihanContactRecord.User__c = UserInfo.getUserId();
        insert houlihanContactRecord;
        List<Contact> externalContactList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.External_Contact, false, MobileSearchResultLimit);
        insert externalContactList;

        Test.startTest();
    
        Test.setFixedSearchResults(new List<Id>(new Map<Id, Contact>([SELECT Id FROM Contact]).keySet()));
        List<Contact> contactResultList = HL_MyObjectComponentController.FindByName('Contact', 'Test', false, MobileSearchResultDefault);

        Test.stopTest();

        System.assertEquals(MobileSearchResultDefault, contactResultList.size());
    }

    @isTest
    private static void TestFindContactsShowMoreResults(){
        Contact houlihanContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        houlihanContactRecord.User__c = UserInfo.getUserId();
        insert houlihanContactRecord;
        List<Contact> externalContactList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.External_Contact, false, MobileSearchResultLimit);
        insert externalContactList;

        Test.startTest();
    
        Test.setFixedSearchResults(new List<Id>(new Map<Id, Contact>([SELECT Id FROM Contact]).keySet()));
        List<Contact> contactResultList = HL_MyObjectComponentController.FindByName('Contact', 'Test', false, MobileSearchResultLimit);

        Test.stopTest();

        System.assertEquals(MobileSearchResultLimit, contactResultList.size());
    }

    @isTest
    private static void TestFindAccountByName(){
        Account accountRecord = (Account)HL_TestFactory.CreateSObject('Account', false);
        accountRecord.Name = 'Test Account';
        insert accountRecord;

        Test.startTest();

        Test.setFixedSearchResults(new List<Id>{accountRecord.Id});

        List<Account> accountResultsList = HL_MyObjectComponentController.FindByName('Company', 'Te', false, MobileSearchResultDefault);

        Test.stopTest();

        System.assertEquals(1, accountResultsList.size());
    }

    @isTest
    private static void TestFindMyAccountByName(){
        Account accountRecord = (Account)HL_TestFactory.CreateSObject('Account', false);
        accountRecord.Name = 'Test Account';
        insert accountRecord;
        Contact houlihanContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        houlihanContactRecord.User__c = UserInfo.getUserId();
        insert houlihanContactRecord;
        Contact externalContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact,false);
        externalContactRecord.AccountId = accountRecord.Id;
        insert externalContactRecord;
        Relationship__c relationshipRecord = (Relationship__c)HL_TestFactory.CreateSObject('Relationship__c',false);
        relationshipRecord.External_Contact__c = externalContactRecord.Id;
        relationshipRecord.HL_Contact__c = houlihanContactRecord.Id;
        insert relationshipRecord;

        Test.startTest();

        List<Account> accountResultsList = HL_MyObjectComponentController.FindByName('Company', 'Test', true, MobileSearchResultDefault);

        Test.stopTest();

        System.assertEquals(1, accountResultsList.size());
    }

    @isTest
    private static void TestFindMyAccountsDefaultResults(){
        Contact houlihanContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        houlihanContactRecord.User__c = UserInfo.getUserId();
        insert houlihanContactRecord;
        List<Account> accountList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++)
            accountList[index].Name = 'Test '+ String.valueOf(index);
        insert accountList;
        List<Contact> externalContactList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.External_Contact, false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++){
            externalContactList[index].AccountId = accountList[index].Id;
        }
        insert externalContactList;
        List<Relationship__c> relationshipList = (List<Relationship__c>)HL_TestFactory.CreateSObjectList('Relationship__c', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++){
            relationshipList[index].External_Contact__c = externalContactList[index].Id;
            relationshipList[index].HL_Contact__c = houlihanContactRecord.Id;
        }
        insert relationshipList;

        Test.startTest();

        List<Account> accountResultList = HL_MyObjectComponentController.FindByName('Company', 'Test', true, MobileSearchResultDefault);

        Test.stopTest();

        System.assertEquals(MobileSearchResultDefault, accountResultList.size());
    }

    @isTest
    private static void TestFindMyAccountsShowMoreResults(){
        Contact houlihanContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        houlihanContactRecord.User__c = UserInfo.getUserId();
        insert houlihanContactRecord;
        List<Account> accountList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++)
            accountList[index].Name = 'Test '+ String.valueOf(index);
        insert accountList;
        List<Contact> externalContactList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.External_Contact, false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++){
            externalContactList[index].AccountId = accountList[index].Id;
        }
        insert externalContactList;
        List<Relationship__c> relationshipList = (List<Relationship__c>)HL_TestFactory.CreateSObjectList('Relationship__c', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++){
            relationshipList[index].External_Contact__c = externalContactList[index].Id;
            relationshipList[index].HL_Contact__c = houlihanContactRecord.Id;
        }
        insert relationshipList;

        Test.startTest();

        List<Account> accountResultList = HL_MyObjectComponentController.FindByName('Company', 'Test', true, MobileSearchResultLimit);

        Test.stopTest();

        System.assertEquals(MobileSearchResultLimit, accountResultList.size());
    }

    @isTest
    private static void TestFindAccountsDefaultResults(){
        List<Account> accountList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++)
            accountList[index].Name = 'Test '+ String.valueOf(index);
        insert accountList;

        Test.startTest();
    
        Test.setFixedSearchResults(new List<Id>(new Map<Id, Account>([SELECT Id FROM Account]).keySet()));
        List<Account> accountResultList = HL_MyObjectComponentController.FindByName('Company', 'Test', false, MobileSearchResultDefault);

        Test.stopTest();

        System.assertEquals(MobileSearchResultDefault, accountResultList.size());
    }

    @isTest
    private static void TestFindAccountsShowMoreResults(){
        List<Account> accountList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++)
            accountList[index].Name = 'Test '+ String.valueOf(index);
        insert accountList;

        Test.startTest();
    
        Test.setFixedSearchResults(new List<Id>(new Map<Id, Account>([SELECT Id FROM Account]).keySet()));
        List<Account> accountResultList = HL_MyObjectComponentController.FindByName('Company', 'Test', false, MobileSearchResultLimit);

        Test.stopTest();

        System.assertEquals(MobileSearchResultLimit, accountResultList.size());
    }

    @isTest
    private static void TestFindOpportunityByName(){
        Opportunity__c opportunityRecord = (Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c', false);
        opportunityRecord.Name = 'Test Opportunity';
        insert opportunityRecord;

        Test.startTest();

        Test.setFixedSearchResults(new List<Id>{opportunityRecord.Id});

        List<Opportunity__c> opportunityResultsList = HL_MyObjectComponentController.FindByName('Opportunity', 'Te', false, MobileSearchResultDefault);

        Test.stopTest();

        System.assertEquals(1, opportunityResultsList.size());
    }

    @isTest
    private static void TestFindMyOpportunityByName(){
        Opportunity__c opportunityRecord = (Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c', false);
        opportunityRecord.Name = 'Test Opportunity';
        insert opportunityRecord;
        Contact houlihanContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        houlihanContactRecord.User__c = UserInfo.getUserId();
        insert houlihanContactRecord;
        Opportunity_Internal_Team__c teamRecord = (Opportunity_Internal_Team__c)HL_TestFactory.CreateSObject('Opportunity_Internal_Team__c', false);
        teamRecord.Opportunity__c = opportunityRecord.Id;
        teamRecord.Contact__c = houlihanContactRecord.Id;
        insert teamRecord;

        Test.startTest();

        Test.setFixedSearchResults(new List<Id>{opportunityRecord.Id});

        List<Opportunity__c> opportunityResultsList = HL_MyObjectComponentController.FindByName('Opportunity', 'Te', true, MobileSearchResultDefault);

        Test.stopTest();

        System.assertEquals(1, opportunityResultsList.size());
    }

    @isTest
    private static void TestFindMyOpportunitiesDefaultResults(){
        List<Opportunity__c> opportunityRecordList = (List<Opportunity__c>)HL_TestFactory.CreateSObjectList('Opportunity__c', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++)
            opportunityRecordList[index].Name = 'Test ' + String.valueOf(index);
        insert opportunityRecordList;
        Contact houlihanContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        houlihanContactRecord.User__c = UserInfo.getUserId();
        insert houlihanContactRecord;
        List<Opportunity_Internal_Team__c> teamRecordList = (List<Opportunity_Internal_Team__c>)HL_TestFactory.CreateSObjectList('Opportunity_Internal_Team__c', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++){
            teamRecordList[index].Opportunity__c = opportunityRecordList[index].Id;
            teamRecordList[index].Contact__c = houlihanContactRecord.Id;
        }
        insert teamRecordList;

        Test.startTest();

        List<Opportunity__c> opportunityResultList = HL_MyObjectComponentController.FindByName('Opportunity', 'Test', true, MobileSearchResultDefault);

        Test.stopTest();

        System.assertEquals(MobileSearchResultDefault, opportunityResultList.size());
    }

    @isTest
    private static void TestFindMyOpportunitiesShowMoreResults(){
        List<Opportunity__c> opportunityRecordList = (List<Opportunity__c>)HL_TestFactory.CreateSObjectList('Opportunity__c', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++)
            opportunityRecordList[index].Name = 'Test ' + String.valueOf(index);
        insert opportunityRecordList;
        Contact houlihanContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        houlihanContactRecord.User__c = UserInfo.getUserId();
        insert houlihanContactRecord;
        List<Opportunity_Internal_Team__c> teamRecordList = (List<Opportunity_Internal_Team__c>)HL_TestFactory.CreateSObjectList('Opportunity_Internal_Team__c', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++){
            teamRecordList[index].Opportunity__c = opportunityRecordList[index].Id;
            teamRecordList[index].Contact__c = houlihanContactRecord.Id;
        }
        insert teamRecordList;

        Test.startTest();

        List<Opportunity__c> opportunityResultList = HL_MyObjectComponentController.FindByName('Opportunity', 'Test', true, MobileSearchResultLimit);

        Test.stopTest();

        System.assertEquals(MobileSearchResultLimit, opportunityResultList.size());
    }

    @isTest
    private static void TestFindOpportunitiesDefaultResults(){
        List<Opportunity__c> opportunityRecordList = (List<Opportunity__c>)HL_TestFactory.CreateSObjectList('Opportunity__c', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++)
            opportunityRecordList[index].Name = 'Test ' + String.valueOf(index);
        insert opportunityRecordList;

        Test.startTest();
    
        Test.setFixedSearchResults(new List<Id>(new Map<Id, Opportunity__c>([SELECT Id FROM Opportunity__c]).keySet()));
        List<Opportunity__c> opportunityResultList = HL_MyObjectComponentController.FindByName('Opportunity', 'Test', false, MobileSearchResultDefault);

        Test.stopTest();

        System.assertEquals(MobileSearchResultDefault, opportunityResultList.size());
    }

    @isTest
    private static void TestFindOpportunitiesShowMoreResults(){
        List<Opportunity__c> opportunityRecordList = (List<Opportunity__c>)HL_TestFactory.CreateSObjectList('Opportunity__c', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++)
            opportunityRecordList[index].Name = 'Test ' + String.valueOf(index);
        insert opportunityRecordList;

        Test.startTest();
    
        Test.setFixedSearchResults(new List<Id>(new Map<Id, Opportunity__c>([SELECT Id FROM Opportunity__c]).keySet()));
        List<Opportunity__c> opportunityResultList = HL_MyObjectComponentController.FindByName('Opportunity', 'Test', false, MobileSearchResultLimit);

        Test.stopTest();

        System.assertEquals(MobileSearchResultLimit, opportunityResultList.size());
    }

    @isTest
    private static void TestFindEngagementByName(){
        Engagement__c engagementRecord = (Engagement__c)HL_TestFactory.CreateSObject('Engagement__c', false);
        engagementRecord.Name = 'Test Engagement';
        insert engagementRecord;

        Test.startTest();

        Test.setFixedSearchResults(new List<Id>{engagementRecord.Id});
        List<Engagement__c> engagementResultsList = HL_MyObjectComponentController.FindByName('Engagement', 'Te', false, MobileSearchResultDefault);

        Test.stopTest();

        System.assertEquals(1, engagementResultsList.size());
    }

    @isTest
    private static void TestFindMyEngagementByName(){
        Engagement__c engagementRecord = (Engagement__c)HL_TestFactory.CreateSObject('Engagement__c', false);
        engagementRecord.Name = 'Test Engagement';
        insert engagementRecord;
        Contact houlihanContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        houlihanContactRecord.User__c = UserInfo.getUserId();
        insert houlihanContactRecord;
        Engagement_Internal_Team__c teamRecord = (Engagement_Internal_Team__c)HL_TestFactory.CreateSObject('Engagement_Internal_Team__c', false);
        teamRecord.Engagement__c = engagementRecord.Id;
        teamRecord.Contact__c = houlihanContactRecord.Id;
        insert teamRecord;

        Test.startTest();

        Test.setFixedSearchResults(new List<Id>{engagementRecord.Id});
        List<Engagement__c> engagementResultsList = HL_MyObjectComponentController.FindByName('Engagement', 'Te', true, MobileSearchResultDefault);

        Test.stopTest();

        System.assertEquals(1, engagementResultsList.size());
    }

    @isTest
    private static void TestFindMyEngagementsDefaultResults(){
        List<Engagement__c> engagementRecordList = (List<Engagement__c>)HL_TestFactory.CreateSObjectList('Engagement__c', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++)
            engagementRecordList[index].Name = 'Test ' + String.valueOf(index);
        insert engagementRecordList;
        Contact houlihanContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        houlihanContactRecord.User__c = UserInfo.getUserId();
        insert houlihanContactRecord;
        List<Engagement_Internal_Team__c> teamRecordList = (List<Engagement_Internal_Team__c>)HL_TestFactory.CreateSObjectList('Engagement_Internal_Team__c', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++){
            teamRecordList[index].Engagement__c = engagementRecordList[index].Id;
            teamRecordList[index].Contact__c = houlihanContactRecord.Id;
        }
        insert teamRecordList;

        Test.startTest();

        List<Engagement__c> engagementResultList = HL_MyObjectComponentController.FindByName('Engagement', 'Test', true, MobileSearchResultDefault);

        Test.stopTest();

        System.assertEquals(MobileSearchResultDefault, engagementResultList.size());
    }

    @isTest
    private static void TestFindMyEngagementsShowMoreResults(){
        List<Engagement__c> engagementRecordList = (List<Engagement__c>)HL_TestFactory.CreateSObjectList('Engagement__c', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++)
            engagementRecordList[index].Name = 'Test ' + String.valueOf(index);
        insert engagementRecordList;
        Contact houlihanContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        houlihanContactRecord.User__c = UserInfo.getUserId();
        insert houlihanContactRecord;
        List<Engagement_Internal_Team__c> teamRecordList = (List<Engagement_Internal_Team__c>)HL_TestFactory.CreateSObjectList('Engagement_Internal_Team__c', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++){
            teamRecordList[index].Engagement__c = engagementRecordList[index].Id;
            teamRecordList[index].Contact__c = houlihanContactRecord.Id;
        }
        insert teamRecordList;

        Test.startTest();

        List<Engagement__c> engagementResultList = HL_MyObjectComponentController.FindByName('Engagement', 'Test', true, MobileSearchResultLimit);

        Test.stopTest();

        System.assertEquals(MobileSearchResultLimit, engagementResultList.size());
    }

    @isTest
    private static void TestFindEngagementsDefaultResults(){
        List<Engagement__c> engagementRecordList = (List<Engagement__c>)HL_TestFactory.CreateSObjectList('Engagement__c', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++)
            engagementRecordList[index].Name = 'Test ' + String.valueOf(index);
        insert engagementRecordList;

        Test.startTest();
    
        Test.setFixedSearchResults(new List<Id>(new Map<Id, Engagement__c>([SELECT Id FROM Engagement__c]).keySet()));
        List<Engagement__c> engagementResultList = HL_MyObjectComponentController.FindByName('Engagement', 'Test', false, MobileSearchResultDefault);

        Test.stopTest();

        System.assertEquals(MobileSearchResultDefault, engagementResultList.size());
    }

    @isTest
    private static void TestFindEngagementsShowMoreResults(){
        List<Engagement__c> engagementRecordList = (List<Engagement__c>)HL_TestFactory.CreateSObjectList('Engagement__c', false, MobileSearchResultLimit);
        for(integer index = 0; index < MobileSearchResultLimit; index++)
            engagementRecordList[index].Name = 'Test ' + String.valueOf(index);
        insert engagementRecordList;

        Test.startTest();
    
        Test.setFixedSearchResults(new List<Id>(new Map<Id, Engagement__c>([SELECT Id FROM Engagement__c]).keySet()));
        List<Engagement__c> engagementResultList = HL_MyObjectComponentController.FindByName('Engagement', 'Test', false, MobileSearchResultLimit);

        Test.stopTest();

        System.assertEquals(MobileSearchResultLimit, engagementResultList.size());
    }

    @isTest
    private static void TestFindWithInvalidObjectType(){
        Test.startTest();

        List<sObject> resultsList = HL_MyObjectComponentController.FindByName('Account', 'Te', false, MobileSearchResultDefault);

        Test.stopTest();

        System.assert(resultsList.size() == 0);
    }
}