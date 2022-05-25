@isTest
private class Test_HL_GiftUtil {
    @isTest
    private static void TestCompareStringValues() {
        String s1 = 'Test1';
        String s2 = 'Test2';

        Test.startTest();

        integer compareAscending = HL_GiftUtil.CompareStringValues(s1, s2);
        HL_GiftUtil.SortDirection = 'DESC';
        integer compareDescending = HL_GiftUtil.CompareStringValues(s1, s2);
        s1 = '';
        s2 = '';
        integer compareSame = HL_GiftUtil.CompareStringValues(s1, s2);

        Test.stopTest();

        System.assertEquals(-1, compareAscending);
        System.assertEquals(1, compareDescending);
        System.assertEquals(0, compareSame);
    }

    @isTest
    private static void TestCompareDateValues() {
        Date d1 = Date.Today();
        Date d2 = d1.addDays(2);

        Test.startTest();

        integer compareAscending = HL_GiftUtil.CompareDateValues(d1, d2);
        HL_GiftUtil.SortDirection = 'DESC';
        integer compareDescending = HL_GiftUtil.CompareDateValues(d1, d2);

        Test.stopTest();

        System.assertEquals(2, compareAscending);
        System.assertEquals(-2, compareDescending);
    }

    @isTest
    private static void TestCompareDateTimeValues() {
        Datetime dt1 = Datetime.newInstance(2016, 09, 12);
        Datetime dt2 = dt1.addDays(2);

        Test.startTest();

        integer compareAscending = HL_GiftUtil.CompareDateTimeValues(dt1, dt2);
        HL_GiftUtil.SortDirection = 'DESC';
        integer compareDescending = HL_GiftUtil.CompareDateTimeValues(dt1, dt2);

        Test.stopTest();

        System.assertEquals(-172800000, compareAscending);
        System.assertEquals(172800000, compareDescending);
    }

    @isTest
    private static void TestCompareCurrencyValues() {
        Decimal de1 = 50.0;
        Decimal de2 = 55.0;

        Test.startTest();

        integer compareAscending = HL_GiftUtil.CompareCurrencyValues(de1, de2);
        HL_GiftUtil.SortDirection = 'DESC';
        integer compareDescending = HL_GiftUtil.CompareCurrencyValues(de1, de2);

        Test.stopTest();

        System.assertEquals(-5, compareAscending);
        System.assertEquals(5, compareDescending);
    }

    @isTest
    private static void TestGetPrevYTDValue() {
        List<Account> acctForContactList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 2);
        List<Contact> externContactList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.External_Contact, false, 1);
        Set<Id> contactIdSet = new Set<Id>();

        insert acctForContactList[0];

        externContactList[0].FirstName = 'TestExterFirstContact';
        externContactList[0].LastName = 'TestExterLastContact';
        insert externContactList[0];
        contactIdSet.add(externContactList[0].Id);

        Test.startTest();

        Map<Id, Decimal> conMap = HL_GiftUtil.GetPrevYTDValue(contactIdSet);

        Test.stopTest();

        System.assert(conMap.size() == 0);
    }

    @isTest
    private static void TestGetPrevYTDNextYearValue() {
        List<Account> acctForContactList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 2);
        List<Contact> externContactList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.External_Contact, false, 1);
        Set<Id> contactIdSet = new Set<Id>();

        insert acctForContactList[0];

        externContactList[0].FirstName = 'TestExterFirstContact';
        externContactList[0].LastName = 'TestExterLastContact';
        insert externContactList[0];
        contactIdSet.add(externContactList[0].Id);

        Test.startTest();

        Map<Id, Decimal> conMap = HL_GiftUtil.GetPrevYTDNextYearValue(contactIdSet);

        Test.stopTest();

        System.assert(conMap.size() == 0);
    }

    @isTest
    private static void TestGetConversionRates() {
        Test.startTest();

        Map<String, Decimal> convMap = HL_GiftUtil.GetConversionRates();

        Test.stopTest();

        System.assert(convMap.size() > 0);
    }

}