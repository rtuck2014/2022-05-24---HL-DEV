/**  
* \arg ClassName		: SL_Batch_RemoveInactiveUsersFromEngShare
* \arg JIRATicket		: HL-32
* \arg CreatedOn		: 08/Oct/2014
* \arg LastModifiedOn	: 08/Oct/2014
* \arg CreatededBy		: Lodhi
* \arg ModifiedBy		: -
* \arg Description		: Batch class to to delete Engagement__Share records for those Engagement where user is inactive
						  and Engagement_Internal_Team__c's end date is current date and create Engagement__Share for 
						  those who doesn't have the manual share.
*/
global class SL_Batch_RemoveInactiveUsersFromEngShare implements Database.Batchable<sObject>
{
	/*
        * MethodName	: start()
        * param			: Database.BatchableContext 
        * Description	: This method invoke when batch execution is start.
 	*/
	global Database.QueryLocator start(Database.BatchableContext BC)  
    {
    	String query = 'SELECT Id, Contact__c, Contact__r.User__r.Id, Start_Date__c, End_Date__c, Engagement__c, Contact__r.User__r.IsActive  FROM Engagement_Internal_Team__c ORDER BY LastModifiedDate'; 
    	return Database.getQueryLocator(query);
    }
    /* End */
    
    /*
        * MethodName	: execute()
        * param			: Database.BatchableContext and list of Engagement_Internal_Team__c 
        * Description	: This method used for deleting and inserting the Engagement__Share records.
 	*/
	global void execute(Database.BatchableContext BC, List<Engagement_Internal_Team__c> lstEIT)
    {
    	SL_ManageSharingRules.manageSharingRules(lstEIT, 'Engagement__c', 'Engagement_Internal_Team__c', '');
    }
    /* End */
    
    /*
        * MethodName	: finish()
        * param			: Database.BatchableContext  
        * Description	: Do nothing.
 	*/
    global void finish(Database.BatchableContext BC)
    {
    	//Do Nothing.
    }
    /* End */
}
/* End */