trigger HL_EngagementTitleRateSheetTrigger on Engagement_Title_Rate_Sheet__c (before insert, before update, after insert, after update) {

	HL_EngagementTitleRateSheetHandler handler = new HL_EngagementTitleRateSheetHandler(Trigger.isExecuting, Trigger.size);

	if(Trigger.isInsert){
		if(Trigger.isBefore)
			handler.onBeforeInsert(Trigger.new);
		else
			handler.onAfterInsert(Trigger.new);
	}
	else if(Trigger.isUpdate){
		if(Trigger.isBefore)
			handler.onBeforeUpdate(Trigger.new);
		else
			handler.onAfterUpdate(Trigger.new);
	}

}