/**  
* \arg ClassName		: SL_BuyerAccountListPDFReport
* \arg JIRATicket		: HL-38
* \arg CreatedOn		: 30/OCT/2014
* \arg LastModifiedOn	: 30/OCT/2014
* \arg CreatededBy		: Lodhi
* \arg ModifiedBy		: -
* \arg Description		: controller for SL_BuyerAccountListPDFReport report.
*/
public with sharing class SL_BuyerAccountListPDFReport extends SL_ReportWrapper
{
	/* Start - Variables */
	/* End - Variables */
	
	/* Start - Constructor */  
	public SL_BuyerAccountListPDFReport(ApexPages.StandardController std)
	{
		super(std);  
	}
	/* End - Constructor */  
	    
	/*   
        @MethodName : getBuyerAccountWrappers.
        @param      : NA.
        @Description: This will return the data for Buyer Account List PDF Report.
    */
    public List<BuyerAccountWrapper> getBuyerAccountWrappers()
    {
    	String strQuery = 'SELECT Id, ' +getCSVCommonFields() + ' FROM Engagement_Counterparty__c WHERE Engagement__c = \''+Apexpages.currentPage().getParameters().get('id')+'\'';
    	
    	List<BuyerAccountWrapper> lstBuyerAccountWrapper = new List<BuyerAccountWrapper>();				  
    	for(Engagement_Counterparty__c objEC : getCounterPartyRecords(strQuery))
    	{
    		lstBuyerAccountWrapper.add(new BuyerAccountWrapper(objEC, objEC.Secondary_HL_Contact__r.Name));
    	}
    	return lstBuyerAccountWrapper;
    }
    
    /* End */
	
	
	
}