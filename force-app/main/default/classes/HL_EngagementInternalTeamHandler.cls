public class HL_EngagementInternalTeamHandler {
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public boolean IsTriggerContext{get{ return isExecuting;}}
    public static Boolean isAfterInsertFlag = false;
    public static Boolean isAfterUpdateFlag = false;
    public static Boolean isAfterDeleteFlag = false;
    
    public HL_EngagementInternalTeamHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;   
    }
    
    /*
        @MethodName         : onBeforeInsert
        @param              : List of Engagement_Internal_Team__c
        @Ticket             : PRJ0016533 - Office Revenue Allocation on Engagement Internal Team
        @Description        : This function will be called on Before insert to populate 'Revenue Allocation' from Contact
    */
    public void onBeforeInsert(List<Engagement_Internal_Team__c> newEITList) {
        
        
        EngagementTeamCreationPB(newEITList);
        UpdateRevenueAllocationOnEIT(newEITList);                                                                                                           
    }
    /* End */
    
    /*
        @MethodName         : OnAfterInsert
        @param              : List of Engagement_Internal_Team__c
        @Description        : This function will be called on after insert of the Engagement_Internal_Team__c records 
    */
     public void OnAfterInsert(List<Engagement_Internal_Team__c> eitList){
        if(!isAfterInsertFlag){           
            isAfterInsertFlag = true;
            UpdateInternalTeamAggregate(eitList);
            SL_ManageSharingRules.manageSharingRules(eitList, 'Engagement__c', 'Engagement_Internal_Team__c', 'insert');
            if(!HL_ConstantsUtil.stopExecutionForPVConversion)
                setupSharingforInsertedOITforRelatedEngagement(eitList);
            UpdateRevenueAllocationOnSiblingEIT(eitList);
            updateCoExistCheckbox(eitList);
        }
    }
    
    public static void EngagementTeamCreationPB(List<Engagement_Internal_Team__c> eitList){
        List<Id> ContactRec = new List<Id>();
        for(Engagement_Internal_Team__c inx : eitList){
            if(inx.Contact__c!=null){
                ContactRec.add(inx.Contact__c);
            }
        }
        Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id, Department, Line_of_Business__c, Legal_Entity__c, Office__c FROM Contact where id in:ContactRec]);
        for(Engagement_Internal_Team__c inx : eitList){
            if(inx.Contact__c!=null && contactMap.containsKey(inx.Contact__c)){
                inx.Department__c = contactMap.get(inx.Contact__c).Department;
                inx.LOB__c = contactMap.get(inx.Contact__c).Line_of_Business__c;
                inx.Legal_Entity__c = contactMap.get(inx.Contact__c).Legal_Entity__c;
                inx.Office__c = contactMap.get(inx.Contact__c).Office__c;
            }
        }
    }
    
    public static void updateCoExistCheckbox(List<Engagement_Internal_Team__c > oitList){
        Set<Id> contactId =   new Set<Id>();
        Set<Id> oppId =   new Set<Id>();
        for(Engagement_Internal_Team__c  inx :oitList){
            contactId.add(inx.contact__c);
            oppId.add(inx.Engagement__c);
        }
        system.debug('oitList'+oitList);
        list<Engagement_Internal_Team__c > internalTeam = new List<Engagement_Internal_Team__c >([Select id,contact__r.Acquired_From__c  from Engagement_Internal_Team__c 
                                                                                                  where Engagement__c in:oppID and Active_On_Engagement__c = true]);
        system.debug('internalTeam'+internalTeam);
        Map<Id,Engagement__c> oppData = new Map<Id,Engagement__c>([Select id,(Select id,contact__c,contact__r.Acquired_From__c from Engagement_Teams__r where  Active_On_Engagement__c = true) from  Engagement__c  where id in:oppId]);
        Map<Id,Set<Id>> mapOfContactandOpp = new Map<Id,Set<id>>();
        Set<Id> allContacts = new Set<Id>();
        system.debug('oppData'+oppData);
        for(Engagement__c ind :oppData.values()){
            Set<Id> contacts = new Set<Id>();
            for(Engagement_Internal_Team__c inx :ind.Engagement_Teams__r){
                contacts.add(inx.contact__c);
                allContacts.add(inx.Contact__c);
            }
            mapOfContactandOpp.put(ind.Id,contacts);
            
        }
        system.debug('allContacts'+allContacts);
        system.debug('mapOfContactandOpp'+mapOfContactandOpp); 
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
            system.debug('totalContacts'+totalContacts);
            system.debug('counter'+counter);
            if(totalContacts == 0){
                oppCheckbox.put(inx,false);
            }
            else if(counter == 0){
                oppCheckbox.put(inx,false);
            }
            else if(totalContacts==counter){
                oppCheckbox.put(inx,false);
            }
            else if(totalContacts>counter){
                oppCheckbox.put(inx,true);
            }
        }
        system.debug('oppCheckbox'+oppCheckbox);
        list<Engagement__c> oppRecords = new List<Engagement__c>();
         for(Id inx :oppId){
             if(oppCheckbox.containsKey(inx)){
                 Engagement__c newRec = new  Engagement__c();
                 newRec.Id = inx;
                 newRec.Co_exist__c  = oppCheckbox.get(inx);
                 oppRecords.add(newRec);
             }
         }
        system.debug('oppRecords size'+oppRecords.size());
        system.debug('oppRecords'+oppRecords);
        if(!oppRecords.isEmpty()){
            update oppRecords;
        }
        
    }

    /*
        @MethodName         : OnAfterUpdate
        @param              : Old and new map of Engagement_Internal_Team__c
        @Description        : This function will be called on after update of the Engagement_Internal_Team__c records 
    */
    public void OnAfterUpdate(List<Engagement_Internal_Team__c> eitList, Map<Id, Engagement_Internal_Team__c> mapOldEIT, Map<Id, Engagement_Internal_Team__c> mapNewEIT)
    {   
        updateCoExistCheckbox(eitList);
        if(HL_TriggerContextUtility.ByPassOnPercentages == null || !HL_TriggerContextUtility.ByPassOnPercentages) {
            UpdateInternalTeamAggregate(eitList); 
            
            boolean pvCheck = false;
            Set<Id> engagementsIds = new Set<Id>();
     
            for (Engagement_Internal_Team__c e : eitList ) { 
                engagementsIds.add(e.Engagement__c);
            }

            Set<string> recordtypenames = new Set<string>();
            
            for (Engagement__c e: [SELECT RecordType.Name FROM Engagement__c WHERE Id IN: engagementsIds]) {
                recordtypenames.add(e.RecordType.Name);
            }
             
            if (recordtypenames.size() > 0 && recordtypenames.contains('Portfolio Valuation')) {
                pvCheck = true;
            }
            // Updated by Sandeep SF-820
            if(pvCheck && !HL_ConstantsUtil.stopExecutionForPVConversion) {
                if(HL_ConstantsUtil.IsSupervisorOrAdmin()) {
                    Monthly_Revenue_Process_Control__c  MRPC = new Monthly_Revenue_Process_Control__c();
                    MRPC = HL_Eng_VP_PositionTriggerHelper.fetchMRPC();  
                    IF(MRPC != null){
                        UpdateEngVPPositionTeamMembers(eitList, mapOldEIT, MRPC );     
                    }
                }       
                setupSharingforUpdatedOITforRelatedEngagement(eitList, mapOldEIT);            
            }
        }
            
        SL_ManageSharingRules.createDeleteShareOnUpdate(mapOldEIT, mapNewEIT, 'Engagement__c', 'Engagement_Internal_Team__c'); 
    }
    
    /*
        @MethodName         : OnAfterDelete
        @param              : map of Engagement_Internal_Team__c  
        @Description        : This function will be called on after delete of the Engagement_Internal_Team__c records
                              to delete the engagement share records related to Engagement_Internal_Team__c 
    */
    public void onAfterDelete(List<Engagement_Internal_Team__c> eitList, Map<Id, Engagement_Internal_Team__c> mapEITOld)
    {
        if(!isAfterDeleteFlag){
            isAfterDeleteFlag = true;
            UpdateInternalTeamAggregate(eitList);
        }
        
        SL_ManageSharingRules.manageSharingRules(mapEITOld.values(), 'Engagement__c', 'Engagement_Internal_Team__c', 'delete');
    }

    public void onAllAfterEvents(Map<Id, Engagement_Internal_Team__c> oldMap, Map<Id, Engagement_Internal_Team__c> newMap)
    {
        HL_TriggerContextUtility.ByPassOnPercentages = true;
        HL_PercentageSplitHandler handler = new HL_PercentageSplitHandler();
        handler.recalculate(oldMap, newMap);
    }  
    
    private void UpdateInternalTeamAggregate(List<Engagement_Internal_Team__c> eitList){
        //Engagements To Update
        List<Engagement__c> eToUpdate = new List<Engagement__c>();
        //Create Set of Engagement Ids
        Set<Id> engs = new Set<Id>();
        for(Engagement_Internal_Team__c eit : eitList)
            engs.add(eit.Engagement__c);
         //Create a map of Engagement|role with team member ids
        Map<String,Set<String>> engTeamMap = new Map<String,Set<String>>();
        for(Engagement_Internal_Team__c er : [SELECT Engagement__c, Contact__r.User__c, Staff_Role__r.Name FROM Engagement_Internal_Team__c WHERE Engagement__c != null AND Engagement__c IN : engs AND End_Date__c = null])
        {
            String key = er.Engagement__c + '_' + er.Staff_Role__r.Name;
            if(engTeamMap.get(key) == null)
                engTeamMap.put(key, new Set<String>{er.Contact__r.User__c});
            else
            {
                Set<String> existingIds = (Set<String>)engTeamMap.get(key);
                existingIds.add(er.Contact__r.User__c);
                engTeamMap.put(er.Engagement__c, existingIds);
            }
        }
        //Get engagements that may need to be updated
        for(Engagement__c e : [SELECT Id, Internal_Team_Aggregate__c FROM Engagement__c WHERE Id IN : engs])
        {
                e.z_Admin_Intern_Aggregate__c = PopulateAggregateField(e.Id + '_Intern', engTeamMap);
                
                e.z_Analyst_Aggregate__c = PopulateAggregateField(e.Id + '_Analyst', engTeamMap);
                    if(e.z_Analyst_Aggregate__c.Length() > 255){
                        e.z_Analyst_Aggregate2__c = e.z_Analyst_Aggregate__c.subString(247);
                    if(e.z_Analyst_Aggregate2__c.Length() > 255){
                        e.z_Analyst_Aggregate3__c = e.z_Analyst_Aggregate2__c.subString(247);
                        e.z_Analyst_Aggregate2__c = e.z_Analyst_Aggregate__c.subString(0,246);
                        }
                    e.z_Analyst_Aggregate__c = e.z_Analyst_Aggregate__c.subString(0,246);
                }
                e.z_Associate_Aggregate__c = PopulateAggregateField(e.Id + '_Associate', engTeamMap);
                    if(e.z_Associate_Aggregate__c.Length() > 255){
                        e.z_Associate_Aggregate2__c = e.z_Associate_Aggregate__c.subString(247);
                    if(e.z_Associate_Aggregate2__c.Length() > 255){
                        e.z_Associate_Aggregate3__c = e.z_Associate_Aggregate2__c.subString(247);
                        e.z_Associate_Aggregate2__c = e.z_Associate_Aggregate__c.subString(0,246);
                        }
                        e.z_Associate_Aggregate__c = e.z_Associate_Aggregate__c.subString(0,246);
                }
                e.z_Final_Rev_Aggregate__c = PopulateAggregateField(e.Id + '_Final Reviewer', engTeamMap);
                e.z_Initiator_Aggregate__c= PopulateAggregateField(e.Id + '_Initiator', engTeamMap);
                if(e.z_Initiator_Aggregate__c.Length() > 255){
                    e.z_Initiator_Aggregate2__c = e.z_Initiator_Aggregate__c.subString(247);
                    e.z_Initiator_Aggregate__c = e.z_Initiator_Aggregate__c.subString(0,246);
                }
                e.z_Manager_Aggregate__c = PopulateAggregateField(e.Id + '_Manager', engTeamMap);
                e.z_Marketing_Aggregate__c = PopulateAggregateField(e.Id + '_Marketing Team', engTeamMap);
                
                if(e.z_Marketing_Aggregate__c.Length() > 255){
                    e.z_Marketing_Aggregate2__c = e.z_Marketing_Aggregate__c.subString(247);
                if(e.z_Marketing_Aggregate2__c.Length() > 255){
                        e.z_Marketing_Aggregate3__c = e.z_Marketing_Aggregate2__c.subString(247);
                        e.z_Marketing_Aggregate2__c = e.z_Marketing_Aggregate2__c.subString(0,246);
                    }
                    e.z_Marketing_Aggregate__c = e.z_Marketing_Aggregate__c.subString(0,246);
                }
                e.z_NonRegistered_Aggregate__c = PopulateAggregateField(e.Id + '_Non-Registered', engTeamMap);
                e.z_PE_HF_Aggregate__c = PopulateAggregateField(e.Id + '_PE/Hedge Fund', engTeamMap);
                e.z_Prelim_Rev_Aggregate__c = PopulateAggregateField(e.Id + '_Prelim Reviewer', engTeamMap);
                e.z_Pricing_Aggregate__c = PopulateAggregateField(e.Id + '_Pricing Committee Approver', engTeamMap);
                e.z_Principal_Aggregate__c = PopulateAggregateField(e.Id + '_Principal', engTeamMap);
                e.z_Public_Aggregate__c = PopulateAggregateField(e.Id + '_Public Person', engTeamMap);
                e.z_Reviewer_Aggregate__c = PopulateAggregateField(e.Id + '_Reviewer', engTeamMap);
                e.z_Seller_Aggregate__c = PopulateAggregateField(e.Id + '_Seller', engTeamMap);
                e.z_Specialty_Aggregate__c = PopulateAggregateField(e.Id + '_Ind/Prod/Geog Person', engTeamMap);
                eToUpdate.add(e);
        }
        
        if(eToUpdate.size() > 0)
           update eToUpdate;
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
    
    private static void UpdateEngVPPositionTeamMembers(List<Engagement_Internal_Team__c> processedInternTeamMemberList , Map<Id,Engagement_Internal_Team__c> processedInternTeamMemberMap, Monthly_Revenue_Process_Control__c MRPC){
      
      Set<Eng_VP_TeamMember__c> EngVPPosTeamMemberList = new Set<Eng_VP_TeamMember__c>();
      List<Eng_VP_TeamMember__c> EngVPPosTeamMemberToDeleteList = new List<Eng_VP_TeamMember__c>();
      
      Set<Id> relatedEngagementIdSet = new Set<Id>();
      Set<Id> relatedContactIdSet = new Set<Id>();
      Map<Id, date> contactWithRecentEndDateMap = new Map<Id, date>(); 
      for(Engagement_Internal_Team__c processedInternTeamMember : processedInternTeamMemberList) {
        if(processedInternTeamMember.End_Date__c != null && processedInternTeamMember.End_Date__c != processedInternTeamMemberMap.get(processedInternTeamMember.Id).End_Date__c)
            relatedEngagementIdSet.add(processedInternTeamMember.Engagement__c);  
            relatedContactIdSet.add(processedInternTeamMember.Contact__c);
      }
      
      Set<Id> ContactsToExclude = new Set<Id>();
      // we will exlucde only that contact which has at least one Engagement team member record with blank end date ( it means Eng team memeber still is in the list under Engagement) 
      for(Contact cont : [SELECT Id, (SELECT Id,End_Date__c FROM Engagement_Teams__r WHERE End_Date__c = null AND Engagement__c In : relatedEngagementIdSet) 
                FROM Contact 
                WHERE Id In : relatedContactIdSet]) {
          If(cont.Engagement_Teams__r.size() > 0)
            ContactsToExclude.add(cont.Id);
      }            
      // Purpose of excluding such contact is to avoid end date populating on Eng VP Team member record where Eng Team member still under Engagement.  
      relatedContactIdSet.removeAll(ContactsToExclude);     
      
      // To calculate most recent end date to be populated in to Eng VP Team member
      AggregateResult[] groupedResults = [SELECT Contact__c contactId, MAX(End_Date__c) recentEndDate  
                        FROM Engagement_Internal_Team__c 
                        WHERE End_Date__c != null AND Engagement__c IN : relatedEngagementIdSet AND Contact__c IN : relatedContactIdSet GROUP BY Contact__c ];
    for (AggregateResult ar : groupedResults) {
        contactWithRecentEndDateMap.put(String.valueof(ar.get('contactId')), Date.valueof(ar.get('recentEndDate')));
    }
    
    for(Eng_VP_TeamMember__c EngVPTM : [SELECT Id, Start_date__c, End_Date__c, Staff__c, Engagement_VP_Position__r.Revenue_Month__c,Engagement_VP_Position__r.Revenue_Year__c   
                      FROM Eng_VP_TeamMember__c 
                      WHERE Engagement_VP_Position__r.Status__c != 'Cancelled' AND Engagement_VP_Position__r.Engagement_VP__r.Engagement__c IN : relatedEngagementIdSet AND Staff__c IN : relatedContactIdSet ]) {
      if(!HL_Eng_VP_PositionTriggerHelper.isRevenueMonthYearPassed(EngVPTM.Engagement_VP_Position__r.Revenue_Month__c, EngVPTM.Engagement_VP_Position__r.Revenue_Year__c,MRPC)){
          if(EngVPTM.End_Date__c == null || EngVPTM.End_Date__c >= contactWithRecentEndDateMap.get(EngVPTM.Staff__c))
              EngVPTM.End_Date__c = contactWithRecentEndDateMap.get(EngVPTM.Staff__c);
          if(contactWithRecentEndDateMap.get(EngVPTM.Staff__c) != null) {
            if(EngVPTM.Start_date__c != null && EngVPTM.Start_date__c > EngVPTM.End_Date__c ) {
                EngVPPosTeamMemberToDeleteList.add(EngVPTM);
              }
              else {
                EngVPTM.End_Date__c = contactWithRecentEndDateMap.get(EngVPTM.Staff__c);
                EngVPTM.Is_Team_Member_Deactivated_Once__c = true;
                EngVPPosTeamMemberList.add(EngVPTM);             
              }
          }
      }
    }
    
    if(EngVPPosTeamMemberToDeleteList.size() > 0){      
      delete EngVPPosTeamMemberToDeleteList;
    }
      
    if(EngVPPosTeamMemberList.size() > 0){               
        Set<Eng_VP_TeamMember__c> setofRecordsToBeRemoved = new Set<Eng_VP_TeamMember__c>();
        setofRecordsToBeRemoved = HL_ContactHandler.removeDuplicateEngVpTMRecrds(EngVPPosTeamMemberList);  
        EngVPPosTeamMemberList.removeAll(setofRecordsToBeRemoved);  
        List<Eng_VP_TeamMember__c> ListOfVPTMs = new List<Eng_VP_TeamMember__c>();
        ListOfVPTMs.addAll(EngVPPosTeamMemberList);
        update ListOfVPTMs;
      }
    }
    
    private static list<Eng_VP__c> EngVPList;
    
    private static void setupSharingforUpdatedOITforRelatedEngagement(list<Engagement_Internal_Team__c> oitList, map<Id, Engagement_Internal_Team__c> mapOldOIT) {
      
      list<Engagement_Internal_Team__c> ValidOITList = new list<Engagement_Internal_Team__c>();
      Set<Id> RelatedEngagementIdSet = new Set<Id>();
      Set<String> EngContactCombinationSetforsiblingOITs = new Set<String>();
      list<Engagement_Internal_Team__c> SiblingOITs = new list<Engagement_Internal_Team__c>();
      for(Engagement_Internal_Team__c oit : [SELECT Id, Contact__r.User__c, End_Date__c, Engagement__c  
                          FROM Engagement_Internal_Team__c
                          WHERE Id IN :oitList ])
      { 
        if(oit.End_Date__c != Null && oit.End_Date__c != mapOldOIT.get(oit.id).End_Date__c)
        {
          ValidOITList.add(oit);          
          RelatedEngagementIdSet.add(oit.Engagement__c);
        }
      }
      
      for(Engagement_Internal_Team__c siblingOIT : [SELECT Id , Engagement__c, Contact__c, contact__r.user__c
                              FROM Engagement_Internal_Team__c
                              WHERE End_Date__c = NULL AND Engagement__c IN :RelatedEngagementIdSet ])
      {
        EngContactCombinationSetforsiblingOITs.add(siblingOIT.Engagement__c+'_'+siblingOIT.Contact__c);
        SiblingOITs.add(siblingOIT);
      } 
      
      list<Engagement_Internal_Team__c> filtered_Level1_OITList = new list<Engagement_Internal_Team__c>();
      Set<Engagement_Internal_Team__c> filtered_Level2_OITList = new Set<Engagement_Internal_Team__c>();
      for(Engagement_Internal_Team__c  validOIT : ValidOITList){ 
        if(!EngContactCombinationSetforsiblingOITs.contains(validOIT.Engagement__c+'_'+validOIT.Contact__c))
          filtered_Level1_OITList.add(validOIT);
        else 
          SiblingOITs.add(validOIT);
      }
      
      map<String, list<Id>> EngagementWithRelatedTMDelegatedUserMap = new map<String, list<Id>>();
      map<String, list<Id>> EngagementWithRelatedTMDelegatedToValidUserMap = new map<String, list<Id>>();
      
      if(filtered_Level1_OITList.size() > 0)
      EngagementWithRelatedTMDelegatedToValidUserMap = HL_Eng_VP_TriggerHelper.fetchUserGroupOnlyRelatedToOIT(filtered_Level1_OITList);     
    
    if(SiblingOITs.size() > 0)
      EngagementWithRelatedTMDelegatedUserMap = HL_Eng_VP_TriggerHelper.fetchUserGroupOnlyRelatedToOIT(SiblingOITs);
      
      
      Set<Id> tempSet = new Set<Id>();
      Boolean isfound = false;
      Set<Id> StopDeletionSharing = new Set<Id>();
      for(Engagement_Internal_Team__c filtered_OIT : filtered_Level1_OITList)
      {
        isfound = false;
        if(EngagementWithRelatedTMDelegatedUserMap.containsKey(filtered_OIT.Engagement__c +'_TM')) 
        {
              tempSet = new Set<Id>();
              tempSet.addAll(EngagementWithRelatedTMDelegatedUserMap.get(filtered_OIT.Engagement__c +'_TM'));
              if(tempSet.contains(filtered_OIT.Contact__r.User__c))
                isfound = true;                 
        }            
            if(EngagementWithRelatedTMDelegatedUserMap.containsKey(filtered_OIT.Engagement__c +'_DU'))              
          {
            tempSet = new Set<Id>();
              tempSet.addAll(EngagementWithRelatedTMDelegatedUserMap.get(filtered_OIT.Engagement__c +'_DU'));
              if(tempSet.contains(filtered_OIT.Contact__r.User__c))
                isfound = true;
              if(EngagementWithRelatedTMDelegatedToValidUserMap.containsKey(filtered_OIT.Engagement__c +'_DU')) 
              {
                for(Id UorGpId : EngagementWithRelatedTMDelegatedToValidUserMap.get(filtered_OIT.Engagement__c +'_DU')) {
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
      
      for(Engagement_Internal_Team__c filtered_OIT2 : filtered_Level2_OITList)
      {
        finalUserIdSetToRemoveSharing.add(filtered_OIT2.Contact__r.User__c);
      }
      
      fetchingVPFamily(RelatedEngagementIdSet);

      list<Eng_VP__Share> listSharedVpToBeDelete = new list<Eng_VP__Share>();
        listSharedVpToBeDelete = [Select Id from Eng_VP__Share Where ParentId =: EngVPList AND UserOrGroupId IN: finalUserIdSetToRemoveSharing AND UserOrGroupId NOT IN : StopDeletionSharing];
    
      if(listSharedVpToBeDelete.size() >0 )  
        delete listSharedVpToBeDelete;
    
    }    
   
    private static void setupSharingforInsertedOITforRelatedEngagement(list<Engagement_Internal_Team__c> oitList) {
      
      map<String, list<Id>> EngagementWithRelatedTMDelegatedUserMap = new map<String, list<Id>>();      
      list<Engagement_Internal_Team__c> EngInternalTeamMemberList = new list<Engagement_Internal_Team__c>();
      Set<Id> reltedEngagementIdSet = new Set<Id>();
        for(Engagement_Internal_Team__c EngInternalTeamMember : [SELECT contact__r.user__c, Engagement__c 
                                       FROM Engagement_Internal_Team__c 
                                       WHERE End_Date__c = NULL AND Id IN : oitList])
        {
          EngInternalTeamMemberList.add(EngInternalTeamMember);
          reltedEngagementIdSet.add(EngInternalTeamMember.Engagement__c);
                                             
        }
          
        EngagementWithRelatedTMDelegatedUserMap = HL_Eng_VP_TriggerHelper.fetchUserGroupOnlyRelatedToOIT(EngInternalTeamMemberList);
        
        fetchingVPFamily(reltedEngagementIdSet);
       
        HL_Eng_VP_TriggerHelper.SetupSharingCoreLogicForEngVP(EngVPList, EngagementWithRelatedTMDelegatedUserMap);
       
    }
    
    public static void fetchingVPFamily(set<Id> reltedEngagementIdSet) {
      EngVPList = new list<Eng_VP__c>();
        
        for(Eng_VP__c EngVP : [SELECT Id, Engagement__c,ownerId 
                     FROM Eng_VP__c
                     WHERE Engagement__c IN : reltedEngagementIdSet])
        {
          EngVPList.add(EngVP);         
        }
    }
    
    public static void UpdateRevenueAllocationOnEIT(List<Engagement_Internal_Team__c> newEITList){
        
        
        Map<Id,String> RevenueAllocationOfficeMap = new Map<Id,String>();
        Map<String,String> ExistingRevAllocationMap = new Map<String,String>();
        Set <Id> setOfEITContact = new Set <Id>();
        Set <Id> setOfExistingOITEng = new Set <Id>();

        for(Engagement_Internal_Team__c AllEIT : newEITList){
            if(AllEIT.Contact__c != null){
                setOfEITContact.add(AllEIT.Contact__c);
                setOfExistingOITEng.add(AllEIT.Engagement__c);
            }
        }
        
        for(Engagement_Internal_Team__c existingEIT : [SELECT Id, Revenue_Allocation__c,Contact__c,Engagement__c  FROM Engagement_Internal_Team__c WHERE Engagement__c IN : setOfExistingOITEng AND Contact__c IN :setOfEITContact AND End_Date__c = null] ){
            if(!ExistingRevAllocationMap.containsKey(existingEIT.Engagement__c+'-'+existingEIT.Contact__c) && existingEIT.Revenue_Allocation__c != null){
                ExistingRevAllocationMap.put(existingEIT.Engagement__c+'-'+existingEIT.Contact__c,existingEIT.Revenue_Allocation__c);
            }
        }

        if(setOfEITContact.size() > 0){         
            for(Contact con : [SELECT id,Office__c,Revenue_Allocation__c FROM Contact WHERE Id IN : setOfEITContact AND (Office__c != null OR Revenue_Allocation__c != null)]){ 
                if(!RevenueAllocationOfficeMap.containsKey(con.Id)){
                    if(con.Revenue_Allocation__c != null){
                        RevenueAllocationOfficeMap.put(con.Id,con.Revenue_Allocation__c);
                    } else {
                        RevenueAllocationOfficeMap.put(con.Id,con.Office__c);
                    }
                }
            }
        }

        if(RevenueAllocationOfficeMap.size () > 0){
            for(Engagement_Internal_Team__c EIT : newEITList){
                if(ExistingRevAllocationMap.containsKey(EIT.Engagement__c+'-'+EIT.Contact__c)){
                    EIT.Revenue_Allocation__c = ExistingRevAllocationMap.get(EIT.Engagement__c+'-'+EIT.Contact__c);
                }else if(RevenueAllocationOfficeMap.containsKey(EIT.Contact__c)){
                    EIT.Revenue_Allocation__c = RevenueAllocationOfficeMap.get(EIT.Contact__c);
                }
            }
        }
    }
    
    
    /*  @MethodName         : UpdateRevenueAllocationOnSiblingEIT
        @Ticket             : PRJ0016533 - Office Revenue Allocation on Engagement Internal Team
        @Description        : To populate 'Revenue Allocation' on all sibling Internal Team records */  
    public static void UpdateRevenueAllocationOnSiblingEIT(List<Engagement_Internal_Team__c> newEITList){
        
        Map<Id,String> RevenueAllocationOfficeMap = new Map<Id,String>();
        Set <Id> setOfEITContact = new Set <Id>();
        Set <Id> setOfEITeng = new Set <Id>();
        Set <Id> setOfInsertedEIT = new Set <Id>();
        List<Engagement_Internal_Team__c> EITtoUpdate = new List<Engagement_Internal_Team__c>();

        for(Engagement_Internal_Team__c AllEIT : newEITList){
            if(AllEIT.Contact__c != null){
                setOfEITeng.add(AllEIT.Engagement__c);
                setOfEITContact.add(AllEIT.Contact__c);
                setOfInsertedEIT.add(AllEIT.Id);
                if(!RevenueAllocationOfficeMap.containsKey(AllEIT.Contact__c)){
                    RevenueAllocationOfficeMap.put(AllEIT.Contact__c,AllEIT.Revenue_Allocation__c);
                }
            }
        }

        // To find sibling OIT and updating with latest Revenue Allocation
        if(RevenueAllocationOfficeMap.size () > 0){
            for(Engagement_Internal_Team__c siblingEIT : [SELECT Id, Revenue_Allocation__c,Contact__c FROM Engagement_Internal_Team__c WHERE Id NOT IN :setOfInsertedEIT AND Engagement__c IN : setOfEITeng AND Contact__c IN :setOfEITContact AND End_Date__c = null]){
                if(RevenueAllocationOfficeMap.containsKey(siblingEIT.Contact__c)){
                    siblingEIT.Revenue_Allocation__c = RevenueAllocationOfficeMap.get(siblingEIT.Contact__c);
                    EITtoUpdate.add(siblingEIT);
                }
            }
        }
        
        if(EITtoUpdate.size() > 0){
            update EITtoUpdate;
        }
    }
    
}