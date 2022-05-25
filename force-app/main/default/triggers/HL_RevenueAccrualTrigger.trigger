trigger HL_RevenueAccrualTrigger on Revenue_Accrual__c (before insert, after insert, before update, after update, before delete)
{
    if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Revenue_Accrual))
    {
        //Creating instance of handler class.
        HL_RevenueAccrualHandler handler = new HL_RevenueAccrualHandler(Trigger.isExecuting, Trigger.size);

        //If trigger is before insert
        if(trigger.isBefore && trigger.isInsert)
            handler.onBeforeInsert(Trigger.new);

        //If trigger is after insert
        if(trigger.isAfter && trigger.isInsert)
            handler.onAfterInsert(Trigger.newMap);

        //if trigger is before update
        if(trigger.isBefore && trigger.isUpdate)
            handler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);

        //If trigger is after update
        if(trigger.isAfter && trigger.isUpdate)
            handler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }

    //Audit Tracking
    if(Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsDelete) &&
       HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Audit_Revenue_Accrual))
    {
        HL_AuditRecordHandler auditHandler = new HL_AuditRecordHandler(SObjectType.Revenue_Accrual__c.getSobjectType());
        auditHandler.RecordAudit(Trigger.oldMap, Trigger.newMap);
    }
}