public without sharing class HL_ActivitySupplement {
    public Activity_Supplement__c ActivitySupplement {get; set;}
    private Event Event {get; set;}
    private List<Contact> RelatedContacts {get; set;}
    public HL_ActivitySupplement(Event event, List<Contact> relatedContacts) {
        this.ActivitySupplement = new Activity_Supplement__c(Activity__c = event.Id);
        this.Event = event;
        this.RelatedContacts = relatedContacts;

        //Generate the Sync Description
        GenerateSyncDescription();
    }

    private void GenerateSyncDescription(){
        ActivitySupplement.Sync_Description__c = HL_Activity.SYNC_DIVIDER + ('\n'.repeat(2));
        
        for(Contact c : RelatedContacts){
             if(c != null)
                ActivitySupplement.Sync_Description__c += c.Name + (!String.isBlank(c.Email) ? ' - ' + c.Email : '') + '\n';
        }

        //Append Link Back to Record
        ActivitySupplement.Sync_Description__c += ('\n'.repeat(2)) + 'To View the Activity in Salesforce, Use The Link Below:\n' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + Event.Id;
    }

    //Generate or Refresh the Sync Description for the Events
    public static List<Activity_Supplement__c> RefreshSyncDescription(List<Event> eList){
        List<Id> idList = new List<Id>();
        Map<Id, List<Contact>> eventToRelatedContactMap = new Map<Id, List<Contact>>();
        Map<Id, Activity_Supplement__c> existingSupplementMap = new Map<Id, Activity_Supplement__c>();
        List<Activity_Supplement__c> asToUpsert = new List<Activity_Supplement__c>();

        for(Event e: eList)
            idList.add(e.Id);

        //Get the Related Contact Records
        for(Event e : [SELECT ParentId__c, Contact__r.Name, Contact__r.Email, Contact__r.RecordType.DeveloperName FROM Event WHERE ParentId__c IN: idList]){
            Contact c = e.Contact__r;
            if(c != null && c.RecordType.DeveloperName == 'EXTERNAL_CONTACT'){
                if(eventToRelatedContactMap.get(e.ParentId__c) == null)
                    eventToRelatedContactMap.put(e.ParentId__c, new List<Contact> {c});
                else{
                    List<Contact> cList = eventToRelatedContactMap.get(e.ParentId__c);
                    cList.add(c);
                }
            }
        }
        
        //Get the Existing Supplement Records
        for(Activity_Supplement__c s : [SELECT Activity__c, Sync_Description__c FROM Activity_Supplement__c WHERE Activity__c IN: idList])
            existingSupplementMap.put(s.Activity__c, s);
        
        for(Id id : idList){
            Activity_Supplement__c s = existingSupplementMap.get(id);

            if(s == null)
                s = new Activity_Supplement__c(Activity__c = id);

            List<Contact> cList = eventToRelatedContactMap.get(id);
            if(cList != null){
                s.Sync_Description__c = new HL_ActivitySupplement(new Event(Id = id), eventToRelatedContactMap.get(id)).ActivitySupplement.Sync_Description__c;
                asToUpsert.add(s);
            }
        }

        if(asToUpsert.size() > 0)
            upsert asToUpsert;
        
        return new List<Activity_Supplement__c>();
    }
}