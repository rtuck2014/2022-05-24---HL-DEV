public without sharing class HL_RivaActivityLinkHandler {
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public boolean IsTriggerContext{get{ return isExecuting;}}
    public static Boolean isAfterInsertFlag = false;
    public static Boolean isAfterDeleteFlag = false;
    public static Boolean isAfterUpdateFlag = false;
    
    public HL_RivaActivityLinkHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
    }
    
    public void OnAfterUpdate(List<Activity_Link__c> updatedRecords){
        if(!isAfterUpdateFlag){ 
            isAfterUpdateFlag = true;
            List<Event> eventsToInsert = new List<Event>();
            List<Event> eventsToUpdate = new List<Event>();
            Set<Id> activityParentIds = new Set<Id>();
            Set<Id> attendeeIds = new Set<Id>();
            Set<Id> parentsToUpdate = new Set<Id>();
            Set<Id> eventIds = new Set<Id>();
            Map<Id, Event> rivaToEventMap = new Map<Id,Event>();
            Map<Id, Activity_Supplement__c> eventToSupplementMap = new Map<Id,Activity_Supplement__c>();
            Map<Id, Contact> userToContactMap = new Map<Id,Contact>();
            Map<Id, Contact> attendeeToContactMap = new Map<Id, Contact>();
            Map<Id,Id> linkToOwnerIdMap = new Map<Id,Id>();
            Map<Id,Event> parentEventMap = new Map<Id,Event>();
            
            //Get Parent Activity Key Set
            for(Activity_Link__c al : updatedRecords){
                activityParentIds.add(al.ActivityId__c);
                if(!String.isBlank(al.ContactId__c))
                    attendeeIds.add(al.ContactId__c);
            }
            
            for(Activity__c a : [SELECT OwnerId FROM Activity__c WHERE Id IN : activityParentIds])
                linkToOwnerIdMap.put(a.Id, a.OwnerId);
            
            //Populate the Attendee to Contact Map
            for(Contact c : [SELECT Name, User__c, AccountId, Account.Name FROM Contact WHERE Id IN : attendeeIds])
                attendeeToContactMap.put(c.Id, c);
            
            //Populate the User to Contact Map
            for(Contact c : [SELECT Name, User__c FROM Contact WHERE User__c IN : linkToOwnerIdMap.values()])
                userToContactMap.put(c.User__c, c);
            
            //Get the Parent Activity__c Records
            Map<Id, Activity__c> parentActivitiesMap = new Map<Id, Activity__c>([SELECT GlobalObjectId__c, StartDateTime__c, EndDateTime__c,  Subject__c, Description__c, OwnerId FROM Activity__c WHERE ID IN : activityParentIds]);
            //Get the Existing Parent Event Records
            for(Event e : [SELECT Riva_Activity_Id__c FROM Event WHERE ParentId__c = null AND Riva_Activity_Id__c IN : activityParentIds])
            {
                rivaToEventMap.put(e.Riva_Activity_Id__c, e);
                eventIds.add(e.Id);
            }
            
            //Get the Existing Supplement Event Records
            for(Activity_Supplement__c s : [SELECT Activity__c, Sync_Description__c FROM Activity_Supplement__c WHERE Activity__c IN : eventIds ])
                eventToSupplementMap.put(s.Activity__c, s);
            
            for(Activity_Link__c al : updatedRecords){
                if(rivaToEventMap.get(al.ActivityId__c) == null){
                    Contact c = (Contact)userToContactMap.get(linkToOwnerIdMap.get(al.ActivityId__c));                  
                    Activity__c a = parentActivitiesMap.get(al.ActivityId__c);
                    if(c != null && a != null){
                        Event e = new Event(Riva_Activity_Id__c = a.Id, Riva_Global_Object_Id__c = a.GlobalObjectId__c, WhoId = c.Id, Primary_Attendee_Id__c = c.Id, Primary_Attendee__c = c.Name, Type = 'Meeting', StartDateTime = a.StartDateTime__c, Start_Date__c = a.StartDateTime__c.Date(), Start_Time__c = a.StartDateTime__c.format('hh:mm a'), EndDateTime = a.EndDateTime__c, End_Date__c = a.EndDateTime__c.Date(), End_Time__c = a.EndDateTime__c.format('hh:mm a'), Subject = a.Subject__c, Description = a.Description__c, Sync_To_Outlook__c = true, OwnerId = a.OwnerId); 
                        if(!String.isBlank(al.ContactId__c))
                        {
                            Contact attendee = (Contact)attendeeToContactMap.get(al.ContactId__c);
                            if(String.isBlank(attendee.User__c)){
                                e.Primary_External_Contact_Id__c = attendee.Id;
                                e.Primary_External_Contact__c = attendee.Name;
                                e.Primary_External_Contact_Company_Id__c = attendee.AccountId;
                                e.Primary_External_Contact_Company__c = attendee.Account.Name;
                            }
                        }
                        eventsToInsert.add(e);
                        rivaToEventMap.put(al.ActivityId__c,e);
                    }
                }
                else
                {
                    Event e = rivaToEventMap.get(al.ActivityId__c);
                    if(!String.isBlank(e.Id) && !parentsToUpdate.contains(e.Id))
                    {
                        parentsToUpdate.add(e.Id);
                        Activity__c a = parentActivitiesMap.get(al.ActivityId__c);
                        Activity_Supplement__c s = eventToSupplementMap.get(e.Id);
                        //Neither of these seem to work when synching back from outlook, so had to use substring
                        //a.Description__c.remove(s.Sync_Description__c);
                        //a.Description__c.replace(s.Sync_Description__c, '')
                        if(a != null){
                            if(!String.isBlank(a.Description__c))
                                e.Description = (a.Description__c.indexOf(HL_Activity.SYNC_DIVIDER) >= 0 ? a.Description__c.substring(0, a.Description__c.indexOf(HL_Activity.SYNC_DIVIDER)) : a.Description__c);
                            else
                                e.Description = '';
                            e.Subject = a.Subject__c;
                            e.StartDateTime = a.StartDateTime__c;
                            e.Start_Date__c = a.StartDateTime__c.Date();
                            e.Start_Time__c = a.StartDateTime__c.format('hh:mm a');
                            e.EndDateTime = a.EndDateTime__c;
                            e.End_Date__c = a.EndDateTime__c.Date();
                            e.End_Time__c = a.EndDateTime__c.format('hh:mm a');
                            eventsToUpdate.add(e);
                        }
                    }
                }
            }
            //Inserts and Updates all of the Parent Event Records
            if(eventsToInsert.size() > 0)
                insert eventsToInsert;
            if(eventsToUpdate.size() > 0)
                update eventsToUpdate;
            
            Map<Id, Event> eventParents = new Map<Id, Event>();
            
            for(Event e : Database.Query(HL_Event.STANDARD_SELECT + 'FROM Event WHERE Riva_Activity_Id__c IN : activityParentIds AND ParentId__c = null')){
                parentEventMap.put(e.Id, e);
                eventParents.put(e.Riva_Activity_Id__c, e);
            }
            
            //Insert/Update Child Records
            SynchronizeChildRecords(activityParentIds, updatedRecords, eventParents, linkToOwnerIdMap, userToContactMap, attendeeToContactMap, parentEventMap);
            //Fix Missing Primary Data
            SynchronizeMissingPrimaryData(activityParentIds, parentEventMap);
            //Trigger Event Sync back to Riva
            TriggerEventSyncBackToRiva(eventParents.values());
        }
    }
    
    
    private void SynchronizeChildRecords(Set<Id> activityParentIds, List<Activity_Link__c> updatedRecords, Map<Id, Event> eventParents, Map<Id,Id> linkToOwnerIdMap, Map<Id, Contact> userToContactMap, Map<Id, Contact> attendeeToContactMap, Map<Id,Event> parentEventMap){
        //Handle all the Children Records
        List<Event> eventsToInsert = new List<Event>();
        List<Event> eventsToUpdate = new List<Event>();
        Map<String, Event> eventChildren = new Map<String, Event>();

        for(Event e : Database.Query(HL_Event.STANDARD_SELECT + 'FROM Event WHERE Riva_Activity_Id__c IN : activityParentIds AND ParentId__c <> null'))
            eventChildren.put(e.Riva_Activity_Id__c + e.WhoId, e);
        
        for(Activity_Link__c al : updatedRecords){
            if(!String.isBlank(al.ContactId__c)){
                Contact c = (Contact)userToContactMap.get(linkToOwnerIdMap.get(al.ActivityId__c));
                Event parent = (Event)eventParents.get(al.ActivityId__c);
                Contact attendee = (Contact)attendeeToContactMap.get(al.ContactId__c);
                if(String.isBlank(attendee.User__c) && String.isBlank(parent.Primary_External_Contact_Id__c))
                {
                    parent.Primary_External_Contact_Id__c = attendee.Id;
                    parent.Primary_External_Contact__c = attendee.Name;
                    parent.Primary_External_Contact_Company_Id__c = attendee.AccountId;
                    parent.Primary_External_Contact_Company__c = attendee.Account.Name;
                    parentEventMap.put(parent.Id, parent);
                    eventsToUpdate.add(parent);
                }
                if(eventChildren.get(al.ActivityId__c + '' + al.ContactId__c) == null && c != null)
                {
                    Event newEvent = new Event(Riva_Activity_Id__c = al.ActivityId__c, Riva_Activity_Link_Id__c = al.Id, WhoId = al.ContactId__c, Primary_Attendee_Id__c = c.Id, Primary_Attendee__c = c.Name, ParentId__c = parent.Id,  StartDateTime = parent.StartDateTime, EndDateTime = parent.EndDateTime, Start_Date__c = parent.Start_Date__c, Start_Time__c = parent.Start_Time__c, End_Date__c = parent.End_Date__c, End_Time__c = parent.End_Time__c, Type = parent.Type, Subject = parent.Subject, Description = parent.Description, OwnerId = parent.CreatedById);
                    if(String.isBlank(attendee.User__c)){
                        newEvent.Primary_External_Contact_Id__c = attendee.Id;
                        newEvent.Primary_External_Contact__c = attendee.Name;
                        newEvent.Primary_External_Contact_Company_Id__c = attendee.AccountId;
                        newEvent.Primary_External_Contact_Company__c = attendee.Account.Name;
                    }
                    eventsToInsert.add(newEvent);
                }
                else{
                    Event child = (Event)eventChildren.get(al.ActivityId__c + '' + al.ContactId__c);
                    if(child != null){
                        child.StartDateTime = parent.StartDateTime;
                        child.EndDateTime = parent.EndDateTime;
                        child.Start_Date__c = parent.Start_Date__c;
                        child.Start_Time__c = parent.Start_Time__c;
                        child.End_Date__c = parent.End_Date__c;
                        child.End_Time__c = parent.End_Time__c;
                        child.Type = parent.Type;
                        child.Subject = parent.Subject;
                        child.Description = parent.Description;
                        eventsToUpdate.add(child);
                    }
                }
            }
        }
        
        //Inserts and Updates all of the Child Event Records
        if(eventsToInsert.size() > 0)
            insert eventsToInsert;
        if(eventsToUpdate.size() > 0)
            update eventsToUpdate;


    }
    
    //Synchronizes the Missing Primary Data for when Link Records are Updated independently/in separate batches
    private void SynchronizeMissingPrimaryData(Set<Id> activityParentIds, Map<Id,Event> parentEventMap){
        List<Event> eventsToUpdate = new List<Event>();
        Map<String, Event> eventChildren = new Map<String, Event>(); 
        
        for(Event e : Database.Query(HL_Event.STANDARD_SELECT + 'FROM Event WHERE Riva_Activity_Id__c IN : activityParentIds AND ParentId__c <> null'))
            eventChildren.put(e.Riva_Activity_Id__c + e.WhoId, e);
        
        for(Event child : eventChildren.values()){
            if(String.isBlank(child.Primary_External_Contact_Id__c) && !String.isBlank(child.ParentId__c))
            {
                Event parent = parentEventMap.get(child.ParentId__c);
                if(parent != null){
                    child.Primary_External_Contact_Id__c = parent.Primary_External_Contact_Id__c;
                    child.Primary_External_Contact__c = parent.Primary_External_Contact__c;
                    child.Primary_External_Contact_Company_Id__c = parent.Primary_External_Contact_Company_Id__c;
                    child.Primary_External_Contact_Company__c = parent.Primary_External_Contact_Company__c;
                    eventsToUpdate.add(child);
                }
            }
        }
        
        if(eventsToUpdate.size() > 0)
            update eventsToUpdate;
    }

    //Triggers the Events to Sync back to Riva
    //This is so that the activity link and attendee block appears back in outlook
    private void TriggerEventSyncBackToRiva(List<Event> eventList){
        for(Event e : eventList)
            e.Riva_Sync_Ready__c = true;

        //Refresh the Sync Description
        HL_ActivitySupplement.RefreshSyncDescription(eventList);
        
        if(eventList.size() > 0)
            update eventList;
    }
    
    //When an Invitee is Removed (Deleted), Remove the Related Native Event Record
    //If it is the Primary External Contact, also clear those respective fields
    public void OnAfterDelete(Map<Id,Activity_Link__c> deletedRecordsMap){
        if(!isAfterDeleteFlag){
            isAfterDeleteFlag = true;
            List<Event> eventsToDelete = new List<Event>();
            List<Event> parentsToUpdate = new List<Event>();
            Map<String, Id> parentToWhoIdMap = new Map<String,Id>();
            for(Event e : [SELECT Id, ParentId__c, WhoId FROM Event WHERE Riva_Activity_Link_Id__c IN : deletedRecordsMap.keySet()]){
                eventsToDelete.add(e);
                parentToWhoIdMap.put(e.ParentId__c, e.WhoId);
            }
            
            //Remove the primary external contact fields if appropriate
            for(Event e : [SELECT Primary_External_Contact__c, Primary_External_Contact_Id__c FROM Event WHERE Id IN : parentToWhoIdMap.keySet()]){
                if(e.Primary_External_Contact_Id__c == parentToWhoIdMap.get(e.Id)){
                    e.Primary_External_Contact_Id__c = null;
                    e.Primary_External_Contact__c = null;
                    parentsToUpdate.add(e);
                }
            }
            
            //Delete the related native child events
            if(eventsToDelete.size() > 0)
                delete eventsToDelete; 
            
            //Update the related native parent events
            if(parentsToUpdate.size() > 0)
                update parentsToUpdate;
        }
    }
}