@IsTest
private class Test_HL_PagePreProcess {
    @IsTest private static void TestPreProcess(){
        //Create Test Data
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        opp.Beneficial_Owner_Control_Person_form__c = 'No';
        insert opp;
        
        Test.startTest();
        //Test with no valid parameters
        HL_PagePreProcess.PreProcess();
        ApexPages.currentPage().getParameters().put('opp',opp.Id);
        ApexPages.currentPage().getParameters().put('action','feis');
        HL_PagePreProcess.PreProcess();
        //Test Again Now that Record was Created
        HL_PagePreProcess.PreProcess();
        Test.stopTest();
    }
    
    @isTest private static void TestForCFEngagementSummary(){
        //Setup Test Data
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('', 1)[0];
        insert e;
        
        ApexPages.currentPage().getParameters().put('eng', e.Id);
        ApexPages.currentPage().getParameters().put('action','summary_cf');
        PageReference dest = HL_PagePreProcess.PreProcess();
        System.assert(dest.getUrl().contains('HL_CF_EngagementSummary'));
    }
}