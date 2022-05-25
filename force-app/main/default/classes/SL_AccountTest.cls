@isTest(SeeAllData=true)     
private with sharing class SL_AccountTest {
    private static User init() {
        return SL_Test.init();
    }

    private static TestMethod void testUpdateSponsorInvestmentAccount() {
        // Create Test Data
        User testUser = init();
        // Get Operating Company Record Type Id
        Id recordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Operating_Company'].Id;        
        // Create Sponsor Account
        Account testSponsorAccount = SL_Test.newAccount('Test Sponsor Account', recordTypeId);
        insert testSponsorAccount;
        // Create Portfolio Account
        Account testPortfolioAccount = SL_Test.newAccount('Test Portfolio Account', recordTypeId);
        insert testPortfolioAccount;
        // Create CapIQ Sponsor Company
        CapIQ_Company__c testCapIQSponsor = SL_Test.newCapIQCompany('Test CapIQ Sponsor Company', '12345678');
        insert testCapIQSponsor;
        // Create CapIQ Portfolio Company
        CapIQ_Company__c testCapIQPortfolio = SL_Test.newCapIQCompany('Test CapIQ Portfolio Company', '87654321');
        insert testCapIQPortfolio;
        // Create Investment Record
        Investment__c testInvestment = SL_Test.newInvestment(testCapIQSponsor.id, testCapIQPortfolio.id);
        insert testInvestment;
                
        // Execute Test
        Test.startTest();

        // Add CapIQ Id to Sponsor Account
        testSponsorAccount.CapIQ_Company__c = testCapIQSponsor.id;
        update testSponsorAccount;
        
        Test.stopTest();
        
        // Verify that Sponsor__c field in Investment Record was updated
        //system.assertNotEquals(null, [SELECT Sponsor__c FROM Investment__c WHERE Id = :testInvestment.id]);
    }
    
    private static TestMethod void testUpdatePortfolioInvestmentAccount() {
        // Create Test Data
        User testUser = init();
        // Get Operating Company Record Type Id
        Id recordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Operating_Company'].Id;        
        // Create Sponsor Account
        Account testSponsorAccount = SL_Test.newAccount('Test Sponsor Company', recordTypeId);
        insert testSponsorAccount;
        // Create Portfolio Account
        Account testPortfolioAccount = SL_Test.newAccount('Test Portfolio Account', recordTypeId);
        insert testPortfolioAccount;
        // Create CapIQ Sponsor Company
        CapIQ_Company__c testCapIQSponsor = SL_Test.newCapIQCompany('Test CapIQ Sponsor Company', '12345678');
        insert testCapIQSponsor;
        // Create CapIQ Portfolio Company
        CapIQ_Company__c testCapIQPortfolio = SL_Test.newCapIQCompany('Test CapIQ Portfolio Company', '87654321');
        insert testCapIQPortfolio;
        // Create Investment Record
        Investment__c testInvestment = SL_Test.newInvestment(testCapIQSponsor.id, testCapIQPortfolio.id);
        insert testInvestment;
                
        // Execute Test
        Test.startTest();

        // Add CapIQ Id to Sponsor Account
        testPortfolioAccount.CapIQ_Company__c = testCapIQPortfolio.id;
        update testPortfolioAccount;
        
        Test.stopTest();
        
        // Verify that Company__c field in Investment Record was updated
        //system.assertNotEquals(null, [SELECT Company__c FROM Investment__c WHERE Id = :testInvestment.id]);
    }
}