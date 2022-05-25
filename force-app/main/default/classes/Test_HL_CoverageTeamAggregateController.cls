@isTest
public class Test_HL_CoverageTeamAggregateController {
    @isTest public static void TestBasicFunctionality(){
        //Setup Test Data
        Account a = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert a;
        //Setup Standard Controller
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        //Test Properties/Methods
        HL_CoverageTeamAggregateController con = new HL_CoverageTeamAggregateController(sc);
        List<Coverage_Team__c> ct = con.CoverageTeam;
    }
}