@isTest
private class Test_HL_SaleTransactionController {
    @isTest private static void TestBasicFunctionality(){
        //Setup Test Data
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('', 1)[0];
        insert e;
        Sale_Transaction__c st = new Sale_Transaction__c(Engagement__c = e.Id);
        insert st;      
        //Setup Query String Parameters
        ApexPages.currentPage().getParameters().put('id', st.Id);
        ApexPages.currentPage().getParameters().put('eng', e.Id);
        //Test Controller Properties/Methods
        HL_SaleTransactionController con = new HL_SaleTransactionController();
        con.Save();
        con.SaleTransaction = new Sale_Transaction__c();
        con.Save();
        con.SaleTransaction = null;
        con.RecordId = null;
        st = con.SaleTransaction;
    }
}