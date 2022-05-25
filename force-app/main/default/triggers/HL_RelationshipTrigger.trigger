trigger HL_RelationshipTrigger on Relationship__c (before insert, before update, before delete, after insert, after update) {
    //Creating instance of handler class.
    SL_RelationshipHandler objRelationshipHandler = new SL_RelationshipHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isBefore)
    {
        if(Trigger.isInsert){
            HL_RelationshipHandler.UpdateOwnerOnInsert(Trigger.New);
        }
        if(Trigger.isUpdate){
            HL_RelationshipHandler.UpdateOwnerOnUpdate(Trigger.oldMap, Trigger.New);
        }
    }
    else {
        if(Trigger.isInsert){
            objRelationshipHandler.onAfterInsert(Trigger.newMap);
        }
        if (Trigger.isUpdate){
            objRelationshipHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }

    //Audit Tracking
    if(Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsDelete) &&
       HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Audit_Relationship))
    {
        HL_AuditRecordHandler auditHandler = new HL_AuditRecordHandler(SObjectType.Relationship__c.getSobjectType());
        auditHandler.RecordAudit(Trigger.oldMap, Trigger.newMap);
    }
}