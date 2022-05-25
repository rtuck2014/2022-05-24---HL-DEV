trigger HL_FSOpportunityTrigger on FS_OPP__c (before update, before delete) {
    //Audit Tracking
    if(Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsDelete) &&
    	 HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Audit_FS_Opp))
	  {
        HL_AuditRecordHandler auditHandler = new HL_AuditRecordHandler(SObjectType.FS_Opp__c.getSobjectType());
        auditHandler.RecordAudit(Trigger.oldMap, Trigger.newMap);
    }
}