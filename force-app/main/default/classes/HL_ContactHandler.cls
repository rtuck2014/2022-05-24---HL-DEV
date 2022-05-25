/*
* Name: HL_ContactHandler
* Created Date: 9/20/2016
* Description: Apex Handler class for Contact object
* Modified Date: 11/04/2019
* Description:  Added the following methods for ERP Integration. The new methods are invoked from OnAfterUpdate method.
*   a) updateContactInfoInAccount()
*/

public with sharing class HL_ContactHandler {
    private static List<Account> ctAccountList;
    private static List<RecordType> recordTypeList;

    static {
        ctAccountList = [
            SELECT Id, Name 
            FROM Account 
            WHERE Name = 'Contacts in Transition' 
            LIMIT 1
        ];

        recordTypeList = [
            SELECT Id 
            FROM RecordType 
            WHERE RecordType.DeveloperName = 'External_Contact' 
            LIMIT 1
        ];
    }

    private boolean isExecuting = false;
    private integer batchSize = 0;

    public HL_ContactHandler(boolean isExecuting, integer size) {
        this.isExecuting = isExecuting;
        this.batchSize = size;
    }
    public HL_ContactHandler(){}

    public void OnAfterInsert(Map<Id, Contact> newContactMap) {
        this.CreateUpdateAffiliation(new Map<Id, Contact>(), newContactMap);
        this.UpdateRivaLinkObjects(newContactMap);
    }

    public void OnAfterUpdate(Map<Id, Contact> oldContactMap, Map<Id, Contact> newContactMap, List<Contact> contactList) {
        this.CreateUpdateAffiliation(oldContactMap, newContactMap);        
        this.CascadeConName(contactList, oldContactMap);
        if(HL_ConstantsUtil.IsSupervisorOrAdmin()) {
            this.PopulateEndDateonVpPositionTM(oldContactMap, newContactMap);        
            Monthly_Revenue_Process_Control__c  MRPC = new Monthly_Revenue_Process_Control__c();
            MRPC = HL_Eng_VP_PositionTriggerHelper.fetchMRPC();  
            IF(MRPC != null){                
                this.PopulateEndDateonVpPositionTMEng(oldContactMap, newContactMap, MRPC);                
            }
        }
        this.CreateAlumniContact(oldContactMap, newContactMap, contactList);
        //Check for Email Changes
        Map<Id, Contact> emailChangeMap = this.GetEmailChangeMap(oldContactMap, newContactMap);
        if (emailChangeMap.size() > 0)
            this.UpdateRivaLinkObjects(emailChangeMap);     
            
        //Check if contact is a primary billing contact for an account
        updateContactInfoInAccount(contactList, newContactMap, oldContactMap);
    }

    public void OnAfterDelete(Map<Id, Contact> oldContactMap) {
        this.HandleMergeScenarios(oldContactMap);
    }

    private void HandleMergeScenarios(Map<Id, Contact> oldContactMap){
        MergedData mergedData = this.GetMergedData(oldContactMap);
        this.CreateMergeAffiliations(mergedData);
        this.UpdateEventRecords(mergedData);
    }

    //Handle merge of Contacts to Properly Create the Affiliation when it is a move to a new Company
    private List<Affiliation__c> CreateMergeAffiliations(MergedData mergedData) {
        List<Affiliation__c> affiliationInsertList = new List<Affiliation__c>();

        if (mergedData.MergedContactMap.size() > 0)
        {
            List<Contact> contactList = [SELECT AccountId FROM Contact WHERE Id IN: mergedData.MasterIdToMergedIdsMap.keyset()];
            for (Contact c : contactList) 
            {
                for (Contact mergedContact : mergedData.MergedContactMap.values()) 
                {
                    //If the Account Ids are Different, we want to Create the Affiliation Record
                    if (mergedContact.MasterRecordId == c.Id && mergedContact.AccountId != c.AccountId) {
                        affiliationInsertList.add(new Affiliation__c(Account__c = mergedContact.AccountId,
                                                  Contact__c = c.Id, Title__c = mergedContact.Title,
                                                  Type__c = 'Former Employee', Status__c = 'Former', End_Date__c = Date.today(),
                                                  Start_Date__c = mergedContact.CreatedDate.date()));
                    }
                }
            }

            if (affiliationInsertList.size() > 0)
                insert affiliationInsertList;
        }

        return affiliationInsertList;
    }

    @future
    public static void SyncAccountAddressToContact(Set<Id> acctIds){
        List<Contact> contactToUpdate = new List<Contact>();
        Map<Id, Account> acctRecs = GetRelatedAccounts(acctIds);
        
        for(Contact c : [SELECT Id, AccountId, MailingStreet, MailingCity, MailingState,  MailingPostalCode, MailingCountry,Inherit_Company_Address__c
                        FROM Contact 
                        WHERE AccountId IN: acctIds]){
            if(acctRecs.containsKey(c.AccountId) && c.Inherit_Company_Address__c){
                Account a = acctRecs.get(c.AccountId);
                if(c.MailingStreet != a.BillingStreet || 
                    c.MailingCity != a.BillingCity || 
                    c.MailingState != a.BillingState || 
                    c.MailingPostalCode != a.BillingPostalCode || 
                    c.MailingCountry != a.BillingCountry){

        contactToUpdate.add(new Contact(Id = c.Id, 
                                        MailingStreet = a.BillingStreet,
                                        MailingCity = a.BillingCity,
                                        MailingState = a.BillingState,
                                        MailingPostalCode = a.BillingPostalCode,
                                        MailingCountry = a.BillingCountry));
                }
               
               
            }
                        }

        if(!contactToUpdate.isEmpty()){
            Database.update(contactToUpdate, false);
        }
    }

    public static Map<Id, Account> GetRelatedAccounts(Set<Id> lstAcctIds){
        Map<Id, Account> relAccounts = new Map<Id, Account>();

        for(Account a : [SELECT Id, BillingStreet, BillingCity, BillingState,  BillingPostalCode, BillingCountry
                        FROM Account WHERE Id IN: lstAcctIds ]){
                            relAccounts.put(a.Id, a);    
                        }
        return relAccounts;
    }

    //Handle Merge of Contacts to Update the Event Records
    private List<Event> UpdateEventRecords(MergedData mergedData) {
        List<Event> eventUpdateList = new List<Event>();

        if (mergedData.MergedContactMap.size() > 0) {
            List<Event> eventList = [SELECT Primary_External_Contact_Id__c,
                            Primary_External_Contact__c,
                            Primary_External_Contact_Company_Id__c,
                            Primary_Attendee_Id__c,
                            Primary_Attendee__c
                            FROM Event
                            WHERE Primary_External_Contact_Id__c IN: mergedData.MergedContactMap.keySet()
                                OR Primary_Attendee_Id__c IN: mergedData.MergedContactMap.keySet()];
            
            for (Event e : eventList) 
            {

                Contact externalMasterContact = mergedData.MergedIdToNewContactMap.get(e.Primary_External_Contact_Id__c);
                Contact internalMasterContact = mergedData.MergedIdToNewContactMap.get(e.Primary_Attendee_Id__c);

                if (externalMasterContact != null) {
                    e.Primary_External_Contact_Id__c = externalMasterContact.Id;
                    e.Primary_External_Contact__c = externalMasterContact.Name;
                    e.Primary_External_Contact_Company_Id__c = externalMasterContact.AccountId;
                }

                if (internalMasterContact != null) {
                    e.Primary_Attendee_Id__c = internalMasterContact.Id;
                    e.Primary_Attendee__c = internalMasterContact.Name;
                }

                if (externalMasterContact != null || internalMasterContact != null)
                    eventUpdateList.add(e);
            }
        }

        if (eventUpdateList.size() > 0)
            update eventUpdateList;

        return eventUpdateList;
    }

    private MergedData GetMergedData(Map<Id, Contact> oldContactMap) {
        MergedData mergedData = new MergedData();

        for (Contact c : oldContactMap.values()) {
            if (!String.isBlank(c.MasterRecordId)) {
                if (mergedData.MasterIdToMergedIdsMap.get(c.MasterRecordId) == null)
                    mergedData.MasterIdToMergedIdsMap.put(c.MasterRecordId, new Set<Id> {c.Id});
                else {
                    Set<Id> mergedIdSet = mergedData.MasterIdToMergedIdsMap.get(c.MasterRecordId);
                    mergedIdSet.add(c.Id);
                    mergedData.MasterIdToMergedIdsMap.put(c.MasterRecordId, mergedIdSet);
                }

                mergedData.MergedContactMap.put(c.Id, c);
            }
        }

        //Create a Map of Merged Contact Id to New Contact, The New Contact Must be Queried for as we need other Contact Fields from the Record
        List<Contact> contactList = [SELECT AccountId, Name FROM Contact WHERE Id IN: mergedData.MasterIdToMergedIdsMap.keySet()];
        for (Contact c : contactList) 
        {
            Set<Id> mergedIdSet = mergedData.MasterIdToMergedIdsMap.get(c.Id);
            for (Id mergedId : mergedIdSet)
                mergedData.MergedIdToNewContactMap.put(mergedId, c);
        }

        return mergedData;
    }

    private Map<Id, Contact> GetEmailChangeMap(Map<Id, Contact> oldContactMap, Map<Id, Contact> newContactMap) {
        //Check for Email Changes
        Map<Id, Contact> emailChangeMap = new Map<Id, Contact>();

        for (Contact c : newContactMap.values()) {
            if (!String.isBlank(c.Email) && c.Email <> oldContactMap.get(c.Id).Email)
                emailChangeMap.put(c.Id, c);
        }

        return emailChangeMap;
    }

    public void CascadeConName(List<Contact> conToCascadeList, Map<Id, Contact> oldContactMap) {
        Set<Id> conIdSet = new Set<Id>();
        for (Contact con : conToCascadeList) {
            if (con.FirstName != oldContactMap.get(con.Id).FirstName || con.LastName != oldContactMap.get(con.Id).LastName)
                conIdSet.add(con.Id);
        }

        if (!conIdSet.isEmpty()) {
            List<Offsite_Template_Coverage_Contact__c> offsiteUpdateList = new List<Offsite_Template_Coverage_Contact__c>();

            List<Offsite_Template_Coverage_Contact__c> otccList = [SELECT Id, Contact_Name__c, Coverage_Contact__r.Coverage_Contact__r.FirstName, Coverage_Contact__r.Coverage_Contact__r.LastName FROM Offsite_Template_Coverage_Contact__c WHERE Coverage_Contact__r.Coverage_Contact__c IN: conIdSet];
            for (Offsite_Template_Coverage_Contact__c otcc : otccList) 
            {
                otcc.Contact_Name__c = otcc.Coverage_Contact__r.Coverage_Contact__r.FirstName + ' ' + otcc.Coverage_Contact__r.Coverage_Contact__r.LastName;
                offsiteUpdateList.add(otcc);
            }

            if (!offsiteUpdateList.isEmpty())
                update offsiteUpdateList;
        }
    }

    private void CreateUpdateAffiliation(Map<Id, Contact> oldContactMap, Map<Id, Contact> newContactMap) {
        List<Affiliation__c> affiliationList = new List<Affiliation__c>();//List of Affiliation__c to create and update
        Map<Id, Date> contactIdToAffiliationEndDateMap = new Map<Id, Date>(); //Map of contact id to Affiliation__c end date where status is former
        Map<Id, Contact> filteredContactMap = new Map<Id, Contact>();//map of filtered contact
        Set<Id> contactIdHavingAffiliationSet = new Set<Id>();//set of contact ids which is having atleast one Affiliation__c record whose status is current

        // GM Jan 6, 2022 - this implementation causes too many SOQL queries, moved to static initialization at top of class
        //List<RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'External_Contact' LIMIT 1];

        String recordTypeId = (!recordTypeList.isEmpty()) ? recordTypeList[0].Id : '';

        //Iterating on Affiliation__c for getting the latest former Affiliation__c end date if exist
        List<Affiliation__c> objAffiliationList = [SELECT Id,
                                              End_Date__c,
                                              Contact__c
                                              FROM Affiliation__c
                                              WHERE Status__c = 'Former'
                                                      AND Contact__c IN: newContactMap.keySet()
                                                      AND End_Date__c != null
                                                      ORDER BY End_Date__c DESC];
        
        for (Affiliation__c objAffiliation : objAffiliationList)
        {
                contactIdToAffiliationEndDateMap.put(objAffiliation.Contact__c, objAffiliation.End_Date__c);
        }

        //Iterating on contact whose account id is changed and creating new Affiliation__c records.
        for (Contact objContact : newContactMap.values()) {
            if (!oldContactMap.isEmpty() && !contactIdHavingAffiliationSet.contains(objContact.Id)
                    && oldContactMap.get(objContact.Id).AccountId != null && objContact.RecordTypeId == recordTypeId
                    && oldContactMap.get(objContact.Id).AccountId != objContact.AccountId) {
                affiliationList.add(new Affiliation__c(Account__c = oldContactMap.get(objContact.Id).AccountId,
                                                       Contact__c = objContact.Id, Title__c = objContact.Title,
                                                       Type__c = 'Former Employee', Status__c = 'Former', End_Date__c = Date.today(),
                                                       Start_Date__c = contactIdToAffiliationEndDateMap.containsKey(objContact.Id)
                                                               ? contactIdToAffiliationEndDateMap.get(objContact.Id)
                                                               : objContact.CreatedDate.date()));
            }
        }

        if (!affiliationList.isEmpty())
            upsert affiliationList;
    }

    //When a new contact is inserted, if it has been part of our activity sync (which is based on email)
    //We want to update the Riva middle object so that the contact gets linked back to the activity
    private void UpdateRivaLinkObjects(Map<Id, Contact> contactMap) {
        List<Activity_Link__c> linkUpdateList = new List<Activity_Link__c>();

        //Create a Map of Email to Contact Id
        Map<String, Id> emailMap = new Map<String, Id>();
        for (Contact c : contactMap.values()) {
            if (!String.isBlank(c.Email))
                emailMap.put(c.Email, c.Id);
        }

        //Get a list of Matching Riva Activity Link Records
        List<Activity_Link__c> alList = [SELECT ContactId__c, Email__c FROM Activity_Link__c WHERE ContactId__c = null AND Email__c IN: emailMap.keySet()];
        for (Activity_Link__c al : alList) 
        {
            al.ContactId__c = emailMap.get(al.Email__c);
            linkUpdateList.add(al);
        }

        if (linkUpdateList.size() > 0)
            update linkUpdateList;

    }

    public void GeoLocationContactUpdate(Map<Id, Contact> oldContactMap, Map<Id, Contact> newContact, Boolean isInsert) {
        List<id> contactIdList = new List<Id>();
        //check if Mailing Address has been updated
        Boolean addressChangedFlag = false;
        for (Contact contact : newContact.Values()) {
            if (!isInsert) {
                Contact oldContact = oldContactMap.get(contact.Id);
                if ((contact.MailingStreet != oldContact.MailingStreet) || (contact.MailingCity != oldContact.MailingStreet) ||
                        (contact.MailingCountry != oldContact.MailingCountry) ||
                        (contact.MailingPostalCode != oldContact.MailingPostalCode)) {
                    addressChangedFlag = true;
                }
            }
            // ifaddress is null or has been changed, geocode it
            if ((contact.Geolocation__Latitude__s == null) || (addressChangedFlag == true)) {
                contactIdList.add(contact.id);
            }
        }

        if (contactIdList.size() > 0) {
            ContactGeocodeAddress.DoAddressGeocode(contactIdList);
        }
    }

    private class MergedData {
        public Map<Id, Contact> MergedContactMap {get; set;}
        public Map<Id, Contact> MergedIdToNewContactMap {get; set;}
        public Map<Id, Set<Id>> MasterIdToMergedIdsMap {get; set;}

        public MergedData() {
            this.MergedContactMap = new Map<Id, Contact>();
            this.MergedIdToNewContactMap = new Map<Id, Contact>();
            this.MasterIdToMergedIdsMap = new Map<Id, Set<Id>>();
        }
    }
  
    //Create Alumni Contact Record when Employee Record's status turns inactive
  private void CreateAlumniContact(Map<Id, Contact> oldContactMap, Map<Id, Contact> newContactMap, List<Contact> newContactList) {
        
    //Initialize & Get necessary Ids     
    Set<string> existingContactSet = new Set<string>();    
        Set<string> lastNamesSet = new Set<string>(); 
    string hlTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Houlihan Employee').getRecordTypeId();
        string externalTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External Contact').getRecordTypeId();

        // GM Jan 6, 2022 - this implementation causes too many SOQL queries, moved to static initialization at top of class
        //List<Account> ctAccountList = [SELECT Id, Name FROM Account WHERE Name = 'Contacts in Transition' Limit 1];

        List<Contact> alumniContacts = new List<Contact>();
        
        if(hlTypeId != null && externalTypeId != null && ctAccountList.size() > 0) {
            
            List<Contact> updatedContactList = new List<Contact>();
      
            //Check relatively small list; usually just 1, to see if there are any status updates for a HL employee record
            for(Contact newContact : newContactList) {

                if(newContact.RecordTypeId == hlTypeId && newContact.Status__c == 'Inactive' && newContact.Status__c != oldContactMap.get(newContact.Id).Status__c) {
                    updatedContactList.add(newContact);
                    lastNamesSet.add(newContact.Legal_Last_Name__c);
                    lastNamesSet.add(newContact.LastName);
                }
            }
            
            //If status update exists
            if(updatedContactList.size() > 0) {
                         
                //Build list of all external contacts 
                //if we running into more than 50K existing contact, we need to rewrite this class to batchable apex. However, the chance of HL has
                //50K former employees is fairly low at the moment. Limiting the result to 50K won't solve the issue because we will potentially get duplication
                List<Contact> existingContactList = [SELECT ID, Name, FirstName, MiddleName, LastName, HL_Alumni__c, HL_Alumni_Contact__c, HL_Alumni_HR_Employee_ID__c FROM Contact 
                                               WHERE RecordTypeId = :externalTypeId AND LastName IN :lastNamesSet];
                for(Contact existingContact : existingContactList) 
                {
                                               
                    //Build Set of External Contact names and HR Alumni Employee Ids - External will not have default Employee Id
                    string HR_Id = (existingContact.HL_Alumni_HR_Employee_ID__c == null ? '' : string.valueOf(existingContact.HL_Alumni_HR_Employee_ID__c));
                    existingContactSet.add(existingContact.FirstName + ' ' + existingContact.MiddleName + ' ' + existingContact.LastName + HR_Id); 
                    existingContactSet.add(existingContact.Name + HR_Id);  
                    
                    //Build list of external contacts that are alumni and were unchecked                              
                    if(existingContact.HL_Alumni_Contact__c != null && existingContact.HL_Alumni__c == false) {                 
                        alumniContacts.add(existingContact);
                    }                               
              }  
                List<Contact> updateContacts = new List<Contact>();
                List<Contact> createContacts = new List<Contact>();
            Contact c;
                
                //Iterate through updated contacts
                for(Contact newContact : updatedContactList) {
          
                    boolean foundMatchingAlumni = false;
                    
                    //Find existing alumni match and check it
                    for(Contact alumni : alumniContacts) {
                        if(alumni.HL_Alumni_Contact__c == newContact.ID) {
                            alumni.HL_Alumni__c = true;
                            updateContacts.add(alumni);
                            foundMatchingAlumni = true;
                        }
                    }
                    
                    if(!foundMatchingAlumni) {

                        string contactFullNameId = '';
                      string contactFullName = '';

                      //List is all employee records - get Employee Id
                      string HR_Id = (newContact.HR_EMPLOYEEID__c == null ? '' : string.valueOf(newContact.HR_EMPLOYEEID__c));
                    
                      //Check if Legal Name exists or use regular name and build key to search set on
                      if(newContact.Legal_First_Name__c != null && newContact.Legal_First_Name__c != '' && newContact.Legal_Last_Name__c != null && newContact.Legal_Last_Name__c != '') {
                          contactFullNameId = newContact.Legal_First_Name__c + ' ' + newContact.Legal_Middle_Name__c + ' ' + newContact.Legal_Last_Name__c + string.valueOf(integer.valueOf(newContact.HR_EMPLOYEEID__c));
                          contactFullName = newContact.Legal_First_Name__c + ' ' + newContact.Legal_Middle_Name__c + ' ' + newContact.Legal_Last_Name__c;
                      }
                      else {
                          contactFullNameId = newContact.FirstName + ' ' + newContact.MiddleName + ' ' + newContact.LastName + string.valueOf(integer.valueOf(newContact.HR_EMPLOYEEID__c));
                          contactFullName = newContact.FirstName + ' ' + newContact.MiddleName + ' ' + newContact.LastName;
                      }
                                      
                      // Check that Legal Name & Legal Name + Employee Id does not exist in External Contact Set already
                      if(existingContactSet.size() == 0 || (!existingContactSet.contains(contactFullName) && !existingContactSet.contains(contactFullNameId) && !existingContactSet.contains(newContact.Name))) {
                          c = new Contact(                   
                              FirstName = newContact.Legal_First_Name__c == null || newContact.Legal_First_Name__c == ''? newContact.FirstName: newContact.Legal_First_Name__c,
                              MiddleName = newContact.Legal_Middle_Name__c == null || newContact.Legal_Middle_Name__c == ''? newContact.MiddleName: newContact.Legal_Middle_Name__c,
                              LastName = newContact.Legal_Last_Name__c == null || newContact.Legal_Last_Name__c == ''? newContact.LastName: newContact.Legal_Last_Name__c,
                              Gender__c = newContact.Gender__c,
                              Birthdate = newContact.Birthdate,
                              AccountId = ctAccountList[0].Id,
                              RecordTypeId = externalTypeId,
                              HL_Alumni__c = true,
                              HL_Alumni_Contact__c = newContact.Id
                          );
                          createContacts.add(c);
            
                          //Add new contact to existing set
                          existingContactSet.add(c.FirstName + ' ' + c.MiddleName + ' ' + c.LastName + HR_Id);  
                      }
                  }
                }
                                      
                if(createContacts.size() > 0) {
                    insert createContacts;    
                }  
                
                if(updateContacts.size() > 0) {
                    update updateContacts;    
                }   
            }
        }
            
    } 
    // To Populate end date on opportunity vp position team member based on deactivating related staff (contact)'s status 
    private void PopulateEndDateonVpPositionTM(Map<Id, Contact> oldContactMap, Map<Id, Contact> newContactMap) {
        
        Set<Id> filteredContactIdSet = new Set<Id>();
        for(Contact cont : newContactMap.values())
        {
            if(cont.Status__c != oldContactMap.get(cont.id).status__c && cont.Status__c == 'Inactive')
            {
                filteredContactIdSet.add(cont.id);
            }
        }
        
        Set<Opp_VP_TeamMember__c> oppVPTeamMembersToUpdate = new Set<Opp_VP_TeamMember__c>();
        List<Opp_VP_TeamMember__c> oppVPTeamMembersToDelete = new list<Opp_VP_TeamMember__c>();
        for(Opp_VP_TeamMember__c oppVPTeamMember : [SELECT Id, End_Date__c, Start_Date__c, staff__c, Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__r.Engagement_Approval_Status__c, 
                                                        Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__r.Converted_to_Engagement__c ,ResultingEngagemnetRTonVPTM__c, Role__c 
                                                    FROM   Opp_VP_TeamMember__c 
                                                    WHERE  Opportunity_VP_Position__r.Status__c != 'Cancelled' 
                                                    AND Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__r.Converted_to_Engagement__c = false  
                                                    AND (Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__r.Approval_Process__c != :label.HL_AppProcessForEngNo  OR ( Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__r.Approval_Process__c = :label.HL_AppProcessForEngNo AND Opportunity_VP_Position__r.Opportunity_VP__r.Opportunity__r.Engagement_Approval_Status__c != :label.HL_Pending_EngReqNo  ))     
                                                    AND ResultingEngagemnetRTonVPTM__c = 'Portfolio_Valuation'                                                   
                                                    AND Staff__c IN : filteredContactIdSet])
        {   
          
            if (oppVPTeamMember != null){     
                if(oppVPTeamMember.End_Date__c == null || oppVPTeamMember.End_Date__c >= date.Today()) 
                   oppVPTeamMember.End_Date__c = date.today(); 
                if(oppVPTeamMember.Start_Date__c <= oppVPTeamMember.End_Date__c)
                {
                    oppVPTeamMembersToUpdate.add(oppVPTeamMember);  
                }               
                else {
                    oppVPTeamMembersToDelete.add(oppVPTeamMember);  
                }
            }
        }
        
        if(oppVPTeamMembersToUpdate.size() > 0)
        {           
            Set<Opp_VP_TeamMember__c> setofRecordsToBeRemoved = new Set<Opp_VP_TeamMember__c>();
            setofRecordsToBeRemoved = removeDuplicateOppVpTMRecrds(oppVPTeamMembersToUpdate);
            oppVPTeamMembersToUpdate.removeAll(setofRecordsToBeRemoved);  
            List<Opp_VP_TeamMember__c> ListOfVPTMs = new List<Opp_VP_TeamMember__c>();
            ListOfVPTMs.addAll(oppVPTeamMembersToUpdate);            
            update ListOfVPTMs; 
        }
        // Deleting those opp position team members who are going to have start date after end date which should not be valid case
        if(oppVPTeamMembersToDelete.size() > 0)
        {   
            delete oppVPTeamMembersToDelete; 
        }
    }  
    
    public static Set<Opp_VP_TeamMember__c> removeDuplicateOppVpTMRecrds(Set<Opp_VP_TeamMember__c> oppVPTeamMembersToUpdate)
    {
        Set<Opp_VP_TeamMember__c> ListofDuplicateData = new Set<Opp_VP_TeamMember__c>();
        
        Map < String, Opp_VP_TeamMember__c > teamMemberUniqueMap = new Map < String, Opp_VP_TeamMember__c > ();
        set < string > userSet = new Set < string > ();
        set < string > roles = new Set < string > ();
        set < Id > parentposition = new Set < Id > ();
        Set < Opp_VP_TeamMember__c > teamMemberstoIgnore = new Set < Opp_VP_TeamMember__c > ();
        for (Opp_VP_TeamMember__c teamMember: oppVPTeamMembersToUpdate) 
        {               

                teamMemberUniqueMap.put((teamMember.Staff__c + '' + teamMember.Role__c + '' + teamMember.Opportunity_VP_Position__c), teamMember);
                userSet.add(teamMember.Staff__c);
                roles.add(teamMember.Role__c);
                parentposition.add(teamMember.Opportunity_VP_Position__c);
                teamMemberstoIgnore.add(teamMember);

        }   
        for (Opp_VP_TeamMember__c teamMember: [ SELECT Staff__c, Role__c, Start_Date__c, End_Date__c, Opportunity_VP_Position__c, Team_Member_Status__c
                                                FROM Opp_VP_TeamMember__c
                                                WHERE Staff__c IN: userSet and Role__c IN: roles and Opportunity_VP_Position__c 
                                                IN: parentposition limit: Limits.getLimitQueryRows()])
        {
            if (teamMemberUniqueMap.containsKey(teamMember.Staff__c + '' + teamMember.Role__c + '' + teamMember.Opportunity_VP_Position__c)) 
            {
                Opp_VP_TeamMember__c duplicateRecord = teamMemberUniqueMap.get(teamMember.Staff__c + '' + teamMember.Role__c + '' + teamMember.Opportunity_VP_Position__c);
                    if(teamMember.Id != duplicateRecord.id){                    
                      if (((duplicateRecord.Start_Date__c <= teamMember.Start_Date__c || duplicateRecord.Start_Date__c <= teamMember.End_Date__c)&& teamMember.Team_Member_Status__c != 'Inactive' ) || 
                        ((duplicateRecord.Start_Date__c < teamMember.Start_Date__c || duplicateRecord.Start_Date__c < teamMember.End_Date__c)&& teamMember.Team_Member_Status__c == 'Inactive' ) ||
                        (duplicateRecord.Start_Date__c > teamMember.Start_Date__c && teamMember.End_Date__c == null ))
                        {
                            
                            ListofDuplicateData.Add(duplicateRecord);
                            
                        }
                   }
            }       
        }
        return ListofDuplicateData;
        
    }
    
    // To Populate end date on Engagement vp position team member based on deactivating related staff (contact)'s status 
    public void PopulateEndDateonVpPositionTMEng(Map<Id, Contact> oldContactMap, Map<Id, Contact> newContactMap,Monthly_Revenue_Process_Control__c MRPC) {
        
        Set<Id> filteredContactIdSet = new Set<Id>();
        for(Contact cont : newContactMap.values())
        {
            System.debug(cont.Status__c);
            System.debug(oldContactMap.get(cont.id).status__c);
            if(cont.Status__c != oldContactMap.get(cont.id).status__c && cont.Status__c == 'Inactive')
            {
                filteredContactIdSet.add(cont.id);
            }
        }        
       
        Set<Eng_VP_TeamMember__c> engVPTeamMembersToUpdate = new Set<Eng_VP_TeamMember__c>();
        List<Eng_VP_TeamMember__c> engVPTeamMembersToDelete = new List<Eng_VP_TeamMember__c>();
        for(Eng_VP_TeamMember__c engVPTeamMember : [SELECT Id, End_Date__c, Start_Date__c,Staff__c,Role__c,Engagement_VP_Position__c, Engagement_VP_Position__r.Revenue_Month__c, Engagement_VP_Position__r.Revenue_Year__c
                                                    FROM   Eng_VP_TeamMember__c 
                                                    WHERE  Engagement_VP_Position__r.Status__c != 'Cancelled' 
                                                    AND Staff__c IN : filteredContactIdSet])
        {
            if(!HL_Eng_VP_PositionTriggerHelper.isRevenueMonthYearPassed(engVPTeamMember.Engagement_VP_Position__r.Revenue_Month__c, engVPTeamMember.Engagement_VP_Position__r.Revenue_Year__c,MRPC)){
                if(engVPTeamMember.End_Date__c == null || engVPTeamMember.End_Date__c >= date.today())
                    engVPTeamMember.End_Date__c = date.today(); 
                if(engVPTeamMember.Start_Date__c <= engVPTeamMember.End_Date__c)
                {
                    engVPTeamMembersToUpdate.add(engVPTeamMember);  
                }
                else {
                    engVPTeamMembersToDelete.add(engVPTeamMember);  
                }
            }
        }
        
        if(engVPTeamMembersToUpdate.size() > 0)
        {
            Set<Eng_VP_TeamMember__c> setofRecordsToBeRemovedEng = new Set<Eng_VP_TeamMember__c>();
            setofRecordsToBeRemovedEng  = removeDuplicateEngVpTMRecrds (engVPTeamMembersToUpdate);
            engVPTeamMembersToUpdate.removeAll(setofRecordsToBeRemovedEng);  
            List<Eng_VP_TeamMember__c> ListOfVPTMs = new List<Eng_VP_TeamMember__c>();
            ListOfVPTMs.addAll(engVPTeamMembersToUpdate);
            update ListOfVPTMs; 
           

        }
        // Deleting those eng position team members who are going to have start date after end date which should not be valid case
        if(engVPTeamMembersToDelete.size() > 0)
        {            
            delete engVPTeamMembersToDelete; 
        }
    }
    public static Set<Eng_VP_TeamMember__c> removeDuplicateEngVpTMRecrds (Set < Eng_VP_TeamMember__c > engVPTeamMembersToUpdate) {
        Set<Eng_VP_TeamMember__c> setofDuplicateData = new Set<Eng_VP_TeamMember__c>();
        Map < String, Eng_VP_TeamMember__c > teamMemberUniqueMap = new Map < String, Eng_VP_TeamMember__c > ();
        set < string > userSet = new Set < string > ();
        set < string > roles = new Set < string > ();
        set < Id > parentposition = new Set < Id > ();
        Set < Eng_VP_TeamMember__c > teamMemberstoIgnore = new Set < Eng_VP_TeamMember__c > ();
        for (Eng_VP_TeamMember__c teamMember: engVPTeamMembersToUpdate) 
        {
            teamMemberUniqueMap.put((teamMember.Staff__c + '' + teamMember.Role__c + '' + teamMember.Engagement_VP_Position__c), teamMember);
            userSet.add(teamMember.Staff__c);
            roles.add(teamMember.Role__c);
            parentposition.add(teamMember.Engagement_VP_Position__c);
            teamMemberstoIgnore.add(teamMember);
        }   
        for (Eng_VP_TeamMember__c teamMember: [ SELECT Staff__c, Role__c, Start_Date__c, End_Date__c, Engagement_VP_Position__c, Team_Member_Status__c 
                                                FROM Eng_VP_TeamMember__c
                                                WHERE Staff__c IN: userSet and Role__c IN: roles and Engagement_VP_Position__c 
                                                    IN: parentposition limit: Limits.getLimitQueryRows()])
        {
            if (teamMemberUniqueMap.containsKey(teamMember.Staff__c + '' + teamMember.Role__c + '' + teamMember.Engagement_VP_Position__c)) 
            {
                Eng_VP_TeamMember__c duplicateRecord = teamMemberUniqueMap.get(teamMember.Staff__c + '' + teamMember.Role__c + '' + teamMember.Engagement_VP_Position__c);
                if(teamMember.Id != duplicateRecord.id){
                
                    if (((duplicateRecord.Start_Date__c <= teamMember.Start_Date__c || duplicateRecord.Start_Date__c <= teamMember.End_Date__c)&& teamMember.Team_Member_Status__c != 'Inactive' ) || 
                    ((duplicateRecord.Start_Date__c < teamMember.Start_Date__c || duplicateRecord.Start_Date__c < teamMember.End_Date__c)&& teamMember.Team_Member_Status__c == 'Inactive' ) ||
                    (duplicateRecord.Start_Date__c > teamMember.Start_Date__c && teamMember.End_Date__c == null ))
                    {
                        
                        setofDuplicateData.add(duplicateRecord);
                        
                    }
                }
            }       
        }
        return setofDuplicateData;
    }    
    
    //Updates the ERP contact fields in the related account if certain contact fields are updated
    public void updateContactInfoInAccount(List<Contact> contactList, Map<Id, Contact> newContactMap, Map<Id, Contact> oldContactMap) {
        Set<Id> conIdSet = new Set<Id>();
        
        for (Contact con : contactList) {
            if (con.FirstName != oldContactMap.get(con.Id).FirstName || con.LastName != oldContactMap.get(con.Id).LastName 
                || con.Phone != oldContactMap.get(con.Id).Phone || con.Email != oldContactMap.get(con.Id).Email)
                 conIdSet.add(con.Id);
        }
 
        if(!conIdSet.isEmpty()) {
            List<Account> accountUpdateList = new List<Account>();
            List<Account> accList = [SELECT Id, ERP_Contact_First_Name__c, ERP_Contact_Last_Name__c, ERP_Contact_Email__c, ERP_Contact_Phone__c, Primary_Billing_Contact__c FROM Account WHERE Primary_Billing_Contact__c IN :conIdSet];
            
            for (Account acc : accList){
                Contact primaryCon = newContactMap.get(acc.Primary_Billing_Contact__c);
                if(primaryCon != null){                    
                    acc.ERP_Contact_First_Name__c = primaryCon.FirstName;
                    acc.ERP_Contact_Last_Name__c = primaryCon.LastName;
                    acc.ERP_Contact_Email__c = primaryCon.Email;
                    acc.ERP_Contact_Phone__c = primaryCon.Phone;
                    accountUpdateList.add(acc);
                }
            }

            if (!accountUpdateList.isEmpty()){
                update accountUpdateList;
               // Database.executeBatch(new HL_UpdateAccountBatch(accountUpdateList));     

            }

        }
    }   
}