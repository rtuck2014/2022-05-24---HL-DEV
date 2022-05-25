trigger HL_MonthlyRevenueProcessControlTrigger on Monthly_Revenue_Process_Control__c (before update, after update) {
	if (HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Monthly_Revenue_Process_Control)) {
		HL_MonthlyRevenueProcessControlHandler handler = new HL_MonthlyRevenueProcessControlHandler(Trigger.isExecuting, Trigger.size);

		if (Trigger.isBefore) {
			if (Trigger.isUpdate)
				handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
		}
		if(Trigger.isAfter){
			if(Trigger.isUpdate){
				handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
			}
		}
	}
}