public class HL_EngagementViewController {
    //Assuming that SysAdmin and CAO's are included as part of EIT Permissions
    public Boolean OnEIT{get{
        if(onEIT == null)
            onEIT = HL_Utility.IsSysAdmin() || HL_Utility.IsCAO() || HL_EIT.IsActiveOnTeam(Engagement.Id,UserInfo.getUserId());
        return onEIT;
    }set;}
    public Boolean isValidPVUser{get;set;}
    public Boolean AddCommentsAccess{get{ return OnEIT;}}
    public Engagement__c Engagement {get; set;}
    public String isQueueableRun {get;set;}
    public String convertedMsg{get;set;}
    public Boolean counterparties_permission{get;set;}
    public HL_EngagementViewController(ApexPages.StandardController controller){
        Engagement = (Engagement__c)controller.getRecord();
         if(Engagement != null) {   
             isQueueableRun = ApexPages.currentPage().getParameters().get('converted');
             convertedMsg = label.OppToEngagementConvert;
            isValidPVUser = VerifyUserforVP(Engagement, 'EngagementPV');
          if(!isValidPVUser)
            for(User u : [SELECT Id, Profile.Name from User Where Id =: userinfo.getUserId() AND Profile.Name = 'System Administrator (Read Only)'])
            {
              isValidPVUser = true;
            }
        }
        system.debug('==test=='+isValidPVUser);
        
        //Permission set logic
        List<PermissionSetAssignment> lstcurrentUserPerSet = [SELECT Id, PermissionSet.Name,AssigneeId,
                                                              Assignee.Profile.Name FROM PermissionSetAssignment
                                                                WHERE AssigneeId = :Userinfo.getUserId()];
	    system.debug('##lstcurrentUserPerSet' + lstcurrentUserPerSet);
        counterparties_permission =false;
        //id profileId=[Select Id,Name from Profile where name='Standard User Template'].Id;
        for ( PermissionSetAssignment psa : lstcurrentUserPerSet ) {
            System.debug('##psa.PermissionSet.Name' + psa.PermissionSet.Name);//profileId==userinfo.getProfileId() && 
            if(psa.PermissionSet.Name.equals('Access_to_view_Counterparties_and_Bids')) {
                counterparties_permission = true;
                break;
            }
        }
    }
    
    public static boolean VerifyUserforVP(Engagement__c Eng, String VerifyTo) {     
        boolean isloggedInUserValidForPV = false;       
        List<Profile> ProfileList = new List<Profile>();        
        Id LoggedInUserProfileId = Userinfo.getProfileId();     
        for(Profile prf : [SELECT Id from Profile WHERE Name = 'System Administrator'  OR Name = 'System Administrator (Read Only)'])       
        {       
            if(LoggedInUserProfileId == prf.id)     
            {       
                isloggedInUserValidForPV = true;        
            }       
        }       
                        
        Set<Id> relatedDelegatedPublicGroupIds = new Set<Id>();     
                    
        map<String, list<Id>> EngagementWithRelatedTMDelegatedUserMap = new map<String, list<Id>>();       
        set<Id> RelatedEngagementIdSet = new set<Id>();        
        set<Id> RelatedUserIdSet = new set<Id>();       
        set<Id> RelatedGroupIdSet = new set<Id>();      
        RelatedEngagementIdSet.add(Eng.id);        
        if(isloggedInUserValidForPV == false && RelatedEngagementIdSet.size() > 0 )        
        {       
            EngagementWithRelatedTMDelegatedUserMap = HL_Eng_VP_TriggerHelper.fetchUserGroupToBeShared(RelatedEngagementIdSet);                   
                    
            if(EngagementWithRelatedTMDelegatedUserMap != null && EngagementWithRelatedTMDelegatedUserMap.KeySet().size() > 0)        
            for(Id opId : RelatedEngagementIdSet)      
            {       
                if(EngagementWithRelatedTMDelegatedUserMap.containsKey(opId+'_TM'))                    
                    for(Id UserGroupId : EngagementWithRelatedTMDelegatedUserMap.get(opId+'_TM'))      
                    {       
                         if(UserGroupId == UserInfo.getUserId())        
                         {      
                            isloggedInUserValidForPV = true;        
                            break;      
                         }              
                    }       
                if(EngagementWithRelatedTMDelegatedUserMap.containsKey(opId+'_DU'))                        
                    for(Id UserGroupId : EngagementWithRelatedTMDelegatedUserMap.get(opId+'_DU'))      
                    {       
                        if(UserGroupId != null && String.valueof(UserGroupId).substring(0,3) == '00G')      
                        {       
                            relatedDelegatedPublicGroupIds.add(UserGroupId);        
                        }       
                        else        
                        {       
                            if(UserGroupId == UserInfo.getUserId())     
                            {       
                                isloggedInUserValidForPV = true;        
                                break;      
                            }       
                        }                               
                    }       
                if(EngagementWithRelatedTMDelegatedUserMap.containsKey(opId+'_PVSupervsr'))        
                    for(Id UserGroupId : EngagementWithRelatedTMDelegatedUserMap.get(opId+'_PVSupervsr'))      
                    {       
                        if(UserGroupId != null && String.valueof(UserGroupId).substring(0,3) == '00G')      
                        {       
                            relatedDelegatedPublicGroupIds.add(UserGroupId);        
                        }       
                    }
                 /*for(Group grp:  [SELECT Id, Name FROM Group WHERE Name =: 'CAO FVA'])
                   relatedDelegatedPublicGroupIds.add(grp.Id);
                */
                 isloggedInUserValidForPV = IsUserMemberofPVSuperVisorOrItschildGroup();
                  system.debug('==test=='+isloggedInUserValidForPV );
                // Commented Code by Sandeep SF-820
                /*if(VerifyTo == 'EngagementPV') {
                if(EngagementWithRelatedTMDelegatedUserMap.containsKey(opId+'_PVStafng'))      
                    for(Id UserGroupId : EngagementWithRelatedTMDelegatedUserMap.get(opId+'_PVStafng'))        
                    {       
                        if(UserGroupId != null && String.valueof(UserGroupId).substring(0,3) == '00G')      
                        {       
                            relatedDelegatedPublicGroupIds.add(UserGroupId);        
                        }       
                    }   
                }*/                
            }           
                    
        }       
                
       if(isloggedInUserValidForPV == false && relatedDelegatedPublicGroupIds.size() > 0)       
        for (GroupMember gm : [SELECT Id, groupId  FROM GroupMember where UserOrGroupId =: UserInfo.getUserId()])       
        {       
            if(relatedDelegatedPublicGroupIds.contains(gm.groupId))     
            {       
                isloggedInUserValidForPV= true;     
            }       
        }       
        system.debug('==test=='+isloggedInUserValidForPV );
        return isloggedInUserValidForPV;        
    }
    
    public static boolean IsUserMemberofPVSuperVisorOrItschildGroup()
    {
         if(HL_ConstantsUtil.isSupervisorMethodExecuted)
        {
            return HL_ConstantsUtil.resultFromSupervisorCalculation;
        }
        else {
            boolean IsAccessibleUser = false;
            //Declaring a Set as we don't want Duplicate Group Ids
            Set<Id> results = new Set<Id>();
            
            //Groups directly associated to user
            Set<Id> groupwithUser = new Set<Id>();
            
            //Populating the Group with User with GroupId we are filtering only  for Group of Type Regular,Role and RoleAndSubordinates
            for(GroupMember  u :[select groupId from GroupMember where UserOrGroupId =: userinfo.getUserId() and (Group.Type = 'Regular')])
            {
                groupwithUser.add(u.groupId);
            }
            
            
            //Combining both the Set
            results.addAll(groupwithUser);
            list<id> tempIDList;
            //Traversing the whole list of Groups to check any other nested Group
            Map<Id,list<Id>> grMap = new Map<Id,List<Id>>();
            for(GroupMember gr : [select id, UserOrGroupId, Groupid from GroupMember where (Group.Type = 'Regular') AND UserOrGroupId IN: results])
            {
                if(!grMap.containskey(gr.UserOrGroupId)){
                   tempIDList = new List<Id>();
                   tempIDList.add(gr.Groupid);
                   grMap.put(gr.UserOrGroupId,tempIDList);
                }
                else
                   grMap.get(gr.UserOrGroupId).add(gr.Groupid);
            }
            
            for(Id i :results)
            {
                if(grMap.containsKey(i))
                {
                    results.addAll(grMap.get(i));
                }
            }
            
            for(Group grp : [Select id from Group WHERE type='Regular' AND DeveloperName = 'Portfolio_Valuation_Supervisors'])
            {
                if(results.contains(grp.id))
                    IsAccessibleUser = true;
            }
            HL_ConstantsUtil.isSupervisorMethodExecuted = true;
            HL_ConstantsUtil.resultFromSupervisorCalculation =IsAccessibleUser;
            return IsAccessibleUser ;        
        }
    }
    
}