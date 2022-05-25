trigger HL_FSEngagementTrigger on FS_Engagement__c (before update, before delete) {
    //Audit Tracking
    if(Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsDelete) &&
    	 HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Audit_FS_Engagement))
		{
        HL_AuditRecordHandler auditHandler = new HL_AuditRecordHandler(SObjectType.FS_Engagement__c.getSobjectType());
        auditHandler.RecordAudit(Trigger.oldMap, Trigger.newMap);
    }
}