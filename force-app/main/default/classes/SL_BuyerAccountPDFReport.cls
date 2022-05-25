/**  
* \arg ClassName        : SL_BuyerAccountPDFReport 
* \arg JIRATicket       : HL-38
* \arg CreatedOn        : 30/OCT/2014
* \arg LastModifiedOn   : 30/OCT/2014
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : -
* \arg Description      : controller for SL_BuyerAccountListPDFReport report.
*/
public with sharing class SL_BuyerAccountPDFReport extends SL_ReportWrapper
{
    /* Start - Variables */
    public List<SelectOption> lstBuyerType			{	get;set;	}
    public List<SelectOption> lstPhaseStatus		{	get;set;	}  
    public List<SelectOption> lstDealRanking		{	get;set;	}
    public String strBuyerType						{	get;set;	}
    public String strDealRanking					{	get;set;	}
    public String strReportName						{	get;set;	}
    public String strExDiss							{	get;set;	}
    public String strInDiss							{	get;set;	}
    public String strHLCon							{	get;set;	}
    public String strDlRank							{	get;set;	}
    public String strPhFax							{	get;set;	}
    public String strSortColumn						{	get;set;	}
    public String strPhaseStatus					{	get;set;	}
    public Engagement__c objEngagement              {	get;set;	}
    public String strSelectedContact				{	get;set;	}
    public List<String> lstContactNames             {	get;set;	}
    private Set<String> setContactIds;
    private Map<String, Schema.SObjectType> mapGlobalDescribe;//!< Describe map to get the fields, fieldset and picklist values etc...
    /* End - Variables */
    
    /* Start - Constructor */  
    public SL_BuyerAccountPDFReport(ApexPages.StandardController std)       
    {
        super(std);
        initialize();
        objEngagement = getEngagement();
        lstBuyerType = getPicklistValues('Engagement_Counterparty__c', 'Type__c');  
    	lstPhaseStatus = getPicklistValues('Engagement_Counterparty__c', 'Status_pl__c'); 
    	lstDealRanking = getPicklistValues('Engagement_Counterparty__c', 'Tier__c');
    }
    /* End - Constructor */  
    
    /*   
        @MethodName : initialize.
        @param      : NA.
        @Description: This method will initialize the variables.
    */
    private void initialize()
    {
    	String strReportType = Apexpages.currentPage().getParameters().get('report');
    	strExDiss = 'false';
    	strInDiss = 'false';
    	strHLCon = 'true';
    	strPhFax = 'true';
    	strDlRank = 'true';
    	
    	if(strReportType == 'SL_BuyerAccountListShortPDFReport')
    		strReportName = 'ListShort1';	  
        else if(strReportType == 'SL_BuyerAccountListPDFReport')
        	strReportName = 'ListShort2';	
        else if(strReportType == 'SL_BuyerAccountListMediumPDFReport')
        	strReportName = 'ListMedium';	
		else if(strReportType == 'SL_BuyerAccountListRegularPDFReport')
			strReportName = 'ListRegular';	
    	mapGlobalDescribe = Schema.getGlobalDescribe();
    	lstBuyerType = new List<SelectOption>(); 
    	lstPhaseStatus = new List<SelectOption>();
    	lstDealRanking = new List<SelectOption>();
    	objEngagement = new Engagement__c();
    }
    /* End */
        
    /*   
        @MethodName : getBuyerAccountWrappers.
        @param      : NA.
        @Description: This will return the data for Buyer Account List PDF Report.
    */
    public List<BuyerAccountWrapper> getBuyerAccountWrappers()
    {
    	String strWhereClause = prepareWhereClause();
        
        String strQuery = 'SELECT Id, ' +getCSVCommonFields() + ' FROM Engagement_Counterparty__c '+  
        				  'WHERE Engagement__c = \''+Apexpages.currentPage().getParameters().get('id')+'\'' + strWhereClause;
        
        System.debug('====strQuery===='+strQuery);
        
        List<BuyerAccountWrapper> lstBuyerAccountWrapper = new List<BuyerAccountWrapper>();//List of BuyerAccountWrapper class
        
        //Iterating on Engagement_Counterparty__c to add the BuyerAccountWrapper object into list                 
        for(Engagement_Counterparty__c objEC : getCounterPartyRecords(strQuery))
        {
            lstBuyerAccountWrapper.add(new BuyerAccountWrapper(objEC, (objEC.Primary_Calling_Responsibility__r.Name != null &&  objEC.Coverage_Officer__r.Name != null) 
																	  ? objEC.Primary_Calling_Responsibility__r.Name + '<br></br><br></br>' + objEC.Coverage_Officer__r.Name
																	  : (objEC.Primary_Calling_Responsibility__r.Name == null &&  objEC.Coverage_Officer__r.Name != null)
																	  ? objEC.Coverage_Officer__r.Name 
																	  : (objEC.Primary_Calling_Responsibility__r.Name != null &&  objEC.Coverage_Officer__r.Name == null)
																	  ? objEC.Primary_Calling_Responsibility__r.Name : ''));
        }
        return lstBuyerAccountWrapper;
    }
    /* End */
    
    /*   
        @MethodName : getBuyerAccountMediumWrappers.
        @param      : NA.
        @Description: This will return the data for Buyer Account List Medium PDF Report.
    */
    public List<BuyerAccountMediumWrapper> getBuyerAccountMediumWrappers()
    {
    	String strWhereClause = prepareWhereClause();
    	List<BuyerAccountMediumWrapper> lstBuyerAccountMediumWrapper = new List<BuyerAccountMediumWrapper>();//List of BuyerAccountMediumWrapper class
        
        String strQuery = 'SELECT Id, Company__r.BillingStreet, Company__r.BillingCity, Company__r.Phone, Company__r.Fax, Company__r.Website, ' + 
        				  ' Company__r.BillingPostalCode, Company__r.BillingState, Company__r.BillingCountry, ' + 
        				  ' (SELECT Id, Contact__c, Contact__r.Name From Engagement_Counterparty_Contacts__r WHERE Contact__c != null), '+ getCSVCommonFields() +
        				  ' FROM Engagement_Counterparty__c WHERE Engagement__c = \''+Apexpages.currentPage().getParameters().get('id')+'\'' + strWhereClause;
        
        System.debug('=====strQuery===='+strQuery);
        
        //Iterating on Engagement_Counterparty__c to add the BuyerAccountMediumWrapper object into list				  
        for(Engagement_Counterparty__c objEC : getCounterPartyRecords(strQuery))
        {
        	Map<Id, Engagement_Counterparty_Contact__c> mapContactIdToECC = new Map<Id, Engagement_Counterparty_Contact__c>();
        	//Iterating on the Engagement_Counterparty_Contact__c to avoid the duplicate contact informations
        	for(Engagement_Counterparty_Contact__c objECC : objEC.Engagement_Counterparty_Contacts__r)
        	{
        		mapContactIdToECC.put(objECC.Contact__r.Id, objECC);
        	}
        	
            lstBuyerAccountMediumWrapper.add(new BuyerAccountMediumWrapper(new BuyerAccountWrapper(objEC, (objEC.Primary_Calling_Responsibility__r.Name != null &&  objEC.Coverage_Officer__r.Name != null) 
            																							  ? objEC.Primary_Calling_Responsibility__r.Name + '<br></br><br></br>' + objEC.Coverage_Officer__r.Name
            																							  : (objEC.Primary_Calling_Responsibility__r.Name == null &&  objEC.Coverage_Officer__r.Name != null)
            																							  ? objEC.Coverage_Officer__r.Name 
            																							  : (objEC.Primary_Calling_Responsibility__r.Name != null &&  objEC.Coverage_Officer__r.Name == null)
            																							  ? objEC.Primary_Calling_Responsibility__r.Name : ''), 
                                             mapContactIdToECC.values(), 
                                             getAddress(objEC.Company__r.BillingStreet, objEC.Company__r.BillingCity, 
                                                        objEC.Company__r.BillingPostalCode, objEC.Company__r.BillingState, 
                                                        objEC.Company__r.BillingCountry, objEC.Company__r.Phone, 
                                                        objEC.Company__r.Fax, objEC.Company__r.Website)));
        }				  
    	return lstBuyerAccountMediumWrapper;
    }
    /* End */
    
    /*   
        @MethodName : getBuyerAccountRegularWrappers.
        @param      : NA.
        @Description: This will return the data for Buyer Account List Rewgular PDF Report.
    */
    public List<BuyerAccountRegularWrapper> getBuyerAccountRegularWrappers()
    {
    	String strWhereClause = prepareWhereClause();
    	List<BuyerAccountRegularWrapper> lstBuyerAccountRegularWrapper = new List<BuyerAccountRegularWrapper>();//List of BuyerAccountRegularWrapper
        
        String strQuery = 'SELECT Id, Company__r.BillingStreet, Company__r.BillingCity, Company__r.Phone, Company__r.Fax, Company__r.Website, Company__r.Ownership,' + 
        				  ' Company__r.BillingPostalCode, Company__r.BillingState, Company__r.BillingCountry, Company__r.ShippingCountry, Company__r.Description,'+
        				  ' Company__r.ShippingPostalCode, Company__r.ShippingState, Company__r.ShippingCity, Company__r.ShippingStreet, Company__c,' + 
        				  ' (SELECT Id, Contact__r.LeadSource, Contact__r.Email, Contact__r.MobilePhone, Contact__r.Phone, Contact__r.Fax, Contact__r.Name, '+
        				  ' Contact__c From Engagement_Counterparty_Contacts__r WHERE Contact__c != null), '+ getCSVCommonFields() +
        				  ' FROM Engagement_Counterparty__c WHERE Engagement__c = \''+Apexpages.currentPage().getParameters().get('id')+'\'' + strWhereClause;
        
        System.debug('=====strQuery===='+strQuery);
        
        //Iterating on Engagement_Counterparty__c to add BuyerAccountRegularWrapper object into list				  
        for(Engagement_Counterparty__c objEC : getCounterPartyRecords(strQuery))
        {
        	Map<Id, Engagement_Counterparty_Contact__c> mapContactIdToECC = new Map<Id, Engagement_Counterparty_Contact__c>();//Map of contact id to Engagement_Counterparty_Contact__c
        	//Iterating on Engagement_Counterparty_Contact__c to avoid duplicate contact informations 
        	for(Engagement_Counterparty_Contact__c objECC : objEC.Engagement_Counterparty_Contacts__r)
        	{
        		mapContactIdToECC.put(objECC.Contact__r.Id, objECC);
        	}
        	
            lstBuyerAccountRegularWrapper.add(new BuyerAccountRegularWrapper(new BuyerAccountWrapper(objEC, (objEC.Primary_Calling_Responsibility__r.Name != null &&  objEC.Coverage_Officer__r.Name != null) 
            																								? objEC.Primary_Calling_Responsibility__r.Name + '<br></br><br></br>' + objEC.Coverage_Officer__r.Name
            																								: (objEC.Primary_Calling_Responsibility__r.Name == null &&  objEC.Coverage_Officer__r.Name != null)
            																								? objEC.Coverage_Officer__r.Name 
            																								: (objEC.Primary_Calling_Responsibility__r.Name != null &&  objEC.Coverage_Officer__r.Name == null)
            																								? objEC.Primary_Calling_Responsibility__r.Name : ''),   
																                                              mapContactIdToECC.values(), 
																                                              getRegularAddress(objEC.Company__r.BillingStreet, objEC.Company__r.BillingCity, 
																                                                                objEC.Company__r.BillingPostalCode, objEC.Company__r.BillingState, 
																                                                                objEC.Company__r.BillingCountry, objEC.Company__r.Phone, 
																                                                                objEC.Company__r.Fax, objEC.Company__r.Website),
																                                              getRegularAddress(objEC.Company__r.ShippingStreet, objEC.Company__r.ShippingCity, 
																                                                                objEC.Company__r.ShippingPostalCode, objEC.Company__r.ShippingState, 
																                                                                objEC.Company__r.ShippingCountry,'','',''), ''));
        }				  
    	return lstBuyerAccountRegularWrapper;
    }
    /* End */
    
    /*   
        @MethodName : getReportVersions.
        @param      : NA.
        @Description: This method will get report names.
    */
    public List<SelectOption> getReportVersions()
    {
    	return new List<SelectOption>{new SelectOption('ListShort1', 'Short #1'), new SelectOption('ListShort2', 'Short #2'),
    								  new SelectOption('ListMedium', 'Medium'), new SelectOption('ListRegular', 'Regular')};
    }
    /* End */
    
    public List<Selectoption> getIsPrintColumn()
 	{
	  	return new List<Selectoption>{new Selectoption('true','Yes'), new Selectoption('false','No')};
	}
	/* End */
	
    /*
        @MethodName : getPicklistValue 
        @param      : Sobject name and filed api name.
        @Description: method to get picklist value from field.
    */
    private List<SelectOption> getPicklistValues(String strSobjectName, String strFieldName)
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.SObjectType targetType = mapGlobalDescribe.get(strSobjectName);//!< From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //!< grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //!< describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //!< get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(strFieldName).getDescribe().getPickListValues(); 
        
        options.add(new SelectOption('all', 'All'));                                                //!< grab the list of picklist values for the passed field on the sobject
        
        for (Schema.PicklistEntry a : pick_list_values) 
        { 
            options.add(new SelectOption(a.getValue(), a.getLabel()));
        }
        return options;
    }
    /* End */
    
    /*
        @MethodName : getSortingColumns 
        @param      : NA.
        @Description: method to all columns name for sorting on the page.
    */
    public List<SelectOption> getSortingColumns()
    {
    	return new List<SelectOption>{new SelectOption('Company__r.Name', 'Company Name'), new SelectOption('Type__c', 'Type'),
    								  new SelectOption('Tier__c', 'Tier'), new SelectOption('Initial_Contact__c', 'Init Cont.'),
    								  new SelectOption('Phone_Discussion__c', 'Phone Disc'),
    								  new SelectOption('Sent_Teaser__c', 'Sent Teaser'), new SelectOption('Confidentiality_Agreement__c', 'Sent CA'),
    								  new SelectOption('Executed_Confidentiality_Agreement__c', 'Exec. CA'), new SelectOption('Sent_Book__c', 'Sent Book'),
    								  new SelectOption('Process_Letter_Sent__c', 'Proc. Ltr.'), new SelectOption('Sent_Blow_up_Letter__c', 'Sent Blow'),
    								  new SelectOption('Book_Returned__c', 'Book Ret.'), new SelectOption('Proposal_Indication__c', 'Rec. Prop.'),
    								  new SelectOption('Met_With_Management__c', 'Met w/Mgm'), new SelectOption('Letter_of_Intent__c', 'Rec. LOI'),
    								  new SelectOption('Declined_Passed__c', 'Pass Decl.')};
    }
    /* End */
    
    /*  
     @MethodName   : generateReport
     @param        : None
     @Description  : This method will call from page to generate the report.
    */
    public PageReference generateReport()
    {
        try
        {   
            PageReference reportPage;
        	setContactIds = new Set<String>();
	    	
	    	for(String strContactId : strSelectedContact.split(','))
	    	{
	    		setContactIds.add(strContactId);
	    	}
            
            if(strReportName == 'ListShort1')  
                reportPage = new PageReference('/apex/SL_BuyerAccountListShortPDFReport');
            else if(strReportName == 'ListShort2')
                reportPage = new PageReference('/apex/SL_BuyerAccountListPDFReport');
            else if(strReportName == 'ListMedium')
				reportPage = new PageReference('/apex/SL_BuyerAccountListMediumPDFReport');
			else if(strReportName == 'ListRegular')
				reportPage = new PageReference('/apex/SL_BuyerAccountListRegularPDFReport');	            	    
            reportPage.setRedirect(false);
            return reportPage;
        }
        catch(Exception ex)
        {
            System.debug('================='+ex.getMessage()+'==============='+ex.getLineNumber());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,''+ ex.getMessage()));
            return null;
        }
    }
    /* End */
    
    /*  
     @MethodName   : prepareWhereClause
     @param        : Buyer report name
     @Description  : This method will prepare where clause for the getting the records.
    */
    private String prepareWhereClause()
    {
    	String strWhereClause = '';
    	
    	if(!String.isEmpty(strSelectedContact))
    	{
	    	String strInClause = inClause(setContactIds);
    		strWhereClause += ' AND ( Coverage_Officer__c IN ' + strInClause + ' OR Primary_Calling_Responsibility__c IN ' + strInClause + ' ) ';
    	}
    	
    	if(String.isNotEmpty(strBuyerType) && strBuyerType != 'all')
    		strWhereClause += ' AND Type__c = \'' + strBuyerType + '\'';
    	
    	if(String.isNotEmpty(strDealRanking) && strDealRanking != 'all' && strReportName != 'ListShort1')
    		strWhereClause += ' AND Tier__c = \'' + strDealRanking + '\'';
    	
    	if(String.isNotEmpty(strPhaseStatus) && strDealRanking != 'all')
    	    strWhereClause += ' AND Status_pl__c = \'' + strPhaseStatus + '\'';    
    	
    	if(String.isNotEmpty(strSortColumn))
    		strWhereClause += ' ORDER BY ' + strSortColumn + ' NULLS LAST ';	
    	return strWhereClause;
    }
    /* End */
    
    /*  
     @MethodName   : getEngagementName
     @param        : NA
     @Description  : This method will get the engagement details.
    */
    public Engagement__c getEngagement() 
    {
    	return [SELECT Id, 
			  	     Client__r.Name,
			  	     Subject__r.Name,
			  	     Name,
			  	     Engagement_Number__c,
			  	     Job_Type__c 
			    FROM Engagement__c 
			   WHERE Id =: Apexpages.currentPage().getParameters().get('id')];
    }
    /* End */
    
    /*  
     @MethodName   : getHLContacts
     @param        : NA
     @Description  : This method will create JSON data for all the houlihan contact id and names.
    */
    public String getHLContacts()
    {
        String recordTypeId = [SELECT Id  FROM RecordType  WHERE RecordType.DeveloperName = 'Houlihan_Employee'].Id;   
    	String strContactJSON = '[';
    	try
    	{
	        for(Contact objContact : [SELECT Id, 
	                                         Name 
	                                    FROM Contact 
	                                   WHERE RecordTypeId =: recordTypeId])
	        {
	        	strContactJSON += ',{id:"' + objContact.Id + '", name:"' + objContact.Name + '"}';
	        }
	        strContactJSON = strContactJSON.replaceFirst(',', '') + ']';
	        return strContactJSON;
    	}
    	catch(Exception e)
        {
            return strContactJSON;
        }         
    }
    /* End */
    
    /*
        @MethodName : inClause.
        @param      : Set of string.
        @Description: to prepare the IN clause for Line_of_Business__c picklist values.
    */
    public String inClause(Set<String> setString) 
    {
	    String strInClaus = '';
	    for(String str : setString)
	    {
	    	strInClaus += ','+'\''+ str +'\'';
	    }	
	    strInClaus = strInClaus.replaceFirst(',', '');
	    strInClaus = '('+ strInClaus + ')';
	    return strInClaus;
	}
	/* End */
}
/* End */