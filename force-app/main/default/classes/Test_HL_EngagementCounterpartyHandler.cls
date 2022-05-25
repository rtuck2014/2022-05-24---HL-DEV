@isTest
private class Test_HL_EngagementCounterpartyHandler {
    @isTest
    private static void TestCounterpartyCommentInsertAndUpdate(){
        //Setup Test Data
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        insert e;
        Engagement_Counterparty__c ec = (Engagement_Counterparty__c)HL_TestFactory.CreateSObject('Engagement_Counterparty__c', false);
        ec.Engagement__c = e.Id;
        
        Test.startTest();
        
        insert ec;
        ec.Engagement_Counterparty_Comment__c = 'Test Comment';
        update ec;
        
        Test.stopTest();
        
        //Verify the Comment was Added
        System.assert([SELECT Id FROM Engagement_Counterparty_Comment__c].size() > 0);
    }
    
    @isTest
    private static void TestCounterpartyAccountIndicatorNew(){
        //Setup Test Data
        Account a = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert a;
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        insert e;
        Engagement_Counterparty__c ec = (Engagement_Counterparty__c)HL_TestFactory.CreateSObject('Engagement_Counterparty__c', false);
        ec.Engagement__c = e.Id;
        ec.Company__c = a.Id;
        
        Test.startTest();
        
        insert ec;
        
        Test.stopTest();
        
        //Verify the Comment was Added
        Account acct = [SELECT Counterparty__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(true,acct.counterparty__c);
    }
    @isTest
    private static void TestEngagementCounterpartyAccountIndicatorUpdate(){
        Account a = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert a;
        Account a2 = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert a2;
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        insert e;
        Engagement_Counterparty__c ec = (Engagement_Counterparty__c)HL_TestFactory.CreateSObject('Engagement_Counterparty__c', false);
        ec.Engagement__c = e.Id;
        ec.Company__c = a.Id; 
        insert ec;
        
        Test.startTest();
        
        ec.Company__c = a2.Id;
        update ec;
        
        Test.stopTest();
        
        Account acct1 = [SELECT Counterparty__c FROM Account WHERE Id = :a.Id];
        Account acct2 = [SELECT Counterparty__c FROM Account WHERE Id = :a2.Id];
        System.assertEquals(false,acct1.Counterparty__c);
        System.assertEquals(true,acct2.Counterparty__c);
    }
    @isTest
    private static void TestEngagementCounterpartyAccountIndicatorDelete(){
        Account a = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert a;
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        insert e;
        Engagement_Counterparty__c ec = (Engagement_Counterparty__c)HL_TestFactory.CreateSObject('Engagement_Counterparty__c', false);
        ec.Engagement__c = e.Id;
        ec.Company__c = a.Id; 
        insert ec;
        
        Test.startTest();
        
        delete ec;
        
        Test.stopTest();
        
        Account acct = [SELECT Counterparty__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(false,acct.counterparty__c);
    }
}