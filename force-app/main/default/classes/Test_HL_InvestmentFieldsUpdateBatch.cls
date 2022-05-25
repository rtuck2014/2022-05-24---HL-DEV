/*
* Name: Test_HL_InvestmentFieldsUpdateBatch 
* Created Date: 2/22/2020
* Description: Test class for HL_InvestmentFieldsUpdateBatch class
*/ 
@isTest
private class Test_HL_InvestmentFieldsUpdateBatch {
    static final string SponsorAccountName = 'Investor';
    static final string PortfolioAccountName = 'Investment';
    static final integer InvestmentSize = 10;
    
    @testSetup
    private static void CreateData(){
        //Create the Base Account with Associate CapIQ Records as our Test Accounts for Investors and Investments
        Account sponsorAccountRecord = (Account)HL_TestFactory.CreateSObject('Account', false);
        sponsorAccountRecord.Name = SponsorAccountName;
        insert sponsorAccountRecord;
        Account portfolioAccountRecord = (Account)HL_TestFactory.CreateSObject('Account', false);
        portfolioAccountRecord.Name = PortfolioAccountName;
        insert portfolioAccountRecord;
        
        CapIQ_Company__c sponsorAccountCapIQRecord = (CapIQ_Company__c)HL_TestFactory.CreateSObject('CapIQ_Company__c', false);
        sponsorAccountCapIQRecord.Company_ID__c = '1';
        sponsorAccountCapIQRecord.HL_Industry_Group__c = 'BUS - Business Services';
        sponsorAccountCapIQRecord.HL_Sector__c = 'Other Services';
        insert sponsorAccountCapIQRecord;

        CapIQ_Company__c portfolioAccountCapIQRecord = (CapIQ_Company__c)HL_TestFactory.CreateSObject('CapIQ_Company__c', false);
        portfolioAccountCapIQRecord.Company_ID__c = '2';
        portfolioAccountCapIQRecord.HL_Industry_Group__c = 'BUS - Business Services';
        portfolioAccountCapIQRecord.HL_Sector__c = 'Other Services';
        insert portfolioAccountCapIQRecord;
        
        sponsorAccountRecord.CapIQ_Company__c = sponsorAccountCapIQRecord.Id;
        portfolioAccountRecord.CapIQ_Company__c = portfolioAccountCapIQRecord.Id;
        
        update sponsorAccountRecord;
        update portfolioAccountRecord;
        
        List<Investment__c> lstInvestment= new List<Investment__c>();
        for(Integer i=0 ;i <200;i++)
        {
            Investment__c investmentRecord = (Investment__c)HL_TestFactory.CreateSObject('Investment__c',false);
            investmentRecord.Portfolio_CapIQ_Company__c = portfolioAccountCapIQRecord.Id;
            investmentRecord.Sponsor_CapIQ_Company__c = sponsorAccountCapIQRecord.Id;
            lstInvestment.add(investmentRecord);
        }
        
        insert lstInvestment;
    }
        
    @isTest
    private static void testRunBatch(){
        
        Test.startTest();

            HL_InvestmentFieldsUpdateBatch batchs=new HL_InvestmentFieldsUpdateBatch();
            database.executeBatch(batchs);
            
        Test.stopTest();
        
        List<Investment__c> inv = [SELECT id, HL_Portfolio_Co_HL_Industry__c FROM investment__c WHERE HL_Portfolio_Co_HL_Industry__c = 'BUS - Business Services'];     
        system.assertNotEquals(inv.size(),0);
    }
}