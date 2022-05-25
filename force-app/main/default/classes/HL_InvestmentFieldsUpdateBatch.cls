global class HL_InvestmentFieldsUpdateBatch implements Database.Batchable<sObject>{
    
    /*global Set<Id> sObjectIds;
    global HL_InvestmentFieldsUpdateBatch(Set<Id> CapIQIds){
        if(CapIQIds.size() > 0){
            sObjectIds = CapIQIds;
        }
    }*/
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //String query = 'SELECT Id, HL_Portfolio_Co_HL_Industry__c, HL_Portfolio_Co_HL_Sector__c, Portfolio_CapIQ_Company__r.HL_Industry_Group__c, Portfolio_CapIQ_Company__r.HL_Sector__c FROM Investment__c WHERE Portfolio_CapIQ_Company__c IN :sObjectIds';
        String query = 'SELECT Id, HL_Portfolio_Co_HL_Industry__c, HL_Portfolio_Co_HL_Sector__c, Portfolio_CapIQ_Company__r.HL_Industry_Group__c, Portfolio_CapIQ_Company__r.HL_Sector__c FROM Investment__c WHERE Portfolio_CapIQ_Company__c <> null AND Portfolio_CapIQ_Company__r.HL_Industry_Group__c <> null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Investment__c> scope){
        for(Investment__c sobjectRecord : scope){
            sobjectRecord.put('HL_Portfolio_Co_HL_Industry__c',sobjectRecord.Portfolio_CapIQ_Company__r.HL_Industry_Group__c);
            sobjectRecord.put('HL_Portfolio_Co_HL_Sector__c',sobjectRecord.Portfolio_CapIQ_Company__r.HL_Sector__c);
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}