trigger HL_OpportunityCommentTrigger on Opportunity_Comment__c (before insert, before update, after insert, after update, after delete) {
	if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Opportunity_Comment))
	{
	    HL_OpportunityCommentHandler handler = new HL_OpportunityCommentHandler(Trigger.isExecuting, Trigger.size);

	    if(trigger.isAfter)
	    {
		    if(trigger.isUpdate)
		    	handler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
		    if(trigger.isInsert)
		        handler.onAfterInsert(Trigger.newMap);
		    if(trigger.isDelete)
		    	handler.onAfterDelete(Trigger.oldMap);
	    }
    }
}