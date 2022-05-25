trigger HL_OffsiteTemplateTrigger on Offsite_Template__c (before insert, after insert) {
	if(Trigger.isAfter && Trigger.isInsert){
		HL_OffsiteTemplateHandler handler = new HL_OffsiteTemplateHandler(Trigger.isExecuting, Trigger.size);
		handler.OnAfterInsert(Trigger.new);
	}
	else if(Trigger.isBefore && Trigger.isInsert){
		HL_OffsiteTemplateHandler handler = new HL_OffsiteTemplateHandler(Trigger.isExecuting, Trigger.size);
		handler.OnBeforeInsert(Trigger.new);
	}
}