/*
* Name: Test_HL_InvestmentHandler 
* Created Date: 2/22/2020
* Description: Test class for HL_InvestmentHandler class
*/ 
@isTest
private class Test_HL_InvestmentHandler {
    static final string SponsorAccountName = 'Investor';
    static final string PortfolioAccountName = 'Investment';
    static final string SponsorAccountName2 = 'Investor two';
    static final string PortfolioAccountName2 = 'Investment two';    
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
    }
    
    @isTest
    private static void testCapIQAfterUpdateScenario(){
    
        CapIQ_Company__c sponsorCapIQRecord = [SELECT id,HL_Industry_Group__c,HL_Sector__c FROM CapIQ_Company__c WHERE Company_ID__c = '1'];
        CapIQ_Company__c portfolioCapIQRecord = [SELECT id,HL_Industry_Group__c,HL_Sector__c FROM CapIQ_Company__c WHERE Company_ID__c = '2'];
    
        Investment__c investmentRecord = (Investment__c)HL_TestFactory.CreateSObject('Investment__c',false);
        investmentRecord.Portfolio_CapIQ_Company__c = portfolioCapIQRecord.Id;
        investmentRecord.Sponsor_CapIQ_Company__c = sponsorCapIQRecord.Id;
        
        insert investmentRecord;
        
        Test.startTest();
        
        portfolioCapIQRecord.HL_Industry_Group__c = 'HC - Healthcare';
        portfolioCapIQRecord.HL_Sector__c = 'Dental';
        update portfolioCapIQRecord;

        Test.stopTest();
        List<Investment__c> inv = [SELECT id, HL_Portfolio_Co_HL_Industry__c FROM investment__c WHERE HL_Portfolio_Co_HL_Industry__c = 'HC - Healthcare'];     
        system.assertNotEquals(inv.size(),0);
    }
    
    @isTest
    private static void testInvestmentBeforeInsertScenario(){
    
        CapIQ_Company__c sponsorCapIQRecord = [SELECT id,HL_Industry_Group__c,HL_Sector__c FROM CapIQ_Company__c WHERE Company_ID__c = '1'];
        CapIQ_Company__c portfolioCapIQRecord = [SELECT id,HL_Industry_Group__c,HL_Sector__c FROM CapIQ_Company__c WHERE Company_ID__c = '2'];
    
        Test.startTest();

        Investment__c investmentRecord = (Investment__c)HL_TestFactory.CreateSObject('Investment__c',false);
        investmentRecord.Portfolio_CapIQ_Company__c = portfolioCapIQRecord.Id;
        investmentRecord.Sponsor_CapIQ_Company__c = sponsorCapIQRecord.Id;
        
        insert investmentRecord;
        
        
        Test.stopTest();
        List<Investment__c> inv = [SELECT id, HL_Portfolio_Co_HL_Industry__c FROM investment__c WHERE HL_Portfolio_Co_HL_Industry__c = 'BUS - Business Services'];     
        system.assertEquals(inv.size(),1);
    }
    
    @isTest
    private static void testInvestmentBeforeUpdateScenario(){
    
        CapIQ_Company__c sponsorCapIQRecord = [SELECT id,HL_Industry_Group__c,HL_Sector__c FROM CapIQ_Company__c WHERE Company_ID__c = '1'];
        CapIQ_Company__c portfolioCapIQRecord = [SELECT id,HL_Industry_Group__c,HL_Sector__c FROM CapIQ_Company__c WHERE Company_ID__c = '2'];
    
        Account sponsorAccountRec = (Account)HL_TestFactory.CreateSObject('Account', false);
        sponsorAccountRec.Name = SponsorAccountName2;
        insert sponsorAccountRec;
        
        Account portfolioAccountRec = (Account)HL_TestFactory.CreateSObject('Account', false);
        portfolioAccountRec.Name = PortfolioAccountName2;
        insert portfolioAccountRec;
        
        CapIQ_Company__c sponsorAccountCapIQRec = (CapIQ_Company__c)HL_TestFactory.CreateSObject('CapIQ_Company__c', false);
        sponsorAccountCapIQRec.Company_ID__c = '3';
        sponsorAccountCapIQRec.HL_Industry_Group__c = 'HC - Healthcare';
        sponsorAccountCapIQRec.HL_Sector__c = 'Dental';
        insert sponsorAccountCapIQRec;

        CapIQ_Company__c portfolioAccountCapIQRec = (CapIQ_Company__c)HL_TestFactory.CreateSObject('CapIQ_Company__c', false);
        portfolioAccountCapIQRec .Company_ID__c = '4';
        portfolioAccountCapIQRec .HL_Industry_Group__c = 'HC - Healthcare';
        portfolioAccountCapIQRec .HL_Sector__c = 'Dental';
        insert portfolioAccountCapIQRec ;      

        sponsorAccountRec.CapIQ_Company__c = sponsorAccountCapIQRec.Id;
        portfolioAccountRec.CapIQ_Company__c = portfolioAccountCapIQRec.Id;
        
        update sponsorAccountRec;
        update portfolioAccountRec;

        Test.startTest();
        Investment__c investmentRecord = (Investment__c)HL_TestFactory.CreateSObject('Investment__c',false);
        investmentRecord.Portfolio_CapIQ_Company__c = portfolioCapIQRecord.Id;
        investmentRecord.Sponsor_CapIQ_Company__c = sponsorCapIQRecord.Id;
        insert investmentRecord;
        
        investmentRecord.Portfolio_CapIQ_Company__c = portfolioAccountCapIQRec.Id;
        investmentRecord.Sponsor_CapIQ_Company__c = sponsorAccountCapIQRec.Id;
        update investmentRecord;
                
        Test.stopTest();
        List<Investment__c> inv = [SELECT id, HL_Portfolio_Co_HL_Industry__c FROM investment__c WHERE HL_Portfolio_Co_HL_Industry__c = 'HC - Healthcare'];     
        system.assertEquals(inv.size(),1);
    }    
        
}