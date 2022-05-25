public without sharing class HL_Eng_VP_TeamMemberTriggerHelper {
    
    public static void beforeInsert(List<Eng_VP_TeamMember__c> newEngVpTeamMemberList, Map<Id, Eng_VP_TeamMember__c> newEngVpTeamMemberMap, List<Eng_VP_TeamMember__c> oldEngVPTeamMemberList , Map<Id, Eng_VP_TeamMember__c> oldEngVPTeamMemberMap) {
       
    }
        
    public static void afterInsert(List<Eng_VP_TeamMember__c> newEngVpTeamMemberList, Map<Id, Eng_VP_TeamMember__c> newEngVpTeamMemberMap, List<Eng_VP_TeamMember__c> oldEngVPTeamMemberList , Map<Id, Eng_VP_TeamMember__c> oldEngVPTeamMemberMap) { 


        if(!HL_ConstantsUtil.stopExecutionForPVConversion){
            validateDuplicate(newEngVpTeamMemberList, oldEngVPTeamMemberMap);   
            stopModificationTM_Basedon_MRPC_onDelete('AfterInsert', newEngVpTeamMemberList);
        }     
    }
    
    public static void beforeUpdate(List<Eng_VP_TeamMember__c> newEngVpTeamMemberList, Map<Id, Eng_VP_TeamMember__c> newEngVpTeamMemberMap, List<Eng_VP_TeamMember__c> oldEngVPTeamMemberList , Map<Id, Eng_VP_TeamMember__c> oldEngVPTeamMemberMap) {
        if(!HL_ConstantsUtil.stopExecutionForPVConversion){
            stopModificationTM_Basedon_MRPC_onDelete('BeforeUpdate', newEngVpTeamMemberList);
        }
    }
    
    public static void afterUpdate(List<Eng_VP_TeamMember__c> newEngVpTeamMemberList, Map<Id, Eng_VP_TeamMember__c> newEngVpTeamMemberMap, List<Eng_VP_TeamMember__c> oldEngVPTeamMemberList , Map<Id, Eng_VP_TeamMember__c> oldEngVPTeamMemberMap) {
        if(!HL_ConstantsUtil.stopExecutionForPVConversion){
            validateDuplicate(newEngVpTeamMemberList, oldEngVPTeamMemberMap);           
        }
    }
    
    public static void beforeDelete(List<Eng_VP_TeamMember__c> newEngVpTeamMemberList, Map<Id, Eng_VP_TeamMember__c> newEngVpTeamMemberMap, List<Eng_VP_TeamMember__c> oldEngVPTeamMemberList , Map<Id, Eng_VP_TeamMember__c> oldEngVPTeamMemberMap) {
        
        if(!HL_ConstantsUtil.IsSupervisorOrAdmin() && oldEngVPTeamMemberList != null && oldEngVPTeamMemberList.size() > 0 ) {
                oldEngVPTeamMemberList[0].addError(Label.HL_No_Delete_Privilige_VP_Team_Member);                       
        }
        if(!HL_ConstantsUtil.stopExecutionForPVConversion){ 
            stopModificationTM_Basedon_MRPC_onDelete('BeforeDelete',oldEngVPTeamMemberList);
        }                  
    }
    
    public static void afterDelete(List<Eng_VP_TeamMember__c> newEngVpTeamMemberList, Map<Id, Eng_VP_TeamMember__c> newEngVpTeamMemberMap, List<Eng_VP_TeamMember__c> oldEngVPTeamMemberList , Map<Id, Eng_VP_TeamMember__c> oldEngVPTeamMemberMap) {
        
    }

    
    public static void stopModificationTM_Basedon_MRPC_onDelete(String eventType, List<Eng_VP_TeamMember__c> oldEngVpTeamMemberList){
        Monthly_Revenue_Process_Control__c  MRPC = new Monthly_Revenue_Process_Control__c();
        MRPC = HL_Eng_VP_PositionTriggerHelper.fetchMRPC();  
        
          
          User getUserProInfo = [SELECT Id,Name, Profile.Name from User Where Id =: userinfo.getUserId()];
          
            for(Eng_VP_TeamMember__c EngVPTM : [Select id,Engagement_VP_Position__r.Revenue_Month__c, Engagement_VP_Position__r.Revenue_Year__c from Eng_VP_TeamMember__c Where ID in: oldEngVpTeamMemberList AND Engagement_VP_Position__r.Status__c =: System.Label.HL_Eng_VP_Status_Completed])
            {     
             if(MRPC == null){
                 if (eventType == 'BeforeDelete'){                    
                        ((Eng_VP_TeamMember__c)Trigger.oldMap.get(EngVPTM.Id)).addError(System.Label.HL_MRPC_Not_Exists); 
                 }
                 else{                     
                        ((Eng_VP_TeamMember__c)Trigger.newMap.get(EngVPTM.Id)).addError(System.Label.HL_MRPC_Not_Exists); 
                 }
             }
             else
             {
            
                if(HL_Eng_VP_PositionTriggerHelper.isRevenueMonthYearPassed(EngVPTM.Engagement_VP_Position__r.Revenue_Month__c, EngVPTM.Engagement_VP_Position__r.Revenue_Year__c,MRPC) && !(HL_Eng_VP_PositionTriggerHelper.isSuperUserOrSysAdmin()))
                    {
                        if(Trigger.IsInsert)
                            ((Eng_VP_TeamMember__c)Trigger.NewMap.get(EngVPTM.Id)).adderror(System.Label.HL_VP_TeamMember_StopChange);
                        else
                            ((Eng_VP_TeamMember__c)Trigger.oldMap.get(EngVPTM.Id)).adderror(System.Label.HL_VP_TeamMember_StopChange);
                    }
             }
            }
    }

    private static void validateDuplicate(List < Eng_VP_TeamMember__c > teamMemberNewList, Map < Id, Eng_VP_TeamMember__c > teamMemberOldMap) {
    Map < String, Eng_VP_TeamMember__c > teamMemberUniqueMap = new Map < String, Eng_VP_TeamMember__c > ();
    set < string > userSet = new Set < string > ();
    set < string > roles = new Set < string > ();
    set < Id > parentposition = new Set < Id > ();
    List < Eng_VP_TeamMember__c > teamMemberstoIgnore = new List < Eng_VP_TeamMember__c > ();
    for (Eng_VP_TeamMember__c teamMember: teamMemberNewList) 
    {
        if (trigger.isinsert || ((teamMember.Role__c != (teamMemberOldMap.get(teamMember.Id).Role__c)) ||
            (teamMember.Start_Date__c != (teamMemberOldMap.get(teamMember.Id).Start_Date__c)) ||
            (teamMember.End_Date__c != (teamMemberOldMap.get(teamMember.Id).End_Date__c))))
        {
                teamMemberUniqueMap.put((teamMember.Staff__c + '' + teamMember.Role__c + '' + teamMember.Engagement_VP_Position__c), teamMember);
                userSet.add(teamMember.Staff__c);
                roles.add(teamMember.Role__c);
                parentposition.add(teamMember.Engagement_VP_Position__c);
                teamMemberstoIgnore.add(teamMember);
        }
    }   
    for (Eng_VP_TeamMember__c teamMember: [ SELECT Staff__c, Role__c, Start_Date__c, End_Date__c, Engagement_VP_Position__c, Team_Member_Status__c 
                                            FROM Eng_VP_TeamMember__c
                                            WHERE Staff__c IN: userSet and Role__c IN: roles and Engagement_VP_Position__c 
                                                IN: parentposition  limit: Limits.getLimitQueryRows()])
    {
        
        if (teamMemberUniqueMap.containsKey(teamMember.Staff__c + '' + teamMember.Role__c + '' + teamMember.Engagement_VP_Position__c)) 
        {
            Eng_VP_TeamMember__c duplicateRecord = teamMemberUniqueMap.get(teamMember.Staff__c + '' + teamMember.Role__c + '' + teamMember.Engagement_VP_Position__c);
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