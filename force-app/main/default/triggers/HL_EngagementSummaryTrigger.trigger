trigger HL_EngagementSummaryTrigger on Engagement_Summary__c (before insert, before update) {
    HL_EngagementSummaryHandler handler = new HL_EngagementSummaryHandler(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.IsBefore){
        if(Trigger.IsUpdate){
            handler.OnBeforeUpdate(Trigger.New);
        }
        else if(Trigger.IsInsert){
            handler.OnBeforeInsert(Trigger.New);
        }
    }
    
    if((Trigger.IsInsert && trigger.isbefore) || ((Trigger.Isupdate && trigger.isbefore)))
    {
        handler.recordvalidations(Trigger.New);
    }
}