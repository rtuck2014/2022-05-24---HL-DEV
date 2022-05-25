@isTest
public class Test_HL_CompanyEngShownController {
    @isTest private static void TestBasicFunctionality(){
            //Setup Test Data
            Account a = SL_TestSetupUtils.CreateAccount('',1)[0];
            insert a;
        	
        	Test.startTest();
                //Setup the Controller
                ApexPages.StandardController sc = new ApexPages.StandardController(a);
                
                HL_CompanyEngagementsShownController con = new HL_CompanyEngagementsShownController(sc);
                con.GetEngList();
            Test.stopTest();
        
            //Confirm there are no errors
            System.assert(!ApexPages.hasMessages(ApexPages.severity.ERROR));
        }
}