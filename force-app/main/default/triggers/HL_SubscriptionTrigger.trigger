//Assigns Apex Sharing Rules to the HL_Report_Link__c Records
trigger HL_SubscriptionTrigger on HL_Subscription__c (after insert, after update, after delete) {
    if(Trigger.isAfter){
        HL_SubscriptionHandler handler = new HL_SubscriptionHandler(Trigger.isExecuting, Trigger.size);
        if(Trigger.isInsert)
            handler.onAfterInsert(Trigger.New);
        else if(Trigger.isUpdate)
            handler.onAfterUpdate(Trigger.OldMap, Trigger.NewMap);
        else if(Trigger.isDelete)
            handler.onAfterDelete(Trigger.Old);
    }
}