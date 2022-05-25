/**
* \arg Trigger Name   : SL_User
* \arg JIRATicket     : HL-30
* \arg CreatedOn      : 1/OCT/2014
* \arg ModifiedBy     : 
* \arg Description    : Trigger used to create or update Delegate_Public_Group__c
*/
trigger SL_User on User (after insert, after update) 
{
	SL_UserHandler objUserHandler = new SL_UserHandler(Trigger.isExecuting, Trigger.size);

	//If trigger is after insert
	if(Trigger.isAfter && Trigger.isInsert)
    {
		objUserHandler.onAfterInsert(Trigger.newMap);
	}

	//iIf trigger is after update
	if(Trigger.isAfter && Trigger.isUpdate)
	{
		objUserHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
	}

}