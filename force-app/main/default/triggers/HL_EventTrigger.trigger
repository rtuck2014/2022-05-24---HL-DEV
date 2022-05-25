trigger HL_EventTrigger on Event (before insert, before update, before delete, after insert, after update, after delete) {
    if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Event)){
        HL_EventHandler handler = new HL_EventHandler(Trigger.isExecuting, Trigger.size);
        if(Trigger.isAfter){
            if(Trigger.isUpdate && HL_TriggerContextUtility.IsFirstRun())
                handler.OnAfterUpdate(Trigger.New);
            else if(Trigger.isDelete)
                handler.OnAfterDelete(Trigger.OldMap);
        }
        else if(Trigger.isBefore && Trigger.IsInsert)
            handler.OnBeforeInsert(Trigger.New);
    }

    //Audit Tracking
    if(Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsDelete) &&
       HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Audit_Event)){
        HL_AuditRecordHandler auditHandler = new HL_AuditRecordHandler(SObjectType.Event.getSobjectType());
        auditHandler.RecordAudit(Trigger.oldMap, Trigger.newMap);
    }
}