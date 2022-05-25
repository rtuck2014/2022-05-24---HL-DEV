@isTest
public class Test_HL_DebtStructureController {
    @isTest public static void TestBasicFunctionality(){
        //Setup Test Data
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('',1)[0];
        insert e;
        Debt_Structure__c ds = new Debt_Structure__c(Engagement__c = e.id);
        insert ds;
        
        //Setup Page Query String
        ApexPages.currentPage().getParameters().put('id', ds.Id);
        ApexPages.currentPage().getParameters().put('eng', e.Id);
        ApexPages.currentPage().getParameters().put('action', '1');
        
        //Test Controller Functionality
        HL_DebtStructureController con = new HL_DebtStructureController();
        List<Engagement_Client_Subject__c> lenders = con.Lenders;
        con.RefreshLenders();
        con.RecordId = ds.Id;
        ds = con.DebtStructure;
        con.DebtStructure = null;
        con.RecordId = null;
        ds = con.DebtStructure;
        con.DebtStructure = new Debt_Structure__c();
        con.Save();
    }
}