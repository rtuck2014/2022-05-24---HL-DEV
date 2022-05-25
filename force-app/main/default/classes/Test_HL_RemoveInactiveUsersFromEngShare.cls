@isTest(SeeAllData=False)
private class Test_HL_RemoveInactiveUsersFromEngShare {
    @testSetup
    private static void CreateData()
    {
        List<User> userList;
        List<Engagement__c> engagementList;
        List<Engagement_Internal_Team__c> eitList;
        List<Delegate_Public_Group__c> dpgList;
        Monthly_Revenue_Process_Control__c mrpcNew = new Monthly_Revenue_Process_Control__c(IsCurrent__c = TRUE,Current_Month__c = '02', Current_Year__c = '2015');
        insert mrpcNew;
        Profile objProfile = [SELECT Name
                              FROM Profile
                              WHERE Name = 'Solution Manager'];

        integer i = 0;
        integer j = 0;
        userList = new List<User>();
        for(User userRecord : (List<User>)HL_TestFactory.CreateSObjectList('User', false, 3))
        {
            userRecord.Lastname = 'User';
            userRecord.Email = 'tuser@yahoo.in';
            userRecord.Username =  i+'test543552542@hl2.com';
            userRecord.ProfileId = objProfile.Id;
            userRecord.Alias = 'tuser';
            userRecord.TimeZoneSidKey = 'GMT';
            userRecord.LocaleSidKey = 'en_US';
            userRecord.EmailEncodingKey = 'ISO-8859-1';
            userRecord.LanguageLocaleKey = 'en_US';
            userRecord.Has_Delegates__c = false;
            userRecord.IsActive = true;
            userList.add(userRecord);
            i++;
        }
        insert userList;

        List<Account> accountList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 1);
        insert accountList;

        i = 0;
        List<Contact> hlContactList = new List<Contact>();
        for(Contact contactRecord : HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.Houlihan_Employee, false, 3))
        {
            contactRecord.AccountId = accountList[0].Id;
            contactRecord.User__c = userList[i].Id;
            hlContactList.add(contactRecord);
            i++;
        }
        insert hlContactList;

        dpgList = new List<Delegate_Public_Group__c>();
        for(Delegate_Public_Group__c dpgRecord : (List<Delegate_Public_Group__c>)HL_TestFactory.CreateSObjectList('Delegate_Public_Group__c', false, 1))
        {
            dpgRecord.Banker__c = userList[0].Id;
            dpgList.add(dpgRecord);
        }
        insert dpgList;

        engagementList = new List<Engagement__c>();
        for(Engagement__c engagementRecord : HL_TestFactory.CreateEngagementList(false, 2))
        {
            engagementRecord.Client__c = accountList[0].Id;
            engagementRecord.Subject__c = accountList[0].Id;
            engagementList.add(engagementRecord);
        }
        insert engagementList;

        i = 0;
        List<Engagement_Counterparty__c> engagementCounterpartyList = new  List<Engagement_Counterparty__c>();
        for(Engagement_Counterparty__c engagementCounterpartyRecord : (List<Engagement_Counterparty__c>)HL_TestFactory.CreateSObjectList('Engagement_Counterparty__c', false, 4))
        {
            if(i>1)
                j = 1;
            engagementCounterpartyRecord.Company__c = accountList[0].Id;
            engagementCounterpartyRecord.Engagement__c = engagementList[j].Id;
            engagementCounterpartyList.add(engagementCounterpartyRecord);
            i++;
        }
        insert engagementCounterpartyList;

        List<Revenue_Accrual__c> revenueAccrualList = new List<Revenue_Accrual__c>{new Revenue_Accrual__c(Engagement__c = engagementList[0].Id, Month__c = 'Jan', Year__c = '2014'),
                                                                                   new Revenue_Accrual__c(Engagement__c = engagementList[1].Id, Month__c = 'Feb', Year__c = '2015')};
        insert revenueAccrualList;

        i = 0; j = 0;
        eitList = new List<Engagement_Internal_Team__c>();
        for(Engagement_Internal_Team__c eitRecord : (List<Engagement_Internal_Team__c>)HL_TestFactory.CreateSObjectList('Engagement_Internal_Team__c', false, 6))
        {
            if(i > 2)
            {
                i = 0;
                j = 1;
            }
            eitRecord.Contact__c = hlContactList[i].Id;
            eitRecord.Engagement__c = engagementList[j].Id;
            eitRecord.End_Date__c = Date.today();
            eitRecord.Start_Date__c = Date.today();
            eitList.add(eitRecord);
            i++;
        }
        insert eitList;
    }

    @isTest
    private static void TestRemoveInactiveUsersFromEngShare()
    {
        List<User> userList = [SELECT IsActive FROM User];

        userList[0].IsActive = false;

        Test.startTest();

        update userList[0];
        SL_Batch_RemoveInactiveUsersFromEngShare objBatchRIU = new SL_Batch_RemoveInactiveUsersFromEngShare();
        Database.executeBatch(objBatchRIU, 50);

        Test.stopTest();

      //  System.assertEquals([SELECT Id FROM Engagement__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 6); 
    }

    @isTest
    private static void TestUpdateEndDateCase()
    {
        List<Engagement_Internal_Team__c> eitList = [SELECT End_Date__c FROM Engagement_Internal_Team__c];

        Test.startTest();

        eitList[0].End_Date__c = Date.today().addDays(-2);
        update eitList[0];

        Test.stopTest();

        System.assertEquals([SELECT Id FROM Engagement__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 5);
        System.assertEquals([SELECT Id FROM Engagement_Counterparty__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 10);
        System.assertEquals([SELECT Id FROM Revenue_Accrual__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 5);
    }

    @isTest
    private static void TestOnChangeParentName()
    {
        List<Engagement__c> engagementList = [SELECT Name FROM Engagement__c];

        Test.startTest();

        engagementList[1].Name = 'DNDTestEngagement';
        update engagementList[1];

        Test.stopTest();

        System.assertEquals([SELECT Id FROM Engagement__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 6);
        System.assertEquals([SELECT Id FROM Engagement_Counterparty__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 12);
        System.assertEquals([SELECT Id FROM Revenue_Accrual__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 6);
    }

    @isTest
    private static void TestDNDCase()
    {
        delete [SELECT Id FROM Engagement__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'];

        Test.startTest();

        SL_Batch_RemoveInactiveUsersFromEngShare objBatchRIU = new SL_Batch_RemoveInactiveUsersFromEngShare();
        Database.executeBatch(objBatchRIU, 50);

        Test.stopTest();

        System.assertEquals([SELECT Id FROM Engagement__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 6);
        System.assertEquals([SELECT Id FROM Engagement_Counterparty__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 12);
        System.assertEquals([SELECT Id FROM Revenue_Accrual__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 6);
    }
}