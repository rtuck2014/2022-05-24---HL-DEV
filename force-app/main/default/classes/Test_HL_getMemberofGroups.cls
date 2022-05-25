@istest

private class Test_HL_getMemberofGroups{

    @istest
    static void testcreateMapsOfGroups(){
    
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
          System.runAs (thisUser) 
          {        
            
            Group grpId = [SELECT Id FROM Group WHERE Name = :Label.HL_PV_Portfolio_Valuation_Supervisors];
            
            GroupMember GM = new GroupMember();
            GM.GroupId = grpId.id;
            GM.UserOrGroupId = thisUser.Id;
            insert GM;
         
            HL_getMemberofGroups objHL_getMemberofGroups = new HL_getMemberofGroups();
            objHL_getMemberofGroups.getAllPublicGroupUsers(grpId.Id);
            
        }
    }


}