@IsTest
private class Test_HL_CoverageContactHandler {
    @isTest private static void TestNewCoverageTeamRecordWithNewData(){
        //Setup our test data
        Account a = SL_TestSetupUtils.CreateAccount('',1)[0];
        insert a;
        Contact extContact = SL_TestSetupUtils.CreateContact('',1,SL_TestSetupUtils.ContactType.External_Contact)[0];
        extContact.AccountId = a.Id;
        insert extContact;
        Contact officerContact = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.Houlihan_Employee)[0];
        insert officerContact;
        
        Test.startTest();
        Coverage_Team__c ct = new Coverage_Team__c(Officer__c = officerContact.Id, Company__c = a.Id);
        insert ct;
        Coverage_Contact__c cc = new Coverage_Contact__c(Coverage_Contact__c = extContact.Id, Coverage_Team_Member__c = ct.Id);
  
        insert cc;
        update cc;
        delete cc;
   		Test.stopTest();
    }
}