trigger HL_ContactTrigger on Contact (before update, before delete, after insert, after update, after delete) {
    //If trigger is after insert
    if (Trigger.isAfter) {
        //Creating instance of handler class.
        HL_ContactHandler contactHandler = new HL_ContactHandler(Trigger.isExecuting, Trigger.size);

        if (Trigger.isInsert)
            contactHandler.onAfterInsert(Trigger.newMap);
        if (Trigger.isUpdate)
            contactHandler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap, Trigger.new);
        if (Trigger.isDelete)
            contactHandler.onAfterDelete(Trigger.oldMap);
    }

    //Audit Tracking
    if (Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsDelete) &&
            HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Audit_Contact))
    {
        HL_AuditRecordHandler auditHandler = new HL_AuditRecordHandler(SObjectType.Contact.getSobjectType());
        auditHandler.RecordAudit(Trigger.oldMap, Trigger.newMap);
    }
}