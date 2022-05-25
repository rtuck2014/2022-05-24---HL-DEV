@isTest
private class Test_HL_CompanyRelatedOppsController {
	 @isTest private static void TestBasicFunctionality(){
        //Setup Test Data
        Account a = SL_TestSetupUtils.CreateAccount('',1)[0];
        insert a;
        //Setup the Controller
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        
        HL_CompanyRelatedOppsController con = new HL_CompanyRelatedOppsController(sc);
        con.GetOppList();
        
        //Confirm there are no errors
        System.assert(!ApexPages.hasMessages(ApexPages.severity.ERROR));
    }
}