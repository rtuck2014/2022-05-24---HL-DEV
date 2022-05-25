@isTest
public class Test_SL_GiftApprovalController {
    @isTest
    private static void TestGiftApprovalController_Approved() {
        SL_GiftApprovalController gac = new SL_GiftApprovalController();
        SL_GiftPreApprovalController gpc = new SL_GiftPreApprovalController();

        Test.startTest();

        List<SelectOption> optionSearchList =  gpc.getSearchOptions();
        gac.getYearFilterOptions();
        List<SelectOption> optionApprovalList =  gac.getApprovalOptions();
        gac.NewSort = 'GiftName';
        gac.ToggleDirection('GiftName');
        gac.ApplySort();
        gac.searchGifts();
        gac.viewType = 'Approved';
        gac.giftList.clear();
        List<SL_Gift> savedGiftList = gac.giftList;
        gac.searchGifts();

        Test.stopTest();

        System.assertEquals(4, optionSearchList.size());
        System.assertEquals(3, optionApprovalList.size());
        System.assertEquals(0, savedGiftList.size());
    }

    @isTest
    private static void testGiftApprovalController_Denied() {
        SL_GiftApprovalController gac = new SL_GiftApprovalController();
        SL_GiftPreApprovalController gpc = new SL_GiftPreApprovalController();

        Test.startTest();

        List<SL_Gift> savedGiftList = gac.giftList;
        gac.viewType = 'Denied';
        gac.searchGifts();
        savedGiftList = gac.giftList;

        Test.stopTest();

        System.assertEquals(0, savedGiftList.size());
    }

    @isTest
    private static void testGiftApprovalController_Pending() {
       List<Account> accountList = new List<Account>();
        List<Contact> hlContactList = new List<Contact>{ new Contact(firstName = 'HL', lastName = 'Employee', RecordTypeId = '012i0000000tEheAAE', MailingCountry='United States') };
        List<Contact> externalContactList = new List<Contact>();
        Account a1 = new Account(Name = 'ABC Company', AccountNumber = '123456');
        accountList.add(a1);
        Account a2 = new Account(Name = 'DEF Company', AccountNumber = '987654');
        accountList.add(a2);
        insert accountList;

        for (Integer i = 0; i < 5; i++) {
            Contact c = new Contact(firstName = 'User' + i, lastName = 'Name' + i, RecordTypeId = '012i0000000tEhjAAE', AccountId = accountList.get(0).Id);
            externalContactList.add(c);
        }
        for (Integer i = 5; i < 10; i++) {
            Contact c = new Contact(firstName = 'User' + i, lastName = 'Name' + i, RecordTypeId = '012i0000000tEhjAAE', AccountId = accountList.get(1).Id);
            externalContactList.add(c);
        }
        insert externalContactList;

        hlContactList.add(new Contact(firstName = 'HL', lastName = 'Employee', RecordTypeId = '012i0000000tEheAAE', MailingCountry='France'));
        insert hlContactList;

        Gift__c gift = new Gift__c();
        gift.Gift_Type__c = 'Gift: Customers';
        gift.Submitted_For__c = hlContactList[0].Id ;
        gift.Name = 'Sees Candy';
        gift.Gift_Value__c = 25.00;
        gift.CurrencyIsoCode = 'USD';
        gift.Approved__c = 'Pending';
        gift.Desired_Date__c = System.today();
        gift.Recipient__c = externalContactList[0].id;
        insert gift;
        Contact c = [Select Id, ( SELECT Gift_Value__C, Approved__c, Desired_Date__c FROM Gifts__r) FROM Contact WHERE id=:externalContactList[0].id LIMIT 1];
        SL_GiftRecipient gr = new SL_GiftRecipient(c, 0.0,0.0, new Map<String, Double>(),gift.Desired_Date__c, 'USD');
        SL_Gift g = new SL_Gift (gift, 0, 0, gr);
        gift = new Gift__c();
        gift.Gift_Type__c = 'Gift: Customers';
        gift.Submitted_For__c = hlContactList[0].Id;
        gift.Name = 'Sees Candy, 2';
        gift.Gift_Value__c = 33.00;
        gift.CurrencyIsoCode = 'USD';
        gift.Approved__c = 'Pending';
        gift.Gift_Value_Distributed__c = true;
        gift.Recipient__c = externalContactList[0].id;
        insert gift;
        List<Gift__c> giftList = [SELECT Name FROM Gift__c WHERE Recipient__r.id = :externalContactList[0].id];
        System.assertEquals(2, giftList.size());
        SL_GiftApprovalController gac = new SL_GiftApprovalController();
        SL_GiftPreApprovalController gpc = new SL_GiftPreApprovalController();

        Test.startTest();

        List<SL_Gift> savedGiftList = gac.giftList;

        System.debug('THis 1:  ' + savedGiftList);
        gac.viewType = 'Pending';
        gac.yearFilter = Date.Today().Year();
        gac.nameFilter = '';
        gac.MonthFilter = 'Feb';
        savedGiftList = gac.giftList;
        List<SelectOption> yr = gac.GetYearFilterOptions();
        List<SelectOption> no = gac.GetMonthFilterOptions();
        gac.ConversionRates = HL_GiftUtil.GetConversionRates();
        gac.FirstPage();
        gac.previous();
        gac.next();
        Boolean gn = gac.getnxt();
        Boolean gp = gac.getprev();
        gac.SearchGifts();
       // savedGiftList[0].selected = true;
        gac.denySelectedGifts();
        gac.approveSelectedGifts();

        Test.stopTest();

        //System.assertEquals(0, savedGiftList.size());
    }

    @isTest
    static void testGiftController_Pending(){
        List<Account> accountList = new List<Account>();
        List<Contact> hlContactList = new List<Contact>{ new Contact(firstName = 'HL', lastName = 'Employee', RecordTypeId = '012i0000000tEheAAE', MailingCountry='United States') };
        List<Contact> externalContactList = new List<Contact>();
        Account a1 = new Account(Name = 'ABC Company', AccountNumber = '123456');
        accountList.add(a1);
        Account a2 = new Account(Name = 'DEF Company', AccountNumber = '987654');
        accountList.add(a2);
        insert accountList;

        for (Integer i = 0; i < 5; i++) {
            Contact c = new Contact(firstName = 'User' + i, lastName = 'Name' + i, RecordTypeId = '012i0000000tEhjAAE', AccountId = accountList.get(0).Id);
            externalContactList.add(c);
        }
        for (Integer i = 5; i < 10; i++) {
            Contact c = new Contact(firstName = 'User' + i, lastName = 'Name' + i, RecordTypeId = '012i0000000tEhjAAE', AccountId = accountList.get(1).Id);
            externalContactList.add(c);
        }
        insert externalContactList;

        hlContactList.add(new Contact(firstName = 'HL', lastName = 'Employee', RecordTypeId = '012i0000000tEheAAE', MailingCountry='France'));
        insert hlContactList;

        Gift__c gift = new Gift__c();
        gift.Gift_Type__c = 'Gift: Customers';
        gift.Submitted_For__c = hlContactList[0].Id ;
        gift.Name = 'Sees Candy';
        gift.Gift_Value__c = 25.00;
        gift.CurrencyIsoCode = 'USD';
        gift.Approved__c = 'Pending';
        gift.Desired_Date__c = System.today();
        gift.Recipient__c = externalContactList[0].id;
        insert gift;
        Contact c = [Select Id, ( SELECT Gift_Value__C, Approved__c, Desired_Date__c FROM Gifts__r) FROM Contact WHERE id=:externalContactList[0].id LIMIT 1];
        SL_GiftRecipient gr = new SL_GiftRecipient(c, 0.0,0.0, new Map<String, Double>(),gift.Desired_Date__c, 'USD');
        SL_Gift g = new SL_Gift (gift, 0, 0, gr);
        gift = new Gift__c();
        gift.Gift_Type__c = 'Gift: Customers';
        gift.Submitted_For__c = hlContactList[0].Id;
        gift.Name = 'Sees Candy, 2';
        gift.Gift_Value__c = 33.00;
        gift.CurrencyIsoCode = 'USD';
        gift.Approved__c = 'Pending';
        gift.Gift_Value_Distributed__c = true;
        gift.Recipient__c = externalContactList[0].id;
        insert gift;
        List<Gift__c> giftList = [SELECT Name FROM Gift__c WHERE Recipient__r.id = :externalContactList[0].id];
        System.assertEquals(2, giftList.size());
        SL_GiftApprovalController gac = new SL_GiftApprovalController();
        SL_GiftPreApprovalController gpc = new SL_GiftPreApprovalController();
        List<SL_Gift> sg = new List<SL_Gift>{g};

        Pagereference pager = page.SL_GiftApproval;
        Test.setCurrentPage(pager);
        gac.GiftList = sg;
        System.debug('Gift [sg] to Approve are:  ' + sg);
        System.debug('Gift [gac.GiftList] to Approve are:  ' + gac.GiftList);
        gac.MonthFilter = 'Feb';
        gac.YearFilter = Date.Today().Year();
        gac.ViewType = 'Pending';
        gac.SearchGifts();
        System.debug('SearchGifts() ' + gac.SearchGifts());
        gac.ApproveSelectedGifts();
    }
}