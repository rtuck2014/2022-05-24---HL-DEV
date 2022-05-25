trigger HL_RivaActivityLinkTrigger on Activity_Link__c (after insert, after update, after delete) {
	if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Riva_Activity_Link)){
        HL_RivaActivityLinkHandler handler = new HL_RivaActivityLinkHandler(Trigger.isExecuting, Trigger.size);
        if(Trigger.isAfter){
            if(Trigger.isDelete)
                handler.OnAfterDelete(Trigger.OldMap);
            else if(Trigger.isUpdate)
                handler.OnAfterUpdate(Trigger.New);
        }
    }
}