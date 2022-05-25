@isTest
private class Test_HL_TestFactory {
    @isTest
    private static void CreatesSingleObjectWithSingleRequiredStringField() {
        Test.startTest();

        Account account = (Account)HL_TestFactory.CreateSObject('Account', false);
        account.BillingCountry = 'United States';
        account.BillingState = 'Pennsylvania';
        account.ShippingCountry = account.BillingCountry;
        account.ShippingState = account.BillingState;

        insert account;

        Test.stopTest();

        System.assert(!String.isBlank(account.Id));
        System.assert(!String.isBlank(account.Name));
    }

    @isTest
    private static void CreatesObjectWithCascadeSetsLookupField() {
        Test.startTest();
        Engagement__c Engagement =(Engagement__c)HL_TestFactory.CreateSObject('Engagement__c',false);        
        Engagement.Name='Test_Engagement';
        Engagement.Stage__c = 'Pitched';
        Engagement.Line_of_Business__c = 'CF';
        Engagement.Job_Type__c = 'Financing';
        Engagement.Primary_Office__c = 'AT';
        Engagement.MNPI__c= 'No';
        insert Engagement;
        HL_TestFactory.SetFillAllFields(true);
        Engagement_Office_Split__c eosRecord = (Engagement_Office_Split__c)HL_TestFactory.CreateSObject('Engagement_Office_Split__c', false);
        eosRecord.Engagement__c = Engagement.id;
        insert eosRecord;

        Test.stopTest();

        System.assert(!String.isBlank(eosRecord.Id));
        System.assert(!String.isBlank(eosRecord.Engagement__c));
    }

    @isTest
    private static void CreatesEngagementObjectWithoutCascadeSetsLookupField() {
        Test.startTest();

        Engagement__c engagement = HL_TestFactory.CreateEngagement(false);
        engagement.MNPI__c= 'No';
        insert engagement;

        Test.stopTest();

        System.assert(!String.isBlank(engagement.Id));
    }

    @isTest
    private static void CreatesObjectWithoutCascadeDoesNotSetLookupField() {
        Test.startTest();

        Contact contact = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        insert contact;

        Test.stopTest();

        System.assert(String.isBlank(contact.AccountId));
    }

    @isTest
    private static void CreateSObjectList(){
        integer listSize = 5;

        Test.startTest();

        List<Opportunity__c> oppList = (List<Opportunity__c>)HL_TestFactory.CreateSObjectList('Opportunity__c', false, listSize);

        Test.stopTest();

        System.assertEquals(listSize, oppList.size());
    }

    @isTest
    private static void CreatesObjectWithExcludeField() {
        Test.startTest();

        
        Engagement__c Engagement =(Engagement__c)HL_TestFactory.CreateSObject('Engagement__c',false);        
        Engagement.Name='Test_Engagement';
        Engagement.Stage__c = 'Pitched';
        Engagement.Line_of_Business__c = 'CF';
        Engagement.Job_Type__c = 'Financing';
        Engagement.Primary_Office__c = 'AT';
        Engagement.MNPI__c= 'No';
        //Engagement.Client_Location__c = 'UK';
        insert Engagement;
        HL_TestFactory.SetFillAllFields(true);
        HL_TestFactory.AddExcludedField('Engagement_Office_Split__c', new Set<String>{'Office__c'});
        Engagement_Office_Split__c eosRecord = (Engagement_Office_Split__c)HL_TestFactory.CreateSObject('Engagement_Office_Split__c', false);
        eosRecord.Engagement__c = Engagement.Id;
        insert eosRecord;

        Test.stopTest();

        System.assert(String.isBlank(eosRecord.Office__c));
    }

    @isTest
    private static void CreatesObjectWithIncludeField() {
        Engagement__c engagement = HL_TestFactory.CreateEngagement(false);
        engagement.MNPI__c= 'No';
        insert engagement;
        
        Test.startTest();
        
        HL_TestFactory.AddIncludedField('Engagement_Office_Split__c', new Set<String>{'Engagement__c','Office__c'});
        Engagement_Office_Split__c eosRecord = (Engagement_Office_Split__c)HL_TestFactory.CreateSObject('Engagement_Office_Split__c', false);
        eosRecord.Engagement__c = engagement.Id;

        insert eosRecord;

        Test.stopTest();

        System.assert(!String.isBlank(eosRecord.Office__c));
    }

    @isTest
    private static void CreateObjectWithUnsupportedTypeThrowsException() {
        Test.startTest();

        try {
            HL_TestFactory.CreateSObject('Unsupported', false);
            System.assert(false);
        } catch (UnsupportedObjectTypeException ex) {
            System.assert(true);
        }

        Test.stopTest();
    }
}