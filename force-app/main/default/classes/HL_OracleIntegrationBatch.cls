global class HL_OracleIntegrationBatch implements Database.Batchable<sObject>, Database.stateful{
    
    global String sObjectAPIName;
    global String whereClause;
    
    global HL_OracleIntegrationBatch(String sObjectAPIName, String whereClause){
        this.sObjectAPIName = sObjectAPIName;
        this.whereClause = whereClause;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM ' + sObjectAPIName + ' WHERE '+ whereClause;
        // String query = 'SELECT Id FROM Opportunity__c WHERE ERP_ID__c = null AND ERP_Submitted_to_Sync__c != null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(sObject sobjectRecord : scope){
            sobjectRecord.put('ERP_Submitted_To_Sync__c',system.now());
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}