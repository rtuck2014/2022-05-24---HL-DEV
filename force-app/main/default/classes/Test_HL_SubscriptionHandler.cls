@isTest
private class Test_HL_SubscriptionHandler { 
    @testSetup
    static void setupSubscriptionData(){
        //Create Test Data
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        c.User__c = UserInfo.getUserId();      
        insert c;
        HL_Report_Link__c reportLink = SL_TestSetupUtils.CreateHLReportLink('', 1)[0];
        insert reportLink;
    }
    
     @isTest private static void TestInsert(){
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        HL_Report_Link__c reportLink = [SELECT Id FROM HL_Report_Link__c LIMIT 1];
        HL_Subscription__c subscription = new HL_Subscription__c(Active__c = true, Subscriber__c = c.Id, HL_Report_Link__c = reportLink.Id);
        Test.startTest();
        	insert subscription;
        Test.stopTest();
        
        //Verify the Sharing Record was Created
        System.assert([SELECT Id FROM HL_Report_Link__Share WHERE RowCause =: Schema.HL_Report_Link__Share.RowCause.Subscription__c].size() > 0);
    }
    
     @isTest private static void TestUpdateStandard(){
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        HL_Report_Link__c reportLink = [SELECT Id FROM HL_Report_Link__c LIMIT 1];
        HL_Subscription__c subscription = new HL_Subscription__c(Active__c = true, Subscriber__c = c.Id, HL_Report_Link__c = reportLink.Id);
        insert subscription;
        HL_Subscription__c subscriptionToUpdate = [SELECT Active__c, Subscriber__c, HL_Report_Link__c FROM HL_Subscription__c];
        
        Test.startTest();
        	 update subscriptionToUpdate;
        Test.stopTest();
        
        //Verify the Sharing Record was Created
        System.assert([SELECT Id FROM HL_Report_Link__Share WHERE RowCause =: Schema.HL_Report_Link__Share.RowCause.Subscription__c].size() > 0);
    }
    
    @isTest private static void TestUpdateToInactive(){
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        HL_Report_Link__c reportLink = [SELECT Id FROM HL_Report_Link__c LIMIT 1];
        HL_Subscription__c subscription = new HL_Subscription__c(Active__c = true, Subscriber__c = c.Id, HL_Report_Link__c = reportLink.Id);
        insert subscription;
        HL_Subscription__c subscriptionToUpdate = [SELECT Active__c, Subscriber__c, HL_Report_Link__c FROM HL_Subscription__c];
        subscriptionToUpdate.Active__c = false;
        
         Test.startTest();
        	 update subscriptionToUpdate;
        Test.stopTest();
        
        //Verify the Sharing Record was Created
        System.assert([SELECT Id FROM HL_Report_Link__Share WHERE RowCause =: Schema.HL_Report_Link__Share.RowCause.Subscription__c].size() == 0);
    }
    
    @isTest private static void TestDelete(){
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        HL_Report_Link__c reportLink = [SELECT Id FROM HL_Report_Link__c LIMIT 1];
        HL_Subscription__c subscription = new HL_Subscription__c(Active__c = true, Subscriber__c = c.Id, HL_Report_Link__c = reportLink.Id);
        insert subscription;
        HL_Subscription__c subscriptionToDelete = [SELECT Active__c, Subscriber__c, HL_Report_Link__c FROM HL_Subscription__c];
        Test.startTest();
        	 delete subscriptionToDelete;
        Test.stopTest();
        
        //Verify the Sharing Record was Removed
        System.assert([SELECT Id FROM HL_Report_Link__Share WHERE RowCause =: Schema.HL_Report_Link__Share.RowCause.Subscription__c].size() == 0);
    }
    
}