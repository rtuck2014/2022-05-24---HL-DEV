@isTest
private class Test_HL_OpportunityCommentHandler {
    @isTest
    private static void TestOnAfterOpportunityCounterpartyWithCommentInsert(){
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('',1)[0];
        o.Beneficial_Owner_Control_Person_form__c = 'No';
        insert o;
        Opportunity_Comment__c oc = new Opportunity_Comment__c(Related_Opportunity__c = o.Id, Comment_Type__c = 'Internal',Comment__c = 'Test');

        Test.startTest();

        HL_OpportunityCommentHandler handler = new HL_OpportunityCommentHandler(false, 1);
        insert oc;

        Test.stopTest();

        //Verify the opportunity has been updated with the latest comment
        o = [SELECT Last_Opportunity_Comment_Any__c, Last_Opportunity_Comment_PIPELINE__c FROM Opportunity__c WHERE Id =: o.Id];
        System.assert(!String.isBlank(o.Last_Opportunity_Comment_Any__c));
        System.assert(!String.isBlank(o.Last_Opportunity_Comment_PIPELINE__c));
    }
}