@isTest
private class Test_HL_OpportunityExternalTeamHandler {
    @isTest
    private static void TestInsertRecord(){
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        c.Email = 'test@test122.com';
        c.Title = 'Mr.';
        insert c;
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('', 1)[0];
        o.Beneficial_Owner_Control_Person_form__c = 'No';
        insert o;
        Opportunity_External_Team__c oet = SL_TestSetupUtils.CreateOET('',1)[0];
        oet.Contact__c = c.Id;
        oet.Opportunity__c = o.Id;
        oet.Primary__c = true;

        Test.startTest();

        insert oet;

        Test.stopTest();

        //Verify records were created
        System.assert([SELECT Id FROM Opportunity_External_Team__c WHERE Opportunity__c =: o.Id].size() > 0);
    }

    @isTest
    private static void TestRemovePrimaryOET(){
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        c.Email = 'test@test122.com';
        c.Title = 'Mr.';
        insert c;
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('', 1)[0];
        o.Beneficial_Owner_Control_Person_form__c = 'No';
        insert o;
        Opportunity_External_Team__c oet = SL_TestSetupUtils.CreateOET('',1)[0];
        oet.Contact__c = c.Id;
        oet.Opportunity__c = o.Id;
        oet.Primary__c = true;

        Test.startTest();

        insert oet;
        HL_OpportunityExternalTeamHandler handler = new HL_OpportunityExternalTeamHandler(new List<Opportunity_External_Team__c>{oet});
        handler.RemovePrimaryOET();

        Test.stopTest();

        o = [SELECT Primary_External_Contact__c FROM Opportunity__c WHERE Id =: o.Id];
        //Verify the Primary Contact Field has been Blanked Out
        System.assert(String.isBlank(o.Primary_External_Contact__c));
    }
}