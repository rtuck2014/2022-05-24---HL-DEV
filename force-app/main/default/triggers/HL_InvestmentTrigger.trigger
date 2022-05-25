trigger HL_InvestmentTrigger on Investment__c (before insert, after insert, before update, after update) {
    //Enable/Disable trigger setting
    if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Investment)){
        //Creating instance of handler class
        HL_InvestmentHandler handler = new HL_InvestmentHandler(Trigger.isExecuting, Trigger.size);
        if(Trigger.isInsert){

            if(Trigger.isBefore){
                handler.OnBeforeInsert(Trigger.new);
            }
        
            if(Trigger.isAfter){
                handler.OnAfterInsert(Trigger.newMap);
            }
        }
        if(Trigger.isUpdate){
            if(Trigger.isBefore){
                handler.OnBeforeUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
            }
        }
    }
    
     //Audit Tracking
    if (Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsDelete) &&
            HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Audit_Investment))
    {
        HL_AuditRecordHandler auditHandler = new HL_AuditRecordHandler(SObjectType.Investment__c.getSobjectType());
        auditHandler.RecordAudit(Trigger.oldMap, Trigger.newMap);
    }    
}