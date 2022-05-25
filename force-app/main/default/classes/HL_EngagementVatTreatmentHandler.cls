/*
* Name: HL_EngagementVatTreatmentHandler 
* Created Date: 10/03/2019
* Created By: Publicis Sapient
* Functionality : Handler class to implement logic for Engagement_VAT_Treatment__c object
*/

public with sharing class HL_EngagementVatTreatmentHandler {
    private boolean IsExecuting = false;
    private integer BatchSize = 0;
    public static final string CLASS_NAME = 'HL_EngagementVATTreatmentHandler';
    
    public HL_EngagementVatTreatmentHandler(boolean executing, integer size){
        IsExecuting = executing;
        BatchSize = size;
    }
    
    //Update VAT Treatment records when the 'Legal Entity' of the parent engagement changes
    public static void updateTaxClassificationCode(Set<Id> vatTreatmentIdSet, Map<Id,Engagement_VAT_Treatment__c> oldEngVATTreatmentMap, Boolean listPassedFromParent){
        try{
            List<Engagement_VAT_Treatment__c> engagementVATTreatmentList = [SELECT Id, Treatment__c, Engagement__c, Engagement__r.Legal_Entity__c, Engagement__r.Legal_Entity__r.ERP_Entity_Code__c FROM Engagement_VAT_Treatment__c WHERE Id IN: vatTreatmentIdSet];
            List<Tax_Classification_Code__mdt> taxClassificationList = [SELECT MasterLabel,ERP_Business_Unit__c,ERP_Entity_Code__c,Tax_Classification_Code__c,Treatment__c FROM Tax_Classification_Code__mdt];
            Map<String,Tax_Classification_Code__mdt> taxClassificationMap = new Map<String,Tax_Classification_Code__mdt>();
            for(Tax_Classification_Code__mdt taxClassification :taxClassificationList){
                taxClassificationMap.put(taxClassification.MasterLabel.trim().toLowercase(), taxClassification);
            }     
            system.debug('Tax_Classification_Code__mdt: ' + taxClassificationMap);
            
            List<Engagement_VAT_Treatment__c> engagementVATTreatmentUpdateList = new List<Engagement_VAT_Treatment__c>();
            for(Engagement_VAT_Treatment__c engVATTreatment : engagementVATTreatmentList){                
                if(listPassedFromParent
                   || Trigger.isInsert
                   || (Trigger.isUpdate 
                       && (engVATTreatment.Treatment__c !=  oldEngVATTreatmentMap.get(engVATTreatment.Id).Treatment__c 
                           || engVATTreatment.Engagement__c != oldEngVATTreatmentMap.get(engVATTreatment.Id).Engagement__c))){
                               String entityCodeTreatment = (engVATTreatment.Engagement__r.Legal_Entity__r.ERP_Entity_Code__c + '-' + engVATTreatment.Treatment__c).trim().toLowercase();
                               Engagement_VAT_Treatment__c EngagementVATTreatment = new Engagement_VAT_Treatment__c();
                               if(taxClassificationMap.containsKey(entityCodeTreatment)){
                                   EngagementVATTreatment.Tax_Classification_Code__c = taxClassificationMap.get(entityCodeTreatment).Tax_Classification_Code__c;
                               }
                               else{
                                   EngagementVATTreatment.Tax_Classification_Code__c = '';
                               }
                               EngagementVATTreatment.Id = engVATTreatment.Id;
                               engagementVATTreatmentUpdateList.add(EngagementVATTreatment);
                           }
            }
            
            if(engagementVATTreatmentUpdateList.size() > 0){
                Database.SaveResult[] saveResultList = Database.update(engagementVATTreatmentUpdateList,false);
                ErrorHandlingUtility.handleDatabaseSaveResults(saveResultList, CLASS_NAME);
            }
        }catch(exception ex){
            ErrorHandlingUtility.logException(null, ex);
        }
    }
    
    //Check for duplicate engagement VAT treatments based on Effective Date
    public static void checkForDuplicateVATTreatments(List<Engagement_VAT_Treatment__c> engagementVATTreatmentList){
        Set<Id> engIds= new Set<Id>();
        Map<String, Engagement_VAT_Treatment__c> engVATMap = new Map<String, Engagement_VAT_Treatment__c>();
        
        for(Engagement_VAT_Treatment__c eVAT : engagementVATTreatmentList){
            engIds.add(eVAT.Engagement__c);
        }
        
        for(Engagement_VAT_Treatment__c eVAT : [SELECT Id, Engagement__c, Effective_Date__c FROM Engagement_VAT_Treatment__c WHERE Engagement__c IN :engIds]){
            engVATMap.put(eVAT.Engagement__c + '-' + eVAT.Effective_Date__c.format(), eVAT);
        }
        
        for(Engagement_VAT_Treatment__c eVAT: engagementVATTreatmentList){
            Engagement_VAT_Treatment__c engVATRecord = engVATMap.get(eVAT.Engagement__c + '-' + eVAT.Effective_Date__c.format());
            if(engVATRecord != null && eVAT.Id != engVATRecord.Id)
                eVAT.addError('A duplicate VAT Treatment record with Effective Date \'' + engVATRecord.Effective_Date__c.format() + '\' '  + 'already exist for this engagement.');
        }
    }
    
    //Assign VAT Treatment Classification Codes
    public static void getVATTaxClassificationCode(List<Engagement_VAT_Treatment__c > engagementVATTreatmentList, Map<Id,Engagement_VAT_Treatment__c> oldEngVATTreatmentMap){
        List<Tax_Classification_Code__mdt> taxClassificationList = [SELECT MasterLabel,ERP_Business_Unit__c,ERP_Entity_Code__c,Tax_Classification_Code__c,Treatment__c FROM Tax_Classification_Code__mdt];
        Map<String,Tax_Classification_Code__mdt> taxClassificationMap = new Map<String,Tax_Classification_Code__mdt>();
        
        for(Tax_Classification_Code__mdt taxClassification :taxClassificationList){
            taxClassificationMap.put(taxClassification.MasterLabel.trim().toLowercase(), taxClassification);
        }     
        system.debug('Tax_Classification_Code__mdt: ' + taxClassificationMap);
        
        for(Engagement_VAT_Treatment__c engVAT : engagementVATTreatmentList){
            if(Trigger.isInsert
               || (Trigger.isUpdate 
                   && (engVAT.Treatment__c !=  oldEngVATTreatmentMap.get(engVAT.Id).Treatment__c 
                       || engVAT.Engagement__c != oldEngVATTreatmentMap.get(engVAT.Id).Engagement__c))){
                           String entityCodeTreatment = (engVAT.HL_Entity_Code__c + '-' + engVAT.Treatment__c).trim().toLowercase();
                           system.debug('entityCodeTreatment:  ' + entityCodeTreatment);
                           
                           if(taxClassificationMap.containsKey(entityCodeTreatment)){
                               engVAT.Tax_Classification_Code__c = taxClassificationMap.get(entityCodeTreatment).Tax_Classification_Code__c;
                           }
                           else{
                               engVAT.Tax_Classification_Code__c = '';
                           }
            }
        }
    }
    
    //Check for modified VAT Treatment records
    public static void checkForUpdatedVATTreatments(List<Engagement_VAT_Treatment__c > engVATTreatmentList, Map<Id,Engagement_VAT_Treatment__c> oldEngVATTreatmentMap){
        Set<Id> engIdSet = new Set<Id>(); 
        if(Trigger.isInsert || Trigger.isUpdate){
            for(Engagement_VAT_Treatment__c engVAT : engVATTreatmentList){
                if(Trigger.isInsert
                   || (Trigger.isUpdate 
                       && (engVAT.Tax_Classification_Code__c != oldEngVATTreatmentMap.get(engVAT.Id).Tax_Classification_Code__c 
                           || engVAT.Effective_Date__c != oldEngVATTreatmentMap.get(engVAT.Id).Effective_Date__c))){
                           engIdSet.add(engVAT.Engagement__c);
                }
            }
        } else if(Trigger.isDelete){
            for(Engagement_VAT_Treatment__c engVAT : oldEngVATTreatmentMap.Values()){
                engIdSet.add(engVAT.Engagement__c);    
            }        
        }
        
        if(engIdSet != null && engIdSet.size() > 0){
            updateTaxClassificationOnContracts(engIdSet);
        }
     }
     
    //Update related contracts with latest VAT Tax Classification Code
    @future
    public static void updateTaxClassificationOnContracts(Set<Id> engagementSet){
        List<Contract__c> contractToUpdateList = new List<Contract__c>();
        Map<Id, Engagement__c> mapOfEngagement = new Map<Id,Engagement__c>();
        
        for(Engagement__c eng : [SELECT Id, Tax_Classification_Code_Eng_VAT_Treatmnt__c, 
                                (SELECT Id, Tax_Classification_Code__c FROM Engagement_VAT_Treatements__r ORDER BY Effective_Date__c DESC, CreatedDate DESC LIMIT 1), 
                                (SELECT Id, ERP_TAX_Classification_Code__c, End_Date__c FROM Contract__r WHERE ERP_Contract_Type__c = 'Engagement') FROM Engagement__c WHERE Id in :engagementSet]){
            if(eng.Contract__r != null && eng.Contract__r.size() > 0){             
                for(Contract__c engContract : eng.Contract__r){
                    if(engContract.End_Date__c == null){
                        Contract__c con = new Contract__c(Id = engContract.Id);
                        if(eng.Engagement_VAT_Treatements__r != null && eng.Engagement_VAT_Treatements__r.size() > 0){
                            con.ERP_TAX_Classification_Code__c = eng.Engagement_VAT_Treatements__r[0].Tax_Classification_Code__c;
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