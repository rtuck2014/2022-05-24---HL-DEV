public without sharing class HL_Opp_VP_PositionTriggerHelper {
    
    public static void beforeInsert(List<Opp_VP_Position__c> newOoppVPPositionList, Map<Id, Opp_VP_Position__c> newOoppVPPositionMap, List<Opp_VP_Position__c> oldOoppVPPositionList , Map<Id, Opp_VP_Position__c> oldOoppVPPositionMap) {

        //To avoid duplicate position based on company reference under same Opp VP
        changeOwnershipToSystemAdmin(newOoppVPPositionList);
        OppVPPositionDuplicateCheck(newOoppVPPositionList); 
        
    }
    public static void beforeDelete(List<Opp_VP_Position__c> newOoppVPPositionList, Map<Id, Opp_VP_Position__c> newOoppVPPositionMap, List<Opp_VP_Position__c> oldOoppVPPositionList , Map<Id, Opp_VP_Position__c> oldOoppVPPositionMap) 
    {
      if(oldOoppVPPositionMap!= null && oldOoppVPPositionList != null)
          stopDeletion(oldOoppVPPositionMap,oldOoppVPPositionList );        
    }
    
    private static void stopDeletion(map<id, Opp_VP_Position__c> oldOoppVPMap, List<Opp_VP_Position__c> oldOoppVPPositionList ) {
        
        for(Opp_VP_Position__c opVp : [Select id,Opportunity_VP__r.Opportunity__r.Converted_to_Engagement__c,Opportunity_VP__r.Opportunity__r.Approval_Process__c,Opportunity_VP__r.Opportunity__r.Engagement_Approval_Status__c From Opp_VP_Position__c Where (Opportunity_VP__r.Opportunity__r.Converted_to_Engagement__c = true OR (Opportunity_VP__r.Opportunity__r.Approval_Process__c =: label.HL_AppProcessForEngNo AND Opportunity_VP__r.Opportunity__r.Engagement_Approval_Status__c=: label.HL_Pending_EngReqNo)) AND Id IN : oldOoppVPMap.KeySet()]) {
            if(opVP.Opportunity_VP__r.Opportunity__r.Converted_to_Engagement__c == true)
                oldOoppVPMap.get(opVp.Id).addError(Label.HL_Pos_Deleted_On_ConvtedOpp);
            if(opVp.Opportunity_VP__r.Opportunity__r.Approval_Process__c == label.HL_AppProcessForEngNo && opVp.Opportunity_VP__r.Opportunity__r.Engagement_Approval_Status__c == label.HL_Pending_EngReqNo)
                oldOoppVPMap.get(opVp.Id).addError(Label.HL_Pos_Deleted_ReqstedEngNo);
        }
        if(!HL_ConstantsUtil.IsSupervisorOrAdmin() && oldOoppVPMap != null && oldOoppVPMap.values() != null&& oldOoppVPMap.values().size() > 0 ) {
            oldOoppVPMap.values()[0].addError(Label.HL_No_Delete_Privilige_VP_Position);
        }
        for (Opp_VP_Position__c opVPPObj: oldOoppVPPositionList ) {
             if(opVPPObj.ResultingEngagemnetRTonVPP__c != 'Portfolio_Valuation' )  
               {
                   opVPPObj.addError(System.Label.HL_VP_Position_Stop_Create_Edit_Delete);
               }
        }      
    }
    
    public static void afterInsert(List<Opp_VP_Position__c> newOoppVPPositionList, Map<Id, Opp_VP_Position__c> newOoppVPPositionMap, List<Opp_VP_Position__c> oldOoppVPPositionList , Map<Id, Opp_VP_Position__c> oldOoppVPPositionMap) { 
        
        // list of positions needs to be updated for Name field from VP's company Name
        List<Opp_VP_Position__c> positionsToUpdateFinallyList = new List<Opp_VP_Position__c>();
        if(!HL_ConstantsUtil.stopCopyingNameFromCompToPosition){
            positionsToUpdateFinallyList = PopulatingPositionName(newOoppVPPositionList);     
            if (positionsToUpdateFinallyList.size() > 0){
                update positionsToUpdateFinallyList;
            }
         }
        
        // To roll up status on VP record based on position's status while inserting positions
        CalculateRollupOnOppVP('AfterInsert',newOoppVPPositionList,newOoppVPPositionMap,null,null);
        
        // To roll up Has Position on Account record based on position's status while inserting positions
        CalculateRollupOnAccount('AfterInsert',newOoppVPPositionList,newOoppVPPositionMap,null,null);
        // Commented code by Sandeep SF-820
        // To setup sharing for position records with requested accesslevel in SF-191 
        //SetupSharingforOppVpPosition(newOoppVPPositionList);
        
        // Method to update Company if its Industry Group is blank
        CompanyWithoutIndustryGroup(newOoppVPPositionList);
    }
    
    public static void beforeUpdate(List<Opp_VP_Position__c> newOoppVPPositionList, Map<Id, Opp_VP_Position__c> newOoppVPPositionMap, List<Opp_VP_Position__c> oldOoppVPPositionList , Map<Id, Opp_VP_Position__c> oldOoppVPPositionMap) {
        // To avoid duplicate position based on company reference under same Opp VP
        //OppVPPositionDuplicateCheck(newOoppVPPositionList);
        
        ValidatePosition(newOoppVPPositionList, 'BeforeUpdate');
    }
    
    private static void ValidatePosition(list<Opp_VP_Position__c> newOoppVPPositionList, String eventType){
        for (Opp_VP_Position__c OpVPObj: newOoppVPPositionList)
            {  
               if(OpVPObj.Name == '' || OpVPObj.Name == null) {
                   OpVPObj.addError(label.HL_Name_Required);                                      
               }
               if(OpVPObj.Status__c == null) {
                    OpVPObj.addError(System.Label.HL_Position_status_Is_Required);                                      
               }                                                 
            }       
    }
    
    public static void afterUpdate(List<Opp_VP_Position__c> newOoppVPPositionList, Map<Id, Opp_VP_Position__c> newOoppVPPositionMap, List<Opp_VP_Position__c> oldOoppVPPositionList , Map<Id, Opp_VP_Position__c> oldOoppVPPositionMap) {
        // To roll up status on VP record based on position's status while inserting positions
        CalculateRollupOnOppVP('AfterUpdate',newOoppVPPositionList,newOoppVPPositionMap,oldOoppVPPositionList,oldOoppVPPositionMap);
        
        // To roll up Has Position on Account record based on position's status while inserting positions
        CalculateRollupOnAccount('AfterUpdate',newOoppVPPositionList,newOoppVPPositionMap,oldOoppVPPositionList,oldOoppVPPositionMap);
        
        // To Populate End Date on Team member if Position's status is going to be set to 'Completed'
        //UpdateRelatedTeamMembers('AfterUpdate',newOoppVPPositionList,newOoppVPPositionMap,oldOoppVPPositionList,oldOoppVPPositionMap);
        
        // Method to update Company if its Industry Group is blank
        CompanyWithoutIndustryGroup(newOoppVPPositionList);
    }
    
       
    public static void afterDelete(List<Opp_VP_Position__c> newOoppVPPositionList, Map<Id, Opp_VP_Position__c> newOoppVPPositionMap, List<Opp_VP_Position__c> oldOoppVPPositionList , Map<Id, Opp_VP_Position__c> oldOoppVPPositionMap) {
        CalculateRollupOnOppVP('AfterDelete',null,null,oldOoppVPPositionList,oldOoppVPPositionMap);
        CalculateRollupOnAccount('AfterDelete',null,null,oldOoppVPPositionList,oldOoppVPPositionMap);
    }
    
    // Method to populate Name field of positions from their VP's company Name
    private static List<Opp_VP_Position__c> PopulatingPositionName( List<Opp_VP_Position__c> newOoppVPPositionList){
        List<Opp_VP_Position__c> positionsToUpdateList = new List<Opp_VP_Position__c>();  
        for(Opp_VP_Position__c oppVPPos : [SELECT Id,Name, Company__r.Name 
                                           FROM Opp_VP_Position__c 
                                           WHERE Id IN : newOoppVPPositionList]) {
            // To avoid this update where position is going to be created with mentioning Name specifically
            If(oppVPPos.Id != null && String.valueof(oppVPPos.Id).length() == 18)
                if(oppVPPos.Name == String.valueof(oppVPPos.Id).subString(0,15)) {
                    oppVPPos.Name = oppVPPos.Company__r.Name ;
                    positionsToUpdateList.add(oppVPPos);
                }
            } 
        return positionsToUpdateList;     
    }
    
    // Method to populate Name field of positions from their VP's company Name
    private static void CalculateRollupOnOppVP(String eventType, List<Opp_VP_Position__c> newOoppVPPositionList, Map<Id, Opp_VP_Position__c> newOoppVPPositionMap, List<Opp_VP_Position__c> oldOoppVPPositionList , Map<Id, Opp_VP_Position__c> oldOoppVPPositionMap){
        List<Id> OppVPToProcess = new List<Id>();
        if (eventType == 'AfterInsert') {
            for(Opp_VP_Position__c pos : newOoppVPPositionList)
                OppVPToProcess.add(pos.Opportunity_VP__c);
        }
        else if (eventType == 'AfterUpdate') {
            for(Opp_VP_Position__c newVPPos : newOoppVPPositionList) {
               
                if(newVPPos.Report_Fee__c != oldOoppVPPositionMap.get(newVPPos.id).Report_Fee__c){
                    OppVPToProcess.add(newVPPos.Opportunity_VP__c);  
                }
            }           
        }
        else if(eventType == 'AfterDelete') {
            for(Opp_VP_Position__c pos : oldOoppVPPositionList)
                OppVPToProcess.add(pos.Opportunity_VP__c);
        }
        
        List<Opp_VP__c> oppVPToUpdateList = new List<Opp_VP__c>(); 
        for(Opp_VP__c oppVP : [SELECT id, overall_VP_Status__c, Fee_Total__c, (select id, Status__c, Report_Fee__c from Opp_VP_Positions__r) 
                             FROM Opp_VP__c 
                             WHERE ID IN : OppVPToProcess]){
            if(oppVP.Opp_VP_Positions__r.size() == 0) {
                oppVP.overall_VP_Status__c = 'New';   
                oppVP.Fee_Total__c = 0.0;    
                oppVPToUpdateList.add(oppVP);                 
            }
            else 
            {
                //boolean VPInProgress = true;
                String StatusTobeUpdated = 'In Progress';                
                decimal tempTotal = 0.0;
                for(Opp_VP_Position__c oppVpPos : oppVP.Opp_VP_Positions__r) {
                    tempTotal += (oppVpPos.Report_Fee__c != null ?oppVpPos.Report_Fee__c : 0) ;                     
                }
                oppVP.Fee_Total__c = tempTotal;                               
                if(oppVP.overall_VP_Status__c != StatusTobeUpdated ||oppVp.Fee_Total__c != null) {
                    if(oppVP.overall_VP_Status__c != StatusTobeUpdated )
                        oppVP.overall_VP_Status__c = StatusTobeUpdated;
                    oppVPToUpdateList.add(oppVP);  
                }
            }
        }        
        if(oppVPToUpdateList.size() > 0 )
            update oppVPToUpdateList;
    }
    
    // Method to populate Name field of positions from their VP's company Name
    private static void CalculateRollupOnAccount(String eventType, List<Opp_VP_Position__c> newOoppVPPositionList, Map<Id, Opp_VP_Position__c> newOoppVPPositionMap, List<Opp_VP_Position__c> oldOoppVPPositionList , Map<Id, Opp_VP_Position__c> oldOoppVPPositionMap){
        List<Id> OppAccountToProcess = new List<Id>();
        if (eventType == 'AfterInsert') {
            for(Opp_VP_Position__c pos : newOoppVPPositionList)
                OppAccountToProcess.add(pos.Company__c);
        }
        else if (eventType == 'AfterUpdate') {
            for(Opp_VP_Position__c newVPPos : newOoppVPPositionList) {
                if(newVPPos.Company__c != oldOoppVPPositionMap.get(newVPPos.id).Company__c){
                    OppAccountToProcess.add(newVPPos.Company__c);  
                    OppAccountToProcess.add(oldOoppVPPositionMap.get(newVPPos.id).Company__c);
                }           
            }           
        }
        else if(eventType == 'AfterDelete') {
            for(Opp_VP_Position__c pos : oldOoppVPPositionList)
                OppAccountToProcess.add(pos.Company__c);
        }
        
        List<Account> AccountToUpdateList = new List<Account>();
        List<Account> AccountToUpdateList1 = new List<Account>();
        AccountToUpdateList1 = [SELECT id,Has_Position__c, (select id from Opp_PV_Positions__r) 
                           FROM Account 
                           WHERE ID IN : OppAccountToProcess];
        for(Account acc : AccountToUpdateList1){
            if(acc.Opp_PV_Positions__r.size() == 0) {
                acc.Has_Position__c = false;       
                AccountToUpdateList.add(acc);                 
            }
            else if(acc.Opp_PV_Positions__r.size() > 0) {
                 acc.Has_Position__c = true;       
                 AccountToUpdateList.add(acc);
            }
        }       
        if(AccountToUpdateList.size() > 0 )
            update AccountToUpdateList;
    }
    
    // Method to avoid position creation/updation if it introduce with duplicate company reference under same VP
    private static void OppVPPositionDuplicateCheck(List<Opp_VP_Position__c> newOoppVPPositionList){
        
        // Set of related Opp VP Id
        Set <String> oppVpofProcessedPositionSet = new Set < String > ();
        // Set of matching criteria (it is generic so it can be modified easily if criteria gets changed)
        Set<String> matchingStringSet = new Set<String>(); 
        // Map of criteria and object instance to apply addError 
        Map<String, Opp_VP_Position__c> ProcessedPositionMap = new Map<String, Opp_VP_Position__c>(); 
        
        for (Opp_VP_Position__c opVPPObj: newOoppVPPositionList) {
             if(opVPPObj.ResultingEngagemnetRTonVPP__c != 'Portfolio_Valuation' )  
               {
                   opVPPObj.addError(System.Label.HL_VP_Position_Stop_Create_Edit_Delete);
               }             
            
            
            if(!(trigger.isUpdate && ((Opp_VP_Position__c )Trigger.oldMap.get(opVPPObj.Id)).Opportunity_VP__c != null && opVPPObj.Opportunity_VP__c != ((Opp_VP_Position__c )Trigger.oldMap.get(opVPPObj.Id)).Opportunity_VP__c)) {
                oppVpofProcessedPositionSet.add(opVPPObj.Opportunity_VP__c);
                matchingStringSet.add(opVPPObj.Opportunity_VP__c+'-'+opVPPObj.Company__c+'-'+opVPPObj.Asset_Classes__c);
                ProcessedPositionMap.put(opVPPObj.Opportunity_VP__c+'-'+opVPPObj.Company__c+'-'+opVPPObj.Asset_Classes__c,opVPPObj);
                }
         }
       
        String matchingString ='';
        for(Opp_VP_Position__c filteredPosition :  [SELECT Id, Company__c, Asset_Classes__c, Opportunity_VP__c 
                                                    FROM  Opp_VP_Position__c
                                                    WHERE /*Status__c != 'Cancelled' AND*/ Opportunity_VP__c IN : oppVpofProcessedPositionSet AND Id NOT IN: newOoppVPPositionList]) {
            matchingString = filteredPosition.Opportunity_VP__c+'-'+filteredPosition.Company__c+'-'+filteredPosition.Asset_Classes__c;
            if(!matchingStringSet.contains(matchingString)) {
                matchingStringSet.add(matchingString);
            }               
            else {
                if(ProcessedPositionMap.containsKey(matchingString))
                    ProcessedPositionMap.get(matchingString).addError(System.Label.DuplicateVP);
            }
        }
    } 
        
    // To change owner of Opp VP Position records to System Administrator 
    private static void changeOwnershipToSystemAdmin(list<Opp_VP_Position__c> newOoppVPPositionList) {
        for(Opp_VP_Position__c oppVPPosition : newOoppVPPositionList)
        {
               //Commented code by Sandeep SF-820
               // oppVPPosition.ownerId = Label.Salesforce_Administrator_ID;
                oppVPPosition.CurrencyIsoCode = oppVPPosition.Parent_Currency_Formula__c;
        }
    }
    
    // Method to update Company record which don't have Industry Group 
    private static void CompanyWithoutIndustryGroup( List<Opp_VP_Position__c> newOppVPPositionList){
        
        Map<Id,Opp_VP_Position__c> CompanyIndustryGroupMap = new Map<Id,Opp_VP_Position__c>(); 
        List<Account> CompanyToUpdate = new List<Account>();
        
        for(Opp_VP_Position__c OppVPPos : [SELECT Id, Company__r.id, Industry_Group_Picklist__c,Sector__c, Company__r.Industry_Group__c 
                                           FROM Opp_VP_Position__c WHERE Id IN : newOppVPPositionList]) {
            if(OppVPPos.Company__r.Industry_Group__c == null ){
                CompanyIndustryGroupMap.put(OppVPPos.Company__r.id,OppVPPos);
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
}