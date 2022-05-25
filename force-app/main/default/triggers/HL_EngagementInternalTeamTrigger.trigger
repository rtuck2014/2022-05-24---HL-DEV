trigger HL_EngagementInternalTeamTrigger on Engagement_Internal_Team__c (before Insert, before update, before delete, after insert, after update, after delete) {
    
    // PRJ0016533 - Office Revenue Allocation on Engagement Internal Team 
    // To populate 'Revenue Allocation' on insert of Internal Team from Contact
    if(Trigger.isBefore){
        HL_EngagementInternalTeamHandler handler = new HL_EngagementInternalTeamHandler(Trigger.isExecuting, Trigger.size);
        if(Trigger.isInsert)
            handler.onBeforeInsert(Trigger.New);
    }
    if(Trigger.isAfter)
    {
        HL_EngagementInternalTeamHandler hlHandler = new HL_EngagementInternalTeamHandler(Trigger.isExecuting, Trigger.size);
        HL_TriggerContextUtility.ByPassOnEIT = true;

        if(Trigger.isInsert)
            hlHandler.OnAfterInsert(Trigger.New);
        else if(Trigger.isUpdate)
            hlHandler.OnAfterUpdate(Trigger.New, Trigger.oldMap, Trigger.newMap);
        else if(Trigger.isDelete)
            hlHandler.OnAfterDelete(Trigger.Old, Trigger.oldMap);

        hlHandler.onAllAfterEvents(Trigger.oldMap, Trigger.newMap);
    }

    //Audit Tracking
    if(Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsDelete) &&
       HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Audit_Engagement_Internal_Team))
    {
        HL_AuditRecordHandler auditHandler = new HL_AuditRecordHandler(SObjectType.Engagement_Internal_Team__c.getSobjectType());
        auditHandler.RecordAudit(Trigger.oldMap, Trigger.newMap);
    }
}