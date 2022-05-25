global class HL_RecalculateLOBSplitBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    String query;
    Date previousMonthDate =System.Today().toStartOfMonth().addDays(-1); 
    global HL_RecalculateLOBSplitBatch(String queryString) {
        query = queryString;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc,  List<Staffing_Details__c> lstStaffingDetail){
        Set<Id> engagementIds = new Set<Id>();

        if(!lstStaffingDetail.isEmpty()){
            for(Staffing_Details__c sd : lstStaffingDetail)
            engagementIds.add(sd.Engagement__c);
            }
    HL_PercentageSplitHandler handler = new HL_PercentageSplitHandler();
    handler.RecalculateLOBSplits(engagementIds);  
    }

    global void finish(Database.BatchableContext bc){

    }
}