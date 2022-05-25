@isTest
private class Test_HL_EngagementHomeController {
	@isTest private static void TestBasicFunctionality(){
        //Setup Test Data
        Account a = SL_TestSetupUtils.CreateAccount('', 1)[0];
        Contact c = SL_TestSetupUtils.CreateContact('1', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('', 1)[0];
        insert a;
        insert c;
        insert e;
        
        Test.startTest();
            HL_EngagementHomeController con = new HL_EngagementHomeController();
            List<Engagement__c> myEngs = con.GetMyEngagements();
            String customFilter = con.CustomFilter;
            con.EITName = 'Test';
            con.EITId = c.Id;
            con.Eng.Name = 'Test';
            con.Eng.Engagement_Number__c = '1';
            con.Eng.z_Client__c = a.Id;
            con.Eng.z_Subject__c = a.Id;
            con.Eng.Line_of_Business_All__c = 'SC';
            con.Eng.Job_Type_All__c = 'Sellside';
            con.Eng.Industry_Group_Abbreviation_All__c = 'IG';
            con.Eng.Stage_All__c = 'Active';
            con.setCon = null;
            myEngs = con.GetMyEngagements();
            con.setCon = null;
            con.UseSearch = true;
            myEngs = con.GetMyEngagements();
            con.ToggleDirection('Name');
            con.ApplySort();
            con.AdvancedSearch();
            con.ClearSearch();
        Test.stopTest();
        System.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR));
    }
}