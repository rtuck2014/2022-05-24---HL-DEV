@isTest
private class Test_HL_MassBid {
    @isTest private static void TestBasicFunctionality(){
        //Setup Test Data
        Account a = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert a;
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('',1)[0];
        insert e;
        Engagement_Counterparty__c ec = SL_TestSetupUtils.CreateEC('', 1)[0];
        ec.Engagement__c = e.Id;
        ec.Company__c = a.Id;
        insert ec;
        Bid__c bid = new Bid__c(Engagement_Counterparty__c = ec.Id, Date__c = Date.today(), Round__c = 'First', Round_Maximum__c = 1.1, Round_Minimum__c = 1.0);
        insert bid;
        
        
        ApexPages.currentPage().getParameters().put('id',e.Id);
        HL_Mass_Bid mb = new HL_Mass_Bid();
        List<Bid__c> bList = mb.getBids();
        List<SelectOption> selectOpts = mb.getRoundOptions();
        mb.Save();
        mb.returnToCounterparties();
        mb.updatePage();
        
        //Verify No Errors
        System.assert(!ApexPages.hasMessages(ApexPages.severity.ERROR));
    }
}