//We need to manually handle the Team
public with sharing class HL_EngagementReportLinks {
    public List<HL_Report_Link__c>	LinkList	{ get;set; }
    public string PageTitle						{ get;set; }    
    public string PageStyle						{ get;set; }
    
    public HL_EngagementReportLinks(Apexpages.StandardController con)
    {
        Engagement__c currEngagement;
        string EngagementID;
        
        try
        {
            currEngagement = [SELECT Name, Full_Engagement_ID__c FROM Engagement__c WHERE ID =: con.getId()];        
            EngagementID = currEngagement.Full_Engagement_ID__c;        
        }
        catch(Exception ex)
        {
            currEngagement = null;
            EngagementID = null;
        }
		
        if(!String.isBlank(EngagementID))
        {
            LinkList = HL_ReportLink.GetByType(EngagementID, 'Engagement Single');
            
			for(HL_Report_Link__c currLink: LinkList)            
                currLink.Report_Link_URL__c = currLink.Report_Link_URL__c.replace('{!Engagement__c.Full_Engagement_ID__c}', EngagementID);

            PageTitle = 'Engagement Reports for ' + currEngagement.Name;    
            PageStyle = 'display:initial;'; 
        }
        else
        {
            LinkList = HL_ReportLink.GetByType('Engagement Group');
            
            PageTitle = 'Engagement Reports';
            PageStyle = 'display:none;';            
        }        
    }
    
    public HL_EngagementReportLinks(){}
    
    public Pagereference ReturnToParent()
    {
        Pagereference pageref = new Pagereference('/' + ApexPages.currentPage().getParameters().get('id'));
	   	return pageref;
    }    
}