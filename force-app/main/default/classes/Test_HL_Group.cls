@isTest
private class Test_HL_Group {
    @isTest private static void TestGroupCRUD(){
        Test.startTest();
        	Group testGroup = HL_Group.CreateGroup('Test', true);
        	//Add Current User to the Group
        	HL_Group.AddGroupMembers(testGroup.Id, new Set<Id> {UserInfo.getUserId()});
        	testGroup = [SELECT DeveloperName FROM Group WHERE Id =: testGroup.Id];
        	Boolean isInGroup = HL_Group.IsInGroup(testGroup.DeveloperName);
        	HL_Group.DeleteGroup(testGroup.Id);
        Test.stopTest();
        
        //Validate the is in group result
        System.assertEquals(isInGroup, true);
    }
    
    @isTest private static void TestGetContacts(){
        //Setup Data
        string groupName = 'TestGroup';
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Contact currentUserContact = SL_TestSetupUtils.CreateContact('',1,SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
            currentUserContact.User__c = UserInfo.getUserId();
            insert currentUserContact;
            
        }
        Group testGroup = HL_Group.CreateGroup(groupName, true);
        //Add Current User to the Group
        HL_Group.AddGroupMembers(testGroup.Id, new Set<Id> {UserInfo.getUserId()});
        Test.startTest();
        	HL_Group hlGroup = new HL_Group(groupName);
        	List<Contact> groupContacts = hlGroup.GetContacts();
        Test.stopTest();
        
        //Validate the contact record is returned
        System.assert(groupContacts.size() > 0);
    }
    
    /*@isTest private static void TestTimeTrackingGroupMethods(){
        //Setup Data
        string groupName = 'Time_Tracking_Litigation';
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Contact currentUserContact = SL_TestSetupUtils.CreateContact('',1,SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
            currentUserContact.User__c = UserInfo.getUserId();
            insert currentUserContact; 
        }
        Group testGroup = HL_Group.CreateGroup(groupName, true);
        //Add Current User to the Group
        HL_Group.AddGroupMembers(testGroup.Id, new Set<Id> {UserInfo.getUserId()});
        
        Test.startTest();
         	string timeTrackingGroup = HL_Group.GetTimeTrackingGroup();
        	List<User> groupMembers = HL_Group.GetTimeTrackingGroupMembers();
        Test.stopTest();
        
        //Validate the group is returned
        System.assert((new Set<String> {'Litigation', 'FR'}).contains(timeTrackingGroup));
        //Validate the group members were returned
        //System.assert(groupMembers.size() > 0);
    }*/
}