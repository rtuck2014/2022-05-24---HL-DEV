trigger HL_EngagementAllocationTrigger on Engagement_Allocation__c (before insert, after insert, before update, after update, before delete)
{
        boolean isActive = false;
        if( Test.isRunningTest())
        {
        isActive = true;
        }
        else
        { 
        isActive = HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Engagement_Allocation);
        }
    if(isActive)
    {
        //Creating instance of handler class.
        HL_EngagementAllocationHandler handler = new HL_EngagementAllocationHandler(Trigger.isExecuting, Trigger.size);

        //If trigger is before insert
        if(trigger.isBefore && trigger.isInsert)
            handler.onBeforeInsert(Trigger.new);

        //If trigger is after insert
        if(trigger.isAfter && trigger.isInsert)
            handler.onAfterInsert(Trigger.newMap);

          }

    
}