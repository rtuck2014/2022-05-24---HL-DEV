trigger HL_RivaActivityTrigger on Activity__c (after insert, after update, after delete) {
    if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Riva_Activity)){
        HL_RivaActivityHandler handler = new HL_RivaActivityHandler(Trigger.isExecuting, Trigger.size);

        if(Trigger.isAfter){
            if(Trigger.isUpdate)
                handler.OnAfterUpdate(Trigger.NewMap);
            else if(Trigger.isDelete)
                handler.OnAfterDelete(Trigger.OldMap);
        }
    }
}