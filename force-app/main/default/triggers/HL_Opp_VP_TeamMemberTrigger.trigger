trigger HL_Opp_VP_TeamMemberTrigger on Opp_VP_TeamMember__c (after delete, after insert, after update, before delete, before insert, before update) {
   // if(userinfo.getuserid()=='00531000007iJuN'){
    If(trigger.IsBefore)
    {
        if(trigger.isInsert)
        {
          HL_Opp_VP_TeamMemberTriggerHelper.beforeInsert(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        }
        else if(trigger.IsUpdate) {
          HL_Opp_VP_TeamMemberTriggerHelper.beforeUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        }
        else if(trigger.IsDelete) {
            HL_Opp_VP_TeamMemberTriggerHelper.beforeDelete(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        }
    }   
    else
    {
        if(trigger.IsInsert)
        {
          HL_Opp_VP_TeamMemberTriggerHelper.afterInsert(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);     
        }
        else if(trigger.IsUpdate) {
          HL_Opp_VP_TeamMemberTriggerHelper.afterUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        }
        else if(trigger.IsDelete) {
          HL_Opp_VP_TeamMemberTriggerHelper.afterDelete(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        }
    }
 //  }
}