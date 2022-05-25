public without sharing class HL_EventHandler {
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public boolean IsTriggerContext{get{ return isExecuting;}}
    public static Boolean isAfterInsertFlag = false;
    public static Boolean isAfterDeleteFlag = false;
    
    public HL_EventHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
    }
    
    //Assign the Contact__c reference, this is primarily used in reporting
    //Strip out any html tags from the description
    public void OnBeforeInsert(List<Event> newRecords){
        for(Event e : newRecords){
            if(!String.isBlank(e.ParentId__c) && !String.isBlank(e.WhoId))
                e.Contact__c = e.WhoId;
            //if(!String.isBlank(e.Description))
                //e.Description = e.Description.stripHtmlTags();
        }
    }

    private void UpdateEventRivaIdRecords(List<Activity__c> aList, List<Activity_Link__c> alList){
        Map<Id, Activity__c> aMap = new Map<Id, Activity__c>();
        Map<Id, Activity_Link__c> alMap = new Map<Id, Activity_Link__c>();
        List<Event> eToUpdate = new List<Event>();
        Set<Id> updateIdList = new Set<Id>();
        for(Activity__c a : aList)
            aMap.put(a.Event__c, a);
        for(Activity_Link__c al : alList)
            alMap.put(al.Event__c, al);
       
        for(Event e: [SELECT ParentId__c, Riva_Activity_Id__c, Riva_Activity_Link_Id__c FROM Event WHERE Id IN: alMap.keySet()]){
            e.Riva_Activity_Link_Id__c = alMap.get(e.Id).Id;
            e.Riva_Activity_Id__c = alMap.get(e.Id).ActivityId__c;
            eToUpdate.add(e);
            updateIdList.add(e.Id);
        }
        for(Event e : [SELECT ParentId__c, Riva_Activity_Id__c FROM Event WHERE Id IN: aMap.keySet() OR ParentId__c IN: aMap.keySet()]){
            e.Riva_Activity_Id__c = String.isBlank(e.ParentId__c) ? aMap.get(e.Id).Id : aMap.get(e.ParentId__c).Id;
            if(!updateIdList.contains(e.Id)){
                eToUpdate.add(e);
                updateIdList.add(e.Id);
            }
        }
        if(eToUpdate.size() > 0){
            HL_TriggerContextUtility.setFirstRunFalse();
            update eToUpdate;
        }
    }
    
    public void OnAfterUpdate(List<Event> updatedRecords){
         UpdateRivaActivityObjects(updatedRecords);
    }

    private void UpdateRivaActivityObjects(List<Event> updatedRecords){
        Map<Id,Event> parentEventToActivityMap = new Map<Id,Event>();
        //If no Riva Activity previously made we want to insert method
        List<Activity__c> newRivaParentRecords = new List<Activity__c>();
        Map<Id,Event> eventInserts = new Map<Id,Event>();
        Map<Id, Id> contactToUser = new Map<Id, Id>();
        Map<Id, Id> userToContact = new Map<Id, Id>();
        Set<Id> primaryAttendees = new Set<Id>();
        Set<Id> eventIds = new Set<Id>();
        List<Event> rivaUpdateList = new List<Event>();
        List<Event> eventsToUpdateList = new List<Event>();
        Map<Id, String> supplementMap = new Map<Id, String>();

        for(Event e : updatedRecords){
            if(e.Riva_Sync_Ready__c){
                eventIds.add(e.Id);
                eventsToUpdateList.add(new Event(Id = e.Id, Riva_Sync_Ready__c = false));
                rivaUpdateList.add(e);
            }
        }

        for(Activity_Supplement__c s : [SELECT Activity__c, Sync_Description__c FROM Activity_Supplement__c WHERE Activity__c IN : eventIds])
            supplementMap.put(s.Activity__c, s.Sync_Description__c);

        for(Event e : rivaUpdateList){
            if(!String.isBlank(e.Riva_Activity_Id__c))
                parentEventToActivityMap.put(e.Riva_Activity_Id__c, e);
            else if(String.isBlank(e.ParentId__c))
                eventInserts.put(e.Id,e);

            if(!String.isBlank(e.Primary_Attendee_Id__c))
                primaryAttendees.add(e.Primary_Attendee_Id__c);
         }
        
        if(primaryAttendees.size() > 0){
            for(Contact c : [SELECT User__c FROM Contact WHERE Id IN: primaryAttendees]){
                contactToUser.put(c.Id, c.User__c);
                userToContact.put(c.User__c, c.Id);
            }
        }

        if(parentEventToActivityMap.size() > 0){
            //Get Riva Activities
            List<Activity__c> aToUpdate = new List<Activity__c>();
            for(Activity__c a : [SELECT Description__c, EndDateTime__c, Event__c, StartDateTime__c, Subject__c, OwnerId FROM Activity__c WHERE Id IN : parentEventToActivityMap.keySet()]){
                Event e = parentEventToActivityMap.get(a.Id);
                string syncDescription = supplementMap.get(e.Id);
                a.Subject__c = e.Subject;
                a.Description__c = String.isBlank(syncDescription) ? e.Description : e.Description + HL_Activity.SYNC_SPACING + syncDescription;
                a.StartDateTime__c = e.StartDateTime;
                a.EndDateTime__c = e.EndDateTime;
                if(e.Primary_Attendee_Id__c != userToContact.get(a.OwnerId))
                    a.OwnerId = contactToUser.get(e.Primary_Attendee_Id__c);
                aToUpdate.add(a);
            }
            
            if(aToUpdate.size() > 0)
                update aToUpdate;
        }
        
        if(eventInserts.size() > 0){
            for(Activity__c a : [SELECT Event__c FROM Activity__c WHERE Event__c IN : eventInserts.keySet()])
                eventInserts.remove(a.Event__c);
            
            for(Event e : eventInserts.values()){
                String description = supplementMap.get(e.Id);

                if(!String.isBlank(e.Description))
                    description = e.Description + HL_Activity.SYNC_SPACING + description;

                newRivaParentRecords.add(new Activity__c(StartDateTime__c = e.StartDateTime, EndDateTime__c = e.EndDateTime, Subject__c = e.Subject, Description__c = description, SyncToOutlook__c = true, Event__c = e.Id, OwnerId = contactToUser.get(e.Primary_Attendee_Id__c)));
            }
            
            if(newRivaParentRecords.size() > 0)
                insert newRivaParentRecords;
        }

        if(eventsToUpdateList.size() > 0){
            List<Activity_Link__c> activityLinkList = InsertRivaChildRecords(eventsToUpdateList);
            update eventsToUpdateList;
            UpdateEventRivaIdRecords(newRivaParentRecords, activityLinkList);
        }
    }

    private List<Activity_Link__c> InsertRivaChildRecords(List<Event> newRecords){
        List<Activity_Link__c> newRivaLinkRecords = new List<Activity_Link__c>();
        Map<Event,Id> internalEventToWhoIdMap = new Map<Event,Id>();
        Map<Event,Id> externalEventToWhoIdMap = new Map<Event, Id>();
        Set<Id> origParentEventIdSet = new Set<Id>();
        Set<Id> parentEventIdSet = new Set<Id>();
        
        for(Event e : newRecords)
           origParentEventIdSet.add(e.Id);

        //Get Child Events Not In Riva
        for(Event e : [SELECT Contact_Record_Type__c, Contact_Name__c, Contact_Email__c, Contact_User_Id__c, Mask_As_External__c, ParentId__c, Riva_Activity_Id__c, WhoId FROM Event WHERE ParentId__c IN: origParentEventIdSet]){
            if(String.isBlank(e.Riva_Activity_Id__c) && !String.isBlank(e.ParentId__c) && !String.isBlank(e.WhoId)){  
                    //Add to Child Events Map
                    if(e.Mask_As_External__c == false && e.Contact_Record_Type__c == 'Houlihan_Employee')
                        internalEventToWhoIdMap.put(e, e.WhoId);
                    else   
                        externalEventToWhoIdMap.put(e, e.WhoId);

                    parentEventIdSet.add(e.ParentId__c);
            }
        }

        if(internalEventToWhoIdMap.size() > 0)
        {
            //Get Contacts To Map
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Name, Email, User__c FROM Contact WHERE Id IN : internalEventToWhoIdMap.values()]);
            
            //Get Parent Native Events
            List<Event> eList = [SELECT Riva_Activity_Id__c FROM Event WHERE Id IN: parentEventIdSet];
            //Set<Id> parentRivaIds = new Set<Id>();
            Map<Id, Id> activityToEventMap = new Map<Id,Id>();
            Map<Id, Id> eventToActivityMap = new Map<Id,Id>();
            //Existing Riva Synched Events that were modified
            for(Event e : eList)
                eventToActivityMap.put(e.Id, e.Riva_Activity_Id__c);
            //New Riva Synched Events
            for(Activity__c a : [SELECT Event__c FROM Activity__c WHERE Event__c IN : parentEventIdSet])
                    activityToEventMap.put(a.Event__c, a.Id);
            
            for(Event e : internalEventToWhoIdMap.keySet()){
                Contact c = contactMap.get(e.WhoId);
                Activity_Link__c al = new Activity_Link__c(ActivityId__c = (String.isBlank(eventToActivityMap.get(e.ParentId__c)) ? activityToEventMap.get(e.ParentId__c) :  eventToActivityMap.get(e.ParentId__c)), Event__c = e.Id, ContactId__c = c.Id, DisplayName__c = c.Name, Email__c = c.Email, IsInvitee__c = true);
                if(!String.isBlank(al.ActivityId__c))
                    newRivaLinkRecords.add(al);
            }
            
            if(newRivaLinkRecords.size() > 0)
                insert newRivaLinkRecords;
        }
        return newRivaLinkRecords;
     }
    
    public void OnAfterDelete(Map<Id,Event> deletedRecordsMap){
        DeleteRivaActivityObjects(deletedRecordsMap);
    }

    private void DeleteRivaActivityObjects(Map<Id, Event> deletedRecordsMap){
        List<Activity_Link__c> activityLinksToDelete = new List<Activity_Link__c>();
        List<Activity__c> activityToDelete = new List<Activity__c>();
        Set<Id> eventDeleteSet = new Set<Id>();
        Set<Id> rivaActivityLinkSet = new Set<Id>();

        for(Event e : deletedRecordsMap.values()){
            if(String.isBlank(e.ParentId__c))
                eventDeleteSet.add(e.Id);  
        }

        //Get Deletions that were just removal of an attendee
        for(Event e : deletedRecordsMap.values()){
            if(!String.isBlank(e.ParentId__c) 
                && !String.isBlank(e.WhoId)
                && !eventDeleteSet.contains(e.ParentId__c)
                && !String.isBlank(e.Riva_Activity_Link_Id__c))
                rivaActivityLinkSet.add(e.Riva_Activity_Link_Id__c);
        }

        //If the whole event was deleted
        if(eventDeleteSet.size() > 0){
            for(Activity__c a : [SELECT Id FROM Activity__c WHERE Event__c IN : eventDeleteSet])
                activityToDelete.add(a);
            
            //Update the related native parent events
            if(activityToDelete.size() > 0)
                delete activityToDelete;
        }

        if(rivaActivityLinkSet.size() > 0){
           for(Activity_Link__c al : [SELECT Id FROM Activity_Link__c WHERE Id IN: rivaActivityLinkSet])
                activityLinksToDelete.add(al);

             //Delete the related native child events
            if(activityLinksToDelete.size() > 0)
                delete activityLinksToDelete; 
        }

    }
}