@isTest
private class Test_HL_CompanyRelEngagementsController {
    @isTest private static void TestBasicFunctionality(){
        //Setup Test Data
        Account a = SL_TestSetupUtils.CreateAccount('',1)[0];
        insert a;
        //Setup the Controller
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        
        HL_CompanyRelatedEngagementsController con = new HL_CompanyRelatedEngagementsController(sc);
        con.GetEngList();
        
        //Confirm there are no errors
        System.assert(!ApexPages.hasMessages(ApexPages.severity.ERROR));
    }
}