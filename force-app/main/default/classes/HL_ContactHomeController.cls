public with sharing class HL_ContactHomeController {
  public String SearchOption {get{
        if(String.isBlank(searchOption))
            searchOption = SearchOptions[0].getValue();
        return searchOption;
  } set;}
  public List<SelectOption> SearchOptions{get{
        return HL_Utility.SearchSelectOptions();
    }}
    private String ContainsPercent {get{return SearchOption == 'Contains' ? '%' : '';}}
    public String SearchFirstName {get; set;}
    public String SearchLastName {get; set;}
    public String SearchCompany {get; set;}
    public String SearchCity {get; set;}
    public String SearchState {get; set;}
    public String SearchEmail {get; set;}
    public String SearchPhone {get; set;}
    private String FirstNameSearch{get {
        return new HL_Search(SearchFirstName, SearchOption == 'Contains').SearchTerm;
    }}
    private String LastNameSearch{get {
        return new HL_Search(SearchLastName, SearchOption == 'Contains').SearchTerm;
    }}
    private String CompanySearch{get {
        return new HL_Search(SearchCompany, SearchOption == 'Contains').SearchTerm;
    }}
    private String CitySearch{get {
        return new HL_Search(SearchCity, SearchOption == 'Contains').SearchTerm;
    }}
    private String StateSearch{get {
        return new HL_Search(SearchState, SearchOption == 'Contains').SearchTerm;
    }}
    private String EmailSearch{get {
        return String.IsBlank(SearchEmail) ? '' : ContainsPercent + SearchEmail.replace('*','') + '%';
    }}
    private String PhoneSearch{get {
        return String.IsBlank(SearchPhone) ? '' : ContainsPercent + SearchPhone.replace('*','') + '%';
    }}
   
    public Id RelationshipWith {get; set;}
    public String RelationshipName {get; set;}
    public String CustomFilter{get {return 'AND RecordType.Name = \'Houlihan Employee\' AND Status__c = \'Active\'';}set;}
    public Relationship__c Relationship {get{
        if(relationship == null)
            relationship = new Relationship__c();
        return relationship;
    } set;}
    public Boolean UseSearch{get{
        if(useSearch == null)
            useSearch = false;
        return useSearch;
    }
    set;}
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                Set<Id> relationships = new Set<Id>();
                if(!UseSearch || !String.isBlank(RelationshipWith)) 
                    relationships = GetRelationships(!UseSearch ? UserInfo.getUserId() : RelationshipWith);
                setCon = new ApexPages.StandardSetController(Database.query('SELECT Name, Contact_Name__c, Account.Name, Title, Phone, MobilePhone, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, LastActivityDate ' +
                                                              				'FROM Contact ' +
                                                                            'WHERE ' + GetWhereClause(!UseSearch || !String.isBlank(RelationshipWith)) +
                                                                            'ORDER BY ' + SortField + ' ' + SortDirection + ' ' +
                                                                            'LIMIT 500'));  
                ActualCount = Database.countQuery('SELECT COUNT() ' +
                                            	  'FROM Contact ' +
                                            	  'WHERE ' + GetWhereClause(!UseSearch || !String.isBlank(RelationshipWith))
                                           		 ); 
            }
            return setCon;
        }
        set;
    }
  public String NewSort {get; set;}
  public String SortField {get{return sortField == null ? 'Name' : sortField;} set{
        ToggleDirection(value);
        SortField = value;
  }}
  public String SortDirection {get{return sortDirection == null ? 'ASC' : sortDirection;} set;}
  public Integer ActualCount{get; set;}
  private string GetWhereClause(Boolean useRelationship){
        //Having Oracle Issues With Escape and Like
        //https://success.salesforce.com/issues_view?id=a1p30000000T3OLAA0
        String whereClause = useRelationship ? 'Id IN : relationships AND ' : '';  
        if(!String.isBlank(SearchLastName))
            whereClause += 'LastName LIKE \'' + LastNameSearch + '\' AND ';
        if(!String.isBlank(SearchFirstName))
            whereClause += 'FirstName LIKE \'' + FirstNameSearch + '\' AND ';
        if(!String.isBlank(SearchCompany))
            whereClause += 'Account.Name LIKE \'' + CompanySearch + '\' AND ';
        if(!String.isBlank(SearchCity))
            whereClause += 'MailingCity LIKE \'' + CitySearch + '\' AND ';
        if(!String.isBlank(SearchState))
            whereClause += 'MailingState LIKE \'' + StateSearch + '\' AND ';
        if(!String.isBlank(SearchEmail))
            whereClause += 'Email LIKE:EmailSearch AND ';
        if(!String.isBlank(SearchPhone))
            whereClause += '(Phone LIKE:PhoneSearch OR MobilePhone LIKE:PhoneSearch) AND ';
        if(!String.isBlank(whereClause))
            whereClause = whereClause.removeEnd('AND ');
        return whereClause;
  }
 
  public HL_ContactHomeController(){
      
  }
  private Set<Id> GetRelationships(Id currentUserId){
      return new Set<Id>(HL_Relationship.GetContactRelationshipsByUser(currentUserId));
  }
  public List<Contact> GetMyContacts(){
      return setCon.getRecords();
   }
   public void ToggleDirection(string newSort){
        setCon = null;
        SortDirection = (SortField == newSort) ? (SortDirection == 'DESC' ? 'ASC' : 'DESC') : 'ASC';
   }
   public void ApplySort()
   {
       setCon = null;
       SortField = NewSort;
   }
   public void AdvancedSearch(){
       setCon = null;
       UseSearch = true;
   }
   public void ClearSearch(){
        setCon = null;
        SearchFirstName = SearchLastName = SearchCompany = SearchCity = SearchState = SearchEmail = SearchPhone = RelationshipWith = null;
        UseSearch = false;
   }
}