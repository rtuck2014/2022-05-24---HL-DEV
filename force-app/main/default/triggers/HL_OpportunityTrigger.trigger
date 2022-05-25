trigger HL_OpportunityTrigger on Opportunity__c (before insert, before update, before delete, after insert, after update) {
    
    if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Opportunity)){
        //Creating instance of handler class.
        HL_OpportunityHandler handler = new HL_OpportunityHandler(Trigger.isExecuting, Trigger.size);

        if(Trigger.isAfter)
        {
            if(Trigger.isInsert)
                handler.OnAfterInsert(Trigger.newMap);
            else if(Trigger.isUpdate && !SL_CheckRecursive.skipOnConvert)
                handler.OnAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
        else if(Trigger.isBefore){
            if(Trigger.IsUpdate && !SL_CheckRecursive.skipOnConvert)
                handler.OnBeforeUpdate(Trigger.Old,Trigger.newMap);
            else if(Trigger.isInsert)
                handler.OnBeforeInsert(Trigger.New);
                //added by Shruthi on 9th Dec 2021
            if(Trigger.IsUpdate || Trigger.Isinsert)
            {
                handler.OnBeforeUpsert(Trigger.New);    
            }
            //added by Shruthi on 9th Dec 2021
        }

        //Audit Tracking
        if(Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsDelete) &&
           HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Audit_Opportunity))
        {
            HL_AuditRecordHandler auditHandler = new HL_AuditRecordHandler(SObjectType.Opportunity__c.getSobjectType());
            auditHandler.RecordAudit(Trigger.oldMap, Trigger.newMap);
        }
    }
}