public with sharing class HL_LookupContactController {
  public List<aContact> SearchResults{get;set;} 
  public String PrimaryEntityId {get; set;}
  public String SecondaryEntityId {get; set;}
  public String Role {get; set;}
  public String SelectedStaffRole {get; set;}
  public String SearchString{get;set;} 
  public Integer LookupAction{get; set;}
  public String NewSort {get; set;}
  public String SortField {get{return sortField == null ? 'Name' : sortField;} set{
        ToggleDirection(value);
        SortField = value;
    }}
  public String SortDirection {get{return sortDirection == null ? 'ASC' : sortDirection;} set;}
  public ApexPages.StandardSetController setCon {
        get{
             //Having Oracle Issues With Escape and Like
             //https://success.salesforce.com/issues_view?id=a1p30000000T3OLAA0
             HL_Search s = new HL_Search(SearchString, true);
             String search = s.SearchTerm;
             String part01 = '';
             String part02 = '';
             if(s.HasMultiple)
             {
                 part01 = s.Term01;
                 part02 = s.Term02;
             }
             String recordTypeName = LookupAction == 4 ? 'Distribution List' : (LookupAction == 3 ? 'Houlihan_Employee' : 'External_Contact');
             String status = 'Active';
            if(setCon == null)
                setCon = new ApexPages.StandardSetController(Database.query(
                    'SELECT Id, Name, Account.Name, Account.BillingCity, Account.BillingState, Account.BillingCountry ' +
                    'FROM Contact ' +
                    'WHERE Status__c =: status AND RecordType.DeveloperName =: recordTypeName AND (Name LIKE \'' + search + '\'' + 
                    (s.HasMultiple ? 'OR ((FirstName LIKE \'' + part01 + '\' AND LastName LIKE \'' + part02 + '\') OR (FirstName LIKE \'' + part02 + '\' AND LastName LIKE \'' + part01 + '\'))) ' : ') ') +
                    'ORDER BY ' + SortField + ' ' + SortDirection + ' LIMIT 1000'
                ));
            setCon.setPageSize(1000);
            return setCon;
        }
        set;
    }
   public Engagement_External_Team__c DummyRecord {get{
        if(DummyRecord == null)
            DummyRecord = new Engagement_External_Team__c(RecordTypeId = HL_Utility.GetRecordTypeId('Engagement_External_Team__c', LookupAction == 3 ? 'Liaison' : 'FR'));
        return DummyRecord;
  }set;}
   public List<SelectOption> Roles {get {
        List<SelectOption> selections = new List<SelectOption>();
        List<String> roleList = HL_Utility.GetPicklistValues('Engagement_External_Team__c','Role__c'); 
        for(String r:roleList)
            selections.add(New SelectOption(r,r));
        return selections;
  }}
    public List<SelectOption> PostStaffRoles{
        get{
            List<SelectOption> selections = new List<SelectOption>();
            List<String> roleList = HL_Utility.GetPicklistValues('Engagement_External_Team__c','Role__c',HL_Utility.GetRecordTypeId('Engagement_External_Team__c', 'Liaison')); 
            for(String r:roleList)
                selections.add(New SelectOption(r,r));
            return selections;
        }
        set;
    }
  public enum ContactLookupAction{
        AddSellerTeam,
        AddPreTransactionBoardMember,
        AddPostTransactionBoardMember,
        AddPostTransactionStaffRole,
        DistributionList,
        AddPostTransactionStaffRoleEXT
  }
  public HL_LookupContactController() {
      Map<String, String> q = ApexPages.currentPage().getParameters();
      if(q.containsKey('action'))
          LookupAction = Integer.valueOf(q.get('action'));
      if(q.containsKey('entity'))
        PrimaryEntityId = q.get('entity');
      if(q.containsKey('secondary'))
         SecondaryEntityId = q.get('secondary');   
  }
   
  public PageReference Search() {
    setCon = null;
    RunSearch();
    return null;
  }
  
  private void RunSearch() {
    SearchResults = PerformSearch(SearchString);               
  } 
  
  private List<aContact> PerformSearch(string search) {
    List<Contact> results = setCon.getRecords();
    List<aContact> aResults = new List<aContact>();
    for(Contact c : results)
        aResults.Add(new aContact(c));
    return aResults; 
  }
    
  public void SaveSelected(){
     ContactLookupAction action = ContactLookupAction.values()[LookupAction];
     Set<Id> selectedContacts = new Set<Id>();
     if(SearchResults <> null)
     {
         for(aContact c : SearchResults)
         {
             if(c.Selected)
                selectedContacts.Add(c.Contact.Id);
         }
         
         if(selectedContacts.size() > 0)
         {
             List<Engagement_External_Team__c> lstExistingCont = [Select id from Engagement_External_Team__c where Engagement__c =: PrimaryEntityId and Contact__c IN : selectedContacts];
             if(lstExistingCont != Null && !lstExistingCont.isEmpty() && action == ContactLookupAction.AddPostTransactionStaffRoleEXT)
             {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This person has already been added as an Engagement Contact. Please go to their Engagement Contact record and click the “Key External Contact” checkbox to add them to this list.'));
             }
             else{
             if(action == ContactLookupAction.AddSellerTeam)
             {
                 List<Engagement_External_Team__c> recordsToInsert = new List<Engagement_External_Team__c>();
                 for(String c : selectedContacts)
                     recordsToInsert.add(new Engagement_External_Team__c(Contact__c = c, Engagement__c = PrimaryEntityId, Role__c = Role));
                 InsertRecords(recordsToInsert);
             }
             
             if(action == ContactLookupAction.AddPreTransactionBoardMember)
             {
                 List<Engagement_External_Team__c> recordsToInsert = new List<Engagement_External_Team__c>();
                 for(String c : selectedContacts)
                     recordsToInsert.add(new Engagement_External_Team__c(Contact__c = c, Engagement__c = PrimaryEntityId, Role__c = 'Pre-Transaction Board Member'));
                 InsertRecords(recordsToInsert);
             }
             
             if(action == ContactLookupAction.AddPostTransactionBoardMember)
             {
                 List<Engagement_External_Team__c> recordsToInsert = new List<Engagement_External_Team__c>();
                 for(String c : selectedContacts)
                     recordsToInsert.add(new Engagement_External_Team__c(Contact__c = c, Engagement__c = PrimaryEntityId, Role__c = 'Post-Transaction Board Member'));
                 InsertRecords(recordsToInsert);
             }
             
             if(action == ContactLookupAction.AddPostTransactionStaffRole)
             {
                 List<Engagement_External_Team__c> recordsToInsert = new List<Engagement_External_Team__c>();
                 for(String c : selectedContacts)
                     recordsToInsert.add(new Engagement_External_Team__c(Contact__c = c, Engagement__c = PrimaryEntityId, Role__c = SelectedStaffRole, RecordTypeId = Schema.SObjectType.Engagement_External_Team__c.getRecordTypeInfosByName().get('Liaison').getRecordTypeId(), Exclude_from_Working_Party__c = TRUE));
                 InsertRecords(recordsToInsert);
             }
             
             if(action == ContactLookupAction.AddPostTransactionStaffRoleEXT)
             {
                 List<Engagement_External_Team__c> recordsToInsert = new List<Engagement_External_Team__c>();
                 for(String c : selectedContacts)
                     recordsToInsert.add(new Engagement_External_Team__c(Contact__c = c, Engagement__c = PrimaryEntityId, Role__c = SelectedStaffRole, Key_External_Contact__c = True, RecordTypeId = Schema.SObjectType.Engagement_External_Team__c.getRecordTypeInfosByName().get('FR').getRecordTypeId()));
                 InsertRecords(recordsToInsert);
             }
            }
             
         }
         else
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Contact(s) Selected'));
     }
     else
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Contact(s) Selected'));
  }
  
    private void InsertRecords(List<SObject> recordsToInsert){
        try
        {
            insert recordsToInsert;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Selections Saved'));
            SearchString = null;
            SearchResults = null;
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
        }   
    }
    
    public class aContact{
        public Contact Contact {get; set;}
        public Boolean Selected {get; set;}
        
        public aContact(Contact c)
        {
            Contact = c;
            Selected = false;
        }
    }
    public void ApplySort()
    {
        setCon = null;
        this.SortField = NewSort;
        RunSearch();
    }
    public void ToggleDirection(string newSort){
        sortDirection = (SortField == newSort) ? (sortDirection == 'DESC' ? 'ASC' : 'DESC') : 'ASC';
    }
}