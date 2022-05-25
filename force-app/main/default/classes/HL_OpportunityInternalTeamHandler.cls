/*
* Name: HL_OpportunityInternalTeamHandler
* Created Date: 3/3/2015
* Description: Apex Handler class for Opportunity_Internal_Team__c object
* Modified Date: 12/03/2019
* Description:  Added the following methods for ERP Integration:
*   a) updateErpPrincipalManager()
*/

public with sharing class HL_OpportunityInternalTeamHandler {
    /* Start - Variable */
    private boolean m_isExecuting = false;
    private static boolean skipAfterUpdateExecution = false;
    private integer BatchSize = 0;
    /* End - Variable */

    /* Start - Constructor */
    public HL_OpportunityInternalTeamHandler(boolean isExecuting, integer size) 
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    /* End - Constructor */

    /*
        @MethodName         : onBeforeInsert
        @param              : List of Opportunity_Internal_Team__c
        @Ticket             : PRJ0016533 - Office Revenue Allocation on Engagement Internal Team
        @Description        : This function will be called on Before insert to populate 'Revenue Allocation' from Contact
    */
    public void onBeforeInsert(List<Opportunity_Internal_Team__c> newOITList) {
        OpportunityTeamCreationPB(newOITList);
        UpdateRevenueAllocationOnOIT(newOITList);                                                                                                           
    }
    /* End */
    
    /*
        @MethodName         : onAfterInsert
        @param              : List of Opportunity_Internal_Team__c
        @Description        : This function will be called on after insert of the Opportunity_Internal_Team__c records
    */
    public void onAfterInsert(List<Opportunity_Internal_Team__c> oitList)
    {
        UpdateEngagementTeamAssembled(oitList);
        UpdateInternalTeamAggregate(oitList);
        SL_ManageSharingRules.manageSharingRules(oitList, 'Opportunity__c', 'Opportunity_Internal_Team__c', 'insert'); 
        setupSharingforInsertedOITforRelatedOpportunity(oitList);           
        UpdateRevenueAllocationOnSiblingOIT(oitList);
        UpdateErpPrincipalManager(oitList);
        updateCoExistCheckbox(oitList);
    }
    /* End */
    
    
    public static void OpportunityTeamCreationPB(List<Opportunity_Internal_Team__c> eitList){
        List<Id> ContactRec = new List<Id>();
        for(Opportunity_Internal_Team__c inx : eitList){
            if(inx.Contact__c!=null){
                ContactRec.add(inx.Contact__c);
            }
        }
        Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id, Department, Line_of_Business__c, Legal_Entity__c, Office__c FROM Contact where id in:ContactRec]);
        for(Opportunity_Internal_Team__c inx : eitList){
            if(inx.Contact__c!=null && contactMap.containsKey(inx.Contact__c)){
                inx.Department__c = contactMap.get(inx.Contact__c).Department;
                inx.LOB__c = contactMap.get(inx.Contact__c).Line_of_Business__c;
                inx.Office__c = contactMap.get(inx.Contact__c).Office__c;
            }
        }
    }
       /*
        @MethodName         : updateCoExistCheckbox
        @param              : List of Opportunity_Internal_Team__c
        @Description        : This function will be called on after insert and after update of the Opportunity_Internal_Team__c records
    */
    public static void updateCoExistCheckbox(List<Opportunity_Internal_Team__c> oitList){
        Set<Id> contactId =   new Set<Id>();
        Set<Id> oppId =   new Set<Id>();
        for(Opportunity_Internal_Team__c inx :oitList){
            contactId.add(inx.contact__c);
            oppId.add(inx.Opportunity__c);
        }
        system.debug('oitList'+oitList);
        list<Opportunity_Internal_Team__c> internalTeam = new List<Opportunity_Internal_Team__c>([Select id,contact__r.Acquired_From__c  from Opportunity_Internal_Team__c 
                                                                                                  where opportunity__c in:oppID and Active_on_opp__c = true]);
        system.debug('internalTeam'+internalTeam);
        Map<Id,Opportunity__c> oppData = new Map<Id,Opportunity__c>([Select id,(Select id,contact__c,contact__r.Acquired_From__c from Opportunity_Internal_Teams__r where  Active_on_opp__c = true) from  Opportunity__c  where id in:oppId]);
        Map<Id,Set<Id>> mapOfContactandOpp = new Map<Id,Set<id>>();Set<Id> allContacts = new Set<Id>();
        for(Opportunity__c ind :oppData.values()){
            Set<Id> contacts = new Set<Id>();
            for(Opportunity_Internal_Team__c inx :ind.Opportunity_Internal_Teams__r){
                contacts.add(inx.contact__c); allContacts.add(inx.Contact__c);
            }
            mapOfContactandOpp.put(ind.Id,contacts);      
        } 
        Map<Id,Contact> contactdata = new Map<Id,Contact>([Select id,Acquired_From__c from Contact where id in :allContacts]);
        Map<Id,boolean> oppCheckbox = new Map<Id,Boolean>();
        for(Id inx: mapOfContactandOpp.keySet()){
            Integer counter = 0;
            Integer totalContacts = mapOfContactandOpp.get(inx).size();
            for(Id ind : mapOfContactandOpp.get(inx)){
                Contact rec = contactdata.get(ind);
                if(rec.Acquired_From__c!=null&&rec.Acquired_From__c.equalsIgnoreCase('GCA')){
                    counter++;
                }
            }
            if(totalContacts == 0){oppCheckbox.put(inx,false);}
            else if(counter == 0){oppCheckbox.put(inx,false);}
            else if(totalContacts==counter){oppCheckbox.put(inx,false);}
            else if(totalContacts>counter){oppCheckbox.put(inx,true);}
        }
        
        list<Opportunity__c> oppRecords = new List<Opportunity__c>();
         for(Id inx :oppId){
             if(oppCheckbox.containsKey(inx)){
                 Opportunity__c newRec = new  Opportunity__c();
                 newRec.Id = inx;
                 newRec.Co_exist__c  = oppCheckbox.get(inx);
                 oppRecords.add(newRec);
             }
         }
        if(!oppRecords.isEmpty()){ update oppRecords;}   
    }
    

    
    /*
        @MethodName         : onAfterUpdate
        @param              : Old and new map of Opportunity_Internal_Team__c
        @Description        : This function will be called on after update of the Opportunity_Internal_Team__c records
    */
    public void onAfterUpdate(Map<Id, Opportunity_Internal_Team__c> mapOldOIT, Map<Id, Opportunity_Internal_Team__c> mapNewOIT, List<Opportunity_Internal_Team__c> oitList)
    {   
        if(!skipAfterUpdateExecution){
        UpdateEngagementTeamAssembled(oitList);
        UpdateInternalTeamAggregate(oitList);
        SL_ManageSharingRules.createDeleteShareOnUpdate(mapOldOIT, mapNewOIT, 'Opportunity__c', 'Opportunity_Internal_Team__c');
        if(HL_ConstantsUtil.IsSupervisorOrAdmin()) {
            UpdateOppVPPositionTeamMembers(oitList, mapOldOIT);
        }
        setupSharingforUpdatedOITforRelatedOpportunity(oitList, mapOldOIT);
        updateErpPrincipalManager(oitList);
            updateCoExistCheckbox(oitList);
        skipAfterUpdateExecution = true;  // setting flag to true 
    }
    }
    /* End */
    
    /*
        @MethodName         : onAfterDelete
        @param              : map of Opportunity_Internal_Team__c
        @Description        : This function will be called on after delete of the Opportunity_Internal_Team__c records
                              to delete the Opportunity share records related to Opportunity_Internal_Team__c   
    */
    public void onAfterDelete(Map<Id, Opportunity_Internal_Team__c> mapOITOld, List<Opportunity_Internal_Team__c> oitList)
    {
        UpdateEngagementTeamAssembled(oitList);
        UpdateInternalTeamAggregate(oitList);
        SL_ManageSharingRules.manageSharingRules(mapOITOld.values(), 'Opportunity__c', 'Opportunity_Internal_Team__c', 'delete');
    }
    /* End */

    public static void UpdateEngagementTeamAssembled(List<Opportunity_Internal_Team__c> oitList){
        //Create Set of Opportunity Ids
        Set<Id> opps = new Set<Id>();
        List<String> engagementTeamRoles = new List<String> {'Principal','Seller','Manager','Initiator'};
        for(Opportunity_Internal_Team__c oit : oitList)
            opps.add(oit.Opportunity__c);
        
        //Get opportunities that may need to be updated
        List<Opportunity__c> possibleOpps = [SELECT Id, Engagement_Team_Assembled__c FROM Opportunity__c WHERE Id IN : opps];
        List<Opportunity_Internal_Team__c> existingEngagementRoles = [SELECT Opportunity__c, Staff_Role__r.Name FROM Opportunity_Internal_Team__c WHERE Opportunity__c IN : opps AND Staff_Role__r.Name IN : engagementTeamRoles AND (End_Date__c = null OR End_Date__c > : date.today())];
        //Create a Map of existing roles to validate against
        Map<String, Id> er = new Map<String,Id>();
        for(Opportunity_Internal_Team__c oit:existingEngagementRoles){
            if(er.get(oit.Opportunity__c + ':' + oit.Staff_Role__r.Name) == null)
                er.put(oit.Opportunity__c + ':' + oit.Staff_Role__r.Name, oit.Opportunity__c);
        }
        
        //Find which opps we need to update and then update
        List<Opportunity__c> oppsToUpdate = new List<Opportunity__c>();
        
        for(Opportunity__c opp : possibleOpps)
        {
            integer roleCount = 0;
            for(String r : engagementTeamRoles)
            {
                if(er.get(opp.Id + ':' + r) <> null)
                    roleCount++;
            }
            
            //Determine if opp needs to be updated
            if((opp.Engagement_Team_Assembled__c && roleCount <> engagementTeamRoles.size()) || (!opp.Engagement_Team_Assembled__c && roleCount >= engagementTeamRoles.size()))
            {
                 opp.Engagement_Team_Assembled__c = !opp.Engagement_Team_Assembled__c;
                 oppsToUpdate.add(opp);
            }
               
        }
        
        if(oppsToUpdate.size() > 0)
            update oppsToUpdate;

    }
    
    public static void UpdateInternalTeamAggregate(List<Opportunity_Internal_Team__c> oitList){
        //Oppt To Update
        List<Opportunity__c> oToUpdate = new List<Opportunity__c>();
        //Create Set of Opportunity Ids
        Set<Id> opps = new Set<Id>();
        for(Opportunity_Internal_Team__c oit : oitList)
            opps.add(oit.Opportunity__c);
        //Create a map of opportunity|role with team member ids
        Map<String,Set<String>> oppTeamMap = new Map<String,Set<String>>();
        for(Opportunity_Internal_Team__c o : [SELECT Opportunity__c, Contact__r.User__c, Staff_Role__r.Name FROM Opportunity_Internal_Team__c WHERE Opportunity__c IN : opps AND End_Date__c = null]){
                String key = o.Opportunity__c + '_' + o.Staff_Role__r.Name;
                if(oppTeamMap.get(key) == null)
                    oppTeamMap.put(key, new Set<String>{o.Contact__r.User__c});
                else
                {
                    Set<String> existingIds = (Set<String>)oppTeamMap.get(key);
                    existingIds.add(o.Contact__r.User__c);
                    oppTeamMap.put(o.Opportunity__c, existingIds);
                }
        }
        
        
        //Get opportunities that may need to be updated
        for(Opportunity__c o : [SELECT Id FROM Opportunity__c WHERE Id IN : opps])
        {
                o.z_Admin_Intern_Aggregate__c = PopulateAggregateField(o.Id + '_Intern', oppTeamMap);
                o.z_Analyst_Aggregate__c = PopulateAggregateField(o.Id + '_Analyst', oppTeamMap);
                if(o.z_Analyst_Aggregate__c.Length() > 255){
                        o.z_Analyst_Aggregate2__c = o.z_Analyst_Aggregate__c.subString(247);
                    if(o.z_Analyst_Aggregate2__c.Length() > 255){
                        o.z_Analyst_Aggregate3__c = o.z_Analyst_Aggregate2__c.subString(247);
                        o.z_Analyst_Aggregate2__c = o.z_Analyst_Aggregate__c.subString(0,246);
                        }
                    o.z_Analyst_Aggregate__c = o.z_Analyst_Aggregate__c.subString(0,246);
                }
                o.z_Associate_Aggregate__c = PopulateAggregateField(o.Id + '_Associate', oppTeamMap);
                if(o.z_Associate_Aggregate__c.Length() > 255){
                        o.z_Associate_Aggregate2__c = o.z_Associate_Aggregate__c.subString(247);
                    if(o.z_Associate_Aggregate2__c.Length() > 255){
                        o.z_Associate_Aggregate3__c = o.z_Associate_Aggregate2__c.subString(247);
                        o.z_Associate_Aggregate2__c = o.z_Associate_Aggregate__c.subString(0,246);
                        }
                        o.z_Associate_Aggregate__c = o.z_Associate_Aggregate__c.subString(0,246);
                }
                o.z_Final_Rev_Aggregate__c = PopulateAggregateField(o.Id + '_Final Reviewer', oppTeamMap);
                o.z_Initiator_Aggregate__c= PopulateAggregateField(o.Id + '_Initiator', oppTeamMap);
                if(o.z_Initiator_Aggregate__c.Length() > 255){
                    o.z_Initiator_Aggregate2__c = o.z_Initiator_Aggregate__c.subString(247);
                    o.z_Initiator_Aggregate__c = o.z_Initiator_Aggregate__c.subString(0,246);
                }
                o.z_Manager_Aggregate__c = PopulateAggregateField(o.Id + '_Manager', oppTeamMap);
                o.z_Marketing_Aggregate__c = PopulateAggregateField(o.Id + '_Marketing Team', oppTeamMap);
                if(o.z_Marketing_Aggregate__c.Length() > 255){
                    o.z_Marketing_Aggregate2__c = o.z_Marketing_Aggregate__c.subString(247);
                    if(o.z_Marketing_Aggregate2__c.Length() > 255){
                        o.z_Marketing_Aggregate3__c = o.z_Marketing_Aggregate2__c.subString(247);
                        o.z_Marketing_Aggregate2__c = o.z_Marketing_Aggregate2__c.subString(0,246);
                    }
                    o.z_Marketing_Aggregate__c = o.z_Marketing_Aggregate__c.subString(0,246);
                }
                o.z_NonRegistered_Aggregate__c = PopulateAggregateField(o.Id + '_Non-Registered', oppTeamMap);
                o.z_PE_HF_Aggregate__c = PopulateAggregateField(o.Id + '_PE/Hedge Fund', oppTeamMap);
                o.z_Prelim_Rev_Aggregate__c = PopulateAggregateField(o.Id + '_Prelim Reviewer', oppTeamMap);
                o.z_Pricing_Aggregate__c = PopulateAggregateField(o.Id + '_Pricing Committee Approver', oppTeamMap);
                o.z_Principal_Aggregate__c = PopulateAggregateField(o.Id + '_Principal', oppTeamMap);
                o.z_Public_Aggregate__c = PopulateAggregateField(o.Id + '_Public Person', oppTeamMap);
                o.z_Reviewer_Aggregate__c = PopulateAggregateField(o.Id + '_Reviewer', oppTeamMap);
                o.z_Seller_Aggregate__c = PopulateAggregateField(o.Id + '_Seller', oppTeamMap);
                o.z_Specialty_Aggregate__c = PopulateAggregateField(o.Id + '_Ind/Prod/Geog Person', oppTeamMap);
                oToUpdate.add(o);
        }
        if(oToUpdate.size() > 0)
            update oToUpdate;
    }

    private static String PopulateAggregateField(String mapKey, Map<String,Set<String>> teamMap){
        String fieldValue = '';
        if(teamMap.get(mapKey) <> null){
            for(String id : (Set<String>)teamMap.get(mapKey)){
                if(id <> null)
                    fieldValue = String.isBlank(fieldValue) ? id : (fieldValue.contains(id) ? fieldValue : fieldValue + '|' + id);
            }
        }
        else
            fieldValue = '';
        
        return fieldValue;
    }
    
    private static void UpdateOppVPPositionTeamMembers(List<Opportunity_Internal_Team__c> processedInternTeamMemberList , Map<Id,Opportunity_Internal_Team__c> processedInternTeamMemberMap){
        
        Set<Opp_VP_TeamMember__c> oppVPPosTeamMemberList = new Set<Opp_VP_TeamMember__c>();
        List<Opp_VP_TeamMember__c> oppVPPosTeamMemberToDeleteList = new List<Opp_VP_TeamMember__c>();
        
        Set<Id> relatedOpportunityIdSet = new Set<Id>();
        Set<Id> relatedContactIdSet = new Set<Id>();
        Map<Id, date> contactWithRecentEndDateMap = new Map<Id, date>(); 
        for(Opportunity_Internal_Team__c processedInternTeamMember : processedInternTeamMemberList) {
            if(processedInternTeamMember.End_Date__c != null && processedInternTeamMember.End_Date__c != processedInternTeamMemberMap.get(processedInternTeamMember.Id).End_Date__c)
                relatedOpportunityIdSet.add(processedInternTeamMember.Opportunity__c);  
                relatedContactIdSet.add(processedInternTeamMember.Contact__c);
        }
        
        Set<Id> ContactsToExclude = new Set<Id>();
        // we will exlucde only that contact which has at least one opportunity team member record with blank end date ( it means opp team memeber still is in the list under opportunity) 
        for(Contact cont : [SELECT Id, (SELECT Id,End_Date__c FROM Opportunity_Teams__r WHERE End_Date__c = null AND Opportunity__c In : relatedOpportunityIdSet) 
                            FROM Contact 
                            WHERE Id In : relatedContactIdSet]) {
            If(cont.Opportunity_Teams__r.size() > 0)
                ContactsToExclude.add(cont.Id);
        }               
        // Purpose of excluding such contact is to avoid end date populating on Opp VP Team member record where opp Team member still under opportunity.  
        relatedContactIdSet.removeAll(ContactsToExclude);       
        
        // To calculate most recent end date to be populated in to Opp VP Team member
        AggregateResult[] groupedResults = [SELECT Contact__c contactId, MAX(End_Date__c) recentEndDate  
                                            FROM Opportunity_Internal_Team__c 
                                            WHERE End_Date__c != null AND Opportunity__c IN : relatedOpportunityIdSet AND Contact__c IN : relatedContactIdSet GROUP BY Contact__c ];
        for (AggregateResult ar : groupedResults) {
            contactWithRecentEndDateMap.put(String.valueof(ar.get('contactId')), Date.valueof(ar.get('recentEndDate')));
        }
        
        for(Opp_VP_TeamMember__c oppVPTM : [SELECT Id, Start_date__c, End_Date__c, Staff__c 
                                            FROM Opp_VP_TeamMember__c 
                                            WHERE Opportunity_VP_Position__r.Status__c != 'Cancelled' 
                                            AND Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__r.Converted_to_Engagement__c = false  
                                            AND (Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__r.Approval_Process__c != :label.HL_AppProcessForEngNo  OR ( Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__r.Approval_Process__c = :label.HL_AppProcessForEngNo AND Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__r.Engagement_Approval_Status__c != :label.HL_Pending_EngReqNo  ))     
                                            AND ResultingEngagemnetRTonVPTM__c = 'Portfolio_Valuation'                                                               
                                            AND Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__c IN : relatedOpportunityIdSet AND Staff__c IN : relatedContactIdSet ]) {
            
            if(oppVPTM.End_Date__c == null || oppVPTM.End_Date__c >= contactWithRecentEndDateMap.get(oppVPTM.Staff__c)) 
                oppVPTM.End_Date__c = contactWithRecentEndDateMap.get(oppVPTM.Staff__c);
            if(contactWithRecentEndDateMap.get(oppVPTM.Staff__c) != null) {
                if(oppVPTM.Start_date__c != null && oppVPTM.Start_date__c > oppVPTM.End_Date__c ) {
                    oppVPPosTeamMemberToDeleteList.add(oppVPTM);
                }
                else {
                    oppVPTM.End_Date__c = contactWithRecentEndDateMap.get(oppVPTM.Staff__c);
                    oppVPTM.Is_Team_Member_Deactivated_Once__c = true;
                    oppVPPosTeamMemberList.add(oppVPTM);                    
                }
            }
            
        }
        
        if(oppVPPosTeamMemberToDeleteList.size() > 0){            
            delete oppVPPosTeamMemberToDeleteList;    
        }    
        if(oppVPPosTeamMemberList.size() > 0){
            Set<Opp_VP_TeamMember__c> setofRecordsToBeRemoved = new Set<Opp_VP_TeamMember__c>();
            setofRecordsToBeRemoved = HL_ContactHandler.removeDuplicateOppVpTMRecrds(oppVPPosTeamMemberList);             
            oppVPPosTeamMemberList.removeAll(setofRecordsToBeRemoved);              
            List<Opp_VP_TeamMember__c> ListOfVPTMs = new List<Opp_VP_TeamMember__c>();
            ListOfVPTMs.addAll(oppVPPosTeamMemberList);            
            update ListOfVPTMs;     
        }
    }
    
    private static list<Opp_VP__c> OppVPList;
    
    private static void setupSharingforUpdatedOITforRelatedOpportunity(list<Opportunity_Internal_Team__c> oitList, map<Id, Opportunity_Internal_Team__c> mapOldOIT) {
        
        list<Opportunity_Internal_Team__c> ValidOITList = new list<Opportunity_Internal_Team__c>();
        Set<Id> RelatedOpportunityIdSet = new Set<Id>();
        Set<String> OppContactCombinationSetforsiblingOITs = new Set<String>();
        list<Opportunity_Internal_Team__c> SiblingOITs = new list<Opportunity_Internal_Team__c>();
        for(Opportunity_Internal_Team__c oit : [SELECT Id, Contact__r.User__c, End_Date__c, Opportunity__c  
                                                FROM Opportunity_Internal_Team__c
                                                WHERE Id IN :oitList ])
        { 
            if(oit.End_Date__c != Null && oit.End_Date__c != mapOldOIT.get(oit.id).End_Date__c)
            {
                ValidOITList.add(oit);              
                RelatedOpportunityIdSet.add(oit.Opportunity__c);
            }
        }
        
        for(Opportunity_Internal_Team__c siblingOIT : [SELECT Id , Opportunity__c, Contact__c, contact__r.user__c
                                                      FROM Opportunity_Internal_Team__c
                                                      WHERE End_Date__c = NULL AND Opportunity__c IN :RelatedOpportunityIdSet ])
        {
            OppContactCombinationSetforsiblingOITs.add(siblingOIT.Opportunity__c+'_'+siblingOIT.Contact__c);
            SiblingOITs.add(siblingOIT);
        } 
        
        list<Opportunity_Internal_Team__c> filtered_Level1_OITList = new list<Opportunity_Internal_Team__c>();
        Set<Opportunity_Internal_Team__c> filtered_Level2_OITList = new Set<Opportunity_Internal_Team__c>();
        for(Opportunity_Internal_Team__c  validOIT : ValidOITList){ 
            if(!OppContactCombinationSetforsiblingOITs.contains(validOIT.Opportunity__c+'_'+validOIT.Contact__c))
                filtered_Level1_OITList.add(validOIT);
            else 
                SiblingOITs.add(validOIT);
        }
        
        map<String, list<Id>> OpportunityWithRelatedTMDelegatedUserMap = new map<String, list<Id>>();
        map<String, list<Id>> OpportunityWithRelatedTMDelegatedToValidUserMap = new map<String, list<Id>>();
        
        if(filtered_Level1_OITList.size() > 0)
            OpportunityWithRelatedTMDelegatedToValidUserMap = HL_Opp_VP_TriggerHelper.fetchUserGroupOnlyRelatedToOIT(filtered_Level1_OITList);     
        
        if(SiblingOITs.size() > 0)
            OpportunityWithRelatedTMDelegatedUserMap = HL_Opp_VP_TriggerHelper.fetchUserGroupOnlyRelatedToOIT(SiblingOITs);
            
            
        Set<Id> tempSet = new Set<Id>();
        Boolean isfound = false;
        Set<Id> StopDeletionSharing = new Set<Id>();
        for(Opportunity_Internal_Team__c filtered_OIT : filtered_Level1_OITList)
        {
            isfound = false;
            if(OpportunityWithRelatedTMDelegatedUserMap.containsKey(filtered_OIT.Opportunity__c +'_TM')) 
            {
                tempSet = new Set<Id>();
                tempSet.addAll(OpportunityWithRelatedTMDelegatedUserMap.get(filtered_OIT.Opportunity__c +'_TM'));
                if(tempSet.contains(filtered_OIT.Contact__r.User__c))
                    isfound = true;                 
            }            
            if(OpportunityWithRelatedTMDelegatedUserMap.containsKey(filtered_OIT.Opportunity__c +'_DU'))                
            {
                tempSet = new Set<Id>();
                tempSet.addAll(OpportunityWithRelatedTMDelegatedUserMap.get(filtered_OIT.Opportunity__c +'_DU'));
                if(tempSet.contains(filtered_OIT.Contact__r.User__c))
                    isfound = true;
                if(OpportunityWithRelatedTMDelegatedToValidUserMap.containsKey(filtered_OIT.Opportunity__c +'_DU')) 
                {
                    for(Id UorGpId : OpportunityWithRelatedTMDelegatedToValidUserMap.get(filtered_OIT.Opportunity__c +'_DU')) {
                        if(tempSet.contains(UorGpId))
                        {
                            StopDeletionSharing.add(UorGpId);
                        }
                    }
                    
                }
            }            
            if(!isfound)
                filtered_Level2_OITList.add(filtered_OIT);
        }
        
        Set<Id> finalUserIdSetToRemoveSharing = new Set<Id>();
        
        for(Opportunity_Internal_Team__c filtered_OIT2 : filtered_Level2_OITList)
        {
            finalUserIdSetToRemoveSharing.add(filtered_OIT2.Contact__r.User__c);
        }
        
        fetchingVPFamily(RelatedOpportunityIdSet);

        list<Opp_VP__Share> listSharedVpToBeDelete = new list<Opp_VP__Share>();
            listSharedVpToBeDelete = [Select Id from Opp_VP__Share Where ParentId =: OppVPList AND UserOrGroupId IN: finalUserIdSetToRemoveSharing AND UserOrGroupId NOT IN : StopDeletionSharing];
            
        if(listSharedVpToBeDelete.size() >0 )   
            delete listSharedVpToBeDelete;
        
    }    
   
    private static void setupSharingforInsertedOITforRelatedOpportunity(list<Opportunity_Internal_Team__c> oitList) {
        
        map<String, list<Id>> OpportunityWithRelatedTMDelegatedUserMap = new map<String, list<Id>>();       
        list<Opportunity_Internal_Team__c> OppInternalTeamMemberList = new list<Opportunity_Internal_Team__c>();
        Set<Id> reltedOpportunityIdSet = new Set<Id>();
        for(Opportunity_Internal_Team__c OppInternalTeamMember : [SELECT contact__r.user__c, Opportunity__c 
                                                                  FROM Opportunity_Internal_Team__c 
                                                                  WHERE End_Date__c = NULL AND Id IN : oitList])
        {
            OppInternalTeamMemberList.add(OppInternalTeamMember);
            reltedOpportunityIdSet.add(OppInternalTeamMember.Opportunity__c);
                                                                            
        }
            
        OpportunityWithRelatedTMDelegatedUserMap = HL_Opp_VP_TriggerHelper.fetchUserGroupOnlyRelatedToOIT(OppInternalTeamMemberList);
        
        fetchingVPFamily(reltedOpportunityIdSet);
       
        HL_Opp_VP_TriggerHelper.SetupSharingCoreLogicForOppVP(OppVPList, OpportunityWithRelatedTMDelegatedUserMap);
        
    }
    
    public static void fetchingVPFamily(set<Id> reltedOpportunityIdSet) {
        OppVPList = new list<Opp_VP__c>();
        
        for(Opp_VP__c OppVP : [SELECT Id, Opportunity__c,ownerId 
                               FROM Opp_VP__c
                               WHERE Opportunity__c IN : reltedOpportunityIdSet])
        {
            OppVPList.add(OppVP);
        }
    } 
    
    /*  @MethodName         : UpdateRevenueAllocationOnSiblingOIT
        @Ticket             : PRJ0016533 - Office Revenue Allocation on Engagement Internal Team
        @Description        : To populate 'Revenue Allocation' on all sibling Internal Team records */  
    public static void UpdateRevenueAllocationOnSiblingOIT(List<Opportunity_Internal_Team__c> newOITList){
        
        Map<Id,String> RevenueAllocationOfficeMap = new Map<Id,String>();
        Set <Id> setOfOITContact = new Set <Id>();
        Set <Id> setOfOITopportunity = new Set <Id>();
        Set <Id> setOfInsertedOIT = new Set <Id>();
        List<Opportunity_Internal_Team__c> OITtoUpdate = new List<Opportunity_Internal_Team__c>();

        for(Opportunity_Internal_Team__c AllOIT : newOITList){
            if(AllOIT.Contact__c != null){
                setOfOITopportunity.add(AllOIT.Opportunity__c);
                setOfOITContact.add(AllOIT.Contact__c);
                setOfInsertedOIT.add(AllOIT.Id);
                if(!RevenueAllocationOfficeMap.containsKey(AllOIT.Contact__c)){
                    RevenueAllocationOfficeMap.put(AllOIT.Contact__c,AllOIT.Revenue_Allocation__c);
                }
            }
        }

        // To find sibling OIT and updating with latest Revenue Allocation
        if(RevenueAllocationOfficeMap.size () > 0){
            for(Opportunity_Internal_Team__c siblingOIT : [SELECT Id, Revenue_Allocation__c,Contact__c FROM Opportunity_Internal_Team__c WHERE Id NOT IN :setOfInsertedOIT AND Opportunity__c IN : setOfOITopportunity AND Contact__c IN :setOfOITContact AND End_Date__c = null]){
                if(RevenueAllocationOfficeMap.containsKey(siblingOIT.Contact__c)){
                    siblingOIT.Revenue_Allocation__c = RevenueAllocationOfficeMap.get(siblingOIT.Contact__c);
                    OITtoUpdate.add(siblingOIT);
                }
            }
        }
        
        if(OITtoUpdate.size() > 0){
            update OITtoUpdate;
        }
    }
    
    public static void UpdateRevenueAllocationOnOIT(List<Opportunity_Internal_Team__c> newOITList){
        
        Map<Id,String> RevenueAllocationOfficeMap = new Map<Id,String>();
        Map<String,String> ExistingRevAllocationMap = new Map<String,String>();
        Set <Id> setOfOITContact = new Set <Id>();
        Set <Id> setOfExistingOITOpportunity = new Set <Id>();

        for(Opportunity_Internal_Team__c AllOIT : newOITList){
            if(AllOIT.Contact__c != null){
                setOfOITContact.add(AllOIT.Contact__c);
                setOfExistingOITOpportunity.add(AllOIT.Opportunity__c);
            }
        }
        
        for(Opportunity_Internal_Team__c existingOIT : [SELECT Id, Revenue_Allocation__c,Contact__c,Opportunity__c  FROM Opportunity_Internal_Team__c WHERE Opportunity__c IN : setOfExistingOITOpportunity AND Contact__c IN :setOfOITContact AND End_Date__c = null] ){
            if(!ExistingRevAllocationMap.containsKey(existingOIT.Opportunity__c+'-'+existingOIT.Contact__c) && existingOIT.Revenue_Allocation__c != null){
                ExistingRevAllocationMap.put(existingOIT.Opportunity__c+'-'+existingOIT.Contact__c,existingOIT.Revenue_Allocation__c);
            }
        }

        if(setOfOITContact.size() > 0){         
            for(Contact con : [SELECT id,Office__c,Revenue_Allocation__c FROM Contact WHERE Id IN : setOfOITContact AND (Office__c != null OR Revenue_Allocation__c != null)]){ 
                if(!RevenueAllocationOfficeMap.containsKey(con.Id)){
                    if(con.Revenue_Allocation__c != null){
                        RevenueAllocationOfficeMap.put(con.Id,con.Revenue_Allocation__c);
                    } else {
                        RevenueAllocationOfficeMap.put(con.Id,con.Office__c);
                    }
                }
            }
        }

        for(Opportunity_Internal_Team__c OIT : newOITList){
            if(ExistingRevAllocationMap.containsKey(OIT.Opportunity__c+'-'+OIT.Contact__c)){
                OIT.Revenue_Allocation__c = ExistingRevAllocationMap.get(OIT.Opportunity__c+'-'+OIT.Contact__c);
            }else if(RevenueAllocationOfficeMap.containsKey(OIT.Contact__c)){
                OIT.Revenue_Allocation__c = RevenueAllocationOfficeMap.get(OIT.Contact__c);
            }
        }
        
    }
    public static void updateErpPrincipalManager(List<Opportunity_Internal_Team__c> oitList){
        
      List<Opportunity_Internal_Team__c> oppInterTeam = [SELECT Contact__r.Email,Opportunity__c,Staff_Role__r.Name, Opportunity__r.ERP_Principal_Manager__c  from Opportunity_Internal_Team__c where Id IN : oitList];
      List<Opportunity__c> oppList = new  List<Opportunity__c>();
        
        for(Opportunity_Internal_Team__c oit : oppInterTeam){  
             
          if( oit.Staff_Role__r.Name == 'Initiator') {
                Opportunity__c opp = new Opportunity__c();           
                opp.Id = oit.Opportunity__c;            
            if(String.isBlank(oit.Opportunity__r.ERP_Principal_Manager__c)){
                opp.ERP_Principal_Manager__c = oit.Contact__r.Email;
                }
                
                oppList.add(opp);
            }
      }
        map<id,Opportunity__c> oppmap = new map<id,Opportunity__c>();

            //put all the values from the list to map. 
            oppmap.putall(oppList);
        if(oppList.size()>0)
            update oppmap.values();
            
    }
    
}