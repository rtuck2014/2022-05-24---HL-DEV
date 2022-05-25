public with sharing class HL_InvestmentsListController {
    public String SortField {get{return sortField == null ? 'Portfolio_CapIQ_Company__r.Name' : sortField;} set{
        ToggleDirection(value);
        SortField = value;
    }}
    public Field_Ids__c FI {get{return Field_Ids__c.getOrgDefaults();}}
    public String SortDirection {get{return sortDirection == null ? 'ASC' : sortDirection;} set;}
    private String StatusFilter = 'Current';
    public integer PageSize = 5;
    public Id AccountId {get; set;}
    public Id UltimateParentId {get {return (ultimateParentId == null ? AccountId : ultimateParentId);} set;}
    public Id CapIQCompanyID {get; set;}
    public String AccountName {get; set;}
    public String CapIQCompanyName {get; set;}
    public String FilterText{get {return statusFilter;}}
    public String InvestmentType {get{
        if(investmentType == null)
            investmentType = 'Investments';
        return investmentType;
    } set;}
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                                'SELECT Name, Amount_of_Investment__c, Date_Sold__c, Description__c, EBITDA_CapIQ__c, EBITDA_HL__c, ' + 
                                'HL_Industry_LK__c, Investment_Date__c, Portfolio_CapIQ_Company__r.Name, ' +
                                'Expected_Exit_Date__c, Related_Fund__r.Name, Revenue_CapIQ__c, Revenue_HL__c, Status__c, Sponsor_CapIQ_Company__r.Name, Actual_Relationship_Type__c ' +
                                'FROM Investment__c ' +
                                'WHERE ' + (investmentType == 'Investments' ? '(Sponsor_CapIQ_Company__c <> null AND Sponsor_CapIQ_Company__c =:CapIQCompanyID) ' :'(Portfolio_CapIQ_Company__c <> null AND Portfolio_CapIQ_Company__c =: CapIQCompanyID) ') +
                                           (statusFilter <> 'All' ? 'AND Status__c =:statusFilter ' : 'AND Status__c <> null ') +
                                'ORDER BY ' + SortField + ' ' + SortDirection + (SortDirection == 'ASC' ? ' NULLS FIRST ' : ' NULLS LAST ')
                ));
                
                setCon.setPageSize(PageSize);
            }
             
            return setCon;
        }
        set;
    }

    public List<Investment__c> getInvestments() {
        return setCon.getRecords();
    }
    
    public HL_InvestmentsListController(){
        AccountId = ApexPages.currentPage().getParameters().get('Id');
        InitializeVariables(AccountId);        
    }
    
    public HL_InvestmentsListController(ApexPages.StandardController acct){
        AccountId = acct.getId();
        InitializeVariables(AccountId);
    }
    
    private void InitializeVariables(Id acctId){
        Account a = [SELECT Name, Ultimate_Parent__c, CapIQ_Company__c, CapIQ_Company__r.Name FROM Account WHERE ID=:acctId];
        AccountName = a.Name;
        CapIQCompanyID = a.CapIQ_Company__c;
        CapIQCompanyName = a.CapIQ_Company__r.Name;
        UltimateParentId = a.Ultimate_Parent__c;
    }
    
    private void ApplyFilter(String filter)
    {
        PageSize = setCon.getPageSize();
        setCon = null;
        StatusFilter = filter;
    }
    
    private void ApplySort(String sortField)
    {
        PageSize = setCon.getPageSize();
        setCon = null;
        this.SortField = sortField;
    }
    public void FilterByAllInvestments(){
        ApplyFilter('All');
    }
    
    public void FilterByPriorInvestments(){
       ApplyFilter('Prior');
    }
    
    public void FilterByCurrentInvestments(){
        ApplyFilter('Current');
    }

    public void SortByDateSold(){
        ApplySort('Date_Sold__c');
    }
    
    public void SortByPortfolioCompany(){
        ApplySort('Portfolio_CapIQ_Company__r.Name');
    }
    
    public void SortByAmountOfInvestment(){
        ApplySort('Amount_of_Investment__c');
    }

    public void SortByRelatedFund(){
        ApplySort('Related_Fund__r.Name');
    }
    
    public void SortByInvestmentDate(){
        ApplySort('Investment_Date__c');
    }
    
    public void SortByExpectedExitDate(){
        ApplySort('Expected_Exit_Date__c');
    }
    
    public void SortBySponsor(){
        ApplySort('Sponsor_CapIQ_Company__r.Name');
    }
    
    public void SortByStatus(){
        ApplySort('Status__c');
    }
    
    public void SortByActualRelationshipType(){
        ApplySort('Actual_Relationship_Type__c');
    }
    
    public void SortByIndustry(){
        ApplySort('HL_Industry_LK__r.Industry_Sector__c');
    }
       
    public void SortByName(){
        ApplySort('Name');
    }
    
    public void ToggleDirection(string newSort){
        SortDirection = (SortField == newSort) ? (SortDirection == 'DESC' ? 'ASC' : 'DESC') : 'ASC';
    }
}