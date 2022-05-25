@IsTest
private class BatchStaffIndustryTest {
    @IsTest
    private static void testBatch(){
        List<Contact> contactList = new List<Contact>([SELECT Id,Department,Industry_Group__c,Office__c FROM Contact]);
        BatchStaffIndustry bsi = new BatchStaffIndustry();
        Test.startTest();
        Database.executeBatch(bsi);
        Test.stopTest();
    }
    @IsTest
    private static void testSchedule(){
        Test.startTest();
        String sch='0 5 2 * * ?';
        System.schedule('Batch Staff Industry', sch , new BatchStaffIndustry());
        Test.stopTest();
    }
    @TestSetup
    private static void setupData(){
        Id hlEmp =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Houlihan_Employee').getRecordTypeId();
        List<Contact> contactList = new List<Contact>();
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Office__c='AM',Industry_Group__c='GEN - General'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Office__c='FF',Industry_Group__c='GEN - General'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Office__c='MD',Industry_Group__c='GEN - General'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Office__c='ML',Industry_Group__c='GEN - General'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Office__c='RO',Industry_Group__c='GEN - General'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Office__c='HK',Industry_Group__c='GEN - General'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Office__c='SY',Industry_Group__c='GEN - General'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Office__c='LO',Industry_Group__c='GEN - General'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Office__c='RO',Industry_Group__c='GEN - General'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Office__c='BE',Industry_Group__c='GEN - General'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Industry_Group__c='IFA - Illiquid Financial Assets'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Industry_Group__c='BUS - Business Services'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Industry_Group__c='IG - Industrials'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Industry_Group__c='CORP - Corporate'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Industry_Group__c='CFR - Consumer Food & Retail'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Industry_Group__c='PFG - Private Funds Group'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Industry_Group__c='O&G - Oil & Gas'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Industry_Group__c='POW - Power & Utilities'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Industry_Group__c='CM - Capital Markets'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Industry_Group__c='DA - Data & Analytics'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Industry_Group__c='TECH - Technology'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Industry_Group__c='HC - Healthcare'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Industry_Group__c='M&A - Mergers & Acquisitions'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Industry_Group__c='RE - Real Estate Lodging and Leisure'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF',Industry_Group__c='TMT - Technology Media & Telecommunications'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='CF'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='FR',Industry_Group__c='O&G - Oil & Gas', Office__c='HO'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='FR',Industry_Group__c='RE - Real Estate Lodging and Leisure'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='FR',Industry_Group__c='POW - Power & Utilities'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='FR'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='FVA',Industry_Group__c='O&G - Oil & Gas'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='FVA'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='FSCG',Industry_Group__c='O&G - Oil & Gas'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='FSCG'));
        contactList.add(new Contact(FirstName='Test',LastName='Contact',RecordTypeId=hlEmp,Department='TEST'));
        insert contactList;
    }
}