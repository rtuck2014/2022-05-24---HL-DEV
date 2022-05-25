public with sharing class HL_CompanyReportLinks {
    public List<HL_Report_Link__c>	LinkList	{ get;set; }
    public string PageTitle						{ get;set; }
    public string PageStyle						{ get;set; } 
    
    public HL_CompanyReportLinks(Apexpages.StandardController con)
    {
        Account currAccount;
        string CompanyID;
        string ShortCompanyID;
        
        try
        {
            currAccount =  [SELECT Id, Name, Full_Account_ID__c FROM Account WHERE ID =: con.getId()];
            CompanyID = currAccount.Full_Account_ID__c;
			ShortCompanyID = String.valueOf(currAccount.Id).substring(0,15);            
        }
        catch(Exception ex)
        {
            currAccount = null;
            CompanyID = null;
			ShortCompanyID = null;            
        }
        
        if(!String.isBlank(CompanyID))
        {
            LinkList = HL_ReportLink.GetByType('Company Single');
            
            for(HL_Report_Link__c currLink: LinkList){            
                currLink.Report_Link_URL__c = currLink.Report_Link_URL__c.replace('{!Account.Full_Account_ID__c}', CompanyID)
            															 .replace('{!Account.Id}', ShortCompanyID);
            }
            PageTitle = 'Company Reports for ' + currAccount.Name;
            PageStyle = 'display:initial;';             
        }
        else  
        {
       		LinkList = HL_ReportLink.GetByType('Company Group');
            
            PageTitle = 'Company Reports';
            PageStyle = 'display:none;';            
        }        
    }
    
    public HL_CompanyReportLinks(){}
    
    public Pagereference ReturnToParent()
    {
        Pagereference pageref = new Pagereference('/' + ApexPages.currentPage().getParameters().get('id'));
	   	return pageref;
    }    
}