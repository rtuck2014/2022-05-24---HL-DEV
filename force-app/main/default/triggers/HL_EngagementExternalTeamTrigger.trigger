trigger HL_EngagementExternalTeamTrigger on Engagement_External_Team__c (before insert, before update, before delete, After insert, After update) {
    if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Engagement_External_Team))
    {
        HL_EngagementExternalTeamHandler handler;
        
        if(Trigger.IsBefore){
            if(Trigger.IsDelete){
                handler = new HL_EngagementExternalTeamHandler(Trigger.Old, trigger.oldMap);
                handler.RemovePrimaryEET();
            }
            else{
                handler = new HL_EngagementExternalTeamHandler(Trigger.New, trigger.oldMap);
                handler.UpdateEETUnique();
                handler.checkForBillToBillingCountry();
                if(HL_ConstantsUtil.ToStopRecursionOfEEThandler){
                    handler.UpdatePrimaryEngagementContact();                    
                }
                if(Trigger.isInsert && !SL_CheckRecursive.skipOnConvert)
                    handler.UpdateSortFields();
            }
        }
        if(Trigger.isAfter){
            if(trigger.isInsert){
                HL_EngagementExternalTeamHandler.createEngagementContracts();
            }
            if(trigger.isUpdate){
                HL_EngagementExternalTeamHandler.createEngagementContracts();                
            }
        }
    }
    
    //Audit Tracking
    if(Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsDelete) &&
       HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Audit_Engagement_External_Team))
    {
        HL_AuditRecordHandler auditHandler = new HL_AuditRecordHandler(SObjectType.Engagement_External_Team__c.getSobjectType());
        auditHandler.RecordAudit(Trigger.oldMap, Trigger.newMap);
    }
}