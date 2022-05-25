@isTest
private class Test_HL_InvestmentsListController {
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
        insert sponsorAccountCapIQRecord;
        CapIQ_Company__c portfolioAccountCapIQRecord = (CapIQ_Company__c)HL_TestFactory.CreateSObject('CapIQ_Company__c', false);
        portfolioAccountCapIQRecord.Company_ID__c = '2';
        insert portfolioAccountCapIQRecord;
        
        sponsorAccountRecord.CapIQ_Company__c = sponsorAccountCapIQRecord.Id;
        portfolioAccountRecord.CapIQ_Company__c = portfolioAccountCapIQRecord.Id;
        
        update sponsorAccountRecord;
        update portfolioAccountRecord;
        
        //Create the Related Investment and Investor Records to Test the Controller Functionality Against
        List<Account> capIQPortfolioAccountList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, InvestmentSize);
        insert capIQPortfolioAccountList;
        List<CapIQ_Company__c> capIQPortfolioList = (List<CapIQ_Company__c>)HL_TestFactory.CreateSObjectList('CapIQ_Company__c', false, InvestmentSize);
        insert capIQPortfolioList;
        for(integer index = 0; index < InvestmentSize; index++)
            capIQPortfolioAccountList[index].CapIQ_Company__c = capIQPortfolioList[index].Id;
        update capIQPortfolioAccountList;
        
        List<Investment__c> investmentList = (List<Investment__c>)HL_TestFactory.CreateSObjectList('Investment__c', false, InvestmentSize);
        for(integer index = 0; index < InvestmentSize; index++){
            investmentList[index].Portfolio_CapIQ_Company__c = capIQPortfolioList[index].Id;
            investmentList[index].Sponsor_CapIQ_Company__c = sponsorAccountCapIQRecord.Id;
            investmentList[index].Investment_Date__c = Date.today().addDays(-1 * index);
            investmentList[index].Status__c = 'Current';
        }
        System.Debug(investmentList);
        insert investmentList;
        
        List<Account> capIQSponsorAccountList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, InvestmentSize);
        insert capIQSponsorAccountList;
        List<CapIQ_Company__c> capIQSponsorList = (List<CapIQ_Company__c>)HL_TestFactory.CreateSObjectList('CapIQ_Company__c', false, InvestmentSize);
        insert capIQSponsorList;
        for(integer index = 0; index < InvestmentSize; index++)
            capIQSponsorAccountList[index].CapIQ_Company__c = capIQSponsorList[index].Id;
        List<Investment__c> investorList = (List<Investment__c>)HL_TestFactory.CreateSObjectList('Investment__c', false, InvestmentSize);
        for(integer index = 0; index < InvestmentSize; index++){
            investorList[index].Portfolio_CapIQ_Company__c = portfolioAccountCapIQRecord.Id;
            investorList[index].Sponsor_CapIQ_Company__c = capIQPortfolioList[index].Id;
            investorList[index].Investment_Date__c = Date.today().addDays(-1 * index);
            investorList[index].Status__c = 'Current';
        }
        insert investorList;
    }
    
    @isTest
    private static void TestInvestmentRetrieval(){
        Account sponsorAccountRecord = [SELECT Id FROM Account WHERE Name =: SponsorAccountName];
        ApexPages.StandardController sc = new ApexPages.StandardController(sponsorAccountRecord);
        
        Test.startTest();
        
        Test.setCurrentPage(new PageReference('/' + sponsorAccountRecord.Id));
        ApexPages.currentPage().getParameters().put('Id',sponsorAccountRecord.Id);
        HL_InvestmentsListController con = new HL_InvestmentsListController(sc);
        List<Investment__c> investmentResultList = con.getInvestments();
        
        Test.stopTest();
        
        System.assertEquals(con.PageSize, investmentResultList.size());
    }
    
    @isTest
    private static void TestInvestorRetrieval(){
        Account portfolioAccountRecord = [SELECT Id FROM Account WHERE Name =: PortfolioAccountName];
        ApexPages.StandardController sc = new ApexPages.StandardController(portfolioAccountRecord);
        
        Test.startTest();
        
        Test.setCurrentPage(new PageReference('/' + portfolioAccountRecord.Id));
        ApexPages.currentPage().getParameters().put('Id',portfolioAccountRecord.Id);
        HL_InvestmentsListController con = new HL_InvestmentsListController();
        con.InvestmentType = 'Investors';
        List<Investment__c> investorResultList = con.getInvestments();
        
        Test.stopTest();
        
        System.assertEquals(con.PageSize, investorResultList.size());
    }
    
    @isTest
    private static void TestInvestmentFilterByAllInvestments(){
        Account sponsorAccountRecord = [SELECT Id FROM Account WHERE Name =: SponsorAccountName];
        ApexPages.StandardController sc = new ApexPages.StandardController(sponsorAccountRecord);
        
        Test.startTest();
        
        Test.setCurrentPage(new PageReference('/' + sponsorAccountRecord.Id));
        ApexPages.currentPage().getParameters().put('Id',sponsorAccountRecord.Id);
        HL_InvestmentsListController con = new HL_InvestmentsListController(sc);
        con.FilterByAllInvestments();
        List<Investment__c> investmentResultList = con.getInvestments();
        
        Test.stopTest();
        
        System.assertEquals(con.PageSize, investmentResultList.size());
    }
    
    @isTest
    private static void TestInvestmentFilterByCurrentInvestments(){
        Account sponsorAccountRecord = [SELECT Id FROM Account WHERE Name =: SponsorAccountName];
        ApexPages.StandardController sc = new ApexPages.StandardController(sponsorAccountRecord);
        
        Test.startTest();
        
        Test.setCurrentPage(new PageReference('/' + sponsorAccountRecord.Id));
        ApexPages.currentPage().getParameters().put('Id',sponsorAccountRecord.Id);
        HL_InvestmentsListController con = new HL_InvestmentsListController(sc);
        con.FilterByCurrentInvestments();
        List<Investment__c> investmentResultList = con.getInvestments();
        
        Test.stopTest();
        
        System.assertEquals(con.PageSize, investmentResultList.size());
    }
    
    @isTest
    private static void TestInvestmentFilterByPriorInvestments(){
        Account sponsorAccountRecord = [SELECT Id FROM Account WHERE Name =: SponsorAccountName];
        ApexPages.StandardController sc = new ApexPages.StandardController(sponsorAccountRecord);
        
        Test.startTest();
        
        Test.setCurrentPage(new PageReference('/' + sponsorAccountRecord.Id));
        ApexPages.currentPage().getParameters().put('Id',sponsorAccountRecord.Id);
        HL_InvestmentsListController con = new HL_InvestmentsListController(sc);
        con.FilterByPriorInvestments();
        List<Investment__c> investmentResultList = con.getInvestments();
        String filterText = con.FilterText;
        
        Test.stopTest();
        
        System.assertEquals(0, investmentResultList.size());
        System.assertEquals('Prior', filterText);
    }
    
    @isTest
    private static void TestInvestmentSortFields(){
        Account sponsorAccountRecord = [SELECT Id FROM Account WHERE Name =: SponsorAccountName];
        ApexPages.StandardController sc = new ApexPages.StandardController(sponsorAccountRecord);
        
        Test.startTest();
        
        Test.setCurrentPage(new PageReference('/' + sponsorAccountRecord.Id));
        ApexPages.currentPage().getParameters().put('Id',sponsorAccountRecord.Id);
        HL_InvestmentsListController con = new HL_InvestmentsListController(sc);
        
        List<Investment__c> investmentOriginalResultList = con.getInvestments();
        
        Field_Ids__c fields = con.FI;
        con.SortByDateSold();
        con.SortByPortfolioCompany();
        con.SortByAmountOfInvestment();
        con.SortByRelatedFund();
        con.SortByExpectedExitDate();
        con.SortBySponsor();
        con.SortByStatus();
        con.SortByActualRelationshipType();
        con.SortByIndustry();
        con.SortByName();
        con.SortByInvestmentDate();
        con.ToggleDirection('DESC');
        
        List<Investment__c> investmentSortedResultList = con.getInvestments();
        
        Test.stopTest();
        
       // System.assertEquals(con.PageSize, investmentSortedResultList.size());
       // System.assertNotEquals(investmentOriginalResultList[0].Id, investmentSortedResultList[0].Id);
        
    }
}