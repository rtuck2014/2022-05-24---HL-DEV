/*
* Name: HL_EngagementExternalTeamHandler
* Created Date: 4/6/2015
* Description: Apex Handler class for Engagement_External_Team__c object
* Modified Date: 11/04/2019
* Description:  Added the following methods for ERP Integration:
*   a) createEngagementContracts()
*   b) createContractsAfterEngagementConversion
*   c) checkForBillToBillingCountry
*/

public class HL_EngagementExternalTeamHandler {
    private List<Engagement_External_Team__c> EngagementExternalTeam {get; set;}
    private Map<Id,Engagement_External_Team__c> OldEngagementExternalTeamMap {get; set;}
    
    public HL_EngagementExternalTeamHandler(List<Engagement_External_Team__c> engagementExternalTeam,Map<Id,Engagement_External_Team__c> OldEngagementExternalTeamMap){
        this.EngagementExternalTeam = engagementExternalTeam;
        this.OldEngagementExternalTeamMap = OldEngagementExternalTeamMap;
    }
    public HL_EngagementExternalTeamHandler(List<Engagement_External_Team__c> engagementExternalTeam){
         this.EngagementExternalTeam = engagementExternalTeam;
    }
    //Populate The EET_UNIQUE__c Field
    public List<Engagement_External_Team__c> UpdateEETUnique(){
        for(Engagement_External_Team__c eet : EngagementExternalTeam)
            eet.EET_UNIQUE__c = eet.Engagement__c + '|' + eet.Contact__c;
        
        return EngagementExternalTeam;
    }
    
    //Updates the Primary External Contact Lookup field on the Engagements
    //Also updates the Primary Checkbox on other EET fields to make sure only one is marked as primary per Engagement
    public List<Engagement_External_Team__c> UpdatePrimaryEngagementContact(){
        
        Map<Id,Id> engsToPrimaryEET = new Map<Id,Id>(); //Map of Engagements to Primary
        List<Engagement__c> engsToUpdate = new List<Engagement__c>();
        List<Engagement_External_Team__c> eetsToUpdate = new List<Engagement_External_Team__c>();
        Set<Engagement_External_Team__c> allUpdatedEET = new Set<Engagement_External_Team__c>();
        Set<Id> eets = new Set<Id>();
        Set<Id> EngagementOfEET = new Set<Id>();
        Map<Id,Integer> engsToUpdateOfNonPrimaryEET = new Map<Id,Integer>();
        List<Engagement__c> engsToUpdateWithNoPEC = new List<Engagement__c>();
        Id primaryContact;
        for(Engagement_External_Team__c eet: EngagementExternalTeam){
            if(eet.Primary__c){
                eets.add(eet.Id);
                engsToPrimaryEET.put(eet.Engagement__c, eet.Contact__c);
            }
            else if(OldEngagementExternalTeamMap != null && eet.Primary__c != OldEngagementExternalTeamMap.get(eet.Id).Primary__c && eet.Primary__c == false){
                engsToPrimaryEET.put(eet.Engagement__c, null);
            } 
        }
        //Update the Primary External Contact Lookup Field on the Engagement
        if(engsToPrimaryEET.size() > 0){
            for(Engagement__c e : [SELECT Primary_External_Contact__c FROM Engagement__c WHERE Id IN:engsToPrimaryEET.keySet()]){
                primaryContact = engsToPrimaryEET.get(e.Id);
                if(e.Primary_External_Contact__c <> primaryContact){
                    e.Primary_External_Contact__c = primaryContact;
                    engsToUpdate.add(e);
                }
            }
        }
        //Update the Engagements that might have Changed
        if(engsToUpdate.size() > 0){
            update engsToUpdate;
            
            for(Engagement_External_Team__c eet : [SELECT Primary__c FROM Engagement_External_Team__c WHERE Id NOT IN:eets AND Id NOT IN:EngagementExternalTeam AND Engagement__c IN:engsToPrimaryEET.keySet() AND Primary__c = true]){
                eet.Primary__c = false;
                eetsToUpdate.add(eet);
            }
            
            if(eetsToUpdate.size() > 0){
                HL_ConstantsUtil.ToStopRecursionOfEEThandler = false;
                update eetsToUpdate;
                
            }
        }
        
        return EngagementExternalTeam;
    }
    
    //Handle the Before Delete to Remove the Primary Reference if the Contact is Deleted
    public List<Engagement_External_Team__c> RemovePrimaryEET(){
        Set<Id> engIds = new Set<Id>(); //Store the Engagements to Update
        List<Engagement__c> engsToIterate = new List<Engagement__c>();
        List<Engagement__c> engsToUpdate = new List<Engagement__c>();
        for(Engagement_External_Team__c eet: EngagementExternalTeam){
            if(eet.Primary__c)
                engIds.add(eet.Engagement__c);
        }
        if(engIds.size()>0){
          engsToIterate = [SELECT Primary_External_Contact__c FROM Engagement__c WHERE Id IN:engIds];  
        }
 
        for(Engagement__c e : engsToIterate){
            e.Primary_External_Contact__c = null;
            engsToUpdate.add(e);
        }
        
        if(engsToUpdate.size() > 0)
            update engsToUpdate; 
        
        return EngagementExternalTeam;
    }
    
    public List<Engagement_External_Team__c> UpdateSortFields(){
        Set<Id> engIds = new Set<Id>();
        Set<String> roles = new Set<String>();
        Set<Id> contacts = new Set<Id>();
        Id engId, acctId;
        String companySort, role, roleSort;
        
        for(Engagement_External_Team__c eet : EngagementExternalTeam){
            engIds.add(eet.Engagement__c);
            roles.add(eet.Role__c);
            contacts.add(eet.Contact__c);
        }
        
        //Get a contact map for the account Ids
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT AccountId FROM Contact WHERE Id IN:contacts]);
        
        for(AggregateResult ar : [SELECT Engagement__c, Role__c, Contact__r.AccountId accountId, MAX(Sort_Role_Order__c) sortRole, MAX(Sort_Company_Order__c) sortCompany FROM Engagement_External_Team__c WHERE Engagement__c IN: engIds AND Role__c IN: roles GROUP BY Engagement__c, Role__c, Contact__r.AccountId]){
            engId = (Id)ar.get('Engagement__c');
            acctId = (Id)ar.get('accountId');
            role = (String)ar.get('Role__c');
            roleSort = (String)ar.get('sortRole');
            companySort = (String)ar.get('sortCompany');
            for(Engagement_External_Team__c eet : EngagementExternalTeam){
                if(eet.Engagement__c == engId && eet.Role__c == role){
                    eet.Sort_Role_Order__c = roleSort;
                    if(contactMap.get(eet.Contact__c).AccountId == acctId)
                        eet.Sort_Company_Order__c = companySort;
                }
            }
        }
        
        return EngagementExternalTeam;
    }

    // Create Engagement Contracts for each unique account related to billing contacts   
    public static void createEngagementContracts(){
        if(!HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Engagement_External_Team_Create_Contract)){
            return;
        }
        
        Set<Id> engagementIdSet = new Set<Id>();
        Set<Id> engagementExternalContactIdSet = new Set<Id>();
        Set<String> engagementIdAccountIdSet = new Set<String>();
        List<Engagement_External_Team__c> engagementExternalTeamInsertList = new List<Engagement_External_Team__c>();
        List<Contract__c> engContractList = new List<Contract__c>();
        List<Contract__c> contractInsertList = new List<Contract__c>();
        List<Contract__c> contractUpdateList = new List<Contract__c>();
        
        //Retrieve all new or updated external team members marked as billing contact
        for(Engagement_External_Team__c engagementExternalTeam : (List<Engagement_External_Team__c>)trigger.new){
            if(engagementExternalTeam.Billing_Contact__c == true
               && (trigger.IsInsert 
                   || (trigger.isUpdate 
                       && engagementExternalTeam.Billing_Contact__c != trigger.oldMap.get(engagementExternalTeam.Id).get('Billing_Contact__c')
                       && engagementExternalTeam.Billing_Contact__c == true))){
                           engagementExternalContactIdSet.add(engagementExternalTeam.Id);
                           if(!engagementIdSet.contains(engagementExternalTeam.Engagement__c))
                               engagementIdSet.add(engagementExternalTeam.Engagement__c);
                       }
        }
        
        //Retrieve all Contracts (Contract Type = 'Engagement') related to engagement records
        Map<String, Contract__c> engContractMap = new Map<String, Contract__c>();
        
        if(engagementIdSet.size()>0){
        engContractList = [SELECT Id, Engagement__c, Bill_To__c
                                               FROM Contract__c
                                              WHERE Engagement__c IN :engagementIdSet
                                                AND ERP_Contract_Type__c = 'Engagement'
                                                AND End_Date__c = null
                                              ORDER BY LastModifiedDate DESC];
        }
        for(Contract__c engContract : engContractList){
            String engContractAccountId = engContract.Engagement__c +'-'+ engContract.Bill_To__c;
            if(engContractMap.get(engContractAccountId) == null){    
                engContractMap.put(engContractAccountId, engContract);
            }             
        } 
        if(engagementExternalContactIdSet.size()>0){
        engagementExternalTeamInsertList = [SELECT Id, Engagement__c, Engagement__r.Name, Engagement__r.Opportunity__c, Contact__c, Contact__r.AccountId, Billing_Contact__c
                                                                              FROM Engagement_External_Team__c 
                                                                              WHERE Id IN :engagementExternalContactIdSet 
                                                                              ORDER BY LastModifiedDate DESC];
        }
        for(Engagement_External_Team__c engagementExternalTeam : engagementExternalTeamInsertList){
            String engagementIdAccountId = engagementExternalTeam.Engagement__c +'-'+engagementExternalTeam.Contact__r.AccountId;
            if(!engagementIdAccountIdSet.contains(engagementIdAccountId)){
                Contract__c contract  = new Contract__c();
                //contract.Contract_Unique_Id__c = engagementIdAccountId;
                contract.ERP_Submitted_to_Sync__c = system.now();

                if(engContractMap.get(engagementIdAccountId) == null){
                    contract.Bill_To__c = engagementExternalTeam.Contact__r.AccountId;
                    contract.Billing_Contact__c = engagementExternalTeam.Contact__c;
                    contract.Ship_To__c = engagementExternalTeam.Contact__r.AccountId;
                    contract.Opportunity__c = engagementExternalTeam.Engagement__r.Opportunity__c;
                    contract.Engagement__c = engagementExternalTeam.Engagement__c;
                    contract.Name = engagementExternalTeam.Engagement__r.Name;
                    contractInsertList.add(contract);
                } else {
                  contract.Id = engContractMap.get(engagementIdAccountId).Id;
                  contract.Billing_Contact__c = engagementExternalTeam.Contact__c;
                  contractUpdateList.add(contract);
                }
                engagementIdAccountIdSet.add(engagementIdAccountId);
            }
        }
        
        if(contractInsertList.size() > 0){
        HL_ConstantsUtil.automatedContractCreation=true;
          insert contractInsertList;
          checkMainContract(contractInsertList[0].Engagement__c);
          
        }
        if(contractUpdateList.size() > 0){
          update contractUpdateList;
        }
    } 
    
    public static void checkMainContract(Id engId){
        
        Boolean isMainFound = false;
        Boolean isMainApplicable = false;
        Id mainApplicableContId = null;
        Id firstContId = null;

        for(Contract__c objCont : [SELECT Id, Is_Main_Contract__c, Bill_To__c, Client__c FROM Contract__c WHERE Engagement__c = :engId AND End_Date__c = NULL AND ERP_Contract_Type__c != 'ICO' ORDER BY CreatedDate]){
            firstContId = firstContId == null ? objCont.Id : firstContId;
            if(objCont.Is_Main_Contract__c){
                isMainFound = true;             
            }
            if(objCont.Bill_To__c == objCont.Client__c){
                isMainApplicable = true;
                mainApplicableContId = objCont.Id;
            }
        } 
        
        if(!isMainFound){
            Contract__c objConToUpdate;
            if(isMainApplicable){
                objConToUpdate = new Contract__c(Id = mainApplicableContId, Is_Main_Contract__c = true);                 
            }
            else{
                objConToUpdate = new Contract__c(Id = firstContId, Is_Main_Contract__c = true);
            }
            update objConToUpdate;
        }
    }
    
    
    // Create Engagement Contracts for each unique account related to billing contacts  
    // This method is called from SL_Convert_Engagement apex class after the opportunity to engagement conversion 
    @future
    public static void createContractsAfterEngagementConversion(Set<Id> engagementIdSet){
        Set<String> engagementIdAccountIdSet = new Set<String>();
        List<Contract__c> contractInsertList = new List<Contract__c>();
        List<Contract__c> contractUpdateList = new List<Contract__c>();
               
        //Retrieve all Contracts (Contract Type = 'Engagement') related to engagement records
        Map<String, Contract__c> engContractMap = new Map<String, Contract__c>();
        List<Contract__c> engContractList = [SELECT Id, Engagement__c, Bill_To__c
                                               FROM Contract__c
                                              WHERE Engagement__c IN :engagementIdSet
                                                AND ERP_Contract_Type__c = 'Engagement'
                                                AND End_Date__c = null
                                              ORDER BY CreatedDate DESC];
        for(Contract__c engContract : engContractList){
            String engContractAccountId = engContract.Engagement__c +'-'+ engContract.Bill_To__c;
            if(engContractMap.get(engContractAccountId) == null){    
                engContractMap.put(engContractAccountId, engContract);
            }             
        }                        
                
        //Retrieve all Engagement External Team record and determine latest record for Bill To account
        List<Engagement_External_Team__c> engagementExternalTeamList = [SELECT Id, Engagement__c, Engagement__r.Name, Engagement__r.Opportunity__c, Contact__c, Contact__r.AccountId, Billing_Contact__c
                                                                              FROM Engagement_External_Team__c 
                                                                              WHERE Engagement__c IN :engagementIdSet 
                                                                                AND Billing_Contact__c = true
                                                                              ORDER BY Engagement__c, LastModifiedDate DESC];
        for(Engagement_External_Team__c engagementExternalTeam : engagementExternalTeamList){
            String engagementIdAccountId = engagementExternalTeam.Engagement__c +'-'+engagementExternalTeam.Contact__r.AccountId;
            if(!engagementIdAccountIdSet.contains(engagementIdAccountId)){
                Contract__c contract  = new Contract__c();
                //contract.Contract_Unique_Id__c = engagementIdAccountId;
                contract.ERP_Submitted_to_Sync__c = system.now();
                
                if(engContractMap.get(engagementIdAccountId) == null){
                    contract.Bill_To__c = engagementExternalTeam.Contact__r.AccountId;
                    contract.Billing_Contact__c = engagementExternalTeam.Contact__c;
                    contract.Ship_To__c = engagementExternalTeam.Contact__r.AccountId;
                    contract.Opportunity__c = engagementExternalTeam.Engagement__r.Opportunity__c;
                    contract.Engagement__c = engagementExternalTeam.Engagement__c;
                    contract.Name = engagementExternalTeam.Engagement__r.Name;
                    //contract.Contract_Unique_Id__c = engagementIdAccountId;
                    contractInsertList.add(contract);
                } else {
                  contract.Id = engContractMap.get(engagementIdAccountId).Id;
                  contract.Billing_Contact__c = engagementExternalTeam.Contact__c;
                  contractUpdateList.add(contract);
                }
                engagementIdAccountIdSet.add(engagementIdAccountId);
            }
        }
        
        if(contractInsertList.size() > 0){
          insert contractInsertList; 
          //HL_ConstantsUtil.automatedContractCreation=true;
        }
        if(contractUpdateList.size() > 0){
          update contractUpdateList;
        }
    }         
    
    //Check if Bill To Company has a 'Billing Country'
    public List<Engagement_External_Team__c> checkForBillToBillingCountry(){
        if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Engagement_External_Team_Bill_To_Country)){
            for(Engagement_External_Team__c eet : EngagementExternalTeam){
                if(eet.Billing_Contact__c == true 
                   && (eet.Company_Billing_Country__c == null || eet.Company_Billing_Country__c == '')){
                       String errorMsg = 'Bill To company \'' +  eet.Company__c + '\' should have a Billing Country.';
                       eet.addError(errorMsg);
                }
            }
        }       
        return EngagementExternalTeam;
    }
}