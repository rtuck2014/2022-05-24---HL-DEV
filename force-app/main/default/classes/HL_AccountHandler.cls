/*
* Name: HL_AccountHandler
* Created Date: 4/15/2015
* Description: Apex Handler class for Account object
* Modified Date: 11/01/2019
* Description: Commented out call to 'populateCleanStatus' method and code that sets 'acc.CleanStatus' to address data.com issue
* Modified Date: 11/04/2019
* Description:  Added the following methods for ERP Integration. The new methods are invoked from OnBeforeUpdate method.
*   a) updatePrimaryBillingContactData()
*   b) setERPAccountContactFlags()
*   c) clearERPUpdateFlags()
*/

public with sharing class HL_AccountHandler{
    private static Map<String, String> mapEUCountries = new Map<String, String>();
        
    static {
        mapEUCountries = new Map<String, String>();

        //Added as part of State/Country Picklist
        //Retrieve list of EU Countries from custom meta data
        for (EU_Country_List__mdt euCountry : [
            SELECT DeveloperName, Country_Name__c 
            FROM EU_Country_List__mdt 
            WHERE Active__c = true]) {

            mapEUCountries.put(euCountry.DeveloperName, euCountry.Country_Name__c);
        }
    }

    private boolean IsExecuting = false;
    private integer BatchSize = 0;
    private static Map<Id, List<Account>> parentIdToAccountListMap;
    private static Map<Id, Set<Id>> parentIdToChildSetMap;

    public HL_AccountHandler(boolean executing, integer size) {
        IsExecuting = executing;
        BatchSize = size;
    }
    public void OnBeforeUpdate(List<Account> newAccountList , List<Account> oldAccountList,  Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap) { 
                for(Account a : newAccountList){
            if((a.BillingStreet != oldAccountMap.get(a.Id).BillingStreet ||
            a.BillingCity != oldAccountMap.get(a.Id).BillingCity ||                        
            a.BillingState != oldAccountMap.get(a.Id).BillingState ||
            a.BillingPostalCode != oldAccountMap.get(a.Id).BillingPostalCode ||
            a.BillingCountry != oldAccountMap.get(a.Id).BillingCountry) && (a.DNBoptimizer__DNB_D_U_N_S_Number__c != null || a.DNBoptimizer__DNB_D_U_N_S_Number__c != ''  || a.DNBoptimizer__DnBCompanyRecord__c != null || a.DNBoptimizer__DnBCompanyRecord__c != '')){
                a.DNBoptimizer__DnBCompanyRecord__c = null;
                a.DNBoptimizer__DNB_D_U_N_S_Number__c = null;
            }
        }
        // To populate clean status based on check box field value by Data hygiene user
        // 01Nov2019 - Commented out call to method to address data.com issue
        //populateCleanStatus(newAccountList, newAccountMap, oldAccountMap); 
        clearERPUpdateFlags(newAccountList, oldAccountMap); 
        updatePrimaryBillingContactData(newAccountList, oldAccountMap);  
        setERPAccountContactFlags(newAccountList, oldAccountMap);
    } 
    
    public void OnBeforeInsert(List<Account> accountList) {
        Set<Id> parentIdSet = new Set<Id>();
        Map<Id, Id> accountIdToCapIQIdMatchMap = new Map<Id, Id>();

        for (Account a : accountList) {
            if (!String.isBlank(a.ParentId)){
                parentIdSet.add(a.ParentId);

                if(!String.isBlank(a.CapIQ_Company__c)){
                    accountIdToCapIQIdMatchMap.put(a.Id, a.CapIQ_Company__c);
                    accountIdToCapIQIdMatchMap.put(a.ParentId, a.CapIQ_Company__c);
                }
            }
        }

        if(parentIdSet.size() > 0)
            UpdateParentFieldOnChildBeforeInsert(accountList, parentIdSet);

        if(accountIdToCapIQIdMatchMap.size() > 0)
            UpdateRelatedCompanyCapIQIDs(null, accountIdToCapIQIdMatchMap);

        IsEUForCF(accountList);
    }

    private void UpdateParentFieldOnChildBeforeInsert(List<Account> accountList, Set<Id> parentIdSet) {
        //Map used to store the filtered Account
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Ultimate_Parent__c FROM Account WHERE Id IN:parentIdSet]);

        for (Account a : accountList) {
            if (!String.isBlank(a.ParentId) && accountMap.containsKey(a.ParentId)) {
                //If Ultimate Parent Id is null then update the Child with its Parent Account Id as Ultimate Parent.
                a.Ultimate_Parent__c = (!String.isBlank(accountMap.get(a.ParentId).Ultimate_Parent__c))
                    ? accountMap.get(a.ParentId).Ultimate_Parent__c
                    : a.ParentId;
            }
        }
    }

    private void UpdateRelatedCompanyCapIQIDs(Set<Id> accountIdSet, Map<Id, Id> accountIdToCapIQIdMatchMap){
        List<Account> accountUpdateList = new List<Account>();
        //Map to store the parent and child ids to the capiq id
        List<Account> capIQAccountList = new List<Account>();

        //Get all accounts part of the CapIQ Updates/Assignment
        for(Account a : [SELECT ParentId, CapIQ_Company__c
                         FROM Account
                         WHERE CapIQ_Company__c IN: accountIdToCapIQIdMatchMap.values()]){
                             accountIdToCapIQIdMatchMap.put(a.Id, a.CapIQ_Company__c);
                             if(!String.isBlank(a.ParentId))
                                 accountIdToCapIQIdMatchMap.put(a.ParentId, a.CapIQ_Company__c);
                             capIQAccountList.add(a);
                         }

        if(accountIdSet == null)
            accountIdSet = new Set<Id>();

        //Get all of the related accounts without a CapIQ Company Assignment
       /*   for(Account a : [SELECT ParentId, CapIQ_Company__c
                         FROM Account
                         WHERE (Id IN: accountIdToCAPIQIdMatchMap.keySet() OR ParentId IN: accountIdToCAPIQIdMatchMap.keySet()) AND CapIQ_Company__c = null AND Id NOT IN: accountIdSet]){
                             //Verify we are not updating one of the accounts already in the trigger context
                             Id capIQId = accountIdToCapIQIdMatchMap.get(a.Id);

                             if(String.isBlank(capIQId) && !String.isBlank(a.ParentId))
                                 capIQId = accountIdToCapIQIdMatchMap.get(a.ParentId);

                             if(!String.isBlank(capIQId)){
                                 a.CapIQ_Company__c = capIQId;
                                 accountUpdateList.add(a);
                             }
                         }

        if(accountUpdateList.size() > 0)
            update accountUpdateList;  */
    } 

    //Update ultimate parent field on child records.
    public void OnAfterUpdate(Map<Id, Account> oldAccountMap, Map<Id, Account> newAccountMap) {
        this.UpdateParentFieldOnChildAfterUpdate(oldAccountMap, newAccountMap);
            Set<Id> acctsAddressUpdate = new Set<Id>();


        Map<Id, Id> accountIdToCapIQIdMatchMap = new Map<Id, Id>();
        //Check if the CapIQ Company Link has been Updated
        for(Account a : newAccountMap.values()){
            if(!String.isBlank(a.CapIQ_Company__c) && oldAccountMap.get(a.Id).CapIQ_Company__c != newAccountMap.get(a.Id).CapIQ_Company__c){
                accountIdToCapIQIdMatchMap.put(a.Id, a.CapIQ_Company__c);
                if(!String.isBlank(a.ParentId))
                    accountIdToCapIQIdMatchMap.put(a.ParentId, a.CapIQ_Company__c);
            }
            
            if(a.BillingStreet != oldAccountMap.get(a.Id).BillingStreet ||
            a.BillingCity != oldAccountMap.get(a.Id).BillingCity ||                        
            a.BillingState != oldAccountMap.get(a.Id).BillingState ||
            a.BillingPostalCode != oldAccountMap.get(a.Id).BillingPostalCode ||
            a.BillingCountry != oldAccountMap.get(a.Id).BillingCountry){
                acctsAddressUpdate.add(a.Id); 
            }
            
        }

        if(accountIdToCapIQIdMatchMap.size() > 0)
            UpdateRelatedCompanyCapIQIDs(newAccountMap.keySet(), accountIdToCapIQIdMatchMap);
            
      // this.updateModifiedDateOnOpportunity(oldAccountMap, newAccountMap);
       this.captureAccountNameChange(oldAccountMap, newAccountMap);
        
              if(!acctsAddressUpdate.isEmpty()){
                HL_ContactHandler.SyncAccountAddressToContact(acctsAddressUpdate);
            }
    }


    private void UpdateParentFieldOnChildAfterUpdate(Map<Id, Account> oldAccountMap, Map<Id, Account> newAccountMap) {
        Set<Id> parentIdSet = new Set<Id>();
        Set<Id> ultimateParentIdSet = new Set<Id>();

        parentIdToAccountListMap = new Map<Id, List<Account>>();
        Map<Id, Account> accountMap = new Map<Id, Account>();

        //getting the utimate id to get all the related child records.
        for (Account a : newAccountMap.values()) {
            if (a.ParentId != oldAccountMap.get(a.Id).ParentId) {
                if (a.ParentId == null)
                    parentIdSet.add(a.Id);
                else if (a.ParentId != null && !newAccountMap.containsKey(a.ParentId))
                    parentIdSet.add(a.ParentId);

                if (!String.isBlank(oldAccountMap.get(a.Id).Ultimate_Parent__c))
                    ultimateParentIdSet.add(oldAccountMap.get(a.Id).Ultimate_Parent__c);
                else if (oldAccountMap.get(a.Id).ParentId == null)
                    ultimateParentIdSet.add(a.Id);

                if (!String.isBlank(a.ParentId) && parentIdToAccountListMap.containsKey(a.ParentId))
                    parentIdToAccountListMap.get(a.ParentId).add(a);
                else if (!String.isBlank(a.ParentId))
                    parentIdToAccountListMap.put(a.ParentId, new List<Account> {a});

                accountMap.put(a.Id, a);
            }
        }

        if (!accountMap.isEmpty())
            updateUltimateParent(accountMap, parentIdSet, ultimateParentIdSet);
    }

    //Update the Ultimate Parent Field on Child Records
    public void OnBeforeDelete(Map<Id, Account> oldAccountMap) {
        this.UpdateParentFieldOnChildBeforeDelete(oldAccountMap);
    }

    private void UpdateParentFieldOnChildBeforeDelete(Map<Id, Account> oldAccountMap) {
        parentIdToAccountListMap = new Map<Id, List<Account>>();
        parentIdToChildSetMap = new Map<Id, Set<Id>>();
        Set<Id> ultimateParentIdSet = new Set<Id>();

        //getting the utimate id to get all the related child records.
        for (Account a : oldAccountMap.values()) {
            //checks to set ultimate Id if not null else assigns the Parent Id as the Ultimate Id
            if (!String.isBlank(a.Ultimate_Parent__c))
                ultimateParentIdSet.add(oldAccountMap.get(a.Id).Ultimate_Parent__c);
            else
                ultimateParentIdSet.add(a.Id);
        }

        for (Account a : [SELECT
                          ParentId,
                          Ultimate_Parent__c
                          FROM Account
                          WHERE ParentId IN: oldAccountMap.keySet()
                          AND Id NOT IN: oldAccountMap.keySet()]) {
                              if (parentIdToChildSetMap.containsKey(a.ParentId))
                                  parentIdToChildSetMap.get(a.ParentId).add(a.Id);
                              else
                                  parentIdToChildSetMap.put(a.ParentId, new Set<Id> {a.Id});
                          }

        for (Account a : [SELECT
                          Ultimate_Parent__c,
                          ParentId
                          FROM Account
                          WHERE Ultimate_Parent__c IN: ultimateParentIdSet
                          AND Id NOT IN: oldAccountMap.keySet()]) {
                              if (parentIdToAccountListMap.containsKey(a.ParentId))
                                  parentIdToAccountListMap.get(a.ParentId).add(a);
                              else
                                  parentIdToAccountListMap.put(a.ParentId, new List<Account> {a});
                          }
    }

    //Update the Ultimate Parent Field on Child Records
    public void OnAfterDelete(Map<Id, Account> oldAccountMap) {
        this.UpdateParentFieldOnChildAfterDelete(oldAccountMap);
        this.HandleMergeScenarios(oldAccountMap);
    }

    private void UpdateParentFieldOnChildAfterDelete(Map<Id, Account> oldAccountMap) {
        List<Account> accountUpdateList = new List<Account>();

        for (Account a : oldAccountMap.values()) {
            if (parentIdToChildSetMap.containsKey(a.Id)) {
                for (Id childId : parentIdToChildSetMap.get(a.Id)) {
                    accountUpdateList.add(new Account(Id = childId, Ultimate_Parent__c = null));
                    if (parentIdToAccountListMap.containsKey(childId)) {
                        accountUpdateList.addAll(updateChildRecordUltimateParent(parentIdToAccountListMap.get(childId), oldAccountMap.keySet(), childId));
                    }
                }
            }
        }

        //Update the Account and its child record with the Ultimate Parent Id
        if (!accountUpdateList.isEmpty())
            update accountUpdateList;
    }

    //Update the Ultimate Parent Field on Child Records
    private void UpdateUltimateParent(Map<Id, Account> accountMap, Set<Id> parentIdSet, Set<Id> ultimateParentIdSet) {
        List<Account> topParentAccountList = [SELECT Id, Ultimate_Parent__c, ParentId FROM Account WHERE Id IN: parentIdSet ];
        List<Account> accountUpdateList = new List<Account>();

        for (Account a : [SELECT
                          Ultimate_Parent__c,
                          ParentId
                          FROM Account
                          WHERE Ultimate_Parent__c IN: ultimateParentIdSet
                          AND Id NOT IN: accountMap.keySet()]) {
                              accountMap.put(a.Id, a);
                              if (a.ParentId != null) {
                                  if (parentIdToAccountListMap.containsKey(a.ParentId))
                                      parentIdToAccountListMap.get(a.ParentId).add(a);
                                  else
                                      parentIdToAccountListMap.put(a.ParentId, new List<Account> {a});
                              }
                          }
        //Iterate on updated Account records and calls the method to get the child record to update with Ultimate Parent and Parent Id.
        for (Account a : topParentAccountList) {
            if (a.ParentId != null && parentIdToAccountListMap.containsKey(a.Id)) {
                accountUpdateList.addAll(updateChildRecordUltimateParent(parentIdToAccountListMap.get(a.Id),
                                                                         parentIdSet,
                                                                         a.Ultimate_Parent__c));
            }
            else if (a.ParentId == null && parentIdToAccountListMap.containsKey(a.Id)) {
                accountUpdateList.add(new Account(Id = a.Id, Ultimate_Parent__c = null));
                accountUpdateList.addAll(updateChildRecordUltimateParent(parentIdToAccountListMap.get(a.Id),
                                                                         parentIdSet,
                                                                         a.Id));
            }

            else if (a.ParentId == null) {
                accountUpdateList.add(new Account(Id = a.Id, Ultimate_Parent__c = null));
            }
        }
        //Update the Account and its child record with the Ultimate Parent Id and its Parent Id.
        if (!accountUpdateList.isEmpty())
            update accountUpdateList;
    }

    //Update ultimate parent field on child records
    private List<Account> UpdateChildRecordUltimateParent(List<Account> accountList, Set<Id> setParentChangeId, Id ultimateId) {
        List<Account> accountUpdateList = new List<Account>();//List to return child Account records to update.
        //getting the utimate id to get all the related child records.
        for (Account a : accountList) {
            //check if Account Record contains any child records
            if (!setParentChangeId.contains(a.Id)) {
                if (!String.isBlank(a.ParentId) && parentIdToAccountListMap.containsKey(a.Id)) {
                    accountUpdateList.add(new Account(Id = a.Id, Ultimate_Parent__c = ultimateId));
                    //calls the method itself in recursion till it gets all its child
                    accountUpdateList.addAll(updateChildRecordUltimateParent(parentIdToAccountListMap.get(a.Id), setParentChangeId, ultimateId));
                }
                else if (!String.isBlank(a.ParentId)) {
                    accountUpdateList.add(new Account(Id = a.Id, Ultimate_Parent__c = ultimateId));
                }
            }
        }
        return accountUpdateList;//return list of child Accounts of particular parents to update its Ultimate Parent and its Parent
    }

    private void HandleMergeScenarios(Map<Id, Account> oldAccountMap){
        MergedData mergedData = this.GetMergedData(oldAccountMap);
        this.UpdateEventRecords(mergedData);
        this.InsertAccountHistoryOfMergedAccounts(mergedData);
    }

    private MergedData GetMergedData(Map<Id, Account> oldAccountMap) {
        MergedData mergedData = new MergedData();

        for (Account a : oldAccountMap.values()) {
            if (!String.isBlank(a.MasterRecordId)) {
                if (mergedData.MasterIdToMergedIdsMap.get(a.MasterRecordId) == null)
                    mergedData.MasterIdToMergedIdsMap.put(a.MasterRecordId, new Set<Id> {a.Id});
                else {
                    Set<Id> mergedIdSet = mergedData.MasterIdToMergedIdsMap.get(a.MasterRecordId);
                    mergedIdSet.add(a.Id);
                    mergedData.MasterIdToMergedIdsMap.put(a.MasterRecordId, mergedIdSet);
                }

                mergedData.MergedAccountMap.put(a.Id, a);
            }
        }

        //Create a Map of Merged Account Id to New Account, The New Account Must be Queried for as we need other Account Fields from the Record
        for (Account a : [SELECT Name FROM Account WHERE Id IN: mergedData.MasterIdToMergedIdsMap.keySet()]) {
            Set<Id> mergedIdSet = mergedData.MasterIdToMergedIdsMap.get(a.Id);
            for (Id mergedId : mergedIdSet)
                mergedData.MergedIdToNewAccountMap.put(mergedId, a);
        }

        return mergedData;
    }

    //Handle Merge of Contacts to Update the Event Records
    private List<Event> UpdateEventRecords(MergedData mergedData) {
        List<Event> eventUpdateList = new List<Event>();

        if (mergedData.MergedAccountMap.size() > 0) {
            for (Event e : [SELECT Primary_External_Contact_Company_Id__c
                            FROM Event
                            WHERE Primary_External_Contact_Company_Id__c IN: mergedData.MergedAccountMap.keySet()]) {
                                Account masterAccount = mergedData.MergedIdToNewAccountMap.get(e.Primary_External_Contact_Company_Id__c);

                                if (masterAccount != null) {
                                    e.Primary_External_Contact_Company_Id__c = masterAccount.Id;
                                    eventUpdateList.add(e);
                                }

                            }
        }

        if (eventUpdateList.size() > 0)
            update eventUpdateList;

        return eventUpdateList;
    }
    
    //****
    //Create account history after merging of any Account.
    //****
  private void InsertAccountHistoryOfMergedAccounts(MergedData mergedData) {
        
        List<Account_Name_History__c> lstAccountHistoryToInsert = new List<Account_Name_History__c>();
           for(Id oldAccId : mergedData.MergedAccountMap.keySet()){
                Account_Name_History__c objAccountHistory = new Account_Name_History__c();
                objAccountHistory.AccountId__c = mergedData.MergedIdToNewAccountMap.get(oldAccId).Id;
                objAccountHistory.Change_Source__c = 'Merged';
                objAccountHistory.Effective_Date__c = System.Now();
                objAccountHistory.Original_AccountId__c = mergedData.MergedAccountMap.get(oldAccId).Id;
                objAccountHistory.Original_Account_Name__c = mergedData.MergedAccountMap.get(oldAccId).Name;
                objAccountHistory.Name = mergedData.MergedIdToNewAccountMap.get(oldAccId).Name;
                objAccountHistory.Current_Account_ID__c = mergedData.MergedIdToNewAccountMap.get(oldAccId).Id;
               
                lstAccountHistoryToInsert.add(objAccountHistory);
        }
        
        List<Account_Name_History__c> lstExistingAccHistory = [SELECT Id, Current_Account_ID__c FROM Account_Name_History__c where Current_Account_ID__c in :mergedData.MergedAccountMap.keySet()];
        if(lstExistingAccHistory != null && lstExistingAccHistory.size() > 0){
            for(Account_Name_History__c objAccountHistory : lstExistingAccHistory){
                objAccountHistory.Current_Account_ID__c = mergedData.MergedIdToNewAccountMap.get(objAccountHistory.Current_Account_ID__c).Id;
            }
            
            update lstExistingAccHistory;
        }
 
            if(lstAccountHistoryToInsert != null && lstAccountHistoryToInsert.size() > 0)
            insert lstAccountHistoryToInsert;
   
   }
   
   //******
    // Create account history after Name Updated on any Account
    //*********
   private void captureAccountNameChange(Map<Id, Account> oldAccountMap, Map<Id, Account> newAccountMap)
   {
        List<Account_Name_History__c> lstAccountHistoryToInsert = new List<Account_Name_History__c>();
        Map<Id,String> mapOfAccIdWithOldName = new Map<Id,String>();
        Map<Id,String> mapOfAccIdWithNewName = new Map<Id,String>();
        for(Account objAcc : newAccountMap.values()){
                Account objAccOld = oldAccountMap.get(objAcc.Id);

                if(objAcc.Name != objAccOld.Name)
                {
                    mapOfAccIdWithOldName.put(objAccOld.Id,objAccOld.Name);
                    mapOfAccIdWithNewName.put(objAccOld.Id,objAcc.Name);
                    Account_Name_History__c objAccountHistory = new Account_Name_History__c();
                    objAccountHistory.AccountId__c = objAcc.Id;
                    objAccountHistory.Change_Source__c = 'Name Change';
                    objAccountHistory.Effective_Date__c = System.NOw();
                    objAccountHistory.Original_AccountId__c = objAcc.Id;
                    objAccountHistory.Original_Account_Name__c = objAccOld.Name;
                    objAccountHistory.Name = objAcc.Name;
                    objAccountHistory.Current_Account_ID__c = objAcc.Id;
                    
                    lstAccountHistoryToInsert.add(objAccountHistory);
                }
        }
        
           if(lstAccountHistoryToInsert != null && lstAccountHistoryToInsert.size() > 0)
        insert lstAccountHistoryToInsert;
    }
    
    private class MergedData {
        public Map<Id, Account> MergedAccountMap {get; set;}
        public Map<Id, Account> MergedIdToNewAccountMap {get; set;}
        public Map<Id, Set<Id>> MasterIdToMergedIdsMap {get; set;}

        public MergedData() {
            this.MergedAccountMap = new Map<Id, Account>();
            this.MergedIdToNewAccountMap = new Map<Id, Account>();
            this.MasterIdToMergedIdsMap = new Map<Id, Set<Id>>();
        }
    }
    
    //The Set below is a predetermined list that CF has given to classify an Account as EU based on BillingCountry
    Set<String> EUCountries = new Set<String>{'armenia',
                                                'egypt',
                                                'iran',
                                                'iraq',
                                                'israel',
                                                'jordan',
                                                'kuwait',
                                                'lebanon',
                                                'oman',
                                                'palestine',
                                                'qatar',
                                                'saudi arabia',
                                                'syria',
                                                'turkey',
                                                'united arab emirates',
                                                'yemen',
                                                'bahrain',
                                                'algeria',
                                                'angola',
                                                'benin',
                                                'botswana',
                                                'burkina faso',
                                                'burundi',
                                                'cameroon',
                                                'cape verde',
                                                'central african republic',
                                                'chad',
                                                'comoros',
                                                'democratic republic of the congo',
                                                'djibouti',
                                                'egypt',
                                                'equatorial guinea',
                                                'eritrea',
                                                'ethiopia',
                                                'gabon',
                                                'gambia',
                                                'ghana',
                                                'guinea',
                                                'guinea-bissau',
                                                'ivory coast',
                                                'kenya',
                                                'lesotho',
                                                'liberia',
                                                'libya',
                                                'madagascar',
                                                'malawi',
                                                'mali',
                                                'mauritania',
                                                'mauritius',
                                                'mayotte',
                                                'morocco',
                                                'mozambique',
                                                'namibia',
                                                'niger',
                                                'nigeria',
                                                'republic of the congo',
                                                'rwanda',
                                                'réunion',
                                                'saint helena, ascension and tristan da cunha',
                                                'senegal',
                                                'seychelles',
                                                'sierra leone',
                                                'somalia',
                                                'south africa',
                                                'south sudan',
                                                'sudan',
                                                'swaziland',
                                                'são tomé and príncipe',
                                                'tanzania',
                                                'togo',
                                                'tunisia',
                                                'uganda',
                                                'western sahara',
                                                'zambia',
                                                'zimbabwe',
                                                'deutschland',
                                                'isle of man',
                                                'russia',
                                                'albania',
                                                'andorra',
                                                'armenia',
                                                'austria',
                                                'azerbaijan',
                                                'belarus',
                                                'belgium',
                                                'bosnia and herzegovina',
                                                'bulgaria',
                                                'croatia',
                                                'cyprus',
                                                'czech republic',
                                                'denmark',
                                                'estonia',
                                                'finland',
                                                'france',
                                                'georgia',
                                                'germany',
                                                'greece',
                                                'hungary',
                                                'iceland',
                                                'ireland',
                                                'italy',
                                                'latvia',
                                                'liechtenstein',
                                                'lithuania',
                                                'luxembourg',
                                                'macedonia',
                                                'malta',
                                                'moldova',
                                                'monaco',
                                                'montenegro',
                                                'netherlands',
                                                'norway',
                                                'poland',
                                                'portugal',
                                                'romania',
                                                'san marino',
                                                'serbia',
                                                'slovakia',
                                                'slovenia',
                                                'spain',
                                                'sweden',
                                                'switzerland',
                                                'ukraine',
                                                'united kingdom',
                                                'vatican city'};

    //This method updates a checkbox on the Account to reflect CF's EU classification
    public void IsEUForCF(List<Account> accList){
        List<Account> accsToUpdate = new List<Account>();
        
        // GM Jan 6, 2022 - this implementation causes too many SOQL queries, commented out and replaced with static initialization at top of class
        /*
        //Added as part of State/Country Picklist
        //Retrieve list of EU Countries from custom meta data
        Map<String, String> mapEUCountries = new Map<String, String>();
        
        for (EU_Country_List__mdt euCountry : [SELECT DeveloperName, Country_Name__c FROM EU_Country_List__mdt WHERE Active__c = true]){
            mapEUCountries.put(euCountry.DeveloperName, euCountry.Country_Name__c);
        }
        */
        
        for(Account a : accList){
            String country = a.BillingCountryCode;
            //if(!String.isBlank(country) && EUCountries.contains(country.toLowerCase())){
            //Modified as part of State/Country Picklist - use map instead of list
            if(!String.isBlank(country) && mapEUCountries.get(country) != null){
                a.Is_Client_EU_CF__c = TRUE;
            }
            else
                a.Is_Client_EU_CF__c = FALSE;
            accsToUpdate.add(a);
        }

    }
  
    private void populateCleanStatus(List<Account> newAccountList, Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap){
    for(Account acc: newaccountList)
        {
         if(acc.Clean_Job_By_Pass__c)
         {
             //01Nov2019 - Commented out line to address data.com issue
             //acc.CleanStatus = 'Skipped';
         }         
         else if(oldAccountMap.get(acc.id).Clean_Job_By_Pass__c && !newAccountMap.get(acc.id).Clean_Job_By_Pass__c){
             // 'Pending' is API vlaue for clean status 'Not Compared'
             //01Nov2019 - Commented out line to address data.com issue
             //acc.CleanStatus = 'Pending';
         }                  
        }
    }
    
    //This method populates ERP Contact fields if Primary_Billing_Contact__c is updated
    public static void updatePrimaryBillingContactData(List<Account> newAccountList, Map<Id, Account> oldAccountMap){
        Set<Id> contactIdSet = new Set<Id>();
        for(Account account : newAccountList){
            if(Trigger.isInsert ||
               (trigger.isUpdate &&
                account.Primary_Billing_Contact__c != oldAccountMap.get(account.Id).Primary_Billing_Contact__c)){
                    contactIdSet.add(account.Primary_Billing_Contact__c);
            }
        } 
        
        Map<Id,Contact> contactMap  = new Map<Id,Contact>();
        if(contactIdSet.size()>0){
            contactMap  = new Map<Id,Contact>([SELECT Id, FirstName, Lastname, Phone, Email, ERP_ID__c, ERP_Contact_Point_Email_ID__c,
                                                                  ERP_Contact_Point_Phone_ID__c, ERP_Contact_Point_Relationship_ID__c, ERP_Person_Party_ID__c
                                                             FROM Contact WHERE Id IN: contactIdSet]);
        }
        
        for(Account account : newAccountList){
            String primaryBillingContact = account.Primary_Billing_Contact__c;
            if(contactMap.containsKey(primaryBillingContact)){
                Contact billcontact = contactMap.get(primaryBillingContact);
                account.ERP_Contact_First_Name__c = billcontact.FirstName;
                account.ERP_Contact_Last_Name__c = billcontact.LastName;
                account.ERP_Contact_Email__c  = billcontact.Email;
                account.ERP_Contact_Phone__c = billcontact.Phone;
                account.ERP_Contact_ID__c = billcontact.ERP_ID__c;
                account.ERP_Contact_Point_Email_ID__c = billcontact.ERP_Contact_Point_Email_ID__c;
                account.ERP_Contact_Point_Phone_ID__c = billcontact.ERP_Contact_Point_Phone_ID__c;
                account.ERP_Contact_Point_Relationship_ID__c = billcontact.ERP_Contact_Point_Relationship_ID__c;
                account.ERP_Person_Party_ID__c = billcontact.ERP_Person_Party_ID__c;
            }
        }
    }
    
    //This method sets ERP account and contact flags when certain account fields are updated
    public void setERPAccountContactFlags(List<Account> newAccountList, Map<Id, Account> oldAccountMap)
    {
        for(Account a : newAccountList){
            Account oa = oldAccountMap.get(a.Id);
            Boolean newPrimaryBillingContact = false;
            
            if((oa.Primary_Billing_Contact__c == Null && a.Primary_Billing_Contact__c != null) ||
               (oa.Primary_Billing_Contact__c != a.Primary_Billing_Contact__c && a.Primary_Billing_Contact__c != null)){
                newPrimaryBillingContact = true;
            }

            if(a.ERP_Org_Party_ID__c != null) {     
         
            if(a.BillingCity != oa.BillingCity || a.BillingCountry != oa.BillingCountry || a.BillingCountryCode != oa.BillingCountryCode ||
               a.BillingPostalCode != oa.BillingPostalCode || a.BillingState != oa.BillingState || 
               a.BillingStateCode != oa.BillingStateCode || a.BillingStreet != oa.BillingStreet ||
               a.Billing_Province__c != oa.Billing_Province__c)
               {
                 a.ERP_Bill_To_Address_Flag__c = 'Update';
               }
            if(oa.BillingCity == null && oa.BillingCountry == null && oa.BillingCountryCode == null &&
               oa.BillingPostalCode == null && oa.BillingState == null && oa.BillingStateCode == null &&
               oa.BillingStreet == null && oa.Billing_Province__c == null)
                {
                if(a.BillingCity != null || a.BillingCountry != null || a.BillingCountryCode != null ||
                   a.BillingPostalCode != null || a.BillingState != null || a.BillingStateCode != null ||
                   a.BillingStreet != null || a.Billing_Province__c != null)
                    {
                        a.ERP_Bill_To_Address_Flag__c = 'New';                   
                    }
                }
            if(a.ShippingCity != oa.ShippingCity || a.ShippingCountry != oa.ShippingCountry || 
               a.ShippingCountryCode != oa.ShippingCountryCode || a.ShippingPostalCode != oa.ShippingPostalCode ||
               a.ShippingState != oa.ShippingState || a.ShippingStateCode != oa.ShippingStateCode ||
               a.ShippingStreet != oa.ShippingStreet || a.Shipping_Province__c != oa.Shipping_Province__c)
               {
                a.ERP_Ship_To_Address_Flag__c = 'Update';
               }
            if(oa.ShippingCity == null && oa.ShippingCountry == null && oa.ShippingCountryCode == null &&
               oa.ShippingPostalCode == null && oa.ShippingState == null && oa.ShippingStateCode == null &&
               oa.ShippingStreet == null && oa.Shipping_Province__c == null)
                {
                if(a.ShippingCity != null || a.ShippingCountry != null || a.ShippingCountryCode != null ||
                   a.ShippingPostalCode != null || a.ShippingState != null || a.ShippingStateCode != null ||
                   a.ShippingStreet != null || a.Shipping_Province__c != null)
                   {
                     a.ERP_Ship_To_Address_Flag__c = 'New';
                   }
                }
           if((a.Primary_Billing_Contact__c != oa.Primary_Billing_Contact__c && a.Primary_Billing_Contact__c != null) ||
              (a.ERP_Contact_First_Name__c != oa.ERP_Contact_First_Name__c && a.ERP_Contact_First_Name__c != null) ||
              (a.ERP_Contact_Last_Name__c != oa.ERP_Contact_Last_Name__c && a.ERP_Contact_Last_Name__c != null)) 
              {
                  a.ERP_Contact_Flag__c = 'Update';
              }
            if(oa.Primary_Billing_Contact__c == null && oa.ERP_Contact_First_Name__c == null && oa.ERP_Contact_Last_Name__c == null)
            {
              if(a.Primary_Billing_Contact__c != null || a.ERP_Contact_First_Name__c != null || a.ERP_Contact_Last_Name__c!= null)  
              {
                 a.ERP_Contact_Flag__c = 'New';
              }
            }
            
            if(a.ERP_Contact_Phone__c != oa.ERP_Contact_Phone__c && a.ERP_Contact_Phone__c != null)
            {
               if(newPrimaryBillingContact) {
                   a.ERP_Contact_Flag__c = 'New';
                   a.ERP_Contact_Point_Phone_Flag__c = 'New';
               } else {
                   a.ERP_Contact_Flag__c = 'Update';
                   a.ERP_Contact_Point_Phone_Flag__c = 'Update';
               }
            }
            if(oa.ERP_Contact_Phone__c == null && a.ERP_Contact_Phone__c != null)
            {
                if(newPrimaryBillingContact){
                    a.ERP_Contact_Flag__c = 'New';
                } else {
                    a.ERP_Contact_Flag__c = 'Update';
                }
                a.ERP_Contact_Point_Phone_Flag__c = 'New';
            }
            if(a.ERP_Contact_Email__c != oa.ERP_Contact_Email__c && oa.ERP_Contact_Email__c != null)
            {
               if(newPrimaryBillingContact) {
                   a.ERP_Contact_Flag__c = 'New';
                   a.ERP_Contact_Point_Email_Flag__c = 'New';
               } else {
                   a.ERP_Contact_Flag__c = 'Update';
                   a.ERP_Contact_Point_Email_Flag__c = 'Update';
               }
            }
            if(oa.ERP_Contact_Email__c == null && a.ERP_Contact_Email__c != null)
            {
                if(newPrimaryBillingContact){
                    a.ERP_Contact_Flag__c = 'New';
                } else {
                    a.ERP_Contact_Flag__c = 'Update';
                }
                a.ERP_Contact_Point_Email_Flag__c = 'New';
            }
            if(a.ERP_Contact_Email__c == Null){
                 a.ERP_Contact_Point_Email_Flag__c = null;
            }
            if(a.ERP_Contact_Phone__c == Null){
                 a.ERP_Contact_Point_Phone_Flag__c = null;
            }
         }
         
         //Clear out ERP contact flags if primary billing contact is deleted
         if(oa.Primary_Billing_Contact__c != null && a.Primary_Billing_Contact__c == null){
             a.ERP_Contact_First_Name__c = null;
             a.ERP_Contact_Last_Name__c = null;
             a.ERP_Contact_Email__c = null;
             a.ERP_Contact_Phone__c = null;
             a.ERP_Person_Party_ID__c = null;
             a.ERP_Contact_ID__c = null;
             a.ERP_Contact_Flag__c = null;
             a.ERP_Contact_Point_Email_Flag__c = null;
             a.ERP_Contact_Point_Email_ID__c = null;
             a.ERP_Contact_Point_Phone_Flag__c = null;
             a.ERP_Contact_Point_Phone_ID__c = null;
             a.ERP_Contact_Point_Relationship_ID__c = null;
         }
      }
   } 
   
    //Clear out ERP Update flags if ERP Status is set to 'Success'
    public static void clearERPUpdateFlags(List<Account> newAccountList, Map<Id, Account> oldAccountMap){
        for(Account acc : newAccountList){
            Account oldAcc = oldAccountMap.get(acc.Id);
            if(oldAcc != null){
                if(acc.ERP_Last_Integration_Response_Date__c != null
                   && acc.ERP_Last_Integration_Response_Date__c != oldAcc.ERP_Last_Integration_Response_Date__c){
                   if(acc.ERP_Last_Integration_Status__c != null
                      && acc.ERP_Last_Integration_Status__c.toUpperCase() == 'SUCCESS'){
                          acc.ERP_Bill_To_Address_Flag__c = null;
                          acc.ERP_Contact_Flag__c = null;
                          acc.ERP_Contact_Point_Email_Flag__c = null;
                          acc.ERP_Contact_Point_Phone_Flag__c = null;
                          acc.ERP_Ship_To_Address_Flag__c = null;
                   }
                }
            }
        }
    } 
}