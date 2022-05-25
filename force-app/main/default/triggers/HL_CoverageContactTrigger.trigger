trigger HL_CoverageContactTrigger on Coverage_Contact__c (after insert, after update, after delete) {
    if(Trigger.IsAfter){
        If(Trigger.IsInsert){
            HL_CoverageContactHandler handler = new HL_CoverageContactHandler(Trigger.isExecuting, Trigger.size);
            handler.OnAfterInsert(Trigger.New, Trigger.newMap);
        }
        //We Only Want to fire the Trigger On Coverage Contact Records where the Coverage Contact has Changed
        If(Trigger.IsUpdate)
            HL_CoverageContactHandler.RelationshipUpdateHandler(Trigger.Old, Trigger.NewMap);     
    }
}