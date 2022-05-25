public with sharing class HL_ContactReportLinks {
    public List<HL_Report_Link__c>	LinkList	{ get;set; }
    public string PageTitle						{ get;set; }
    public string PageStyle						{ get;set; }
    
    public HL_ContactReportLinks(Apexpages.StandardController con)
    {
        Contact currContact;
        string ContactID; 
        
        try
        {
            currContact = [SELECT Name, Full_Contact_ID__c FROM Contact WHERE ID =: con.getId()]; 
            ContactID = currContact.Full_Contact_ID__c;             
        }
       	catch(Exception ex) 
        {
            currContact = null;
            ContactID = null;             
        }
       
        
        if(!String.isBlank(ContactID))
        {
            LinkList = HL_ReportLink.GetByType('Contact Single');
            
			for(HL_Report_Link__c currLink: LinkList)            
                currLink.Report_Link_URL__c = currLink.Report_Link_URL__c.replace('{!Contact.Full_Contact_ID__c}', ContactID);
            
            PageTitle = 'Contact Reports for ' + currContact.Name;
            PageStyle = 'display:initial;';              
        }
        else   
        {	
            LinkList = HL_ReportLink.GetByType('Contact Group');
            
            PageTitle = 'Contact Reports';
            PageStyle = 'display:none;';            
        }        
    }
    
    public HL_ContactReportLinks(){}
    
    public Pagereference ReturnToParent()
    {
        Pagereference pageref = new Pagereference('/' + ApexPages.currentPage().getParameters().get('id'));
	   	return pageref;
    }    
    
}