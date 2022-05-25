@isTest
private class Test_HL_OpportunityHomeController {
    @isTest private static void TestBasicFunctionality(){
        //Setup Test Data
        Account a = SL_TestSetupUtils.CreateAccount('', 1)[0];
        Contact c = SL_TestSetupUtils.CreateContact('1', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('', 1)[0];
        o.Beneficial_Owner_Control_Person_form__c = 'No';
        insert a;
        insert c;
        insert o;
        Test.startTest();
            HL_OpportunityHomeController con = new HL_OpportunityHomeController();
            List<Opportunity__c> myOpps = con.GetMyOpportunities();
            String customFilter = con.CustomFilter;
            con.OITName = 'Test';
            con.OITId = c.Id;
            con.Opp.Name = 'Test';
            //con.Opp.Opportunity_Number__c = '1';
            con.Opp.Client__c = a.Id;
            con.Opp.Subject__c = a.Id;
            con.Opp.Line_of_Business_All__c = 'SC';
            con.Opp.Job_Type_All__c = 'Sellside';
            con.Opp.Industry_Group_Abbreviation_All__c = 'IG';
            con.Opp.Stage_All__c = 'Active';
            con.setCon = null;
            myOpps = con.GetMyOpportunities();
            con.setCon = null;
            con.UseSearch = true;
            myOpps = con.GetMyOpportunities();
            con.ToggleDirection('Name');
            con.ApplySort();
            con.AdvancedSearch();
            con.ClearSearch();
        Test.stopTest();
        System.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR));
    }
}