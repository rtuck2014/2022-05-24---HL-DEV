/*
* Name: HL_OpportunityVATTreatmentHandler 
* Created Date: 10/03/2019
* Created By: Publicis Sapient
* Functionality : Handler class to implement logic for Opportunity_VAT_Treatment__c object
*/

public with sharing class HL_OpportunityVATTreatmentHandler {
    private boolean IsExecuting = false;
    private integer BatchSize = 0;
    public static final string CLASS_NAME = 'HL_OpportunityVATTreatmentHandler';
    
    public HL_OpportunityVATTreatmentHandler(boolean executing, integer size){
        IsExecuting = executing;
        BatchSize = size;
    }
    
    //Update VAT Treatment records when the 'Legal Entity' of the parent opportunity changes
    public static void updateTaxClassificationCode(List<Opportunity_VAT_Treatment__c> opportunityVATTreatmentList, List<Opportunity_VAT_Treatment__c> oldOpportunityVATTreatmentList, Boolean listPassedFromParent){
        try{
            List<Tax_Classification_Code__mdt> taxClassificationList = [SELECT MasterLabel,ERP_Business_Unit__c,Legal_Entity_Name__c, ERP_Entity_Code__c, Tax_Classification_Code__c,Treatment__c FROM Tax_Classification_Code__mdt];
            Map<String,Tax_Classification_Code__mdt> taxClassificationMap = new Map<String,Tax_Classification_Code__mdt>();
            for(Tax_Classification_Code__mdt taxClassification :taxClassificationList){
                taxClassificationMap.put(taxClassification.MasterLabel.trim().toLowercase(), taxClassification);
            }        
            Map<Id,Opportunity_VAT_Treatment__c> oldOppVATTreatmentMap;
            if(trigger.isUpdate && listPassedFromParent == false){
                oldOppVATTreatmentMap = new Map<Id,Opportunity_VAT_Treatment__c>(oldOpportunityVATTreatmentList);
            }
            List<Opportunity_VAT_Treatment__c> oppVATTreatmentUpdateList = new List<Opportunity_VAT_Treatment__c>();
            for(Opportunity_VAT_Treatment__c oppVATTreatment : opportunityVATTreatmentList){
                if(listPassedFromParent
                   || Trigger.isInsert
                   || (Trigger.isUpdate 
                       && (oppVATTreatment.Treatment__c !=  oldOppVATTreatmentMap.get(oppVATTreatment.Id).Treatment__c 
                           || oppVATTreatment.Opportunity__c != oldOppVATTreatmentMap.get(oppVATTreatment.Id).Opportunity__c))){         
                               String businessType_Treatment = (oppVATTreatment.Opportunity__r.Legal_Entity__r.ERP_Entity_Code__c +'-'+oppVATTreatment.Treatment__c).trim().toLowercase();
                               Opportunity_VAT_Treatment__c opportunityVATTreatment = new Opportunity_VAT_Treatment__c();
                               if(taxClassificationMap.containsKey(businessType_Treatment)){
                                   opportunityVATTreatment.Tax_Classification_Code__c = taxClassificationMap.get(businessType_Treatment).Tax_Classification_Code__c;
                               }
                               else{
                                   opportunityVATTreatment.Tax_Classification_Code__c = '';
                               }
                               opportunityVATTreatment.Id = oppVATTreatment.Id;
                               oppVATTreatmentUpdateList.add(opportunityVATTreatment);
                           }
            }
            if(oppVATTreatmentUpdateList.size() > 0){
                Database.SaveResult[] saveResultList = Database.update(oppVATTreatmentUpdateList,false);
                ErrorHandlingUtility.handleDatabaseSaveResults(saveResultList, CLASS_NAME);
            }
        }catch(exception ex){
            ErrorHandlingUtility.logException(null, ex);
        }
    }
    
    //Check for duplicate opportunity VAT treatments based on Effective Date
    public static void checkForDuplicateVATTreatments(List<Opportunity_VAT_Treatment__c> opportunityVATTreatmentList){
        Set<Id> oppIds= new Set<Id>();
        Map<String, Opportunity_VAT_Treatment__c> oppVATMap = new Map<String, Opportunity_VAT_Treatment__c>();
        
        for(Opportunity_VAT_Treatment__c oVAT : opportunityVATTreatmentList){
            oppIds.add(oVAT.Opportunity__c);
        }
        
        for(Opportunity_VAT_Treatment__c oVAT : [SELECT Id, Opportunity__c, Effective_Date__c FROM Opportunity_VAT_Treatment__c WHERE Opportunity__c IN :oppIds]){
            oppVATMap.put(oVAT.Opportunity__c + '-' + oVAT.Effective_Date__c.format(), oVAT);
        }
        
        for(Opportunity_VAT_Treatment__c oVAT: opportunityVATTreatmentList){
            Opportunity_VAT_Treatment__c oppVATRecord = oppVATMap.get(oVAT.Opportunity__c + '-' + oVAT.Effective_Date__c.format());
            if(oppVATRecord != null && oVAT.Id != oppVATRecord.Id)
                oVAT.addError('A duplicate VAT Treatment record with Effective Date \'' + oppVATRecord.Effective_Date__c.format() + '\' '  + 'already exist for this opportunity.');
        }
    }
    
    //Assign VAT Treatment Classification Codes
    public static void getVATTaxClassificationCode(List<Opportunity_VAT_Treatment__c > oppVATTreatmentList, Map<Id,Opportunity_VAT_Treatment__c> oldOppVATTreatmentMap){
        List<Tax_Classification_Code__mdt> taxClassificationList = [SELECT MasterLabel,ERP_Business_Unit__c,ERP_Entity_Code__c,Tax_Classification_Code__c,Treatment__c FROM Tax_Classification_Code__mdt];
        Map<String,Tax_Classification_Code__mdt> taxClassificationMap = new Map<String,Tax_Classification_Code__mdt>();
        
        for(Tax_Classification_Code__mdt taxClassification :taxClassificationList){
            taxClassificationMap.put(taxClassification.MasterLabel.trim().toLowercase(), taxClassification);
        }     
        system.debug('Tax_Classification_Code__mdt: ' + taxClassificationMap);
        
        for(Opportunity_VAT_Treatment__c oppVAT : oppVATTreatmentList){
            if(Trigger.isInsert
               || (Trigger.isUpdate 
                   && (oppVAT.Treatment__c != oldOppVATTreatmentMap.get(oppVAT.Id).Treatment__c 
                       || oppVAT.Opportunity__c != oldOppVATTreatmentMap.get(oppVAT.Id).Opportunity__c))){
                           String entityCodeTreatment = (oppVAT.HL_Entity_Code__c + '-' + oppVAT.Treatment__c).trim().toLowercase();
                           system.debug('entityCodeTreatment:  ' + entityCodeTreatment);
                           
                           if(taxClassificationMap.containsKey(entityCodeTreatment)){
                               oppVAT.Tax_Classification_Code__c = taxClassificationMap.get(entityCodeTreatment).Tax_Classification_Code__c;
                           }
                           else{
                               oppVAT.Tax_Classification_Code__c = '';
                           }
                       }
        }
    }
    
    //Check for modified VAT Treatment records
    public static void checkForUpdatedVATTreatments(List<Opportunity_VAT_Treatment__c > oppVATTreatmentList, Map<Id,Opportunity_VAT_Treatment__c> oldOppVATTreatmentMap){
        Set<Id> oppIdSet = new Set<Id>(); 
        if(Trigger.isInsert || Trigger.isUpdate){
            for(Opportunity_VAT_Treatment__c oppVAT : oppVATTreatmentList){
                if(Trigger.isInsert
                   || (Trigger.isUpdate 
                       && (oppVAT.Tax_Classification_Code__c != oldOppVATTreatmentMap.get(oppVAT.Id).Tax_Classification_Code__c 
                           || oppVAT.Effective_Date__c != oldOppVATTreatmentMap.get(oppVAT.Id).Effective_Date__c))){
                           oppIdSet.add(oppVAT.Opportunity__c);
                }
            }
        } else if(Trigger.isDelete){
            for(Opportunity_VAT_Treatment__c oppVAT : oldOppVATTreatmentMap.Values()){
                oppIdSet.add(oppVAT.Opportunity__c);    
            }        
        }
        
        if(oppIdSet != null && oppIdSet.size() > 0){
            updateTaxClassificationOnContracts(oppIdSet);
        }
     }
     
    //Update related contracts with latest VAT Tax Classification Code
    @future
    public static void updateTaxClassificationOnContracts(Set<Id> opportunitySet){
        List<Contract__c> contractToUpdateList = new List<Contract__c>();
        Map<Id, Opportunity__c> opportunityMap = new Map<Id, Opportunity__c>();
        
        for(Opportunity__c opp : [SELECT Id,
                                        (SELECT Id, Tax_Classification_Code__c FROM Opportunity_VAT_Treatments__r ORDER BY Effective_Date__c DESC, CreatedDate DESC LIMIT 1), 
                                        (SELECT Id, ERP_TAX_Classification_Code__c, End_Date__c FROM Contract__r WHERE ERP_Contract_Type__c = 'Engagement') 
                                    FROM Opportunity__C 
                                   WHERE Id in :opportunitySet]){
            if(opp.Contract__r != null && opp.Contract__r.size() > 0){             
                for(Contract__c oppContract : opp.Contract__r){
                    if(oppContract.End_Date__c == null){
                        Contract__c con = new Contract__c(Id = oppContract.Id);
                        if(opp.Opportunity_VAT_Treatments__r != null && opp.Opportunity_VAT_Treatments__r.size() > 0){
                           con.ERP_TAX_Classification_Code__c = opp.Opportunity_VAT_Treatments__r[0].Tax_Classification_Code__c;
                        } else {
                            con.ERP_TAX_Classification_Code__c = '';
                        }
                        contractToUpdateList.add(con);
                    }
                }                   
            }
        }
        
        if(contractToUpdateList != null && contractToUpdateList.size() > 0){
            update contractToUpdateList;
        }
    }
}