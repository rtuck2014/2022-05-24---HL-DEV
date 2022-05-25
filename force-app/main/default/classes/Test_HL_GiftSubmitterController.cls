@isTest
private class Test_HL_GiftSubmitterController {
    @testSetup
    private static void SetupSubmitterData(){
        List<Account> acctForContactList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 2);
        List<Contact> internContactList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.Houlihan_Employee, false, 1);
        List<Contact> externContactList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.External_Contact, false, 1);
        List<Gift__c> giftList = (List<Gift__c>)HL_TestFactory.CreateSObjectList('Gift__c', false, 1);

        insert acctForContactList[0];

        internContactList[0].FirstName = 'TestInternFirstContact';
        internContactList[0].LastName = 'TestInternLastContact';
        internContactList[0].Account = AcctForContactList[0];
        internContactList[0].User__c = UserInfo.getUserId();
        insert internContactList[0];

        externContactList[0].FirstName = 'TestExterFirstContact';
        externContactList[0].LastName = 'TestExterLastContact';
        insert externContactList[0];

        giftList[0].Name = 'TestGift';
        giftList[0].Recipient__c = externContactList[0].Id;
        giftList[0].Submitted_For__c = internContactList[0].Id;
        giftList[0].Submitted_By__c = internContactList[0].Id;
        giftList[0].Gift_Type__c = 'Gift: Customers';
        giftList[0].Vendor__c = 'TestVendor';
        giftList[0].Currency__c = 'U.S. Dollar';
        giftList[0].HL_Relationship__c = 'Client';
        giftList[0].Gift_Value__c = 50.00;
        giftList[0].Reason_For_Gift__c = 'Test Reason';
        giftList[0].Approved__c = 'Pending';
        insert giftList[0];
    }

    @isTest
    private static void TestApprovedGifts() {
        Gift__c giftRecord =  [SELECT Name, Approved__c, Submitted_For__r.MailingCountry, CurrencyIsoCode
                               FROM Gift__c
                               LIMIT 1];

        Test.startTest();

        HL_GiftSubmitterController gsc = new HL_GiftSubmitterController();
        gsc.getYearFilterOptions();
        List<SelectOption> opts =  gsc.getApprovalOptions();
        System.assertEquals(3, opts.size());
        List<SL_Gift> savedGiftList = gsc.giftList;
        giftRecord.Approved__c='Approved';
        update giftRecord;
        gsc.viewType = 'Approved';
        gsc.yearFilter = Date.Today().Year();
        gsc.searchGifts();
        savedGiftList = gsc.giftList;

        Test.stopTest();

        System.assertEquals(1, savedGiftList.size());
    }

    @isTest
    private static void TestDeniedGifts() {
        Gift__c giftRecord =  [SELECT Name, Approved__c, Submitted_For__r.MailingCountry, CurrencyIsoCode
                               FROM Gift__c
                               LIMIT 1];

        Test.startTest();

        HL_GiftSubmitterController gsc = new HL_GiftSubmitterController();
        gsc.getYearFilterOptions();
        List<SelectOption> optionList =  gsc.getApprovalOptions();
        List<SL_Gift> savedGiftList = gsc.giftList;
        giftRecord.Approved__c='Denied';
        giftRecord.CurrencyIsoCode='';
        update giftRecord;
        gsc.viewType = 'Denied';
        gsc.searchGifts();
        savedGiftList = gsc.giftList;

        Test.stopTest();

        System.assertEquals(3, optionList.size());
        System.assertEquals(1, savedGiftList.size());
    }

    @isTest
    private static void TestPendingGifts(){
        Gift__c giftRecord =  [SELECT Name, Approved__c, Submitted_For__r.MailingCountry, CurrencyIsoCode
                               FROM Gift__c
                               LIMIT 1];

        Test.startTest();

        HL_GiftSubmitterController gsc = new HL_GiftSubmitterController();
        gsc.getYearFilterOptions();
        List<SelectOption> optionList =  gsc.getApprovalOptions();
        List<SL_Gift> savedGiftList = gsc.giftList;
        giftRecord.Approved__c='Pending';
        update giftRecord;
        gsc.viewType = 'Pending';
        gsc.yearFilter = Date.Today().Year();
        gsc.nameFilter = '';
        gsc.searchGifts();
        savedGiftList = gsc.giftList;
        PageReference pageRef = gsc.AddGift();
        gsc.ApplySort();
        gsc.ToggleDirection('GiftName');

        Test.stopTest();

        System.assertEquals(3, optionList.size());
        System.assertEquals(pageRef.getUrl(), '/apex/SL_GiftPreApproval');
        System.assertEquals(gsc.SortDirection, 'DESC');

    }
}