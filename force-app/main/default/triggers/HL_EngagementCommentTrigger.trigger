trigger HL_EngagementCommentTrigger on Engagement_Comment__c (before update, after insert, after update, after delete) {
	if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Engagement_Comment))
	{
		//Creating instance of handler class.
	    HL_EngagementCommentHandler handler = new HL_EngagementCommentHandler(Trigger.isExecuting, Trigger.size);

	    if(trigger.isAfter){
	    	if(trigger.isUpdate)
	    		handler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
		    if(trigger.isInsert)
		        handler.onAfterInsert(Trigger.newMap);
		    if(trigger.isDelete)
		    	handler.onAfterDelete(Trigger.oldMap);
	    }
    }
}