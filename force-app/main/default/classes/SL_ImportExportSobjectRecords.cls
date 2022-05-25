/**  
* \arg ClassName      : SL_ImportExportSobjectRecords
* \arg JIRATicket     : HL-18
* \arg CreatedOn      : 20/JUN/2014
* \arg LastModifiedOn : 20/JUN/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Controller class for SL_ImportExportSobjectRecords page.
*/
public with sharing class SL_ImportExportSobjectRecords 
{
	/* Start - Variables */
	public PicklistWrapper sobjectPicklistWrapper		{	get;set;	}
	public String strImportContentVersionName			{	get;set;	}
	public String strExportContentVersionName			{	get;set;	}
	
	private Set<String>  sojectBlackList = new Set<String>	{ 'ContentDocumentLink', // set of object which is causes the error.
				  											  'IdeaComment',
				  											  'ContentDocumentFeed',
				  											  'ContentDocumentHistory',   
				  											  'CollaborationGroup',
				  											  'Group',
				  											  'CollaborationGroupMember',
				  											  'CollaborationGroupMemberRequest',
				  											  'ApexTestQueueItem',
				  											  'Approval',
				  											  'Asset',
				  											  'EmailTemplate',
				  											  'ObjectPermissions',
				  											  'FieldPermissions',
				  											  'edynamics__Chatter_Archive_Header__c',
				  											  'edynamics__caSettings__c',
				  											  'edynamics__Chatter_Queue__c',
				  											  'edynamics__Chatter_Archive__c',
				  											  'edynamics__Chatter_Queue_Settings__c',  
				  											  'edynamics__ArchiveForChatter__c',
				  											  'PushTopic',
				  											  'ContentWorkspaceDoc',
				  											  'edynamics__PM_Archiver_Settings__c',
				  											  'UserRole'};
	/* End - Variables */
	
	/* Start - Constructor */
	public SL_ImportExportSobjectRecords()
	{
		intialization();
		sobjectPicklistWrapper = getSobjectPicklistValues();   
	}
	/* End - Contructor */
	    
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
		@MethodName : intialization 
		@param 	    : NA
		@Description: to intializa all global variables. 
	*/
	private void intialization()
	{
		strImportContentVersionName = strExportContentVersionName = '';
	}
	/* End */
    
    
   	/* 
        @MethodName : getSobjectPicklistValues.
        @param      : NA
        @Description: Sobject API and Labels
   	*/
   	private PicklistWrapper getSobjectPicklistValues()  
   	{ 
   		List<SelectOption> lstSelectOption = new List<Selectoption>();
   		for(Schema.SObjectType sobj :Schema.getGlobalDescribe().values())
   		{
			if(sobj.getDescribe().isQueryable() && sobj.getDescribe().isUpdateable() 
				&& sobj.getDescribe().isCreateable() && !sojectBlackList.contains(sobj.getDescribe().getName()))
   			{
   				lstSelectOption.add(new Selectoption(sobj.getDescribe().getName(), sobj.getDescribe().getLabel()));
   			}
   		}
   		lstSelectOption.sort();
   		return new PicklistWrapper(lstSelectOption, new List<Selectoption>());
   	} 
	/* End */
	
	/* 
        @MethodName : importRecords
        @param      : NA
        @Description: to import the records
   	*/
	public void importRecords()
	{
		try
		{
			if(strImportContentVersionName != null && strImportContentVersionName != '')
			{
				List<ContentVersion> lstContentVersion = [SELECT Title, 
																 PathOnClient, 
																 VersionData 
															FROM ContentVersion 
														   WHERE Title =:strImportContentVersionName]; 
				if(lstContentVersion.isEmpty())
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,
																'Content Version is not available with this name. Please provide the Content Version Title.'));
				else
				{
					String recordsBundleAsJSON = lstContentVersion[0].VersionData.toString();
					Set<Id> setRecordIds = SL_SObjectDataLoader.deserialize(recordsBundleAsJSON);  
				}
			}
			else
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please provide the Content Version Title.'));	
		}
		catch(Exception ex)
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
		}
	}
	/* End */
	
	/* 
        @MethodName : exportRecords        
        @param      : NA
        @Description: to export the records
   	*/
	public void exportRecords()
	{
		try
		{
			if(strExportContentVersionName != '' && !sobjectPicklistWrapper.selectedValues.isEmpty())
			{
				Set<Id> setSobjectIds = new Set<Id>();
				
				for(Selectoption option : sobjectPicklistWrapper.selectedValues)
						setSobjectIds.addAll(getSobjectId(option.getValue()));
				
				if(!setSobjectIds.isEmpty())
				{	
					String recordsBundleAsJSON = SL_SObjectDataLoader.serialize(setSobjectIds);
						
					ContentVersion objContentVersion = new ContentVersion(VersionData = Blob.valueOf(recordsBundleAsJSON),    
																		  Title = strExportContentVersionName, 
																		  PathOnClient = strExportContentVersionName);
			
					insert objContentVersion;
				}
				else
				{   
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No records found.'));	
				}
			}
			else
			{
				if(strExportContentVersionName == '')
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please provide the Content Version Title.'));	
				if(sobjectPicklistWrapper.selectedValues.isEmpty())
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select atleast one Sobject.'));	
			}
		}
		catch(Exception ex)
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
		}
	}
	/* End */
	
	/* 
        @MethodName : getSobjectId        
        @param      : Sobject Name
        @Description: to get ids of the records.
   	*/
   	private Set<Id> getSobjectId(String sobjName)
   	{
   		Set<Id> setSobjectIds = new Set<Id>();
   		for(Sobject sobj : Database.query('SELECT Id FROM ' + sobjName +' LIMIT 1000'))
   		{
   			setSobjectIds.add((Id)sobj.get('Id'));
   		}
   		return setSobjectIds;
   	}
   	/* End */
	
}