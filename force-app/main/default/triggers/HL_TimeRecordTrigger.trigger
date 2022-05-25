trigger HL_TimeRecordTrigger on Time_Record__c (before insert, before update,after insert, after update, after delete) {
    HL_TimeRecordHandler handler = new HL_TimeRecordHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
            handler.OnAfterInsert(Trigger.new);
        else if(Trigger.isUpdate)
            handler.OnAfterUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
        else if(Trigger.isDelete){
            handler.OnAfterDelete(Trigger.old);
        }
    } 
     else if(Trigger.isBefore){ 
            if(Trigger.isInsert){
                handler.OnBeforeInsert(Trigger.New);}
                else if(Trigger.isUpdate){
                 handler.OnBeforeUpdate(Trigger.New,Trigger.Oldmap);
                }
        }
}