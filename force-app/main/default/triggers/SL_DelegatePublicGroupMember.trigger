/**
* \arg Trigger Name   : SL_DelegatePublicGroupMember
* \arg JIRATicket     : HL-30
* \arg CreatedOn      : 06/Oct/2014
* \arg ModifiedBy     : Lodhi
* \arg Description    : Trigger to manage the Group Member on the basis of Delegate Public Group Member records.
*/

trigger SL_DelegatePublicGroupMember on Delegate_Public_Group_Member__c (after delete, after insert, after update) 
{
	SL_DelegatePublicGroupMemberHandler objHandler = new SL_DelegatePublicGroupMemberHandler(Trigger.isExecuting, Trigger.size);

	//If trigger is after insert
	if(Trigger.isAfter && Trigger.isInsert)
    {
		objHandler.onAfterInsert(Trigger.newMap);
	}
	
	//If trigger is after update
	if(Trigger.isAfter && Trigger.isUpdate)
    {
		objHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
	}
	
	//If trigger is after delete
	if(Trigger.isAfter && Trigger.isDelete)
    {
		objHandler.onAfterDelete(Trigger.oldMap);
	}
}