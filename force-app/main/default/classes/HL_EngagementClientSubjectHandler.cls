public class HL_EngagementClientSubjectHandler {
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public boolean IsTriggerContext{get{ return isExecuting;}}
    public static Boolean isAfterInsertFlag = false;
    public static Boolean isAfterUpdateFlag = false;
    public static Boolean isAfterDeleteFlag = false;
    
    public HL_EngagementClientSubjectHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
    }
    
    public void OnBeforeInsert(List<Engagement_Client_Subject__c> ecsList){
        this.populateOriginalClientSubjectNameOnInsert(ecsList);
    }
    
    public void OnAfterInsert(List<Engagement_Client_Subject__c> ecsList){
        if(!isAfterInsertFlag){
            isAfterInsertFlag = true;
            UpdatePublicPrivate(ecsList);
            this.AddClientsSubjectsNamesOnEng(ecsList);
        }
    }
    
    public void OnAfterUpdate(List<Engagement_Client_Subject__c> ecsList){
        if(!isAfterUpdateFlag){
            isAfterUpdateFlag = true;
            UpdatePublicPrivate(ecsList);
        }
    }
    
    public void OnAfterDelete(List<Engagement_Client_Subject__c> ecsList){
         if(!isAfterDeleteFlag){
            isAfterDeleteFlag = true;
            UpdatePublicPrivate(ecsList);
            
            Set<Id> setEngId = new Set<Id>();
            Set<Id> setAccId = new Set<Id>();
            for(Engagement_Client_Subject__c objClientSubject : ecsList)
            {
                if(objClientSubject.Type__c == 'Client' || objClientSubject.Type__c == 'Subject'){ 
                    setEngId.add(objClientSubject.Engagement__c);
                    setAccId.add(objClientSubject.Client_Subject__c);
                }
            }
            
                if(setEngId.size() > 0)
                this.UpdateAdditionalClientsSubjectsNames(setEngId, ecsList, setAccId);
            
            
         }
    }
    
    private void UpdatePublicPrivate(List<Engagement_Client_Subject__c> ecsList){
        //List of Engagements to Update
        List<Engagement__c> engsToUpdate = new List<Engagement__c>();
        //Set of Eng IDs
        Set<Id> engs = new Set<Id>();
        //Get a Map of Engs with Client/Subject ownership
        Map<Id,Set<String>> engsToOwnership = new Map<Id,Set<String>>();
        Set<String> currentVals;
        for(Engagement_Client_Subject__c ecs : ecsList)
            engs.Add(ecs.Engagement__c);
        if(engs.size() > 0){
            //Get all related Client/Subjects
            for(Engagement_Client_Subject__c cs : [SELECT Engagement__c, Client_Subject__r.Ownership FROM Engagement_Client_Subject__c WHERE Engagement__c IN:engs]){ 
                if(!engsToOwnership.containsKey(cs.Engagement__c))
                    engsToOwnership.put(cs.Engagement__c, new Set<String> {cs.Client_Subject__r.Ownership});
                else{
                    currentVals = engsToOwnership.get(cs.Engagement__c);
                    currentVals.add(cs.Client_Subject__r.Ownership);
                    engsToOwnership.put(cs.Engagement__c, currentVals);
                } 
            }

            //Update the Engagements
            for(Id engId : engsToOwnership.keySet()){
                currentVals = engsToOwnership.get(engId);
                engsToUpdate.add(new Engagement__c(
                                                   Id = engId, 
                                                   Public_Or_Private__c = (currentVals.contains('Public Debt') || currentVals.contains('Public Equity') ? 'Public' : 'Private')
                                                  )
                                ); 
            }

            if(engsToUpdate.size() > 0)
                update engsToUpdate;
       }
    }
    public static void stopDeletion(List<Engagement_Client_Subject__c> deletingRecordList) {
         for(Engagement_Client_Subject__c  engObj : deletingRecordList){
          if(engObj.Primary__c ){             
             engObj.addError('Primary Clients and Subjects cannot be deleted');
            }
        }
    }
       
    public static void stopDuplicate(List < Engagement_Client_Subject__c > InsertingACSRecords) {
        set < ID > RelatedEngagementIdSet = new set < ID > ();
        set < ID > RelatedCompantyIdSet = new set < ID > ();
        for (Engagement_Client_Subject__c engObj1: InsertingACSRecords) {
            RelatedEngagementIdSet.add(engObj1.Engagement__c);
            RelatedCompantyIdSet.add(engObj1.Client_Subject__c);
        }
        map < id, Account > RelatedAccountMap = new map < Id, Account > ([SELECT id, Name FROM Account WHERE id IN : RelatedCompantyIdSet]);
        map < id, set < string >> EngagementWithRelatedExistingACSMap = new map < id, set < string >> ();

        Set < String > CombinationSet;
        for (Engagement__c eng : [SELECT ID, (SELECT id, Type__c, Client_Subject__c, Engagement__c, Role__c, Other_Related_Object_Id__c FROM Engagement_Clients_Subjects__r) FROM Engagement__c WHERE ID IN : RelatedEngagementIdSet]) {
            CombinationSet = new Set < String > ();
            for (Engagement_Client_Subject__c acs : eng.Engagement_Clients_Subjects__r) {
                string role = '';
                string relatedObject = '';
                if (acs.Role__c != null) {
                    role = acs.Role__c ;
                }
                
                if (acs.Other_Related_Object_Id__c != null) {
                    relatedObject =  String.valueOf(acs.Other_Related_Object_Id__c);
                }
                
                CombinationSet.add(acs.type__c + '_' + acs.Client_Subject__c + '_' + role + '_' + relatedObject);
            }
            EngagementWithRelatedExistingACSMap.put(eng.Id, CombinationSet);
        }

        for (Engagement_Client_Subject__c ACSRecord : InsertingACSRecords) {       
            string role = '';
            string relatedObject = '';
            if (ACSRecord.Role__c != null) {
                role = ACSRecord.Role__c ;
            }
            
            if (ACSRecord.Other_Related_Object_Id__c != null) {
                relatedObject =  String.valueOf(ACSRecord.Other_Related_Object_Id__c);
            }
            If(EngagementWithRelatedExistingACSMap.containsKey(ACSRecord.Engagement__c) && EngagementWithRelatedExistingACSMap.get(ACSRecord.Engagement__c) != null 
               && EngagementWithRelatedExistingACSMap.get(ACSRecord.Engagement__c).contains(ACSRecord.type__c + '_' + ACSRecord.Client_Subject__c + '_' + role + '_' + relatedObject) 
               && RelatedAccountMap.containsKey(ACSRecord.Client_Subject__c)) {
                ACSRecord.addError('Company Name : ' + '\'' +RelatedAccountMap.get(ACSRecord.Client_Subject__c).Name + '\'' + ' already exists as an Additional Client/Subject');
            }
        }
    }    
    
    public static void validateDuplicateRecord(List<Engagement_Client_Subject__c> EnggClientNewList, Map <Id,Engagement_Client_Subject__c> EnggClientOldMap) {
        Map<String, Engagement_Client_Subject__c> EnggClientUniqueMap = new Map<String, Engagement_Client_Subject__c>();
        set<Id> EngagementIdSet = new Set<Id>();
        set<Engagement_Client_Subject__c> BulkyLoaderSet = new Set<Engagement_Client_Subject__c>();
        for (Engagement_Client_Subject__c EnggClient : EnggClientNewList){             
            //Check for duplicate Primary Address in same transaction
            if (((EnggClient.Client_Subject__c+''+EnggClient.Engagement__c+''+EnggClient.Type__c) !=null) && 
                ((EnggClient.Client_Subject__c+''+EnggClient.Engagement__c+''+EnggClient.Type__c) != 
                    (EnggClientOldMap.get(EnggClient.Id).Client_Subject__c+''+EnggClientOldMap.get(EnggClient.Id).Engagement__c+''+EnggClientOldMap.get(EnggClient.Id).Type__c)))
            {
                string role = '';
                string relatedObject = '';
                if (EnggClient.Role__c != null) {
                    role = EnggClient.Role__c ;
                }
                if (EnggClient.Other_Related_Object_Id__c != null) {
                    relatedObject =  String.valueOf(EnggClient.Other_Related_Object_Id__c);
                }
                BulkyLoaderSet.add(EnggClient);
                // Check for existing Primary Address       
                if (EnggClientUniqueMap.containsKey(EnggClient.Client_Subject__c+''+EnggClient.Engagement__c+''+EnggClient.Type__c+''+role+''+relatedObject)){
                    EnggClient.addError('Company Name : ' + '\'' + EnggClient.Client_Subject__r.Name+'\''+ 'with this Type already exists');
                }else{
                    EnggClientUniqueMap.put((EnggClient.Client_Subject__c+''+EnggClient.Engagement__c+''+EnggClient.Type__c+''+role+''+relatedObject), EnggClient);
                    EngagementIdSet.add(EnggClient.Engagement__c);
                }
            }            
        }
        
        for (Engagement_Client_Subject__c enggclientRecord  : [SELECT Client_Subject__c, Engagement__c,Type__c,Client_Subject__r.Name, Role__c, Other_Related_Object_Id__c
                                                               FROM Engagement_Client_Subject__c
                                                               WHERE Engagement__c IN :EngagementIdSet AND ID NOT IN : BulkyLoaderSet limit : Limits.getLimitQueryRows()]){    
            string role = '';
            string relatedObject = '';
            if (enggclientRecord.Role__c != null) {
                role = enggclientRecord.Role__c ;
            }
            if (enggclientRecord.Other_Related_Object_Id__c != null) {
                relatedObject =  String.valueOf(enggclientRecord.Other_Related_Object_Id__c);
            }
            if(EnggClientUniqueMap.containsKey(enggclientRecord.Client_Subject__c+''+enggclientRecord.Engagement__c+''+enggclientRecord.Type__c+''+role+''+relatedObject)) {
                Engagement_Client_Subject__c duplicateRecord = EnggClientUniqueMap.get(enggclientRecord.Client_Subject__c+''+enggclientRecord.Engagement__c+''+enggclientRecord.Type__c+''+role);
                duplicateRecord.addError('Company Name : ' + '\''+enggclientRecord.Client_Subject__r.Name+'\''+ 'with this Type already exists');
            }
        }
    }
    
   //**** UpdatesAdditionalClientsSubject Names after delete *** //
    private void UpdateAdditionalClientsSubjectsNames(Set<Id> EngIds, List<Engagement_Client_Subject__c> triggerOld, Set<Id> setAccId){
        Map<Id,Account> mapAccount = new Map<Id,Account>([SELECT Id, Name from Account where Id in :setAccId]); 
        Map<Id,Engagement__C> mapEng = new Map<Id,Engagement__c>([SELECT id, Original_Client_Name__c, Original_Subject_Name__c FROM Engagement__c where Id in :EngIds]);
        if(mapEng != null && mapEng.size() > 0){
            for(Engagement_Client_Subject__c objEngClientSub : triggerOld){
                if(mapEng.containsKey(objEngClientSub.Engagement__c)){
                    String strClientSubName = mapAccount.containsKey(objEngClientSub.Client_Subject__c) ? mapAccount.get(objEngClientSub.Client_Subject__c).Name : '';
                    Engagement__c currEng = mapEng.get(objEngClientSub.Engagement__c);
                    if(objEngClientSub.Type__c == 'Client'){
                        String strEngOriginalClientName = String.IsNotBlank(currEng.Original_Client_Name__c) ? currEng.Original_Client_Name__c : '';
                        String originalClientSubName = String.IsNotBlank(objEngClientSub.Original_Name__c) ? objEngClientSub.Original_Name__c : strClientSubName; 
                        currEng.Original_Client_Name__c = strEngOriginalClientName.replace(originalClientSubName,'');
                    }
                    else{
                        String strEngOriginalSubName = String.IsNotBlank(currEng.Original_Subject_Name__c) ? currEng.Original_Subject_Name__c : '';
                        String originalClientSubName = String.IsNotBlank(objEngClientSub.Original_Name__c) ? objEngClientSub.Original_Name__c : strClientSubName; 
                        currEng.Original_Subject_Name__c = strEngOriginalSubName.replace(originalClientSubName,'');                     
                    }
                    mapEng.put(objEngClientSub.Engagement__c,currEng);
                }
            }
            
            for(Id engId : mapEng.keySet()){
                Engagement__c currEng = mapEng.get(engId);
                currEng.Original_Client_Name__c = String.IsNotBlank(currEng.Original_Client_Name__c) ? refineOppClientSubjectName(currEng.Original_Client_Name__c) : currEng.Original_Client_Name__c;
                currEng.Original_Subject_Name__c = String.IsNotBlank(currEng.Original_Subject_Name__c) ? refineOppClientSubjectName(currEng.Original_Subject_Name__c) : currEng.Original_Subject_Name__c;
            }
           update mapEng.values(); 
        }

    
    }
    // *** Refines the string on Engagement fields after AdditionClientSubject is deleted from table ***
    public string refineOppClientSubjectName(String strEngClientSubjectName){
        strEngClientSubjectName = strEngClientSubjectName.trim();
        String finalStr = '';
        String firstChar = strEngClientSubjectName.subString(0,1);
        String lastChar = strEngClientSubjectName.subString(strEngClientSubjectName.length() - 1,strEngClientSubjectName.length());
        if(firstChar == '|')
           strEngClientSubjectName = strEngClientSubjectName.subString(1,strEngClientSubjectName.length()).trim();
    
        if(lastChar == '|')
            strEngClientSubjectName = strEngClientSubjectName.removeEnd('|').trim();
        
        List<String> lstAllOriginalNames = strEngClientSubjectName.split('\\|');
        
        Integer currIndex = 0;
        for(String strr : lstAllOriginalNames){    
            if(String.isNotBlank(strr.trim())){
                finalStr = finalStr + strr.trim();   
                finalStr = finalStr + ' | ';
            }
        }
        finalStr = finalStr.trim();
        finalStr = finalStr.removeEnd('|');
        finalStr = finalStr.trim();
        
        return finalStr;
    }
    
   //**** Adding AdditionalClientSubject Names on opportunity fileds ***
    private void AddClientsSubjectsNamesOnEng(List<Engagement_Client_Subject__c> triggerNew){
        Map<Id,List<Engagement_Client_Subject__c>> mapOfEngIdwithClientSubjects = new Map<Id,List<Engagement_Client_Subject__c>>();
        List<Engagement__c> lstEngToUpdate = new List<Engagement__c>(); 
        Map<Id,Id> mapOfClientSubjectWithEng = new Map<Id,Id>();
        for(Engagement_Client_Subject__c objEngClientSub : triggerNew){
            if(objEngClientSub.Engagement__c != null){
                mapOfClientSubjectWithEng.put(objEngClientSub.Id, objEngClientSub.Engagement__c);
            }
        }    
        
        List<Engagement_Client_Subject__c> ocsList = [SELECT id, Client_Subject__r.Name, Type__c, Engagement__c, Original_Name__c FROM Engagement_Client_Subject__c WHERE Engagement__c in : mapOfClientSubjectWithEng.values() AND Type__c IN ('Client','Subject') ORDER BY Primary__c desc, Client_Subject__r.Name];         
        if(ocsList != null && ocsList.size() > 0){
            for(Engagement_Client_Subject__c objEngClientSub : ocsList){
                if(mapOfEngIdwithClientSubjects.containsKey(objEngClientSub.Engagement__c)){
                    List<Engagement_Client_Subject__c> lstEngClientSub = mapOfEngIdwithClientSubjects.get(objEngClientSub.Engagement__c);
                    lstEngClientSub.add(objEngClientSub);
                    mapOfEngIdwithClientSubjects.put(objEngClientSub.Engagement__c,lstEngClientSub);
                }
                else{
                    List<Engagement_Client_Subject__c> lstEngClientSub = new List<Engagement_Client_Subject__c>();
                    lstEngClientSub.add(objEngClientSub);
                    mapOfEngIdwithClientSubjects.put(objEngClientSub.Engagement__c,lstEngClientSub);
                }
            }
            
            for(Id engId : mapOfEngIdwithClientSubjects.keySet()){
                Engagement__c objEng = new Engagement__c(Id = engId);
                List<string> lstOriginalClientSubject = GetAdditionalClientsSubjectsByNames(engId,mapOfEngIdwithClientSubjects.get(engId));
                objEng.Original_Client_Name__c = lstOriginalClientSubject[0];
                objEng.Original_Subject_Name__c = lstOriginalClientSubject[1];
                
                lstEngToUpdate.add(objEng);
            }
            
            if(lstEngToUpdate != null && lstEngToUpdate.size() > 0){
                update lstEngToUpdate;
            }
            
        }       
    }
      
    // Method adding for AdditionalClientSubject.
     private List<string> GetAdditionalClientsSubjectsByNames(String EntityId, List<Engagement_Client_Subject__c> ocsList){
      String strOriginalClientName = '';
      String strOriginalSubjectName = '';
      List<String> lstOriginalClientSubject = new List<String>();
      if(ocsList == null)
        ocsList = [SELECT id, Client_Subject__r.Name, Type__c FROM Engagement_Client_Subject__c WHERE Engagement__c =: EntityId AND Type__c IN ('Client','Subject') ORDER BY Primary__c desc, Client_Subject__r.Name];
      
      if(ocsList != null && ocsList.size() > 0)
      {
        for(Engagement_Client_Subject__c objClientSubject : ocsList)

        {
            String strCurrentName = String.IsNotBlank(objClientSubject.Original_Name__c) ? objClientSubject.Original_Name__c : objClientSubject.Client_Subject__r.Name;
            if(objClientSubject.Type__c.equalsIgnoreCase('Client'))
            {
                strOriginalClientName =  String.isBlank(strOriginalClientName) ? strCurrentName : strOriginalClientName + ' | ' + strCurrentName;
            }
            else
            {
                strOriginalSubjectName =  String.isBlank(strOriginalSubjectName) ? strCurrentName : strOriginalSubjectName + ' | ' + strCurrentName;

            }
            
          // objClientSubject.Is_Created_With_Opportunity__c = TRUE;
        }
        
            //update ocsList;
      }
      
      lstOriginalClientSubject.add(strOriginalClientName);
      lstOriginalClientSubject.add(strOriginalSubjectName);
      
      return lstOriginalClientSubject;
    }
    /*public void validateFeeAttribution(List<Engagement_Client_Subject__c> triggerNew, Map<Id,Engagement_Client_Subject__c> oldMap){
        Map<Id,Decimal> engIds = new Map<Id,Decimal>();
        Map<Id,Decimal> engIdsVal = new Map<Id,Decimal>();
        for(Engagement_Client_Subject__c objClientSub : triggerNew){
            if(objClientSub.FeeAttribution__c  == null)
                objClientSub.FeeAttribution__c  = 0;
            if(engIds.get(objClientSub.Engagement__c) != null){
                Decimal revAlloc = engIds.get(objClientSub.Engagement__c) + objClientSub.FeeAttribution__c ;
                if(revAlloc > 100){
                    objClientSub.addError('Fee Attribution cannot exceed 100%');
                }
                engIds.put(objClientSub.Engagement__c,revAlloc);
            }
            else{
                if(objClientSub.FeeAttribution__c  > 100){
                    objClientSub.addError('Fee Attribution cannot exceed 100%');
                }
                engIds.put(objClientSub.Engagement__c,objClientSub.FeeAttribution__c );
            }
        }
        list<Engagement_Client_Subject__c> ecList = new list<Engagement_Client_Subject__c>();
        if(oldMap.size() > 0){
            ecList = [select id,Engagement__c,FeeAttribution__c  
             from Engagement_Client_Subject__c where Engagement__c IN: engIds.keySet() AND Id NOT IN: oldMap.keySet()];
        }
        else{
            ecList = [select id,Engagement__c,FeeAttribution__c  
             from Engagement_Client_Subject__c where Engagement__c IN: engIds.keySet()];
        }
        for(Engagement_Client_Subject__c ec : ecList){
            if(ec.FeeAttribution__c  == null)
                ec.FeeAttribution__c  = 0;
            if(engIdsVal.get(ec.Engagement__c) != null){
                Decimal revAlloc = engIdsVal.get(ec.Engagement__c) + ec.FeeAttribution__c ;
                engIdsVal.put(ec.Engagement__c,revAlloc);
            }
            else{
                engIdsVal.put(ec.Engagement__c,ec.FeeAttribution__c );
            }
        }
        for(Engagement_Client_Subject__c ec : triggerNew){
            if(ec.FeeAttribution__c  == null)
                ec.FeeAttribution__c  = 0;
            if(engIdsVal.get(ec.Engagement__c) != null){
                if((engIds.get(ec.Engagement__c) + engIdsVal.get(ec.Engagement__c)) > 100){
                    ec.addError('Fee Attribution cannot exceed 100%');
                }
            }
        }
    }*/
    public void validateClientHoldings(List<Engagement_Client_Subject__c> triggerNew, Map<Id,Engagement_Client_Subject__c> oldMap){
        Map<Id,Decimal> engIds = new Map<Id,Decimal>();
        Map<Id,Decimal> engIdsVal = new Map<Id,Decimal>();
        for(Engagement_Client_Subject__c objClientSub : triggerNew){
            if(objClientSub.ClientHoldings__c == null)
                objClientSub.ClientHoldings__c = 0;
            if(engIds.get(objClientSub.Engagement__c) != null){
                Decimal revAlloc = engIds.get(objClientSub.Engagement__c) + objClientSub.ClientHoldings__c;
                if(revAlloc > 100){
                    objClientSub.addError('Client Holdings cannot exceed 100%');
                }
                engIds.put(objClientSub.Engagement__c,revAlloc);
            }
            else{
                if(objClientSub.ClientHoldings__c > 100){
                    objClientSub.addError('Client Holdings cannot exceed 100%');
                }
                engIds.put(objClientSub.Engagement__c,objClientSub.ClientHoldings__c);
            }
        }
        list<Engagement_Client_Subject__c> ecList = new list<Engagement_Client_Subject__c>();
        if(oldMap.size() > 0){
            ecList = [select id,Engagement__c,ClientHoldings__c 
             from Engagement_Client_Subject__c where Engagement__c IN: engIds.keySet() AND Id NOT IN: oldMap.keySet()];
        }
        else{
            ecList = [select id,Engagement__c,ClientHoldings__c 
             from Engagement_Client_Subject__c where Engagement__c IN: engIds.keySet()];
        }
        for(Engagement_Client_Subject__c ec : ecList){
            if(ec.ClientHoldings__c == null)
                ec.ClientHoldings__c = 0;
            if(engIdsVal.get(ec.Engagement__c) != null){
                Decimal revAlloc = engIdsVal.get(ec.Engagement__c) + ec.ClientHoldings__c;
                engIdsVal.put(ec.Engagement__c,revAlloc);
            }
            else{
                engIdsVal.put(ec.Engagement__c,ec.ClientHoldings__c);
            }
        }
        for(Engagement_Client_Subject__c ec : triggerNew){
            if(ec.ClientHoldings__c == null)
                ec.ClientHoldings__c = 0;
            if(engIdsVal.get(ec.Engagement__c) != null){
                if((engIds.get(ec.Engagement__c) + engIdsVal.get(ec.Engagement__c)) > 100){
                    ec.addError('Client Holdings cannot exceed 100%');
                }
            }
        }
    }
    public void validateRevenueAllocation(List<Engagement_Client_Subject__c> triggerNew, Map<Id,Engagement_Client_Subject__c> oldMap){
        Map<Id,Decimal> engIds = new Map<Id,Decimal>();
        Map<Id,Decimal> engIdsVal = new Map<Id,Decimal>();
        for(Engagement_Client_Subject__c objClientSub : triggerNew){
            if(objClientSub.CreditorRevenueAllocationPercentage__c == null)
                objClientSub.CreditorRevenueAllocationPercentage__c = 0;
            if(engIds.get(objClientSub.Engagement__c) != null){
                Decimal revAlloc = engIds.get(objClientSub.Engagement__c) + objClientSub.CreditorRevenueAllocationPercentage__c;
                if(revAlloc > 100){
                    objClientSub.addError('Revenue Allocation cannot exceed 100%');
                }
                engIds.put(objClientSub.Engagement__c,revAlloc);
            }
            else{
                if(objClientSub.CreditorRevenueAllocationPercentage__c > 100){
                    objClientSub.addError('Revenue Allocation cannot exceed 100%');
                }
                engIds.put(objClientSub.Engagement__c,objClientSub.CreditorRevenueAllocationPercentage__c);
            }
        }
        list<Engagement_Client_Subject__c> ecList = new list<Engagement_Client_Subject__c>();
        if(oldMap.size() > 0){
            ecList = [select id,Engagement__c,CreditorRevenueAllocationPercentage__c 
             from Engagement_Client_Subject__c where Engagement__c IN: engIds.keySet() AND Id NOT IN: oldMap.keySet()];
        }
        else{
            ecList = [select id,Engagement__c,CreditorRevenueAllocationPercentage__c 
             from Engagement_Client_Subject__c where Engagement__c IN: engIds.keySet()];
        }
        for(Engagement_Client_Subject__c ec : ecList){
            if(ec.CreditorRevenueAllocationPercentage__c == null)
                ec.CreditorRevenueAllocationPercentage__c = 0;
            if(engIdsVal.get(ec.Engagement__c) != null){
                Decimal revAlloc = engIdsVal.get(ec.Engagement__c) + ec.CreditorRevenueAllocationPercentage__c;
                engIdsVal.put(ec.Engagement__c,revAlloc);
            }
            else{
                engIdsVal.put(ec.Engagement__c,ec.CreditorRevenueAllocationPercentage__c);
            }
        }
        for(Engagement_Client_Subject__c ec : triggerNew){
            if(ec.CreditorRevenueAllocationPercentage__c == null)
                ec.CreditorRevenueAllocationPercentage__c = 0;
            if(engIdsVal.get(ec.Engagement__c) != null){
                if((engIds.get(ec.Engagement__c) + engIdsVal.get(ec.Engagement__c)) > 100){
                    ec.addError('Revenue Allocation cannot exceed 100%');
                }
            }
        }
    }
    public void validateKeyCreditor(List<Engagement_Client_Subject__c> triggerNew, Map<Id,Engagement_Client_Subject__c> oldMap){
        Map<Id,Decimal> engIds = new Map<Id,Decimal>();
        Map<Id,Decimal> engIdsVal = new Map<Id,Decimal>();
        for(Engagement_Client_Subject__c objClientSub : triggerNew){
            if(objClientSub.KeyCreditorWeighting__c == null)
                objClientSub.KeyCreditorWeighting__c = 0;
            if(engIds.get(objClientSub.Engagement__c) != null){
                Decimal revAlloc = engIds.get(objClientSub.Engagement__c) + objClientSub.KeyCreditorWeighting__c;
                if(revAlloc > 100){
                    objClientSub.addError('Key Creditor Weighting cannot exceed 100%');
                }
                engIds.put(objClientSub.Engagement__c,revAlloc);
            }
            else{
                if(objClientSub.KeyCreditorWeighting__c > 100){
                    objClientSub.addError('Key Creditor Weighting cannot exceed 100%');
                }
                engIds.put(objClientSub.Engagement__c,objClientSub.KeyCreditorWeighting__c);
            }
        }
        list<Engagement_Client_Subject__c> ecList = new list<Engagement_Client_Subject__c>();
        if(oldMap.size() > 0){
            ecList = [select id,Engagement__c,KeyCreditorWeighting__c 
             from Engagement_Client_Subject__c where Engagement__c IN: engIds.keySet() AND Id NOT IN: oldMap.keySet()];
        }
        else{
            ecList = [select id,Engagement__c,KeyCreditorWeighting__c 
             from Engagement_Client_Subject__c where Engagement__c IN: engIds.keySet()];
        }
        for(Engagement_Client_Subject__c ec : ecList){
            if(ec.KeyCreditorWeighting__c == null)
                ec.KeyCreditorWeighting__c = 0;
            if(engIdsVal.get(ec.Engagement__c) != null){
                Decimal revAlloc = engIdsVal.get(ec.Engagement__c) + ec.KeyCreditorWeighting__c;
                engIdsVal.put(ec.Engagement__c,revAlloc);
            }
            else{
                engIdsVal.put(ec.Engagement__c,ec.KeyCreditorWeighting__c);
            }
        }
        for(Engagement_Client_Subject__c ec : triggerNew){
            if(ec.KeyCreditorWeighting__c == null)
                ec.KeyCreditorWeighting__c = 0;
            if(engIdsVal.get(ec.Engagement__c) != null){
                if((engIds.get(ec.Engagement__c) + engIdsVal.get(ec.Engagement__c)) > 100){
                    ec.addError('Key Creditor Weighting cannot exceed 100%');
                }
            }
        }
    }
    //*** Populates OriginalNames in table when AdditionClientSubject is added ***
    public void populateOriginalClientSubjectNameOnInsert(List<Engagement_Client_Subject__c> triggerNew){
        Set<Id> setAccIds = new Set<Id>();
        Map<Id, String> mapOfAccIdWithName = new Map<Id, String>();
        for(Engagement_Client_Subject__c objClientSub : triggerNew){
            if(objClientSub.Client_Subject__c != null){
                setAccIds.add(objClientSub.Client_Subject__c);
            }
        }
        if(setAccIds != null && setAccIds.size() > 0){
            for(Account objAcc : [SELECT id, Name from Account WHERE Id IN :setAccIds]){
                mapOfAccIdWithName.put(objAcc.Id, objAcc.Name);
            }
            
            for(Engagement_Client_Subject__c objClientSub : triggerNew){
                if(objClientSub.Client_Subject__c != null && mapOfAccIdWithName.containsKey(objClientSub.Client_Subject__c))
                    objClientSub.Original_Name__c = mapOfAccIdWithName.get(objClientSub.Client_Subject__c);
    
            }
        }
    }

}