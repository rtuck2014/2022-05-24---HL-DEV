public with sharing class HL_DashboardLinks {
	public List<HL_Report_Link__c>	LinkList	{ get;set; }
    public string PageTitle						{ get;set; }
    public string PageStyle						{ get;set; }

	public HL_DashboardLinks(Apexpages.StandardController con) {
		LinkList = HL_ReportLink.GetByType('Dashboard Group');
            PageTitle = 'Dashboard Reports';
            PageStyle = 'display:none;';
    }
	public HL_DashboardLinks(){}
}