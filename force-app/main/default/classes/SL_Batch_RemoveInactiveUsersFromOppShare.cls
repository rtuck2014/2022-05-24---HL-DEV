/**  
* \arg ClassName		: SL_Batch_RemoveInactiveUsersFromOppShare
* \arg JIRATicket		: HL-90,HL-32
* \arg CreatedOn		: 22/Jan/2015
* \arg LastModifiedOn	: 22/Jan/2015
* \arg CreatededBy		: Lodhi
* \arg ModifiedBy		: -
* \arg Description		: Batch class to to delete Opportunity__Share records for those Opportunity__c where user 
						  and Opportunity_Internal_Team__c's areinactive and create Opportunity__Share for those 
						  who doesn't have the manual share.
*/
global class SL_Batch_RemoveInactiveUsersFromOppShare implements Database.Batchable<sObject>
{
	/*
        * MethodName	: start()
        * param			: Database.BatchableContext 
        * Description	: This method invoke when batch execution is start.
 	*/
	global Database.QueryLocator start(Database.BatchableContext BC)  
    {
    	String query = 'SELECT Id, Contact__c, Contact__r.User__r.Id, Start_Date__c, End_Date__c, Opportunity__c, Contact__r.User__r.IsActive  FROM Opportunity_Internal_Team__c ORDER BY LastModifiedDate'; 
    	return Database.getQueryLocator(query);
    }
    /* End */
    
    /*
        * MethodName	: execute()
        * param			: Database.BatchableContext and list of Opportunity_Internal_Team__c 
        * Description	: This method used for deleting and inserting the Opportunity__Share records.
 	*/
	global void execute(Database.BatchableContext BC, List<Opportunity_Internal_Team__c> lstOIT)
    {
    	SL_ManageSharingRules.manageSharingRules(lstOIT, 'Opportunity__c', 'Opportunity_Internal_Team__c', '');
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