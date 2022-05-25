trigger HL_OpportunityExternalTeamTrigger on Opportunity_External_Team__c (before insert, before update, before delete) {
    if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Opportunity_External_Team))
    {
        HL_OpportunityExternalTeamHandler handler;

        if(Trigger.IsBefore){
            if(Trigger.IsDelete){
                handler = new HL_OpportunityExternalTeamHandler(Trigger.Old);
                handler.RemovePrimaryOET();
            }
            else{
                handler = new HL_OpportunityExternalTeamHandler(Trigger.New);
                handler.UpdateOETUnique();
                handler.UpdatePrimaryOpportunityContact();
                handler.checkForBillToBillingCountry();
                if(Trigger.isInsert)
                    handler.UpdateSortFields();
            }
        } 
    }

    //Audit Tracking
    if(Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsDelete) &&
       HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Audit_Opportunity_External_Team))
    {
        HL_AuditRecordHandler auditHandler = new HL_AuditRecordHandler(SObjectType.Opportunity_External_Team__c.getSobjectType());
        auditHandler.RecordAudit(Trigger.oldMap, Trigger.newMap);
    }
}