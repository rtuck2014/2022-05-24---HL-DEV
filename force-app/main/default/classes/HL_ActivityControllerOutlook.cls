public without sharing class HL_ActivityControllerOutlook extends HL_ActivityControllerBase {    
    public String eventsId {get{
        Id mySql = ApexPages.currentPage().getParameters().get('id');
        if(eventsId == null)
            if(mySql != null){
                eventsId = [select id,Type 
                            From Event 
                            WHERE id =: mySql].Type;
            }
        return eventsId;
    }set;
                           }
    public string activityId;
    public Id DelId {get; set;}
    public String FormattedStart {get{
        return Activity.StartDateTime.format();
        
    }
                                 }
    
    public String FormattedStartDate {get{
        return Activity.StartDateTime == null? '': Activity.StartDateTime.format('hh:mm a');
    }
                                     }
    
    public String FormattedEnd {get{
        return Activity.EndDateTime.format(); 
        
    }
                               }
    
    public String FormattedEndDate {get{
        return Activity.EndDateTime == null? '': Activity.EndDateTime.format('hh:mm a');
    }
                                   }
    
    public Enum RelatedEventType {
        External, Internal, Company, Opportunity, Engagement, Campaigns
            }
    public Activity_Supplement__c ActivitySupplement {get{
        if (activitySupplement == null) {
            //if (!String.isBlank(Activity.Id)) {
            if (!String.isBlank(EntityId)) {
                List<Activity_Supplement__c> asList = [SELECT Activity__c, Internal_Notes__c, Sync_Description__c
                                                       FROM Activity_Supplement__c
                                                       WHERE Activity__c = : EntityId];
                
                activitySupplement = asList.size() > 0 ? asList[0] : new Activity_Supplement__c();
            }
            else
                activitySupplement = new Activity_Supplement__c();
        }
        
        return activitySupplement;
    } set;
                                                     }
    
    public Event Activity {get{
        if (activity == null)
            activity = new Event();
        return activity;
    } set;
                          }
    
    public String WhoId {get; set;}
    public String WhatId {get; set;}
    public String SelectedAccountId {get; set;}
    public String SelectedAccountName {get; set;}
    public String SelectedEmployeeId {get; set;}
    public String SelectedEmployeeName {get; set;}
    public String SelectedOpportunityId {get; set;}
    public String SelectedOpportunityName {get; set;}
    public String SelectedEngagementId {get; set;}
    public String SelectedEngagementName {get; set;}
    public String SelectedContactId {get; set;}
    public String SelectedContactName {get; set;}
    //public String SelectedCampaignId {get; set;}
    //public String SelectedCampaignName {get; set;}        
    public Boolean HasViewAccess {get{
        //Non-Private Activities: Other Attendees Should Have Edit/Modify Access
        //Private Activities: Other Attendees Can View, but not Edit
        Id userId = UserInfo.getUserId();
        Contact c = HL_Contact.GetByUserId(userId);
        Boolean tempViewAccess = HasModifyAccess || HasLimitedModifyAccess || InternalWhoRelations.contains(UserContactRecord.Id) || (Activity.Pfg__c && c.Industry_Group__C == 'PFG - Private Funds Group');
        if(Activity.type == 'Meeting')
        {
            //Get a Map of Event Id with HL Attendees
            Set<Id> attendeeSet = new Set<Id>();
            Set<Id> menteeSet = new Set<Id>();
            
            for(Event e : [SELECT ParentId__c, WhoId, Mask_As_External__c FROM Event WHERE ParentId__c =: Activity.Id AND WhoID <> null]){
                if(!e.Mask_As_External__c)
                { 
                    attendeeSet.add(e.WhoId);
                }
                else
                {
                    menteeSet.add(e.WhoId);
                }
            }
            
            tempViewAccess = hasModifyAccess || menteeSet.contains(UserContactRecord.id) || InternalWhoRelations.contains(UserContactRecord.Id) || attendeeSet.contains(UserContactRecord.id) || HL_Group.IsInGroup('Mentor_Activity_Access');
        }
        return tempViewAccess ;
    } set;
                                 }
    public Boolean HasLimitedModifyAccess {
        get{
            return !Activity.Private__c && InternalWhoRelations.contains(UserContactRecord.Id);
        }
        set;
    }      
    public Boolean HasModifyAccess {get{
        if (hasModifyAccess == null) {
            if (!String.isEmpty(Activity.Id)) {
                Id userId = UserInfo.getUserId();
                Contact c = HL_Contact.GetById(Activity.Primary_Attendee_Id__c);
                //Non-Private Activities: Other Attendees Should Have Edit/Modify Access
                //Private Activities: Other Attendees Can View, but not Edit
                hasModifyAccess = (Supervisors.contains(UserContactRecord.Id) || InternalWhoRelations.contains(UserContactRecord.Id) || userId == Activity.Contact_User_Id__c || userId == Activity.CreatedById || Activity.Primary_Attendee_Id__c == UserContactRecord.Id || Supervisors.contains(c.User__c));
                
                if(!hasModifyAccess && Activity.Type == 'Internal' && HasInternalSupervisorAccess){
                    Schema.RecordTypeInfo internalRecordTypeInfo = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Internal ' + UserContactRecord.Line_of_Business__c);
                    if(internalRecordTypeInfo != null)
                        hasModifyAccess = Activity.RecordTypeId == internalRecordTypeInfo.getRecordTypeId();
                }  
                if(Activity.type == 'Meeting' || Activity.type == 'Email' || Activity.type == 'Other' || Activity.type == 'Call'|| Activity.type == 'Platinum')
                {
                    //Get a Map of Event Id with HL Attendees
                    Set<Id> attendeeSet = new Set<Id>();
                    Set<Id> menteeSet = new Set<Id>();
                    Set<Id> hlEmpSet = new Set<Id>();                    
                    for(Event e : [SELECT ParentId__c, WhoId, Mask_As_External__c,Who.RecordType.DeveloperName,Contact__r.User__c FROM Event WHERE ParentId__c =: Activity.Id AND WhoID <> null AND Mask_As_External__c = false])
                    { 
                        attendeeSet.add(e.WhoId);
                        if(e.Who.RecordType.DeveloperName=='Houlihan_Employee'){
                            hlEmpSet.add(e.Contact__r.User__c);
                        }
                    }
                    //hasModifyAccess = attendeeSet.contains(UserContactRecord.id) || userId == Activity.CreatedById || Activity.Primary_Attendee_Id__c == UserContactRecord.Id || hasMentorActivityAccess ;
                    Id currentUserId = UserInfo.getUserId();
                    for(Delegate_Public_Group_Member__c member : [SELECT Id,Delegate__c FROM Delegate_Public_Group_Member__c WHERE Delegate_Public_Group__r.Banker__c in :hlEmpSet AND Active__c=true]){
                        if(currentUserId==member.Delegate__c){
                            hasModifyAccess=true;
                            break;
                        }
                    }
                        
                    /*for(Id empId : hlEmpSet){
                        if(InternalWhoRelations.contains(empId)){
                            hasModifyAccess=true;
                            break;
                        }
                    }*/
                    if(!hasModifyAccess){
                        hasModifyAccess = (Supervisors.contains(UserContactRecord.Id) || Supervisors.contains(c.User__c) || InternalWhoRelations.contains(UserContactRecord.Id)|| attendeeSet.contains(UserContactRecord.id) || (attendeeSet.contains(UserContactRecord.id) && HL_Group.IsInGroup('Mentor_Activity_Access')));
                    }
                }
            }
            else
                hasModifyAccess = true;
        }
        return hasModifyAccess;
    } set;
                                   } 
    
    public List<Event> ExistingRelatedEvents {get{
        if (existingRelatedEvents == null) {
            Id activityId = Activity.Id;
            String relatedEventQuery = HL_Event.STANDARD_SELECT + ' FROM Event WHERE ParentId__c =: activityId';
            existingRelatedEvents = Database.query(relatedEventQuery);
        }
        return existingRelatedEvents;
    } set;
                                             }
    /*
public List<Account> RelatedCompanies {get{
if (relatedCompanies == null)
relatedCompanies = [SELECT Name, BillingCity, BillingState, BillingCountry
FROM Account
WHERE Id IN : EventWhatRelations
ORDER BY Name];
return relatedCompanies;
} set;
}

*/
    
    //Vikas CompanyActivity changes from line 166 to 185
    public List<Account> RelatedCompanies {get{
        if (relatedCompanies == null){
            relatedCompanies = [SELECT Name, BillingCity, BillingState, BillingCountry
                                FROM Account
                                WHERE Id IN : EventWhatRelations
                                ORDER BY Name];
            if((relatedCompanies == null || relatedCompanies.size() == 0) && HL_Utility.GetObjectTypeById(WhatId) == 'Account'){
                relatedCompanies = [SELECT Name, BillingCity, BillingState, BillingCountry
                                    FROM Account
                                    WHERE Id = :WhatId
                                    ORDER BY Name];
            }
        }
        return relatedCompanies;
    } set;
                                          }
    
    // Vikas 
    
    
    //Internal Contact Attendees
    public List<SelectedEmployee> HLEmployees {get{
        if (hlEmployees == null) {
            List<Contact> cList = [SELECT Name, User__c, Title, Email, Office__c, Line_Of_Business__c, Phone, MobilePhone
                                   FROM Contact
                                   WHERE Id IN: internalWhoRelations
                                   ORDER BY Name];
            hlEmployees = new List<SelectedEmployee>();
            if (cList.size() == 0) {
                Contact c = HL_Contact.GetByUserId(UserInfo.getUserId());
                if (c <> null) {
                    cList.Add(c);
                    Activity.Primary_Attendee_Id__c = cList[0].Id;
                }
            }
            for (Contact c : cList)
                hlEmployees.Add(New SelectedEmployee(c, Activity.Primary_Attendee_Id__c == c.Id));
            
        }
        return hlEmployees;
    } set;
                                              }
    
    private SelectedEmployee PrimaryAttendee {
        get{
            for (SelectedEmployee se : HLEmployees) {
                if (se.Primary)
                    return se;
            }
            
            return null;
        }
    }
    private SelectedContact PrimaryContact {
        get{
            SelectedContact selectedContact;
            for (SelectedContact sc : RelatedContacts) {
                if (sc.Primary) {
                    selectedContact = sc;
                    break;                    
                }
            }
            return selectedContact;
        }
    }
    
    public List<Opportunity__c> RelatedOpportunities {get{
        if (relatedOpportunities == null)
            relatedOpportunities = [SELECT Name, Client__r.Name, Subject__r.Name, Job_Type__c, Line_of_Business__c, Industry_Group__c, Stage__c
                                    FROM Opportunity__c
                                    WHERE Id IN : EventWhatRelations
                                    ORDER BY Name];
        
        return relatedOpportunities;
    } set;

        }

    public List<Engagement__c> RelatedEngagements {get{
    if (relatedEngagements == null)
        relatedEngagements = [SELECT Name, Client__r.Name, Subject__r.Name, Job_Type__c, Line_of_Business__c, Industry_Group__c, Stage__c
                                FROM Engagement__c
                                WHERE Id IN : EventWhatRelations
                                ORDER BY Name];
    
    return relatedEngagements;
} set;
        }
    
    //public List<Campaign> RelatedCampaigns {get{
        //if (relatedCampaigns == null)
            //relatedCampaigns = [SELECT Name,recordtype.name,Type FROM Campaign
                               // WHERE Id IN : EventWhatRelations
                              //  ORDER BY Name];
        //return relatedCampaigns;
   // } set;
                                           //}
    
    //External Contacts (Or Internal Contacts Masked as External)
    public List<SelectedContact> RelatedContacts {get{
        if (relatedContacts == null) {
            List<Contact> cList = [SELECT Name, Account.Id, Account.Name, Title, Email, Office__c, Line_Of_Business__c, Phone, MobilePhone, RecordType.DeveloperName
                                   FROM Contact
                                   WHERE Id IN : ExternalWhoRelations
                                   ORDER BY Name];                                       
            relatedContacts = new List<SelectedContact>();
            if (cList.size() == 0 && !string.isBlank(WhoId) && Activity.Type != 'Internal') {
                Contact c = HL_Contact.GetById(WhoId);
                if (c != null) {
                    if (c.RecordType.DeveloperName == 'EXTERNAL_CONTACT' || (c.RecordType.DeveloperName == 'HOULIHAN_EMPLOYEE' && (HasInternalAccess|| hasMentorActivityAccess))) {
                        cList.Add(c);
                        Activity.Primary_External_Contact_Id__c = c.Id;
                        Activity.Primary_External_Contact_Company_Id__c = c.Account.Id;
                        if (c.RecordType.DeveloperName == 'HOULIHAN_EMPLOYEE' && String.isBlank(Activity.Type) && HasInternalAccess)
                            Activity.Type = 'Internal';
                        else if (c.RecordType.DeveloperName == 'HOULIHAN_EMPLOYEE' && String.isBlank(Activity.Type) && hasMentorActivityAccess)
                            Activity.Type = 'Internal Mentor Meeting';
                    }
                }
            }
            for (Contact c : cList)
                relatedContacts.add(new SelectedContact(c,  Activity.Primary_External_Contact_Id__c == c.Id));
        }
        return relatedContacts;
    } set;
                                                 }
    
    //List of Contact Records from the Related Contacts
    private List<Contact> RelatedContactsContactList {get{
        List<Contact> cList = new List<Contact>();
        
        for (SelectedContact sc : RelatedContacts)
            cList.Add(sc.Contact);
        
        return cList;
    }
                                                     }
    
    public Set<Id> EventWhatRelations {get{
        if (eventWhatRelations == null)
            eventWhatRelations = new Set<Id>(GetWhatRelations(EntityId));
        return eventWhatRelations;
    }
                                       set;
                                      }
    
    public Set<Id> InternalWhoRelations {get{
        if (internalWhoRelations == null)
            internalWhoRelations = new Set<Id>(GetWhoInternalRelations(EntityId));
        return internalWhoRelations;
    }
                                         set;
                                        }
    
    public Set<Id> ExternalWhoRelations {get{
        if (externalWhoRelations == null)
            externalWhoRelations = new Set<Id>(GetWhoExternalRelations(EntityId));
        return externalWhoRelations;
    }
                                         set;
                                        }
    
    
    public HL_ActivityControllerOutlook() {
        if (ApexPages.currentPage() != null)
            EntityId = HL_PageUtility.GetParameter('id');
    }
    
    public HL_ActivityControllerOutlook(ApexPages.StandardController controller) {
        EntityId = HL_PageUtility.GetParameter('id');
        
        List<Event> eList = new List<Event>([SELECT Id, ParentId__c FROM Event WHERE Id=:EntityId]);
        if(!elist.isEmpty()){
            if(String.isNotBlank(eList.get(0).ParentId__c)){
                EntityId=eList.get(0).ParentId__c;
            }
        }
        if (EntityType != 'Account' && EntityType != 'Contact'){
            List<String> fieldsToAdd = new List<String>{'Primary_External_Contact_Company_Id__c','Primary_External_Contact_Company__c','PFG__c','ParentId__c','isFollowUp__c','End_Time__c','Start_Time__c','Start_Date__c','End_Date__c','Private__c','Is_Complete__c','Subject__c'};
            if(!Test.isRunningTest()){
                controller.addFields(fieldsToAdd);
            }
            Activity = (Event)controller.getRecord();
        }
        WhoId = HL_PageUtility.GetParameter('who_id');
        WhatId = HL_PageUtility.GetParameter('what_id');
        Id relatedId = HL_PageUtility.GetParameter('related_id');
        if (!String.isBlank(relatedId)) {
            if (HL_Utility.GetObjectTypeById(relatedId) == 'Account')
                WhatId = relatedId;
            else
                WhoId = relatedId;
        }
    }
    
    private void UpsertParentActivity() {
        //Custom Setting to Assign the Default Owner to all Instances except for the HL Employee Event Children
        Default_Owner__c mc = Default_Owner__c.getOrgDefaults();        
        //Get the Primary HL Contact and Assign to the Activity Record
        SelectedEmployee primary = PrimaryAttendee;
        //Get the Primary External Contact and Assign to the Activity Record
        SelectedContact pc = PrimaryContact;
        //Assign the Record Type based on the Type
        if (Activity.Type == 'Internal' || Activity.Type == 'Internal Mentor Meeting' || Activity.Type == 'Follow-up Internal'){       
            Activity.Private__c = true;
            try{
                Activity.RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Internal ' + PrimaryAttendee.Employee.Line_of_Business__c).getRecordTypeId();
            }
            catch(Exception ex){
                HL_PageUtility.ShowError('Invalid Primary Attendee Selected for Internal Activity, Record Type has not been Setup: ' + PrimaryAttendee.Employee.Line_of_Business__c);
                throw ex;
            }
        }
        
        
        //Format the date/time fields
        Activity.StartDateTime = HL_DateUtility.FormatDateTime(Activity.Start_Date__c, Activity.Start_Time__c);
        Activity.EndDateTime = HL_DateUtility.FormatDateTime(Activity.Start_Date__c, Activity.End_Time__c);
        
        //Assign the Primary HL and Contact Attendee Fields
        if(primary != null && primary.Employee != null){
            Activity.Primary_Attendee_Id__c = primary.Employee.Id;
            Activity.Primary_Attendee__c = primary.Employee.Name;
            Activity.WhoId = primary.Employee.Id;
        }
        if(pc != null && pc.Contact != null){
            Activity.Primary_External_Contact_Id__c = pc.Contact.Id;
            Activity.Primary_External_Contact__c = pc.Contact.Name;
            Activity.Primary_External_Contact_Company_Id__c = pc.Contact.Account.Id;
            Activity.Primary_External_Contact_Company__c = pc.Contact.Account.Name;
        }
        Activity.OwnerId = mc.Id__c;
        
        upsert Activity;
        Activity.ParentId__c = Activity.Id;
        activityId= Activity.id;        
    }
    
    private Boolean ValidateActivity() {
        Boolean isValid = true;
        
        if (Apexpages.currentPage() != null) {
            //There needs to be both a primary HL Contact and a Primary External Contact or If "No Primary External Contact" to mention then Companies Discussed is required 
            if ((PrimaryAttendee == null || PrimaryContact == null) && !Activity.No_External_Contact__c) {
                isValid = false;
                HL_PageUtility.ShowError('Please mark the "No External Contact" checkbox if you wish not to include an primary external attendee on this activity');
            }
            else if (Activity.No_External_Contact__c && (PrimaryContact != null)) {
                isValid = false;
                HL_PageUtility.ShowError('Please either remove external attendee or uncheck the No External Contact checkbox');
            } 
            else if (Activity.No_External_Contact__c && (RelatedCompanies == null || RelatedCompanies.size() < 1)) {
                isValid = false;
                HL_PageUtility.ShowError('If no external attendee is entered, then Companies Discussed is required to create an activity');
            } 
            else  if (String.isBlank(Activity.Subject)) {
                isValid = false;
                HL_PageUtility.ShowError('Subject Required');
            }
            else if (Activity.Start_Date__c == null || String.isBlank(Activity.Start_Time__c) || String.IsBlank(Activity.End_Time__c)) {
                isValid = false;
                HL_PageUtility.ShowError('Date, Start and End Time are Required');
            }
            else if (Activity.isFollowUp__c) {
                if (Activity.Followup_Start_Date__c == null || String.IsBlank(Activity.Followup_Start_Time__c) || String.IsBlank(Activity.Followup_End_Time__c)) {
                    isValid = false;
                    HL_PageUtility.ShowError('Follow-up Date and Time are Required');
                }
                if (String.isBlank(Activity.Followup_Type__c)) {
                    isValid = false;
                    HL_PageUtility.ShowError('Follow-up Type is Required');
                }
            }
        }
        
        //!ApexPages.hasMessages(ApexPages.Severity.Error) - this won't work for mobile
        return isValid;
    }
    
    //Assign specific fields from the parent to the child event
    private Event SynchronizeParentData(Event e) {
        e.Type = Activity.Type;
        e.Subject = Activity.Subject;
        e.Description = Activity.Description;
        e.StartDateTime = Activity.StartDateTime;
        e.EndDateTime = Activity.EndDateTime;
        e.Primary_Attendee_Id__c = Activity.Primary_Attendee_Id__c;
        e.Primary_Attendee__c = Activity.Primary_Attendee__c;
        e.Primary_External_Contact_Id__c = Activity.Primary_External_Contact_Id__c;
        e.Primary_External_Contact__c = Activity.Primary_External_Contact__c;
        e.Primary_External_Contact_Company_Id__c = Activity.Primary_External_Contact_Company_Id__c;
        e.Primary_External_Contact_Company__c = Activity.Primary_External_Contact_Company__c;
        e.Private__c = Activity.Private__c;
        e.OwnerId = Activity.OwnerId;
        e.Is_Complete__c = Activity.Is_Complete__c;
        return e;
    }
    
    private Event GetExistingEvent(Id relatedId) {
        Event existingEvent = null;
        
        for (Event e : ExistingRelatedEvents) {
            if (e.WhoId == relatedId || e.WhatId == relatedId) {
                existingEvent = e;
                break;
            }
        }
        return existingEvent;
    }
    
    private RelatedEventType GetRelatedEventType(Object o) {
        if (o instanceof Account)
            return RelatedEventType.Company;
        if (o instanceof Opportunity__c)
            return RelatedEventType.Opportunity;
        if (o instanceof Engagement__c)
            return RelatedEventType.Engagement;
        //if (o instanceof Campaign)
            //return RelatedEventType.Campaigns;
        if (o instanceof SelectedEmployee)
            return RelatedEventType.Internal;
        
        return RelatedEventType.External;
    }
    private List<Event> AddRecordToInsert(List<Event> insertList, Object o, Id id) {
        //Clone the Parent Event
        Event e = Activity.clone();
        RelatedEventType eventType = GetRelatedEventType(o);
        
        if (eventType == RelatedEventType.Company || eventType == RelatedEventType.Opportunity || eventType == RelatedEventType.Engagement) {
            e.WhatId = id;
            e.WhoId = null;
        }
        else {
            e.WhatId = null;
            
            if (eventType == RelatedEventType.Internal) {
                SelectedEmployee c = (SelectedEmployee)o;
                e.WhoId = c.Employee.Id;
                system.debug('c>>>'+c.Employee.User__c);
                e.OwnerId = c.Employee.User__c;
                System.debug('--------------------------------------Owner Id ----------------------------------------' + e.OwnerId+'-------'+c);
            }
            else {
                SelectedContact c = (SelectedContact)o;
                e.WhoId = c.Contact.Id;
                //For Internal Events these are Internal Contacts, so we want to flag them
                if (e.Type == 'Internal' || e.Type == 'Follow-up Internal' || e.Type == 'Internal Mentor Meeting')
                    e.Mask_As_External__c = true;
            }
        }
        insertList.add(e);
        return insertList;
    }
    
    private Map<Id, Object> GetRelatedEventMap() {
        Map<Id, Object> relatedEventMap = new Map<Id, Object>();
        
        for (Account a : RelatedCompanies)
            relatedEventMap.put(a.Id, a);
        
        for (Opportunity__c o : RelatedOpportunities)
            relatedEventMap.put(o.Id, o);

        for (Engagement__c eng : RelatedEngagements)
            relatedEventMap.put(eng.Id, eng);
        
        /*for (Campaign cp : RelatedCampaigns)
            relatedEventMap.put(cp.Id, cp);*/
        
        for (SelectedEmployee c : HLEmployees){
            relatedEventMap.put(c.Employee.Id, c);
        }
        
        for (SelectedContact c : RelatedContacts)
            relatedEventMap.put(c.Contact.Id, c);
        
        return relatedEventMap;
    }
    
    private void PrepareChildFollowupRecords(List<Event> childList) {
        RelatedEventFollowupDML(childList);
    }
    
    private void DeleteRemovedChildEvents(Map<Id, Object> relatedEventMap) {
        List<Event> deleteList = new List<Event>();
        for (Event e : ExistingRelatedEvents) {
            Id key = String.isBlank(e.WhoId) ? e.WhatId : e.WhoId;
            if (relatedEventMap.get(key) == null)
                deleteList.add(e);
        }
        
        if (deleteList.size() > 0)
            delete deleteList;
    }
    
    public void SaveActivity() {
        //There needs to be both a primary HL Contact and a Primary External Contact
        if (ValidateActivity()) {
            List<Event> eventInsertList = new List<Event>();
            List<Event> eventUpdateList = new List<Event>();
            Map<Id, Object> relatedEventMap = GetRelatedEventMap();
            Event followup;
            try {             
                UpsertParentActivity(); 
                if (Activity.isFollowUp__c) {
                    followup = CreateFollowup(Activity.clone());
                    insert followup;
                    Activity.Followup_Parent__c = followup.Id;
                }
                
                for (Id id : relatedEventMap.keySet()) {
                    Event existingRelated = GetExistingEvent(id);
                    if (existingRelated == null) {
                        eventInsertList = AddRecordToInsert(eventInsertList, relatedEventMap.get(id), id);
                    }
                    else {
                        existingRelated = SynchronizeParentData(existingRelated);
                        eventUpdateList.add(existingRelated);
                    }
                }
                
                if (eventInsertList.size() > 0)
                    insert eventInsertList ;
                
                if (eventUpdateList.size() > 0)
                    update eventUpdateList;
                
                //Remove any child events that were deleted
                DeleteRemovedChildEvents(relatedEventMap);
                
                if (Activity.isFollowUp__c && (eventInsertList.size() > 0 || eventUpdateList.size() > 0)) {
                    List<Event> childList = eventInsertList.clone();
                    childList.addAll(eventUpdateList);
                    PrepareChildFollowupRecords(childList);
                }
                
                if (String.isBlank(ActivitySupplement.Activity__c)) {
                    ActivitySupplement.Activity__c = Activity.Id;
                    ActivitySupplement.Sync_Description__c = GenerateSyncDescription(Activity.Id);
                    insert ActivitySupplement;
                }
                else {
                    ActivitySupplement.Sync_Description__c = GenerateSyncDescription(Activity.Id);
                    update ActivitySupplement;
                }
                
                eventUpdateList.clear();              
                if (Activity.isFollowUp__c) {
                    insert new Activity_Supplement__c(Activity__c = followup.Id,
                                                      Sync_Description__c = GenerateSyncDescription(followup.Id));
                    if (followup.Sync_To_Outlook__c) {
                        followup.Riva_Sync_Ready__c = true;
                        eventUpdateList.add(followup);
                    }
                }
                
                Activity = ClearFollowupFields(Activity);
                Activity.ParentId__c = null;
                if (Activity.Sync_To_Outlook__c)
                    Activity.Riva_Sync_Ready__c = true;
                
                eventUpdateList.add(Activity);
                update eventUpdateList;              
            }
            catch (DmlException ex) {
                if (ApexPages.currentPage() != null)
                    ApexPages.addMessages(ex);
                else
                    System.Debug(ex);
                throw ex;                    
                
            }          
        }
    }
    
    private String GenerateSyncDescription(Id eventId) {
        return new HL_ActivitySupplement(new Event(Id = eventId), RelatedContactsContactList).ActivitySupplement.Sync_Description__c;
    }
    
    private void RelatedEventFollowupDML(List<Event> eList) {
        List<Event> followupList = new List<Event>();
        for (Event e : eList) {
            Event followup = Activity.clone();
            followup.WhoId = e.WhoId;
            followup.WhatId = e.WhatId;
            followup.Mask_As_External__c = e.Mask_As_External__c;
            followupList.add(CreateFollowup(followup));
        }
        
        if (followupList.size() > 0)
            insert followupList;
    }
    
    public PageReference SaveRecord() {        
        PageReference pageResult = ApexPages.currentPage();
        SaveActivity();
        if (!ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
            Event event = [Select Id,WhoId From Event Where id =:activityId];
            if(event != null){
                WhoId = event.WhoId;  
            }
            if (HL_PageUtility.GetParameter('retURL') != null || WhoId == null){
                pageResult = CancelRecord();
            }
            else
                pageResult = new PageReference('/' + WhoId);
        }
        return pageResult;
    }
    
    public PageReference saveRec() { 
        try{
            PageReference result;
            string url;        
            PageReference pf = ApexPages.currentPage(); 
            if ((activity.Type=='Internal Mentor Meeting') && RelatedContacts.size()> 0 && hlEmployees.size() > 0){   
                If (RelatedContacts[0].Contact.Id == hlEmployees[0].Employee.Id)
                {   
                    HL_PageUtility.ShowError(System.Label.SFMenteeError);
                    return null;
                }
            }         
            SaveActivity();
            if (!ApexPages.hasMessages(ApexPages.Severity.ERROR)) {          
                System.debug('save successful');
                url = '/apex/HL_ActivityEventViewOutlook?id=' + activityId;
                if (String.isNotBlank(HL_PageUtility.GetParameter('retURL')))
                    url = url + '&retURL=' + HL_PageUtility.GetParameter('retURL');
                result = new PageReference(url);
                result.setRedirect(true);
                System.debug('save successful url:'+url);
            }  
            return result;
        }
        catch (Exception e){
            System.debug('error in HL_ActivityControllerOutlook:'+e.getMessage());
            return null;
        }
        
    } 
    
    public PageReference DeleteRecord() {
        Id parentId = HL_PageUtility.GetParameter('id');
        
        if (!String.isBlank(parentId)) {
            try {
                DeleteRecord(parentId);
            }
            catch (DmlException ex) {
                if (ApexPages.currentPage() != null)
                    ApexPages.addMessages(ex);
            }
        }
        
        if (!String.isBlank(HL_PageUtility.GetParameter('retURL')))
            return new PageReference(HL_PageUtility.GetParameter('retURL'));
        else
            return page.HL_ContactHome;
    }
    
    @AuraEnabled
    public static void DeleteRecord(String id) {
        List<Event> eventList = [SELECT Id FROM Event WHERE Id = : id OR (ParentId__c <> null AND ParentId__c = : id)];
        delete eventList;
    }
    
    public PageReference CancelRecord() {
        return new PageReference('/apex/HL_ActivityEventViewOutlook?id='+activityId);
    }
    
    //Creates the Followup Event off of the Original Event Followup Fields
    private Event CreateFollowup(Event e) {
        Event f = e.clone();
        f.Type = (f.Type == 'Internal' ? 'Internal' : 'Follow-up ' + f.Followup_Type__c);
        f.Subject = 'Follow-up: ' + e.Subject.remove('Follow-up: ');
        f.Description = e.Followup_Comments__c;
        f.Start_Date__c = e.Followup_Start_Date__c;
        f.Start_Time__c = e.Followup_Start_Time__c;
        f.StartDateTime = HL_DateUtility.FormatDateTime(e.Followup_Start_Date__c, e.Followup_Start_Time__c);
        f.End_Date__c = e.Followup_Start_Date__c;
        f.End_Time__c = e.Followup_End_Time__c;
        f.EndDateTime = HL_DateUtility.FormatDateTime(e.Followup_Start_Date__c, e.Followup_End_Time__c);
        f.Sync_To_Outlook__c = e.Followup_Sync_To_Outlook__c;
        f.ParentId__c = e.Followup_Parent__c;
        f.Notify_Coverage_Team__c = e.Notify_Coverage_Team__c;
        return ClearFollowupFields(f);
    }
    
    //Clears the Followup Fields - We treat followups as additional events
    private Event ClearFollowupFields(Event e) {
        e.isFollowUp__c = false;
        e.Followup_Type__c = null;
        e.Followup_Comments__c = null;
        e.Followup_Parent__c = null;
        e.Followup_Start_Date__c = null;
        e.Followup_Start_Time__c = null;
        e.Followup_End_Date__c = null;
        e.Followup_End_Time__c = null;
        e.Followup_Sync_To_Outlook__c = false;
        return e;
    }
    
    public void AddCompany() {
        if (SelectedAccountId <> '') {
            RelatedCompanies.add(HL_Company.GetById(SelectedAccountId));
            SelectedAccountId = null;
            SelectedAccountName = null;
        }
    }
    
    public void AddEmployee() {
        if (SelectedEmployeeId <> '') {
            //Added by SF-773                        
            HLEmployees.add(new SelectedEmployee(HL_Contact.GetById(SelectedEmployeeId), HLEmployees.size() == 0));
            if(HLEmployees.size() > 1 && Activity.Type == 'Internal Mentor Meeting')
            {
                HLEmployees.clear();
                HLEmployees.add(new SelectedEmployee(HL_Contact.GetById(SelectedEmployeeId), HLEmployees.size() == 0));                
            }           
            SelectedEmployeeId = null;
            SelectedEmployeeName = null;            
        } 
    }
    
    public void AddOpportunity() {
        if (SelectedOpportunityId <> '') {
            RelatedOpportunities.add(HL_Opportunity.GetById(SelectedOpportunityId));
            SelectedOpportunityId = null;
            SelectedOpportunityName = null;
        }
    }

    public void AddEngagement() {
        if (SelectedEngagementId <> '') {
            RelatedEngagements.add(HL_Engagement.GetByEId(SelectedEngagementId));
            SelectedEngagementId = null;
            SelectedEngagementName = null;
        }
    }
    
    /*public void AddCampaign() {
        if (SelectedCampaignId <> '') {
            RelatedCampaigns.add(HL_Campaign.GetById(SelectedCampaignId));
            SelectedCampaignId = null;
            SelectedCampaignName = null;
        }
    }*/
    public void AddContact() {
        if (SelectedContactId <> '') {
            //Added by SF-579             
            if(Activity.Type == 'Internal Mentor Meeting')
                RelatedContacts.clear();
            RelatedContacts.add(new SelectedContact(HL_Contact.GetById(SelectedContactId), RelatedContacts.size() == 0));
            SelectedContactId = null;
            SelectedContactName = null;                    
        }
    }
    
    //Removes the External Contact
    public void RemoveExternal() {
        if (!String.isBlank(DelId)) {
            for (Integer i = 0; i < RelatedContacts.size(); i++) {
                if (RelatedContacts[i].Contact.Id == DelId) {
                    RelatedContacts.remove(i);
                    break;
                }
            }
        }
    }
    
    //Removes the Employee
    public void RemoveEmployee() {
        if (!String.isBlank(DelId)) {
            for (Integer i = 0; i < HLEmployees.size(); i++) {
                if (HLEmployees[i].Employee.Id == DelId) {
                    HLEmployees.remove(i);
                    break;
                }
            }
        }
    }
    
    //Removes the Company
    public void RemoveCompany() {
        if (!String.isBlank(DelId)) {
            for (Integer i = 0; i < RelatedCompanies.size(); i++) {
                if (RelatedCompanies[i].Id == DelId) {
                    RelatedCompanies.remove(i);
                    break;
                }
            }
        }
    }
    
    //Removes the Opportunity
    public void RemoveOpp() {
        if (!String.isBlank(DelId)) {
            for (Integer i = 0; i < RelatedOpportunities.size(); i++) {
                if (RelatedOpportunities[i].Id == DelId) {
                    RelatedOpportunities.remove(i);
                    break;
                }
            }
        }
    }

    //Removes the Engagement
    public void RemoveEng() {
        if (!String.isBlank(DelId)) {
            for (Integer i = 0; i < RelatedEngagements.size(); i++) {
                if (RelatedEngagements[i].Id == DelId) {
                    RelatedEngagements.remove(i);
                    break;
                }
            }
        }
    }
    
    //Removes the Campaign
   /* public void RemoveCam() {
        if (!String.isBlank(DelId)) {
            for (Integer i = 0; i < RelatedCampaigns.size(); i++) {
                if (RelatedCampaigns[i].Id == DelId) {
                    RelatedCampaigns.remove(i);
                    break;
                }
            }
        }
    }*/
    
    //For Internal Events - We only want Internal Contacts
    //For All Others - We only want External Contacts    
    public void OnActivityTypeChanged() {
        //Validate Access if Internal is Selected
        if (Activity.Type == 'Internal' || Activity.Type == 'Internal Mentor Meeting') {
            if (!HasInternalAccess && !hasMentorActivityAccess) {
                Activity.Type = 'Meeting';
                return;
            }
        }
        
        String recordTypeToRemove = Activity.Type == 'Internal' ? 'External_Contact' : 'Houlihan_Employee';
        if(Activity.Type == 'Internal Mentor Meeting')
        {
            RelatedContacts.clear();
            List<Contact> cList = new List<Contact>();
            Contact c = HL_Contact.GetById(WhoId);
            if (c != null) {
                if (c.RecordType.DeveloperName == 'HOULIHAN_EMPLOYEE' && hasMentorActivityAccess) {
                    cList.Add(c);
                    Activity.Primary_External_Contact_Id__c = c.Id;
                    Activity.Primary_External_Contact_Company_Id__c = c.Account.Id;                      
                }
            }
            
            for (Contact c1 : cList){
                relatedContacts.add(new SelectedContact(c1,  Activity.Primary_External_Contact_Id__c == c1.Id));
            }    
            
            HLEmployees.clear();                
            List<Contact> cHLList = new List<Contact>();
            Contact c2 = HL_Contact.GetByUserId(UserInfo.getUserId());
            if (c2 <> null) {
                cHLList.Add(c2);                
                Activity.Primary_Attendee_Id__c = cHLList[0].Id;
            }
            for (Contact c3 : cHLList){
                hlEmployees.Add(New SelectedEmployee(c3, Activity.Primary_Attendee_Id__c == c3.Id));
            }           
        }
        else {
            Integer i = 0;
            while (i < RelatedContacts.size()) {
                if (RelatedContacts[i].Contact.RecordType.DeveloperName == recordTypeToRemove)
                    RelatedContacts.remove(i);
                else
                    i++;
            }
        }
    }
    
    
    public class SelectedEmployee {
        public Contact Employee {get; set;}
        public Boolean Primary {get; set;}
        public SelectedEmployee(Contact c, Boolean isPrimary) {
            Employee = c;
            Primary = isPrimary;
        }
    }
    
    public class SelectedContact {
        public Contact Contact {get; set;}
        public Boolean Primary {get; set;}
        public SelectedContact(Contact c, Boolean isPrimary) {
            Contact = c;
            Primary = isPrimary;
        }
    }
    
    @AuraEnabled
    public static Boolean HasInternalTypeAccess() {
        return new HL_ActivityControllerOutlook().HasInternalAccess;
    }
    
    @AuraEnabled
    public static void Save(String activityId, String type, String subject, String description, String internalNotes, 
                            String startDate, String startTime, String endDate, String endTime, Boolean isPrivate, 
                            Boolean sync, Boolean notify, Boolean isComplete, Boolean hasFollowup, String fuType, 
                            String fuStartDate, String fuStartTime, String fuEndDate, String fuEndTime, Boolean fuSync, 
                            String fuDescription, Id primaryAttendee, Id primaryEmp, String attendeesJSON, String empsJSON, 
                            String compsJSON, String oppsJSON, String engsJSON, Boolean PfgClick, String PfgNottificationChange, 
                            String clientParticipationChange,Boolean noExternalContactClick) {
                                //Format the dates                    
                                startDate = HL_DateUtility.FormatJSDate(startDate);
                                endDate = HL_DateUtility.FormatJSDate(endDate);
                                if (!String.isBlank(fuStartDate)) {
                                    fuStartDate = HL_DateUtility.FormatJSDate(fuStartDate);
                                    fuEndDate = HL_DateUtility.FormatJSDate(fuEndDate);
                                }
                                
                                //Set Id to null if empty string was passed
                                if (String.isBlank(activityId))
                                    activityId = null;
                                
                                HL_ActivityControllerOutlook con = new HL_ActivityControllerOutlook();
                                Event e = new Event(Id = activityId,
                                                    Type = type,
                                                    Subject = subject,
                                                    Description = description,
                                                    Private__c = isPrivate,
                                                    Sync_To_Outlook__c = sync,
                                                    Notify_Coverage_Team__c = notify,
                                                    Is_Complete__c = isComplete,
                                                    StartDateTime = HL_DateUtility.FormatDateTime(Date.parse(startDate), startTime),
                                                    EndDateTime = HL_DateUtility.FormatDateTime(Date.parse(endDate), endTime),
                                                    Start_Date__c = Date.parse(startDate),
                                                    Start_Time__c = startTime,
                                                    End_Date__c = Date.parse(endDate),
                                                    End_Time__c = endTime,
                                                    WhoId = primaryAttendee,
                                                    Primary_Attendee_Id__c = primaryEmp,
                                                    Primary_External_Contact_Id__c = primaryAttendee,
                                                    PFG__c = PfgClick,
                                                    PFG_Notification__c = PfgNottificationChange,
                                                    Client_Participation__c = clientParticipationChange,
                                                    No_External_Contact__c  = noExternalContactClick);
                                
                                if (hasFollowup) {
                                    e.isFollowUp__c = hasFollowup;
                                    e.Followup_Type__c = fuType;
                                    e.Followup_Start_Date__c = Date.parse(fuStartDate);
                                    e.Followup_Start_Time__c = fuStartTime;
                                    e.Followup_End_Date__c = Date.parse(fuEndDate);
                                    e.Followup_End_Time__c = fuEndTime;
                                    e.Followup_Comments__c = fuDescription;
                                    e.Sync_To_Outlook__c = fuSync;
                                }
                                con.Activity = e;
                                con.ActivitySupplement.Internal_Notes__c = internalNotes;
                                
                                //Primary Attendee Contact Record (External)
                                Contact pa = HL_Contact.GetById(primaryAttendee);
                                //Primary Employee Contact Record (Internal)
                                // Contact pe = new Contact();
                                //if(primaryEmp != null){
                                Contact pe = HL_Contact.GetById(primaryEmp);
                                // }
                                //Convert the JSON to our Objects
                                con.RelatedContacts = new List<SelectedContact>();
                                
                                for (Contact c : (List<Contact>)HL_JSONUtility.ConvertJSONToListOfSObject('Contact', attendeesJSON))
                                    con.RelatedContacts.add(new SelectedContact(pa.Id == c.Id ? pa : c, c.Id == primaryAttendee));
                                
                                con.HLEmployees = new List<SelectedEmployee>();
                                for (Contact c : (List<Contact>)HL_JSONUtility.ConvertJSONToListOfSObject('Contact', empsJSON))
                                    con.HLEmployees.add(new SelectedEmployee(pe.Id == c.Id ? pe : c, c.Id == primaryEmp));
                                con.RelatedCompanies = new List<Account>();
                                for (Account a : (List<Account>)HL_JSONUtility.ConvertJSONToListOfSObject('Account', compsJSON))
                                    con.RelatedCompanies.add(a);
                                
                                con.RelatedOpportunities = new List<Opportunity__c>();
                                for (Opportunity__c o : (List<Opportunity__c>)HL_JSONUtility.ConvertJSONToListOfSObject('Opportunity__c', oppsJSON))
                                    con.RelatedOpportunities.add(o);

                                con.RelatedEngagements = new List<Engagement__c>();
                                for (Engagement__c eng : (List<Engagement__c>)HL_JSONUtility.ConvertJSONToListOfSObject('Engagement__c', engsJSON))
                                    con.RelatedEngagements.add(eng);
                                
                                //con.RelatedCampaigns = new List<Campaign>();
                                //for (Campaign cp : (List<Campaign>)HL_JSONUtility.ConvertJSONToListOfSObject('Campaign', campJSON))
                                   // con.RelatedCampaigns.add(cp);
                               // con.SaveActivity();
                            }
    
    
    //Retrieves the What Relations For Events (Companies and Opportunities)
    //AuraEnabled: Requires List instead of Set
    @AuraEnabled
    public static List<Id> GetWhatRelations(Id eventId) {
        List<Id> whatRelations = new List<Id>();
        for (Event e : [SELECT WhatId
                        FROM Event
                        WHERE Id = : eventId OR (ParentId__c <> null AND ParentId__c = : eventId)])
            whatRelations.add(e.WhatId);
        return whatRelations;
    }
    
    //Retrieves the Who Relations for Events (HL Contacts - Internal)
    @AuraEnabled
    public static List<Id> GetWhoInternalRelations(Id eventId) {
        List<Id> whoRelations = new List<Id>();
        for (Event e : [SELECT WhoId
                        FROM Event
                        WHERE ParentId__c = : eventId
                        AND (Contact__r.RecordType.DeveloperName = 'Houlihan_Employee' AND Mask_As_External__c = false)])
            whoRelations.add(e.WhoId);
        return whoRelations;
    }
    //Retrieves the Who Relations for Events (External Contacts and Internal Masked as External)
    //Aura Enabled: Requires List instead of Set External_Contact
    @AuraEnabled
    public static List<Id> GetWhoExternalRelations(Id eventId) {
        List<Id> whoRelations = new List<Id>();
        for (Event e : [SELECT WhoId
                        FROM Event
                        WHERE ParentId__c = : eventId                         
                        AND (Contact__r.RecordType.DeveloperName = 'External_Contact' OR Mask_As_External__c = true)])
            whoRelations.add(e.WhoId);
        return whoRelations;
    }
    
    @AuraEnabled
    public static List<Contact> GetDefaultAttendee(Id attendeeId) {
        return new List<Contact> {HL_Contact.GetById(attendeeId)};
            }
    @AuraEnabled
    public static List<Contact> GetDefaultContact() {
        return new List<Contact> {HL_Contact.GetByUserId(UserInfo.getUserId())};
            }
    
    @AuraEnabled
    public static Event GetById(Id eventId) {
        return HL_Event.GetById(eventId);
    }
    
    @AuraEnabled
    public static Activity_Supplement__c GetActivitySupplement(Id eventId) {
        HL_ActivityControllerOutlook con = new HL_ActivityControllerOutlook();
        con.Activity.Id = eventId;
        return con.ActivitySupplement;
    }
    
    @AuraEnabled
    public static List<Contact> GetAttendees(Id eventId) {
        Set<Id> whoRelations = new Set<Id>(GetWhoExternalRelations(eventId));
        return [SELECT RecordTypeId, Name, Account.Id, Account.Name, Title, Email, Office__c, Line_Of_Business__c, Phone, MobilePhone
                FROM Contact
                WHERE Id IN : whoRelations
                ORDER BY Name];
    }
    
    @AuraEnabled
    public static List<Contact> GetEmployees(Id eventId) {
        Set<Id> whoRelations = new Set<Id>(GetWhoInternalRelations(eventId));
        return [SELECT RecordTypeId, Name, Account.Id, Account.Name, Title, Email, Office__c, Line_Of_Business__c, Phone, MobilePhone
                FROM Contact
                WHERE Id IN : whoRelations
                ORDER BY Name];
    }
    
    @AuraEnabled
    public static Boolean HasDeleteRights(Id eventId) {
        Contact c = HL_Contact.GetByUserId();
        Event e = GetById(eventId);
        return (c.Id == e.Primary_Attendee_Id__c || UserInfo.getUserId() == e.CreatedById);
    }
    
    @AuraEnabled
    public static List<Account> GetComps(Id eventId) {
        Set<Id> whatRelations = new Set<Id>(GetWhatRelations(eventId));
        return [SELECT Name, BillingCity, BillingState, BillingCountry, Location__c
                FROM Account
                WHERE Id IN : whatRelations
                ORDER BY Name];
    }
    
    @AuraEnabled
    public static List<Opportunity__c> GetOpps(Id eventId) {
        Set<Id> whatRelations = new Set<Id>(GetWhatRelations(eventId));
        return [SELECT Name, Client__r.Name, Subject__r.Name
                FROM Opportunity__c
                WHERE Id IN : whatRelations
                ORDER BY Name];
    }
    
    @AuraEnabled
    public static List<Engagement__c> GetEngs(Id eventId) {
        Set<Id> whatRelations = new Set<Id>(GetWhatRelations(eventId));
        return [SELECT Name, Id, Client__r.Name, Subject__r.Name
                FROM Engagement__c
                WHERE Id IN : whatRelations
                ORDER BY Name];
    }
    
    /*@AuraEnabled
    public static List<Campaign> GetCamp(Id eventId) {
        Set<Id> whatRelations = new Set<Id>(GetWhatRelations(eventId));
        return [SELECT Id,Name,RecordType.name,Type FROM Campaign
                WHERE Id IN : whatRelations
                ORDER BY Name];
    }*/
    
    @AuraEnabled
    public static List<String> GetActivityTypes() {
        return HL_Utility.GetPicklistValues('Event', 'Type');
    }
    
    @AuraEnabled
    public static List<String> GetFollowupTypes() {
        return HL_Utility.GetPicklistValues('Event', 'Followup_Type__c');
    }    
    @AuraEnabled
    public static Account getAccountData(String accountId){
        Account account = [SELECT Id, Name, Location__c FROM Account WHERE id = :accountId LIMIT 1];
        return account;
    }

    public PageReference goToSendNotification(){
        PageReference pr = new PageReference('/apex/HL_SendEmail?retURL=/'+EntityId+'&template=Event&ro='+EntityId+'&isFromOutlook=true&retUrl=/apex/HL_ActivityEventViewOutlook?Id='+EntityId);
        return pr;
    }
}