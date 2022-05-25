/**
* \arg Trigger Name   : SL_DelegatePublicGroup
* \arg JIRATicket     : HL-30
* \arg CreatedOn      : 1/OCT/2014
* \arg ModifiedBy     : 
* \arg Description    : Trigger used to create group, groupmember and update the Public_Group_ID__c field of Delegate_Public_Group__c
*/
trigger SL_DelegatePublicGroup on Delegate_Public_Group__c (before insert, after delete) 
{	
	SL_DelegatePublicGroupHandler objHandler = new SL_DelegatePublicGroupHandler(Trigger.isExecuting, Trigger.size);
	
	//If trigger is after insert
	if(Trigger.isBefore && Trigger.isInsert)
    {
		objHandler.onBeforeInsert(Trigger.new);      
	}
	
	//If trigger is after delete
	if(Trigger.isAfter && Trigger.isDelete)
    {
		objHandler.onAfterDelete(Trigger.old);
	}
}