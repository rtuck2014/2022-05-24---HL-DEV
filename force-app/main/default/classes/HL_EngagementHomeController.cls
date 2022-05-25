public with sharing class HL_EngagementHomeController { 
    public String MainSearchOption {get{
        if(String.isBlank(mainSearchOption))
            mainSearchOption = MainSearchOptions[0].getValue();
        return mainSearchOption;
    } set;}
    public static List<SelectOption> MainSearchOptions{get{
        return new List<SelectOption> {new SelectOption('All', 'All Engagements'), new SelectOption('My','My Engagements')};
    }}
    public Engagement__c Eng {get{
        if(eng == null)
            eng = new Engagement__c();
        return eng;
    } set;}
    private String NameSearch{get {
        return new HL_Search(Eng.Name, true).SearchTerm;
    }} 
    public Boolean UseSearch{get{
        if(useSearch == null)
            useSearch = false;
        return useSearch;
    } set;}
    public Id EITId {get; set;}
    public String EITName {get; set;}
    private String EITSearch{get{
        return new HL_Search(EITId, true).SearchTerm;
    }}
    public String CustomFilter{get {return 'AND RecordType.Name = \'Houlihan Employee\' AND Status__c = \'Active\'';}set;}
    public ApexPages.StandardSetController setCon {
        get{  
            if(setCon == null){
                Boolean useCurrentUser = !UseSearch;
                Id ClientId, SubjectId;
                String lob,jobType,industryGroup,stage,engagementNumber;
                if(!String.isBlank(Eng.Engagement_Number__c))
                    engagementNumber = Eng.Engagement_Number__c;
                if(!String.isBlank(Eng.z_Client__c))
                    ClientId = Eng.z_Client__c;
                if(!String.isBlank(Eng.z_Subject__c))
                    SubjectId = Eng.z_Subject__c;
                if(!String.isBlank(Eng.Line_Of_Business_All__c))
                    lob = Eng.Line_of_Business_All__c;
                if(!String.isBlank(Eng.Job_Type_All__c))
                    jobType = Eng.Job_Type_All__c;
                if(!String.isBlank(Eng.Industry_Group_Abbreviation_All__c))
                    industryGroup = Eng.Industry_Group_Abbreviation_All__c;
                if(!String.isBlank(Eng.Stage_All__c))
                    stage = Eng.Stage_All__c;
                setCon = new ApexPages.StandardSetController(Database.query('SELECT Name, CreatedDate, Date_Engaged__c, LastModifiedDate, CreatedBy.Name, Line_Of_Business__c, Client__r.Name, Subject__r.Name, Job_Type__c, Industry_Group__c, Sector__c, Stage__c, Engagement_Number__c ' +
                                                                            'FROM Engagement__c ' +
                                                                            'WHERE ' + GetWhereClause(!UseSearch) +
                                                                            'ORDER BY ' + SortField + ' ' + SortDirection + ' ' +
                                                                            'LIMIT 1000'));
                ActualCount = Database.countQuery('SELECT COUNT() ' +
                                                  'FROM Engagement__c ' +
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
        String whereClause = useCurrentUser ? 'My_Engagement__c =: useCurrentUser AND Status__c = \'Active\' AND ' : (MainSearchOption == 'My' ? 'My_Engagement__c = true AND ' : '');      
        if(!String.isBlank(Eng.Name))
            whereClause += 'Name LIKE \'' + NameSearch + '\' AND ';
        if(!String.isBlank(Eng.Engagement_Number__c))
            whereClause += 'Engagement_Number__c =: engagementNumber AND ';
        if(!String.isBlank(Eng.z_Client__c))
            whereClause += 'Client__c=:ClientId AND ';   
        if(!String.isBlank(Eng.z_Subject__c))
            whereClause += 'Subject__c=:SubjectId AND '; 
        if(!String.isBlank(Eng.Line_Of_Business_All__c))
            whereClause += 'Line_of_Business__c =: lob AND '; 
        if(!String.isBlank(Eng.Job_Type_All__c))
            whereClause += 'Job_Type__c =: jobType AND '; 
        if(!String.isBlank(Eng.Industry_Group_Abbreviation_All__c))
            whereClause += 'Industry_Group_REPORTING__c =: industryGroup AND ';
        if(!String.isBlank(Eng.Stage_All__c))
            whereClause += 'Stage__c =: stage AND ';
         if(!String.isBlank(EITId))
            whereClause += '(z_Admin_Intern_Aggregate__c LIKE:EITSearch OR z_Analyst_Aggregate__c LIKE:EITSearch OR z_Analyst_Aggregate2__c LIKE: EITSearch OR z_Analyst_Aggregate3__c LIKE: EITSearch OR z_Associate_Aggregate__c LIKE: EITSearch OR z_Associate_Aggregate2__c LIKE: EITSearch OR z_Associate_Aggregate3__c LIKE: EITSearch OR z_Final_Rev_Aggregate__c LIKE: EITSearch OR z_Initiator_Aggregate__c LIKE: EITSearch OR z_Initiator_Aggregate2__c LIKE: EITSearch OR z_Manager_Aggregate__c LIKE: EITSearch OR z_Marketing_Aggregate__c LIKE: EITSearch OR z_Marketing_Aggregate2__c LIKE: EITSearch OR z_Marketing_Aggregate3__c LIKE: EITSearch OR z_PE_HF_Aggregate__c LIKE: EITSearch OR z_Prelim_Rev_Aggregate__c LIKE: EITSearch OR z_Pricing_Aggregate__c LIKE: EITSearch OR z_Principal_Aggregate__c LIKE: EITSearch OR z_Public_Aggregate__c LIKE: EITSearch OR z_Reviewer_Aggregate__c LIKE: EITSearch OR z_Seller_Aggregate__c LIKE: EITSearch OR z_Seller_Aggregate__c LIKE: EITSearch) AND ';
        if(!String.isBlank(whereClause))
            whereClause = whereClause.removeEnd('AND ');
        return whereClause;
    }
    
    public HL_EngagementHomeController(){
        
    }
    public List<Engagement__c> GetMyEngagements(){
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
        Eng = null;
        EITId = EITName = null;
        UseSearch = false;
    }
}