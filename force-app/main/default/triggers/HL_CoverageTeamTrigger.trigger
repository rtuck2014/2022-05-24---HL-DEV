trigger HL_CoverageTeamTrigger on Coverage_Team__c (before update, before delete, after insert, after update, after delete) {
    /*if(Trigger.isBefore && Trigger.isUpdate){
        HL_CoverageTeamHandler.validateCoverageTagging(Trigger.new, Trigger.newMap, Trigger.oldMap);
    }*/
    
    if(Trigger.isAfter)
    {
        if(Trigger.isDelete){
            HL_CoverageTeamHandler.UpdateCoverageTeamAggregateFuture(Trigger.Old);
            //            HL_CoverageTeamHandler.UpdateCoverageTeamAggregate(Trigger.Old);
            
        }
        else{
            HL_CoverageTeamHandler.UpdateCoverageTeamAggregateFuture(Trigger.New);
            //            HL_CoverageTeamHandler.UpdateCoverageTeamAggregate(Trigger.New);
        }
        
        /*if((Trigger.isInsert || Trigger.isUpdate) && HL_CoverageTeamHandler.isCovergeTriggerExecuted == false) {
            HL_CoverageTeamHandler.InsertCoverageTagging(Trigger.New, Trigger.oldMap, Trigger.isInsert);
        }*/
        
    }
    
    //Audit Tracking
    if(Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsDelete) &&
       HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Audit_Coverage_Team)){
           HL_AuditRecordHandler auditHandler = new HL_AuditRecordHandler(SObjectType.Coverage_Team__c.getSobjectType());
           auditHandler.RecordAudit(Trigger.oldMap, Trigger.newMap);
       }
}