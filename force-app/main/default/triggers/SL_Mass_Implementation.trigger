/**
 * 
 * @author Privlad
 */
trigger SL_Mass_Implementation on SL_Mass_Implementation__c (after delete, after insert, after undelete, after update, before delete, before insert, before update)
{
	SL_LIB16_handler_Implementation handler = new SL_LIB16_handler_Implementation(Trigger.isExecuting, Trigger.size);
	
	if (trigger.IsInsert) {
		
		if (trigger.IsBefore) {
			handler.OnBeforeInsert(Trigger.new);
		} else {
			handler.OnAfterInsert(Trigger.newMap);
		}
		
	} else if (trigger.IsUpdate) {
		
		if(trigger.IsBefore){
			handler.OnBeforeUpdate(Trigger.oldMap,Trigger.newMap);
		} else {    
			handler.OnAfterUpdate(Trigger.oldMap,Trigger.newMap);
		}
		
	} else if (trigger.isDelete) {
		
		if (trigger.IsBefore) {
			handler.OnBeforeDelete(Trigger.oldMap);
		} else {
			handler.OnAfterDelete(Trigger.oldMap);
		}
		
	} else {
		
		if (trigger.IsBefore) {
			handler.OnBeforeUndelete(trigger.new);
		} else {
			handler.OnAfterUndelete(trigger.new);
		}
		
	}

}