public without sharing class HL_Eng_VP_PositionTriggerHelper {
    
    private static Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    private static boolean IsInvalidUser ;

    public static void beforeInsert(List<Eng_VP_Position__c> newEengVPPositionList, Map<Id, Eng_VP_Position__c> newEengVPPositionMap, List<Eng_VP_Position__c> oldEengVPPositionList , Map<Id, Eng_VP_Position__c> oldEengVPPositionMap) {
        // Commented code by Sandeep SF-820
        // To avoid duplicate position based on company reference under same Eng VP
         changeOwnershipToSystemAdmin(newEengVPPositionList);
        //Updated code by Sandeep SF-820
        if(!HL_ConstantsUtil.stopExecutionForPVConversion){ 
            EngVPPositionDuplicateCheck(newEengVPPositionList);         
        }
        // SF-832 by Sandeep Singhal to populate Generate Accrual on position if status is Generate while PV conversion to avoid validation
        if(HL_ConstantsUtil.stopExecutionForPVConversion) 
            PopulateGenerateAccrualInConversion(newEengVPPositionList); 
        
    }
    
    public static void afterInsert(List<Eng_VP_Position__c> newEengVPPositionList, Map<Id, Eng_VP_Position__c> newEengVPPositionMap, List<Eng_VP_Position__c> oldEengVPPositionList , Map<Id, Eng_VP_Position__c> oldEengVPPositionMap) { 
        
        // list of positions needs to be updated for Name field from VP's company Name
        List<Eng_VP_Position__c> positionsToUpdateFinallyList = new List<Eng_VP_Position__c>();
        if(!HL_ConstantsUtil.stopCopyingNameFromCompToPosition && !HL_ConstantsUtil.stopExecutionForPVConversion){
            positionsToUpdateFinallyList = PopulatingPositionName(newEengVPPositionList);     
            if (positionsToUpdateFinallyList.size() > 0){
                update positionsToUpdateFinallyList;
            } 
        }
        // To roll up status on VP record based on position's status while inserting positions
        if(!HL_ConstantsUtil.stopExecutionForPVConversion)
            CalculateRollupOnEngVP('AfterInsert',newEengVPPositionList,newEengVPPositionMap,null,null);
        
        // To roll up Has Position on Account record based on position's status while inserting positions
        if(!HL_ConstantsUtil.stopExecutionForPVConversion)
            CalculateRollupOnAccount('AfterInsert',newEengVPPositionList,newEengVPPositionMap,null,null);
        
        // To setup sharing for position records with requested accesslevel in SF-191 
        // Commented code by Sandeep SF-820
        //SetupSharingforEngVpPosition(newEengVPPositionList);
        
        // Method to update Company if its Industry Group is blank
        CompanyWithoutIndustryGroup(newEengVPPositionList);
    }
    
    public static void beforeUpdate(List<Eng_VP_Position__c> newEengVPPositionList, Map<Id, Eng_VP_Position__c> newEengVPPositionMap, List<Eng_VP_Position__c> oldEengVPPositionList , Map<Id, Eng_VP_Position__c> oldEengVPPositionMap) {
        // This method also copy Report Fee in to Fee Completed field for SF-832 for update
        CopyReportFeeInFeeCompleted(newEengVPPositionList); 
        // To avoid duplicate position based on company reference under same Eng VP
        if(!HL_ConstantsUtil.stopExecutionForPVConversion){
            EngVPPositionDuplicateCheck(newEengVPPositionList);
            Monthly_Revenue_Process_Control__c  MRPC = new Monthly_Revenue_Process_Control__c();
            MRPC = fetchMRPC();         
            // To Generate Revenue Accrual for Eng VP Position SF-832
            generateRevenueAccrualList(newEengVPPositionList, 'BeforeUpdate', MRPC);
        }
        
        // To check if industry group and setor is populated on position to mark it completed
        CheckIGSinImportedPosition(newEengVPPositionList,oldEengVPPositionMap); 
    }
    
    public static void afterUpdate(List<Eng_VP_Position__c> newEengVPPositionList, Map<Id, Eng_VP_Position__c> newEengVPPositionMap, List<Eng_VP_Position__c> oldEengVPPositionList , Map<Id, Eng_VP_Position__c> oldEengVPPositionMap) {
        // To roll up status on VP record based on position's status while inserting positions
        if(!HL_ConstantsUtil.stopExecutionForPVConversion)
            CalculateRollupOnEngVP('AfterUpdate',newEengVPPositionList,newEengVPPositionMap,oldEengVPPositionList,oldEengVPPositionMap);
        
        // To roll up Has Position on Account record based on position's status while inserting positions
        if(!HL_ConstantsUtil.stopExecutionForPVConversion)
            CalculateRollupOnAccount('AfterUpdate',newEengVPPositionList,newEengVPPositionMap,oldEengVPPositionList,oldEengVPPositionMap);
        
        // To Populate End Date on Team member if Position's status is going to be set to 'Completed'
        if(!HL_ConstantsUtil.stopExecutionForPVConversion)
            UpdateRelatedTeamMembers('AfterUpdate',newEengVPPositionList,newEengVPPositionMap,oldEengVPPositionList,oldEengVPPositionMap);
        
        // Method to update Company if its Industry Group is blank
        CompanyWithoutIndustryGroup(newEengVPPositionList);
        
        UpdateLastModifiedDateOnEngVP('AfterUpdate',newEengVPPositionList,newEengVPPositionMap,oldEengVPPositionList,oldEengVPPositionMap);
    }
    
    public static void beforeDelete(List<Eng_VP_Position__c> newEengVPPositionList, Map<Id, Eng_VP_Position__c> newEengVPPositionMap, List<Eng_VP_Position__c> oldEengVPPositionList , Map<Id, Eng_VP_Position__c> oldEengVPPositionMap) {
        IsInvalidUser = True;
        User u = [Select Id, Profile.Name From User Where Id = : UserInfo.getUserId()];
        for(Delete_CanceledPositionSetting__mdt cmd : [Select Profile_Name__c,User_ID__c,Security_Type__c  From     Delete_CanceledPositionSetting__mdt])
        {
            if(cmd.Security_Type__c == 'Profile Name')
            {
                if(cmd.Profile_Name__c == u.Profile.Name)
                {
                    IsInvalidUser = False;
                    break;
                }
            }
            
            if(IsInvalidUser && cmd.Security_Type__c == 'User ID')
            {
                If(cmd.User_ID__c == userinfo.getUserId().substring(0,15))
                {   
                    IsInvalidUser = False;
                    break;
                }
            }                
        }
        
        if(!HL_ConstantsUtil.IsSupervisorOrAdmin() && oldEengVPPositionList  != null && oldEengVPPositionList .size() > 0 ) {
            oldEengVPPositionList [0].addError(Label.HL_No_Delete_Privilige_VP_Position);
            
        }
        if(!HL_ConstantsUtil.stopExecutionForPVConversion){
            StopDeletion(oldEengVPPositionList);
        }
    }
    
    public static void afterDelete(List<Eng_VP_Position__c> newEengVPPositionList, Map<Id, Eng_VP_Position__c> newEengVPPositionMap, List<Eng_VP_Position__c> oldEengVPPositionList , Map<Id, Eng_VP_Position__c> oldEengVPPositionMap) {
        // Updated by Sandeep SF-820
        if(!HL_ConstantsUtil.stopExecutionForPVConversion){
            CalculateRollupOnEngVP('AfterDelete',null,null,oldEengVPPositionList,oldEengVPPositionMap);
            CalculateRollupOnAccount('AfterDelete',null,null,oldEengVPPositionList,oldEengVPPositionMap);
        }
    }
    
    // Method to populate Name field of positions from their VP's company Name
    private static List<Eng_VP_Position__c> PopulatingPositionName( List<Eng_VP_Position__c> newEengVPPositionList){
        List<Eng_VP_Position__c> positionsToUpdateList = new List<Eng_VP_Position__c>();  
        for(Eng_VP_Position__c engVPPos : [SELECT Id,Name, Company__r.Name 
                                           FROM Eng_VP_Position__c 
                                           WHERE Id IN : newEengVPPositionList]) {
            // To avoid this update where position is going to be created with mentioning Name specifically
            If(engVPPos.Id != null && String.valueof(engVPPos.Id).length() == 18)
                if(engVPPos.Name == String.valueof(engVPPos.Id).subString(0,15)) {
                    engVPPos.Name = engVPPos.Company__r.Name ;
                    positionsToUpdateList.add(engVPPos);
                }
            } 
        return positionsToUpdateList;     
    }
    // Method to populate Name Last Modified field of Engagement Valuation Period from their Eng Valuation Period Position Completed Date
    private static void UpdateLastModifiedDateOnEngVP(String eventType, List<Eng_VP_Position__c> newEengVPPositionList, Map<Id, Eng_VP_Position__c> newEengVPPositionMap, List<Eng_VP_Position__c> oldEengVPPositionList , Map<Id, Eng_VP_Position__c> oldEengVPPositionMap){
    Set<Id> engVPIds = new Set<Id>();
    if (eventType == 'AfterUpdate') {
      for(Eng_VP_Position__c newVPPos : newEengVPPositionList) {
       if(oldEengVPPositionMap.get(newVPPos.id).Completed_Date__c!=newVPPos.Completed_Date__c){
          engVPIds.add(newVPPos.Engagement_VP__c);
       }
      }
    }
    Map<Id,Eng_VP__c> mapEngVpToUpdate = new Map<Id,Eng_VP__c>([Select Id,Last_Position_Completed_Date__c from Eng_VP__c where Id IN:engVPIds]);
    for(Eng_VP_Position__c newVPPos : newEengVPPositionList) {
     if(newVPPos.Completed_Date__c!=null && mapEngVpToUpdate!=null && mapEngVpToUpdate.get(newVPPos.Engagement_VP__c)!=null){
         Eng_VP__c enfVP =mapEngVpToUpdate.get(newVPPos.Engagement_VP__c);
         enfVP.Last_Position_Completed_Date__c =newVPPos.Completed_Date__c; 
         mapEngVpToUpdate.put(newVPPos.Engagement_VP__c,enfVP);
     }
    }
    if(mapEngVpToUpdate!=null && !mapEngVpToUpdate.isEmpty())
     update mapEngVpToUpdate.values();
   }
    // Method to populate Name field of positions from their VP's company Name
    private static void CalculateRollupOnEngVP(String eventType, List<Eng_VP_Position__c> newEengVPPositionList, Map<Id, Eng_VP_Position__c> newEengVPPositionMap, List<Eng_VP_Position__c> oldEengVPPositionList , Map<Id, Eng_VP_Position__c> oldEengVPPositionMap){
        // to stop running rollup logic on VP level again
        HL_ConstantsUtil.stopUpdatingPVValueStatusChange = true;
        List<Id> EngVPToProcess = new List<Id>();
        if (eventType == 'AfterInsert') {
            for(Eng_VP_Position__c pos : newEengVPPositionList)
                EngVPToProcess.add(pos.Engagement_VP__c);
        }
        else if (eventType == 'AfterUpdate') {
            for(Eng_VP_Position__c newVPPos : newEengVPPositionList) {
                if(newVPPos.Status__c != oldEengVPPositionMap.get(newVPPos.id).Status__c){
                    EngVPToProcess.add(newVPPos.Engagement_VP__c);  
                }
                if(newVPPos.Report_Fee__c != oldEengVPPositionMap.get(newVPPos.id).Report_Fee__c){
                    EngVPToProcess.add(newVPPos.Engagement_VP__c);  
                }
            }           
        }
        else if(eventType == 'AfterDelete') {
            for(Eng_VP_Position__c pos : oldEengVPPositionList)
                EngVPToProcess.add(pos.Engagement_VP__c);
        }
        
        List<Eng_VP__c> engVPToUpdateList = new List<Eng_VP__c>(); 
        Map<Id,List<Eng_VP_Position__c>> vpToPositionMap = new Map<Id,List<Eng_VP_Position__c>>();
        List<Eng_VP__c> vpList = new List<Eng_VP__c>([SELECT id, overall_VP_Status__c, Fee_Total__c FROM Eng_VP__c WHERE Id IN :EngVPToProcess]);
        Set<Id> vpIdSet = new Set<Id>();
        for(Eng_VP__c vp : vpList){
            vpIdSet.add(vp.Id);
        }
        for(Eng_VP_Position__c vpPosition : [SELECT Id,Status__c,Report_Fee__c,Engagement_VP__c FROM Eng_VP_Position__c WHERE Engagement_VP__c in :vpIdSet]){
            if(!vpToPositionMap.containsKey(vpPosition.Engagement_VP__c)){
                vpToPositionMap.put(vpPosition.Engagement_VP__c, new List<Eng_VP_Position__c>());
            }
            vpToPositionMap.get(vpPosition.Engagement_VP__c).add(vpPosition);
        }
        for(Eng_VP__c engVP : vpList){            
            if(!vpToPositionMap.containsKey(engVP.Id) || vpToPositionMap.get(engVP.Id).isEmpty()) {
                engVP.overall_VP_Status__c = 'New';   
                engVP.Fee_Total__c = 0.0;       
                engVPToUpdateList.add(engVP);
            }
            else {
                boolean VPInProgress = true;    
                boolean isSingleCompleted = false;
                boolean isSingleProgress = false;
                decimal tempTotal = 0.0;
                for(Eng_VP_Position__c engVPPos : vpToPositionMap.get(engVP.Id)) {
                    if(engVPPos.Status__c == System.Label.HL_Eng_VP_Status_Completed){
                        isSingleCompleted = true;
                    } 
                    if(engVPPos.Status__c == 'In Progress' ){
                        isSingleProgress = true;
                    }                   
                    if(engVPPos.Status__c != 'Cancelled'){
                        tempTotal += (engVPPos.Report_Fee__c != null ? engVPPos.Report_Fee__c : 0);
                    } 
                }
                
                engVP.Fee_Total__c = tempTotal;
                string StatusTobeUpdated;
                if(isSingleCompleted && !isSingleProgress)
                    StatusTobeUpdated = 'Completed';                                                            
                else
                    StatusTobeUpdated = 'In Progress' ;
                
                if(engVP.overall_VP_Status__c != StatusTobeUpdated ||engVP.Fee_Total__c != null) {
                    engVP.overall_VP_Status__c = StatusTobeUpdated;
                    engVPToUpdateList.add(engVP);  
                }
            }
        }
        
        if(engVPToUpdateList.size() > 0 )
            update engVPToUpdateList;
    }
    
    // Method to populate Name field of positions from their VP's company Name
    private static void CalculateRollupOnAccount(String eventType, List<Eng_VP_Position__c> newEengVPPositionList, Map<Id, Eng_VP_Position__c> newEengVPPositionMap, List<Eng_VP_Position__c> oldEengVPPositionList , Map<Id, Eng_VP_Position__c> oldEengVPPositionMap){
        List<Id> EngAccountToProcess = new List<Id>();
        if (eventType == 'AfterInsert') {
            for(Eng_VP_Position__c pos : newEengVPPositionList)
                EngAccountToProcess.add(pos.Company__c);
        }
        else if (eventType == 'AfterUpdate') {
            for(Eng_VP_Position__c newVPPos : newEengVPPositionList) {
                if(newVPPos.Company__c != oldEengVPPositionMap.get(newVPPos.id).Company__c){
                    EngAccountToProcess.add(newVPPos.Company__c);  
                    EngAccountToProcess.add(oldEengVPPositionMap.get(newVPPos.id).Company__c);
                }           
            }           
        }
        else if(eventType == 'AfterDelete') {
            for(Eng_VP_Position__c pos : oldEengVPPositionList)
                EngAccountToProcess.add(pos.Company__c);
        }
        
        List<Account> AccountToUpdateList = new List<Account>(); 
        List<Account> AccountToUpdateList1 = new List<Account>();
        AccountToUpdateList1  = [SELECT id,Has_Position__c, (select id from Eng_PV_Positions__r) 
                           FROM Account 
                           WHERE ID IN : EngAccountToProcess];
        for(Account acc : AccountToUpdateList1  ){
            if(acc.Eng_PV_Positions__r.size() == 0) {
                acc.Has_Position__c = false;       
                AccountToUpdateList.add(acc);                 
            }
            else if(acc.Eng_PV_Positions__r.size() > 0) {
                 acc.Has_Position__c = true;       
                 AccountToUpdateList.add(acc);
            }
        }       
        if(AccountToUpdateList.size() > 0 )
            update AccountToUpdateList;
    }
    // To keep Fee Completed in sync with Report Fee if status is completed. 
    private static void CopyReportFeeInFeeCompleted(List<Eng_VP_Position__c> newEengVPPositionList){
        for (Eng_VP_Position__c egVPPObj: newEengVPPositionList){                
             if(egVPPObj.Name == '' || egVPPObj.Name == null) {
                   egVPPObj.addError(label.HL_Name_Required);                                      
             }
             if(egVPPObj.Status__c == null) {
                   egVPPObj.addError(Label.HL_Position_status_Is_Required);                                      
             }             
             if(egVPPObj.status__c == System.Label.HL_Eng_VP_Status_Completed)
                 egVPPObj.Fee_Completed__c = egVPPObj.Report_Fee__c; 
        }
    }
    // Method to populate Generate Accrual on position if status is Generate while PV conversion to avoid validation
    private static void PopulateGenerateAccrualInConversion(List<Eng_VP_Position__c> newEengVPPositionList){
        for (Eng_VP_Position__c egVPPObj: newEengVPPositionList) {
            //if(egVPPObj.Status__c == System.Label.HL_Eng_VP_Status_Completed)
                //egVPPObj.Generate_Accrual__c  = 'Yes'; 
        }
    }
    // Method to avoid position creation/updation if it introduce with duplicate company reference under same VP
    private static void EngVPPositionDuplicateCheck(List<Eng_VP_Position__c> newEengVPPositionList){
        
        // Set of related Eng VP Id
        Set <String> engVpofProcessedPositionSet = new Set < String > ();
        // Set of matching criteria (it is generic so it can be modified easily if criteria gets changed)
        Set<String> matchingStringSet = new Set<String>(); 
        // Map of criteria and object instance to apply addError 
        Map<String, Eng_VP_Position__c> ProcessedPositionMap = new Map<String, Eng_VP_Position__c>(); 
        
        for (Eng_VP_Position__c egVPPObj: newEengVPPositionList) {
            if(Trigger.IsInsert)
                if(egVPPObj.Status__c == System.Label.HL_Eng_VP_Status_Completed || egVPPObj.Status__c == 'Cancelled' )
                {
                    egVPPObj.addError(System.Label.HL_Status_Not_Allowed_On_On_Created_Position);
                }
            if(!(trigger.isUpdate && ((Eng_VP_Position__c )Trigger.oldMap.get(egVPPObj.Id)).Engagement_VP__c != null && egVPPObj.Engagement_VP__c != ((Eng_VP_Position__c )Trigger.oldMap.get(egVPPObj.Id)).Engagement_VP__c)) {
                engVpofProcessedPositionSet.add(egVPPObj.Engagement_VP__c);
                matchingStringSet.add(egVPPObj.Engagement_VP__c+'-'+egVPPObj.Company__c+'-'+egVPPObj.Asset_Classes__c);
                ProcessedPositionMap.put(egVPPObj.Engagement_VP__c+'-'+egVPPObj.Company__c+'-'+egVPPObj.Asset_Classes__c,egVPPObj);
            }
        }
       
        String matchingString ='';
        for(Eng_VP_Position__c filteredPosition :  [SELECT Id, Company__c, Asset_Classes__c, Engagement_VP__c 
                                                    FROM  Eng_VP_Position__c
                                                    WHERE Status__c != 'Cancelled' AND Engagement_VP__c IN : engVpofProcessedPositionSet AND Id NOT IN: newEengVPPositionList]) {
            matchingString = filteredPosition.Engagement_VP__c+'-'+filteredPosition.Company__c+'-'+filteredPosition.Asset_Classes__c;
            if(!matchingStringSet.contains(matchingString)) {
                matchingStringSet.add(matchingString);
            }               
            else {
                if(ProcessedPositionMap.containsKey(matchingString))
                    ProcessedPositionMap.get(matchingString).addError(System.Label.DuplicateVP);
            }
        }
    }
    
    private static void UpdateRelatedTeamMembers(String eventType, List<Eng_VP_Position__c> newEengVPPositionList, Map<Id, Eng_VP_Position__c> newEengVPPositionMap, List<Eng_VP_Position__c> oldEengVPPositionList , Map<Id, Eng_VP_Position__c> oldEengVPPositionMap){
        
        Set<Id> filteredPositions = new Set<Id>();
        List<Eng_VP_TeamMember__c> engVpTeamMemberToUpdateList = new List<Eng_VP_TeamMember__c>();
        List<Eng_VP_TeamMember__c> engVPTeamMembersToDeleteList = new List<Eng_VP_TeamMember__c>();
        if (eventType == 'AfterUpdate') {
            for(Eng_VP_Position__c newVPPos : newEengVPPositionList) {
                if(newVPPos.Status__c != oldEengVPPositionMap.get(newVPPos.id).Status__c && (newVPPos.Status__c == System.Label.HL_Eng_VP_Status_Completed || newVPPos.Status__c == 'Cancelled')){
                    filteredPositions.add(newVPPos.Id);  
                }           
            }    
            
            for(Eng_VP_TeamMember__c engVpTeamMember : [SELECT Id, Start_Date__c, End_Date__c 
                                                        FROM Eng_VP_TeamMember__c
                                                        WHERE /*End_Date__c = Null AND*/ Engagement_VP_Position__c IN : filteredPositions]) 
            {
                if (engVpTeamMember.End_Date__c == null || engVpTeamMember.End_Date__c >= date.Today())
                    engVpTeamMember.End_Date__c  = date.Today();                
                if(engVpTeamMember.Start_Date__c <= engVpTeamMember.End_Date__c)
                    {
                        engVpTeamMemberToUpdateList.add(engVpTeamMember);  
                    }
                    else {
                        engVPTeamMembersToDeleteList.add(engVpTeamMember);  
                    }                
            }  
            
            if(engVpTeamMemberToUpdateList.size() > 0) 
            {
                update engVpTeamMemberToUpdateList;
            }
                
            // Deleting those Eng position team members who are going to have start date after end date which should not be valid case
            if(engVPTeamMembersToDeleteList.size() > 0)
            {
                delete engVPTeamMembersToDeleteList; 
            }                
        }
    }
   
    // To stop user to delete any thing on Position if revenue month/year has been passed or if it is cancelled no matter revenue month/year is passed or not
    public static void StopDeletion(List<Eng_VP_Position__c> oldEengVPPositionList) {
        
        Monthly_Revenue_Process_Control__c  MRPC = new Monthly_Revenue_Process_Control__c();
        MRPC = fetchMRPC();     
        for(Eng_VP_Position__c egVPPObj : oldEengVPPositionList)
        {   
            // To stop Deleting position if Fee completed is filled and enagagement stage is closed
            if(egVPPObj.Fee_Completed__c != null && egVPPObj.Engagement_Stage__c == 'Closed')
            {
                if(egVPPObj.Fee_Completed__c != 0 &&  egVPPObj.Status__c == 'Completed, Generate Accrual')
                    egVPPObj.adderror(System.Label.HL_PositionDel_On_ClosedEng);
            }
             // To stop Deleting position if Fee completed is filled and enagagement stage is Dead
            if(egVPPObj.Fee_Completed__c != null && egVPPObj.Engagement_Stage__c == 'Dead')
            {
                if(egVPPObj.Fee_Completed__c != 0 &&  egVPPObj.Status__c == 'Completed, Generate Accrual')
                    egVPPObj.adderror(System.Label.HL_PositionDel_On_DeadEng);
            }
            // To stop Deleting position if Fee completed is filled and Revenue Accrual is locked
            if(egVPPObj.Fee_Completed__c != null && IsReveneAccrualLocked())
            {
                egVPPObj.adderror(System.Label.HL_Revenue_Locked_Msg_forPositon);
            }
            if(MRPC == null)
                egVPPObj.addError(System.Label.HL_MRPC_Not_Exists); 
            else {
                if(egVPPObj.status__c == System.Label.HL_Eng_VP_Status_Completed && isRevenueMonthYearPassed(egVPPObj.Revenue_Month__c, egVPPObj.Revenue_Year__c,MRPC))
                    {
                        egVPPObj.adderror(System.Label.HL_VP_Position_Stop_Deletion);
                    }
                    // Related to 'DMND0023673' - to allow delete cancelled Position for selected userss and sys admin.
                else if(egVPPObj.status__c == 'Cancelled')
                    {
                        if(IsInvalidUser){   
                            egVPPObj.adderror(System.Label.HL_VP_Position_Stop_Delete_On_Cancelled);
                        }
                    }
            }
        }    
    }
    public static Monthly_Revenue_Process_Control__c fetchMRPC() {
        List<Monthly_Revenue_Process_Control__c> MRPCRecords = new List<Monthly_Revenue_Process_Control__c>();
        Monthly_Revenue_Process_Control__c  MRPC = new Monthly_Revenue_Process_Control__c();
        MRPCRecords = [Select Id, Current_Month__c, Current_Year__c FROM Monthly_Revenue_Process_Control__c WHERE IsCurrent__c = True Limit 1];
        if(MRPCRecords.size() == 1) 
            MRPC = MRPCRecords[0];
        else
            MRPC = null;
        return MRPC;
    }     
    
    public static boolean isRevenueMonthYearPassed(String revMonth, String revYear, Monthly_Revenue_Process_Control__c  MRPC ) {
        boolean isRevenueMonthYearPassed = false;
        Integer currentYear;
        Integer currentmonth;           
        if(MRPC.Current_Month__c != null)
            currentmonth= Integer.valueof(MRPC.Current_Month__c);
        if(MRPC.Current_Year__c != null)
            currentYear = Integer.valueof(MRPC.Current_Year__c);      
       
        if(revYear != '' && revYear != null && revMonth != '' && revMonth != Null && currentYear !=Null && currentmonth != Null){
            if(Integer.valueOf(revYear) < currentYear) 
            {               
                isRevenueMonthYearPassed = true;
            }
            else if(Integer.valueOf(revYear) == currentYear && Integer.valueOf(revMonth) < currentmonth) 
            {
                isRevenueMonthYearPassed = true;
            }            
        } 
        return isRevenueMonthYearPassed;  
    }
     
        private static void generateRevenueAccrualList(list<Eng_VP_Position__c> newEengVPPositionList, String eventType,Monthly_Revenue_Process_Control__c  MRPC ){
            Id Position_Cancelled_RT_Id = Schema.SObjectType.Eng_VP_Position__c.getRecordTypeInfosByName().get('Cancelled').getRecordTypeId();
            Boolean IsAdminorSupervisor = IsAdminorPVSupervisor();    
            Boolean IsFieldsetFieldUpdated = true;
            List<Schema.FieldSetMember> fields = Schema.SObjectType.Eng_VP_Position__c.fieldSets.getMap().get('HL_PositionEditable').getFields();
            List<string> lstFieldstoUpdate = new List<String>();
            for(Schema.FieldSetMember fieldSetMemberObj : fields){
                lstFieldstoUpdate.add(fieldSetMemberObj.getFieldPath());
            }

            for (Eng_VP_Position__c egVPPObj: newEengVPPositionList)
            {
                if(MRPC == null){
                     if(((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Status__c != egVPPObj.Status__c){
                         egVPPObj.addError(System.Label.HL_MRPC_Not_Exists);
                    }
                }
                else {
                                                                  
                    // Generate Accrual 
                    if(egVPPObj.Status__c == System.Label.HL_Eng_VP_Status_Completed) {
                        if(egVPPObj.Status__c != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Status__c) {
                           
                            if(((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Status__c == 'In Progress'){
                                
                                if(PortfolioValuationConfig__c.getOrgDefaults() != null && PortfolioValuationConfig__c.getOrgDefaults().Lock_Rollup__c)
                                {
                                    egVPPObj.Revenue_Year__c    = PortfolioValuationConfig__c.getOrgDefaults().Revenue_Year__c;
                                    egVPPObj.Revenue_Month__c   = PortfolioValuationConfig__c.getOrgDefaults().Revenue_Month__c;
                                    egVPPObj.Completed_Date__c  = DateTime.newInstance(Integer.valueOf(PortfolioValuationConfig__c.getOrgDefaults().Revenue_Year__c), Integer.ValueOf(PortfolioValuationConfig__c.getOrgDefaults().Revenue_Month__c), Integer.valueOf(PortfolioValuationConfig__c.getOrgDefaults().Completion_Day__c), 00, 00, 00);
                                    egVPPObj.Fee_Completed__c = egVPPObj.Report_Fee__c;
                                    egVPPObj.Cancel_Month__c  = '';
                                    egVPPObj.Cancel_Year__c  = '';
                                    egVPPObj.Cancel_Date__c  = null;
                                }
                                else{
                                    egVPPObj.Revenue_Year__c    = MRPC.Current_Year__c;
                                    egVPPObj.Revenue_Month__c   = MRPC.Current_Month__c;
                                    egVPPObj.Completed_Date__c  = system.now();
                                    egVPPObj.Fee_Completed__c = egVPPObj.Report_Fee__c;
                                    egVPPObj.Cancel_Month__c  = '';
                                    egVPPObj.Cancel_Year__c  = '';
                                    egVPPObj.Cancel_Date__c  = null;
                                }
                            }
                            // To stop user to modify any thing on cancelled Position no matter revenue month/year has been passed or not
                            else if(((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Status__c == 'Cancelled' && !(((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Is_By_Pass_Error_On_Edit_AfterComplete__c != egVPPObj.Is_By_Pass_Error_On_Edit_AfterComplete__c) 
                                    )
                            {
                                egVPPObj.addError(System.Label.HL_VP_Position_Stop_Edit_On_Cancelled);
                            }
                        }
                        // To stop user to modify any thing on Position if revenue month/year has been passed
                        else {

                            // added for ticket :- PRJ0016466; if 'IsFieldsetFieldUpdated' is false that means fields(other than fieldset) are modified on position
                            IsFieldsetFieldUpdated = validateNonRevenueFieldsChanges(egVPPObj,lstFieldstoUpdate);
                                                
                            
                            if(isRevenueMonthYearPassed(egVPPObj.Revenue_Month__c, egVPPObj.Revenue_Year__c, MRPC) && !(isSuperUserOrSysAdmin() && IsFieldsetFieldUpdated )){
                               if(!(egVPPObj.currencyIsoCode != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).currencyIsoCode) && !(((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Is_By_Pass_Error_On_Edit_AfterComplete__c != egVPPObj.Is_By_Pass_Error_On_Edit_AfterComplete__c))
                                        
                                    egVPPObj.addError(System.Label.HL_VP_Position_Stop_Edit);
                                
                            }                     
                            else{
                                if(!(egVPPObj.currencyIsoCode != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).currencyIsoCode)){
                                    if(egVPPObj.Cancel_Date__c != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Cancel_Date__c)
                                        egVPPObj.addError('You can not change Cancel Date manually.' );
                                    if(egVPPObj.Cancel_Month__c != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Cancel_Month__c)
                                        egVPPObj.addError('You can not change Cancel Month manually.' );
                                    if(egVPPObj.Cancel_Year__c != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Cancel_Year__c)
                                        egVPPObj.addError('You can not change Cancel Year manually.' );
                                    if(egVPPObj.Completed_Date__c != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Completed_Date__c)
                                        egVPPObj.addError('You can not change Completed Date manually.' );
                                    if(egVPPObj.Revenue_Month__c != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Revenue_Month__c)
                                        egVPPObj.addError('You can not change Revenue Month manually.' );
                                    if(egVPPObj.Revenue_Year__c != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Revenue_Year__c)
                                        egVPPObj.addError('You can not change Revenue Year manually.' );
                                    if(egVPPObj.Fee_Completed__c != egVPPObj.Report_Fee__c){    
                                        if(egVPPObj.Fee_Completed__c != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Fee_Completed__c)
                                            egVPPObj.addError('You can not change Fee Completed manually.' );
                                    }    
                                }
                            }
                        }
                    }                
                    // Cancellation Accrual 
                    else if(egVPPObj.Status__c == 'Cancelled') {
                        if(egVPPObj.Status__c != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Status__c){
                            
                            if(HL_ConstantsUtil.ToStopChangesStatusToCancelled )
                            {
                                egVPPObj.addError(System.Label.HL_Status_Changed_NotAllowed_ToCancelled);
                            }
                            else{
                                egVPPObj.RecordTypeId    =  Position_Cancelled_RT_Id;
                                egVPPObj.Revenue_Year__c    = '';
                                egVPPObj.Revenue_Month__c   = '';
                                egVPPObj.Completed_Date__c  = null;
                                egVPPObj.Fee_Completed__c  = 0;
                                egVPPObj.Cancel_Year__c     = MRPC.Current_Year__c;
                                egVPPObj.Cancel_Month__c    = MRPC.Current_Month__c;
                                egVPPObj.Cancel_Date__c     = system.now();
                            }
                        }
                        else
                        {
                            
                            if(!(egVPPObj.currencyIsoCode != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).currencyIsoCode))
                                egVPPObj.addError(System.Label.HL_VP_Position_Stop_Edit_On_Cancelled);
                        }
                    }
                    
                    // Reverting Status to 'In Progress' if revenue month/year has not been passed
                    else if(egVPPObj.Status__c == 'In Progress') {
                        
                            
                        if(egVPPObj.Status__c != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Status__c){
                            
                                
                            if(((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Status__c == System.Label.HL_Eng_VP_Status_Completed && isRevenueMonthYearPassed(egVPPObj.Revenue_Month__c, egVPPObj.Revenue_Year__c, MRPC)){
                                egVPPObj.addError(System.Label.HL_VP_Position_Stop_Edit);
                            }
                            else {
                                egVPPObj.Revenue_Year__c    = '';
                                egVPPObj.Revenue_Month__c   = '';
                                egVPPObj.Completed_Date__c  = null;
                                egVPPObj.Fee_Completed__c  = 0;
                                egVPPObj.Cancel_Month__c  = '';
                                egVPPObj.Cancel_Year__c  = '';
                                egVPPObj.Cancel_Date__c  = null;                    
                                
                            }
                            
                        }
                        else
                        {
                            if(!(egVPPObj.currencyIsoCode != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).currencyIsoCode)){
                                if(egVPPObj.Cancel_Date__c != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Cancel_Date__c)
                                    egVPPObj.addError('You can not change Cancel Date manually.' );
                                if(egVPPObj.Cancel_Month__c != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Cancel_Month__c)
                                    egVPPObj.addError('You can not change Cancel Month manually.' );
                                if(egVPPObj.Cancel_Year__c != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Cancel_Year__c)
                                    egVPPObj.addError('You can not change Cancel Year manually.' );
                                if(egVPPObj.Completed_Date__c != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Completed_Date__c)
                                    egVPPObj.addError('You can not change Completed Date manually.' );
                                if(egVPPObj.Revenue_Month__c != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Revenue_Month__c)
                                    egVPPObj.addError('You can not change Revenue Month manually.' );
                                if(egVPPObj.Revenue_Year__c != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Revenue_Year__c)
                                    egVPPObj.addError('You can not change Revenue Year manually.' );
                                if(egVPPObj.Fee_Completed__c != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).Fee_Completed__c)
                                    egVPPObj.addError('You can not change Fee Completed manually.' );
                            }
                        }
                    } 
                }               
            }       
        }


        //Regarding ticket :- PRJ0016466 
        Private static boolean validateNonRevenueFieldsChanges(Eng_VP_Position__c egVPPObj, list<String> lstFieldstoUpdate){
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get('Eng_VP_Position__c').getDescribe().fields.getMap();
            Set<String> setPositionApi = new Set<String>();
            boolean tempIsValidFieldUpdated = true;
            for(Schema.SObjectField sfield : fieldMap.Values()){
                schema.describefieldresult dfield = sfield.getDescribe();
                String fieldname;
                fieldname = dfield.getname();
                setPositionApi.add(fieldname);
             }
            for(String eachField : lstFieldstoUpdate){
                if(setPositionApi.contains(eachField))
                    setPositionApi.remove(eachField);
            }
           for(String eachField : setPositionApi){
               if(egVPPObj.get(eachField) != ((Eng_VP_Position__c)Trigger.oldMap.get(egVPPObj.Id)).get(eachField)){
                  tempIsValidFieldUpdated = false;
                  break;
                 } 
            }
            return tempIsValidFieldUpdated;     
        }
        
        //To check if logged in user is super-user
        public static boolean isSuperUserOrSysAdmin() {
            boolean isSuperUserOrSysAdmin = false;
            for(PV_Super_User__mdt PVSuperUsers : [Select User_Id__c From PV_Super_User__mdt]){
               if(PVSuperUsers.User_Id__c.length()>= 15 && PVSuperUsers.User_Id__c.substring(0,15) == userInfo.getUserId().substring(0,15)){   
                    isSuperUserOrSysAdmin = true;
                    break;
                }
            }
            if(!isSuperUserOrSysAdmin){
                if(UserInfo.getProfileId().subString(0,15) == System.Label.HL_Sys_Admin_ProfId){
                    isSuperUserOrSysAdmin  = true;
                }
            }
            return isSuperUserOrSysAdmin;
        }
        
     // To change owner of Opp VP Position records to System Administrator 
    private static void changeOwnershipToSystemAdmin(list<Eng_VP_Position__c> newEngVPPositionList) {
        for(Eng_VP_Position__c engVPPosition : newEngVPPositionList)
        {
               //Commented code by Sandeep SF-820
               // engVPPosition.ownerId = Label.Salesforce_Administrator_ID;
                engVPPosition.CurrencyIsoCode = engVPPosition.Parent_Currency_Formula__c;
        }
    }
    
    public static boolean IsReveneAccrualLocked(){
        boolean IsReveneAccrualLocked = false;      
        if(HL_General__c.getOrgDefaults() != null && HL_General__c.getOrgDefaults().Revenue_Accrual_Locked__c && UserInfo.getProfileId().subString(0,15) != System.Label.HL_Accounting_User_ProfId && UserInfo.getProfileId().subString(0,15) != System.Label.HL_Sys_Admin_ProfId && UserInfo.getProfileId().subString(0,15)!=System.Label.HL_Standard_User_Template_ProfId)
        {
            IsReveneAccrualLocked  = true;    
        }
        system.debug('===IsReveneAccrualLocked  ===='+IsReveneAccrualLocked  );
        return IsReveneAccrualLocked ;
    }

    
    // Method to update Company record which don't have Industry Group
    private static void CompanyWithoutIndustryGroup( List<Eng_VP_Position__c> newEengVPPositionList){
        
        Map<Id,Eng_VP_Position__c> CompanyIndustryGroupMap = new Map<Id,Eng_VP_Position__c>(); 
        List<Account> CompanyToUpdate = new List<Account>();
        
        for(Eng_VP_Position__c engVPPos : [SELECT Id, Company__r.id, Industry_Group_Picklist__c,Sector__c, Company__r.Industry_Group__c 
                                           FROM Eng_VP_Position__c WHERE Id IN : newEengVPPositionList AND Industry_Group_Picklist__c != null AND Sector__c != null]) {
            if(engVPPos.Company__r.Industry_Group__c == null ){
                CompanyIndustryGroupMap.put(engVPPos.Company__r.id,engVPPos);
            }
        }   
        for(Account updateCompanyRecord : [SELECT Id, Industry_Group__c, Sector__c
                                           FROM Account WHERE Id IN : CompanyIndustryGroupMap.keySet()]){
            
            if(CompanyIndustryGroupMap.containsKey(updateCompanyRecord.Id)){
                updateCompanyRecord.Industry_Group__c = CompanyIndustryGroupMap.get(updateCompanyRecord.Id).Industry_Group_Picklist__c;
                updateCompanyRecord.Sector__c = CompanyIndustryGroupMap.get(updateCompanyRecord.Id).Sector__c;
            }
            CompanyToUpdate.add(updateCompanyRecord);
        }
        
        if(CompanyToUpdate.size() > 0){
            update CompanyToUpdate;
        }
    }
    
    
    // To check if industry group and setor is populated on position to mark it completed
    private static void CheckIGSinImportedPosition( List<Eng_VP_Position__c> newEengVPPositionList, Map<Id, Eng_VP_Position__c> oldEengVPPositionMap){
        
        for(Eng_VP_Position__c CurrentEVPP : newEengVPPositionList){
            if(CurrentEVPP.Status__c == 'Completed, Generate Accrual' && CurrentEVPP.Status__c != oldEengVPPositionMap.get(CurrentEVPP.id).Status__c && (CurrentEVPP.Industry_Group_Picklist__c == null || CurrentEVPP.Industry_Group_Picklist__c == '')){
                CurrentEVPP.addError(System.Label.HL_No_IG_S_on_Position);
            }
        }
    }
        
     public static Boolean IsAdminorPVSupervisor(){
    
        Boolean IsTrue = false;
        Boolean IsSystemAdministrator = false;
        Boolean isPVMember = false;
        String lblText = Label.HL_PVSupervisorGroupId;
        Id grpId = Id.valueOf(lblText);
        Set<Id> setUsersinGroup = new Set<Id>();
        
            if(UserInfo.getProfileId().subString(0,15) == System.Label.HL_Sys_Admin_ProfId){
                IsSystemAdministrator  = true;
            }
            HL_getMemberofGroups objGetMember = new HL_getMemberofGroups();
                setUsersinGroup = objGetMember.getAllPublicGroupUsers(grpId);
                
                if(setUsersinGroup.contains(UserInfo.getUserId())){
                    isPVMember = true;
                }
            if(isPVMember == true || IsSystemAdministrator == true){
                IsTrue = true;
            }
        
        return IsTrue;
    
    
    }

}