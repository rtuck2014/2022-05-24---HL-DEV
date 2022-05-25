public with sharing class HL_CompanyHomeController {
    public String CustomFilter{get {return 'AND RecordType.Name = \'Houlihan Employee\' AND Status__c = \'Active\'';}set;}
    public HL_CompanyHomeController(){}
    public Account Account {get{
        if(account == null)
            account = new Account();
        return account;
    }set;}
    public String SearchOption {get{
        if(String.isBlank(searchOption))
            searchOption = SearchOptions[0].getValue();
        return searchOption;
    } set;}
    public List<SelectOption> SearchOptions{get{
        return HL_Utility.SearchSelectOptions();
    }}
    public String SearchName {get; set;}
    public String SearchCity {get; set;}
    public String SearchState {get; set;}
	public String SearchCountry {get; set;}
    public String SearchClientNumber {get; set;}
    public String SearchPhone {get; set;}
    private String NameSearch{get {
        return new HL_Search(SearchName, SearchOption == 'Contains').SearchTerm;
    }}
    private HL_Search Search{get{
        	return new HL_Search(SearchName, SearchOption == 'Contains');
    	}
    }
    private String CitySearch{get {
        return new HL_Search(SearchCity, SearchOption == 'Contains').SearchTerm;
    }}
    private String StateSearch{get {
        return new HL_Search(SearchState, SearchOption == 'Contains').SearchTerm;
    }}
	private String CountrySearch{get {
        return new HL_Search(SearchCountry, SearchOption == 'Contains').SearchTerm;
    }}
    private String IndustrySearch{get {
        return new HL_Search(Account.Industry_Group_Abbreviation_All__c, false).SearchTerm;
    }}
    private String ClientNumberSearch{get {
        return new HL_Search(SearchClientNumber, SearchOption == 'Contains').SearchTerm;
    }}
    private String PhoneSearch{get {
        return new HL_Search(SearchPhone, SearchOption == 'Contains').SearchTerm;
    }}
    private String CoverageSearch{get{
        return new HL_Search(CoverageBy, true).SearchTerm;
    }}
    public Id CoverageBy {get; set;}
    public String CoverageName {get; set;}
    public Id RelationshipWith {get; set;}
    public String RelationshipName {get; set;}
    public Boolean UseSearch{get{
        if(useSearch == null)
            useSearch = false;
        return useSearch;
    }set;}
    
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                Set<Id> relationships = new Set<Id>();
                if(!UseSearch || !String.isBlank(RelationshipWith)) 
                    relationships = GetRelationships(!UseSearch ? UserInfo.getUserId() : RelationshipWith); 

                setCon = new ApexPages.StandardSetController(Database.Query('SELECT Name, RecordType.Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Client_Number__c, Phone, Industry_Group__c, Primary_Coverage_Officer__r.Name, LastActivityDate, No_Parent_Company__c ' +
                                                                            'FROM Account ' +
                                                                            'WHERE ' + GetWhereClause(!UseSearch || !String.isBlank(RelationshipWith)) +
                                                                            'ORDER BY ' + SortField + ' ' + SortDirection + ' ' +
                                                                            'LIMIT 1000'));
                ActualCount = Database.countQuery('SELECT COUNT() ' +
                                                  'FROM Account ' +
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
        if(!String.isBlank(SearchName))
            whereClause += 'Name LIKE \'' + NameSearch + '\' AND ';
        if(!String.isBlank(SearchCity))
            whereClause += 'BillingCity LIKE \'' + CitySearch + '\' AND ';
        if(!String.isBlank(SearchState))
            whereClause += 'BillingState LIKE \'' + StateSearch + '\' AND ';
		if(!String.isBlank(SearchCountry))
            whereClause += 'BillingCountry LIKE \'' + SearchCountry + '\' AND ';
        if(!String.isBlank(Account.Industry_Group_Abbreviation_All__c))
            whereClause += 'Industry_Group_REPORTING__c LIKE:IndustrySearch AND ';
        if(!String.isBlank(SearchClientNumber))
            whereClause += 'Client_Number__c LIKE:ClientNumberSearch AND ';
        if(!String.isBlank(SearchPhone))
            whereClause += '(Phone LIKE:PhoneSearch OR Fax LIKE:PhoneSearch) AND ';
        if(!String.isBlank(CoverageBy))
            whereClause += 'Coverage_Team_Aggregate__c LIKE:CoverageSearch AND ';
        if(!String.isBlank(whereClause))
            whereClause = whereClause.removeEnd('AND ');
        return whereClause;
    }
    
    private Set<Id> GetRelationships(Id userId){
        return new Set<Id>(HL_Relationship.GetCompanyRelationshipsByUser(userId));
    }
    
    public List<Account> GetMyCompanies(){
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
        SearchName = SearchCity = SearchState = SearchCountry = Account.Industry_Group_Abbreviation_All__c = SearchClientNumber = RelationshipWith = RelationshipName = CoverageBy = CoverageName = null;
        UseSearch = false;
    }
}