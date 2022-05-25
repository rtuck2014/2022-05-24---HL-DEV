@isTest
public class Test_SL_GiftPreApprovalController {
    private static SL_GiftPreApprovalController gpc = new SL_GiftPreApprovalController();
    private static Gift__c gift = new Gift__c();

    @testSetup
    private static void TestGiftDataSetup(){
        List<Account> accountList = new List<Account>();
        List<Contact> hlContactList = new List<Contact>{ new Contact(firstName = 'HL', lastName = 'Employee', RecordTypeId = '012i0000000tEheAAE', MailingCountry='United States') };
            List<Contact> externalContactList = new List<Contact>();
        Account a1 = new Account(Name = 'ABC Company', AccountNumber = '123456');
        accountList.add(a1);
        Account a2 = new Account(Name = 'DEF Company', AccountNumber = '987654');
        accountList.add(a2);
        insert accountList;

        for (Integer i = 0; i < 5; i++) {
            Contact c = new Contact(FirstName = 'User' + i, LastName = 'Name' + i, RecordTypeId = '012i0000000tEhjAAE', AccountId = accountList.get(0).Id);
            externalContactList.add(c);
        }
        for (Integer i = 5; i < 10; i++) {
            Contact c = new Contact(FirstName = 'User' + i, LastName = 'Name' + i, RecordTypeId = '012i0000000tEhjAAE', AccountId = accountList.get(1).Id);
            externalContactList.add(c);
        }
        insert externalContactList;

        hlContactList.add (new Contact(FirstName = 'HL', LastName = 'Employee', RecordTypeId = '012i0000000tEheAAE', MailingCountry='France'));
        insert hlContactList;
        gift.Gift_Type__c = 'Gift: Customers';
        gift.Submitted_For__c = hlContactList[0].Id ;
        gift.Name = 'Sees Candy';
        gift.Gift_Value__c = 25.00;
        gift.CurrencyIsoCode = 'USD';
        gift.Desired_Date__c = Date.today();
        gift.Approved__c = 'Approved';
        gift.Recipient__c = externalContactList[0].id;
        insert gift;
        Contact c = [Select Id, ( SELECT Gift_Value__C, Approved__c, Desired_Date__c FROM Gifts__r) FROM Contact WHERE id=: externalContactList[0].id LIMIT 1];
        SL_GiftRecipient gr = new SL_GiftRecipient(c,0.0,0.0, new Map<String, Double>(),gift.Desired_Date__c, 'USD');
        SL_Gift g = new SL_Gift (gift,0,0,gr);
        gift = new Gift__c();
        gift.Gift_Type__c = 'Gift: Customers';
        gift.Submitted_For__c = hlContactList[0].Id;
        gift.Name = 'Sees Candy, 2';
        gift.Gift_Value__c = 33.00;
        gift.CurrencyIsoCode = 'USD';
        gift.Approved__c = 'Pending';
        gift.Desired_Date__c = Date.today();
        gift.Gift_Value_Distributed__c = true;
        gift.Recipient__c = externalContactList[0].id;
        insert gift;
    }

    @isTest
    private static void TestGiftRecepients() {
        List<SelectOption> opts =  gpc.getSearchOptions();
        System.assertEquals(4, opts.size());
        Boolean caughtException = false;

        String retSearchMessage = 'Records returned: 10 (max 1000).';
        gpc.searchTextAccount = '';
        gpc.searchOptionAccount = 'contains';

        gpc.searchTextContact = '';
        gpc.searchTextAccount = '';
        gpc.searchOptionContact = 'contains';
        gpc.searchRecipients();
        System.assertEquals('You must enter at least one search term.', gpc.searchMessage);

        gpc.searchTextContact = 'u';
        gpc.searchOptionContact = 'contains';
        gpc.searchRecipients();
        System.assertEquals(10, gpc.getAllRecipientsList().size());

        System.assertEquals(25, gpc.getAllRecipientsList().get(0).recipient.Gifts__r.get(0).Gift_Value__c);
        System.assertEquals('ABC Company', gpc.getAllRecipientsList().get(0).recipient.Account.Name);
        System.assertEquals(retSearchMessage, gpc.searchMessage);

        gpc.searchTextContact = 'u';
        gpc.searchOptionContact = 'startswith';
        gpc.searchRecipients();
        System.assertEquals(10, gpc.getAllRecipientsList().size());
        System.assertEquals(25, gpc.getAllRecipientsList().get(0).recipient.Gifts__r.get(0).Gift_Value__c);
        System.assertEquals(retSearchMessage, gpc.searchMessage);

        gpc.searchTextContact = 'User0';
        gpc.searchOptionContact = 'startswith';
        gpc.searchRecipients();
        System.assertEquals(1, gpc.getAllRecipientsList().size());

        gpc.searchTextContact = 'Name0';
        gpc.searchOptionContact = 'endswith';
        gpc.searchRecipients();
        System.assertEquals(1, gpc.getAllRecipientsList().size());

        gpc.searchTextContact = 'User0 Name0';
        gpc.searchOptionContact = 'exact';
        gpc.searchRecipients();
        System.assertEquals(1, gpc.getAllRecipientsList().size());

        gpc.searchTextContact = '';
        gpc.searchOptionContact = 'contains';

        gpc.searchTextAccount = 'om';
        gpc.searchOptionAccount = 'contains';
        gpc.searchRecipients();
        System.assertEquals(10, gpc.getAllRecipientsList().size());

        gpc.searchTextAccount = 'abc';
        gpc.searchOptionAccount = 'startswith';
        gpc.searchRecipients();
        System.assertEquals(5, gpc.getAllRecipientsList().size());

        gpc.searchTextAccount = 'any';
        gpc.searchOptionAccount = 'endswith';
        gpc.searchRecipients();
        System.assertEquals(10, gpc.getAllRecipientsList().size());

        gpc.searchTextAccount = 'DEF Company';
        gpc.searchOptionAccount = 'exact';
        gpc.searchRecipients();
        System.assertEquals(5, gpc.getAllRecipientsList().size());
    }

    @isTest
    private static void TestGetAllRecipients() {
        gpc.searchTextAccount = '';
        gpc.searchOptionAccount = 'contains';
        gpc.searchTextContact = 'u';
        gpc.searchOptionContact = 'contains';
        gpc.searchRecipients();

        Test.startTest();

        List<SL_GiftRecipient> allRecipientList = gpc.getAllRecipientsList();

        Test.stopTest();

        System.assertEquals(10, allRecipientList.size());
        System.assertEquals(false, allRecipientList[0].GetWasOver());
        System.assertEquals(false, allRecipientList[0].GetIsOver());
    }

    @isTest
    private static void testSelectedRecipients() {
        gpc.searchTextAccount = '';
        gpc.searchOptionAccount = 'contains';
        gpc.searchTextContact = 'u';
        gpc.searchOptionContact = 'contains';

        Test.startTest();

        gpc.searchRecipients();
        gpc.getAllRecipientsList().get(1).selected = true;
        gpc.addSelectedRecipients();
        gpc.getSelRecipientsList().get(0).selected = true;

        Test.stopTest();

        System.assertEquals(true, gpc.getAllRecipientsList().get(1).selected);
        System.assertEquals(1, gpc.getSelRecipientsList().size());
        System.assertEquals(true, gpc.getAllRecipientsList().get(1).selected);
    }

    @isTest
    private static void TestAddSelectedRecipients() {
        gpc.searchTextAccount = '';
        gpc.searchOptionAccount = 'contains';
        gpc.searchTextContact = 'u';
        gpc.searchOptionContact = 'contains';

        Test.startTest();

        gpc.searchRecipients();
        gpc.getAllRecipientsList().get(1).selected = true;
        gpc.addSelectedRecipients();

        Test.stopTest();

        System.assert(!ApexPages.hasMessages(ApexPages.severity.ERROR));
    }

    @isTest
    private static void TestSaveGifts() {
        Contact contactRecord = [SELECT Id FROM Contact WHERE LastName = 'Employee' AND MailingCountry = 'United States' LIMIT 1];

        gpc.gift.Gift_Type__c = 'Gift: Customers';
        gpc.gift.Submitted_For__c = contactRecord.Id;
        gpc.gift.Name = 'Sees Candy, 3';
        gpc.gift.Gift_Value__c = 33.00;
        gpc.gift.CurrencyIsoCode = 'USD';

        Test.startTest();

        gpc.saveGifts();

        Test.stopTest();

        System.assertEquals(33, gpc.gift.Gift_Value__c);
    }

    @isTest
    private static void TestRemoveSelectedRecipients() {
        Test.startTest();

        gpc.removeSelectedRecipients();

        Test.stopTest();

        System.assertEquals(0, gpc.getSelRecipientsList().size());
    }


    @isTest
    private static void TestProceedToCongratulations() {
        Contact contactRecord = [SELECT Id FROM Contact WHERE LastName = 'Employee' AND MailingCountry = 'United States' LIMIT 1];
        gift = new Gift__c();
        gpc.gift.Gift_Type__c = 'Gift: Customers';
        gpc.gift.Submitted_For__c = contactRecord.Id;
        gpc.gift.Name = 'Excessive';
        gpc.gift.Gift_Value__c = 150.00;
        gpc.gift.Desired_Date__c = Date.today().addYears(3);
        gpc.gift.CurrencyIsoCode = 'USD';
        gpc.searchTextAccount = '';
        gpc.searchOptionAccount = 'contains';
        gpc.searchTextContact = 'u';
        gpc.searchOptionContact = 'contains';

        Test.startTest();

        gpc.searchRecipients();
        gpc.getAllRecipientsList().get(1).selected = true;
        gpc.addSelectedRecipients();
        gpc.saveGifts();
        gpc.proceedToCongratulations();

        Test.stopTest();

        gpc.gift.Name = null;
        gpc.proceedToCongratulations();
        System.currentPageReference().getParameters().put('retURL', '/apex/SL_GiftPreApproval');
        gpc.returnToPreApproval();
        gpc.returnToBlankPreApproval();
        gpc.cancel();

        System.assert(ApexPages.hasMessages(ApexPages.severity.ERROR));
    }

    @isTest
    private static void TestGiftDesiredDate() {
        Contact contactRecord = [SELECT Id FROM Contact WHERE LastName = 'Employee' AND MailingCountry = 'United States' LIMIT 1];
        gift = new Gift__c();
        gpc.gift.Gift_Type__c = 'Gift: Customers';
        gpc.gift.Submitted_For__c = contactRecord.Id;
        gpc.gift.Name = 'Excessive';
        gpc.gift.Gift_Value__c = 0.00;
        gpc.gift.Desired_Date__c = Date.today().addDays(-3);
        gpc.gift.CurrencyIsoCode = 'USD';
        gpc.searchTextAccount = '';
        gpc.searchOptionAccount = 'contains';
        gpc.searchTextContact = 'u';
        gpc.searchOptionContact = 'contains';

        Test.startTest();

        gpc.searchRecipients();
        gpc.getAllRecipientsList().get(1).selected = true;
        gpc.addSelectedRecipients();
        gpc.saveGifts();

        Test.stopTest();

        System.assert(ApexPages.hasMessages(ApexPages.severity.ERROR));
    }

    @isTest
    static void TestGetGiftsJustAdded() {
        Gift__c newGift = [SELECT Name, Gift_value__c FROM Gift__c WHERE Name = 'Sees Candy'];
        List<SL_Gift> giftTestList = gpc.getGiftsJustAdded();
        gpc.searchTextAccount = 'a';
        gpc.searchTextContact = 'u';
        gpc.searchOptionContact = 'contains';

        Test.startTest();

        gpc.searchRecipients();
        gpc.getAllRecipientsList().get(1).selected = true;
        gpc.addSelectedRecipients();
        gpc.removeSelectedRecipients();
        gpc.getAllRecipientsList().clear();
        gpc.removeSelectedRecipients();
        gpc.searchTextContact = 'xyz';
        gpc.searchTextAccount = 'xyz';
        gpc.searchOptionContact = 'contains';
        gpc.searchRecipients();

        Test.stopTest();

        System.assertEquals(25.00, newGift.Gift_Value__c);
        System.assertEquals(0, giftTestList.size());
        System.assertEquals('No contacts were found that match search criteria', gpc.searchMessage);
    }
}