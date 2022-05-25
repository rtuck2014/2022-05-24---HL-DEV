/*
* Name: HL_ContractHandler
* Created Date: 10/11/2019
* Created By: Publicis Sapient
* Functionality : Handler class to implement logic for Contract__c object
*/

public class HL_ContractHandler{

    //Assign Client Number to new Bill To, Ship To and Client company records
    public static void updateAccountClientNumbers(){
        if(!HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Contract_Update_Account_Client_Numbers))
            return;
        
        Set<Id> accountIdSet = new Set<Id>();      
        Map<Id,Contract__c> oldContractMap = new Map<Id,Contract__c>();
        if(Trigger.isUpdate){
            oldContractMap = new Map<Id,Contract__c>((List<Contract__c>)Trigger.old);
        }
        Map<Id, Id> accountContractMap = new Map<Id, Id>();

        for(Contract__c contract : (List<Contract__c>)Trigger.new){
            if(contract.Bill_To__c != null
               && (Trigger.isInsert
                   || (Trigger.isUpdate
                       && (contract.Bill_To__c != oldContractMap.get(contract.Id).Bill_To__c
                           || contract.Billing_Contact__c != oldContractMap.get(contract.Id).Billing_Contact__c)))){
                               accountIdSet.add(contract.Bill_To__c);
                               accountContractMap.put(contract.Bill_To__c, contract.Billing_Contact__c);
                           }
           if(contract.Client__c != null
                && (Trigger.isInsert
                    || (Trigger.isUpdate
                        && (contract.client__c != oldContractMap.get(contract.Id).client__c)))){
                            if(!accountIdSet.contains(contract.client__c))
                                accountIdSet.add(contract.client__c);
             }
           if(contract.Ship_To__c != null
               && (Trigger.isInsert
                   || (Trigger.isUpdate
                       && (contract.Ship_To__c != oldContractMap.get(contract.Id).Ship_To__c)))){
                           if(!accountIdSet.contains(contract.Ship_To__c))
                               accountIdSet.add(contract.Ship_To__c);
                       }            
        } 
        
        
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
         Map<Id,Contact> ContactMap = new Map<Id,Contact>();
        
        if(accountIdSet.size()>0){
          accountList = [SELECT Id, Client_Number__c FROM Account WHERE Id IN :accountIdSet FOR UPDATE];  
        }
        if(accountContractMap.size()>0){
          contactList =[select Id,AccountId,FirstName,LastName,Email,Phone from Contact Where Id IN :accountContractMap.values()];   
        }
       
        for (Contact cont : ContactList){
            ContactMap.put(cont.AccountId,Cont);
        }
 
        HL_Auto_Number_Settings__c autoNumber = HL_Auto_Number_Settings__c.getValues('Account');
        Integer clientNumber = Integer.valueOf(autoNumber.Auto_Number__c);
        if(accountList.size() > 0){
            for(Account account :accountList){
                if(account.Client_Number__c == null){
                    clientNumber++;
                    account.Client_Number__c = String.valueOf(clientNumber);
                }
                if(ContactMap.get(account.Id) != null){
                    account.Primary_Billing_Contact__c  = ContactMap.get(account.Id).Id;
                    account.ERP_Contact_First_Name__c = ContactMap.get(account.Id).FirstName;
                    account.ERP_Contact_Last_Name__c = ContactMap.get(account.Id).LastName;
                    account.ERP_Contact_Phone__c = ContactMap.get(account.Id).Phone;
                    account.ERP_Contact_Email__c = ContactMap.get(account.Id).Email;
                }
            }
            update accountList;
            autoNumber.Auto_Number__c = clientNumber;
            update autoNumber; 
        }
    }

    //For new contracts, copy values from source opportunity or engagement
    public static void setContractInitialValues(){
        //Retrieve Contract with related opportunity and engagement values
        List<Contract__c> contractList = [SELECT Id, Bill_To__c, Name, Ship_To__c, ERP_Legal_Entity_Lookup__c, ERP_Legal_Entity__c, Description__c, Opportunity__c, Engagement__c, Client__c, Contract_Number__c,
                                                 ERP_Contract_Type__c, HL_Entity__c, Opportunity__r.ERP_Entity_Code__c, Opportunity__r.ERP_LOB__c, ERP_Task_Name__c, ERP_Task_Number__c, ERP_Business_Unit_Id__c, ERP_Business_Unit__c,
                                                 Opportunity__r.Client__c,  Opportunity__r.ERP_Project_Name__c, Opportunity__r.Legal_Entity__r.CurrencyISOCode, Opportunity__r.Legal_Entity__r.Name, Opportunity__r.ERP_Industry_Group_Reporting__c,
                                                 Opportunity__r.Opportunity_Description__c, Opportunity__r.CurrencyISOCode, Opportunity__r.ERP_Business_Unit_Id__c, Opportunity__r.ERP_Business_Unit__c, Opportunity__r.ERP_Product_Type_Code__c,
                                                 Opportunity__r.Primary_Office__c, Opportunity__r.Legal_Cap__c, Opportunity__r.Total_Estimated_Fee__c,  Opportunity__r.Expense_Cap__c, Opportunity__r.Line_of_Business__c,
                                                 Opportunity__r.Opportunity_Number_Suffix__c, Opportunity__r.ERP_Project_Number__c, Engagement__r.ERP_Project_Number__c,
                                                 Engagement__r.Client__c, Engagement__r.ERP_Project_Name__c, Engagement__r.Legal_Entity__r.CurrencyISOCode,  Engagement__r.Total_Fee__c,
                                                 Engagement__r.Engagement_Number_Suffix__c, Engagement__r.Transaction_Description__c, Engagement__r.CurrencyISOCode, Engagement__r.ERP_Business_Unit_Id__c, Engagement__r.ERP_Business_Unit__c,
                                                 Engagement__r.Expense_Cap__c, Engagement__r.Legal_Entity__r.Name, Engagement__r.ERP_Entity_Code__c, Engagement__r.ERP_LOB__c, Engagement__r.ERP_Product_Type_Code__c,
                                                 Engagement__r.Primary_Office__c, Engagement__r.Legal_Cap__c, Engagement__r.Total_Estimated_Fee__c, Engagement__r.Line_of_Business__c, Engagement__r.ERP_Industry_Group_Reporting__c
                                          FROM Contract__c 
                                          WHERE Id IN: trigger.new];
        List<Contract__c> contractUpdateList = new List<Contract__c>();
        
        for(Contract__c contract : contractList){
            //Set fields common to both Engagement and ICO contracts
            contract.ERP_Original_Project_Number__c = contract.Opportunity__r.ERP_Project_Number__c;
            contract.ERP_Submitted_to_Sync__c = System.now().addSeconds(30);
            
            //Set fields for Engagement contracts
            if(contract.ERP_Contract_Type__c == 'Engagement'){
                contract.ERP_Labor_Format__c = 'HL Labor';
                //contract.ERP_Payment_Terms__c = 'IMMEDIATE';
            }
            
            //Set fields for ICO contracts
            if(contract.ERP_Contract_Type__c == 'ICO'){
                contract.ERP_Labor_Format__c = 'ICO Labor';
            }
            
            //Update Contract with Engagement information
            if(contract.Engagement__c != null){
                if(contract.ERP_Contract_Type__c == 'Engagement'){
                    system.debug('Retrieve Contract information from engagement.');
                    if(contract.Name == null || contract.Name == '') contract.Name = contract.Engagement__r.ERP_Project_Name__c + ' - ' + contract.Contract_Number__c;
                    if(contract.Bill_To__c == null) contract.Bill_To__c = contract.Engagement__r.Client__c;
                    if(contract.Description__c == null || contract.Description__c == '')  contract.Description__c = contract.Engagement__r.Transaction_Description__c;
                    if(contract.Ship_To__c == null) contract.Ship_To__c = contract.Bill_To__c;
                    if(contract.ERP_Business_Unit_Id__c == null || contract.ERP_Business_Unit_Id__c == '') contract.ERP_Business_Unit_Id__c = contract.Engagement__r.ERP_Business_Unit_Id__c;
                    if(contract.ERP_Business_Unit__c == null || contract.ERP_Business_Unit__c == '') contract.ERP_Business_Unit__c = contract.Engagement__r.ERP_Business_Unit__c;
                    if(contract.HL_Entity__c == null || contract.HL_Entity__c == '') contract.HL_Entity__c = contract.Engagement__r.ERP_Entity_Code__c;
                    if(contract.Engagement__r.Legal_Entity__c != null){
                        if(contract.ERP_Legal_Entity_Lookup__c == null) contract.ERP_Legal_Entity_Lookup__c = contract.Engagement__r.Legal_Entity__c;
                        if(contract.ERP_Legal_Entity__c == null || contract.ERP_Legal_Entity__c == '') contract.ERP_Legal_Entity__c = contract.Engagement__r.Legal_Entity__r.Name;
                    } else {
                        if(contract.ERP_Legal_Entity_Lookup__c == null) contract.ERP_Legal_Entity_Lookup__c = contract.Opportunity__r.Legal_Entity__c;
                        if(contract.ERP_Legal_Entity__c == null || contract.ERP_Legal_Entity__c == '') contract.ERP_Legal_Entity__c = contract.Opportunity__r.Legal_Entity__r.Name;
                    }
                    
                    contract.Client__c = contract.Engagement__r.Client__c;
                    contract.Contract_Number_Suffix__c = contract.Engagement__r.Engagement_Number_Suffix__c;
                    contract.CurrencyISOCode = contract.Engagement__r.CurrencyISOCode;
                    contract.ERP_Bill_Transaction_Currency__c = contract.Engagement__r.CurrencyISOCode;
                    contract.ERP_Expense_Cap__c = contract.Engagement__r.Expense_Cap__c;
                    contract.HL_LOB__c = contract.Engagement__r.ERP_LOB__c;
                    contract.Line_of_Business__c = contract.Engagement__r.Line_of_Business__c;
                    contract.HL_Location__c = contract.Engagement__r.Primary_Office__c;
                    contract.Legal_Cap__c = contract.Engagement__r.Legal_Cap__c;
                    contract.Funding_Amount__c = contract.Engagement__r.Total_Fee__c;
                    contract.Total_Fee__c = contract.Engagement__r.Total_Fee__c;
                    contract.Industry_Code__c = contract.Engagement__r.ERP_Industry_Group_Reporting__c;
                    contract.Product_Type_Code__c = contract.Engagement__r.ERP_Product_Type_Code__c;
                    contractUpdateList.add(contract);
 
                } else if(contract.ERP_Contract_Type__c == 'ICO') {
                    contract.CurrencyISOCode = contract.Engagement__r.CurrencyISOCode;
                    contract.Line_of_Business__c = contract.Engagement__r.Line_of_Business__c;
                    contract.HL_LOB__c = contract.Engagement__r.ERP_LOB__c;
                    contract.Industry_Code__c = contract.Engagement__r.ERP_Industry_Group_Reporting__c;
                    contract.Product_Type_Code__c = contract.Engagement__r.ERP_Product_Type_Code__c;
                    if(contract.ERP_Legal_Entity_Lookup__c == null){
                        contract.ERP_Legal_Entity_Lookup__c = (contract.Engagement__r.Legal_Entity__c != null) ? contract.Engagement__r.Legal_Entity__c : contract.Opportunity__r.Legal_Entity__c;
                    } 
                    contractUpdateList.add(contract);
                }
                
            //Update Contract with Opportunity information
            } else if (contract.Opportunity__c != null){
                system.debug('Retrieve contract information from opportunity.');
                if(contract.ERP_Contract_Type__c == 'Engagement'){
                    if(contract.Name == null || contract.Name == '') contract.Name = contract.Opportunity__r.ERP_Project_Name__c + ' - ' + contract.Contract_Number__c;
                    if(contract.Bill_To__c == null) contract.Bill_To__c = contract.Opportunity__r.Client__c;
                    if(contract.Description__c == null || contract.Description__c == '')  contract.Description__c = contract.Opportunity__r.Opportunity_Description__c;
                    if(contract.Ship_To__c == null) contract.Ship_To__c = contract.Bill_To__c;
                    if(contract.ERP_Legal_Entity_Lookup__c == null) contract.ERP_Legal_Entity_Lookup__c = contract.Opportunity__r.Legal_Entity__c;
                    if(contract.ERP_Legal_Entity__c == null || contract.ERP_Legal_Entity__c == '') contract.ERP_Legal_Entity__c = contract.Opportunity__r.Legal_Entity__r.Name;
                    if(contract.ERP_Business_Unit_Id__c == null || contract.ERP_Business_Unit_Id__c == '') contract.ERP_Business_Unit_Id__c = contract.Opportunity__r.ERP_Business_Unit_Id__c;
                    if(contract.ERP_Business_Unit__c == null || contract.ERP_Business_Unit__c == '') contract.ERP_Business_Unit__c = contract.Opportunity__r.ERP_Business_Unit__c;
                    if(contract.HL_Entity__c == null || contract.HL_Entity__c == '') contract.HL_Entity__c = contract.Opportunity__r.ERP_Entity_Code__c;
                    
                    contract.Client__c = contract.Opportunity__r.Client__c;                  
                    contract.CurrencyISOCode = contract.Opportunity__r.CurrencyISOCode;
                    contract.Contract_Number_Suffix__c = contract.Opportunity__r.Opportunity_Number_Suffix__c;
                    contract.ERP_Bill_Transaction_Currency__c = contract.Opportunity__r.CurrencyISOCode;
                    contract.ERP_Expense_Cap__c = contract.Opportunity__r.Expense_Cap__c;
                    contract.HL_LOB__c = contract.Opportunity__r.ERP_LOB__c;
                    contract.Line_of_Business__c = contract.Opportunity__r.Line_of_Business__c;
                    contract.HL_Location__c = contract.Opportunity__r.Primary_Office__c;
                    contract.Legal_Cap__c = contract.Opportunity__r.Legal_Cap__c;
                    contract.Funding_Amount__c = contract.Opportunity__r.Total_Estimated_Fee__c;
                    contract.Total_Fee__c = contract.Opportunity__r.Total_Estimated_Fee__c;
                    contract.Industry_Code__c = contract.Opportunity__r.ERP_Industry_Group_Reporting__c;
                    contract.Product_Type_Code__c = contract.Opportunity__r.ERP_Product_Type_Code__c;
                    contractUpdateList.add(contract);
                } else if(contract.ERP_Contract_Type__c == 'ICO') {
                    contract.CurrencyISOCode = contract.Opportunity__r.CurrencyISOCode;
                    contract.Line_of_Business__c = contract.Opportunity__r.Line_of_Business__c;
                    contract.HL_LOB__c = contract.Opportunity__r.ERP_LOB__c;
                    contract.Industry_Code__c = contract.Opportunity__r.ERP_Industry_Group_Reporting__c;
                    contract.Product_Type_Code__c = contract.Opportunity__r.ERP_Product_Type_Code__c;
                    if(contract.ERP_Legal_Entity_Lookup__c == null)
                        contract.ERP_Legal_Entity_Lookup__c = contract.Opportunity__r.Legal_Entity__c;
                    contractUpdateList.add(contract);
                }
            }
        }
        system.debug('contractUpdateList: ' + contractUpdateList); 
        
        if(contractUpdateList.size() > 0){
            Database.saveResult[] saveResultList = Database.update(contractUpdateList,false);
            ErrorHandlingUtility.handleDatabaseSaveResults(saveResultList, 'HL_Contract_Handler');
        }
    }
    
    //Set the new Contract 'ERP Tax Classification Code' based on engagement or opportunity VAT Treatment records
    //Only update Contracts for 'ERP Contract Type = 'Engagement'
    public static void setNewContractTaxClassificationCode(){
        Set<Id> engagementIdSet = new Set<Id>();
        Set<Id> opportunityIdSet = new Set<Id>();
        List<Engagement_VAT_Treatment__c> engagementVATTreatmentList = new List<Engagement_VAT_Treatment__c>();
        List<Opportunity_VAT_Treatment__c> oppVATTreatmentList = new List<Opportunity_VAT_Treatment__c>();
        Map<Id, Engagement_VAT_Treatment__c> engagementVATHandlerMap = new Map<Id, Engagement_VAT_Treatment__c>();
        Map<Id, Opportunity_VAT_Treatment__c> opportunityVATHandlerMap = new Map<Id, Opportunity_VAT_Treatment__c>();
        
        for(Contract__c contract :(List<Contract__c>)trigger.new ){
            if(contract.ERP_Contract_Type__c == 'Engagement'){
                if(contract.Engagement__c != null){
                    engagementIdSet.add(contract.Engagement__c);
                }
                else if(contract.Opportunity__c != null){
                    opportunityIdSet.add(contract.Opportunity__c); 
                }
            }
        }
        if(engagementIdSet.size()>0){
            engagementVATTreatmentList = [SELECT Id, Engagement__c, Effective_Date__c, Tax_Classification_Code__c FROM Engagement_VAT_Treatment__c WHERE Engagement__c IN :engagementIdSet ORDER BY Effective_Date__c DESC];
        }
        //List<Engagement_VAT_Treatment__c> engagementVATTreatmentList = [SELECT Id, Engagement__c, Effective_Date__c, Tax_Classification_Code__c FROM Engagement_VAT_Treatment__c WHERE Engagement__c IN :engagementIdSet ORDER BY Effective_Date__c DESC];
        for(Engagement_VAT_Treatment__c engVATTreatment :engagementVATTreatmentList){
            if(!engagementVATHandlerMap.containsKey(engVATTreatment.Engagement__c)){
                engagementVATHandlerMap.put(engVATTreatment.Engagement__c,engVATTreatment);
            }
        }
        
        if(opportunityIdSet.size()>0){
        oppVATTreatmentList = [SELECT Id, Opportunity__c, Effective_Date__c, Tax_Classification_Code__c FROM Opportunity_VAT_Treatment__c WHERE Opportunity__c IN :opportunityIdSet ORDER BY Effective_Date__c DESC];
        }
        //List<Opportunity_VAT_Treatment__c> oppVATTreatmentList = [SELECT Id, Opportunity__c, Effective_Date__c, Tax_Classification_Code__c FROM Opportunity_VAT_Treatment__c WHERE Opportunity__c IN :opportunityIdSet ORDER BY Effective_Date__c DESC];
        for(Opportunity_VAT_Treatment__c oppVATTreatment :oppVATTreatmentList){
            if(!opportunityVATHandlerMap.containsKey(oppVATTreatment.Opportunity__c)){
                opportunityVATHandlerMap.put(oppVATTreatment.Opportunity__c,oppVATTreatment);
            }
        }
        
        for(Contract__c contract :(List<Contract__c>)trigger.new ){
            if(contract.ERP_Contract_Type__c == 'Engagement'){
                if(contract.Engagement__c != null && engagementVATHandlerMap.containsKey(contract.Engagement__c)){
                    contract.ERP_TAX_Classification_Code__c = engagementVATHandlerMap.get(contract.Engagement__c).Tax_Classification_Code__c;
                } else if(contract.Engagement__c == null && contract.Opportunity__c != null && opportunityVATHandlerMap.containsKey(contract.Opportunity__c)){
                    contract.ERP_TAX_Classification_Code__c = opportunityVATHandlerMap.get(contract.Opportunity__c).Tax_Classification_Code__c;
                }
            }
        }
    }
        
    // Set Contract Bill To and Ship To based on selected Billing Contact
    public static void setBillToShipToBasedOnBillingContact(List<Contract__c> newList, Map<Id,Contract__c> oldContractMap, Boolean isInsert){
        Map<Id,Contact> mapContactIdWithContact = new Map<Id,Contact>();        
        if(isInsert){
            set<Id> setContactIds = new set<Id>();
            for(Contract__c objCont : newList){
                if(objCont.ERP_Contract_Type__c == 'Engagement'){
                    if(string.isNotBlank(objCont.Billing_Contact__c)){
                        setContactIds.add(objCont.Billing_Contact__c);
                    }
                }
            }
            if(setContactIds.size() > 0){
                mapContactIdWithContact = new Map<Id,Contact>([SELECT Id, AccountId FROM Contact WHERE Id IN :setContactIds]);
                if(mapContactIdWithContact !=null && mapContactIdWithContact.size() > 0){
                    for(Contract__c objCont : newList){
                        if(objCont.ERP_Contract_Type__c == 'Engagement'){
                            if(string.isNotBlank(objCont.Billing_Contact__c) && mapContactIdWithContact.containsKey(objCont.Billing_Contact__c)){
                                objCont.Bill_To__c = mapContactIdWithContact.get(objCont.Billing_Contact__c).AccountId;
                                objCont.Ship_To__c = mapContactIdWithContact.get(objCont.Billing_Contact__c).AccountId;
                            }
                        }
                    }
                }
            }
        }
        else{
            map<Id,Id> mapContIdWithContactId = new map<Id,Id>();
            for(Contract__c objCont : newList){
                Contract__c objContOld = oldContractMap.get(objCont.Id);
                if(objCont.ERP_Contract_Type__c == 'Engagement'){
                    if((objCont.Billing_Contact__c != objContOld.Billing_Contact__c && string.isNotBlank(objCont.Billing_Contact__c))|| (objCont.ERP_Contract_Type__c != objContOld.ERP_Contract_Type__c)){
                        mapContIdWithContactId.put(objCont.Id,objCont.Billing_Contact__c);
                    }
                }
            }
            if(mapContIdWithContactId.size() > 0){
                mapContactIdWithContact = new Map<Id,Contact>([SELECT Id, AccountId FROM Contact WHERE Id IN :mapContIdWithContactId.values()]);
                if(mapContactIdWithContact !=null && mapContactIdWithContact.size() > 0){
                    for(Contract__c objCont : newList){
                         if(objCont.ERP_Contract_Type__c == 'Engagement'){
                            if(mapContIdWithContactId.containsKey(objCont.Id) && string.isNotBlank(objCont.Billing_Contact__c) && mapContactIdWithContact.containsKey(objCont.Billing_Contact__c)){
                                objCont.Bill_To__c = mapContactIdWithContact.get(objCont.Billing_Contact__c).AccountId;
                                objCont.Ship_To__c = mapContactIdWithContact.get(objCont.Billing_Contact__c).AccountId;
                            }
                        }
                    }
                }
            }
        }
    }
   // Upadte ERP_Update_Revenue_Method__c field to True, Evrry time ERP_Revenue_Method__c is changed.
     public static void ERPUpdateRevenueMethod(List<Contract__c> newContractList, Map<Id, Contract__c> oldContractMap){
        for(Contract__c newCont : newContractList){
            Contract__c oldCont = oldContractMap.get(newCont.Id);
            if(oldCont != null){
             
                    if(oldCont.ERP_Revenue_Method__c != newCont.ERP_Revenue_Method__c){
                              newCont.ERP_Update_Revenue_Method__c = true;
                    }
             
            }
        }
    }
    
    public static void clearERPUpdateRevenueMethod(List<Contract__c> newContractList, Map<Id, Contract__c> oldContractMap){
        for(Contract__c newCon : newContractList){
            Contract__c oldCon = oldContractMap.get(newCon.Id);
            if(oldCon != null){
                if(newCon.ERP_Last_Integration_Response_Date__c != null
                   && newCon.ERP_Last_Integration_Response_Date__c != oldCon.ERP_Last_Integration_Response_Date__c){
                   if(newCon.ERP_Last_Integration_Status__c != null 
                      && newCon.ERP_Last_Integration_Status__c.toUpperCase() == 'SUCCESS'){
                          newCon.ERP_Update_Revenue_Method__c = false;
                     }
                }
            }
        }
    }
 //Check Billing Contacts that are included as Opportunity Contact or Engagement Contact to set Is_Main_Contract__c to true
    public static void checkMainContract(List<Contract__c> newList,Map<id,Contract__c> oldMap,Map<id,Contract__c> newMap){
         HL_ConstantsUtil.automatedContractCreation=false;
        if(!HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Contract_Billing_Information))
            return;
        set<Id> setEngIds = new set<Id>();
        set<Id> setOppIds = new set<Id>(); 
        List<Contract__c>lstContractToUpdate =new List<Contract__c>();
        map<Id,List<Contract__c>> mapOppIdWithExistContacts = new map<Id,List<Contract__c>>();
        map<Id,List<Contract__c>> mapEngIdWithExistContact = new map<Id,List<Contract__c>>();   
        for(Contract__c objCont : newList){
               // if((oldMap==null && objCont.ERP_Contract_Type__c == 'Engagement') || (oldMap!=null && oldMap.containsKey(objCont.Id) && newMap.containsKey(objCont.Id) && oldMap.get(objCont.Id).Is_Main_Contract__c!=newMap.get(objCont.Id).Is_Main_Contract__c)){
                  if(objCont.ERP_Contract_Type__c == 'Engagement'){ 
                    if(string.isNotBlank(objCont.Engagement__c)){
                        setEngIds.add(objCont.Engagement__c);
                    }
                    else if(string.isNotBlank(objCont.Opportunity__c)){
                        setOppIds.add(objCont.Opportunity__c);
                    }    
                }
                
            } 
            system.debug('setEngIds...'+setEngIds);
         system.debug('setOppIds...'+setOppIds);
         for(Contract__c objCont : [SELECT Id, Is_Main_Contract__c,Opportunity__c, Bill_To__c, Client__c FROM Contract__c WHERE Opportunity__c= :setOppIds AND End_Date__c = NULL AND ERP_Contract_Type__c != 'ICO' ORDER BY CreatedDate desc]){
           List<Contract__c> lstCnt=new List<Contract__c>();
           if(mapOppIdWithExistContacts!=null && mapOppIdWithExistContacts.get(objCont.Opportunity__c)!=null){
            lstCnt=mapOppIdWithExistContacts.get(objCont.Opportunity__c);
            lstCnt.add(objCont);
            mapOppIdWithExistContacts.put(objCont.Opportunity__c,lstCnt);
           }
           else{
            lstCnt.add(objCont);
            mapOppIdWithExistContacts.put(objCont.Opportunity__c,lstCnt);
           }
         } 
         for(Contract__c objCont : [SELECT Id, Is_Main_Contract__c,Engagement__c, Bill_To__c, Client__c FROM Contract__c WHERE Engagement__c = :setEngIds AND End_Date__c = NULL AND ERP_Contract_Type__c != 'ICO' ORDER BY CreatedDate desc]){
             List<Contract__c> lstCnt=new List<Contract__c>();
           if(mapEngIdWithExistContact!=null && mapEngIdWithExistContact.get(objCont.Engagement__c)!=null){
            lstCnt=mapEngIdWithExistContact.get(objCont.Engagement__c);
            lstCnt.add(objCont);
            mapEngIdWithExistContact.put(objCont.Engagement__c,lstCnt);
           }
           else{
            lstCnt.add(objCont);
            mapEngIdWithExistContact.put(objCont.Engagement__c,lstCnt);
           }
         }
         system.debug('mapEngIdWithExistContact...'+mapEngIdWithExistContact);
         system.debug('mapOppIdWithExistContacts...'+mapOppIdWithExistContacts);
         for(string engId: mapEngIdWithExistContact.keyset()){
          Boolean isMainFound = false;
          Boolean isMainApplicable = false;
          Id mainApplicableContId = null;
          Id firstContId = null;
            if(mapEngIdWithExistContact.get(engId)!=null){
            Contract__c objConToUpdate;
                 List<Contract__c> lstCnt=mapEngIdWithExistContact.get(engId);
                 if(lstCnt.size()==1){
                     if(!lstCnt[0].Is_Main_Contract__c){
                         objConToUpdate=new Contract__c(id=lstCnt[0].id,Is_Main_Contract__c=true);
                         lstContractToUpdate.add(objConToUpdate);
                     }
                 }
                 else{
                 set<Id> setMainContIds = new set<Id>();
                     for(Contract__c objCont: lstCnt){
                        firstContId = firstContId == null ? objCont.Id : firstContId;
                        if(objCont.Is_Main_Contract__c){
                            isMainFound = true;
                            setMainContIds.add(objCont.Id);             
                        }
                        if(objCont.Bill_To__c == objCont.Client__c){
                            isMainApplicable = true;
                            mainApplicableContId = objCont.Id;
                        }
                     }
                     system.debug('isMainFound...'+isMainFound);
                       if(!isMainFound){
                       
                        if(isMainApplicable){
                            objConToUpdate= new Contract__c(Id = mainApplicableContId, Is_Main_Contract__c = true);                 
                        }
                        else{
                            objConToUpdate= new Contract__c(Id = firstContId, Is_Main_Contract__c = true);
                        }
                        lstContractToUpdate.add(objConToUpdate);
                    }
                    else{
                      Boolean changeOfMainCont=false;
                      Id changeOfMainContId;
                      system.debug('oldMap...'+oldMap);
                        if(oldMap==null && lstCnt[0].Is_Main_Contract__c && setMainContIds.size()>1){
                            for(Id contId : setMainContIds){
                             if(lstCnt[0].Id!=contId){
                              objConToUpdate= new Contract__c(Id = contId, Is_Main_Contract__c = false);
                              lstContractToUpdate.add(objConToUpdate);
                             }
                            }
                        }
                        else if(oldMap!=null && setMainContIds.size()>1){
                            for(Id contId : setMainContIds){
                                if(oldMap.containsKey(contId) && newMap.containsKey(contId) && oldMap.get(contId).Is_Main_Contract__c!=newMap.get(contId).Is_Main_Contract__c && newMap.get(contId).Is_Main_Contract__c){
                                    changeOfMainCont=true;
                                    changeOfMainContId=contId;
                                }
                               }
                               for(Id contId : setMainContIds){
                                if(changeOfMainContId!=contId){
                                    objConToUpdate= new Contract__c(Id = contId, Is_Main_Contract__c = false);
                                    lstContractToUpdate.add(objConToUpdate);
                                   }
                               }
                        }
                        else if(oldMap==null && !lstCnt[0].Is_Main_Contract__c && setMainContIds.size()==1){
                        
                        objConToUpdate= new Contract__c(Id = lstCnt[0].Id, Is_Main_Contract__c = true);
                              lstContractToUpdate.add(objConToUpdate);
                        }
                     }
                 }
             }
         }
           for(string oppId: mapOppIdWithExistContacts.keyset()){
           Boolean isMainFound = false;
           Boolean isMainApplicable = false;
           Id mainApplicableContId = null;
           Id firstContId = null;
            if(mapOppIdWithExistContacts.get(oppId)!=null){
            Contract__c objConToUpdate;
                 List<Contract__c> lstCnt=mapOppIdWithExistContacts.get(oppId);
                 if(lstCnt.size()==1){
                     if(!lstCnt[0].Is_Main_Contract__c){
                         objConToUpdate=new Contract__c(id=lstCnt[0].id,Is_Main_Contract__c=true);
                         lstContractToUpdate.add(objConToUpdate);
                     }
                 }
                 else{
                  set<Id> setMainContIds = new set<Id>();
                     for(Contract__c objCont: lstCnt){
                        firstContId = firstContId == null ? objCont.Id : firstContId;
                        if(objCont.Is_Main_Contract__c){
                            isMainFound = true;  
                            setMainContIds.add(objCont.Id);           
                        }
                        if(objCont.Bill_To__c == objCont.Client__c){
                            isMainApplicable = true;
                            mainApplicableContId = objCont.Id;
                        }
                     }
                     system.debug('isMainFound..'+isMainFound);
                       if(!isMainFound){
                       
                        if(isMainApplicable){
                            objConToUpdate= new Contract__c(Id = mainApplicableContId, Is_Main_Contract__c = true);                 
                        }
                        else{
                            objConToUpdate= new Contract__c(Id = firstContId, Is_Main_Contract__c = true);
                        }
                        lstContractToUpdate.add(objConToUpdate);
                    }
                    else{
                        Boolean changeOfMainCont=false;
                        Id changeOfMainContId;
                          if(oldMap==null && lstCnt[0].Is_Main_Contract__c && setMainContIds.size()>1){
                              for(Id contId : setMainContIds){
                               if(lstCnt[0].Id!=contId){
                                objConToUpdate= new Contract__c(Id = contId, Is_Main_Contract__c = false);
                                lstContractToUpdate.add(objConToUpdate);
                               }
                              }
                          }
                          else if(oldMap!=null && setMainContIds.size()>1){
                              for(Id contId : setMainContIds){
                                  if(oldMap.containsKey(contId) && newMap.containsKey(contId) && oldMap.get(contId).Is_Main_Contract__c!=newMap.get(contId).Is_Main_Contract__c && newMap.get(contId).Is_Main_Contract__c){
                                      changeOfMainCont=true;
                                      changeOfMainContId=contId;
                                  }
                                 }
                                 for(Id contId : setMainContIds){
                                  if(changeOfMainContId!=contId){
                                      objConToUpdate= new Contract__c(Id = contId, Is_Main_Contract__c = false);
                                      lstContractToUpdate.add(objConToUpdate);
                                     }
                                 }
                          }
                          else if(oldMap==null && !lstCnt[0].Is_Main_Contract__c && setMainContIds.size()==1){
                          objConToUpdate= new Contract__c(Id = lstCnt[0].Id, Is_Main_Contract__c = true);
                                lstContractToUpdate.add(objConToUpdate);
                          }
                       }
                 }
             }
         } 
         system.debug('lstContractToUpdate...'+lstContractToUpdate); 
         if(!lstContractToUpdate.isEmpty()){
         update lstContractToUpdate;
          }   
    }           
    //Only allow Billing Contacts that are included as Opportunity Contact or Engagement Contact
    public static void validateContractBillingContact(List<Contract__c> newList, Map<Id,Contract__c> oldContractMap, Boolean isInsert){
        if(!HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Contract_Billing_Information))
            return;
            
        set<Id> setEngIds = new set<Id>();
        set<Id> setOppIds = new set<Id>();
        map<Id,set<Id>> mapEngIdWithEngContactIds = new map<Id,set<Id>>();
        map<Id,set<Id>> mapOppIdWithOppContactIds = new map<Id,set<Id>>();
        
        if(isInsert){
            for(Contract__c objCont : newList){
                if(objCont.ERP_Contract_Type__c == 'Engagement'){
                    if(string.isNotBlank(objCont.Engagement__c)){
                        setEngIds.add(objCont.Engagement__c);
                    }
                    else if(string.isNotBlank(objCont.Opportunity__c)){
                        setOppIds.add(objCont.Opportunity__c);
                    }    
                }
            }
            
            if(setEngIds.size() > 0){
                for(Engagement__c objEng : [SELECT Id, (Select Id,Contact__c FROM Engagement_Working_Groups__r WHERE Billing_Contact__c = TRUE) FROM Engagement__c WHERE Id in :setEngIds]){
                    Set<Id> setEngContIds = new Set<Id>();
                    for(Engagement_External_Team__c objEngCont : objEng.Engagement_Working_Groups__r){
                        setEngContIds.add(objEngCont.Contact__c);
                    }
                    mapEngIdWithEngContactIds.put(objEng.Id, setEngContIds);
                }
            }
            if(setOppIds.size() > 0){
                for(Opportunity__c objOpp : [SELECT Id, (Select Id,Contact__c FROM Opportunity_Client_Teams__r WHERE Billing_Contact__c = TRUE) FROM Opportunity__c WHERE Id in :setOppIds]){
                    Set<Id> setOppContIds = new Set<Id>();
                    for(Opportunity_External_Team__c objOppCont : objOpp.Opportunity_Client_Teams__r){
                        setOppContIds.add(objOppCont.Contact__c);
                    }
                    mapOppIdWithOppContactIds.put(objOpp.Id, setOppContIds);
                }
            }

            for(Contract__c objCont : newList){
                if(objCont.ERP_Contract_Type__c == 'Engagement'){
                    if(string.isNotBlank(objCont.Engagement__c)){
                        Set<Id> setEngContIds = mapEngIdWithEngContactIds.get(objCont.Engagement__c);
                        if(!setEngContIds.contains(objCont.Billing_Contact__c)){
                            objCont.Billing_Contact__c.addError('Please select a Billing Contact from the Engagement Contacts list.');
                        }
                    }
                    else if(string.isNotBlank(objCont.Opportunity__c)){
                        Set<Id> setOppContIds = mapOppIdWithOppContactIds.get(objCont.Opportunity__c);
                        if(!setOppContIds.contains(objCont.Billing_Contact__c)){
                            objCont.Billing_Contact__c.addError('Please select a Billing Contact from the Opportunity Contacts list.');
                        }
                    }
                }
            }
        }
        else{
            Set<Id> setEligibleCont = new Set<Id>();
            for(Contract__c objCont : newList){
                if(objCont.ERP_Contract_Type__c == 'Engagement'){
                    Contract__c objContOld = oldContractMap.get(objCont.Id);
                    if((objCont.Billing_Contact__c != objContOld.Billing_Contact__c && string.isNotBlank(objCont.Billing_Contact__c))|| (objCont.ERP_Contract_Type__c != objContOld.ERP_Contract_Type__c)){
                        setEligibleCont.add(objCont.Id);
                        if(string.isNotBlank(objCont.Engagement__c)){
                            setEngIds.add(objCont.Engagement__c);
                        }
                        else if(string.isNotBlank(objCont.Opportunity__c)){
                            setOppIds.add(objCont.Opportunity__c);
                        }
                    }
                }
            }
           
            if(setEngIds.size() > 0){
                for(Engagement__c objEng : [SELECT Id, (Select Id,Contact__c FROM Engagement_Working_Groups__r WHERE Billing_Contact__c = TRUE) FROM Engagement__c WHERE Id in :setEngIds]){
                    Set<Id> setEngContIds = new Set<Id>();
                    for(Engagement_External_Team__c objEngCont : objEng.Engagement_Working_Groups__r){
                        setEngContIds.add(objEngCont.Contact__c);
                    }
                    mapEngIdWithEngContactIds.put(objEng.Id, setEngContIds);
                }
            }
            if(setOppIds.size() > 0){
                for(Opportunity__c objOpp : [SELECT Id, (Select Id,Contact__c FROM Opportunity_Client_Teams__r WHERE Billing_Contact__c = TRUE) FROM Opportunity__c WHERE Id in :setOppIds]){
                    Set<Id> setOppContIds = new Set<Id>();
                    for(Opportunity_External_Team__c objOppCont : objOpp.Opportunity_Client_Teams__r){
                        setOppContIds.add(objOppCont.Contact__c);
                    }
                    mapOppIdWithOppContactIds.put(objOpp.Id, setOppContIds);
                }
            }
            
            for(Contract__c objCont : newList){
                if(objCont.ERP_Contract_Type__c == 'Engagement'){
                    if(setEligibleCont.contains(objCont.Id)){
                        if(string.isNotBlank(objCont.Engagement__c)){
                            Set<Id> setEngContIds = mapEngIdWithEngContactIds.get(objCont.Engagement__c);
                            if(!setEngContIds.contains(objCont.Billing_Contact__c)){
                                objCont.Billing_Contact__c.addError('Please select a Billing Contact from the Engagement Contacts list.');
                            }
                        }
                        else if(string.isNotBlank(objCont.Opportunity__c)){
                            Set<Id> setOppContIds = mapOppIdWithOppContactIds.get(objCont.Opportunity__c);
                            if(!setOppContIds.contains(objCont.Billing_Contact__c)){
                                objCont.Billing_Contact__c.addError('Please select a Billing Contact from the Opportunity Contacts list.');
                            }
                        }
                    }
                }
            }
        }
    }
    public static void setContractStatus(List<Contract__c> trgNew,Map<Id,Contract__c> oldMap){
        for(Contract__c c : trgNew){
            c.Status__c=c.OppEngStatus__c;
        }
    }
}