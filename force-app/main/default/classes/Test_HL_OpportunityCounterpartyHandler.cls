@isTest
private class Test_HL_OpportunityCounterpartyHandler {
	@isTest
    private static void TestOpportunityCounterpartyComment(){
        Account a = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert a;
        Opportunity__c o = (Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c', false);
        insert o;
        Opportunity_Counterparty__c oc = (Opportunity_Counterparty__c)HL_TestFactory.CreateSObject('Opportunity_Counterparty__c', false);
        oc.Opportunity__c = o.Id;
		oc.Company__c = a.Id;

        Test.startTest();

        insert oc;
        oc.Opportunity_Counterparty_Comment__c = 'Test Comment';
        update oc;

        Test.stopTest();

        //Verify the Comment was Added
        System.assert([SELECT Id FROM Opportunity_Counterparty_Comment__c].size() > 0);

    }
    @isTest
    private static void TestOpportunityCounterpartyAccountIndicatorNew(){
        Account a = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert a;
        Opportunity__c o = (Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c', false);
        insert o;
        Opportunity_Counterparty__c oc = (Opportunity_Counterparty__c)HL_TestFactory.CreateSObject('Opportunity_Counterparty__c', false);
        oc.Opportunity__c = o.Id;
        oc.Company__c = a.Id; 
        
        Test.startTest();

        insert oc;

        Test.stopTest();
        
       Account acct = [SELECT Counterparty__c FROM Account WHERE Id = :a.Id];
       System.assertEquals(true,acct.counterparty__c);
    }
    @isTest
    private static void TestOpportunityCounterpartyAccountIndicatorUpdate(){
        Account a = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert a;
        Account a2 = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert a2;
        Opportunity__c o = (Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c', false);
        insert o;
        Opportunity_Counterparty__c oc = (Opportunity_Counterparty__c)HL_TestFactory.CreateSObject('Opportunity_Counterparty__c', false);
        oc.Opportunity__c = o.Id;
        oc.Company__c = a.Id; 
        insert oc;
        
        Test.startTest();

        oc.Company__c = a2.Id;
        update oc;

        Test.stopTest();
        
       Account acct1 = [SELECT Counterparty__c FROM Account WHERE Id = :a.Id];
       Account acct2 = [SELECT Counterparty__c FROM Account WHERE Id = :a2.Id];
       System.assertEquals(false,acct1.Counterparty__c);
       System.assertEquals(true,acct2.Counterparty__c);
    }
    @isTest
    private static void TestOpportunityCounterpartyAccountIndicatorDelete(){
        Account a = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert a;
        Opportunity__c o = (Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c', false);
        insert o;
        Opportunity_Counterparty__c oc = (Opportunity_Counterparty__c)HL_TestFactory.CreateSObject('Opportunity_Counterparty__c', false);
        oc.Opportunity__c = o.Id;
        oc.Company__c = a.Id; 
        insert oc;
        
        Test.startTest();

        delete oc;
        
        Test.stopTest();
        
       Account acct = [SELECT Counterparty__c FROM Account WHERE Id = :a.Id];
       System.assertEquals(false,acct.counterparty__c);
    }
}