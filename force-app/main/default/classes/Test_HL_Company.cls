@isTest
private class Test_HL_Company {
    @isTest 
    private static void TestGetById(){
        Account accountRecord = (Account)HL_TestFactory.CreateSObject('Account', false);
        accountRecord.Name = 'Test Account';
        insert accountRecord;
        
        Test.startTest();
        
        Account accountResult = HL_Company.GetById(accountRecord.Id);
        
        Test.stopTest();
        
        System.assertEquals(accountRecord.Id, accountResult.Id);
    }
    
    @isTest
    private static void TestGetCoverageTeamAggregate(){
        CapIQ_Company__c portfolioCapIQCompany = (CapIQ_Company__c)HL_TestFactory.CreateSObject('CapIQ_Company__c', false);
        insert portfolioCapIQCompany;  
        CapIQ_Company__c sponsorCapIQCompany = (CapIQ_Company__c)HL_TestFactory.CreateSObject('CapIQ_Company__c', false);
        insert sponsorCapIQCompany; 
        
        Account portfolioAccount = (Account)HL_TestFactory.CreateSObject('Account', false);
        portfolioAccount.Name = 'Portfolio Account';
        portfolioAccount.CapIQ_Company__c = portfolioCapIQCompany.Id;
        insert portfolioAccount;
        Account sponsorAccount = (Account)HL_TestFactory.CreateSObject('Account', false);
        sponsorAccount.Name = 'Sponsor Account';
        sponsorAccount.CapIQ_Company__c = sponsorCapIQCompany.Id;
        insert sponsorAccount;
        
        portfolioCapIQCompany.Company_ID__c = portfolioAccount.Id;
        update portfolioCapIQCompany;
        sponsorCapIQCompany.Company_ID__c = sponsorAccount.Id;
        update sponsorCapIQCompany;
        
        Contact houlihanContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        houlihanContactRecord.User__c = UserInfo.getUserId();
        houlihanContactRecord.Status__c = 'Active';
        houlihanContactRecord.Industry_Group__c = 'FS - Financial Sponsors';
        insert houlihanContactRecord;
        Coverage_Team__c coverageTeamRecord = (Coverage_Team__c)HL_TestFactory.CreateSObject('Coverage_Team__c',false);
        coverageTeamRecord.RecordTypeId = Schema.SObjectType.Coverage_Team__c.getRecordTypeInfosByName().get('FS Coverage Team Member').getRecordTypeId();
        coverageTeamRecord.Coverage_Team_Status__c = 'Active';
        coverageTeamRecord.Company__c = portfolioAccount.Id;
        coverageTeamRecord.Officer__c = houlihanContactRecord.Id;
        insert coverageTeamRecord;
        
        Investment__c investmentRecord = (Investment__c)HL_TestFactory.CreateSObject('Investment__c',false);
        investmentRecord.Portfolio_CapIQ_Company__c = portfolioCapIQCompany.Id;
        investmentRecord.Sponsor_CapIQ_Company__c = sponsorCapIQCompany.Id;
        insert investmentRecord;
        
        Test.startTest();
        
        List<Coverage_Team__c> coverageTeamAggregateResultList = HL_Company.GetCoverageTeamAggregate(portfolioAccount.Id);
        
        Test.stopTest();
        
        System.assert(coverageTeamAggregateResultList.size() == 1);
    }
}