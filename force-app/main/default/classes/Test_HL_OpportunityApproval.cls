@isTest
private class Test_HL_OpportunityApproval {
    @isTest private static void TestGetById(){
        //Setup Test Data
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('',1)[0];
        o.Beneficial_Owner_Control_Person_form__c = 'No';
        insert o;
        Opportunity_Approval__c oa = new Opportunity_Approval__c(Related_Opportunity__c = o.Id);
        insert oa;
        
        Test.startTest();
            Opportunity_Approval__c oaResult = HL_OpportunityApproval.GetById(oa.Id);
            System.assertEquals(oa.Id, oaResult.Id);
        Test.stopTest();
    }
}