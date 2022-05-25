/**  
* \arg ClassName		: SL_ReportWrapper
* \arg JIRATicket		: HL-38
* \arg CreatedOn		: 30/OCT/2014
* \arg LastModifiedOn	: 30/OCT/2014
* \arg CreatededBy		: Lodhi
* \arg ModifiedBy		: -
* \arg Description		: This class will have all the wrapper class which is going to use in HL-35 task.
*/
public abstract with sharing class SL_ReportWrapper  
{
	/* Start - Variables*/
	public Engagement__c engagement								{	get;	private set;	}
	
	Map<String, Schema.SObjectType> mapGlobalDescribe;
	/* End Variable */
	
	/* Start - Constructor */
	public SL_ReportWrapper(ApexPages.StandardController std)
	{
		mapGlobalDescribe = Schema.getGlobalDescribe();
		List<Engagement__c> lstEngagement = [SELECT Id, Name FROM Engagement__c WHERE Id =: std.getId()];
		if(lstEngagement.isEmpty())
			engagement = new Engagement__c();
		else 	
			engagement = lstEngagement[0];
	}
	/* End - Constructor */
	
	//////////WRAPPER CLASSES/////////
	
	/* Start - Wrapper class for columns on the report */
	public class ColumnWrapper
	{
		public String strLabel									{	get; 	private set;	}//to store column label 
		public String strAPIName								{	get; 	private set;	}//to store column api name 
		public String strFieldType								{	get; 	private set;	}//to store column type 
		
		public ColumnWrapper(String strLabel, String strAPIName, String strFieldType)
		{
			this.strLabel = strLabel;
			this.strAPIName = strAPIName;
			this.strFieldType = strFieldType;
		}
	}
	/* End - Wrapper class for columns on the report */
	
	/* Start - Wrapper class for Address on the report */
	public class Address
	{
		public String strLocation								{	get; 	private set;	}//to store location
		public String strPhone									{	get; 	private set;	}//to store phone number
		public String strFax									{	get; 	private set;	}//to store fax number
		public String strWebsite								{	get; 	private set;	}//to store website
		
		public Address(String strLocation, String strPhone, String strFax, String strWebsite)
		{
			this.strLocation = strLocation;
			this.strPhone = strPhone;
			this.strFax = strFax;
			this.strWebsite = strWebsite;
		}
	}
	/* End - Wrapper class for Address on the report */
	
	//HL-38
	/* Start - Wrapper class for binding the hl contact name with engagement counterparty on the report */
	public class BuyerAccountWrapper
	{
		public Engagement_Counterparty__c ECounterparty			{	get;	private set;	}
		public String HLContact									{	get; 	private set;	}
		
		public BuyerAccountWrapper(Engagement_Counterparty__c ECounterparty, String HLContact)
		{
			this.ECounterparty = ECounterparty;
			this.HLContact = HLContact;
		}
	}
	/* End - Wrapper class for binding the hl contact name with engagement counterparty on the report */
	
	//HL-39
	/* Start - Wrapper class for binding the list of company name with engagement counterparty type on the report */
	public class TypeWrapper
    {
    	public String strType									{	get;	private set;	}
    	public List<String> lstCompanyName						{	get;	private set;	}
    	
    	public TypeWrapper(String strType, List<String> lstCompanyName)
    	{
    		this.strType = strType;
    		this.lstCompanyName = lstCompanyName;
    	}
    }
    /* End - Wrapper class for binding the list of company name with engagement counterparty type on the report */
    
    /* Start - Wrapper class for binding status type, total no of records in column, 
       		   list of type wrapper class and map of type to total no of records */
    public class StatusWrapper
    {
    	public String strStatus									{	get;	private set;	}
    	public Integer intGTotal								{	get;	private set;	}
    	public List<TypeWrapper> lstTypeWrapper					{	get;	private set;	}
    	
    	public StatusWrapper(String strStatus, Integer intGTotal, List<TypeWrapper> lstTypeWrapper)
    	{
    		this.strStatus = strStatus;
    		this.lstTypeWrapper = lstTypeWrapper;
    		this.intGTotal = intGTotal;
    	}
    }
	/* End - Wrapper class for binding status type, total no of records in column, 
       		 list of type wrapper class and map of type to total no of records */	
    
    /* Start - Wrapper class for binding the counterparty type to map of status type to total counterparty records */		 
   	public class SummarySubTotalWrapper
    {
    	public String strType									{	get;	private set;	}
    	public Map<String, Integer> mapStatusToTotal			{	get;	private set;	}
    	
    	public SummarySubTotalWrapper(String strType, Map<String, Integer> mapStatusToTotal)
    	{
    		this.strType = strType;
    		this.mapStatusToTotal = mapStatusToTotal;
    	}
    }
    /* End - Wrapper class for binding the counterparty type to map of status type to total counterparty records */
    
    /* Start - Wrapper class for binding the counterparty type to total counterparty records on the basis of type */
    public class SummaryTotalWrapper
    {
    	public String strType									{	get;	private set;	}
    	public Integer total									{	get;	private set;	}
    	
    	public SummaryTotalWrapper(String strType, Integer total)
    	{
    		this.strType = strType;
    		this.total = total;
    	}
    }
    /* End - Wrapper class for binding the counterparty type to total counterparty records on the basis of type */
    
    /* Start - Wrapper class for binding the columns label with its index */
    public class SummaryColumns
    {
    	public String strLabel 										{	get;	private set;	}
    	public Integer index										{	get; 	private set;	}
    	
    	public SummaryColumns(String strLabel, Integer index)
    	{
    		this.strLabel = strLabel;
    		this.index = index;
    	}
    }
    /* End - Wrapper class for binding the columns label with its index */
	
	//HL-40
	/* Start - Wrapper class for binding the BuyerAccountWrapper with contact information and address */
	public class BuyerAccountMediumWrapper
	{
		public BuyerAccountWrapper objBAWrapper					{	get; 	private set;	}
		public List<Engagement_Counterparty_Contact__c> lstECC	{	get; 	private set;	}
		public Address objAddress								{	get; 	private set;	}
		
		public BuyerAccountMediumWrapper(BuyerAccountWrapper objBAWrapper, List<Engagement_Counterparty_Contact__c> lstECC	, Address objAddress)
		{
			this.objBAWrapper = objBAWrapper;
			this.lstECC = lstECC;
			this.objAddress = objAddress;
		}
	}
	/* End - Wrapper class for binding the BuyerAccountWrapper with contact information and address */
	
	//HL-41
	/* Start - Wrapper class for binding the BuyerAccountWrapper, contact information, permanent address, mailing address,
			   business description and discussion correspondence log on report */
	public class BuyerAccountRegularWrapper
	{
		public BuyerAccountWrapper objBAWrapper					{	get; 	private set;	}
		public List<Engagement_Counterparty_Contact__c> lstECC	{	get; 	private set;	}
		public Address objPermanentAddress						{	get;	private set;	}
		public Address objMailingAddress						{	get; 	private set;	}
		public String strDiscussionCorrespondenceLog			{	get; 	private set;	}
		
		public BuyerAccountRegularWrapper(BuyerAccountWrapper objBAWrapper, List<Engagement_Counterparty_Contact__c> lstECC, 
										  Address objPermanentAddress, Address objMailingAddress, String strDiscussionCorrespondenceLog)
		{
			this.objBAWrapper = objBAWrapper;
			this.lstECC = lstECC;
			this.objPermanentAddress = objPermanentAddress;
			this.objMailingAddress = objMailingAddress;
			this.strDiscussionCorrespondenceLog = strDiscussionCorrespondenceLog;
		}
	}
	/* End - Wrapper class for binding the BuyerAccountWrapper, contact information, permanent address, mailing address,
			 business description and discussion correspondence log on report */
	
    /*   
        @MethodName : getCounterPartyRecords.
        @param      : soql query
        @Description: This will return the all the engagement counterparty records.
    */
	public List<Engagement_Counterparty__c> getCounterPartyRecords(String strQuery)
	{
		return Database.query(strQuery);
	}
	/* End */
	
	/*   
        @MethodName : getCurrentDate.
        @param      : NA.
        @Description: This will return the current date on the report.
    */
	public String getCurrentDateTime()
	{
		return Datetime.now().format('MM/dd/yyyy hh:mm:ssa');
	}
	/* End */
	
	
	/*  
     @MethodName   : getPicklistValue
     @param        : Sobject and Pick list API name.
     @Description  : This method will return the list of SelectOption which will contains the picklist value to display on the page.
    */
	public List<String> getPicklistValue(String strSobjectName, String strFieldName)
	{
		List<String> lstPicklistValues = new List<String>();
		Schema.SObjectType targetType = mapGlobalDescribe.get(strSobjectName);//From the Object Api name retrieving the SObject
    	Sobject Object_name = targetType.newSObject();
 		Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
   		Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
   		Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
   		List<Schema.PicklistEntry> pick_list_values = field_map.get(strFieldName).getDescribe().getPickListValues(); 
   														//grab the list of picklist values for the passed field on the sobject
    	for (Schema.PicklistEntry a : pick_list_values) 
    	{ 
      		lstPicklistValues.add(a.getValue());
    	}
		return lstPicklistValues;
	}
	/* End */
	
	/*  
     @MethodName   : getAddress
     @param        : Street, city, postalcode, state, country, phone, fax, website.
     @Description  : This method will return the address for buyer account medium type pdf report.
    */
	public Address getAddress(String strStreet, String strCity, String strPostalCode, 
							  String strState, String strCountry, String strPhone, 
							  String strFax, String strWebsite)
	{
		String strLocation = (!String.isEmpty(strStreet)) ? strStreet : '';
		strLocation += (!String.isEmpty(strLocation) && !String.isEmpty(strCity)) ? '<br/>'+strCity : (String.isEmpty(strLocation) && !String.isEmpty(strCity)) ? strCity:'';
		strLocation += (!String.isEmpty(strLocation) && !String.isEmpty(strState) && !String.isEmpty(strPostalCode)) ? '<br/>'+ strState + ', ' + strPostalCode : 
					   (!String.isEmpty(strLocation) && !String.isEmpty(strState) && String.isEmpty(strPostalCode)) ? '<br/>'+ strState :
					   (!String.isEmpty(strLocation) && String.isEmpty(strState) && !String.isEmpty(strPostalCode)) ? '<br/>'+ strPostalCode : 
					   (String.isEmpty(strLocation) && !String.isEmpty(strState) && !String.isEmpty(strPostalCode)) ? strState + ', ' + strPostalCode :
					   (String.isEmpty(strLocation) && !String.isEmpty(strState) && String.isEmpty(strPostalCode)) ? strState :
					   (String.isEmpty(strLocation) && String.isEmpty(strState) && !String.isEmpty(strPostalCode)) ? strPostalCode : '';
					   
		strLocation += (!String.isEmpty(strLocation) && !String.isEmpty(strCountry)) ? '<br/>' + strCountry :
					   (String.isEmpty(strLocation) && !String.isEmpty(strCountry)) ? strCountry : '';
					   
		return new Address(strLocation, strPhone, strFax, strWebsite);
	}	
	/* End */
	
	/*  
     @MethodName   : getAddress
     @param        : Street, city, postalcode, state, country, phone, fax, website.
     @Description  : This method will return the address for buyer account regular type pdf report.
    */
	public Address getRegularAddress(String strStreet, String strCity, String strPostalCode, 
							  		 String strState, String strCountry, String strPhone, 
							  		 String strFax, String strWebsite)
	{
		String strLocation = (!String.isEmpty(strStreet)) ? strStreet : '';
		strLocation += (!String.isEmpty(strLocation) && !String.isEmpty(strCity)) ? '<br/>'+strCity : 
					   (String.isEmpty(strLocation) && !String.isEmpty(strCity)) ? strCity : 
					   (!String.isEmpty(strLocation) && String.isEmpty(strCity)) ? '<br/>': '';
		
		strLocation += (!String.isEmpty(strLocation) && !String.isEmpty(strState) && !String.isEmpty(strPostalCode)) ? ' '+ strState + ', ' + strPostalCode : 
					   (!String.isEmpty(strLocation) && !String.isEmpty(strState) && String.isEmpty(strPostalCode)) ? ' '+ strState :
					   (!String.isEmpty(strLocation) && String.isEmpty(strState) && !String.isEmpty(strPostalCode)) ? ' '+ strPostalCode : 
					   (String.isEmpty(strLocation) && !String.isEmpty(strState) && !String.isEmpty(strPostalCode)) ? strState + ', ' + strPostalCode :
					   (String.isEmpty(strLocation) && !String.isEmpty(strState) && String.isEmpty(strPostalCode)) ? strState :
					   (String.isEmpty(strLocation) && String.isEmpty(strState) && !String.isEmpty(strPostalCode)) ? strPostalCode : '';
					   
		strLocation += (!String.isEmpty(strLocation) && !String.isEmpty(strCountry)) ? '<br/>' + strCountry :
					   (String.isEmpty(strLocation) && !String.isEmpty(strCountry)) ? strCountry : '';
					   
		return new Address(strLocation, strPhone, strFax, strWebsite);
	}
	/* End */	
	
	/*   
        @MethodName : getCounterPartyRecords.
        @param      : NA.
        @Description: This will return the common fields.
    */
	public String getCSVCommonFields()
	{
		return 'Company__r.Name, Type__c, Tier__c, Phone_Discussion__c, Sent_Teaser__c, Confidentiality_Agreement__c, ' +
			   'Executed_Confidentiality_Agreement__c, Sent_Book__c, Process_Letter_Sent__c, Proposal_Indication__c, Initial_Contact__c, ' +
    		   'Book_Returned__c, Met_With_Management__c, Letter_of_Intent__c, Declined_Passed__c,Sent_Blow_up_Letter__c, ' +
    		   'Primary_Calling_Responsibility__c, Primary_Calling_Responsibility__r.Name, Coverage_Officer__c, Coverage_Officer__r.Name ';
	}
	/* End */
	
	/*   
        @MethodName : getColumnWrappers.
        @param      : NA.
        @Description: This will return all the columns with its label, api name and type of column.
    */
	public List<ColumnWrapper> getColumnWrappers()
	{
		return new List<ColumnWrapper>{
									  		new ColumnWrapper('Type', 'Type__c', 'Picklist'),
									  		new ColumnWrapper('Tier', 'Tier__c', 'Picklist'),
									  		new ColumnWrapper('HL Contacts', 'hlcontacts', 'String'),
									  		new ColumnWrapper('Init<br/>Cont.', 'Initial_Contact__c', 'DATE'),
									  		new ColumnWrapper('Phone<br/>Disc', 'Phone_Discussion__c', 'DATE'),
									  		new ColumnWrapper('Sent<br/>Teaser', 'Sent_Teaser__c', 'DATE'),
									  		new ColumnWrapper('Sent<br/>CA', 'Confidentiality_Agreement__c', 'DATE'),
									  		new ColumnWrapper('Rec.<br/>Mark', 'NA', 'DATE'),
									  		new ColumnWrapper('Exec.<br/>CA', 'Executed_Confidentiality_Agreement__c', 'DATE'),
									  		new ColumnWrapper('Sent<br/>Book', 'Sent_Book__c', 'DATE'),
									  		new ColumnWrapper('Proc.<br/>Ltr.', 'Process_Letter_Sent__c', 'DATE'),
									  		new ColumnWrapper('Sent<br/>Blow', 'Sent_Blow_up_Letter__c', 'DATE'),
									  		new ColumnWrapper('Book<br/>Ret.', 'Book_Returned__c', 'DATE'),
									  		new ColumnWrapper('Rec.<br/>Prop.', 'Proposal_Indication__c', 'DATE'),
									  		new ColumnWrapper('Met w/<br/>Mgm', 'Met_With_Management__c', 'DATE'),
									  		new ColumnWrapper('Rec.<br/>LOI', 'Letter_of_Intent__c', 'DATE'),
									  		new ColumnWrapper('Pass /<br/>Decl.', 'Declined_Passed__c', 'DATE')
								  	  };
	}
	/* End */
}