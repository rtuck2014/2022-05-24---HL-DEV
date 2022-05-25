/**
* \arg ClassName      : SL_Batch_StampInternalTeam
* \arg JIRATicket     : HL-91
* \arg CreatedOn      : 24/JAN/2015
* \arg LastModifiedOn : 24/JAN/2015
* \arg CreatededBy    : GM
* \arg ModifiedBy     : GM
* \arg Description    : Batch class to stamp Internal team reocrds 
*/
global with sharing class SL_Batch_StampInternalTeam implements Database.Batchable<sObject> {
    /* Start Variables */
    private String query;
    /* End Variables */

    global SL_Batch_StampInternalTeam(String query) {
        this.query = query;        
    }

    /* End Constructor */

    /*
        @MethodName : start.
        @param      : Database.BatchableContext
        @Description: This function is used to set the query to fetch the records
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        return Database.getQueryLocator(query);
    }
    /* End */

    /*
        @MethodName : execute.
        @param      : Database.BatchableContext and List of Event.
        @Description: This function will roll up fields of Relationship records.
    */
    global void execute(Database.BatchableContext BC, List<SObject> scope) {        
        HL_PercentageSplitHandler.stampContactValuesOnITeam(scope);
    }
    /* End */

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
            HL_Email.SendEmail(new List<String> {a.CreatedBy.Email},null, null, 'Stamp Internal Team Job: ' + a.Status, 
                    'The batch Apex job processed ' + a.TotalJobItems +
             ' batches with ' + a.NumberOfErrors + ' failures.', false);           
        }
    }
    /* End */
}