@isTest
private class Test_HL_ConstantsUtil {
    @isTest
     public static void testUtilClassMethod() { 
         Boolean StopValidation = HL_ConstantsUtil.StopValidation; 
         Boolean AllowExecutionForManualInsertEngCounterparty = HL_ConstantsUtil.AllowExecutionForManualInsertEngCounterparty;
         Boolean stopCopyingNameFromCompToPosition = HL_ConstantsUtil.stopCopyingNameFromCompToPosition;
         Boolean engagementValue = HL_ConstantsUtil.engagementValue;
         Boolean stopExecuteEstFeeUpdateTrigger = HL_ConstantsUtil.stopExecuteEstFeeUpdateTrigger;
         Boolean stopExecutionForPVConversion = HL_ConstantsUtil.stopExecutionForPVConversion;
         HL_ConstantsUtil.IsSupervisorOrAdmin();
     } 
    Static testMethod void testUtilClassMethod1(){
        Profile profile1 = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User user1 = new User(
            Alias = 'standt01',
            Email='standarduser01@testorg.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing01',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = profile1.Id, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standarduser01@testorg1234.com');
        Insert user1;
        
        System.runAs(user1){
        System.assertEquals(true, HL_ConstantsUtil.IsHavingPVPermissionSetOrIsSysAdmin());     
        }
        
        Profile profile2 = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User user2 = new User(
            Alias = 'standt02',
            Email='standarduser02@testorg.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing02',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = profile2.Id, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standarduser02@testorg12345.com');
        Insert user2;
        
        System.runAs(user2){
        HL_ConstantsUtil.IsHavingPVPermissionSetOrIsSysAdmin();     
        }
            
    }
    @isTest
    public Static void testConstantsUtil(){
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
        contact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Houlihan Employee').getRecordTypeId();
        insert contact;
        
        Opportunity__c opportunity = new Opportunity__c();
        opportunity.Name = 'Engagement 125';
        opportunity.Client__c = account.Id;
        opportunity.Subject__c = account.Id;
        opportunity.Beneficial_Owner_Control_Person_form__c = 'No';
        insert opportunity;
        
        Engagement__c engagement = new Engagement__c();
        engagement.Name = 'Engagement 125';
        engagement.Client__c = account.Id;
        engagement.Subject__c = account.Id;
        insert engagement;
         
        Profile profile1 = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User user1 = new User(
            Alias = 'standt',
            Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8',
            FirstName = 'Test',
            LastName='User',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = profile1.Id, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standarduser@testorg1234.com');
        Insert user1;
  
        System.runAs(user1){
        Event_Expense__c eveExp = new Event_Expense__c();
        eveExp.City__c = 'New York';
        eveExp.Start_Date__c = Date.newInstance(2019, 01, 26);
        eveExp.End_Date__c = Date.newInstance(2019, 06, 26);
        eveExp.Requestor_Name__c = contact.id ;
        eveExp.Is_Clone__c = true;
        eveExp.Status__c = 'Approved';
        insert eveExp;
        
        HL_ConstantsUtil.IshavingValidRoleInInternTeamEng(engagement.id);
        HL_ConstantsUtil.IshavingValidRoleInInternTeamOpp(opportunity.id);
        HL_ConstantsUtil.EventExpenseNonCAOPrivilegedUsers();
        HL_ConstantsUtil.getSingleQuotesStr('test');
        HL_ConstantsUtil.buildEventExpenseWhereClause(eveExp,'mon','fri','test','cl');
        }
    }
}