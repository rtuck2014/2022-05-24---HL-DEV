trigger HL_RevenueProjectionTrigger on Revenue_Projection__c (before insert, before update, after insert, after update, after delete) {
	HL_RevenueProjectionHandler revenueProjectionHandler = new HL_RevenueProjectionHandler();
    if(Trigger.IsBefore && Trigger.IsInsert) {
        revenueProjectionHandler.onBeforeInsert(Trigger.new);
    }
	
    if(Trigger.IsBefore && Trigger.IsUpdate) {
        revenueProjectionHandler.onBeforeUpdate(Trigger.new);
    }
    
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
        if (trigger.isUpdate) {
            revenueProjectionHandler.onAfterUpdate(Trigger.new);
        } else {
            revenueProjectionHandler.onAfterInsert(Trigger.newMap, Trigger.new);
        }
        
    }  

    if(trigger.isAfter && trigger.isDelete) {
        revenueProjectionHandler.onAfterDelete(Trigger.old);
    }
}