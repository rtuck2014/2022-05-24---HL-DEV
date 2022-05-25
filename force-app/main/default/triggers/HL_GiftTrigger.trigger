trigger HL_GiftTrigger on Gift__c (before insert, after insert, after update, after delete) {
	if (HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Gift)) {
		HL_GiftHandler handler = new HL_GiftHandler(Trigger.isExecuting, Trigger.size);

		if (Trigger.isBefore) {
			if (Trigger.isInsert)
				handler.OnBeforeInsert(Trigger.new);
		}
		else {
			if (Trigger.isInsert)
				handler.OnAfterInsert(Trigger.new);
			else if (Trigger.isUpdate)
				handler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap);
			else if (Trigger.isDelete)
				handler.OnAfterDelete(Trigger.old);
		}
	}
}