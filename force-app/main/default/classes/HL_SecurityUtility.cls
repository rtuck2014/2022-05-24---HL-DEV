public without sharing class HL_SecurityUtility {
    private static Set<String> NBCViewAccess;

    static {
        NBCViewAccess= new Set<String>();

        for (GroupMember grpMem : [
            SELECT Id, UserOrGroupId 
            FROM GroupMember 
            WHERE Group.Name = 'NBC Form - View Access']) {

            NBCViewAccess.add(grpMem.UserOrGroupId);
        }
    }

    public static Boolean HasProfile(string profile){
        Profile p = [Select Id FROM Profile WHERE Name =: profile];
        return (p != null && Userinfo.getProfileId() == p.Id);
    }

    //Profile Related Checks
    public static Boolean IsCAO(){
        //Custom Setting
        Profile_Ids__c p = Profile_Ids__c.getOrgDefaults();
        return UserInfo.getProfileId() == p.CAO__c;
    }
    
     //Profile Related Checks
    public static Boolean IsCAOCF(){
        //Custom Setting
        User u = [Select Id,Department FROM User WHERE Id=: UserInfo.getUserId()];
        return u.Department.toUppercase() == 'CF';
    }
    
    public static Boolean IsSysAdmin(){
         //Custom Setting
        Profile_Ids__c p = Profile_Ids__c.getOrgDefaults();
        Id userProfileId = UserInfo.getProfileId();
        system.debug('userProfileId == p.System_Administrator__c'+userProfileId == p.System_Administrator__c);
        return userProfileId == p.System_Administrator__c;
    }
    
      //Group Related Checks
    public static Boolean IsNBCViewGroup(){
        //Custom Setting

        // GM Jan 6, 2022 - this implementation causes too many SOQL queries, moved to static initialization at top of class
        /*
        Set<String> NBCViewAccess= new Set<String>();
        for(GroupMember grpMem : [SELECT Id, UserOrGroupId FROM GroupMember where Group.Name='NBC Form - View Access']){
            NBCViewAccess.add(grpMem.UserOrGroupId);
        }
        */

        return NBCViewAccess.contains(UserInfo.getUserId());
    }

    //Verify Field Accessibility - Especially Useful for Lightning Queries
    public static Boolean VerifyFieldAccess(List<String> fieldList, Map<String, Schema.SObjectField> fieldMap){
        Boolean hasAccess = true;
        for(String field : fieldList){
            if(!fieldMap.get(field).getDescribe().isAccessible()){
                hasAccess = false;
                break;
            }
        }

        if(!hasAccess)
            throw new System.NoAccessException();

        return hasAccess;
    }
}