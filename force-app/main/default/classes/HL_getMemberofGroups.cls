/*
Created Date : 9-Nov 2018
Author : R-System
Purpose : to get all members of either directly or indirectly belongs to supervisor group
*/

public class HL_getMemberofGroups{
    public Map<id, Set<Id>> mapOfGroupIdToUsersOnly = new Map<id, Set<Id>>();
    public Map<id, Set<Id>> mapOfGroupIdToInnerGroups = new Map<id, Set<Id>>();
    public Set<Id> userIdSet = new Set<Id>();
    
    public HL_getMemberofGroups(){
        createMapsOfGroups();
    }
    
    public Set<Id> getAllPublicGroupUsers(Id GroupId){
        if(mapOfGroupIdToUsersOnly != NULL && mapOfGroupIdToUsersOnly.containsKey(GroupId))
            userIdSet.addAll(mapOfGroupIdToUsersOnly.get(GroupId));
        
        if(mapOfGroupIdToInnerGroups.containsKey(GroupId)){
            for(Id eachInnerGroup : mapOfGroupIdToInnerGroups.get(GroupId)){
                getAllPublicGroupUsers(eachInnerGroup);
            }
        }
        
        return userIdSet;
    }

    public void createMapsOfGroups(){
    
        List<GroupMember> lstGrpmember = new List<GroupMember>();
        if(test.isrunningtest()){
            lstGrpMember.addall([SELECT UserOrGroupId, GroupId FROM GroupMember where group.type = 'regular' and Group.name = :Label.HL_PV_Portfolio_Valuation_Supervisors
                                 ]);
        }
        else{
            lstGrpMember.addall([SELECT UserOrGroupId, GroupId FROM GroupMember where group.type = 'regular']);
        }
            for(GroupMember eachGroupMember : lstGrpMember)
            {
                if(String.valueOf(eachGroupMember.UserOrGroupId).startsWith('005'))
                {
                    if(!mapOfGroupIdToUsersOnly.containsKey(eachGroupMember.GroupId))
                        mapOfGroupIdToUsersOnly.put(eachGroupMember.GroupId, new Set<Id>());
                    
                    mapOfGroupIdToUsersOnly.get(eachGroupMember.GroupId).add(eachGroupMember.UserOrGroupId);
                }
                
                else if(String.valueOf(eachGroupMember.UserOrGroupId).startsWith('00G'))
                {
                    if(!mapOfGroupIdToInnerGroups.containsKey(eachGroupMember.GroupId))
                        mapOfGroupIdToInnerGroups.put(eachGroupMember.GroupId, new Set<Id>());
                    
                    mapOfGroupIdToInnerGroups.get(eachGroupMember.GroupId).add(eachGroupMember.UserOrGroupId);
                }
            }
        
    }
}