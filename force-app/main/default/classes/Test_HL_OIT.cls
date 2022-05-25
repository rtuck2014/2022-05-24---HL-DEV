@isTest
private class Test_HL_OIT {
    @isTest private static void TestBasicFunctionality(){
        //Setup Test Data
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('', 1)[0];
        o.Beneficial_Owner_Control_Person_form__c = 'No';
        insert o;
        
        Boolean isOnTeam = HL_OIT.IsActiveOnTeam(o.Id, UserInfo.getUserId());
        System.assert(!isOnTeam);
    }
}