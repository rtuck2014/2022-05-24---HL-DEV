trigger HL_Eng_VP_Trigger on Eng_VP__c (after insert, before insert, before update,  after update, before delete,  after delete) {
    If(trigger.IsBefore)
    {
        if(trigger.isInsert)
        {
            HL_Eng_VP_TriggerHelper.beforeInsert(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);  
        }
        else if(trigger.IsUpdate){        
            HL_Eng_VP_TriggerHelper.beforeUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap); 
        }
        else if(trigger.IsDelete){
            HL_Eng_VP_TriggerHelper.beforeDelete(trigger.old); 
        }
    }   
    else {
        if(trigger.IsInsert) {
           HL_Eng_VP_TriggerHelper.afterInsert(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);  
        }
        else if(trigger.IsUpdate) {  
            HL_Eng_VP_TriggerHelper.afterUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);        
        }        
        else if(trigger.IsDelete) {
            HL_Eng_VP_TriggerHelper.afterDelete(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);                  
        }
    } 
}