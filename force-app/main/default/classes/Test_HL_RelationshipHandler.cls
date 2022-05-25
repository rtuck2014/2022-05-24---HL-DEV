@isTest
private class Test_HL_RelationshipHandler {
    @isTest private static void TestBasicFunctionality(){
         //Setup Test Data
        Contact con = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        insert con;
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        insert c;
        Contact c2 = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        insert c2;
        List<Relationship__c> rList = SL_TestSetupUtils.CreateRelationship('',2);
        for(Relationship__c r : rList){
            r.External_Contact__c = con.Id;
        }
        rList[0].HL_Contact__c = c.id;
        rList[1].HL_Contact__c = c2.id;
        insert rList;          
       
        delete rList;
       
    }
}