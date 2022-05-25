public class HL_Group {
    private String GroupName {get; set;}
    public HL_Group(String groupName){
        this.GroupName = groupName;
    }

    //Gets the contact records for the users within the group
    public List<Contact> GetContacts(){
        List<Contact> contactRecords = new List<Contact>();
        
        for(Contact c : [SELECT Name, Email, Office__c, Title, User__c FROM Contact WHERE User__c IN: HL_Group.GetGroupMembers(GroupName)])
                contactRecords.add(c);

        return contactRecords;
    }

    public static Group CreateGroup(String groupName,Boolean includeBosses){
        Group newGroup = new Group(Name = groupName, Type = 'Regular', DoesIncludeBosses = includeBosses);
        insert newGroup;
        return newGroup;
    }
    
    public static void AddGroupMembers(Id groupId, Set<Id> userIds){
        List<GroupMember> newMembers = new List<GroupMember>();
        
        for(Id userId : userIds){
            newMembers.add(new GroupMember(GroupId = groupId,UserOrGroupId = userId));
        }
        
        if(newMembers.size() > 0)
            insert newMembers;
    }
    
    public static Group DeleteGroup(Id groupId){
        Group deleteGroup = [SELECT Id FROM Group WHERE Id=:groupId];
        delete deleteGroup;
        return deleteGroup;
    }

    public static Boolean IsInGroup(String groupName){
        return IsInGroup(UserInfo.getUserId(), groupName);
    }
    public static Boolean IsInGroup(Id userOrGroupId, String groupName){
        List<GroupMember> gms = [SELECT Id FROM GroupMember WHERE UserOrGroupId =: userOrGroupId AND Group.DeveloperName =: groupName];
        return gms.size() > 0;
    }
    
    public static List<GroupMember> GetGroups(Id userId){
        List<GroupMember> gmList = [SELECT Group.DeveloperName FROM GroupMember WHERE UserOrGroupId =: userId];
        return gmList;
    }
    
    @AuraEnabled
    public static List<User> GetTimeTrackingGroupMembers(){
        return GetGroupMembers('Time_Tracking_' + GetTimeTrackingGroup());
    }

    @AuraEnabled
    public static List<User> GetGroupMembers(string groupName){
        Set<Id> userIds = new Set<Id>();
        
        for(GroupMember gm : [SELECT userOrGroupId FROM GroupMember WHERE Group.DeveloperName =: groupName])
            userIds.add(gm.UserOrGroupId);
        
        return [SELECT Name, Title, Phone, Email FROM User WHERE Id IN:userIds ORDER BY Name];
    }

    public static String GetTimeTrackingGroup(){
        List<String> categories = HL_Utility.GetPicklistValues('Time_Record_Period__c', 'Period_Category__c');
        List<GroupMember> groupList = GetGroups(UserInfo.getUserId());
        string category = '';
        
        //All Time Tracking Groups Should/Must Start with: Time_Tracking_
        for(string c : categories){
            for(GroupMember gm : groupList){
                if('Time_Tracking_' + c == gm.Group.DeveloperName || 'Time_Tracking_' + c + '_Supervisor' == gm.Group.DeveloperName){
                    category = c;
                    break;
                }
            }
        }

        return category;
    }
}