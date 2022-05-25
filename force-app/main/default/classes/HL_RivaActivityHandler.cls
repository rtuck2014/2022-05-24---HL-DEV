public without sharing class HL_RivaActivityHandler {
    private boolean isExecuting = false;
	private integer batchSize = 0;
	public boolean IsTriggerContext{get{ return isExecuting;}}
    public static Boolean isAfterInsertFlag = false;
    public static Boolean isAfterUpdateFlag = false;
    public static Boolean isAfterDeleteFlag = false;

    public HL_RivaActivityHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
    }
    
    public void OnAfterUpdate(Map<Id, Activity__c> newRecordsMap){
        if(!isAfterUpdateFlag){
            isAfterUpdateFlag = true;
            Set<Id> rivaIds = newRecordsMap.keySet();
            for(List<Activity_Link__c> relatedLinks : [SELECT ActivityId__c, ContactId__c, DisplayName__c, Event__c, IsInvitee__c FROM Activity_Link__c WHERE ActivityId__c IN : rivaIds AND ContactId__c <> null])
            {
                HL_RivaActivityLinkHandler handler = new HL_RivaActivityLinkHandler(false, relatedLinks.size());
                handler.OnAfterUpdate(relatedLinks);
            }
        }
    }
    
    public void OnAfterDelete(Map<Id,Activity__c> deletedRecordsMap){
        if(!isAfterDeleteFlag){
            isAfterDeleteFlag = true;
            List<Event> relatedEvents = [SELECT Id FROM Event WHERE Riva_Activity_Id__c IN : deletedRecordsMap.keySet()];
            if(relatedEvents.size() > 0)
                delete relatedEvents; 
        }
    }
}