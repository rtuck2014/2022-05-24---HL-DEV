@isTest
private class Test_HL_ReportLink {
    @isTest private static void TestBasicFunctionality(){
        //Create Test Data of Engagement Single Link Records
        List<HL_Report_Link__c> lnksCreated = SL_TestSetupUtils.CreateHLReportLink(null,5);
        for(integer i=0;i<lnksCreated.size(); i++)
            lnksCreated[i].Display_Name__c += '_' + i; 
        insert lnksCreated;     
        Test.startTest();
        	List<HL_Report_Link__c> lnkResults = HL_ReportLink.GetByType('Engagement Single');
        Test.stopTest();      
        System.assertEquals(lnkResults.size(), lnksCreated.size()); 
    }
    
    @isTest private static void TestAsStandardUser(){
        //Create Test Data of Engagement Single Link Records
        User u = SL_TestSetupUtils.CreateTestUser('Standard User');
        List<HL_Report_Link__c> lnksCreated = SL_TestSetupUtils.CreateHLReportLink(null,5);
        for(integer i=0;i<lnksCreated.size(); i++)
            lnksCreated[i].Display_Name__c += '_' + i; 
        insert lnksCreated;
        insert u;
        System.runAs(u){
            Test.startTest();
                List<HL_Report_Link__c> lnkResults = HL_ReportLink.GetByType('Engagement Single');
            Test.stopTest();
            
            System.assertEquals(0, lnkResults.size()); 
        }
    }
}