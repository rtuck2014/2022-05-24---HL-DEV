@isTest
private class Test_HL_ContactHomeController {
    @isTest private static void TestBasicFunctionality(){
        HL_ContactHomeController con = new HL_ContactHomeController();
        System.assert(!String.isBlank(con.CustomFilter));
        
        //Test Methods
        ApexPages.StandardSetController setCon = con.setCon;
 
        con.GetMyContacts();
        con.SearchFirstName = 'Test';
        con.SearchLastName = 'Test';
        con.SearchCompany = 'Test';
        con.SearchEmail = 'Test Test';
        con.SearchPhone = 'Test';
        con.SearchCity = 'Test';
        con.SearchState = 'Test';
        con.UseSearch = true;
        //Search with Criteria
   		con.setCon = null;
        setCon = con.setCon;
        con.GetMyContacts();
        con.ToggleDirection('Name');
        con.ApplySort();
        con.AdvancedSearch();
        con.ClearSearch();
        //Verify no Page Errors
        System.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR));
    }
}