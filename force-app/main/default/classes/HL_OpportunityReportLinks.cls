public with sharing class HL_OpportunityReportLinks {
    public List<HL_Report_Link__c>	LinkList	{ get;set; }
    public string PageTitle						{ get;set; }
    public string PageStyle						{ get;set; }
    
    public HL_OpportunityReportLinks(Apexpages.StandardController con)
    {        
        Opportunity__c currOpportunity;
        string OpportunityID; 
      
        try
        {
        	currOpportunity = [SELECT Name, Full_Opportunity_ID__c FROM Opportunity__c WHERE ID =: con.getId()];
            OpportunityID = currOpportunity.Full_Opportunity_ID__c; 
        }
        catch(Exception ex)
        {
            currOpportunity = null;
            OpportunityID = null;
        }       
        
        if(!String.isBlank(OpportunityID))
        {
            LinkList = HL_ReportLink.GetByType(OpportunityID, 'Opportunity Single');
            
			for(HL_Report_Link__c currLink: LinkList)            
                currLink.Report_Link_URL__c = currLink.Report_Link_URL__c.replace('{!Opportunity__c.Full_Opportunity_ID__c}', OpportunityID);
            
            PageTitle = 'Opportunity Reports for ' + currOpportunity.Name;   
            PageStyle = 'display:initial;';            
        }
        else     
        {
        	LinkList = HL_ReportLink.GetByType('Opportunity Group');
            
            PageTitle = 'Opportunity Reports';
            PageStyle = 'display:none;';
        }    
    }
    
    public HL_OpportunityReportLinks(){}
    
    public Pagereference ReturnToParent()
    {
        Pagereference pageref = new Pagereference('/' + ApexPages.currentPage().getParameters().get('id'));
	   	return pageref;
    }
}