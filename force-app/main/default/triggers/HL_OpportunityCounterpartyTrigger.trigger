trigger HL_OpportunityCounterpartyTrigger on Opportunity_Counterparty__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Opportunity_Counterparty))
    {
        HL_OpportunityCounterpartyHandler och = new HL_OpportunityCounterpartyHandler(Trigger.New);
        if(Trigger.IsBefore){
            if(Trigger.IsInsert)
                och.UpdateDefaultFields();
            else if(Trigger.IsUpdate)
                och.InsertCounterpartyComments();
        }
        else if(Trigger.isAfter){
            if(Trigger.isInsert)
                och.onAfterInsert(Trigger.New);
            else if(Trigger.isUpdate)
                och.onAfterUpdate(Trigger.Old,Trigger.newMap);
            else if(Trigger.isDelete)
                och.onAfterDelete(Trigger.Old);
            else if(Trigger.isUndelete)
                och.onAfterUndelete(Trigger.New);
        }
    }
    
    //Audit Tracking
    if(Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsDelete) &&
       HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Audit_Opportunity_Counterparty))
    {
        HL_AuditRecordHandler auditHandler = new HL_AuditRecordHandler(SObjectType.Opportunity_Counterparty__c.getSobjectType());
        auditHandler.RecordAudit(Trigger.oldMap, Trigger.newMap);
    }
}