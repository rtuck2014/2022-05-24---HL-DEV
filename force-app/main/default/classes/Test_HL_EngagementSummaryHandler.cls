@isTest
private class Test_HL_EngagementSummaryHandler {
     @isTest private static void TestOnBeforeInsert(){
        //Setup Test Data
        List<Account> aList = SL_TestSetupUtils.CreateAccount('', 3);
        //Modified as part of State/Country Picklist - Assign valid country
        aList[0].BillingCountry = 'United States';
        aList[1].BillingCountry = 'United States';
        aList[2].BillingCountry = 'United States';
        insert aList;
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('',1)[0];
        insert e;
        List<Engagement_Counterparty__c> ecList = SL_TestSetupUtils.CreateEC('',3);
        ecList[0].Type__c = 'Strategic';
        ecList[0].Company__c = aList[0].Id;
        ecList[0].Initial_Contact__c = Date.today();
        ecList[0].Sent_Book__c = Date.today();
        ecList[0].Proposal_Indication__c = Date.today();
        ecList[0].Met_With_Management__c = Date.today();
        ecList[0].Letter_of_Intent__c = Date.today();
        ecList[1].Type__c = 'Strategic';
        ecList[1].Company__c = aList[1].Id;
        ecList[1].Initial_Contact__c = Date.today();
        ecList[1].Sent_Book__c = Date.today();
        ecList[1].Proposal_Indication__c = Date.today();
        ecList[1].Met_With_Management__c = Date.today();
        ecList[1].Letter_of_Intent__c = Date.today();
        ecList[2].Type__c = 'Financial';
        ecList[2].Company__c = aList[0].Id;
        ecList[2].Initial_Contact__c = Date.today();
        ecList[2].Sent_Book__c = Date.today();
        ecList[2].Proposal_Indication__c = Date.today();
        ecList[2].Met_With_Management__c = Date.today();
        ecList[2].Letter_of_Intent__c = Date.today();
        insert ecList;
        Engagement_Summary__c es = new Engagement_Summary__c(Engagement__c = e.Id);

        Test.startTest();
            HL_EngagementSummaryHandler handler = new HL_EngagementSummaryHandler(false, 1);
            insert es;
        Test.stopTest();
         
    }
    
    @isTest private static void TestOnBeforeUpdate(){
        //Setup Test Data
        List<Account> aList = SL_TestSetupUtils.CreateAccount('', 3);
        //Modified as part of State/Country Picklist - Assign valid country
        aList[0].BillingCountry = 'United States';
        aList[1].BillingCountry = 'United States';
        aList[2].BillingCountry = 'United States';
        insert aList;
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('',1)[0];
        insert e;
        List<Engagement_Counterparty__c> ecList = SL_TestSetupUtils.CreateEC('',3);
        ecList[0].Type__c = 'Strategic';
        ecList[0].Company__c = aList[0].Id;
        ecList[0].Initial_Contact__c = Date.today();
        ecList[0].Sent_Book__c = Date.today();
        ecList[0].Proposal_Indication__c = Date.today();
        ecList[0].Met_With_Management__c = Date.today();
        ecList[0].Letter_of_Intent__c = Date.today();
        ecList[1].Type__c = 'Strategic';
        ecList[1].Company__c = aList[1].Id;
        ecList[1].Initial_Contact__c = Date.today();
        ecList[1].Sent_Book__c = Date.today();
        ecList[1].Proposal_Indication__c = Date.today();
        ecList[1].Met_With_Management__c = Date.today();
        ecList[1].Letter_of_Intent__c = Date.today();
        ecList[2].Type__c = 'Financial';
        ecList[2].Company__c = aList[0].Id;
        ecList[2].Initial_Contact__c = Date.today();
        ecList[2].Sent_Book__c = Date.today();
        ecList[2].Proposal_Indication__c = Date.today();
        ecList[2].Met_With_Management__c = Date.today();
        ecList[2].Letter_of_Intent__c = Date.today();
        insert ecList;
        Engagement_Summary__c es = new Engagement_Summary__c(Engagement__c = e.Id);
        insert es;
        
        Test.startTest();
            HL_EngagementSummaryHandler handler = new HL_EngagementSummaryHandler(false, 1);
            update es;
        Test.stopTest();
    }
}