@isTest
private class Test_HL_GiftEditControllerExt {
    @testSetup
    private static void SetupGiftEditData(){
        List<Account> acctForContactList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 2);
        List<Contact> internContactList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.Houlihan_Employee, false, 1);
        List<Contact> externContactList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.External_Contact, false, 1);
        List<Gift__c> giftList = (List<Gift__c>)HL_TestFactory.CreateSObjectList('Gift__c', false, 2);

        insert acctForContactList[0];

        internContactList[0].FirstName = 'TestInternFirstContact';
        internContactList[0].LastName = 'TestInternLastContact';
        internContactList[0].Account = AcctForContactList[0];
        insert internContactList[0];

        externContactList[0].FirstName = 'TestExterFirstContact';
        externContactList[0].LastName = 'TestExterLastContact';
        insert externContactList[0];

        giftList[0].Name='TestGift';
        giftList[0].Recipient__c=ExternContactList[0].Id;
        giftList[0].Submitted_For__c=InternContactList[0].Id;
        giftList[0].Submitted_By__c=InternContactList[0].Id;
        giftList[0].Gift_Type__c='Gift: Customers';
        giftList[0].Vendor__c='TestVendor';
        giftList[0].Currency__c='U.S. Dollar';
        giftList[0].HL_Relationship__c='Client';
        giftList[0].Gift_Value__c=101.00;
        giftList[0].Reason_For_Gift__c='Test Reason';
        giftList[0].Approved__c='Approved';
        giftList[0].Desired_Date__c = Date.today();
        giftList[0].CurrencyIsoCode = 'USD';
        giftList[1].Name='TestGift';
        giftList[1].Recipient__c=ExternContactList[0].Id;
        giftList[1].Submitted_For__c=InternContactList[0].Id;
        giftList[1].Submitted_By__c=InternContactList[0].Id;
        giftList[1].Gift_Type__c='Gift: Customers';
        giftList[1].Vendor__c='TestVendor';
        giftList[1].Currency__c='Euro (in France)';
        giftList[1].HL_Relationship__c='Client';
        giftList[1].Gift_Value__c=0.00;
        giftList[1].Reason_For_Gift__c='Test Reason';
        giftList[1].Approved__c='Approved';
        giftList[1].Desired_Date__c = Date.today();
        giftList[1].CurrencyIsoCode = 'EUR';
        insert giftList;
    }

    @isTest
    private static void TestGiftEditSave() {
        List<Gift__c> giftList = [SELECT Name, CurrencyIsoCode, Currency__c, Recipient__c, Desired_Date__c, Gift_Value__c FROM Gift__c WHERE CurrencyIsoCode = 'USD'];
        ApexPages.StandardController sc = new ApexPages.StandardController(giftList[0]);
        ApexPages.currentPage().getParameters().put('Id', giftList[0].Id);

        Test.startTest();

        HL_GiftEditControllerExt controllerExt = new HL_GiftEditControllerExt(sc);
        controllerExt.save();

        Test.stopTest();

        List<Gift__c> giftResultList = [SELECT Name, Recipient__r.LastName, Recipient__c
                                        FROM Gift__c
                                        WHERE Name = 'TestGift' LIMIT 1];

        System.assertEquals('TestExterLastContact', giftResultList[0].Recipient__r.LastName);
    }

    @isTest
    private static void TestAddGift(){
        List<Gift__c> giftList = [SELECT Name FROM Gift__c WHERE CurrencyIsoCode = 'USD'];
        ApexPages.StandardController sc = new ApexPages.StandardController(giftList[0]);
        ApexPages.currentPage().getParameters().put('Id', giftList[0].Id);

        Test.startTest();

        HL_GiftEditControllerExt controllerExt = new HL_GiftEditControllerExt(sc);
        String AddPageUrl = controllerExt.AddGift().getUrl();

        Test.stopTest();

        System.assertEquals('/apex/SL_GiftPreApproval', AddPageUrl);
    }

    @isTest
    private static void TestGiftMaxValue(){
        List<Gift__c> giftList = [SELECT Name FROM Gift__c WHERE CurrencyIsoCode = 'USD'];
        Gift__c[] gifts = [SELECT Name, Recipient__r.LastName, Recipient__c, CurrencyIsoCode,Currency__c, Gift_Value__c, Desired_Date__c
                           FROM Gift__c
                           WHERE Name = 'TestGift' LIMIT 1];

        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(gifts[0]);
        ApexPages.currentPage().getParameters().put('Id', giftList[0].Id);
        HL_GiftEditControllerExt controllerExt = new HL_GiftEditControllerExt(sc);
        GiftList[0].Gift_Value__c = 101.00;
        update GiftList[0];
        ApexPages.currentPage().getParameters().put('Id', giftList[0].Id);
        controllerExt.save();

        Test.stopTest();

        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            if(msg.getSeverity() == ApexPages.Severity.WARNING){
                System.assertEquals(ApexPages.Severity.WARNING, msg.getSeverity());
            }else if(msg.getSeverity() == ApexPages.Severity.CONFIRM){
                System.assertEquals(ApexPages.Severity.CONFIRM, msg.getSeverity());
            }
        }
    }

    @isTest
    private static void TestGiftMinValue(){
        List<Gift__c> giftList = [SELECT Name FROM Gift__c];
        Gift__c[] gifts = [SELECT Name, Recipient__r.LastName, Recipient__c, CurrencyIsoCode, Currency__c, Gift_Value__c, Desired_Date__c
                           FROM Gift__c
                           WHERE Name = 'TestGift' LIMIT 2];
        ApexPages.StandardController sc = new ApexPages.StandardController(gifts[1]);
        ApexPages.currentPage().getParameters().put('Id', giftList[1].Id);
        HL_GiftEditControllerExt controllerExt = new HL_GiftEditControllerExt(sc);
        GiftList[1].Gift_Value__c = 0.00;
        GiftList[1].Desired_Date__c=system.today().addDays(-2);
        update GiftList[1];
        ApexPages.currentPage().getParameters().put('Id', giftList[1].Id);

        Test.startTest();

        controllerExt.save();

        Test.stopTest();

        System.assert(ApexPages.hasMessages(ApexPages.severity.ERROR));
    }

    @isTest
    private static void TestCancel(){
        List<Gift__c> giftList = [SELECT Name FROM Gift__c WHERE CurrencyIsoCode = 'USD'];
        ApexPages.StandardController sc = new ApexPages.StandardController(giftList[0]);
        ApexPages.currentPage().getParameters().put('Id', giftList[0].Id);

        Test.startTest();

        HL_GiftEditControllerExt controllerExt = new HL_GiftEditControllerExt(sc);
        controllerExt.ReturnURL='/apex/SL_GiftPreApproval';
        PageReference pageRef = controllerExt.Cancel();

        Test.stopTest();

        System.assertEquals(new PageReference('/apex/SL_GiftPreApproval').getUrl(), pageRef.getUrl());
    }
}