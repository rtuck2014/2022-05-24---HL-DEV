global class HL_OracleIntegrationBatchScheduler implements Schedulable {
    
    global String sObjectAPIName;
    global String whereClause;
    
    global HL_OracleIntegrationBatchScheduler(String sObjectAPIName, String whereClause){
        this.sObjectAPIName = sObjectAPIName;
        this.whereClause = whereClause;
    }
    global void execute(SchedulableContext sc) {
        HL_OracleIntegrationBatch oracleIntegrationBatch = new HL_OracleIntegrationBatch(sObjectAPIName,whereClause);
        Database.executeBatch(oracleIntegrationBatch);
    }
}