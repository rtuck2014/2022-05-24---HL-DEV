@isTest
private class Test_HL_GiftHandler {
    @isTest
    private static void TestGiftInsert(){
        Contact currentUserContact = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        List<Contact> recipientList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.External_Contact, false, 1);
        List<Gift__c> giftList = (List<Gift__c>)HL_TestFactory.CreateSObjectList('Gift__c', false, 10);
        List<Email_Template__c> emailTemplateList = (List<Email_Template__c>)HL_TestFactory.CreateSObjectList('Email_Template__c', false, 2);
        currentUserContact.User__c = UserInfo.GetUserId();

        insert currentUserContact;
        insert recipientList;

        emailTemplateList[0].Name = 'Gift_Log_Confirmation';
        emailTemplateList[1].Name = 'Gift_Log_Submitted';
        emailTemplateList[0].Related_Object__c = emailTemplateList[1].Related_Object__c = 'Gift__c';
        insert emailTemplateList;

        for(Gift__c g : giftList)
            g.Recipient__c = recipientList[0].Id;

        Test.startTest();

        insert giftList;

        Test.stopTest();

        //Validate the Batch field was populated
        giftList = [SELECT Batch_Guid__c, Submitted_By__c FROM Gift__c WHERE Id IN: giftList];

        System.assert(!String.isBlank(giftList[0].Batch_Guid__c));
        //Validate the Submitted By field was populated
        System.assert(!String.isBlank(giftList[0].Submitted_By__c));
    }

    @isTest
    private static void TestGiftUpdate(){
        Contact currentUserContact = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        List<Contact> recipientList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.External_Contact, false, 1);
        List<Gift__c> giftList = (List<Gift__c>)HL_TestFactory.CreateSObjectList('Gift__c', false, 10);
        List<Email_Template__c> emailTemplateList = (List<Email_Template__c>)HL_TestFactory.CreateSObjectList('Email_Template__c', false, 5);
        currentUserContact.User__c = UserInfo.GetUserId();

        insert currentUserContact;
        insert recipientList;

        emailTemplateList[0].Name = 'Gift_Log_Confirmation';
        emailTemplateList[1].Name = 'Gift_Log_Submitted';
        emailTemplateList[2].Name = 'Gift_Log_Status';
        emailTemplateList[3].Name = 'Gift_Log_Revised';
        emailTemplateList[4].Name = 'Gift_Log_Edited';

        for(Email_Template__c et: emailTemplateList)
            et.Related_Object__c = 'Gift__c';

        insert emailTemplateList;

        for(Gift__c g : giftList)
            g.Recipient__c = recipientList[0].Id;

        insert giftList;
        for(Gift__c g : giftList){
            g.Approved__c = 'Approved';
            g.Gift_Value__c = 10.00;
        }

        Test.startTest();

        update giftList;

        Test.stopTest();

        //Validate the Approved field was populated
        giftList = [SELECT Approved__c FROM Gift__c WHERE Id IN: giftList];
        System.assert(!String.isBlank(giftList[0].Approved__c));
    }

    @isTest
    private static void TestGiftDelete(){
        Contact currentUserContact = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        List<Contact> recipientList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.External_Contact, false, 1);
        List<Gift__c> giftList = (List<Gift__c>)HL_TestFactory.CreateSObjectList('Gift__c', false, 2);
        List<Email_Template__c> emailTemplateList = (List<Email_Template__c>)HL_TestFactory.CreateSObjectList('Email_Template__c', false, 3);
        currentUserContact.User__c = UserInfo.GetUserId();

        insert currentUserContact;
        insert recipientList;

        emailTemplateList[0].Name = 'Gift_Log_Confirmation';
        emailTemplateList[1].Name = 'Gift_Log_Submitted';
        emailTemplateList[2].Name = 'Gift_Log_Cancelled';
        for(Email_Template__c et: emailTemplateList)
            et.Related_Object__c = 'Gift__c';

        insert emailTemplateList;

        for(Gift__c g : giftList)
            g.Recipient__c = recipientList[0].Id;

        giftList[0].Approved__c = 'Approved';

        insert giftList;

        Test.startTest();

        delete giftList;

        Test.stopTest();

        //Validate the delete was successful
        System.assert([SELECT Id FROM Gift__c WHERE Id IN: giftList].size() == 0);
    }
}