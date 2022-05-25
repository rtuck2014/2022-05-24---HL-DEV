@isTest
private class Test_HL_RelationshipController {
    @isTest private static void TestBasicFunctionality(){
        //Setup Test Data
        //External Contact
        Contact ec = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        insert ec;
        //Internal Contact
        Contact ic = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        insert ic;
        Relationship__c r = SL_TestSetupUtils.CreateRelationship('', 1)[0];
        r.HL_Contact__c = ic.Id;
        r.External_Contact__c = ec.Id;
        insert r;
        
        //Setup Standard Controller
        ApexPages.StandardController sc = new ApexPages.StandardController(r);
        //Call the Controller Actions for Full Coverage
        HL_RelationshipController con = new HL_RelationshipController(sc);
        //We should not have full note access without being a delegate or the actual relationship contact
        System.assert(!con.HasNoteAccess);
        //Should not be detected as SF1
        System.assert(!con.IsS1);
        
        //Call the Save Method for Full Coverage
        PageReference pf = con.SaveAndReturn();
        //Verify error was not thrown
        System.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR));
        
   }
}