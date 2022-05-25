trigger HL_OpportunityClientSubjectTrigger on Opportunity_Client_Subject__c (after insert, after update, after delete,before insert,before update, before delete) 
    {
    
if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.OpportunityClientSubject))
  {
    
        if(Trigger.IsAfter)
        {
            HL_OpportunityClientSubjectHandler.UpdatePublicPrivate(!Trigger.IsDelete ? Trigger.New : Trigger.Old);
            if(Trigger.IsInsert){
               HL_OpportunityClientSubjectHandler oHandler = New HL_OpportunityClientSubjectHandler();
               oHandler.OnAfterInsert(Trigger.New);
               }
               if(Trigger.IsDelete){
               HL_OpportunityClientSubjectHandler oHandler = New HL_OpportunityClientSubjectHandler();
               oHandler.OnAfterDelete(Trigger.Old);
               }
                
        }
        else
        { 
             HL_OpportunityClientSubjectHandler oHandler = New HL_OpportunityClientSubjectHandler();
            if(Trigger.IsInsert)
            {
              // Added by Harsh (SF-400 Date 23th March 2017) Purpose: Added this if clause to stop duplication if this duplication happenes while inserting Client/Subject on Opportunity. 
              HL_OpportunityClientSubjectHandler.stopDuplicate(Trigger.new);
              oHandler.OnBeforeInsert(Trigger.new);
                 oHandler.validateRevenueAllocation(Trigger.new,new Map<Id,Opportunity_Client_Subject__c>());
                 oHandler.validateClientHoldings(Trigger.new,new Map<Id,Opportunity_Client_Subject__c>());
                 //oHandler.validateFeeAttribution(Trigger.new,new Map<Id,Opportunity_Client_Subject__c>());
                oHandler.validateKeyCreditor(Trigger.new,new Map<Id,Opportunity_Client_Subject__c>()); 
            }
            else if(Trigger.IsUpdate)
            {
              // Added by Harsh (SF-400 Date 24th March 2017) Purpose: Added this if clause to validate Duplicate Record if this duplication happenes while updating Client/Subject on Opportunity.
              HL_OpportunityClientSubjectHandler.validateDuplicateRecord(Trigger.new,Trigger.oldMap);
              oHandler.validateRevenueAllocation(Trigger.new,Trigger.oldMap);
                 oHandler.validateClientHoldings(Trigger.new,Trigger.oldMap);
                 //oHandler.validateFeeAttribution(Trigger.new,Trigger.oldMap);
                oHandler.validateKeyCreditor(Trigger.new,Trigger.oldMap); 
            }
            else if(Trigger.IsDelete)
            {
              // Added by Sandeep (SF-507 Date 17th March 2017) Purpose: Added this if clause to stop deletion if this deletion happenes while updating Client/Subject on Opportunity. 
                if(!HL_ConstantsUtil.StopValidation)
                    HL_OpportunityClientSubjectHandler.stopDeletion(Trigger.Old);
            }
        }  
    }
}