@isTest
private class Test_HL_EngagementCommentHandler {
    @isTest
    private static void TestOnAfterEngagementCommentInsert(){
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        insert e;
        Engagement_Comment__c ec = new Engagement_Comment__c(Engagement__c = e.Id, Comment_Type__c = 'Internal', Comment__c = 'Test');

        Test.startTest();

        HL_EngagementCommentHandler handler = new HL_EngagementCommentHandler(false, 1);
        insert ec;

        Test.stopTest();

        //Verify the engagement has been updated with the latest comment
        e = [SELECT Last_Engagement_Comment_Any__c, Last_Engagement_Comment_PIPELINE__c FROM Engagement__c WHERE Id =: e.Id];
        System.assert(!String.isBlank(e.Last_Engagement_Comment_Any__c));
        System.assert(!String.isBlank(e.Last_Engagement_Comment_PIPELINE__c));
    }
}