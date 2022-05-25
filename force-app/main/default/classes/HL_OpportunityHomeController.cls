public with sharing class HL_OpportunityHomeController { 
    public String MainSearchOption {get{
        if(String.isBlank(mainSearchOption))
            mainSearchOption = MainSearchOptions[0].getValue();
        return mainSearchOption;
    } set;}
    public static List<SelectOption> MainSearchOptions{get{
        return new List<SelectOption> {new SelectOption('All', 'All Opportunities'), new SelectOption('My','My Opportunities')};
    }}
    public Opportunity__c Opp {get{
        if(Opp == null)
            Opp = new Opportunity__c();
        return Opp;
    } set;}
    private String NameSearch{get {
        return new HL_Search(Opp.Name, true).SearchTerm;
    }} 
    public Boolean UseSearch{get{
        if(useSearch == null)
            useSearch = false;
        return useSearch;
    }
                             set;}
    public Id OITId {get; set;}
    public String OITName {get; set;}
    private String OITSearch{get{
        return new HL_Search(OITId, true).SearchTerm;
    }}
    public String CustomFilter{get {return 'AND RecordType.Name = \'Houlihan Employee\' AND Status__c = \'Active\'';}set;}
    public ApexPages.StandardSetController setCon {
        get{  
            if(setCon == null){
                Boolean useCurrentUser = !UseSearch;
                Id ClientId, SubjectId;
                String lob,jobType,industryGroup,stage,opportunityNumber;
                if(!String.isBlank(Opp.Opportunity_Number__c))
                    opportunityNumber = Opp.Opportunity_Number__c;
                if(!String.isBlank(Opp.Client__c))
                    ClientId = Opp.Client__c;
                if(!String.isBlank(Opp.Subject__c))
                    SubjectId = Opp.Subject__c;
                if(!String.isBlank(Opp.Line_Of_Business_All__c))
                    lob = Opp.Line_of_Business_All__c;
                if(!String.isBlank(Opp.Job_Type_All__c))
                    jobType = Opp.Job_Type_All__c;
                 if(!String.isBlank(Opp.Industry_Group_Abbreviation_All__c))
                    industryGroup = Opp.Industry_Group_Abbreviation_All__c;
                if(!String.isBlank(Opp.Stage_All__c))
                    stage = Opp.Stage_All__c;

                setCon = new ApexPages.StandardSetController(Database.query('SELECT Name, CreatedDate, Created_Date_Display__c, LastModifiedDate, CreatedBy.Name, Line_Of_Business__c, Client__r.Name, Subject__r.Name, Job_Type__c, Industry_Group__c, Sector__c, Stage__c, Opportunity_Number__c ' +
                                                                            'FROM Opportunity__c ' +
                                                                            'WHERE ' + GetWhereClause(!UseSearch) +
                                                                            'ORDER BY ' + SortField + ' ' + SortDirection + ' ' +
                                                                            'LIMIT 1000'));
                ActualCount = Database.countQuery('SELECT COUNT() ' +
                                                  'FROM Opportunity__c ' +
                                                  'WHERE ' + GetWhereClause(!UseSearch)
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
    private string GetWhereClause(Boolean useCurrentUser){
        //Having Oracle Issues With Escape and Like
        //https://success.salesforce.com/issues_view?id=a1p30000000T3OLAA0
        Id ClientId, SubjectId;
        String lob,jobType,industryGroup;
        String whereClause = useCurrentUser ? 'My_Opportunity__c =: useCurrentUser AND Status__c = \'Active\' AND ' : (MainSearchOption == 'My' ? 'My_Opportunity__c = true AND ' : ''); 
        //whereClause += 'Stage__c <> \'Engaged\' AND ';
        if(!String.isBlank(Opp.Name))
            whereClause += 'Name LIKE \'' + NameSearch + '\' AND ';
        if(!String.isBlank(Opp.Opportunity_Number__c))
            whereClause += 'Opportunity_Number__c =: opportunityNumber AND ';
        if(!String.isBlank(Opp.Client__c))
            whereClause += 'Client__c=:ClientId AND ';   
        if(!String.isBlank(Opp.Subject__c))
            whereClause += 'Subject__c=:SubjectId AND '; 
        if(!String.isBlank(Opp.Line_Of_Business_All__c))
            whereClause += 'Line_of_Business__c =: lob AND '; 
        if(!String.isBlank(Opp.Job_Type_All__c))
            whereClause += 'Job_Type__c =: jobType AND '; 
        if(!String.isBlank(Opp.Industry_Group_Abbreviation_All__c))
            whereClause += 'Industry_Group_REPORTING__c =: industryGroup AND ';
        if(!String.isBlank(Opp.Stage_All__c))
            whereClause += 'Stage__c =: stage AND ';
        if(!String.isBlank(OITId))
            whereClause += '(z_Admin_Intern_Aggregate__c LIKE:OITSearch OR z_Analyst_Aggregate__c LIKE:OITSearch OR z_Analyst_Aggregate2__c LIKE: OITSearch OR z_Associate_Aggregate__c LIKE: OITSearch OR z_Associate_Aggregate2__c LIKE: OITSearch OR z_Final_Rev_Aggregate__c LIKE: OITSearch OR z_Initiator_Aggregate__c LIKE: OITSearch OR z_Initiator_Aggregate2__c LIKE: OITSearch OR z_Manager_Aggregate__c LIKE: OITSearch OR z_Marketing_Aggregate__c LIKE: OITSearch OR z_Marketing_Aggregate2__c LIKE: OITSearch OR z_Marketing_Aggregate3__c LIKE: OITSearch OR z_PE_HF_Aggregate__c LIKE: OITSearch OR z_Prelim_Rev_Aggregate__c LIKE: OITSearch OR z_Pricing_Aggregate__c LIKE: OITSearch OR z_Principal_Aggregate__c LIKE: OITSearch OR z_Public_Aggregate__c LIKE: OITSearch OR z_Reviewer_Aggregate__c LIKE: OITSearch OR z_Seller_Aggregate__c LIKE: OITSearch OR z_Seller_Aggregate__c LIKE: OITSearch) AND ';

        if(!String.isBlank(whereClause))
            whereClause = whereClause.removeEnd('AND ');
        return whereClause;
    }
    
    public HL_OpportunityHomeController(){
        
    }
    public List<Opportunity__c> GetMyOpportunities(){
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
        Opp = null;
        OITId = OITName = null;
        UseSearch = false;
    }
}