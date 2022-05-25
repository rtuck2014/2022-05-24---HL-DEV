public class HL_Eng_VP_TriggerHelper {
    
    public static void beforeInsert(List<Eng_VP__c> newEengVPList, Map<Id, Eng_VP__c> newEengVPMap, List<Eng_VP__c> oldEengVPList , Map<Id, Eng_VP__c> oldEengVPMap) {
        changeOwnershipToSystemAdmin(newEengVPList);       
        if(!HL_ConstantsUtil.stopExecutionForPVConversion && !HL_ConstantsUtil.stopUpdatingPVValueStatusChange)
           avoidChangesOnRollupFieldsOnVP('BeforeInsert', newEengVPList, null, null, null);  
    }
    
    public static void afterInsert(List<Eng_VP__c> newEengVPList, Map<Id, Eng_VP__c> newEengVPMap, List<Eng_VP__c> oldEengVPList , Map<Id, Eng_VP__c> oldEengVPMap) { 
        SetupSharingforEngVp(newEengVPList);
        CreateEngVPAllocations(newEengVPList,oldEengVPMap); //Added on March 10, 2021
        
        if(PortfolioValuationConfig__c.getOrgDefaults() == null || (PortfolioValuationConfig__c.getOrgDefaults() != null && !PortfolioValuationConfig__c.getOrgDefaults().Lock_Rollup__c))
            CalculateRollupOnEng('AfterInsert', newEengVPList, newEengVPMap, null, null);
        
        
    }
    
    public static void beforeUpdate(List<Eng_VP__c> newEengVPList, Map<Id, Eng_VP__c> newEengVPMap, List<Eng_VP__c> oldEengVPList , Map<Id, Eng_VP__c> oldEengVPMap) {   
      // if(!HL_ConstantsUtil.stopExecutionForPVConversion && !HL_ConstantsUtil.stopUpdatingPVValueStatusChange)
         //  avoidChangesOnRollupFieldsOnVP('BeforeUpdate', newEengVPList, newEengVPMap, oldEengVPList , oldEengVPMap);     
    }
   
    public static void afterUpdate(List<Eng_VP__c> newEengVPList, Map<Id, Eng_VP__c> newEengVPMap, List<Eng_VP__c> oldEengVPList , Map<Id, Eng_VP__c> oldEengVPMap) {
       CreateEngVPAllocations(newEengVPList,oldEengVPMap);
        if(HL_ConstantsUtil.ToStopChangesCurrency){
            if(PortfolioValuationConfig__c.getOrgDefaults() == null || (PortfolioValuationConfig__c.getOrgDefaults() != null && !PortfolioValuationConfig__c.getOrgDefaults().Lock_Rollup__c))
                CalculateRollupOnEng('AfterUpdate', newEengVPList, newEengVPMap, oldEengVPList , oldEengVPMap);
        }
        
    }    
    
    
    public static void afterDelete(List<Eng_VP__c> newEengVPList, Map<Id, Eng_VP__c> newEengVPMap, List<Eng_VP__c> oldEengVPList , Map<Id, Eng_VP__c> oldEengVPMap) {
        if(PortfolioValuationConfig__c.getOrgDefaults() == null || (PortfolioValuationConfig__c.getOrgDefaults() != null && !PortfolioValuationConfig__c.getOrgDefaults().Lock_Rollup__c))
            CalculateRollupOnEng('AfterDelete', null, null, oldEengVPList , oldEengVPMap);
    }
    public static void beforeDelete(List<Eng_VP__c> oldEengVPList) {
        
        if(!HL_ConstantsUtil.IsSupervisorOrAdmin() && oldEengVPList != null && oldEengVPList.size() > 0 ) {
            oldEengVPList[0].addError(Label.HL_No_Delete_Privilige_VP);
        }  
        if(!HL_ConstantsUtil.stopExecutionForPVConversion){
            StopDeletion(oldEengVPList);
        }
    }
        
    // To change owner of Opp VP records to System Administrator 
    private static void changeOwnershipToSystemAdmin(list<Eng_VP__c> newEngVPList) {
            
      for(Eng_VP__c EngVP : newEngVPList)
      {
          EngVP.ownerId = Label.Salesforce_Administrator_ID;
          EngVP.CurrencyIsoCode = EngVP.Parent_Currency_Formula__c;
      }
    }
    
    public static void SetupSharingforEngVp(list<Eng_VP__c> newEengVPList) {
      
      
      map<String, list<Id>> EngagementWithRelatedTMDelegatedUserMap = new map<String, list<Id>>(); 
      Set<Id> RelatedEngagementIdSet = new Set<Id>();
        for(Eng_VP__c egVp : newEengVPList) 
        {
            RelatedEngagementIdSet.add(egVp.Engagement__c);
        }
      EngagementWithRelatedTMDelegatedUserMap = fetchUserGroupToBeShared(RelatedEngagementIdSet);
      SetupSharingCoreLogicForEngVP(newEengVPList, EngagementWithRelatedTMDelegatedUserMap);
      
    }      
    
    public static map<String, list<Id>> fetchUserGroupToBeShared(Set<Id> RelatedEngagementIdSet) {        
        
        map<String, list<Id>> EngagementWithRelatedTMDelegatedUserMap = new map<String, list<Id>>();
        list<Engagement_Internal_Team__c> EngInternalTeamMemberList = new list<Engagement_Internal_Team__c>();
        if(HL_ConstantsUtil.EngInternalTeamMemberList != null &&  HL_ConstantsUtil.EngInternalTeamMemberList.size() == 0) {
            EngInternalTeamMemberList = [SELECT contact__r.user__c, Engagement__c 
                       FROM Engagement_Internal_Team__c 
                       WHERE End_Date__c = NULL AND contact__r.user__r.IsActive = True AND Engagement__c IN : RelatedEngagementIdSet];
            HL_ConstantsUtil.EngInternalTeamMemberList = EngInternalTeamMemberList;
        }
        else
        {
            EngInternalTeamMemberList = HL_ConstantsUtil.EngInternalTeamMemberList;
        }
        
    if(EngInternalTeamMemberList.size() > 0)
      EngagementWithRelatedTMDelegatedUserMap = fetchUserGroupOnlyRelatedToOIT(EngInternalTeamMemberList);        
        
   //    Id PVStaffingGrpId, PVSupervisorGrpId ;    // Commented code by Harsh Singh SF-820
       Id PVSupervisorGrpId ;    
       list<Group> GroupList = new list<Group>();
       
       if(HL_ConstantsUtil.PVGroupList != null &&  HL_ConstantsUtil.PVGroupList.size() == 0) {
       //    GroupList = [SELECT Id, Name   FROM Group WHERE Name =: system.Label.HL_PV_Portfolio_Valuation_Staffing OR Name =: system.Label.HL_PV_Portfolio_Valuation_Supervisors]; // Commented code by Harsh Singh SF-820
           GroupList = [SELECT Id, Name   FROM Group WHERE Name =: system.Label.HL_PV_Portfolio_Valuation_Supervisors];
           HL_ConstantsUtil.PVGroupList = GroupList;
       }
       else
       {
           GroupList = HL_ConstantsUtil.PVGroupList;
       }
       for(Group grp: GroupList)
       {       
         if(grp.Name == system.Label.HL_PV_Portfolio_Valuation_Supervisors)
         {
           PVSupervisorGrpId = grp.Id;
         }
       }
       
      
       for(Id egtyId : RelatedEngagementIdSet)
       {          
         EngagementWithRelatedTMDelegatedUserMap.put(egtyId+'_PVSupervsr',new List<Id>{PVSupervisorGrpId});
       }      
      return EngagementWithRelatedTMDelegatedUserMap;
    }    
    
    public static void SetupSharingCoreLogicForEngVP(list<Eng_VP__c> newEengVPList , map<String, list<Id>> EngagementWithRelatedTMDelegatedUserMap)
    {
      list<Eng_VP__share> SharingEngVPList = new list<Eng_VP__share>();
      
      if(newEengVPList != null )
      for(Eng_VP__c egVp : newEengVPList) 
        {
            Set<id> myMatchingSet = new Set<id>();
            if(EngagementWithRelatedTMDelegatedUserMap.containsKey(egVp.Engagement__c+'_TM'))             
              for(Id UserGroupId : EngagementWithRelatedTMDelegatedUserMap.get(egVp.Engagement__c+'_TM'))
              {
                 
                 if(UserGroupId != null && UserGroupId != egVp.ownerId)
                  SharingEngVPList.add(new Eng_VP__share(ParentId = egVp.id, UserOrGroupId = UserGroupId, Accesslevel = 'Edit'));
                  
                 
              }     
                   
            if(EngagementWithRelatedTMDelegatedUserMap.containsKey(egVp.Engagement__c+'_DU')){   
              for(Id UserGroupId : EngagementWithRelatedTMDelegatedUserMap.get(egVp.Engagement__c+'_DU'))
              {
                if(UserGroupId != null && UserGroupId != egVp.ownerId)
                  SharingEngVPList.add(new Eng_VP__share(ParentId = egVp.id, UserOrGroupId = UserGroupId, Accesslevel = 'Edit'));
                
              }
            }
            if(EngagementWithRelatedTMDelegatedUserMap.containsKey(egVp.Engagement__c+'_PVSupervsr'))
              for(Id UserGroupId : EngagementWithRelatedTMDelegatedUserMap.get(egVp.Engagement__c+'_PVSupervsr'))
              {
                if(UserGroupId != null && UserGroupId != egVp.ownerId)
                  SharingEngVPList.add(new Eng_VP__share(ParentId = egVp.id, UserOrGroupId = UserGroupId, Accesslevel = 'Edit'));
              }                    
        }    
        
        if(SharingEngVPList.size() > 0 )
        {
          insert SharingEngVPList;
        }      
    }     
    
    public static map<String, list<Id>> fetchUserGroupOnlyRelatedToOIT(list<Engagement_Internal_Team__c> EngInternalTeamMemberList) { 
      
      map<String, list<Id>> EngagementWithRelatedTMDelegatedUserMap = new map<String, list<Id>>();
        map<Id, Set<Id>> userEngagementMap = new map<Id, Set<Id>>();
      Set<String> matchingSet = new Set<String>();
      for(Engagement_Internal_Team__c eit : EngInternalTeamMemberList)
        {          
          if(!matchingSet.contains(eit.Engagement__c+''+eit.contact__r.user__c)){              
          if(!EngagementWithRelatedTMDelegatedUserMap.containskey(eit.Engagement__c+'_TM'))
            EngagementWithRelatedTMDelegatedUserMap.put(eit.Engagement__c+'_TM', new list<id>{eit.contact__r.user__c});
          else
            EngagementWithRelatedTMDelegatedUserMap.get(eit.Engagement__c+'_TM').add(eit.contact__r.user__c);
          matchingSet.add(eit.Engagement__c+''+eit.contact__r.user__c);
          }
          if(!userEngagementMap.containskey(eit.contact__r.user__c))
            userEngagementMap.put(eit.contact__r.user__c, new set<id>{eit.Engagement__c});
          else
            userEngagementMap.get(eit.contact__r.user__c).add(eit.Engagement__c);
          
        }
        
        map<Id, Set<Id>> UserWithDelegatedGroupIdMap = new map<Id, Set<Id>>();
            
        
        Set<id> relatedpublicGroupIdSet = new Set<Id>();
       
        if(userEngagementMap.KeySet().size() > 0 )
        for(Delegate_Public_Group__c dpg : [SELECT Banker__c , Public_Group_ID__c, (select Delegate__c, Delegate_Public_Group__r.Banker__c  from Delegate_Public_Group_Members__r )
                          FROM Delegate_Public_Group__c
                          WHERE Banker__c IN : userEngagementMap.KeySet()])
        {
            if(userEngagementMap.containsKey(dpg.Banker__c))
                for(Id engagementId : userEngagementMap.get(dpg.Banker__c))
                {
                    if(!EngagementWithRelatedTMDelegatedUserMap.containskey(engagementId+'_DU'))
                        EngagementWithRelatedTMDelegatedUserMap.put(engagementId+'_DU',new list<id>{dpg.Public_Group_ID__c});          
                    else             
                        EngagementWithRelatedTMDelegatedUserMap.get(engagementId+'_DU').add(dpg.Public_Group_ID__c);
                }              
        }
        return EngagementWithRelatedTMDelegatedUserMap;
    }
   
    /** Added BY SF- 832 **/
    private static void CalculateRollupOnEng(String eventType, List<Eng_VP__c> newEngVPList, Map<Id, Eng_VP__c> newEngVPMap, List<Eng_VP__c> oldEngVPList , Map<Id, Eng_VP__c> oldEngVPMap){
        List<Id> EngToProcess = new List<Id>();
        if (eventType == 'AfterInsert') {
            for(Eng_VP__c engVPNewObj : newEngVPList){
                if (engVPNewObj.Total_Fee_Completed__c != null)
                    EngToProcess.add(engVPNewObj.Engagement__c);                  
            }
        }
        else if (eventType == 'AfterUpdate') {
            for(Eng_VP__c newVPengVPNewObj : newEngVPList) {
                if(newVPengVPNewObj.Total_Fee_Completed__c !=null && newVPengVPNewObj.Total_Fee_Completed__c != oldEngVPMap.get(newVPengVPNewObj.id).Total_Fee_Completed__c){
                    EngToProcess.add(newVPengVPNewObj.Engagement__c);                     
                }
            }           
        }
        else if(eventType == 'AfterDelete') {
            for(Eng_VP__c engVPNewObj : oldEngVPList){
               
                if (engVPNewObj.Total_Fee_Completed__c != null){
                    EngToProcess.add(engVPNewObj.Engagement__c);
                }                   
            }
        }
        List<Engagement__c> engToUpdateList = new List<Engagement__c >(); 
        Decimal decEmptyVal = 0.00;
        boolean isIncluded;
        for(Engagement__c engObj : [SELECT id, Total_Estimated_Fee__c, (select id, Total_Fee_Completed__c from Engagement_Portfolio_Valuations__r) 
                             FROM Engagement__c 
                             WHERE ID IN : EngToProcess]){
            isIncluded = false;
            if(engObj.Engagement_Portfolio_Valuations__r.size() == 0 ) {           
                engObj.Total_Estimated_Fee__c = decEmptyVal;
                isIncluded = true;           
            }
            else {
                decimal tempTotal = 0.0;
                for(Eng_VP__c engVPObj : engObj.Engagement_Portfolio_Valuations__r) {                             
                    if(engVPObj != null && engVPObj.Total_Fee_Completed__c != null){
                        tempTotal += engVPObj.Total_Fee_Completed__c;  
                        isIncluded = true;                       
                    }                    
                }
                engObj.Total_Estimated_Fee__c = tempTotal;   
            }
            if(isIncluded)
            {
                engToUpdateList.add(engObj);
            }            
        }
        if(engToUpdateList.size() > 0 ){
            HL_ConstantsUtil.stopExecuteEstFeeUpdateTrigger = true;
            update engToUpdateList;
            HL_ConstantsUtil.stopExecuteEstFeeUpdateTrigger = false;
        }
    }
    public static void avoidChangesOnRollupFieldsOnVP(String eventType, List<Eng_VP__c> newEngVPList, Map<Id, Eng_VP__c> newEngVPMap, List<Eng_VP__c> oldEngVPList , Map<Id, Eng_VP__c> oldEngVPMap){        
        
        if(eventType == 'BeforeInsert'){
            for(Eng_VP__c newEngVPObj : newEngVPList) {            
                   newEngVPObj.Fee_Total__c  = 0.0;       
                   newEngVPObj.Overall_VP_Status__c = 'New';
            }
        }
        else if(eventType == 'BeforeUpdate')
        {
            List<Id> EngVPToProcess = new List <Id>();
            for(Eng_VP__c newEngVPObj : newEngVPList) {       
                if(newEngVPObj.Name == '' || newEngVPObj.Name == null) {
                   newEngVPObj.addError(label.HL_Name_Required);                                      
                }
                if((newEngVPObj.Fee_Total__c != oldEngVPMap.get(newEngVPObj.id).Fee_Total__c)||(newEngVPObj.Overall_VP_Status__c != oldEngVPMap.get(newEngVPObj.id).Overall_VP_Status__c ) ){
                    EngVPToProcess.add(newEngVPObj.Id);   
                }
            }
            Map<String, String>strMap = new Map<String, String>();        
            for(Eng_VP__c engObj : [SELECT id, Fee_Total__c, Overall_VP_Status__c, (select id, Report_Fee__c, Status__c from Eng_VP_Positions__r) 
                             FROM Eng_VP__c 
                             WHERE ID IN : EngVPToProcess]){
                if(engObj.Eng_VP_Positions__r.size() == 0) {
                    newEngVPMap.get(engObj.id).Fee_Total__c = 0.0;  
                    newEngVPMap.get(engObj.id).Overall_VP_Status__c = 'New';             
                }
                else {
                    decimal tempTotal = 0.0;
                    String tempStatus = 'Completed';
                    boolean isSingleCompleted = false;
                    boolean isSingleProgress = false;
                    for(Eng_VP_Position__c engVPObj : engObj.Eng_VP_Positions__r) {  
                        if(engVPObj!= null && engVPObj.Status__c != 'Cancelled'){
                            tempTotal += (engVPObj.Report_Fee__c != null ? engVPObj.Report_Fee__c: 0);
                        }
                        if(engVPObj.Status__c == System.Label.HL_Eng_VP_Status_Completed){
                            isSingleCompleted = true;
                        } 
                        if(engVPObj.Status__c == 'In Progress' ){
                            isSingleProgress = true;
                        } 
                    }                    
                    if(isSingleCompleted && !isSingleProgress)
                        tempStatus = 'Completed';                                                            
                    else
                        tempStatus = 'In Progress' ;
                    newEngVPMap.get(engObj.id).Fee_Total__c = tempTotal;  
                    newEngVPMap.get(engObj.id).Overall_VP_Status__c = tempStatus ;                                       
                }  
            }
        }                   
    }
    
    public static void StopDeletion(List<Eng_VP__c> oldEngVPist) {        
         
        for(Eng_VP__c egVPPObj : oldEngVPist)
        {   
            // To stop Deleting position if Fee completed is filled and enagagement stage is closed
            if(egVPPObj.Total_Fee_Completed__c != null && egVPPObj.Total_Fee_Completed__c != 0 && egVPPObj.Engagement_Stage__c == 'Closed')
            {
                egVPPObj.adderror(System.Label.HL_VP_Del_On_ClosedEng);
            }
            // To stop Deleting position if Fee completed is filled and enagagement stage is Dead 
            if(egVPPObj.Total_Fee_Completed__c != null && egVPPObj.Total_Fee_Completed__c != 0 && egVPPObj.Engagement_Stage__c == 'Dead')
            {
                egVPPObj.adderror(System.Label.HL_VP_Del_On_DeadEng);
            }
            // To stop Deleting position if Fee completed is filled and Revenue Accrual is locked
            if(egVPPObj.Total_Fee_Completed__c != null && HL_Eng_VP_PositionTriggerHelper.IsReveneAccrualLocked())
            {
                egVPPObj.adderror(System.Label.HL_Revenue_Locked_Msg_forVP);
            }           
        }    
    }
    
    /* Date : March 10, 2021
        Adding a logic to Create Eng VP Allocation Records */
//      @InvocableMethod(label='Create Eng VP Allocation Records'  category='Apex')

    public static void CreateEngVPAllocations(List<Eng_VP__c> lstEngVPRec,Map<Id, Eng_VP__c> oldEengVPMap){
        List<Eng_Valuation_Period_Allocation__c> engVPAllocToInsert = new List<Eng_Valuation_Period_Allocation__c>();
        List<Eng_VP__c> lstEngVPRecNew =new List<Eng_VP__c>();
        Map<Id,Set<Date>> mapDupCheck = new  Map<Id,Set<Date>>();
         system.debug('lstEngVPRec.....'+lstEngVPRec);
        if(oldEengVPMap!=null){
        for(Eng_VP__c egVpRec : lstEngVPRec){
         system.debug(oldEengVPMap.get(egVpRec.Id).Client_Final_Deadline__c+'if.....'+egVpRec.Client_Final_Deadline__c);
         system.debug('else ....'+ (egVpRec.Client_Final_Deadline__c!=oldEengVPMap.get(egVpRec.Id).Client_Final_Deadline__c));
           // if(egVpRec.Client_Final_Deadline__c!=null && egVpRec.Client_Final_Deadline__c!=oldEengVPMap.get(egVpRec.Id).Client_Final_Deadline__c){
            lstEngVPRecNew.add(egVpRec);
           // }
        }
        }
        else{
        lstEngVPRecNew.addAll(lstEngVPRec);
        }
        system.debug('lstEngVPRecNew.....'+lstEngVPRecNew);
          for(Eng_Valuation_Period_Allocation__c egVpRec :[Select id,Week_Starting__c,Engagement_Valuation_Period__c  from Eng_Valuation_Period_Allocation__c where Engagement_Valuation_Period__c =:lstEngVPRecNew]){
           Set<Date> setStartDate= new Set<Date>();
           if(mapDupCheck!=null && mapDupCheck.get(egVpRec.Engagement_Valuation_Period__c)!=null){
            setStartDate=mapDupCheck.get(egVpRec.Engagement_Valuation_Period__c);
             setStartDate.add(egVpRec.Week_Starting__c);
            mapDupCheck.put(egVpRec.Engagement_Valuation_Period__c,setStartDate);
            }
            else{
            
            setStartDate.add(egVpRec.Week_Starting__c);
            mapDupCheck.put(egVpRec.Engagement_Valuation_Period__c,setStartDate);
            }
        }
        for(Eng_VP__c egVpRec : lstEngVPRecNew){
                  if(egVpRec.Client_Final_Deadline__c != null){
                 Date cliendDateWeekStart = egVpRec.Client_Final_Deadline__c.toStartofWeek();
                 Date ClientWeekEnd = cliendDateWeekStart.addDays(6);
                 system.debug('egVpRec.ClientStartDate__c.....'+egVpRec.ClientStartDate__c);
            List<Date> lstOfWeekStartDates = GetEngVPAllocatioNStartDate(egVpRec.Client_Final_Deadline__c,egVpRec.ClientStartDate__c);
             Set<Date> startdateSet= new Set<Date>();
             if( mapDupCheck.get(egVpRec.Id)!=null){
             startdateSet= mapDupCheck.get(egVpRec.Id);
             }
            system.debug('startdateSet....'+startdateSet);
            for(Date d : lstOfWeekStartDates){
                    Decimal adminAllocation;
                    Decimal analystAllocation;
                    Decimal associateAllocation;
                      if(startdateSet!=null && !startdateSet.contains(d)){
                    engVPAllocToInsert.add(new Eng_Valuation_Period_Allocation__c(Engagement_Valuation_Period__c = egVpRec.Id,
                                                                   Week_Starting__c = d,
                                                                   Week_Ending__c = d.addDays(6)));
                                                                   startdateSet.add(d);
                                                                   }
            }
            //Add the last week of the Client Final Deadline Added on 03/23/2021
           
            if(startdateSet!=null && !startdateSet.contains(cliendDateWeekStart)){
            engVPAllocToInsert.add(new Eng_Valuation_Period_Allocation__c(Engagement_Valuation_Period__c = egVpRec.Id,
                                                                   Week_Starting__c = cliendDateWeekStart,
                                                                   Week_Ending__c = ClientWeekEnd));}
                                                                  
            }

        }
        system.debug('engVPAllocToInsert....'+engVPAllocToInsert);
        if(!engVPAllocToInsert.isEmpty()){
           // Database.insert(engVPAllocToInsert, false);
           insert engVPAllocToInsert;
        }
    } 
     
    /* Added Date : March 10, 2021
        Logic to Get the Start of the Week Date upt to the Client_Final_Deadline__c */
    public static List<Date> GetEngVPAllocatioNStartDate(Date clDeadlineDate,Date clcreatelineDate){
        List<Date> dateList = new List<Date>();
        
        if(clcreatelineDate==null){
        clcreatelineDate=Date.today();
        }
        Date clientDate = clDeadlineDate;
        Date weekStart = clcreatelineDate.toStartofWeek();
        Date weekEnd = weekStart.addDays(6);
        Date cliendDateWeekStart = clientDate.toStartofWeek();
        Date ClientWeekEnd = cliendDateWeekStart.addDays(6);
        Integer x = weekStart.daysBetween(cliendDateWeekStart);
        Integer totalWeeksBetweenDates = x/7;
        for(Integer i = 0; i < totalWeeksBetweenDates; i++){
            System.debug('I is: ' + i);
            if(dateList.isEmpty()){
                dateList.add(weekStart);
               // dateList.add(cliendDateWeekStart);
            } else {
                Date dd = dateList[i-1];
                dateList.add(dd.addDays(7));
            }
        }
        System.debug('Date List to Return is  ' + dateList);
        return dateList;
    }
}