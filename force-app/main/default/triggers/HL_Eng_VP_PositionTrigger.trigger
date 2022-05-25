trigger HL_Eng_VP_PositionTrigger on Eng_VP_Position__c (after insert, before insert, before update,  after update, before delete,  after delete) {
  
 if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Valuation_Period_Position)){
 
      If(trigger.IsBefore){
            if(trigger.isInsert)
            {
              HL_Eng_VP_PositionTriggerHelper.beforeInsert(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            }
            else if(trigger.IsUpdate) {
              HL_Eng_VP_PositionTriggerHelper.beforeUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            }
            else if(trigger.IsDelete) {
                HL_Eng_VP_PositionTriggerHelper.beforeDelete(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);            
            }
      }
    
    else{
        if(trigger.IsInsert){
          HL_Eng_VP_PositionTriggerHelper.afterInsert(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);     
        }
        else if(trigger.IsUpdate){
          HL_Eng_VP_PositionTriggerHelper.afterUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        }
        else if(trigger.IsDelete){
          HL_Eng_VP_PositionTriggerHelper.afterDelete(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        }
    }
 }  
}