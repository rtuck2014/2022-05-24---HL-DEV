@isTest
private class Test_HL_RivaActivityLinkHandler {
    @isTest private static void TestAfterUpdate(){
        //Setup the Test Data
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        insert c;
        Contact e = SL_TestSetupUtils.CreateContact('',1,SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        e.User__c = UserInfo.getUserId();
        insert e;
        Activity__c a = new Activity__c(StartDateTime__c = DateTime.now(), EndDateTime__c = DateTime.now(), Subject__c = 'Test', Description__c = 'Test');
        insert a;
        Activity_Link__c al = new Activity_Link__c(ActivityId__c = a.Id, ContactId__c = c.Id, DisplayName__c = c.Name);
        al.IsInvitee__c = true;
		insert al;
        Activity_Link__c al02 = new Activity_Link__c(ActivityId__c = a.Id, ContactId__c = e.Id, DisplayName__c = e.Name);
        insert al02;
        
        Test.startTest();
        	update al;
        	update al02;
        Test.stopTest();
    }
    
    @isTest private static void TestAfterDelete(){
        //Setup the Test Data
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        insert c;
        Contact e = SL_TestSetupUtils.CreateContact('',1,SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        e.User__c = UserInfo.getUserId();
        insert e;
        Activity__c a = new Activity__c(StartDateTime__c = DateTime.now(), EndDateTime__c = DateTime.now(), Subject__c = 'Test', Description__c = 'Test');
        insert a;
        Activity_Link__c al = new Activity_Link__c(ActivityId__c = a.Id, ContactId__c = c.Id, DisplayName__c = c.Name);
        insert al;
        al.IsInvitee__c = true;
		update al;
        
        Test.startTest();
        	delete al;
        Test.stopTest();
    }
}