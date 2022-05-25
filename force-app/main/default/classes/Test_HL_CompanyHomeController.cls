@isTest
private class Test_HL_CompanyHomeController {
    @isTest private static void TestBasicFunctionality(){
        HL_CompanyHomeController con = new HL_CompanyHomeController();
        System.assert(!String.isBlank(con.CustomFilter));
        
        //Test Methods
        ApexPages.StandardSetController setCon = con.setCon;
 
        con.GetMyCompanies();
        con.SearchCity = 'Test';
        con.SearchClientNumber = 'Test';
        con.Account.Industry_Group_Abbreviation_All__c = 'Test';
        con.SearchName = 'Test Test';
        con.SearchPhone = 'Test';
        con.SearchState = 'Test';
        con.UseSearch = true;
        //Search with Criteria
   		con.setCon = null;
        setCon = con.setCon;
        con.GetMyCompanies();
        con.ToggleDirection('Name');
        con.ApplySort();
        con.AdvancedSearch();
        con.ClearSearch();
        //Verify no Page Errors
        System.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR));
    }
}