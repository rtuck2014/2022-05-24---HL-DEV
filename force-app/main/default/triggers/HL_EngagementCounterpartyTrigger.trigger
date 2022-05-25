trigger HL_EngagementCounterpartyTrigger on Engagement_Counterparty__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    HL_EngagementCounterpartyHandler handler = new HL_EngagementCounterpartyHandler(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.IsBefore){
        if(Trigger.IsInsert)
            handler.UpdateDefaultFields(Trigger.New);
        else if(Trigger.IsUpdate)
            handler.InsertCounterpartyComments(Trigger.New);
    }
    else if(Trigger.isAfter)
    {
        if(Trigger.isInsert){
            handler.InsertConversionRelatedItems(Trigger.New);
            handler.onAfterInsert(Trigger.New);
        }
        else if(Trigger.isUpdate)
            handler.onAfterUpdate(Trigger.Old,Trigger.newMap);
        else if(Trigger.isDelete)
            handler.onAfterDelete(Trigger.Old);
        else if(Trigger.isUndelete)
            handler.onAfterUndelete(Trigger.New);
    }
    
    //Audit Tracking
    if(Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsDelete) &&
       HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Audit_Engagement_Counterparty))
    {
        HL_AuditRecordHandler auditHandler = new HL_AuditRecordHandler(SObjectType.Engagement_Counterparty__c.getSobjectType());
        auditHandler.RecordAudit(Trigger.oldMap, Trigger.newMap);
    }
}