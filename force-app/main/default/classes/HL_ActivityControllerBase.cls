public virtual class HL_ActivityControllerBase {
    public Contact UserContactRecord {
        get {
            if (userContactRecord == null)
                userContactRecord = HL_Contact.GetByUserId();

            return userContactRecord;
        }
        set;
    }

    public Boolean HasInternalSupervisorAccess {
        get {
            if (hasInternalSupervisorAccess == null)
                hasInternalSupervisorAccess = HL_SecurityUtility.IsSysAdmin() || HL_Group.IsInGroup('Activity_Internal_Supervisor_Access');

            return HasInternalSupervisorAccess;
        }
        set;
    }

    public Boolean HasInternalAccess {
        get {
            if (hasInternalAccess == null)
                hasInternalAccess = HL_SecurityUtility.IsSysAdmin() || HL_Group.IsInGroup('Activity_Internal_Supervisor_Access') || HL_Group.IsInGroup('Activity_Internal_Access');

            return hasInternalAccess;
        }
        set;
    }

    public Boolean hasMentorActivityAccess {
        get {
            if (hasMentorActivityAccess == null)
                hasMentorActivityAccess = HL_SecurityUtility.IsSysAdmin() || HL_Group.IsInGroup('Mentor_Activity_Access');
            return hasMentorActivityAccess;
        }
        set;
    }

    public Id EntityId {
        get {
            if (String.isBlank(entityId))
                entityId = userInfo.getUserId();
            return entityId;
        }
        set;
    }

    public String EntityType {
        get {
            return !String.isBlank(EntityId) ? HL_Utility.GetObjectTypeById(EntityId) : '';
        }
    }

    public String RetEntity {
        get {
            return EntityType == 'User' ? '/' : EntityId;
        }
    }

    public Set<Id> Supervisors {
        get {
            if (supervisors == null) {
                supervisors = new Set<Id> ();
                //Get the Supervisors to provide appropriate view/edit rights
                for (Delegate_Public_Group__c dpg: HL_DelegatePublicGroup.GetSupervisors())
                    supervisors.add(dpg.Banker__c);
            }
            return supervisors;
        }
        set;
    }

    //For Companies(Accounts) We Want to use what_id, for Contacts use who_id
    public PageReference NewActivity() {
        PageReference result = new PageReference('/apex/HL_ActivityEvent?' + (HL_Utility.GetObjectTypeById(EntityId) == 'Account' ? 'what_id=' : 'who_id=') + EntityId + '&retURL=' + EntityId);
        return result;
    }

    public PageReference EditRecord() {
        string url = '/apex/HL_ActivityEvent?id=' + EntityId;
        if (!String.isBlank(HL_PageUtility.GetParameter('retURL')))
            url = url + '&retURL=' + HL_PageUtility.GetParameter('retURL');
        PageReference result = new PageReference(url);
        result.setRedirect(true);
        return result;

    }

    public PageReference EditRecordOutlook() {
        string url = '/apex/HL_ActivityEventOutlook?id=' + EntityId;
        if (!String.isBlank(HL_PageUtility.GetParameter('retURL')))
            url = url + '&retURL=' + HL_PageUtility.GetParameter('retURL');
        PageReference result = new PageReference(url);
        result.setRedirect(true);
        return result;

    }

    public HL_Activity CreateActivityFromEvent(Id contactId,Contact c,Id UserId, Event e, Map<Id, Contact> primaryAttendeeMap, Set<Id> attendeeContactIdSet, Set<Id> menteeContactIdSet) {
        HL_Activity a = new HL_Activity();
       // Contact c = HL_Contact.GetByUserId(UserId);
        Contact primaryAttendee = primaryAttendeeMap.Get(e.Primary_Attendee_Id__c);
        Id internalRecordTypeAccess;
        if (attendeeContactIdSet == null)
            attendeeContactIdSet = new Set<Id> ();
        if (HasInternalSupervisorAccess) {
            Schema.RecordTypeInfo internalRecordTypeInfo = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Internal ' + UserContactRecord.Line_of_Business__c);
            if (internalRecordTypeInfo != null)
                internalRecordTypeAccess = internalRecordTypeInfo.getRecordTypeId();
        }

        a.Activity = e;
        a.ActivityDate = e.StartDateTime;
        a.MessageDate = a.ActivityDate.format();
        a.ModifyAccess = contactId == e.Primary_Attendee_Id__c ||
            userId == e.CreatedById ||
            Supervisors.contains(e.CreatedById) ||
            (!e.Private__c && e.Type<>'Internal' && attendeeContactIdSet.contains(contactId)) ||
            (primaryAttendee != null && this.Supervisors.contains(primaryAttendee.User__c)) ||
            (internalRecordTypeAccess != null && e.RecordTypeId == internalRecordTypeAccess);
        a.ViewAccess = a.ModifyAccess || attendeeContactIdSet.contains(contactId) || (a.Activity.PFG__c && c.Industry_Group__c == 'PFG - Private Funds Group');
        a.PrimaryAttendee = e.Primary_Attendee__c == null ? e.CreatedBy.Name : e.Primary_Attendee__c;
        a.PrimaryContactId = e.Primary_External_Contact_Id__c;
        a.PrimaryContact = e.Primary_External_Contact__c;
        a.LinkId = e.ParentId__c == null ? e.Id : e.ParentId__c;
        if (e.Type == 'Internal Mentor Meeting') {
            a.ModifyAccess = (attendeeContactIdSet.contains(contactId) && HL_Group.IsInGroup('Mentor_Activity_Access'));
            a.ViewAccess = a.ModifyAccess || HL_Group.IsInGroup('Mentor_Activity_Access') || (menteeContactIdSet != null && menteeContactIdSet.contains(contactId));
        }
  
        return a;
    }
    /* 
     private Boolean HasLOBSupervisor(string lob) {
         Boolean result = false;
         List<User> supervisorList = new List<User>();

         for (Id id : this.Supervisors)
             supervisorList.add(new User(Id = id));

         List<Contact> supervisorContactList = HL_Contact.GetListByUsers(supervisorList);

         for (Contact s : supervisorContactList) {
             if (s.Line_of_Business__c == lob) {
                 result = true;
                 break;
             }
         }

         return result;
     } */
    public HL_Activity CreateActivityFromTask(Task t) {
        system.debug('==task=='+t);
        
        HL_Activity a = new HL_Activity();
        a.Subject = t.Subject;
        a.isTask = true;
        a.Task = t;
        a.type = t.TaskSubtype;
        DateTime DT;
        
        if(t.Start_Date__c<>null){
            Integer d = t.Start_Date__c.day();
            Integer mo = t.Start_Date__c.month();
            Integer yr = t.Start_Date__c.year();
            DT = DateTime.newInstance(yr, mo, d);
            
        }else if(t.ActivityDate<>null){
            Integer d = t.ActivityDate.day();
            Integer mo = t.ActivityDate.month();
            Integer yr = t.ActivityDate.year();
            DT = DateTime.newInstance(yr, mo, d);
        }
        
        if(DT<>null){
            DT.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            a.MessageDate = DT.format();
        }
        a.ActivityDate = t.Start_Date__c<>null?t.Start_Date__c:system.today();
        a.PrimaryAttendee = t.Primary_Attendee__c == null ? t.CreatedBy.Name : t.Primary_Attendee__c;
        a.PrimaryContact = t.who.name;
        a.PrimaryContactId = t.whoId;
        a.LinkId = t.Id;
        a.Description = t.Description;
    
        return a;
    }
    public HL_Activity CreateActivityFromActivityHistory(EmailMessage EmailMessage, Task t, Map<Id, ActivityHistory> mapActivityHistory, Map<Id, String> mapActivityWithEmailDesc, Map<string, Contact> mapPrimaryContact) {
        HL_Activity a = new HL_Activity();
        a.isTask = true;
       
        if (t != null && mapActivityHistory != null && mapActivityHistory.get(t.Id) != null && mapActivityHistory.get(t.Id).ActivityDate != null) {
            a.ActivityDate = mapActivityHistory.get(t.Id).ActivityDate;
        } else if (t != null) {
            a.ActivityDate = t.ActivityDate;
        }
        if (t != null && mapActivityHistory != null && mapActivityHistory.get(t.Id) != null && mapActivityHistory.get(t.Id).Subject != null) {
            a.Subject = mapActivityHistory.get(t.Id).Subject;
        } else if (t != null) {
            a.Subject = t.Subject;
        }
        if (t != null && mapActivityHistory != null && mapActivityHistory.get(t.Id) != null && mapActivityHistory.get(t.Id).ActivitySubtype != null) {
            a.type = mapActivityHistory.get(t.Id).ActivitySubtype;
        } else if (t != null) {
            a.type = t.TaskSubtype;
        }
        a.LinkId = EmailMessage.Id;
        if(a.Subject==null){
        a.Subject=EmailMessage.subject;
        }

        if (t != null)
        a.Description = mapActivityWithEmailDesc.get(t.Id);
        if(a.Description==null){
        a.Description=EmailMessage.TextBody;
        }
        if(a.type=='' || a.type==null){a.type='Email';}
        if (EmailMessage.MessageDate != null) {
            //if (a.ActivityDate != null){
                a.ActivityDate = EmailMessage.MessageDate;
                a.MessageDate = a.ActivityDate.format();
                //}
            String toAddress = EmailMessage.ToAddress;
             String CcAddress =EmailMessage.CcAddress;
            String[] contactEmail = new String[] {};
            String[] toEmailAddress = new String[] {};
            if (EmailMessage != null && EmailMessage.FromAddress != null)
            contactEmail.add(EmailMessage.FromAddress);
            if(toAddress!= null )
            toEmailAddress = toAddress.split(';');
            if(CcAddress != null )
            toEmailAddress.addAll(CcAddress.split(';'));
            contactEmail.addAll(toEmailAddress);
            if(EmailMessage!= null && EmailMessage.BccAddress!= null)
            contactEmail.addAll(EmailMessage.BccAddress.split(';'));
                 if(EmailMessage.Id=='02s6e00000zDO3MAAW'){
                  system.debug('contactEmail....'+contactEmail);
                  system.debug('mapPrimaryContact....'+mapPrimaryContact);
                }
            for (String email: contactEmail) {
                email = email.trim();
               
                if (!email.toLowerCase().contains('hl.com') && a.PrimaryContact == null && a.PrimaryContactId == null) {
                    if (mapPrimaryContact != null && mapPrimaryContact.get(email.toLowerCase()) != null) {
                        a.PrimaryContact = mapPrimaryContact.get(email.toLowerCase()).name;
                        a.PrimaryContactId = mapPrimaryContact.get(email.toLowerCase()).Id;

                    }
                } else if (email.toLowerCase().contains('hl.com') && a.PrimaryAttendee == null) {
                    if (mapPrimaryContact != null && mapPrimaryContact.get(email.toLowerCase()) != null) {
                        system.debug(mapPrimaryContact.get(email.toLowerCase()).Id + 'email....' + email);
                        a.PrimaryAttendee = mapPrimaryContact.get(email.toLowerCase()).name;
                    }
                }

            }
        }

        return a;
    }
    public HL_Activity CreateActivityFromOpenActivity(EmailMessage EmailMessage, Task t, Map<Id, OpenActivity> mapOpenActivity, Map<Id, String> mapActivityWithEmailDesc, Map<string, Contact> mapPrimaryContact) {
        HL_Activity a = new HL_Activity();
        a.isTask = true;
        if (mapOpenActivity != null && mapOpenActivity.get(t.Id) != null && mapOpenActivity.get(t.Id).ActivityDate != null) {
            a.ActivityDate = mapOpenActivity.get(t.Id).ActivityDate;
        } else {
            a.ActivityDate = t.ActivityDate;
        }
        if (mapOpenActivity != null && mapOpenActivity.get(t.Id) != null && mapOpenActivity.get(t.Id).Subject != null) {
            a.Subject = mapOpenActivity.get(t.Id).Subject;
        } else {
            a.Subject = t.Subject;
        }
        if (mapOpenActivity != null && mapOpenActivity.get(t.Id) != null && mapOpenActivity.get(t.Id).ActivitySubtype != null) {
            a.type = mapOpenActivity.get(t.Id).ActivitySubtype;
        } else {
            a.type = t.TaskSubtype;
        }

        a.LinkId = EmailMessage.Id;
         if(a.Subject==null){
        a.Subject=EmailMessage.subject;
        }
        a.Description = mapActivityWithEmailDesc.get(t.Id);
        if(a.Description==null){
        a.Description=EmailMessage.TextBody;
        }
        if(a.type=='' || a.type==null){a.type='Email';}
        if (EmailMessage.MessageDate != null) {
            a.ActivityDate = EmailMessage.MessageDate;
            a.MessageDate = EmailMessage.MessageDate.format();
            String toAddress = EmailMessage.ToAddress;
            String CcAddress =EmailMessage.CcAddress;
            String[] contactEmail = new String[] {};
            String[] toEmailAddress = new String[] {};
            if (EmailMessage != null && EmailMessage.FromAddress != null)
                contactEmail.add(EmailMessage.FromAddress);
                if(toAddress!= null )
            toEmailAddress = toAddress.split(';');
                  if(CcAddress != null )
            toEmailAddress.addAll(CcAddress .split(';'));
            contactEmail.addAll(toEmailAddress);
            if(EmailMessage!= null && EmailMessage.BccAddress!= null)
            contactEmail.addAll(EmailMessage.BccAddress.split(';'));

            for (String email: contactEmail) {
                email = email.trim();
                if (!email.toLowerCase().contains('hl.com') && a.PrimaryContact == null && a.PrimaryContactId == null) {
                    if (mapPrimaryContact != null && mapPrimaryContact.get(email.toLowerCase()) != null) {
                        a.PrimaryContact = mapPrimaryContact.get(email.toLowerCase()).name;
                        a.PrimaryContactId = mapPrimaryContact.get(email.toLowerCase()).Id;

                    }
                }
                if (email.toLowerCase().contains('hl.com') && a.PrimaryAttendee == null) {
                    if (mapPrimaryContact != null && mapPrimaryContact.get(email.toLowerCase()) != null) {

                        a.PrimaryAttendee = mapPrimaryContact.get(email.toLowerCase()).name;
                    }
                }

            }

        }
               return a;
    }
    public HL_Activity CreateActivityFromEmailMessage(EmailMessage EmailMessage, Map<string, Contact> mapPrimaryContact) {
        HL_Activity a = new HL_Activity();
        a.isTask = true;
        a.LinkId = EmailMessage.Id;
        a.Description = EmailMessage.TextBody;
        a.type = 'Email';
        
        if (EmailMessage.Subject != null)
            a.Subject = EmailMessage.Subject;
        if (EmailMessage.MessageDate != null) {
            a.ActivityDate = EmailMessage.MessageDate;
            a.MessageDate = EmailMessage.MessageDate.format();
            }
            String toAddress = EmailMessage.ToAddress;
            String CcAddress =EmailMessage.CcAddress;
            String[] contactEmail = new String[] {};
            String[] toEmailAddress = new String[] {};
           
        
            
            if (EmailMessage != null && EmailMessage.FromAddress != null)
                contactEmail.add(EmailMessage.FromAddress);
                if(toAddress!= null )
            toEmailAddress = toAddress.split(';');
                if(CcAddress != null )
            toEmailAddress.addAll(CcAddress .split(';'));
            contactEmail.addAll(toEmailAddress);
            for (String email: contactEmail) {
                email = email.trim();
                if (!email.toLowerCase().contains('hl.com') && a.PrimaryContact == null && a.PrimaryContactId == null) {
                    if (mapPrimaryContact != null && mapPrimaryContact.get(email.toLowerCase()) != null) {
                        a.PrimaryContact = mapPrimaryContact.get(email.toLowerCase()).name;
                        a.PrimaryContactId = mapPrimaryContact.get(email.toLowerCase()).Id;

                    }
                }
                if (email.toLowerCase().contains('hl.com') && a.PrimaryAttendee == null) {
                    if (mapPrimaryContact != null && mapPrimaryContact.get(email.toLowerCase()) != null) {

                        a.PrimaryAttendee = mapPrimaryContact.get(email.toLowerCase()).name;
                    }
                }

            

        }
     
        return a;
    }
}