public class HL_Opp_VP_TriggerHelper {
    
    public static void beforeInsert(List<Opp_VP__c> newOoppVPList, Map<Id, Opp_VP__c> newOoppVPMap, List<Opp_VP__c> oldOoppVPList , Map<Id, Opp_VP__c> oldOoppVPMap) {
        changeOwnershipToSystemAdmin(newOoppVPList);
        avoidChangesOnRollupFieldsOnVP('BeforeInsert', newOoppVPList, null, null, null);  
    }
    
    public static void afterInsert(List<Opp_VP__c> newOoppVPList, Map<Id, Opp_VP__c> newOoppVPMap, List<Opp_VP__c> oldOoppVPList , Map<Id, Opp_VP__c> oldOoppVPMap) { 
        SetupSharingforOppVp(newOoppVPList);
        
    }
    
    public static void beforeUpdate(List<Opp_VP__c> newOoppVPList, Map<Id, Opp_VP__c> newOoppVPMap, List<Opp_VP__c> oldOoppVPList , Map<Id, Opp_VP__c> oldOoppVPMap) {
        avoidChangesOnRollupFieldsOnVP('BeforeUpdate', newOoppVPList, newOoppVPMap, oldOoppVPList , oldOoppVPMap);     
    }
    /*
    public static void afterUpdate(List<Opp_VP__c> newOoppVPList, Map<Id, Opp_VP__c> newOoppVPMap, List<Opp_VP__c> oldOoppVPList , Map<Id, Opp_VP__c> oldOoppVPMap) {
    }*/
    
    public static void beforeDelete(List<Opp_VP__c> newOoppVPList, Map<Id, Opp_VP__c> newOoppVPMap, List<Opp_VP__c> oldOoppVPList , Map<Id, Opp_VP__c> oldOoppVPMap) {
        avoidChangesOnRollupFieldsOnVP('BeforeDelete',null,null,oldOoppVPList,null);  
        if(oldOoppVPMap != null)
            stopDeletion(oldOoppVPMap);
    //    if(newOoppVPList != null)   

    }
    /*
    public static void afterDelete(List<Opp_VP__c> newOoppVPList, Map<Id, Opp_VP__c> newOoppVPMap, List<Opp_VP__c> oldOoppVPList , Map<Id, Opp_VP__c> oldOoppVPMap) {

    }*/
    private static void stopDeletion(map<id, Opp_VP__c> oldOoppVPMap) {
        
        for(Opp_VP__c opVp : [Select id, Opportunity__r.Converted_to_Engagement__c, Opportunity__r.Approval_Process__c, Opportunity__r.Engagement_Approval_Status__c From Opp_Vp__c Where (Opportunity__r.Converted_to_Engagement__c = true OR (Opportunity__r.Approval_Process__c =: label.HL_AppProcessForEngNo AND Opportunity__r.Engagement_Approval_Status__c=: label.HL_Pending_EngReqNo)) AND Id IN : oldOoppVPMap.KeySet()]) {
            if(opVP.Opportunity__r.Converted_to_Engagement__c == true)
                oldOoppVPMap.get(opVp.Id).AddError(Label.HL_Val_Pos_Deleted_On_ConvtedOpp);
            if(opVp.Opportunity__r.Approval_Process__c == label.HL_AppProcessForEngNo && opVp.Opportunity__r.Engagement_Approval_Status__c == label.HL_Pending_EngReqNo)
                 oldOoppVPMap.get(opVp.Id).addError(Label.HL_Val_Pos_Deleted_ReqstedEngNo);
            
        }
        if(!HL_ConstantsUtil.IsSupervisorOrAdmin() && oldOoppVPMap != null && oldOoppVPMap.values() != null&& oldOoppVPMap.values().size() > 0 ) {
            oldOoppVPMap.values()[0].addError(Label.HL_No_Delete_Privilige_VP_Position);
        }
    }
    
    
    // To change owner of Opp VP records to System Administrator 
    private static void changeOwnershipToSystemAdmin(list<Opp_VP__c> newOoppVPList) {
        for(Opp_VP__c oppVP : newOoppVPList)
        {
                oppVP.ownerId = Label.Salesforce_Administrator_ID;
                oppVP.CurrencyIsoCode = OppVP.Parent_Currency_Formula__c;
        }
    }
    
    private static void SetupSharingforOppVp(list<Opp_VP__c> newOoppVPList) {       
        
        map<String, list<Id>> OpportunityWithRelatedTMDelegatedUserMap = new map<String, list<Id>>(); 
        Set<Id> RelatedOpportunityIdSet = new Set<Id>();
        for(Opp_VP__c opVp : newOoppVPList) 
        {
            RelatedOpportunityIdSet.add(opVp.Opportunity__c);
        }
        OpportunityWithRelatedTMDelegatedUserMap = fetchUserGroupToBeShared(RelatedOpportunityIdSet);
        SetupSharingCoreLogicForOppVP(newOoppVPList, OpportunityWithRelatedTMDelegatedUserMap);
        
    }       
    
    public static map<String, list<Id>> fetchUserGroupToBeShared(Set<Id> RelatedOpportunityIdSet) {        
        
        map<String, list<Id>> OpportunityWithRelatedTMDelegatedUserMap = new map<String, list<Id>>();
        list<Opportunity_Internal_Team__c> OppInternalTeamMemberList = new list<Opportunity_Internal_Team__c>();
        OppInternalTeamMemberList = [SELECT contact__r.user__c, Opportunity__c 
                                     FROM Opportunity_Internal_Team__c 
                                     WHERE End_Date__c = NULL AND contact__r.user__r.IsActive = True AND Opportunity__c IN : RelatedOpportunityIdSet];
                                                
        if(OppInternalTeamMemberList.size() > 0)
            OpportunityWithRelatedTMDelegatedUserMap = fetchUserGroupOnlyRelatedToOIT(OppInternalTeamMemberList);        
           
     
        Id PVSupervisorGrpId ;            
        for(Group grp:  [SELECT Id, Name     FROM Group WHERE Name =: system.Label.HL_PV_Portfolio_Valuation_Supervisors])
        {          
            if(grp.Name == system.Label.HL_PV_Portfolio_Valuation_Supervisors)
            {
                PVSupervisorGrpId = grp.Id;
            }
        }
        
        for(Id optyId : RelatedOpportunityIdSet)
        {            
            OpportunityWithRelatedTMDelegatedUserMap.put(optyId+'_PVSupervsr',new List<Id>{PVSupervisorGrpId});
        }       
        return OpportunityWithRelatedTMDelegatedUserMap;
    }    
    
    public static void SetupSharingCoreLogicForOppVP(list<Opp_VP__c> newOoppVPList , map<String, list<Id>> OpportunityWithRelatedTMDelegatedUserMap)
    {
        list<Opp_VP__share> SharingOppVPList = new list<Opp_VP__Share>();
        if(newOoppVPList != null )
        for(Opp_VP__c opVp : newOoppVPList) 
        {
            if(OpportunityWithRelatedTMDelegatedUserMap.containsKey(opVp.Opportunity__c+'_TM'))            
                for(Id UserGroupId : OpportunityWithRelatedTMDelegatedUserMap.get(opVp.Opportunity__c+'_TM'))
                {
                     if(UserGroupId != null && UserGroupId != opVp.ownerId)
                        SharingOppVPList.add(new Opp_VP__share(ParentId = opVp.id, UserOrGroupId = UserGroupId, Accesslevel = 'Edit'));
                }
            if(OpportunityWithRelatedTMDelegatedUserMap.containsKey(opVp.Opportunity__c+'_DU'))             
                for(Id UserGroupId : OpportunityWithRelatedTMDelegatedUserMap.get(opVp.Opportunity__c+'_DU'))
                {
                    if(UserGroupId != null && UserGroupId != opVp.ownerId)
                        SharingOppVPList.add(new Opp_VP__share(ParentId = opVp.id, UserOrGroupId = UserGroupId, Accesslevel = 'Edit'));
                }
            if(OpportunityWithRelatedTMDelegatedUserMap.containsKey(opVp.Opportunity__c+'_PVSupervsr'))
                for(Id UserGroupId : OpportunityWithRelatedTMDelegatedUserMap.get(opVp.Opportunity__c+'_PVSupervsr'))
                {
                    if(UserGroupId != null && UserGroupId != opVp.ownerId)
                        SharingOppVPList.add(new Opp_VP__share(ParentId = opVp.id, UserOrGroupId = UserGroupId, Accesslevel = 'Edit'));
                } 
            // Commented Code by Sandeep SF-820
            /*if(OpportunityWithRelatedTMDelegatedUserMap.containsKey(opVp.Opportunity__c+'_PVStafng'))
                for(Id UserGroupId : OpportunityWithRelatedTMDelegatedUserMap.get(opVp.Opportunity__c+'_PVStafng'))
                {
                    if(UserGroupId != null && UserGroupId != opVp.ownerId)
                        SharingOppVPList.add(new Opp_VP__share(ParentId = opVp.id, UserOrGroupId = UserGroupId, Accesslevel = 'Read'));
                }*/            
        }    
        
        if(SharingOppVPList.size() > 0 )
        {
            insert SharingOppVPList;
        }           
    }     
    
    public static map<String, list<Id>> fetchUserGroupOnlyRelatedToOIT(list<Opportunity_Internal_Team__c> OppInternalTeamMemberList) { 
        
        map<String, list<Id>> OpportunityWithRelatedTMDelegatedUserMap = new map<String, list<Id>>();
        map<Id, Set<Id>> userOpportunityMap = new map<Id, Set<Id>>();
        Set<id> matchingSet = new Set<id>();
        for(Opportunity_Internal_Team__c oit : OppInternalTeamMemberList)
        {
             if(!matchingSet.contains(oit.contact__r.user__c)){
                if(!OpportunityWithRelatedTMDelegatedUserMap.containskey(oit.Opportunity__c+'_TM'))
                    OpportunityWithRelatedTMDelegatedUserMap.put(oit.Opportunity__c+'_TM', new list<id>{oit.contact__r.user__c});
                else
                    OpportunityWithRelatedTMDelegatedUserMap.get(oit.Opportunity__c+'_TM').add(oit.contact__r.user__c);
                matchingSet.add(oit.contact__r.user__c);
            }
            if(!userOpportunityMap.containskey(oit.contact__r.user__c))
                userOpportunityMap.put(oit.contact__r.user__c, new set<id>{oit.Opportunity__c});
            else
                userOpportunityMap.get(oit.contact__r.user__c).add(oit.Opportunity__c);
            
        }
        
        map<Id, Set<Id>> UserWithDelegatedGroupIdMap = new map<Id, Set<Id>>();
            
        
        Set<id> relatedpublicGroupIdSet = new Set<Id>();
        if(userOpportunityMap.KeySet().size() > 0 )
        for(Delegate_Public_Group__c dpg : [SELECT Banker__c , Public_Group_ID__c, (select Delegate__c, Delegate_Public_Group__r.Banker__c  from Delegate_Public_Group_Members__r )
                                            FROM Delegate_Public_Group__c
                                            WHERE Banker__c IN : userOpportunityMap.KeySet()])
        {
            if(userOpportunityMap.containsKey(dpg.Banker__c))
                for(Id opportunityId : userOpportunityMap.get(dpg.Banker__c))
                {
                    if(!OpportunityWithRelatedTMDelegatedUserMap.containskey(opportunityId+'_DU'))
                        OpportunityWithRelatedTMDelegatedUserMap.put(opportunityId+'_DU',new list<id>{dpg.Public_Group_ID__c});             
                    else                    
                        OpportunityWithRelatedTMDelegatedUserMap.get(opportunityId+'_DU').add(dpg.Public_Group_ID__c);      
                }               
        }
        return OpportunityWithRelatedTMDelegatedUserMap;
    }
 
    public static void avoidChangesOnRollupFieldsOnVP(String eventType, List<Opp_VP__c> newOppVPList, Map<Id, Opp_VP__c> newOppVPMap, List<Opp_VP__c> oldOppVPList , Map<Id, Opp_VP__c> oldOppVPMap){        
        if(eventType == 'BeforeInsert'){
            for(Opp_VP__c newOppVPObj : newOppVPList) {  
               if(newOppVPObj.ResultingEngagemnetRTonVP__c != 'Portfolio_Valuation' )  
               {
                   newOppVPObj.addError(System.Label.HL_VP_Stop_Create_Edit_Delete);
               }        
               newOppVPObj.Fee_Total__c  = 0.0;                  
               newOppVPObj.Overall_VP_Status__c = 'New';       
            }
        }
        else if (eventType == 'BeforeUpdate'){
            List<Id> oppVPToProcess = new List <Id>();
            for(Opp_VP__c newOppVPObj : newOppVPList) {  
                if(newOppVPObj.ResultingEngagemnetRTonVP__c != 'Portfolio_Valuation' ){                
                     newOppVPObj.addError(System.Label.HL_VP_Stop_Create_Edit_Delete);
                }
                if(newOppVPObj.Name == '' || newOppVPObj.Name == null) {
                   newOppVPObj.addError(label.HL_Name_Required);                                      
                }     
                if((newOppVPObj.Fee_Total__c != oldOppVPMap.get(newOppVPObj.id).Fee_Total__c)||(newOppVPObj.Overall_VP_Status__c != oldOppVPMap.get(newOppVPObj.id).Overall_VP_Status__c )){
                    OppVPToProcess.add(newOppVPObj.Id);   
                }  
            }
            Map<String, String>strMap = new Map<String, String>();        
            for(Opp_VP__c  oppObj : [SELECT id, Fee_Total__c, Overall_VP_Status__c, (select id, Report_Fee__c, Status__c from Opp_VP_Positions__r) 
                             FROM Opp_VP__c 
                             WHERE ID IN : oppVPToProcess]){
                if(oppObj.Opp_VP_Positions__r.size() == 0) {
                    newOppVPMap.get(oppObj.id).Fee_Total__c = 0.0;  
                    newOppVPMap.get(oppObj.id).Overall_VP_Status__c = 'New';             
                }
                else {
                    decimal tempTotal = 0.0;
                    String tempStatus = 'Completed';
                    for(Opp_VP_Position__c oppVpPos : oppObj.Opp_VP_Positions__r) {  
                        if(oppVpPos!= null){
                            tempTotal += (oppVpPos.Report_Fee__c != null ?oppVpPos.Report_Fee__c : 0);  
                        }  
                        if (oppVpPos!= null && (oppVpPos.Status__c != 'Completed'))
                        {
                            tempStatus = 'In Progress';
                        }
                    }    
                    newOppVPMap.get(oppObj.id).Fee_Total__c = tempTotal;  
                    newOppVPMap.get(oppObj.id).Overall_VP_Status__c = tempStatus ;                                   
                }  
            } 
        }         
        if(eventType == 'BeforeDelete'){ 
            for(Opp_VP__c newOppVPObj : oldOppVPList) {  
               if(newOppVPObj.ResultingEngagemnetRTonVP__c != null && newOppVPObj.ResultingEngagemnetRTonVP__c != 'Portfolio_Valuation')  
               {
                   newOppVPObj.addError(System.Label.HL_VP_Stop_Create_Edit_Delete);
               } 
            }
       }          
    }
}