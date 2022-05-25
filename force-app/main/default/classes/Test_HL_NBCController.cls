@isTest
private class Test_HL_NBCController
{
    @isTest
    private static void TestBasicFunctionality()
    {
        //Setup Test Data
        Account a = SL_TestSetupUtils.CreateAccount('', 1)[0];
        Insert a;
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('', 1)[0];
        o.Beneficial_Owner_Control_Person_form__c = 'No';
        Insert o;
        Opportunity_Approval__c oa = SL_TestSetupUtils.CreateOA('', 1)[0];
        oa.Related_Opportunity__c = o.Id;
        Insert oa;
        Test.startTest();
        PageReference pageRef = Page.HL_CNBC;
        Test.setCurrentPage(pageRef);
        //Setup Standard Controller
        ApexPages.StandardController sc = new  ApexPages.StandardController(oa);
        //Test Controller Properties/Methods
        HL_NBCController con = new  HL_NBCController(sc);
        List<Financials__c> financials = con.Financials;
        Financials__c financial = con.NewFinancials;
        con.NewFinancials.Related_Account__c = a.Id;
        con.RefreshFinancials();
        con.SaveAndReturn();
        con.SaveNewFinancial();
        con.SaveRecord();
        Test.stopTest();
        //Confirm there are no errors
        //System.assert(!ApexPages.hasMessages(ApexPages.severity.ERROR));
    }
    @isTest
    private static void Test2()
    {
        //Setup Test Data
        //Insert Additional Clients/Subjects
        Account newClient = SL_TestSetupUtils.CreateAccount('', 1)[0];
        Insert newClient;
        Account newSubject = SL_TestSetupUtils.CreateAccount('', 1)[0];
        Insert newSubject;
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('', 1)[0];
        o.Beneficial_Owner_Control_Person_form__c = 'No';
        Insert o;
        
        contact objcon = new  contact();
        objcon.FirstName = 'Test';
        objcon.LastName = 'Contact';
        objcon.AccountId = newClient.Id;
        Insert objcon;
        
        List<Staff_Role__c> staffRoleList = new List<Staff_Role__c>();
        Staff_Role__c staffRole = new Staff_Role__c();
        staffRole.Name = 'Principal';
        staffRoleList.add(staffRole);
        Staff_Role__c staffRole1 = new Staff_Role__c();
        staffRole.Name = 'Manager';
        staffRoleList.add(staffRole1);
        Staff_Role__c staffRole2 = new Staff_Role__c();
        staffRole.Name = 'Initiator';
        staffRoleList.add(staffRole2);
        insert staffRoleList;
        //System.debug('Staffrole' +staffRoleList[0].Id +staffRoleList[1].Id +staffRoleList[2].Id );
        
        List<Opportunity_Internal_Team__c> oppIntList = new List<Opportunity_Internal_Team__c>();
        Opportunity_Internal_Team__c oppIntTeam = new Opportunity_Internal_Team__c();
        oppIntTeam.Contact__c = objcon.Id;
        oppIntTeam.Opportunity__c = o.Id;
        oppIntTeam.Staff_Role__c = staffRoleList[0].Id;
        oppIntList.add(oppIntTeam);
        
        Opportunity_Internal_Team__c oppIntTeam1 = new Opportunity_Internal_Team__c();
        oppIntTeam1.Contact__c = objcon.Id;
        oppIntTeam1.Opportunity__c = o.Id;
        oppIntTeam1.Staff_Role__c = staffRoleList[1].Id;
        oppIntList.add(oppIntTeam1);
        
        Opportunity_Internal_Team__c oppIntTeam2 = new Opportunity_Internal_Team__c();
        oppIntTeam2.Contact__c = objcon.Id;
        oppIntTeam2.Opportunity__c = o.Id;
        oppIntTeam2.Staff_Role__c = staffRoleList[2].Id;
        oppIntList.add(oppIntTeam2);
        
        insert oppIntList;
        
        Opportunity_Approval__c oa = SL_TestSetupUtils.CreateOA('', 1)[0];
        oa.Related_Opportunity__c = o.Id;
        oa.Form_Type__c = 'NBC';
        oa.Is_Majority_Sale__c = 'Yes';
        oa.EU_Override__c = true;
        Insert oa;
        System.debug(oa.Is_Client_EU__c);
        Financials__c pFinancials = new  Financials__c(Related_Account__c = newClient.Id, Related_Approval__c = oa.Id);
        Insert pFinancials;
        System.debug(oa.Form_Type__C);
        Opportunity_Client_Subject__c addSubject = new  Opportunity_Client_Subject__c(Opportunity__c = o.Id, Primary__c = false, Client_Subject__c = newSubject.Id, Type__c = 'Subject');
        Insert addSubject;
        System.debug(oa.Form_Type__C);
        Test.startTest();
        PageReference pageRef = Page.HL_CNBC;
        Test.setCurrentPage(pageRef);
        //Setup Standard Controller
        ApexPages.StandardController sc = new  ApexPages.StandardController(oa);
        //Test Controller Properties/Methods
        HL_NBCController con = new  HL_NBCController(sc);
        con.SubmitForReview();
        con.SaveRecord();
        System.debug(oa.Form_Type__C);
        con.SaveAndReturn();
        System.debug(oa.Form_Type__C);
        con.DelId = pFinancials.Id;
        Boolean OnOIT = con.OnOIT;
        PageReference objPf = con.TriggerValidation();
        con.DelId = pFinancials.Id;
        con.SubmitToAdmin();
        con.DeleteFinancial();
        con.EUOverride();
        con.IsMajoritySaleValid();
        //con.ValidateNBCForm(oa);
        //con.ValidateCNBCForm();
        /*contact objcon = new  contact();
        objcon.FirstName = 'Test1';
        objcon.LastName = 'Test2';
        Insert objcon;
        contact objcon2 = new  contact();
        objcon2.FirstName = 'Test3';
        objcon2.LastName = 'Test4';
        Insert objcon2;
        list<Contact> lstcon = new  list<Contact>();
        lstcon.add(objcon);
        lstcon.add(objcon2); */
        //con.GetMajoritySaleContactNames(lstcon);
        con.CancelSubmission();
        Test.stopTest();
        //Confirm there are no errors
        //System.assert(!ApexPages.hasMessages(ApexPages.severity.ERROR));
    }
    @isTest
    private static void Test3()
    {
        //Setup Test Data
        //Insert Additional Clients/Subjects
        Account newClient = SL_TestSetupUtils.CreateAccount('', 1)[0];
        Insert newClient;
        Account newSubject = SL_TestSetupUtils.CreateAccount('', 1)[0];
        Insert newSubject;
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('', 1)[0];
        o.Beneficial_Owner_Control_Person_form__c = 'No';
        Insert o;
        Opportunity_Approval__c oa = SL_TestSetupUtils.CreateOA('', 1)[0];
        oa.Related_Opportunity__c = o.Id;
        oa.Form_Type__c = 'NBC';
        Insert oa;
        System.debug(oa.Form_Type__C);
        Financials__c pFinancials = new  Financials__c(Related_Account__c = newClient.Id, Related_Approval__c = oa.Id);
        Insert pFinancials;
        System.debug(oa.Form_Type__C);
        Opportunity_Client_Subject__c addSubject = new  Opportunity_Client_Subject__c(Opportunity__c = o.Id, Primary__c = false, Client_Subject__c = newSubject.Id, Type__c = 'Subject');
        Insert addSubject;
        System.debug(oa.Form_Type__C);
        PageReference pageRef = Page.HL_NBC;
        Test.setCurrentPage(pageRef);
        //Setup Standard Controller
        ApexPages.StandardController sc = new  ApexPages.StandardController(oa);
        //Test Controller Properties/Methods
        HL_NBCController con = new  HL_NBCController(sc);
        con.onchangeFlagSet();
        System.debug(oa.Form_Type__C);
        con.SubmitForReview();
        
    }
}