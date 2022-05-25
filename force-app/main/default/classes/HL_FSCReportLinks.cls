public with sharing class HL_FSCReportLinks {
    public List<HL_Report_Link__c>	LinkList	{ get;set; }
    public string PageTitle						{ get;set; }    
    public string PageStyle						{ get;set; }
    
    public HL_FSCReportLinks()
    {
        LinkList = HL_ReportLink.GetByType('FSC Group');
        
        PageTitle = 'Financial Sponsors Reports';
        PageStyle = 'display:none;';                  
    }
}