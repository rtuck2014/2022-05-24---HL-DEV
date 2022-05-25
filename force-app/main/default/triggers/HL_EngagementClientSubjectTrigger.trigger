trigger HL_EngagementClientSubjectTrigger on Engagement_Client_Subject__c (after insert, after update, after delete, before insert, before update, before delete) {

if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.EngagementClientSubject))
  {

    HL_EngagementClientSubjectHandler handler = new HL_EngagementClientSubjectHandler(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.IsAfter){
        if(Trigger.isInsert)
            handler.OnAfterInsert(Trigger.New);
        else if(Trigger.isUpdate)
            handler.OnAfterUpdate(Trigger.New);
        else if(Trigger.isDelete)
            handler.OnAfterDelete(Trigger.Old);
    }
    else
     {
         if(Trigger.IsInsert){
                // Added by Harsh (SF-400 Date 23th March 2017) Purpose: Added this if clause to stop duplication if this duplication happenes while inserting Client/Subject on Engagement. 
                HL_EngagementClientSubjectHandler.stopDuplicate(Trigger.new);  
                handler.OnBeforeInsert(Trigger.new);  
                handler.validateRevenueAllocation(Trigger.new,new Map<Id,Engagement_Client_Subject__c>());
                 handler.validateClientHoldings(Trigger.new,new Map<Id,Engagement_Client_Subject__c>());
                 //handler.validateFeeAttribution(Trigger.new,new Map<Id,Engagement_Client_Subject__c>());
                handler.validateKeyCreditor(Trigger.new,new Map<Id,Engagement_Client_Subject__c>()); 
            }
            else if(Trigger.IsUpdate)
            {
              // Added by Harsh (SF-400 Date 24th March 2017) Purpose: Added this if clause to validate Duplicate Record if this duplication happenes while updating Client/Subject on Engagement.
              HL_EngagementClientSubjectHandler.validateDuplicateRecord(Trigger.new,Trigger.oldMap);
              handler.validateRevenueAllocation(Trigger.new,Trigger.oldMap);
                 handler.validateClientHoldings(Trigger.new,Trigger.oldMap);
                 //handler.validateFeeAttribution(Trigger.new,Trigger.oldMap);
                handler.validateKeyCreditor(Trigger.new,Trigger.oldMap); 
            }
            else if(Trigger.IsDelete)
            {
                // Added by Harsh (SF-507 Date 20th March 2017) Purpose: Added this if clause to stop deletion if this deletion happenes while updating Client/Subject on Engagement. 
                if(!HL_ConstantsUtil.StopValidation)
                    HL_EngagementClientSubjectHandler.stopDeletion(Trigger.Old);
            }
      }
  }
}