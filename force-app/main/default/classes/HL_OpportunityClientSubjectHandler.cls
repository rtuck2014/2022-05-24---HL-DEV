public class HL_OpportunityClientSubjectHandler {
    public static void UpdatePublicPrivate(List<Opportunity_Client_Subject__c> ocsList){
        //List of Opportunities to Update
        List<Opportunity__c> oppsToUpdate = new List<Opportunity__c>();
        //Set of Opp IDs
        Set<Id> opps = new Set<Id>();
        //Get a Map of Opps with Client/Subject ownership
        Map<Id,Set<String>> oppsToOwnership = new Map<Id,Set<String>>();
        Set<String> currentVals;
        for(Opportunity_Client_Subject__c ocs : ocsList)
            opps.Add(ocs.Opportunity__c);
        //Get all related Client/Subjects
        for(Opportunity_Client_Subject__c cs : [SELECT Opportunity__c, Client_Subject__r.Ownership FROM Opportunity_Client_Subject__c WHERE Opportunity__c IN:opps]){ 
            if(!oppsToOwnership.containsKey(cs.Opportunity__c))
                oppsToOwnership.put(cs.Opportunity__c, new Set<String> {cs.Client_Subject__r.Ownership});
            else{
                currentVals = oppsToOwnership.get(cs.Opportunity__c);
                currentVals.add(cs.Client_Subject__r.Ownership);
                oppsToOwnership.put(cs.Opportunity__c, currentVals);
            } 
        }
        //Update the Opportunities
        for(Opportunity__c opp : [SELECT Public_Or_Private__c FROM Opportunity__c WHERE Id IN:oppsToOwnership.keySet() AND Converted_to_Engagement__c = False]){
            currentVals = oppsToOwnership.get(opp.Id);
            if(currentVals.contains('Public Debt') || currentVals.contains('Public Equity'))
                opp.Public_Or_Private__c = 'Public';
            else
                opp.Public_Or_Private__c = 'Private';
            oppsToUpdate.add(opp);
        }
        
        if(oppsToUpdate.size() > 0)
            update oppsToUpdate;
    }
    
    //***Update the Opportunity for AdditionalClientSubject ****
    public void OnAfterInsert(List<Opportunity_Client_Subject__c> triggerNew) {
   // this.updateLastModifiedDateTimeOnOpportunity(triggerNew);
      this.AddClientsSubjectsNamesOnOpp(triggerNew);
    
    }
    
    public void OnBeforeInsert(List<Opportunity_Client_Subject__c> triggerNew) {
        this.populateOriginalClientSubjectNameOnInsert(triggerNew);
    
    }
    
    public void OnAfterDelete(List<Opportunity_Client_Subject__c> triggerOld) {
    Set<Id> setOppId = new Set<Id>();
    Set<Id> setAccId = new Set<Id>();
    for(Opportunity_Client_Subject__c objClientSubject : triggerOld)
    {
        if(objClientSubject.Type__c == 'Client' || objClientSubject.Type__c == 'Subject'){ 
            setOppId.add(objClientSubject.Opportunity__c);
            setAccId.add(objClientSubject.Client_Subject__c);
        }
    }
    
    if(setOppId.size() > 0)
        this.UpdateAdditionalClientsSubjectsNames(setOppId, triggerOld, setAccId);
    
    
    }
    
    public static void stopDeletion(List<Opportunity_Client_Subject__c> deletingRecordList) {
        for(Opportunity_Client_Subject__c  oppObj : deletingRecordList){
          if(oppObj.Primary__c ){  
             oppObj.addError('Primary Clients and Subjects cannot be deleted');
            }
        } 
    }
    
    public static void stopDuplicate(List<Opportunity_Client_Subject__c> InsertingACSRecords ) {
        set<ID> RelatedOpportunityIdSet = new set<ID>();
        set<ID> RelatedCompantyIdSet = new set<ID>();
        for(Opportunity_Client_Subject__c  oppObj1 : InsertingACSRecords){
          RelatedOpportunityIdSet.add(oppObj1.opportunity__c);
          RelatedCompantyIdSet.add(oppObj1.Client_Subject__c);
        }
        map<id, Account> RelatedAccountMap = new map<Id, Account> ([SELECT id, Name FROM Account WHERE id IN : RelatedCompantyIdSet]);
        map<id,set<string>> OpportunityWithRelatedExistingACSMap = new map<id,set<string>>();
        
        Set<String> CombinationSet;         
        for(opportunity__c opp : [SELECT ID,(SELECT id,Type__c,Client_Subject__c,Opportunity__c FROM Opportunity_Clients_Subjects__r) FROM Opportunity__c WHERE ID IN : RelatedOpportunityIdSet]) {
           CombinationSet = new Set<String>();
           for(Opportunity_Client_Subject__c acs : opp.Opportunity_Clients_Subjects__r) { 
              CombinationSet.add(acs.type__c+'_'+acs.Client_Subject__c);          
            }
           OpportunityWithRelatedExistingACSMap.put(opp.Id,CombinationSet);             
        }  
       
        for(Opportunity_Client_Subject__c ACSRecord : InsertingACSRecords){  
                     
            If(OpportunityWithRelatedExistingACSMap.containsKey(ACSRecord.Opportunity__c) && OpportunityWithRelatedExistingACSMap.get(ACSRecord.Opportunity__c) != null 
               && OpportunityWithRelatedExistingACSMap.get(ACSRecord.Opportunity__c).contains(ACSRecord.type__c+'_'+ACSRecord.Client_Subject__c) 
               && RelatedAccountMap.containsKey(ACSRecord.Client_Subject__c)) {
                ACSRecord.addError('Company Name : ' + '\'' +RelatedAccountMap.get(ACSRecord.Client_Subject__c).Name + '\'' + ' already exists as an Additional Client/Subject');             
            }
        }            
    }
         
    public static void validateDuplicateRecord(List<Opportunity_Client_Subject__c> OptyClientNewList, Map <Id,Opportunity_Client_Subject__c> optyClientOldMap) {
        Map<String, Opportunity_Client_Subject__c> OptyClientUniqueMap = new Map<String, Opportunity_Client_Subject__c>();
        set<Id> OpportunityIdSet = new Set<Id>();
        set<Opportunity_Client_Subject__c> BulkyLoaderSet = new Set<Opportunity_Client_Subject__c>();
        for (Opportunity_Client_Subject__c OptyClient : OptyClientNewList){             
            //Check for duplicate Primary Address in same transaction
            if (((OptyClient.Client_Subject__c+''+OptyClient.Opportunity__c+''+OptyClient.Type__c) !=null) && 
                ((OptyClient.Client_Subject__c+''+OptyClient.Opportunity__c+''+OptyClient.Type__c) != 
                    (optyClientOldMap.get(OptyClient.Id).Client_Subject__c+''+optyClientOldMap.get(OptyClient.Id).Opportunity__c+''+optyClientOldMap.get(OptyClient.Id).Type__c))) {
                    
                    BulkyLoaderSet.add(OptyClient);
                    // Check for existing Primary Address       
                    if (OptyClientUniqueMap.containsKey(OptyClient.Client_Subject__c+''+OptyClient.Opportunity__c+''+OptyClient.Type__c)){
                       OptyClient.addError('Company Name : ' + '\'' + OptyClient.Client_Subject__r.Name + '\''+ 'with this Type already exists');
                    }else{
                       OptyClientUniqueMap.put((OptyClient.Client_Subject__c+''+OptyClient.Opportunity__c+''+OptyClient.Type__c), OptyClient);
                       OpportunityIdSet.add(OptyClient.Opportunity__c);
                    }
            }
            
        }
        
        for (Opportunity_Client_Subject__c optyClientRecord  : [SELECT Client_Subject__c, Opportunity__c,Type__c,Client_Subject__r.Name
                                                                FROM Opportunity_Client_Subject__c
                                                                WHERE Opportunity__c IN :OpportunityIdSet AND ID NOT IN : BulkyLoaderSet limit : Limits.getLimitQueryRows()]){
            if(OptyClientUniqueMap.containsKey(optyClientRecord.Client_Subject__c+''+optyClientRecord.Opportunity__c+''+optyClientRecord.Type__c)) {
                Opportunity_Client_Subject__c duplicateRecord = OptyClientUniqueMap.get(optyClientRecord.Client_Subject__c+''+optyClientRecord.Opportunity__c+''+optyClientRecord.Type__c);
                duplicateRecord.addError('Company Name : ' + '\'' +optyClientRecord.Client_Subject__r.Name + '\''+ 'with this Type already exists');
            }
        }                                
    }
  /*  
    //*****
    // this method is used to update Last Updation Timestamp when a new Client/Subject Added 
    public void updateLastModifiedDateTimeOnOpportunity(List<Opportunity_Client_Subject__c> triggerNew)
    {
        set<Id> setOppIds = new set<Id>();
        // get All opportunity ids for which record created.
        for(Opportunity_Client_Subject__c objClientSub : triggerNew)
        {
            setOppIds.add(objClientSub.Opportunity__c);
        }
        if(setOppIds != null && setOppIds.size() > 0)
        {
            //get All opportunity details
            List<Opportunity__c> lstOppToUpdate = [select id,Last_Modification_Date_Time__c from Opportunity__c where Id in :setOppIds];
            if(lstOppToUpdate !=null && lstOppToUpdate.size() > 0)
            {
                // update all opportunities with current date.
                for(Opportunity__c objOpp : lstOppToUpdate)
                {
                    objOpp.Last_Modification_Date_Time__c = DateTime.Now();
                }
                
                update lstOppToUpdate;
            }
        }
    } 
    */
    
    //**** Adding AdditionalClientSubject Names on opportunity fileds ***
    private void AddClientsSubjectsNamesOnOpp(List<Opportunity_Client_Subject__c> triggerNew){
        Map<Id,Id> mapOfClientSubjectWithOpp = new Map<Id,Id>();
        Map<Id,List<Opportunity_Client_Subject__c>> mapOfOppIdwithClientSubjects = new Map<Id,List<Opportunity_Client_Subject__c>>();
        List<Opportunity__c> lstOppToUpdate = new List<Opportunity__c>();
        for(Opportunity_Client_Subject__c objOppClientSub : triggerNew){
            if(objOppClientSub.Opportunity__c != null){
                mapOfClientSubjectWithOpp.put(objOppClientSub.Id, objOppClientSub.Opportunity__c);
            }
        }
        if(mapOfClientSubjectWithOpp.size() > 0){
            List<Opportunity_Client_Subject__c> ocsList = [SELECT id, Client_Subject__r.Name, Type__c, Opportunity__c, Original_Name__C FROM Opportunity_Client_Subject__c WHERE Opportunity__c In : mapOfClientSubjectWithOpp.values() AND Type__c IN ('Client','Subject') ORDER BY Primary__c desc, Client_Subject__r.Name];           
            if(ocsList != null && ocsList.size() > 0){
                for(Opportunity_Client_Subject__c objOppClientSub : ocsList){
                    if(mapOfOppIdwithClientSubjects.containsKey(objOppClientSub.Opportunity__c)){
                        List<Opportunity_Client_Subject__c> lstOppClientSub = mapOfOppIdwithClientSubjects.get(objOppClientSub.Opportunity__c);
                        lstOppClientSub.add(objOppClientSub);
                        mapOfOppIdwithClientSubjects.put(objOppClientSub.Opportunity__c,lstOppClientSub);
                    }
                    else{
                        List<Opportunity_Client_Subject__c> lstOppClientSub = new List<Opportunity_Client_Subject__c>();
                        lstOppClientSub.add(objOppClientSub);
                        mapOfOppIdwithClientSubjects.put(objOppClientSub.Opportunity__c,lstOppClientSub);
                    }
                }
                
                for(Id oppId : mapOfOppIdwithClientSubjects.keySet()){
                    Opportunity__c objOpp = new Opportunity__c(Id = oppId);
                    List<string> lstOriginalClientSubject = GetAdditionalClientsSubjectsByNames(oppId,mapOfOppIdwithClientSubjects.get(oppId));
                    objOpp.Original_Client_Name__c = lstOriginalClientSubject[0];
                    objOpp.Original_Subject_Name__c = lstOriginalClientSubject[1];
                    
                    lstOppToUpdate.add(objOpp);
                }
                
                if(lstOppToUpdate != null && lstOppToUpdate.size() > 0){
                    update lstOppToUpdate;
                }
                
            }
        }
    }

    
    private List<string> GetAdditionalClientsSubjectsByNames(String EntityId, List<Opportunity_Client_Subject__c> ocsList){
      String strOriginalClientName = '';
      String strOriginalSubjectName = '';
      List<String> lstOriginalClientSubject = new List<String>();
      if(ocsList == null)
        ocsList = [SELECT id, Client_Subject__r.Name, Type__c FROM Opportunity_Client_Subject__c WHERE Opportunity__c =: EntityId AND Type__c IN ('Client','Subject') ORDER BY Primary__c desc, Client_Subject__r.Name];
      
      if(ocsList != null && ocsList.size() > 0)
      {
        for(Opportunity_Client_Subject__c objClientSubject : ocsList)
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
    
    
    //**** UpdatesAdditionalClientsSubject Names after delete *** //
    private void UpdateAdditionalClientsSubjectsNames(Set<Id> oppIds, List<Opportunity_Client_Subject__c> triggerOld, Set<Id> setAccId){
        Map<Id,Account> mapAccount = new Map<Id,Account>([SELECT Id, Name from Account where Id in :setAccId]); 
        Map<Id,Opportunity__c> mapOpp = new Map<Id,Opportunity__c>([SELECT id, Original_Client_Name__c, Original_Subject_Name__c FROM Opportunity__c where Id in :oppIds]);
        if(mapOpp != null && mapOpp.size() > 0){
            for(Opportunity_Client_Subject__c objOppClientSub : triggerOld){
                if(mapOpp.containsKey(objOppClientSub.Opportunity__c)){
                    String strClientSubName = mapAccount.containsKey(objOppClientSub.Client_Subject__c) ? mapAccount.get(objOppClientSub.Client_Subject__c).Name : '';
                    Opportunity__c currOpp = mapOpp.get(objOppClientSub.Opportunity__c);
                    if(objOppClientSub.Type__c == 'Client'){
                        String strOppOriginalClientName = String.IsNotBlank(currOpp.Original_Client_Name__c) ? currOpp.Original_Client_Name__c : '';
                        String originalClientSubName = String.IsNotBlank(objOppClientSub.Original_Name__c) ? objOppClientSub.Original_Name__c : strClientSubName; 
                        currOpp.Original_Client_Name__c = strOppOriginalClientName.replace(originalClientSubName,'');
                    }
                    else{
                        String strOppOriginalSubName = String.IsNotBlank(currOpp.Original_Subject_Name__c) ? currOpp.Original_Subject_Name__c : '';
                        String originalClientSubName = String.IsNotBlank(objOppClientSub.Original_Name__c) ? objOppClientSub.Original_Name__c : strClientSubName; 
                        currOpp.Original_Subject_Name__c = strOppOriginalSubName.replace(originalClientSubName,'');                     
                    }
                    mapOpp.put(objOppClientSub.Opportunity__c,currOpp);
                }
            }
            
            for(Id oppId : mapOpp.keySet()){
                Opportunity__c currOpp = mapOpp.get(oppId);
                currOpp.Original_Client_Name__c = String.IsNotBlank(currOpp.Original_Client_Name__c) ? refineOppClientSubjectName(currOpp.Original_Client_Name__c) : currOpp.Original_Client_Name__c;
                currOpp.Original_Subject_Name__c = String.IsNotBlank(currOpp.Original_Subject_Name__c) ? refineOppClientSubjectName(currOpp.Original_Subject_Name__c) : currOpp.Original_Subject_Name__c;
            }
           Update mapOpp.values(); 
        }

    
    }
    
    // *** Populates OriginalNames in table when AdditionClientSubject is added ***
    public void populateOriginalClientSubjectNameOnInsert(List<Opportunity_Client_Subject__c> triggerNew){
        Set<Id> setAccIds = new Set<Id>();
        Map<Id, String> mapOfAccIdWithName = new Map<Id, String>();
        for(Opportunity_Client_Subject__c objClientSub : triggerNew){
            if(objClientSub.Client_Subject__c != null){
                setAccIds.add(objClientSub.Client_Subject__c);
            }
        }
        if(setAccIds != null && setAccIds.size() > 0){
            for(Account objAcc : [SELECT id, Name from Account WHERE Id IN :setAccIds]){
                mapOfAccIdWithName.put(objAcc.Id, objAcc.Name);
            }
            
            for(Opportunity_Client_Subject__c objClientSub : triggerNew){
                if(objClientSub.Client_Subject__c != null && mapOfAccIdWithName.containsKey(objClientSub.Client_Subject__c))
                    objClientSub.Original_Name__c = mapOfAccIdWithName.get(objClientSub.Client_Subject__c);
    
            }
        }
    }
    // *** Refines the string on Opportunity fields after AdditionClientSubject is deleted from table ***
      public string refineOppClientSubjectName(String strOppClientSubjectName){
        strOppClientSubjectName = strOppClientSubjectName.trim();
        String finalStr = '';
        String firstChar = strOppClientSubjectName.subString(0,1);
        String lastChar = strOppClientSubjectName.subString(strOppClientSubjectName.length() - 1,strOppClientSubjectName.length());
        if(firstChar == '|')
           strOppClientSubjectName = strOppClientSubjectName.subString(1,strOppClientSubjectName.length()).trim();
    
        if(lastChar == '|')
            strOppClientSubjectName = strOppClientSubjectName.removeEnd('|').trim();
        
        List<String> lstAllOriginalNames = strOppClientSubjectName.split('\\|');
        
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
	
	
	/*
	public void validateFeeAttribution(List<Opportunity_Client_Subject__c> triggerNew, Map<Id,Opportunity_Client_Subject__c> oldMap){        
        Map<Id,Decimal> oppIds = new Map<Id,Decimal>();
        Map<Id,Decimal> oppIdsVal = new Map<Id,Decimal>();
        for(Opportunity_Client_Subject__c objClientSub : triggerNew){
            if(objClientSub.FeeAttribution__c  == null)
                objClientSub.FeeAttribution__c  = 0;
            if(oppIds.get(objClientSub.Opportunity__c) != null){
                Decimal revAlloc = oppIds.get(objClientSub.Opportunity__c) + objClientSub.FeeAttribution__c ;
                if(revAlloc > 100){
                    objClientSub.addError('Fee Attribution cannot exceed 100%');
                }
                oppIds.put(objClientSub.Opportunity__c,revAlloc);
            }
            else{
                if(objClientSub.FeeAttribution__c  > 100){
                    objClientSub.addError('Fee Attribution cannot exceed 100%');
                }
                oppIds.put(objClientSub.Opportunity__c,objClientSub.FeeAttribution__c );
            }
        }
        list<Opportunity_Client_Subject__c> ecList = new list<Opportunity_Client_Subject__c>();
        if(oldMap.size() > 0){
            ecList = [select id,Opportunity__c,FeeAttribution__c  
             from Opportunity_Client_Subject__c where Opportunity__c IN: oppIds.keySet() AND Id NOT IN: oldMap.keySet()];
        }
        else{
            ecList = [select id,Opportunity__c,FeeAttribution__c  
             from Opportunity_Client_Subject__c where Opportunity__c IN: oppIds.keySet()];
        }
        for(Opportunity_Client_Subject__c ec : ecList){
            if(ec.FeeAttribution__c  == null)
                ec.FeeAttribution__c  = 0;
            if(oppIdsVal.get(ec.Opportunity__c) != null){
                Decimal revAlloc = oppIdsVal.get(ec.Opportunity__c) + ec.FeeAttribution__c ;
                oppIdsVal.put(ec.Opportunity__c,revAlloc);
            }
            else{
                oppIdsVal.put(ec.Opportunity__c,ec.FeeAttribution__c );
            }
        }
        for(Opportunity_Client_Subject__c ec : triggerNew){
            if(ec.FeeAttribution__c  == null)
                ec.FeeAttribution__c  = 0;
            if(oppIdsVal.get(ec.Opportunity__c) != null){
                if((oppIds.get(ec.Opportunity__c) + oppIdsVal.get(ec.Opportunity__c)) > 100){
                    ec.addError('Fee Attribution cannot exceed 100%');
                }
            }
        }
    }*/
    public void validateClientHoldings(List<Opportunity_Client_Subject__c> triggerNew, Map<Id,Opportunity_Client_Subject__c> oldMap){
        Map<Id,Decimal> oppIds = new Map<Id,Decimal>();
        Map<Id,Decimal> oppIdsVal = new Map<Id,Decimal>();
        for(Opportunity_Client_Subject__c objClientSub : triggerNew){
            if(objClientSub.ClientHoldings__c == null)
                objClientSub.ClientHoldings__c = 0;
            if(oppIds.get(objClientSub.Opportunity__c) != null){
                Decimal revAlloc = oppIds.get(objClientSub.Opportunity__c) + objClientSub.ClientHoldings__c;
                if(revAlloc > 100){
                    objClientSub.addError('Client Holdings cannot exceed 100%');
                }
                oppIds.put(objClientSub.Opportunity__c,revAlloc);
            }
            else{
                if(objClientSub.ClientHoldings__c > 100){
                    objClientSub.addError('Client Holdings cannot exceed 100%');
                }
                oppIds.put(objClientSub.Opportunity__c,objClientSub.ClientHoldings__c);
            }
        }
        list<Opportunity_Client_Subject__c> ecList = new list<Opportunity_Client_Subject__c>();
        if(oldMap.size() > 0){
            ecList = [select id,Opportunity__c,ClientHoldings__c 
             from Opportunity_Client_Subject__c where Opportunity__c IN: oppIds.keySet() AND Id NOT IN: oldMap.keySet()];
        }
        else{
            ecList = [select id,Opportunity__c,ClientHoldings__c 
             from Opportunity_Client_Subject__c where Opportunity__c IN: oppIds.keySet()];
        }
        for(Opportunity_Client_Subject__c ec : ecList){
            if(ec.ClientHoldings__c == null)
                ec.ClientHoldings__c = 0;
            if(oppIdsVal.get(ec.Opportunity__c) != null){
                Decimal revAlloc = oppIdsVal.get(ec.Opportunity__c) + ec.ClientHoldings__c;
                oppIdsVal.put(ec.Opportunity__c,revAlloc);
            }
            else{
                oppIdsVal.put(ec.Opportunity__c,ec.ClientHoldings__c);
            }
        }
        for(Opportunity_Client_Subject__c ec : triggerNew){
            if(ec.ClientHoldings__c == null)
                ec.ClientHoldings__c = 0;
            if(oppIdsVal.get(ec.Opportunity__c) != null){
                if((oppIds.get(ec.Opportunity__c) + oppIdsVal.get(ec.Opportunity__c)) > 100){
                    ec.addError('Client Holdings cannot exceed 100%');
                }
            }
        }
    }
    public void validateRevenueAllocation(List<Opportunity_Client_Subject__c> triggerNew, Map<Id,Opportunity_Client_Subject__c> oldMap){
        Map<Id,Decimal> oppIds = new Map<Id,Decimal>();
        Map<Id,Decimal> oppIdsVal = new Map<Id,Decimal>();
        for(Opportunity_Client_Subject__c objClientSub : triggerNew){
            if(objClientSub.RevenueAllocation__c == null)
                objClientSub.RevenueAllocation__c = 0;
            if(oppIds.get(objClientSub.Opportunity__c) != null){
                Decimal revAlloc = oppIds.get(objClientSub.Opportunity__c) + objClientSub.RevenueAllocation__c;
                if(revAlloc > 100){
                    objClientSub.addError('Revenue Allocation cannot exceed 100%');
                }
                oppIds.put(objClientSub.Opportunity__c,revAlloc);
            }
            else{
                if(objClientSub.RevenueAllocation__c > 100){
                    objClientSub.addError('Revenue Allocation cannot exceed 100%');
                }
                oppIds.put(objClientSub.Opportunity__c,objClientSub.RevenueAllocation__c);
            }
        }
        list<Opportunity_Client_Subject__c> ecList = new list<Opportunity_Client_Subject__c>();
        if(oldMap.size() > 0){
            ecList = [select id,Opportunity__c,RevenueAllocation__c 
             from Opportunity_Client_Subject__c where Opportunity__c IN: oppIds.keySet() AND Id NOT IN: oldMap.keySet()];
        }
        else{
            ecList = [select id,Opportunity__c,RevenueAllocation__c 
             from Opportunity_Client_Subject__c where Opportunity__c IN: oppIds.keySet()];
        }
        for(Opportunity_Client_Subject__c ec : ecList){
            if(ec.RevenueAllocation__c == null)
                ec.RevenueAllocation__c = 0;
            if(oppIdsVal.get(ec.Opportunity__c) != null){
                Decimal revAlloc = oppIdsVal.get(ec.Opportunity__c) + ec.RevenueAllocation__c;
                oppIdsVal.put(ec.Opportunity__c,revAlloc);
            }
            else{
                oppIdsVal.put(ec.Opportunity__c,ec.RevenueAllocation__c);
            }
        }
        for(Opportunity_Client_Subject__c ec : triggerNew){
            if(ec.RevenueAllocation__c == null)
                ec.RevenueAllocation__c = 0;
            if(oppIdsVal.get(ec.Opportunity__c) != null){
                if((oppIds.get(ec.Opportunity__c) + oppIdsVal.get(ec.Opportunity__c)) > 100){
                    ec.addError('Revenue Allocation cannot exceed 100%');
                }
            }
        }
    }
    public void validateKeyCreditor(List<Opportunity_Client_Subject__c> triggerNew, Map<Id,Opportunity_Client_Subject__c> oldMap){
        Map<Id,Decimal> oppIds = new Map<Id,Decimal>();
        Map<Id,Decimal> oppIdsVal = new Map<Id,Decimal>();
        for(Opportunity_Client_Subject__c objClientSub : triggerNew){
            if(objClientSub.KeyCreditorWeighting__c == null)
                objClientSub.KeyCreditorWeighting__c = 0;
            if(oppIds.get(objClientSub.Opportunity__c) != null){
                Decimal revAlloc = oppIds.get(objClientSub.Opportunity__c) + objClientSub.KeyCreditorWeighting__c;
                if(revAlloc > 100){
                    objClientSub.addError('Key Creditor Weighting cannot exceed 100%');
                }
                oppIds.put(objClientSub.Opportunity__c,revAlloc);
            }
            else{
                if(objClientSub.KeyCreditorWeighting__c > 100){
                    objClientSub.addError('Key Creditor Weighting cannot exceed 100%');
                }
                oppIds.put(objClientSub.Opportunity__c,objClientSub.KeyCreditorWeighting__c);
            }
        }
        list<Opportunity_Client_Subject__c> ecList = new list<Opportunity_Client_Subject__c>();
        if(oldMap.size() > 0){
            ecList = [select id,Opportunity__c,KeyCreditorWeighting__c 
             from Opportunity_Client_Subject__c where Opportunity__c IN: oppIds.keySet() AND Id NOT IN: oldMap.keySet()];
        }
        else{
            ecList = [select id,Opportunity__c,KeyCreditorWeighting__c 
             from Opportunity_Client_Subject__c where Opportunity__c IN: oppIds.keySet()];
        }
        for(Opportunity_Client_Subject__c ec : ecList){
            if(ec.KeyCreditorWeighting__c == null)
                ec.KeyCreditorWeighting__c = 0;
            if(oppIdsVal.get(ec.Opportunity__c) != null){
                Decimal revAlloc = oppIdsVal.get(ec.Opportunity__c) + ec.KeyCreditorWeighting__c;
                oppIdsVal.put(ec.Opportunity__c,revAlloc);
            }
            else{
                oppIdsVal.put(ec.Opportunity__c,ec.KeyCreditorWeighting__c);
            }
        }
        for(Opportunity_Client_Subject__c ec : triggerNew){
            if(ec.KeyCreditorWeighting__c == null)
                ec.KeyCreditorWeighting__c = 0;
            if(oppIdsVal.get(ec.Opportunity__c) != null){
                if((oppIds.get(ec.Opportunity__c) + oppIdsVal.get(ec.Opportunity__c)) > 100){
                    ec.addError('Key Creditor Weighting cannot exceed 100%');
                }
            }
        }
    }
}