global class HL_UpdateEngagementBatch implements Database.Batchable<Engagement__c>{
List<Engagement__c> lstEngagement = new List<Engagement__c>();
Date previousMonthDate = System.Today().toStartOfMonth().addDays(-1);

global HL_UpdateEngagementBatch(List<Engagement__c> lstEngagement){
    this.lstEngagement = lstEngagement;

}
global Iterable<Engagement__c>start(Database.BatchableContext BC){
return lstEngagement;
}
global void execute(Database.BatchableContext BC,List<Engagement__c> lstEngagement){
//update lstEngagement;

//Block the Engagement Trigger from Firing
    HL_TriggerContextUtility.ByPassOnMonthlyRevenueProcess = true;
    update lstEngagement;
    //Unblock Engagement Trigger from Firing
    HL_TriggerContextUtility.ByPassOnMonthlyRevenueProcess = false;
}
global void finish(Database.BatchableContext BC){
    Id lobSplitBatchId =  Database.Executebatch(new HL_RecalculateLOBSplitBatch('SELECT Engagement__c FROM Staffing_Details__c WHERE Revenue_Date__c =:previousMonthDate'));
    System.debug('LOB Split Batch Job Id is: ' + lobSplitBatchId);

}

}