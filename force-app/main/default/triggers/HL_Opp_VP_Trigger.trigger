trigger HL_Opp_VP_Trigger on Opp_VP__c (after insert, before insert, before update,  after update, before delete,  after delete) {
    If(trigger.IsBefore)
    {
        if(trigger.isInsert)
        {
            HL_Opp_VP_TriggerHelper.beforeInsert(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);  
        }
        else if(trigger.IsUpdate){        
            HL_Opp_VP_TriggerHelper.beforeUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap); 
        }
        else if(trigger.IsDelete){
            HL_Opp_VP_TriggerHelper.beforeDelete(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        }
    }   
    else {
        if(trigger.IsInsert) {
           HL_Opp_VP_TriggerHelper.afterInsert(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);  
        }
        else if(trigger.IsUpdate) {            
        }
        else if(trigger.IsDelete) {
                
        }
    } 
}