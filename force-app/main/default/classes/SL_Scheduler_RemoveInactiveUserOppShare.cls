/**  
* \arg ClassName		: SL_Scheduler_RemoveInactiveUserOppShare
* \arg JIRATicket		: HL-90,HL-32
* \arg CreatedOn		: 22/Jan/2015
* \arg LastModifiedOn	: 22/Jan/2015
* \arg CreatededBy		: Lodhi
* \arg ModifiedBy		: -
* \arg Description		: Schedular class for SL_Batch_RemoveInactiveUsersFromOppShare Batch class 
*/
global class SL_Scheduler_RemoveInactiveUserOppShare implements schedulable
{
	/*
        * MethodName	: execute()
        * param			: SchedulableContext sc 
        * Description	: This method used for executing the SL_Batch_RemoveInactiveUsersFromEngShare batch class.
 	*/
	global void execute(SchedulableContext SC)
	{
		SL_Batch_RemoveInactiveUsersFromOppShare objBatchRIUOS = new SL_Batch_RemoveInactiveUsersFromOppShare();
		DataBase.executeBatch(objBatchRIUOS, 400);
	}
	/* End */
}
/* End */