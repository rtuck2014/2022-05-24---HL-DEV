@isTest
private class Test_HL_FR_DealInformationController {
    
     @isTest private static void TestBasicFunctionality(){
        Engagement__c e = [SELECT Id FROM Engagement__c];
        Engagement_External_Team__c eet = [SELECT Id FROM Engagement_External_Team__c];
        Engagement_Client_Subject__c ecs = [SELECT Id FROM Engagement_Client_Subject__c];
         Test.startTest();
        //Test Properties and Methods of Controller
        ApexPages.StandardController sc = new ApexPages.StandardController(e);
        Test.setCurrentPage(new PageReference('/' + e.id));
        HL_FR_DealInformationController fdi = new HL_FR_DealInformationController(sc);
        Sale_Transaction__c st = fdi.NewSaleTransaction;
        st.Name = 'TestST';
        List<Engagement_Internal_Team__c> eitList = fdi.InitiatorMarketingTeam;
        List<HL_EngagementFinancialsPivot> efpList = fdi.EngagementFinancials;
        HL_EngagementFinancialsPivot efpRevenue = fdi.RevenueFinancials;
        HL_EngagementFinancialsPivot efpEBITDA = fdi.EBITDAFinancials;
        HL_EngagementFinancialsPivot efpCapex = fdi.CapexFinancials;
        //List<Sale_Transaction__c> stList = fdi.SalesTransactions;
        List<Financing__c> fList = fdi.Financing; 
        List<Engagement_Client_Subject__c> ecsPreList = fdi.PreTransactionEquityHolders;
        List<Engagement_Client_Subject__c> ecsPostList = fdi.PostTransactionEquityHolders;
        List<HL_FR_DealInformationController.aBoardMember> eetPreBoard = fdi.PreTransactionBoardMembers;
        List<HL_FR_DealInformationController.aBoardMember> eetPostBoard = fdi.PostTransactionBoardMembers;
        List<HL_FR_DealInformationController.aDebtStructure> eetPreDebt = fdi.PreTransactionDebtStructures;
        List<HL_FR_DealInformationController.aDebtStructure> eetPostDebt = fdi.PostTransactionDebtStructures;
        Engagement_Financials__c efRecord = fdi.EngagementFinancialsRecord;
        List<Sale_Transaction__c> salesTransactions = fdi.SalesTransactions;
        List<Engagement_External_Team__c> postTransStaffRoles = fdi.PostTransactionStaffRoles;
         Test.StopTest();
    }
    
     @isTest private static void TestBasicFunctionality2(){
        Engagement__c e = [SELECT Id FROM Engagement__c];
        Engagement_External_Team__c eet = [SELECT Id,Contact__c FROM Engagement_External_Team__c];
        Engagement_Client_Subject__c ecs = [SELECT Id FROM Engagement_Client_Subject__c];
         
        //Test Properties and Methods of Controller
        ApexPages.StandardController sc = new ApexPages.StandardController(e);
        Test.setCurrentPage(new PageReference('/' + e.id));
        HL_FR_DealInformationController fdi = new HL_FR_DealInformationController(sc);
        Test.startTest();        
        fdi.UpdateCapexFinancials();
        fdi.UpdateEBITDAFinancials();
        fdi.UpdateRevenueFinancials();
        fdi.AddNewSalesTransaction();
        fdi.NewPreTransactionDebtStructure.Security_Type__c = '';
        fdi.NewPostTransactionDebtStructure.Security_Type__c = '';
        fdi.NewFinancing.Financing_Type__c = '';
        fdi.SaveNewPostTransactionDebtStructure();
        fdi.SaveNewPreTransactionDebtStructure();
        fdi.SaveNewFinancing();
        fdi.RefreshFinancing();
        fdi.RefreshPostTransactionBoardMembers();
        fdi.RefreshPostTransactionDebtStructures();
        fdi.RefreshPostTransactionEquityHolders();
        fdi.RefreshPostTransactionStaffRoles();
        fdi.RefreshPreTransactionBoardMembers();
        fdi.RefreshPreTransactionDebtStructures();
        fdi.RefreshPreTransactionEquityHolders();
        fdi.RefreshSalesTransactions();
        fdi.CopyBMToPostID = eet.Id;
        fdi.CopyBMToPost();
        fdi.CopyEHToPostID = ecs.Id;
          fdi.CopyEHToPost();
        fdi.SaveAndReturn();
        fdi.SaveRecord();
        fdi.CancelAction();
        fdi.DelId = eet.Id;
        fdi.DeleteFinancing();
        fdi.DeletePostBM();
        fdi.DeletePostDS();
        fdi.DeletePostEH();
        fdi.DeletePostSR();
        fdi.DeletePreBM();        
        fdi.DeletePreDS();
        fdi.DeletePreEH();
        fdi.DeleteSalesTransaction();
        fdi.checkEngSendBTPEmail();        
        fdi.DeletePostSREXT();
        HL_FR_DealInformationController.aBoardMember obj = new HL_FR_DealInformationController.aBoardMember(eet);
         Test.StopTest();
    }
    /*
    @isTest private static void TestBasicFunctionalityOld(){
        Engagement__c e = [SELECT Id FROM Engagement__c];
        Engagement_External_Team__c eet = [SELECT Id FROM Engagement_External_Team__c];
        Engagement_Client_Subject__c ecs = [SELECT Id FROM Engagement_Client_Subject__c];
         
        //Test Properties and Methods of Controller
        ApexPages.StandardController sc = new ApexPages.StandardController(e);
        Test.setCurrentPage(new PageReference('/' + e.id));
        HL_FR_DealInformationController fdi = new HL_FR_DealInformationController(sc);
        Sale_Transaction__c st = fdi.NewSaleTransaction;
        st.Name = 'TestST';
        List<Engagement_Internal_Team__c> eitList = fdi.InitiatorMarketingTeam;
        List<HL_EngagementFinancialsPivot> efpList = fdi.EngagementFinancials;
        HL_EngagementFinancialsPivot efpRevenue = fdi.RevenueFinancials;
        HL_EngagementFinancialsPivot efpEBITDA = fdi.EBITDAFinancials;
        HL_EngagementFinancialsPivot efpCapex = fdi.CapexFinancials;
        //List<Sale_Transaction__c> stList = fdi.SalesTransactions;
        List<Financing__c> fList = fdi.Financing; 
        List<Engagement_Client_Subject__c> ecsPreList = fdi.PreTransactionEquityHolders;
        List<Engagement_Client_Subject__c> ecsPostList = fdi.PostTransactionEquityHolders;
        List<HL_FR_DealInformationController.aBoardMember> eetPreBoard = fdi.PreTransactionBoardMembers;
        List<HL_FR_DealInformationController.aBoardMember> eetPostBoard = fdi.PostTransactionBoardMembers;
        List<HL_FR_DealInformationController.aDebtStructure> eetPreDebt = fdi.PreTransactionDebtStructures;
        List<HL_FR_DealInformationController.aDebtStructure> eetPostDebt = fdi.PostTransactionDebtStructures;
        Engagement_Financials__c efRecord = fdi.EngagementFinancialsRecord;
        List<Sale_Transaction__c> salesTransactions = fdi.SalesTransactions;
        List<Engagement_External_Team__c> postTransStaffRoles = fdi.PostTransactionStaffRoles;
        
        fdi.UpdateCapexFinancials();
        fdi.UpdateEBITDAFinancials();
        fdi.UpdateRevenueFinancials();
        fdi.AddNewSalesTransaction();
        fdi.NewPreTransactionDebtStructure.Security_Type__c = '';
        fdi.NewPostTransactionDebtStructure.Security_Type__c = '';
        fdi.NewFinancing.Financing_Type__c = '';
        fdi.SaveNewPostTransactionDebtStructure();
        fdi.SaveNewPreTransactionDebtStructure();
        fdi.SaveNewFinancing();
        fdi.RefreshFinancing();
        fdi.RefreshPostTransactionBoardMembers();
        fdi.RefreshPostTransactionDebtStructures();
        fdi.RefreshPostTransactionEquityHolders();
        fdi.RefreshPostTransactionStaffRoles();
        fdi.RefreshPreTransactionBoardMembers();
        fdi.RefreshPreTransactionDebtStructures();
        fdi.RefreshPreTransactionEquityHolders();
        fdi.RefreshSalesTransactions();
        fdi.CopyBMToPostID = eet.Id;
        fdi.CopyBMToPost();
        fdi.CopyEHToPostID = ecs.Id;
          fdi.CopyEHToPost();
        fdi.SaveAndReturn();
        fdi.SaveRecord();
        fdi.CancelAction();
        fdi.DelId = eet.Id;
        fdi.DeleteFinancing();
        fdi.DeletePostBM();
        fdi.DeletePostDS();
        fdi.DeletePostEH();
        fdi.DeletePostSR();
        fdi.DeletePreBM();
        Test.StartTest();
        fdi.DeletePreDS();
        fdi.DeletePreEH();
        fdi.DeleteSalesTransaction();
        fdi.checkEngSendBTPEmail();
        
        fdi.DeletePostSREXT();
        HL_FR_DealInformationController.aBoardMember obj = new HL_FR_DealInformationController.aBoardMember(eet);
         Test.StopTest();
    }*/
    
    @TestSetup
    private static void setupData(){
         //Setup the Test Data
        Account a = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert a;
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        insert c;
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('',1)[0];
        e.Client__c = a.Id;
        e.Subject__c = a.Id;
        insert e;
        Engagement_External_Team__c eet = SL_TestSetupUtils.CreateEET('', 1)[0];
        eet.Engagement__c = e.Id;
        eet.Contact__c = c.Id;
        insert eet;
        Engagement_Client_Subject__c ecs = new Engagement_Client_Subject__c();
        ecs.Engagement__c = e.Id;
        ecs.Client_Subject__c = a.Id;
        insert ecs;
    }    
    
}