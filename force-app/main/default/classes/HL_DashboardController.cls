public class HL_DashboardController {
    public List<HL_Report_Link__c>  LinkList    { get;set; }
    public string PageTitle                     { get;set; }    
    public String[] ReportGroup                 { get;set; }    
    
    public HL_DashboardController()
    {
        List<string> reportTypeList = new List<string>{'My Dashboards','Line of Business Dashboards','Industry Group/Product Line Dashboards', 'Sector Coverage Dashboards', 'Accounting Dashboards'};
        LinkList = HL_ReportLink.GetByType(null,reportTypeList);     
        Set<String> GroupSet = new Set<String>();
        
        for(HL_Report_Link__c h : LinkList)
            GroupSet.add(h.Report_Type__c);
        ReportGroup = new String[GroupSet.size()];
        Integer i = 0;
        for(String RGroup: GroupSet){
            ReportGroup[i] = RGroup;
            i++;
        }
        
        PageTitle = 'HL Dashboards';        
    }        
    
    public Pagereference ReturnToParent()
    {
        Pagereference pageref = new Pagereference('/' + ApexPages.currentPage().getParameters().get('id'));
        return pageref;
    }    
    
}