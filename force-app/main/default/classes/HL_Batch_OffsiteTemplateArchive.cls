global class HL_Batch_OffsiteTemplateArchive implements Database.Batchable<sObject> {
	
	String query = 'SELECT RecordTypeId FROM Offsite_Template__c WHERE RecordType.DeveloperName = \'Live\' AND Archive__c = true';
	
	global HL_Batch_OffsiteTemplateArchive() {}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}
    
   	global void execute(Database.BatchableContext BC, List<Offsite_Template__c> offsiteTemplateList) {
		//Archive all 
		HL_OffsiteTemplate_Update osUpdate = new HL_OffsiteTemplate_Update(offsiteTemplateList);
		osUpdate.UpdateAll();
	}
	
	global void finish(Database.BatchableContext BC) {
		// Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id = 
                              :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion if there is an error in any of the batches.
        if (a.NumberOfErrors > 0) {
            HL_Email.SendEmail(new List<String> {a.CreatedBy.Email}, null, null, 'Offsite Template Archive: ' + a.Status, 'The batch Apex job processed ' + a.TotalJobItems +
             ' batches with ' + a.NumberOfErrors + ' failures.', false); 
        }
	}
	
}