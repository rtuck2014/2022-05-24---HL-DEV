trigger HL_BidTrigger on Bid__c (before update, before delete) {
	//Audit Tracking
	if (Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsDelete) &&
			HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Audit_Bid))
	{
		HL_AuditRecordHandler auditHandler = new HL_AuditRecordHandler(SObjectType.Bid__c.getSobjectType());
		auditHandler.RecordAudit(Trigger.oldMap, Trigger.newMap);
	}
}