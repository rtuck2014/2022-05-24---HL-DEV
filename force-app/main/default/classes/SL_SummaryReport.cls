/**  
* \arg ClassName        : SL_BuyerAccountPDFReport 
* \arg JIRATicket       : HL-38
* \arg CreatedOn        : 30/OCT/2014
* \arg LastModifiedOn   : 30/OCT/2014
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : -
* \arg Description      : controller for SL_BuyerAccountListPDFReport report.
*/
public with sharing class SL_SummaryReport extends SL_ReportWrapper  
{
	/* Start - Variables */
	public List<SummaryColumns> lstColumns 							{	get;	private set;	}//List of SummaryColumns wrapper class
	public List<StatusWrapper> lstSummaryReport						{	get; 	private set;	}//List of StatusWrapper class
	public Map<String, Integer> mapStatusToTotal					{	get; 	private set;	}//Map of counterparty status to total no of records
	public List<SummarySubTotalWrapper> lstSummarySubTotalWrapper	{	get; 	private set;	}//List of SummarySubTotalWrapper class
	public List<SummaryTotalWrapper> lstSummaryTotalWrapper			{	get; 	private set;	}//List of SummaryTotalWrapper class
	
	
    /* End - Variables */
    
    /* Start - Constructor */  
    public SL_SummaryReport(ApexPages.StandardController std)  
    {
        super(std); 
        lstSummaryReport = getSummaryReportInformation();
    }
    /* End - Constructor */
    
    /*  
     @MethodName   : getSummaryReportInformation
     @param        : NA.
     @Description  : This method will return the list of StatusWrapper.
    */
    private List<StatusWrapper> getSummaryReportInformation()
    {
    	List<StatusWrapper> lstStatusWrapper = new List<StatusWrapper>();//List of StatusWrapper
    	try
    	{
	    	Map<String, Map<String, List<String>>> mapStatus_Type_LstAccountName = new Map<String, Map<String, List<String>>>();//Map of counterparty status to map of type to list of account name
	    	Map<String, Integer> mapType_StatusToTotal = new Map<String, Integer>();//Map of string combination of type and status to total no of records on the basis of type 
	    	List<String> lstTypeValues = getPicklistValue('Engagement_Counterparty__c', 'Type__c');//getting the counterparty Type__c picklist values    
	    	List<String> lstStatusValues = getPicklistValue('Engagement_Counterparty__c', 'Status_pl__c');//getting the counterparty Status_pl__c picklist values
	    	lstColumns = new List<SummaryColumns>();//List of SummaryColumns wrapper class
	    	lstSummarySubTotalWrapper = new List<SummarySubTotalWrapper>();//List of SummarySubTotalWrapper class
	    	lstSummaryTotalWrapper = new List<SummaryTotalWrapper>();//List of SummaryTotalWrapper class
	    	mapStatusToTotal = new Map<String, Integer>();//Map of counterparty status to total no of records
	    	
	    	Set<String> setStatus = new Set<String>();//Set of counterparty status
	    	setStatus.addAll(lstStatusValues);
	    	
	    	Set<String> setAvoidDuplicate = new Set<String>();//Set of string to avoid duplicate company names
	    	
	    	//Iterating on Engagement_Counterparty__c for preparing the map of counterparty status to map of type to list of company name
	    	for(Engagement_Counterparty__c objEC : [SELECT Id, 
	    												   Status__c,   
	    												   Status_pl__c, 
	    												   Type__c, 
	    												   Company__c, 
	    												   Company__r.Name 
	    											  FROM Engagement_Counterparty__c 
	    											 WHERE Engagement__c =: Apexpages.currentPage().getParameters().get('id')
	    											   AND Company__c != NULL
	    											   AND Type__c != NULL
	    										  ORDER BY Company__r.Name])
	    	{
	    		String strStatus = (setStatus.contains(objEC.Status__c) ? objEC.Status__c : 'No Status');
	    		
	    		if(!mapStatus_Type_LstAccountName.containsKey(strStatus))
	    			mapStatus_Type_LstAccountName.put(strStatus, new Map<String, List<String>>());
	    		
	    		if(!mapStatus_Type_LstAccountName.get(strStatus).containsKey(objEC.Type__c))
	    			mapStatus_Type_LstAccountName.get(strStatus).put(objEC.Type__c, new List<String>{objEC.Company__r.Name});
	    		else if(!setAvoidDuplicate.contains(strStatus +'_'+ objEC.Type__c +'_'+ objEC.Company__c))
	    			mapStatus_Type_LstAccountName.get(strStatus).get(objEC.Type__c).add(objEC.Company__r.Name);
	    		
	    		setAvoidDuplicate.add(strStatus +'_'+ objEC.Type__c +'_'+ objEC.Company__c);
	    	}
	    	  
	    	Integer counter = 1;
	    	if(mapStatus_Type_LstAccountName.containsKey('No Status'))
	    	{
	    		lstColumns.add(new SummaryColumns('No Status', counter++));
	    		List<TypeWrapper> lstTypeWrapper = new List<TypeWrapper>();
	    		Integer intGTotal = 0;
	    		//Iterating on list of counterparty type values
	    		for(String strType : lstTypeValues)
	    		{
	    			if(!mapType_StatusToTotal.containsKey(strType + '_' + 'No Status'))
	    				mapType_StatusToTotal.put(strType + '_' + 'No Status', 0);
	    				
	    			if(mapStatus_Type_LstAccountName.get('No Status').containsKey(strType))
	    			{
	    				intGTotal += mapStatus_Type_LstAccountName.get('No Status').get(strType).size();
	    				mapType_StatusToTotal.put(strType + '_' + 'No Status', 
	    											mapType_StatusToTotal.get(strType + '_' + 'No Status') + mapStatus_Type_LstAccountName.get('No Status').get(strType).size());
	    				lstTypeWrapper.add(new TypeWrapper(strType, mapStatus_Type_LstAccountName.get('No Status').get(strType)));
	    			}
	    			else
	    			{
	    				lstTypeWrapper.add(new TypeWrapper(strType, new List<String>()));
	    			}
	    		}
	    		lstStatusWrapper.add(new StatusWrapper('No Status', intGTotal, lstTypeWrapper));
	    		mapStatusToTotal.put('No Status', intGTotal);
	    	}
	    	
	    	//Iterating on counterparty status values for adding the typewrapper and StatusWrapper object into list
	    	for(String strStatus : lstStatusValues)
	    	{
	    		if(!mapStatus_Type_LstAccountName.containsKey(strStatus))
	    			continue;
	    		lstColumns.add(new SummaryColumns(strStatus, counter++));
	    		List<TypeWrapper> lstTypeWrapper = new List<TypeWrapper>();
	    		Integer intGTotal = 0;
	    		//Iterating on list of counterparty type values for adding the typewrapper object into list
	    		for(String strType : lstTypeValues)
	    		{
	    			if(!mapType_StatusToTotal.containsKey(strType + '_' + strStatus))
	    				mapType_StatusToTotal.put(strType + '_' + strStatus, 0);
	    				
	    			if(mapStatus_Type_LstAccountName.get(strStatus).containsKey(strType))
	    			{
	    				intGTotal += mapStatus_Type_LstAccountName.get(strStatus).get(strType).size();
	    				mapType_StatusToTotal.put(strType + '_' + strStatus, 
	    											mapType_StatusToTotal.get(strType + '_' + strStatus) + mapStatus_Type_LstAccountName.get(strStatus).get(strType).size());
	    				lstTypeWrapper.add(new TypeWrapper(strType, mapStatus_Type_LstAccountName.get(strStatus).get(strType)));
	    			}
	    			else
	    			{
	    				lstTypeWrapper.add(new TypeWrapper(strType, new List<String>()));
	    			}
	    		}
	    		mapStatusToTotal.put(strStatus, intGTotal);
	    		lstStatusWrapper.add(new StatusWrapper(strStatus, intGTotal, lstTypeWrapper));
	    	}
	    	
	    	//Iterating on list of counterparty type values
	    	for(String strType : lstTypeValues)
	    	{
	    		Map<String, Integer> mapStatusToTotal = new Map<String, Integer>();
	    		Integer intTotal = 0;
	    		Boolean isValid = false;
	    		//Iterating on list of SummaryColumns wrapper class for adding the SummarySubTotalWrapper and SummaryTotalWrapper into list
	    		for(SummaryColumns status : lstColumns)
	    		{
	    			if(mapType_StatusToTotal.containsKey(strType +'_'+ status.strLabel))
	    			{
	    				if(mapType_StatusToTotal.get(strType +'_'+ status.strLabel) > 0)
	    					isValid = true;
	    					
	    				intTotal += mapType_StatusToTotal.get(strType +'_'+ status.strLabel);
	    				mapStatusToTotal.put(status.strLabel, mapType_StatusToTotal.get(strType +'_'+ status.strLabel));
	    			}
	    		}
	    		if(isValid)
	    		{
	    			lstSummarySubTotalWrapper.add(new SummarySubTotalWrapper((strType != 'Capital Provider') ? strType : 'Cap Prov', mapStatusToTotal));
	    			lstSummaryTotalWrapper.add(new SummaryTotalWrapper((strType != 'Capital Provider') ? strType : 'Cap Prov', intTotal));
	    		}
	    	}
    	}
    	catch(Exception ex)
    	{
    		System.debug('=============ex==========='+ex.getlineNumber());	
    	}
    	return lstStatusWrapper;
    }
    /* End */
}
/* End */