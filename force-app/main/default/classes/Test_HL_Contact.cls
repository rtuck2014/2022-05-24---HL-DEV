@isTest
private class Test_HL_Contact {
    @isTest 
    private static void TestGetById(){
        Contact externalContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact,false);
        insert externalContactRecord;
        
        Test.startTest();
        
        Contact contactResult = HL_Contact.GetById(externalContactRecord.Id);
        
        Test.stopTest();
        
        System.assertEquals(externalContactRecord.Id, contactResult.Id);
    }
    
    @isTest
    private static void TestGetByCompany(){
        Account accountRecord = (Account)HL_TestFactory.CreateSObject('Account', false);
        accountRecord.Name = 'Test Account';
        insert accountRecord;
        Contact externalContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact,false);
        externalContactRecord.AccountId = accountRecord.Id;
        insert externalContactRecord;
        
        Test.startTest();
        
        List<Contact> contactResultsList = HL_Contact.GetByCompany(accountRecord.Id);
        
        Test.stopTest();
        
        System.assertEquals(1, contactResultsList.size());
    }
    
    @isTest
    private static void TestGetByUserId(){
        Contact houlihanContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        houlihanContactRecord.User__c = UserInfo.getUserId();
        insert houlihanContactRecord;
        
        Test.startTest();
        
        Contact contactResult = HL_Contact.GetByUserId();
        
        Test.stopTest();
        
        System.assertEquals(houlihanContactRecord.Id, contactResult.Id);
    }
    
    @isTest
    private static void TestGetList(){
        final integer contactRecordCount = 20;
        List<Contact> contactList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.External_Contact, false, contactRecordCount);
        insert contactList;
        
        Test.startTest();
        
        List<Contact> contactResultsList = HL_Contact.GetList(contactList);
        
        Test.stopTest();
        
        System.assertEquals(contactRecordCount, contactResultsList.size());
    }
    
    @isTest
    private static void TestGetMap(){
        final integer contactRecordCount = 20;
        List<Contact> contactList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.External_Contact, false, contactRecordCount);
        insert contactList;
        
        Test.startTest();
        
        Map<Id, Contact> contactResultsMap = HL_Contact.GetMap(contactList);
        
        Test.stopTest();
        
        System.assertEquals(contactRecordCount, contactResultsMap.size());
    }
    
    @isTest
    private static void TestGetListByUsers(){
        final integer contactRecordCount = 20;
        List<User> userList = (List<User>)HL_TestFactory.CreateSObjectList('User', false, contactRecordCount);
        insert userList;
        List<Contact> contactList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.Houlihan_Employee, false, contactRecordCount);
        for(integer index = 0; index < contactRecordCount; index++)
            contactList[index].User__c = userList[index].Id;
        insert contactList;
        
        Test.startTest();
        
        List<Contact> contactResultsList = HL_Contact.GetListByUsers(userList);
        
        Test.stopTest();
        
        System.assertEquals(contactRecordCount, contactResultsList.size());
    }
    
    @isTest
    private static void TestGetMapByUsers(){
        final integer contactRecordCount = 20;
        List<User> userList = (List<User>)HL_TestFactory.CreateSObjectList('User', false, contactRecordCount);
        insert userList;
        List<Contact> contactList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.Houlihan_Employee, false, contactRecordCount);
        for(integer index = 0; index < contactRecordCount; index++)
            contactList[index].User__c = userList[index].Id;
        insert contactList;
        
        Test.startTest();
        
        Map<Id, Contact> contactResultsMap = HL_Contact.GetMapByUsers(userList);
        
        Test.stopTest();
        
        System.assertEquals(contactRecordCount, contactResultsMap.size());
    }
}