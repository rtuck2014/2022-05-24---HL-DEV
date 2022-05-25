trigger HL_AccountTrigger on Account (before insert, before update, before delete, after delete, after update) {
    if (HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Account)){
        HL_AccountHandler handler = new HL_AccountHandler(Trigger.isExecuting, Trigger.size);

        if (Trigger.isBefore && Trigger.isInsert)
            handler.OnBeforeInsert(Trigger.new);

        if (Trigger.isBefore && Trigger.isUpdate){
            handler.IsEUForCF(Trigger.new);
            handler.OnBeforeUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
            }

        if (Trigger.isAfter && Trigger.isUpdate)
            handler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap);

        if (Trigger.isBefore && Trigger.isDelete)
            handler.OnBeforeDelete(Trigger.oldMap);

        if (Trigger.isAfter && Trigger.isDelete)
            handler.OnAfterDelete(Trigger.oldMap);           
       
    }

    //Audit Tracking
    if (Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsDelete)
            && HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Audit_Account))
    {
        HL_AuditRecordHandler auditHandler = new HL_AuditRecordHandler(SObjectType.Account.getSobjectType());
        auditHandler.RecordAudit(Trigger.oldMap, Trigger.newMap);
    }
}