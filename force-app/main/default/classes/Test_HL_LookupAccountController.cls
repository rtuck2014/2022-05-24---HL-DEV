@isTest
private class Test_HL_LookupAccountController {
    @isTest private static void TestBasicFunctionality(){
        //Setup Test Data
        Account a = SL_TestSetupUtils.CreateAccount('', 1)[0];
        a.Name = 'Test Account';
        insert a;
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('', 1)[0];
        o.Beneficial_Owner_Control_Person_form__c = 'No';
        insert o;
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('', 1)[0];
        insert e;
        //Setup Query String Parameters
        ApexPages.currentPage().getParameters().put('action','0');
        ApexPages.currentPage().getParameters().put('entity',o.Id);
        ApexPages.currentPage().getParameters().put('secondary',a.Id);
        //Test Controller Properties/Methods
        HL_LookupAccountController con = new HL_LookupAccountController();
        con.getFormTag();
        con.getTextBox();
        for(Integer i = 0; i < HL_LookupAccountController.AccountLookupAction.values().size(); i++)
        {
            con.LookupAction = i;
            con.SearchString = 'Test';
            con.Search();
            //Assert that a result was found
            System.assert(con.SearchResults.size() > 0);
            con.SearchResults[0].Selected = true;
            con.SaveSelected();
        }
        con.Account = new Account(Name='Test Account');
        con.saveAccount();
        
        con.ApplySort();
        con.SaveAndIgnore();
    }
}