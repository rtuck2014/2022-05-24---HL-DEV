/**
* \arg ClassName      : SL_Batch_PercentageSplit
* \arg JIRATicket     : HL-43
* \arg CreatedOn      : 12/JAN/2015
* \arg LastModifiedOn : 12/JAN/2015
* \arg CreatededBy    : GM
* \arg ModifiedBy     : GM
* \arg Description    : Batch class to recalculate Percent Staff/Role split on engagement.
*/
global class SL_Batch_PercentageSplit implements Database.Batchable<sObject> {

    String query;

    global SL_Batch_PercentageSplit(String query) {
        this.query = query;
    }
    global SL_Batch_PercentageSplit() {
        this('Select Id FROM Engagement__c WHERE (ID in (select engagement__c FROM engagement_internal_team__c where (End_Date__c <= TODAY AND Staff_Revenue_Split__c != 0) OR Engagement__r.Recalculate_Deal_Percentages__c=true))');
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    /*
        @MethodName : execute.
        @param      : Database.BatchableContext and List of Event.
        @Description: This method recalculates engagements
    */
    global void execute(Database.BatchableContext BC, List<Engagement__c> lstEngagement) {        
        HL_PercentageSplitHandler handler = new HL_PercentageSplitHandler();
        Set<Id> stIds = new Set<Id>();
        for (Engagement__c e : lstEngagement)
            stIds.add(e.Id);
        //Collect all the Engagement Ids and pass it to the Handler class
        handler.Recalculate(stIds);
        handler.RecalculateLOBSplits(stIds);

    }
    /*
        @MethodName : finish.
        @param      : Database.BatchableContext .
        @Description: do nothing
    */
    global void finish(Database.BatchableContext BC) {
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id = 
                              :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion if there is an error in any of the batches.
        if (a.NumberOfErrors > 0) {
            HL_Email.SendEmail(new List<String> {a.CreatedBy.Email}, null, null, 'Engagement Staff Split Calculations: ' + a.Status, 'The batch Apex job processed ' + a.TotalJobItems +
             ' batches with ' + a.NumberOfErrors + ' failures.', false);         
        }
    }

}