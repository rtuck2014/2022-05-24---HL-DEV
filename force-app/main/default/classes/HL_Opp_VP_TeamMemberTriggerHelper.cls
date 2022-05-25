public without sharing class HL_Opp_VP_TeamMemberTriggerHelper {

      
    public static void beforeInsert(List<Opp_VP_TeamMember__c> newOppVpTeamMemberList, Map<Id, Opp_VP_TeamMember__c> newOppVpTeamMemberMap, List<Opp_VP_TeamMember__c> oldOppVPTeamMemberList , Map<Id, Opp_VP_TeamMember__c> oldOppVPTeamMemberMap) {
         // Commented code by Sandeep SF-820
        //changeOwnershipToSystemAdmin(newOppVpTeamMemberList);
        if(newOppVpTeamMemberList != null)
         ResultingEngagemnetRTonVPTM(newOppVpTeamMemberList);
        
    }
    
    public static void afterInsert(List<Opp_VP_TeamMember__c> newOppVpTeamMemberList, Map<Id, Opp_VP_TeamMember__c> newOppVpTeamMemberMap, List<Opp_VP_TeamMember__c> oldOppVPTeamMemberList , Map<Id, Opp_VP_TeamMember__c> oldOppVPTeamMemberMap) { 
        
        // Commented code by Sandeep SF-820
        // To setup sharing for Opp Vp Team Member records with requested accesslevel in SF-191
        //SetupSharingforOppVpTeamMember(newOppVpTeamMemberList);
        validateDuplicate(newOppVpTeamMemberList, oldOppVPTeamMemberMap);
    }
      
    public static void beforeUpdate(List<Opp_VP_TeamMember__c> newOppVpTeamMemberList, Map<Id, Opp_VP_TeamMember__c> newOppVpTeamMemberMap, List<Opp_VP_TeamMember__c> oldOppVPTeamMemberList , Map<Id, Opp_VP_TeamMember__c> oldOppVPTeamMemberMap) {
        if(newOppVpTeamMemberList != null)
         ResultingEngagemnetRTonVPTM(newOppVpTeamMemberList);
    }
    
    public static void afterUpdate(List<Opp_VP_TeamMember__c> newOppVpTeamMemberList, Map<Id, Opp_VP_TeamMember__c> newOppVpTeamMemberMap, List<Opp_VP_TeamMember__c> oldOppVPTeamMemberList , Map<Id, Opp_VP_TeamMember__c> oldOppVPTeamMemberMap) {
        
            validateDuplicate(newOppVpTeamMemberList, oldOppVPTeamMemberMap);
       
    }
    
    public static void beforeDelete(List<Opp_VP_TeamMember__c> newOppVpTeamMemberList, Map<Id, Opp_VP_TeamMember__c> newOppVpTeamMemberMap, List<Opp_VP_TeamMember__c> oldOppVPTeamMemberList , Map<Id, Opp_VP_TeamMember__c> oldOppVPTeamMemberMap) {
        if(oldOppVPTeamMemberMap!= null && oldOppVPTeamMemberList != null )
            stopDeletion(oldOppVPTeamMemberMap,oldOppVPTeamMemberList); 
    }
    
    public static void afterDelete(List<Opp_VP_TeamMember__c> newOppVpTeamMemberList, Map<Id, Opp_VP_TeamMember__c> newOppVpTeamMemberMap, List<Opp_VP_TeamMember__c> oldOppVPTeamMemberList , Map<Id, Opp_VP_TeamMember__c> oldOppVPTeamMemberMap) {
    }
      // commenting Code for SF-820 by Sandeep
    /*
    private static void SetupSharingforOppVpTeamMember(list<Opp_VP_TeamMember__c> newOoppVPPositionList) {      
        
        map<String, list<Id>> OpportunityWithRelatedTMDelegatedUserMap = new map<String, list<Id>>(); 
        Set<Id> RelatedOpportunityIdSet = new Set<Id>();
        List<Opp_VP_TeamMember__c> InsertedOppVpTeamMembersList = new List<Opp_VP_TeamMember__c>();
        InsertedOppVpTeamMembersList = [SELECT id, Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__c, ownerId 
                                        FROM Opp_VP_TeamMember__c
                                        WHERE Id IN : newOoppVPPositionList];                                        
        for(Opp_VP_TeamMember__c opVPTM : InsertedOppVpTeamMembersList) 
        {
            RelatedOpportunityIdSet.add(opVPTM.Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__c);
        }
        OpportunityWithRelatedTMDelegatedUserMap = HL_Opp_VP_TriggerHelper.fetchUserGroupToBeShared(RelatedOpportunityIdSet);
        SetupSharingCoreLogicForOppVPTeamMembers(InsertedOppVpTeamMembersList, OpportunityWithRelatedTMDelegatedUserMap);
    }
    
    public static void SetupSharingCoreLogicForOppVPTeamMembers(list<Opp_VP_TeamMember__c> InsertedOppVpTeamMembersList, map<String, list<Id>> OpportunityWithRelatedTMDelegatedUserMap) { 
        
        list<Opp_VP_TeamMember__share> SharingOppVPTMList = new list<Opp_VP_TeamMember__share>();
        if(InsertedOppVpTeamMembersList != null)
        for(Opp_VP_TeamMember__c opVPTeamMember : InsertedOppVpTeamMembersList) 
        {
            if(OpportunityWithRelatedTMDelegatedUserMap.containsKey(opVPTeamMember.Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__c +'_TM'))
                for(Id UserGroupId : OpportunityWithRelatedTMDelegatedUserMap.get(opVPTeamMember.Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__c +'_TM'))
                {
                    if(UserGroupId != null && UserGroupId != opVPTeamMember.ownerId)
                        SharingOppVPTMList.add(new Opp_VP_TeamMember__share(ParentId = opVPTeamMember.id, UserOrGroupId = UserGroupId, Accesslevel = 'Edit'));
                }
            if(OpportunityWithRelatedTMDelegatedUserMap.containsKey(opVPTeamMember.Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__c +'_DU'))
                for(Id UserGroupId : OpportunityWithRelatedTMDelegatedUserMap.get(opVPTeamMember.Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__c +'_DU'))
                {
                    if(UserGroupId != null && UserGroupId != opVPTeamMember.ownerId)
                        SharingOppVPTMList.add(new Opp_VP_TeamMember__share(ParentId = opVPTeamMember.id, UserOrGroupId = UserGroupId, Accesslevel = 'Edit'));
                }
            if(OpportunityWithRelatedTMDelegatedUserMap.containsKey(opVPTeamMember.Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__c +'_PVSupervsr'))
                for(Id UserGroupId : OpportunityWithRelatedTMDelegatedUserMap.get(opVPTeamMember.Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__c +'_PVSupervsr'))
                {
                    if(UserGroupId != null && UserGroupId != opVPTeamMember.ownerId)
                        SharingOppVPTMList.add(new Opp_VP_TeamMember__share(ParentId = opVPTeamMember.id, UserOrGroupId = UserGroupId, Accesslevel = 'Edit'));
                }
             if(OpportunityWithRelatedTMDelegatedUserMap.containsKey(opVPTeamMember.Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__c +'_PVStafng'))
                for(Id UserGroupId : OpportunityWithRelatedTMDelegatedUserMap.get(opVPTeamMember.Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__c +'_PVStafng'))
                {
                    if(UserGroupId != null && UserGroupId != opVPTeamMember.ownerId)
                        SharingOppVPTMList.add(new Opp_VP_TeamMember__share(ParentId = opVPTeamMember.id, UserOrGroupId = UserGroupId, Accesslevel = 'Edit'));
                }            
        }    
        
        if(SharingOppVPTMList.size() > 0 )
        {
            insert SharingOppVPTMList;
        }   
    }
    
    // To change owner of Opp VP Team Member records to System Administrator 
    private static void changeOwnershipToSystemAdmin(list<Opp_VP_TeamMember__c> newOppVpTeamMemberList) {
                
        for(Opp_VP_TeamMember__c oppVPTeamMember : newOppVpTeamMemberList)
        {
                oppVPTeamMember.ownerId = Label.Salesforce_Administrator_ID;
        }
    }
    */
    private static void stopDeletion(map<id, Opp_VP_TeamMember__c > oldOoppVPMap, List < Opp_VP_TeamMember__c > oldOppVPTeamMemberList ) {        
        
        for(Opp_VP_TeamMember__c opVp : [Select id, Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__r.Converted_to_Engagement__c, Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__r.Approval_Process__c, Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__r.Engagement_Approval_Status__c From Opp_VP_TeamMember__c Where (Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__r.Converted_to_Engagement__c  = true OR (Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__r.Approval_Process__c =: label.HL_AppProcessForEngNo AND Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__r.Engagement_Approval_Status__c=: label.HL_Pending_EngReqNo)) AND Id IN : oldOoppVPMap.KeySet()]) {
             if(opVP.Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__r.Converted_to_Engagement__c == true)  
                oldOoppVPMap.get(opVp.Id).addError(Label.HL_Val_Team_Memb_Deleted_On_ConvtedOpp);
             if(opVp.Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__r.Approval_Process__c == label.HL_AppProcessForEngNo && opVp.Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__r.Engagement_Approval_Status__c == label.HL_Pending_EngReqNo)
                oldOoppVPMap.get(opVp.Id).addError(Label.HL_Team_Mem_Deleted_ReqstedEngNo);
        }
        for(Opp_VP_TeamMember__c teamMember: oldOppVPTeamMemberList){
            if(teamMember.ResultingEngagemnetRTonVPTM__c != 'Portfolio_Valuation' )  
            {
                teamMember.addError(System.Label.HL_VP_TeamMember_Stop_Create_Edit_Delete);
            } 
        } 
        if(!HL_ConstantsUtil.IsSupervisorOrAdmin() && oldOoppVPMap != null && oldOoppVPMap.values() != null&& oldOoppVPMap.values().size() > 0 ) {
                oldOoppVPMap.values()[0].addError(Label.HL_No_Delete_Privilige_VP_Team_Member);
        }        
    }
    
    private static void ResultingEngagemnetRTonVPTM(List < Opp_VP_TeamMember__c > teamMemberNewList) {
        for (Opp_VP_TeamMember__c teamMember: teamMemberNewList) 
        {
            if(teamMember.ResultingEngagemnetRTonVPTM__c != 'Portfolio_Valuation' )  
            {
                teamMember.addError(System.Label.HL_VP_TeamMember_Stop_Create_Edit_Delete);
            }
        }    
    }  
    
    
    private static void validateDuplicate(List < Opp_VP_TeamMember__c > teamMemberNewList, Map < Id, Opp_VP_TeamMember__c > teamMemberOldMap) {
    Map < String, Opp_VP_TeamMember__c > teamMemberUniqueMap = new Map < String, Opp_VP_TeamMember__c > ();
    set < string > userSet = new Set < string > ();
    set < string > roles = new Set < string > ();
    set < Id > parentposition = new Set < Id > ();
    List < Opp_VP_TeamMember__c > teamMemberstoIgnore = new List < Opp_VP_TeamMember__c > ();
    for (Opp_VP_TeamMember__c teamMember: teamMemberNewList) 
    {               
        if (trigger.isinsert || ((teamMember.Role__c != (teamMemberOldMap.get(teamMember.Id).Role__c)) ||
            (teamMember.Start_Date__c != (teamMemberOldMap.get(teamMember.Id).Start_Date__c)) ||
            (teamMember.End_Date__c != (teamMemberOldMap.get(teamMember.Id).End_Date__c))))
        {
                teamMemberUniqueMap.put((teamMember.Staff__c + '' + teamMember.Role__c + '' + teamMember.Opportunity_VP_Position__c), teamMember);
                userSet.add(teamMember.Staff__c);
                roles.add(teamMember.Role__c);
                parentposition.add(teamMember.Opportunity_VP_Position__c);
                teamMemberstoIgnore.add(teamMember);
        }
    }   
    for (Opp_VP_TeamMember__c teamMember: [ SELECT Staff__c, Role__c, Start_Date__c, End_Date__c, Opportunity_VP_Position__c, Team_Member_Status__c
                                            FROM Opp_VP_TeamMember__c
                                            WHERE Staff__c IN: userSet and Role__c IN: roles and Opportunity_VP_Position__c 
                                                IN: parentposition limit: Limits.getLimitQueryRows()])
    {
        if (teamMemberUniqueMap.containsKey(teamMember.Staff__c + '' + teamMember.Role__c + '' + teamMember.Opportunity_VP_Position__c)) 
        {
            Opp_VP_TeamMember__c duplicateRecord = teamMemberUniqueMap.get(teamMember.Staff__c + '' + teamMember.Role__c + '' + teamMember.Opportunity_VP_Position__c);
             if(teamMember.Id != duplicateRecord.id){                                       
              if (((duplicateRecord.Start_Date__c <= teamMember.Start_Date__c || duplicateRecord.Start_Date__c <= teamMember.End_Date__c)&& teamMember.Team_Member_Status__c != 'Inactive' ) || 
                    ((duplicateRecord.Start_Date__c < teamMember.Start_Date__c || duplicateRecord.Start_Date__c < teamMember.End_Date__c)&& teamMember.Team_Member_Status__c == 'Inactive' ) ||
                    (duplicateRecord.Start_Date__c > teamMember.Start_Date__c && teamMember.End_Date__c == null ))
                    {
                        
                        duplicateRecord.addError(System.Label.HL_Date_Overlapping_Error);
                        
                    }
              }
        }       
    }
} 
       
}