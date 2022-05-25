public without sharing class HL_ActivityAuraController extends HL_ActivityControllerBase {
  @AuraEnabled
  public Id recordId;

  @AuraEnabled
  public List<String> apexMessages = new List<String>();
  @AuraEnabled
  public String pageReferenceURL;
  @AuraEnabled
  public Boolean pageReferenceRedirect = false;

  @AuraEnabled
  public String eventsId {
    get {
      Id mySql = recordId;
      if (eventsId == null)
        if (mySql != null) {
          eventsId = [SELECT id, Type FROM Event WHERE id = :mySql].Type;
        }
      return eventsId;
    }
    set;
  }

  @AuraEnabled
  public string activityId;
  @AuraEnabled
  public Id DelId { get; set; }
  @AuraEnabled
  public String FormattedStart {
    get {
      return Activity.StartDateTime.format();
    }
  }

  @AuraEnabled
  public String FormattedStartDate {
    get {
      return Activity.StartDateTime == null
        ? ''
        : Activity.StartDateTime.format('hh:mm a');
    }
  }

  @AuraEnabled
  public String FormattedEnd {
    get {
      return Activity.EndDateTime.format();
    }
  }

  @AuraEnabled
  public String FormattedEndDate {
    get {
      return Activity.EndDateTime == null
        ? ''
        : Activity.EndDateTime.format('hh:mm a');
    }
  }

  public enum RelatedEventType {
    External,
    Internal,
    Company,
    Opportunity,
    Campaigns
  }
  @AuraEnabled
  public Activity_Supplement__c ActivitySupplement {
    get {
      if (activitySupplement == null) {
        if (!String.isBlank(Activity.Id)) {
          List<Activity_Supplement__c> asList = [
            SELECT Activity__c, Internal_Notes__c, Sync_Description__c
            FROM Activity_Supplement__c
            WHERE Activity__c = :Activity.Id
          ];

          activitySupplement = asList.size() > 0
            ? asList[0]
            : new Activity_Supplement__c();
        } else
          activitySupplement = new Activity_Supplement__c();
      }

      return activitySupplement;
    }
    set;
  }

  @AuraEnabled
  public Event Activity {
    get {
      if (activity == null)
        activity = new Event();
      return activity;
    }
    set;
  }

  @AuraEnabled
  public String WhoId { get; set; }
  @AuraEnabled
  public String WhatId { get; set; }
  @AuraEnabled
  public String SelectedAccountId { get; set; }
  @AuraEnabled
  public String SelectedAccountName { get; set; }
  @AuraEnabled
  public String SelectedEmployeeId { get; set; }
  @AuraEnabled
  public String SelectedEmployeeName { get; set; }
  @AuraEnabled
  public String SelectedOpportunityId { get; set; }
  @AuraEnabled
  public String SelectedOpportunityName { get; set; }
  @AuraEnabled
  public String SelectedContactId { get; set; }
  @AuraEnabled
  public String SelectedContactName { get; set; }
  @AuraEnabled
  public String SelectedCampaignId { get; set; }
  @AuraEnabled
  public String SelectedCampaignName { get; set; }
  @AuraEnabled
  public Boolean HasViewAccess {
    get {
      //Non-Private Activities: Other Attendees Should Have Edit/Modify Access
      //Private Activities: Other Attendees Can View, but not Edit
      Id userId = UserInfo.getUserId();
      Contact c = HL_Contact.GetByUserId(userId);
      Boolean tempViewAccess =
        HasModifyAccess ||
        HasLimitedModifyAccess ||
        InternalWhoRelations.contains(UserContactRecord.Id) ||
        (Activity.Pfg__c && c.Industry_Group__C == 'PFG - Private Funds Group');
      if (Activity.type == 'Meeting') {
        //Get a Map of Event Id with HL Attendees
        Set<Id> attendeeSet = new Set<Id>();
        Set<Id> menteeSet = new Set<Id>();

        for (Event e : [
          SELECT ParentId__c, WhoId, Mask_As_External__c
          FROM Event
          WHERE ParentId__c = :Activity.Id AND WhoID != NULL
        ]) {
          if (!e.Mask_As_External__c) {
            attendeeSet.add(e.WhoId);
          } else {
            menteeSet.add(e.WhoId);
          }
        }

        tempViewAccess =
          hasModifyAccess ||
          menteeSet.contains(UserContactRecord.id) ||
          InternalWhoRelations.contains(UserContactRecord.Id) ||
          attendeeSet.contains(UserContactRecord.id) ||
          HL_Group.IsInGroup('Mentor_Activity_Access');
      }
      return tempViewAccess;
    }
    set;
  }
  @AuraEnabled
  public Boolean HasLimitedModifyAccess {
    get {
      return !Activity.Private__c &&
        InternalWhoRelations.contains(UserContactRecord.Id);
    }
    set;
  }
  @AuraEnabled
  public Boolean HasModifyAccess {
    get {
      if (hasModifyAccess == null) {
        if (!String.isEmpty(Activity.Id)) {
          Id userId = UserInfo.getUserId();
          Contact c = HL_Contact.GetById(Activity.Primary_Attendee_Id__c);
          //Non-Private Activities: Other Attendees Should Have Edit/Modify Access
          //Private Activities: Other Attendees Can View, but not Edit
          hasModifyAccess = (Supervisors.contains(UserContactRecord.Id) ||
          InternalWhoRelations.contains(UserContactRecord.Id) ||
          userId == Activity.Contact_User_Id__c ||
          userId == Activity.CreatedById ||
          Activity.Primary_Attendee_Id__c == UserContactRecord.Id ||
          Supervisors.contains(c.User__c));

          if (
            !hasModifyAccess &&
            Activity.Type == 'Internal' &&
            HasInternalSupervisorAccess
          ) {
            Schema.RecordTypeInfo internalRecordTypeInfo = Schema.SObjectType.Event.getRecordTypeInfosByName()
              .get('Internal ' + UserContactRecord.Line_of_Business__c);
            if (internalRecordTypeInfo != null)
              hasModifyAccess =
                Activity.RecordTypeId ==
                internalRecordTypeInfo.getRecordTypeId();
          }
          if (
            Activity.type == 'Meeting' ||
            Activity.type == 'Email' ||
            Activity.type == 'Other' ||
            Activity.type == 'Call' ||
            Activity.type == 'Platinum'
          ) {
            //Get a Map of Event Id with HL Attendees
            Set<Id> attendeeSet = new Set<Id>();
            Set<Id> menteeSet = new Set<Id>();
            Set<Id> hlEmpSet = new Set<Id>();
            for (Event e : [
              SELECT
                ParentId__c,
                WhoId,
                Mask_As_External__c,
                Who.RecordType.DeveloperName,
                Contact__r.User__c
              FROM Event
              WHERE
                ParentId__c = :Activity.Id
                AND WhoID != NULL
                AND Mask_As_External__c = FALSE
            ]) {
              attendeeSet.add(e.WhoId);
              if (e.Who.RecordType.DeveloperName == 'Houlihan_Employee') {
                hlEmpSet.add(e.Contact__r.User__c);
              }
            }
            //hasModifyAccess = attendeeSet.contains(UserContactRecord.id) || userId == Activity.CreatedById || Activity.Primary_Attendee_Id__c == UserContactRecord.Id || hasMentorActivityAccess ;
            Id currentUserId = UserInfo.getUserId();
            for (Delegate_Public_Group_Member__c member : [
              SELECT Id, Delegate__c
              FROM Delegate_Public_Group_Member__c
              WHERE
                Delegate_Public_Group__r.Banker__c IN :hlEmpSet
                AND Active__c = TRUE
            ]) {
              if (currentUserId == member.Delegate__c) {
                hasModifyAccess = true;
                break;
              }
            }

            /*for(Id empId : hlEmpSet){
                          if(InternalWhoRelations.contains(empId)){
                              hasModifyAccess=true;
                              break;
                          }
                      }*/
            if (!hasModifyAccess) {
              hasModifyAccess = (Supervisors.contains(UserContactRecord.Id) ||
              Supervisors.contains(c.User__c) ||
              InternalWhoRelations.contains(UserContactRecord.Id) ||
              attendeeSet.contains(UserContactRecord.id) ||
              (attendeeSet.contains(UserContactRecord.id) &&
              HL_Group.IsInGroup('Mentor_Activity_Access')));
            }
          }
        } else
          hasModifyAccess = true;
      }
      return hasModifyAccess;
    }
    set;
  }

  @AuraEnabled
  public List<Event> ExistingRelatedEvents {
    get {
      System.debug('ExistingRelatedEvents, activityId = ' + Activity.Id);

      if (existingRelatedEvents == null) {
        Id activityId = Activity.Id;
        String relatedEventQuery =
          HL_Event.STANDARD_SELECT +
          ' FROM Event WHERE ParentId__c =: activityId';
        existingRelatedEvents = Database.query(relatedEventQuery);
      }
      return existingRelatedEvents;
    }
    set;
  }

  @AuraEnabled
  public List<Account> RelatedCompanies {
    get {
      if (relatedCompanies == null) {
        relatedCompanies = [
          SELECT Name, BillingCity, BillingState, BillingCountry
          FROM Account
          WHERE Id IN :EventWhatRelations
          ORDER BY Name
        ];
        if (
          (relatedCompanies == null || relatedCompanies.size() == 0) &&
          HL_Utility.GetObjectTypeById(WhatId) == 'Account'
        ) {
          relatedCompanies = [
            SELECT Name, BillingCity, BillingState, BillingCountry
            FROM Account
            WHERE Id = :WhatId
            ORDER BY Name
          ];
        }
      }
      return relatedCompanies;
    }
    set;
  }

  // Vikas

  //Internal Contact Attendees
  @AuraEnabled
  public List<SelectedEmployee> HLEmployees {
    get {
      if (hlEmployees == null) {
        List<Contact> cList = [
          SELECT
            Name,
            User__c,
            Title,
            Email,
            Office__c,
            Line_Of_Business__c,
            Phone,
            MobilePhone
          FROM Contact
          WHERE Id IN :internalWhoRelations
          ORDER BY Name
        ];
        hlEmployees = new List<SelectedEmployee>();
        if (cList.size() == 0) {
          Contact c = HL_Contact.GetByUserId(UserInfo.getUserId());
          if (c <> null) {
            cList.Add(c);
            Activity.Primary_Attendee_Id__c = cList[0].Id;
          }
        }
        for (Contact c : cList) {
          hlEmployees.Add(
            new SelectedEmployee(c, Activity.Primary_Attendee_Id__c == c.Id)
          );

          HL_RelatedWidgetItem item = new HL_RelatedWidgetItem(c.Id, c.Name);

          item.addValue(
            new HL_RelatedWidgetItemValue('title', 'Title', c.Title)
          );

          HLEmployeesSidebar.add(item);
        }
      }
      return hlEmployees;
    }
    set;
  }

  @AuraEnabled
  public List<HL_RelatedWidgetItem> HLEmployeesSidebar = new List<HL_RelatedWidgetItem>();

  private SelectedEmployee PrimaryAttendee {
    get {
      for (SelectedEmployee se : HLEmployees) {
        if (se.Primary)
          return se;
      }

      return null;
    }
  }
  private SelectedContact PrimaryContact {
    get {
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

  @AuraEnabled
  public List<Opportunity__c> RelatedOpportunities {
    get {
      if (relatedOpportunities == null)
        relatedOpportunities = [
          SELECT
            Name,
            Client__r.Name,
            Subject__r.Name,
            Job_Type__c,
            Line_of_Business__c,
            Industry_Group__c,
            Stage__c
          FROM Opportunity__c
          WHERE Id IN :EventWhatRelations
          ORDER BY Name
        ];

      return relatedOpportunities;
    }
    set;
  }

  @AuraEnabled
  public List<Campaign> RelatedCampaigns {
    get {
      if (relatedCampaigns == null)
        relatedCampaigns = [
          SELECT Name, recordtype.name, Type
          FROM Campaign
          WHERE Id IN :EventWhatRelations
          ORDER BY Name
        ];
      return relatedCampaigns;
    }
    set;
  }

  //External Contacts (Or Internal Contacts Masked as External)
  @AuraEnabled
  public List<SelectedContact> RelatedContacts {
    get {
      if (relatedContacts == null) {
        List<Contact> cList = [
          SELECT
            Name,
            Account.Id,
            Account.Name,
            Title,
            Email,
            Office__c,
            Line_Of_Business__c,
            Phone,
            MobilePhone,
            RecordType.DeveloperName
          FROM Contact
          WHERE Id IN :ExternalWhoRelations
          ORDER BY Name
        ];
        relatedContacts = new List<SelectedContact>();
        if (
          cList.size() == 0 &&
          !string.isBlank(WhoId) &&
          Activity.Type != 'Internal'
        ) {
          Contact c = HL_Contact.GetById(WhoId);
          if (c != null) {
            if (
              c.RecordType.DeveloperName == 'EXTERNAL_CONTACT' ||
              (c.RecordType.DeveloperName == 'HOULIHAN_EMPLOYEE' &&
              (HasInternalAccess || hasMentorActivityAccess))
            ) {
              cList.Add(c);
              Activity.Primary_External_Contact_Id__c = c.Id;
              Activity.Primary_External_Contact_Company_Id__c = c.Account.Id;
              if (
                c.RecordType.DeveloperName == 'HOULIHAN_EMPLOYEE' &&
                String.isBlank(Activity.Type) &&
                HasInternalAccess
              )
                Activity.Type = 'Internal';
              else if (
                c.RecordType.DeveloperName == 'HOULIHAN_EMPLOYEE' &&
                String.isBlank(Activity.Type) &&
                hasMentorActivityAccess
              )
                Activity.Type = 'Internal Mentor Meeting';
            }
          }
        }
        for (Contact c : cList) {
          relatedContacts.add(
            new SelectedContact(
              c,
              Activity.Primary_External_Contact_Id__c == c.Id
            )
          );

          HL_RelatedWidgetItem item = new HL_RelatedWidgetItem(c.Id, c.Name);

          item.addValue(
            new HL_RelatedWidgetItemValue(
              'accountName',
              'Account Name',
              c.Account.Name
            )
          );
          item.addValue(
            new HL_RelatedWidgetItemValue('title', 'Title', c.Title)
          );

          RelatedContactsSidebar.add(item);
        }
      }
      return relatedContacts;
    }
    set;
  }

  @AuraEnabled
  public List<HL_RelatedWidgetItem> RelatedContactsSidebar = new List<HL_RelatedWidgetItem>();

  //List of Contact Records from the Related Contacts
  private List<Contact> RelatedContactsContactList {
    get {
      List<Contact> cList = new List<Contact>();

      for (SelectedContact sc : RelatedContacts)
        cList.Add(sc.Contact);

      return cList;
    }
  }

  @AuraEnabled
  public Set<Id> EventWhatRelations {
    get {
      if (eventWhatRelations == null)
        eventWhatRelations = new Set<Id>(GetWhatRelations(EntityId));
      return eventWhatRelations;
    }
    set;
  }

  @AuraEnabled
  public Set<Id> InternalWhoRelations {
    get {
      if (internalWhoRelations == null)
        internalWhoRelations = new Set<Id>(GetWhoInternalRelations(EntityId));
      return internalWhoRelations;
    }
    set;
  }

  @AuraEnabled
  public Set<Id> ExternalWhoRelations {
    get {
      if (externalWhoRelations == null)
        externalWhoRelations = new Set<Id>(GetWhoExternalRelations(EntityId));
      return externalWhoRelations;
    }
    set;
  }

  private static Event getEventInit(Id recordId) {
    return [
      SELECT
        Id,
        StartDateTime,
        EndDateTime,
        Private__c,
        Primary_External_Contact_Id__c,
        Primary_Attendee_Id__c,
        Contact_User_Id__c,
        CreatedById,
        Type,
        Subject,
        Industry_Group__c,
        Product_Type__c,
        Purpose__c,
        Description,
        PFG_Notification__c,
        Client_Participation__c,
        Sync_To_Outlook__c,
        Notify_Coverage_Team__c,
        Start_Date__c,
        Start_Time__c,
        End_Time__c,
        PFG__c // TODO - missing fields, add
      FROM Event
      WHERE Id = :recordId
    ];
  }

  @AuraEnabled
  public static HL_ActivityAuraController getModel(Id recordId) {
      System.debug('recordId ' + recordId);
      
    try {
      HL_ActivityAuraController model = new HL_ActivityAuraController();
      model.recordId = recordId;
      model.EntityId = recordId;

      model.Activity = getEventInit(recordId);

      return model;
    } catch (Exception e) {
        System.debug(e.getMessage());
        System.debug(e.getStackTraceString());

      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static HL_ActivityAuraController getModelWithWhoWhatAndRelatedIds(
    Id recordId,
    Id whoId,
    Id whatId,
    Id relatedId
  ) {
    try {
      HL_ActivityAuraController model = new HL_ActivityAuraController();
      model.recordId = recordId;
      model.EntityId = recordId;

      if (model.EntityType != 'Account' && model.EntityType != 'Contact') {
        model.Activity = getEventInit(recordId);
      }

      model.WhoId = whoId;
      model.WhatId = whatId;

      if (!String.isBlank(relatedId)) {
        if (HL_Utility.GetObjectTypeById(relatedId) == 'Account') {
          model.WhatId = relatedId;
        } else {
          model.WhoId = relatedId;
        }
      }

      return model;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
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
    if (
      Activity.Type == 'Internal' ||
      Activity.Type == 'Internal Mentor Meeting' ||
      Activity.Type == 'Follow-up Internal'
    ) {
      Activity.Private__c = true;
      try {
        Activity.RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName()
          .get('Internal ' + PrimaryAttendee.Employee.Line_of_Business__c)
          .getRecordTypeId();
      } catch (Exception ex) {
        apexMessages.add(
          'Invalid Primary Attendee Selected for Internal Activity, Record Type has not been Setup: ' +
          PrimaryAttendee.Employee.Line_of_Business__c
        );
        throw ex;
      }
    }

    //Format the date/time fields
    Activity.StartDateTime = HL_DateUtility.FormatDateTime(
      Activity.Start_Date__c,
      Activity.Start_Time__c
    );
    Activity.EndDateTime = HL_DateUtility.FormatDateTime(
      Activity.Start_Date__c,
      Activity.End_Time__c
    );

    //Assign the Primary HL and Contact Attendee Fields
    if (primary != null && primary.Employee != null) {
      Activity.Primary_Attendee_Id__c = primary.Employee.Id;
      Activity.Primary_Attendee__c = primary.Employee.Name;
      Activity.WhoId = primary.Employee.Id;
    }
    if (pc != null && pc.Contact != null) {
      Activity.Primary_External_Contact_Id__c = pc.Contact.Id;
      Activity.Primary_External_Contact__c = pc.Contact.Name;
      Activity.Primary_External_Contact_Company_Id__c = pc.Contact.Account.Id;
      Activity.Primary_External_Contact_Company__c = pc.Contact.Account.Name;
    }
    Activity.OwnerId = mc.Id__c;

    upsert Activity;
    Activity.ParentId__c = Activity.Id;
    activityId = Activity.id;
  }

  private Boolean ValidateActivity() {
    Boolean isValid = true;

    //There needs to be both a primary HL Contact and a Primary External Contact or If "No Primary External Contact" to mention then Companies Discussed is required
    if (
      (PrimaryAttendee == null || PrimaryContact == null) &&
      !Activity.No_External_Contact__c
    ) {
      isValid = false;

      apexMessages.add(
        'Please mark the "No External Contact" checkbox if you wish not to include an primary external attendee on this activity'
      );
    } else if (Activity.No_External_Contact__c && (PrimaryContact != null)) {
      isValid = false;
      apexMessages.add(
        'Please either remove external attendee or uncheck the No External Contact checkbox'
      );
    } else if (
      Activity.No_External_Contact__c &&
      (RelatedCompanies == null ||
      RelatedCompanies.size() < 1)
    ) {
      isValid = false;
      apexMessages.add(
        'If no external attendee is entered, then Companies Discussed is required to create an activity'
      );
    } else if (String.isBlank(Activity.Subject)) {
      isValid = false;
      apexMessages.add('Subject Required');
    } else if (
      Activity.Start_Date__c == null ||
      String.isBlank(Activity.Start_Time__c) ||
      String.IsBlank(Activity.End_Time__c)
    ) {
      System.debug('startDate ' + Activity.Start_Date__c);
      System.debug('startTime ' + Activity.Start_Time__c);
      System.debug('endTime ' + Activity.End_Time__c);

      isValid = false;
      apexMessages.add('Date, Start and End Time are Required');
    } else if (Activity.isFollowUp__c) {
      if (
        Activity.Followup_Start_Date__c == null ||
        String.IsBlank(Activity.Followup_Start_Time__c) ||
        String.IsBlank(Activity.Followup_End_Time__c)
      ) {
        isValid = false;
        apexMessages.add('Follow-up Date and Time are Required');
      }
      if (String.isBlank(Activity.Followup_Type__c)) {
        isValid = false;
        apexMessages.add('Follow-up Type is Required');
      }
    }

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
    if (o instanceof Campaign)
      return RelatedEventType.Campaigns;
    if (o instanceof SelectedEmployee)
      return RelatedEventType.Internal;

    return RelatedEventType.External;
  }
  private List<Event> AddRecordToInsert(
    List<Event> insertList,
    Object o,
    Id id
  ) {
    //Clone the Parent Event
    Event e = Activity.clone();
    RelatedEventType eventType = GetRelatedEventType(o);

    if (
      eventType == RelatedEventType.Company ||
      eventType == RelatedEventType.Opportunity ||
      eventType == RelatedEventType.Campaigns
    ) {
      e.WhatId = id;
      e.WhoId = null;
    } else {
      e.WhatId = null;

      if (eventType == RelatedEventType.Internal) {
        SelectedEmployee c = (SelectedEmployee) o;
        e.WhoId = c.Employee.Id;
        system.debug('c>>>' + c.Employee.User__c);
        e.OwnerId = c.Employee.User__c;
        System.debug(
          '--------------------------------------Owner Id ----------------------------------------' +
          e.OwnerId +
          '-------' +
          c
        );
      } else {
        SelectedContact c = (SelectedContact) o;
        e.WhoId = c.Contact.Id;
        //For Internal Events these are Internal Contacts, so we want to flag them
        if (
          e.Type == 'Internal' ||
          e.Type == 'Follow-up Internal' ||
          e.Type == 'Internal Mentor Meeting'
        )
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

    for (Campaign cp : RelatedCampaigns)
      relatedEventMap.put(cp.Id, cp);

    for (SelectedEmployee c : HLEmployees) {
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

  private static HL_ActivityAuraController deserializeModel(String jsonModel) {
    HL_ActivityAuraController model = (HL_ActivityAuraController) JSON.deserialize(
      jsonModel,
      HL_ActivityAuraController.class
    );

    model.apexMessages = new List<String>();

    return model;
  }

  @AuraEnabled
  public static HL_ActivityAuraController SaveActivity(String jsonModel) {
    HL_ActivityAuraController model = deserializeModel(jsonModel);

    return SaveActivity(model);
  }

  private static HL_ActivityAuraController SaveActivity(
    HL_ActivityAuraController model
  ) {
    //There needs to be both a primary HL Contact and a Primary External Contact
    if (model.ValidateActivity()) {
      List<Event> eventInsertList = new List<Event>();
      List<Event> eventUpdateList = new List<Event>();
      Map<Id, Object> relatedEventMap = model.GetRelatedEventMap();
      Event followup;
      try {
        model.UpsertParentActivity();
        if (model.Activity.isFollowUp__c) {
          followup = model.CreateFollowup(model.Activity.clone());
          insert followup;
          model.Activity.Followup_Parent__c = followup.Id;
        }

        for (Id id : relatedEventMap.keySet()) {
          Event existingRelated = model.GetExistingEvent(id);
          if (existingRelated == null) {
            eventInsertList = model.AddRecordToInsert(
              eventInsertList,
              relatedEventMap.get(id),
              id
            );
          } else {
            existingRelated = model.SynchronizeParentData(existingRelated);
            eventUpdateList.add(existingRelated);
          }
        }

        if (eventInsertList.size() > 0)
          insert eventInsertList;

        if (eventUpdateList.size() > 0)
          update eventUpdateList;

        //Remove any child events that were deleted
        model.DeleteRemovedChildEvents(relatedEventMap);

        if (
          model.Activity.isFollowUp__c &&
          (eventInsertList.size() > 0 ||
          eventUpdateList.size() > 0)
        ) {
          List<Event> childList = eventInsertList.clone();
          childList.addAll(eventUpdateList);
          model.PrepareChildFollowupRecords(childList);
        }

        if (String.isBlank(model.ActivitySupplement.Activity__c)) {
          model.ActivitySupplement.Activity__c = model.Activity.Id;
          model.ActivitySupplement.Sync_Description__c = model.GenerateSyncDescription(
            model.Activity.Id
          );
          insert model.ActivitySupplement;
        } else {
          model.ActivitySupplement.Sync_Description__c = model.GenerateSyncDescription(
            model.Activity.Id
          );
          update model.ActivitySupplement;
        }

        eventUpdateList.clear();
        if (model.Activity.isFollowUp__c) {
          insert new Activity_Supplement__c(
            Activity__c = followup.Id,
            Sync_Description__c = model.GenerateSyncDescription(followup.Id)
          );
          if (followup.Sync_To_Outlook__c) {
            followup.Riva_Sync_Ready__c = true;
            eventUpdateList.add(followup);
          }
        }

        model.Activity = model.ClearFollowupFields(model.Activity);
        model.Activity.ParentId__c = null;
        if (model.Activity.Sync_To_Outlook__c)
          model.Activity.Riva_Sync_Ready__c = true;

        eventUpdateList.add(model.Activity);
        update eventUpdateList;
      } catch (DmlException ex) {
        model.apexMessages.add(ex.getMessage());

        System.debug(ex.getMessage());
        System.debug(ex.getStackTraceString());

        throw ex;
      }
    }

    return model;
  }

  private String GenerateSyncDescription(Id eventId) {
    return new HL_ActivitySupplement(
        new Event(Id = eventId),
        RelatedContactsContactList
      )
      .ActivitySupplement.Sync_Description__c;
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

  @AuraEnabled
  public static HL_ActivityAuraController SaveRecord(
    String jsonModel,
    String retUrl
  ) {
    HL_ActivityAuraController model = deserializeModel(jsonModel);

    PageReference pageResult = null;
    SaveActivity(model);
    if (model.apexMessages.size() == 0) {
      Event event = [SELECT Id, WhoId FROM Event WHERE id = :model.activityId];
      if (event != null) {
        model.WhoId = event.WhoId;
      }
      if (retUrl != null || model.WhoId == null) {
        CancelRecord(model, null);

        return model;
      } else
        pageResult = new PageReference('/' + model.WhoId);
    }

    if (pageResult != null) {
      model.pageReferenceURL = pageResult.getURL();
      model.pageReferenceRedirect = pageResult.getRedirect();
    } else {
      model.pageReferenceURL = null;
      model.pageReferenceRedirect = false;
    }

    return model;
  }

  @AuraEnabled
  public static HL_ActivityAuraController saveRec(
    String jsonModel,
    String retURL
  ) {
    HL_ActivityAuraController model = deserializeModel(jsonModel);

    try {
      string url;
      if (
        (model.activity.Type == 'Internal Mentor Meeting') &&
        model.RelatedContacts.size() > 0 &&
        model.hlEmployees.size() > 0
      ) {
        if (
          model.RelatedContacts[0].Contact.Id ==
          model.hlEmployees[0].Employee.Id
        ) {
          model.apexMessages.add(System.Label.SFMenteeError);
          return null;
        }
      }
      SaveActivity(model);
      if (model.apexMessages.size() == 0) {
        url = '/apex/HL_ActivityEventview?id=' + model.activityId;
        if (!String.isBlank(retURL))
          url = url + '&retURL=' + retURL;

        model.pageReferenceURL = url;
        model.pageReferenceRedirect = true;
      }
      return model;
    } catch (Exception e) {
      return null;
    }
  }

  public PageReference DeleteRecord() {
    Id parentId = HL_PageUtility.GetParameter('id');

    if (!String.isBlank(parentId)) {
      try {
        DeleteRecord(parentId);
      } catch (DmlException ex) {
        apexMessages.add(ex.getMessage());
      }
    }

    if (!String.isBlank(HL_PageUtility.GetParameter('retURL')))
      return new PageReference(HL_PageUtility.GetParameter('retURL'));
    else
      return page.HL_ContactHome;
  }

  @AuraEnabled
  public static HL_ActivityAuraController CancelRecord(
    String jsonModel,
    String retURL
  ) {
    HL_ActivityAuraController model = deserializeModel(jsonModel);

    return CancelRecord(model, retURL);
  }

  private static HL_ActivityAuraController CancelRecord(
    HL_ActivityAuraController model,
    String retURL
  ) {
    string returnPage = retURL;
    if (returnPage == null) {
      returnPage = '/';
    }

    model.pageReferenceURL = returnPage;
    model.pageReferenceRedirect = true;

    return model;
  }

  //Creates the Followup Event off of the Original Event Followup Fields
  private Event CreateFollowup(Event e) {
    Event f = e.clone();
    f.Type = (f.Type == 'Internal'
      ? 'Internal'
      : 'Follow-up ' + f.Followup_Type__c);
    f.Subject = 'Follow-up: ' + e.Subject.remove('Follow-up: ');
    f.Description = e.Followup_Comments__c;
    f.Start_Date__c = e.Followup_Start_Date__c;
    f.Start_Time__c = e.Followup_Start_Time__c;
    f.StartDateTime = HL_DateUtility.FormatDateTime(
      e.Followup_Start_Date__c,
      e.Followup_Start_Time__c
    );
    f.End_Date__c = e.Followup_Start_Date__c;
    f.End_Time__c = e.Followup_End_Time__c;
    f.EndDateTime = HL_DateUtility.FormatDateTime(
      e.Followup_Start_Date__c,
      e.Followup_End_Time__c
    );
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

  @AuraEnabled
  public static HL_ActivityAuraController AddCompany(String jsonModel) {
    HL_ActivityAuraController model = deserializeModel(jsonModel);

    if (model.SelectedAccountId <> '') {
      model.RelatedCompanies.add(HL_Company.GetById(model.SelectedAccountId));
      model.SelectedAccountId = null;
      model.SelectedAccountName = null;
    }

    return model;
  }

  @AuraEnabled
  public static HL_ActivityAuraController AddEmployee(String jsonModel) {
    HL_ActivityAuraController model = deserializeModel(jsonModel);

    if (model.SelectedEmployeeId <> '') {
      //Added by SF-773
      model.HLEmployees.add(
        new SelectedEmployee(
          HL_Contact.GetById(model.SelectedEmployeeId),
          model.HLEmployees.size() == 0
        )
      );
      if (
        model.HLEmployees.size() > 1 &&
        model.Activity.Type == 'Internal Mentor Meeting'
      ) {
        model.HLEmployees.clear();
        model.HLEmployees.add(
          new SelectedEmployee(
            HL_Contact.GetById(model.SelectedEmployeeId),
            model.HLEmployees.size() == 0
          )
        );
      }
      model.SelectedEmployeeId = null;
      model.SelectedEmployeeName = null;
    }

    return model;
  }

  @AuraEnabled
  public static HL_ActivityAuraController AddOpportunity(String jsonModel) {
    HL_ActivityAuraController model = deserializeModel(jsonModel);

    if (model.SelectedOpportunityId <> '') {
      model.RelatedOpportunities.add(
        HL_Opportunity.GetById(model.SelectedOpportunityId)
      );
      model.SelectedOpportunityId = null;
      model.SelectedOpportunityName = null;
    }

    return model;
  }

  @AuraEnabled
  public static HL_ActivityAuraController AddCampaign(String jsonModel) {
    HL_ActivityAuraController model = deserializeModel(jsonModel);

    if (model.SelectedCampaignId <> '') {
      model.RelatedCampaigns.add(HL_Campaign.GetById(model.SelectedCampaignId));
      model.SelectedCampaignId = null;
      model.SelectedCampaignName = null;
    }

    return model;
  }

  @AuraEnabled
  public static HL_ActivityAuraController AddContact(String jsonModel) {
    HL_ActivityAuraController model = deserializeModel(jsonModel);

    if (model.SelectedContactId <> '') {
      //Added by SF-579
      if (model.Activity.Type == 'Internal Mentor Meeting')
        model.RelatedContacts.clear();
      System.debug('selectedContactId = ' + model.SelectedContactId);
      model.RelatedContacts.add(
        new SelectedContact(
          HL_Contact.GetById(model.SelectedContactId),
          model.RelatedContacts.size() == 0
        )
      );
      model.SelectedContactId = null;
      model.SelectedContactName = null;
    }

    model = SaveActivity(model);

    return model;
  }

  //Removes the External Contact

  @AuraEnabled
  public static HL_ActivityAuraController RemoveExternal(String jsonModel) {
    HL_ActivityAuraController model = deserializeModel(jsonModel);

    if (!String.isBlank(model.DelId)) {
      for (Integer i = 0; i < model.RelatedContacts.size(); i++) {
        if (model.RelatedContacts[i].Contact.Id == model.DelId) {
          model.RelatedContacts.remove(i);
          break;
        }
      }
    }

    return model;
  }

  //Removes the Employee
  @AuraEnabled
  public static HL_ActivityAuraController RemoveEmployee(String jsonModel) {
    HL_ActivityAuraController model = deserializeModel(jsonModel);

    if (!String.isBlank(model.DelId)) {
      for (Integer i = 0; i < model.HLEmployees.size(); i++) {
        if (model.HLEmployees[i].Employee.Id == model.DelId) {
          model.HLEmployees.remove(i);
          break;
        }
      }
    }

    return model;
  }

  //Removes the Company
  @AuraEnabled
  public static HL_ActivityAuraController RemoveCompany(String jsonModel) {
    HL_ActivityAuraController model = deserializeModel(jsonModel);

    if (!String.isBlank(model.DelId)) {
      for (Integer i = 0; i < model.RelatedCompanies.size(); i++) {
        if (model.RelatedCompanies[i].Id == model.DelId) {
          model.RelatedCompanies.remove(i);
          break;
        }
      }
    }

    return model;
  }

  //Removes the Opportunity
  @AuraEnabled
  public static HL_ActivityAuraController RemoveOpp(String jsonModel) {
    HL_ActivityAuraController model = deserializeModel(jsonModel);

    if (!String.isBlank(model.DelId)) {
      for (Integer i = 0; i < model.RelatedOpportunities.size(); i++) {
        if (model.RelatedOpportunities[i].Id == model.DelId) {
          model.RelatedOpportunities.remove(i);
          break;
        }
      }
    }

    return model;
  }

  //Removes the Campaign
  @AuraEnabled
  public static HL_ActivityAuraController RemoveCam(String jsonModel) {
    HL_ActivityAuraController model = deserializeModel(jsonModel);

    if (!String.isBlank(model.DelId)) {
      for (Integer i = 0; i < model.RelatedCampaigns.size(); i++) {
        if (model.RelatedCampaigns[i].Id == model.DelId) {
          model.RelatedCampaigns.remove(i);
          break;
        }
      }
    }

    return model;
  }

  //For Internal Events - We only want Internal Contacts
  //For All Others - We only want External Contacts
  @AuraEnabled
  public static HL_ActivityAuraController OnActivityTypeChanged(
    String jsonModel
  ) {
    HL_ActivityAuraController model = deserializeModel(jsonModel);

    //Validate Access if Internal is Selected
    if (
      model.Activity.Type == 'Internal' ||
      model.Activity.Type == 'Internal Mentor Meeting'
    ) {
      if (!model.HasInternalAccess && !model.hasMentorActivityAccess) {
        model.Activity.Type = 'Meeting';
        return model;
      }
    }

    String recordTypeToRemove = model.Activity.Type == 'Internal'
      ? 'External_Contact'
      : 'Houlihan_Employee';
    if (model.Activity.Type == 'Internal Mentor Meeting') {
      model.RelatedContacts.clear();
      List<Contact> cList = new List<Contact>();
      Contact c = HL_Contact.GetById(model.WhoId);
      if (c != null) {
        if (
          c.RecordType.DeveloperName == 'HOULIHAN_EMPLOYEE' &&
          model.hasMentorActivityAccess
        ) {
          cList.Add(c);
          model.Activity.Primary_External_Contact_Id__c = c.Id;
          model.Activity.Primary_External_Contact_Company_Id__c = c.Account.Id;
        }
      }

      for (Contact c1 : cList) {
        model.relatedContacts.add(
          new SelectedContact(
            c1,
            model.Activity.Primary_External_Contact_Id__c == c1.Id
          )
        );
      }

      model.HLEmployees.clear();
      List<Contact> cHLList = new List<Contact>();
      Contact c2 = HL_Contact.GetByUserId(UserInfo.getUserId());
      if (c2 <> null) {
        cHLList.Add(c2);
        model.Activity.Primary_Attendee_Id__c = cHLList[0].Id;
      }
      for (Contact c3 : cHLList) {
        model.hlEmployees.Add(
          new SelectedEmployee(
            c3,
            model.Activity.Primary_Attendee_Id__c == c3.Id
          )
        );
      }
    } else {
      Integer i = 0;
      while (i < model.RelatedContacts.size()) {
        if (
          model.RelatedContacts[i].Contact.RecordType.DeveloperName ==
          recordTypeToRemove
        )
          model.RelatedContacts.remove(i);
        else
          i++;
      }
    }

    return model;
  }

  public class SelectedEmployee {
    @AuraEnabled
    public Contact Employee { get; set; }
    @AuraEnabled
    public Boolean Primary { get; set; }

    @AuraEnabled
    public String employeeName {
      get {
        return Employee?.Name;
      }
      private set;
    }

    @AuraEnabled
    public String employeeTitle {
      get {
        return Employee?.Title;
      }
      private set;
    }

    @AuraEnabled
    public String employeeEmail {
      get {
        return Employee?.Email;
      }
      private set;
    }

    @AuraEnabled
    public String employeePhone {
      get {
        return Employee?.Phone;
      }
      private set;
    }

    public SelectedEmployee(Contact c, Boolean isPrimary) {
      Employee = c;
      Primary = isPrimary;
    }
  }

  public class SelectedContact {
    @AuraEnabled
    public Contact Contact { get; set; }
    @AuraEnabled
    public Boolean Primary { get; set; }

    @AuraEnabled
    public String contactId {
      get {
        return Contact.Id;
      }
      private set;
    }

    @AuraEnabled
    public String contactName {
      get {
        return Contact.Name;
      }
      private set;
    }

    @AuraEnabled
    public String accountName {
      get {
        return Contact?.Account?.Name;
      }
      private set;
    }

    @AuraEnabled
    public String contactTitle {
      get {
        return Contact.Title;
      }
      private set;
    }

    @AuraEnabled
    public String contactEmail {
      get {
        return Contact?.Email;
      }
      private set;
    }

    @AuraEnabled
    public String contactPhone {
      get {
        return Contact.Phone;
      }
      private set;
    }

    @AuraEnabled
    public String contactMobilePhone {
      get {
        return Contact?.MobilePhone;
      }
      private set;
    }

    public SelectedContact(Contact c, Boolean isPrimary) {
      Contact = c;
      Primary = isPrimary;
    }
  }

  public static List<Id> GetWhatRelations(Id eventId) {
    List<Id> whatRelations = new List<Id>();
    for (Event e : [
      SELECT WhatId
      FROM Event
      WHERE Id = :eventId OR (ParentId__c != NULL AND ParentId__c = :eventId)
    ])
      whatRelations.add(e.WhatId);
    return whatRelations;
  }

  public static List<Id> GetWhoInternalRelations(Id eventId) {
    List<Id> whoRelations = new List<Id>();
    for (Event e : [
      SELECT WhoId
      FROM Event
      WHERE
        ParentId__c = :eventId
        AND Contact__r.RecordType.DeveloperName = 'Houlihan_Employee'
        AND Mask_As_External__c = FALSE
    ])
      whoRelations.add(e.WhoId);
    return whoRelations;
  }

  public static List<Id> GetWhoExternalRelations(Id eventId) {
    List<Id> whoRelations = new List<Id>();
    for (Event e : [
      SELECT WhoId
      FROM Event
      WHERE
        ParentId__c = :eventId
        AND (Contact__r.RecordType.DeveloperName = 'External_Contact'
        OR Mask_As_External__c = TRUE)
    ])
      whoRelations.add(e.WhoId);
    return whoRelations;
  }

  public static void DeleteRecord(String id) {
    List<Event> eventList = [
      SELECT Id
      FROM Event
      WHERE Id = :id OR (ParentId__c != NULL AND ParentId__c = :id)
    ];
    delete eventList;
  }
}