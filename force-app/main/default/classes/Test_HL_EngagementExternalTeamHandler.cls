@isTest
private class Test_HL_EngagementExternalTeamHandler {
    
    @isTest private static void TestBasicFunctionality(){
        Contact c = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        insert c;
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        insert e;
        Engagement_External_Team__c eet = (Engagement_External_Team__c)HL_TestFactory.CreateSObject('Engagement_External_Team__c', false);
        eet.Contact__c = c.Id;
        eet.Engagement__c = e.Id;
        eet.Primary__c = true;
        
        Test.startTest();
        
        insert eet;
        
        Test.stopTest();
        
        //Verify records were created
        System.assert([SELECT Id FROM Engagement_External_Team__c WHERE Engagement__c =: e.Id].size() > 0);
    }
    
    @isTest private static void TestBasicFunctionalityOfUpdate(){
        Contact c = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        insert c;
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        insert e;
        Engagement_External_Team__c eet = (Engagement_External_Team__c)HL_TestFactory.CreateSObject('Engagement_External_Team__c', false);
        eet.Contact__c = c.Id;
        eet.Engagement__c = e.Id;
        eet.Primary__c = true;
        
        Test.startTest();
        
        insert eet;
        eet.Primary__c = false;
        update eet;
        
        Test.stopTest();
        
    }
    
    @isTest private static void TestRemovePrimaryEET(){
        Contact c = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        insert c;
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        insert e;
        Engagement_External_Team__c eet = (Engagement_External_Team__c)HL_TestFactory.CreateSObject('Engagement_External_Team__c', false);
        eet.Contact__c = c.Id;
        eet.Engagement__c = e.Id;
        eet.Primary__c = true;
        
        Test.startTest();
        
        insert eet;
        HL_EngagementExternalTeamHandler handler = new HL_EngagementExternalTeamHandler(new List<Engagement_External_Team__c>{eet},new Map<Id,Engagement_External_Team__c>{eet.id=>eet});
        handler.RemovePrimaryEET();      
        Test.stopTest();
        
        e = [SELECT Primary_External_Contact__c FROM Engagement__c WHERE Id =: e.Id];
        //Verify the Primary Contact Field has been Blanked Out
        System.assert(String.isBlank(e.Primary_External_Contact__c));
    }
    
    @isTest
    static void createEngagementContractsTest(){
          
        HL_Auto_Number_Settings__c autoNumber = new HL_Auto_Number_Settings__c();
        autoNumber.Name = 'Account';
        autoNumber.Auto_Number__c = 100;
        insert autoNumber;
        
        Account account = new Account();
        account.Name = 'Account Test 1';
        account.BillingCountry = 'United States';
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Contact';
        contact.LastName = 'Test145';
        contact.Email = 'contacttest145@test145.com';
        contact.Phone = '9999999999';
        contact.AccountId = account.Id;
        contact.Title = 'Marketing Head';
        insert contact;
        
        Engagement__c engagement = new Engagement__c();
        engagement.Name = 'Engagement 125';
        engagement.Client__c = account.Id;
        engagement.Subject__c = account.Id;
        insert engagement;
        
        Engagement_External_Team__c engagementContact = new Engagement_External_Team__c();
        engagementContact.Engagement__c = engagement.Id;
        engagementContact.Contact__c = contact.Id;
        engagementContact.Primary__c = true;
        insert engagementContact;

        engagementContact.Billing_Contact__c = true;
        engagementContact.Acknowledge_Billing_Contact__c = true;
        update engagementContact;  

    }
    
    @isTest
    Static Void createContractsAfterEngagementConversionTest(){
         Test.startTest();
        
        Set<Id> engagementSet = new Set<Id>(); 

        HL_Auto_Number_Settings__c autoNumber = new HL_Auto_Number_Settings__c();
        autoNumber.Name = 'Account';
        autoNumber.Auto_Number__c = 100;
        insert autoNumber;
        
        Account account = new Account();
        account.Name = 'Account Test 1';
        account.BillingCountry = 'United States';
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Contact';
        contact.LastName = 'Test';
        contact.Email = 'contacttest145@test.com';
        contact.Phone = '9999999999';
        contact.AccountId = account.Id;
        contact.Title = 'Marketing Head';
        insert contact;
        
        Engagement__c engagement = new Engagement__c();
        engagement.Name = 'Engagement 125';
        engagement.Client__c = account.Id;
        engagement.Subject__c = account.Id;
        insert engagement;
        
        Engagement_External_Team__c engagementContact = new Engagement_External_Team__c();
        engagementContact.Engagement__c = engagement.Id;
        engagementContact.Contact__c = contact.Id;
        engagementContact.Primary__c = true;
        insert engagementContact;

        engagementContact.Billing_Contact__c = true;
        engagementContact.Acknowledge_Billing_Contact__c = true;
        update engagementContact;
        
        engagementSet.add(engagementContact.Id);
        HL_EngagementExternalTeamHandler.createContractsAfterEngagementConversion(engagementSet);
        Test.stopTest();
    }
    
    Static testMethod void remainFunctionTest(){
        
        HL_Auto_Number_Settings__c autoNumber = new HL_Auto_Number_Settings__c();
        autoNumber.Name = 'Account';
        autoNumber.Auto_Number__c = 100;
        insert autoNumber;
        
        Account account = new Account();
        account.Name = 'Account Test 1';
        account.BillingCountry = 'United States';
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Contact';
        contact.LastName = 'Test';
        contact.Email = 'contacttest145@test.com';
        contact.Phone = '9999999999';
        contact.AccountId = account.Id;
        contact.Title = 'Marketing Head';
        insert contact;
        
        Engagement__c engagement = new Engagement__c();
        engagement.Name = 'Engagement 125';
        engagement.Client__c = account.Id;
        engagement.Subject__c = account.Id;
        insert engagement;
        
        List<Engagement_External_Team__c> engagementExternalTeam = new List<Engagement_External_Team__c>();
        Engagement_External_Team__c engagementContact = new Engagement_External_Team__c();
        engagementContact.Engagement__c = engagement.Id;
        engagementContact.Contact__c = contact.Id;
        engagementContact.Primary__c = true;
        engagementExternalTeam.add(engagementContact);
        insert engagementExternalTeam;

        HL_EngagementExternalTeamHandler hlEngExtTeamHandler = new HL_EngagementExternalTeamHandler(engagementExternalTeam);
            hlEngExtTeamHandler.UpdateSortFields();
        
    }
    
}