/***************************************************************************
Name        : HL_Event_Expense_Trigger
Created     : 4/6/2018
Description : To handle all triggers of Event_Expense__c
******************************************************************************/
trigger HL_Event_Expense_Trigger on Event_Expense__c (after insert, before insert, before update,  after update, before delete,  after delete) {
    if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Event_Expense)){
        If(trigger.IsBefore)
        {
            if(trigger.isInsert)
            {
                HL_Event_Expense_TriggerHandler.beforeInsert(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);  
            }
            else if(trigger.IsUpdate){        
                HL_Event_Expense_TriggerHandler.beforeUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap); 
            }
            else if(trigger.IsDelete){
                HL_Event_Expense_TriggerHandler.beforeDelete(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            }
        }   
        else {
            if(trigger.IsInsert) {
               HL_Event_Expense_TriggerHandler.afterInsert(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);  
            }
            else if(trigger.IsUpdate) {            
               HL_Event_Expense_TriggerHandler.afterUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);              
            }
            else if(trigger.IsDelete) {
                    
            }
        }
     } 
}