/**  
* \arg ClassName      : SL_ChangeColumns
* \arg JIRATicket     : HL-17
* \arg CreatedOn      : 4/JUNE/2014
* \arg LastModifiedOn : 4/JUNE/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : This is controller class for SL_ChangeColumns page.
*/
public with sharing class SL_ChangeColumns 
{
	/* Start Variables */
	public PicklistWrapper opportunityPicklist  			{   get;set;    }//!< Opportunity multiselected picklist.   
    public PicklistWrapper engagementPicklist   			{   get;set;    }//!< Engagement multiselected picklist.
    
    public string PageOppStyle  							{	get;set;	}
    public string PageEngStyle  							{	get;set;	}
    public string PageTitle 								{	get;set;	}
    private string lob									    {	get;set;	}
    private Pipeline_Column_Selection__c pcs;
    private Map<String, Schema.SObjectType> mapGlobalDescribe = Schema.getGlobalDescribe();
	/* End Variables */ 
	
	/* Start - Constructor */
    public SL_ChangeColumns() 
    {
    	try
    	{
            Contact c = HL_Contact.GetByUserId(); 
        	lob = c.Line_Of_Business__c;
            
	    	pcs = getPCS();
	    	opportunityPicklist = getPicklistValues((pcs.Opportunity_Columns__c != null) ? pcs.Opportunity_Columns__c.split(',') : new List<String>(), 'Opportunity__c');
		    engagementPicklist = getPicklistValues(((pcs.Engagement_Columns__c != null)) ? pcs.Engagement_Columns__c.split(',') : new List<String>(), 'Engagement__c');
            if(ApexPages.currentPage().getParameters().get('pagetype')=='opp')
            {
                PageTitle = 'Customize Opportunity Manager Columns';
                PageOppStyle = 'display:initial;';
                PageEngStyle = 'display:none;';
            }
            else
            {
                PageTitle = 'Customize Engagement Manager Columns';
                PageOppStyle = 'display:none;';
                PageEngStyle = 'display:initial;';
            }            
    	}
    	
    	catch(Exception e)
       	{
       		system.debug('======Exception======'+e.getMessage() +'======Linenumber======'+ e.getlineNumber());
		}
    }
    /* End - Constructor */
    
    /* Start - Wrapper Class for Picklist */
    public class PicklistWrapper
    {
        public List<SelectOption> allValues     {   get;set;    }
        public List<SelectOption> selectedValues{   get;set;    }
        
        public PicklistWrapper(List<SelectOption> allValues, List<SelectOption> selectedValues)
        {
            this.allValues = allValues;
            this.selectedValues = selectedValues;
        }
    }
    /* End - Wrapper Class for Picklist */
    
    /* 
        @MethodName : getPCS.
        @param      : NA.
        @Description: to insert fields of selected from the picklist in the Pipeline_Column_Selection__c.
    */
    private Pipeline_Column_Selection__c getPCS()
    {
    	List<Pipeline_Column_Selection__c> lstPCS = [SELECT Id, 
    														Engagement_Columns__c, 
    														Opportunity_Columns__c 
    												   FROM Pipeline_Column_Selection__c
    												  WHERE User__c =: Userinfo.getUserId() LIMIT 1];
       
    	if(lstPCS.isEmpty())
    		return SL_PipelineManager.GetDefaultPCS(mapGlobalDescribe, lob);
    	else
    		return lstPCS[0];
    }
    /* End */
    
    /* 
        @MethodName : getPicklistValues.
        @param      : Set of selected fields and sobject name.
        @Description: to get the options to display the engagements records.
    */
   private PicklistWrapper getPicklistValues(List<String> lstSelectedFields, String SobjectName)
   { 
        List<SelectOption> optionsSelected = new List<SelectOption>();
        List<SelectOption> optionsAvailable = new List<SelectOption>();
        Schema.FieldSet fieldSetObj = SL_PipelineManager.GetPipelineFS(mapGlobalDescribe, SobjectName, 'Available_Pipeline_Columns_', lob);
        Set<String> setSelectedFields = new Set<String>();
        setSelectedFields.addAll(lstSelectedFields);
        
        for(Schema.FieldSetMember objFSM : fieldSetObj.getFields())
        {
        	if(objFSM.getFieldPath().contains('.'))
    		{
    			String strParentRelation = objFSM.getFieldPath().split('\\.')[0].replace('__r','__c');  
	            String strFieldAPIName = objFSM.getFieldPath().split('\\.')[1];
	            if( mapGlobalDescribe.get(SobjectName).getDescribe().fields.getMap().containsKey(strParentRelation.trim()))
	            {
	            	Schema.SObjectField RefrenceField = mapGlobalDescribe.get(SobjectName).getDescribe().fields.getMap().get(strParentRelation.trim());
			        String strParentObjectName = (!RefrenceField.getDescribe().getReferenceTo().isEmpty()) ? String.valueOf(RefrenceField.getDescribe().getReferenceTo()[0]) : '';
		            Schema.SObjectField parentField = mapGlobalDescribe.get(strParentObjectName).getDescribe().fields.getMap().get(strFieldAPIName.trim());
		            
		            if(RefrenceField.getDescribe().isAccessible() && parentField.getDescribe().isAccessible() && setSelectedFields.contains(objFSM.getFieldPath()))
	                {
	    				optionsSelected.add(new SelectOption(objFSM.getFieldPath(), objFSM.getLabel()));
	                }
	                else if(RefrenceField.getDescribe().isAccessible() && parentField.getDescribe().isAccessible() )
	                {
	                	optionsAvailable.add(new SelectOption(objFSM.getFieldPath(), objFSM.getLabel()));
	                }
	            }
    		}
    		else
    		{
    			Schema.SObjectField field = mapGlobalDescribe.get(SobjectName).getDescribe().fields.getMap().get(objFSM.getFieldPath().trim());
    			if(field.getDescribe().isAccessible() && setSelectedFields.contains(objFSM.getFieldPath()))
    			{
    				optionsSelected.add(new SelectOption(objFSM.getFieldPath(), objFSM.getLabel()));
    			}
    			else if(field.getDescribe().isAccessible())
    			{ 
    				optionsAvailable.add(new SelectOption(objFSM.getFieldPath(), objFSM.getLabel()));
    			}
    			
    		}
        }
        
		optionsAvailable.sort();
        //Create a selected list that is not sorted alphabetically but persists the original column order 
        List<SelectOption> optionsSelectedUnsorted = new List<SelectOption>();
        for(String currItem: lstSelectedFields)
        {
            SelectOption currSelection;
            for(SelectOption listSelectionItem: optionsSelected )
            {
                if(listSelectionItem.getValue() == currItem)
                    optionsSelectedUnsorted.add(listSelectionItem);
            }
        }       
       
        return new PicklistWrapper(optionsAvailable, optionsSelectedUnsorted);
   	}
    /* End */
   
   	 /*
        @MethodName : getCSVFields.
        @param      : NA
        @Description: to get the fields value of the Objects
    */
    private String getCSVFields(List<SelectOption> options)
    {
    	String strCSVFields =  ''; 
    	for(SelectOption option : options)
		{
       		strCSVFields += (strCSVFields == '') ? option.getValue() : ',' + option.getValue();
		}
		return strCSVFields;
    }
    /* End */
     
    /*
        @MethodName : saveChangeColumn.
        @param      : NA
        @Description: on save change column page.
    */
    public Pagereference saveChangeColumn()
    {
		if(!opportunityPicklist.selectedValues.isEmpty() && !engagementPicklist.selectedValues.isEmpty())
		{
	       	pcs.Opportunity_Columns__c =  getCSVFields(opportunityPicklist.selectedValues);
	       	pcs.Engagement_Columns__c = getCSVFields(engagementPicklist.selectedValues);
	       	upsert pcs;
	       	 
	    	Pagereference pageref = new Pagereference('/apex/SL_PipelineManager?pagetype=' + ApexPages.currentPage().getParameters().get('pagetype'));  
		   	return pageref;
		}
		else
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select atleast one field from picklist.'));
			return null;
		}
    }
    /* End */
    
   
    /*
        @MethodName : cancelChangeColumn.
        @param      : NA
        @Description: on cancel change column page.
    */
    public Pagereference cancelChangeColumn()
    {
    	Pagereference pageref = new Pagereference('/apex/SL_PipelineManager?pagetype=' + ApexPages.currentPage().getParameters().get('pagetype'));
	   	return pageref;
    }
    /* End */
}