trigger HL_OpportunityInternalTeamTrigger on Opportunity_Internal_Team__c (before Insert, before update, before delete, after insert, after update, after delete) {
    
    // PRJ0016533 - Office Revenue Allocation on Engagement Internal Team 
    // To populate 'Revenue Allocation' on insert of Internal Team from Contact
    if(Trigger.isBefore){
        HL_OpportunityInternalTeamHandler handler = new HL_OpportunityInternalTeamHandler(Trigger.isExecuting, Trigger.size);
        if(Trigger.isInsert)
            handler.onBeforeInsert(Trigger.New);
    }
    if(Trigger.isAfter)
    {
        HL_OpportunityInternalTeamHandler handler = new HL_OpportunityInternalTeamHandler(Trigger.isExecuting, Trigger.size);

        if(Trigger.isInsert)
            handler.onAfterInsert(Trigger.New);
        else if(Trigger.isUpdate)
            handler.onAfterUpdate(Trigger.oldMap, Trigger.newMap, Trigger.New);
        else if(Trigger.isDelete){
            handler.onAfterDelete(Trigger.oldMap, Trigger.Old);
        }
    }

    //Audit Tracking
    if(Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsDelete) &&
       HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Audit_Opportunity_Internal_Team))
    {
        HL_AuditRecordHandler auditHandler = new HL_AuditRecordHandler(SObjectType.Opportunity_Internal_Team__c.getSobjectType());
        auditHandler.RecordAudit(Trigger.oldMap, Trigger.newMap);
    }
}