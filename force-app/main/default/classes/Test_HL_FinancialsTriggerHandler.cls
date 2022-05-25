@IsTest
private class Test_HL_FinancialsTriggerHandler 
{
  @IsTest
  private static void testmethod1()
    {
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
          Opp.Beneficial_Owner_Control_Person_form__c = 'No';
        insert opp;
        
        Opportunity_Approval__c oa = SL_TestSetupUtils.CreateOA('',1)[0];
            oa.Related_Opportunity__c = opp.id;
            oa.Form_Type__c = 'NBC';
            oa.Grade__c='A';
        insert oa;
        
        Account a =new account();
          a.name='test';
        insert a;
        
        Test.startTest();
            Financials__c f= new Financials__c();
                f.Type__c= 'Annual';
                f.Year__c='2010';
                f.Related_Approval__c=oa.id;
            f.Related_Account__c=a.id;
            insert f;
          
          Financials__c f1= new Financials__c();
                f1.Type__c= 'Annual';
                f1.Year__c='2011';
                f1.Related_Approval__c=oa.id;
            f1.Related_Account__c=a.id;
            insert f1;
        Test.stopTest();
    }
}