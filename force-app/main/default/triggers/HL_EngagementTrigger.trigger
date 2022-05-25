trigger HL_EngagementTrigger on Engagement__c (before insert, before update, before delete, after insert, after update) {
    if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Engagement) && !HL_TriggerContextUtility.ByPassOnMonthlyRevenueProcess)
    {
        HL_EngagementHandler engagementHandler = new HL_EngagementHandler(Trigger.isExecuting, Trigger.size);

        if(Trigger.IsBefore){
            if(Trigger.IsUpdate && !HL_TriggerContextUtility.ByPassOnEIT && !SL_CheckRecursive.skipOnConvert){
                engagementHandler.OnBeforeUpdate(trigger.new ,Trigger.newMap, trigger.old, trigger.oldMap);
            }
            else if(Trigger.IsInsert)
                engagementHandler.OnBeforeInsert(Trigger.New);
        }
        else if(Trigger.isAfter){
            if(Trigger.isInsert){
                engagementHandler.onAfterInsert(Trigger.newMap);
                //HL_EngagementHandler.PortfolioValuation(trigger.new);
            }
            else if(Trigger.isUpdate)
                engagementHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);                 
        }
    }

    //Audit Tracking
    if(Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsDelete) &&
       HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Audit_Engagement))
    {
        
        HL_AuditRecordHandler auditHandler = new HL_AuditRecordHandler(SObjectType.Engagement__c.getSobjectType());
        auditHandler.RecordAudit(Trigger.oldMap, Trigger.newMap);
    }
}