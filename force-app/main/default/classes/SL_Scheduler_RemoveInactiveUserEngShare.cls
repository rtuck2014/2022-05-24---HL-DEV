/**  
* \arg ClassName		: SL_Scheduler_RemoveInactiveUserEngShare
* \arg JIRATicket		: HL-32
* \arg CreatedOn		: 10/OCT/2014
* \arg LastModifiedOn	: 10/OCT/2014
* \arg CreatededBy		: Lodhi
* \arg ModifiedBy		: -
* \arg Description		: Schedular class for SL_Batch_RemoveInactiveUsersFromEngShare Batch class 
*/
global class SL_Scheduler_RemoveInactiveUserEngShare implements schedulable
{
	/*
        * MethodName	: execute()
        * param			: SchedulableContext sc 
        * Description	: This method used for executing the SL_Batch_RemoveInactiveUsersFromEngShare batch class.
 	*/
	global void execute(SchedulableContext SC)
	{
		SL_Batch_RemoveInactiveUsersFromEngShare objBatchRIU = new SL_Batch_RemoveInactiveUsersFromEngShare();
		DataBase.executeBatch(objBatchRIU, 400);
	}
	/* End */
}
/* End */