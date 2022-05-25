@isTest
private class Test_HL_CoverageTeamController {
    @testSetup 
    private static void SetupCoverageTeamData(){        
        List<CapIQ_Company__c> capIQCompanyList = (List<CapIQ_Company__c>)HL_TestFactory.CreateSObjectList('CapIQ_Company__c', false, 1);
        insert capIQCompanyList;
        
        RecordType accountOperatingCompanyRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Operating_Company'];
        List<Account> accountList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 3);
        accountList[0].Name = 'CapIQ Assigned Standard';
        accountList[0].CapIQ_Company__c = capIQCompanyList[0].Id;
        accountList[0].RecordTypeId = accountOperatingCompanyRecordType.Id;
        accountList[1].Name = 'CapIQ Assigned FS';
        accountList[1].CapIQ_Company__c = capIQCompanyList[0].Id;
        accountList[1].RecordTypeId = accountOperatingCompanyRecordType.Id;
        accountList[2].Name = 'CapIQ Unassigned';
        accountList[2].RecordTypeId = accountOperatingCompanyRecordType.Id;
        insert accountList;
        
        Contact internalContactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        internalContactRecord.Industry_Group__c = 'FS - Financial Sponsors';
        insert internalContactRecord;        
        
        RecordType coverageTeamStandardRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Coverage_Team__c' AND DeveloperName = 'Standard_Coverage_Team_Member'];
        RecordType coverageTeamFSRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Coverage_Team__c' AND DeveloperName = 'FS_Coverage_Team_Member'];
        List<Coverage_Team__c> coverageTeamList = (List<Coverage_Team__c>)HL_TestFactory.CreateSObjectList('Coverage_Team__c', false, 3);
        coverageTeamList[0].RecordTypeId = coverageTeamStandardRecordType.Id;
        coverageTeamList[0].Company__c = accountList[0].Id;        
        coverageTeamList[0].Officer__c = internalContactRecord.Id;
        coverageTeamList[1].RecordTypeId = coverageTeamFSRecordType.Id;
        coverageTeamList[1].Company__c = accountList[1].Id;
        coverageTeamList[1].Officer__c = internalContactRecord.Id;     
        coverageTeamList[2].RecordTypeId = coverageTeamFSRecordType.Id;
        coverageTeamList[2].Company__c = accountList[2].Id;
        coverageTeamList[2].Officer__c = internalContactRecord.Id;
        insert coverageTeamList;
    }
    
    @isTest
    private static void TestCoverageTeamControllerWithStandardCoverageTeam() {
        Coverage_Team__c coverageTeamRecord = [SELECT Id FROM Coverage_Team__c WHERE Company__r.Name = 'CapIQ Assigned Standard' LIMIT 1];
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(coverageTeamRecord);        
        ApexPages.currentPage().getParameters().put('Id', coverageTeamRecord.Id);
        HL_CoverageTeamController coverageTeamController = new HL_CoverageTeamController(sc);
        PageReference checkRecordTypeResult = coverageTeamController.CheckRecordType();

        Test.stopTest();
        
        System.assert(checkRecordTypeResult != null);
    }
    
    @isTest
    private static void TestCoverageTeamControllerWithFSCoverageTeam(){
        Coverage_Team__c coverageTeamRecord = [SELECT Id FROM Coverage_Team__c WHERE Company__r.Name = 'CapIQ Assigned FS' LIMIT 1];
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(coverageTeamRecord);        
        ApexPages.currentPage().getParameters().put('Id', coverageTeamRecord.Id);
        HL_CoverageTeamController coverageTeamController = new HL_CoverageTeamController(sc);
        PageReference checkRecordTypeResult = coverageTeamController.CheckRecordType();

        Test.stopTest(); 
        
        System.assert(checkRecordTypeResult == null);
    }
    
    @isTest
    private static void TestCoverageTeamControllerWithCapIQUnassigned() {
        Coverage_Team__c coverageTeamRecord = [SELECT Id FROM Coverage_Team__c WHERE Company__r.Name = 'CapIQ Unassigned' LIMIT 1];
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(coverageTeamRecord);        
        ApexPages.currentPage().getParameters().put('Id', coverageTeamRecord.Id);
        HL_CoverageTeamController coverageTeamController = new HL_CoverageTeamController(sc);
        PageReference checkRecordTypeResult = coverageTeamController.CheckRecordType();

        Test.stopTest();
        
        System.assert(checkRecordTypeResult == null);
    }
}