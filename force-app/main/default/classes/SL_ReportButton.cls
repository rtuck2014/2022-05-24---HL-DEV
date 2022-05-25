/**
* @ClassName 		: SL_ReportButton
* @JIRATicket   	: HL-3
* @CreatedOn    	: 25/AUG/2014
* @ModifiedBy   	: Lodhi
* @Description 	 	: Controller class for SL_ReportButton component
*/
public with sharing class SL_ReportButton 
{
	/* Start - Variables */
	/* End - Variables */
	
	/* Start - Constructor */
	public SL_ReportButton()
	{
		//do nothing.
	}
	/* End - Constructor */
	
	public static Pagereference generateReport(String strImplementationId, String strImplementationName, String strParentId)
	{
		List<SL_View__c> lstView = [SELECT Id, 
						  				   RowsCount__c, 
										   Columns__c 
									  FROM SL_View__c
									 WHERE Implementation__c =: strImplementationId
									   AND Implementation_Type__c = 'Target'
									   AND Name =: strImplementationName
									   AND (User__c =: UserInfo.getUserId() OR IsDefault__c =: true)];
		if(!lstView.isEmpty())
			return new PageReference('/apex/SL_Racetrack_Report_Pdf?viewId='+lstView[0].Id + '&parentId='+strParentId+'&ImpId='+strImplementationId);
		else
			return null;								   
	}
}
/*End */