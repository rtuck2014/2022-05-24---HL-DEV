@isTest
private class Test_HL_Relationship {
    @isTest private static void TestBasicFunctionality(){
        //Setup Test Data
        //External Contact
        Contact ec = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        insert ec;
        //Internal Contact
        Contact ic = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        insert ic;
        
        //Call Class Methods
        //Save Relationship
        HL_Relationship.SaveRelationship(ic.Id, ec.Id, 'High', '', '', '', false);
        //This should return our Relationship
        Relationship__c relByEmpAndContact = HL_Relationship.GetByEmployeeAndContact(ic.Id, ec.Id);
        Relationship__c rel = HL_Relationship.GetById(relByEmpAndContact.Id);
        System.assertEquals(relByEmpAndContact.Id, rel.Id);
        
        List<Id> contactRelationships = HL_Relationship.GetContactRelationshipsByUser(UserInfo.getUserId());
        List<Id> companyRelationships = HL_Relationship.GetCompanyRelationshipsByUser(UserInfo.getUserId());
        List<Contact> c = HL_Relationship.GetDefaultContact();
        Boolean hasFullAccess = HL_Relationship.HasFullAccess(rel.Id, UserInfo.getUserId());
        System.assert(!hasFullAccess);
        
        //Test both true and false results
        Boolean doesExist = HL_Relationship.DoesExist(ic.Id, ec.Id);
        Boolean doesNotExist = HL_Relationship.DoesExist(ec.Id, ic.Id);
        System.assert(doesExist);
        System.assert(!doesNotExist);

        //Update Relationship
        HL_Relationship.UpdateRelationship(ic.Id, ec.Id, 'High', '', '', '', false);
   
    }
   
}