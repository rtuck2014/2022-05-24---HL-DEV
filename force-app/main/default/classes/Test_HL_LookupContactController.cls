@isTest
private class Test_HL_LookupContactController {
    @isTest private static void TestBasicFunctionality(){
        //Setup Test Data
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        c.LastName = 'Test';
        c.FirstName = 'Test';
        c.Status__c = 'Active';
        insert c;
        Contact employee = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        employee.LastName = 'Test';
        employee.FirstName = 'Test';
        employee.Status__c = 'Active';
        insert employee;
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('', 1)[0];
        o.Beneficial_Owner_Control_Person_form__c = 'No';
        insert o;
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('', 1)[0];
        insert e;
        //Setup Query String Parameters
        ApexPages.currentPage().getParameters().put('action','0');
        ApexPages.currentPage().getParameters().put('entity',o.Id);
        ApexPages.currentPage().getParameters().put('secondary',c.Id);
        //Test Controller Properties/Methods
        HL_LookupContactController con = new HL_LookupContactController();
        for(Integer i = 0; i < HL_LookupContactController.ContactLookupAction.values().size(); i++)
        {
            con.LookupAction = i;
            con.SearchString = 'Test';
            con.Search();
            //Assert that a result was found
            //System.assert(con.SearchResults.size() > 0);
          //  con.SearchResults[0].Selected = true;
           // con.SaveSelected();
        }
        Engagement_External_Team__c eet = con.DummyRecord;
        List<SelectOption> staffRoleList = con.Roles;
        List<SelectOption> postStaffRoleList = con.PostStaffRoles;
        con.SearchResults[0].Selected = true;
        con.SaveSelected();
        con.LookupAction = 0;
         con.SearchResults[0].Selected = true;
        con.SaveSelected();
        con.LookupAction = 1;
         con.SearchResults[0].Selected = true;
        con.SaveSelected();
        con.LookupAction = 2;
         con.SearchResults[0].Selected = true;
        con.SaveSelected();
        con.LookupAction = 3;
         con.SearchResults[0].Selected = true;
        con.SaveSelected();
        
    }
}