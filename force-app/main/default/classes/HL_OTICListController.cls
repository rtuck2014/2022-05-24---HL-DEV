public with sharing class HL_OTICListController
{
    private ApexPages.StandardSetController standardController;
	private List<Offsite_Template_Investment_Company__c> investmentList;
    private PageReference returnPage;
    public Boolean CurrentOnly {get; set;}
    public String AlphabetFilter {get; set;}
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                //This is really bad to have to go off Recently Viewed, but seems to be the only option at present
                List<RecentlyViewed> rvList = [SELECT Id FROM RecentlyViewed WHERE Type = 'Offsite_Template__c' ORDER BY LastViewedDate DESC];
                if(rvList.size() > 0){
                    Id offsiteId = rvList[0].Id;
                    returnPage = new PageReference('/' + offsiteId);
                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                            'SELECT Offsite_Template__c, Portfolio_Company__c, Description__c, Investment_Date__c, Investment_Company__c, Prospect__c, Status__c, Service__c, Sort_Field__c, Include__c FROM Offsite_Template_Investment_Company__c WHERE Offsite_Template__c =: offsiteId '  +
                            (CurrentOnly ? ' AND Status__c = \'Current\' ' : '') +
                            (AlphabetFilter != 'All' ? ' AND Portfolio_Company__c LIKE \'' + AlphabetFilter + '%\' ' : '') +
                            'ORDER BY ' + SortField + ' '  + SortDirection
                    ));
                }
                else
                    setCon = new ApexPages.StandardSetController(new List<Offsite_Template_Investment_Company__c>());
            }
            setCon.setPageSize(100);
            return setCon;
        }
        set;
    }
    public String SortField {get{return sortField == null ? 'Sort_Field__c' : sortField;} set{
        toggleDirection(value);
        SortField = value;
    }}
    public void Next(){
        integer currentPageNumber = setCon.getPageNumber();
        setCon.save();
        setCon.setpageNumber(currentPageNumber + 1);
        investmentList = null;
    }
    public void Previous(){
        integer currentPageNumber = setCon.getPageNumber();
        setCon.save();
        setCon.setpageNumber(currentPageNumber - 1);
        investmentList = null;
    }
    public void Filter(){
        investmentList = null;
        setCon = null;
    }
    public String SortDirection {get{return sortDirection == null ? 'ASC' : sortDirection;} set;}
    public HL_OTICListController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
        CurrentOnly = true;
        AlphabetFilter = 'All';
    }
    
    public PageReference updateInclude()
    {       
        // Get the selected records 
        List<Offsite_Template_Investment_Company__c> selectedInvestments = (List<Offsite_Template_Investment_Company__c>)standardController.getSelected();
        // Update records       
        for(Offsite_Template_Investment_Company__c selected : selectedInvestments)
            selected.Include__c = !selected.Include__c;
        return standardController.save();        
    }

    public PageReference updateInvestmentsAndReturn()
    {       
        updateInvestments();
        return returnPage;
    }

    public void updateInvestments()
    {       
        if(investmentList != null){
        	update investmentList;
            HL_PageUtility.ShowConfirm('Records Saved'); 
        }
    }
    
    public PageReference cancel(){
        return returnPage;
    }
    
    public List<Offsite_Template_Investment_Company__c> getInvestments(){
        if(investmentList == null){
           investmentList = setCon.GetRecords();
        }
        return investmentList;
    }
    private void toggleDirection(string newSort){
        sortDirection = (SortField == newSort) ? (sortDirection == 'DESC' ? 'ASC' : 'DESC') : 'ASC';
    }
}