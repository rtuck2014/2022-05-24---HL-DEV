global with sharing class SL_LIB16_Implementation_Page extends SL_LIB16_install
{
	public sObject originalSObject;
	public String pageTitle {get; set;}
	public SL_Mass_Implementation__c curNewRecordVal {get; set;}

	public String inTargetObject {get; set;}
	public String inParentObject {get; set;}
	public String inSearchObject {get; set;}


	private ID curRecordID = null;
	public SL_LIB16_Implementation_Page()
    {
		init();
		curRecordID = System.currentPageReference().getParameters().get('id');
		
    }
    
	public SL_LIB16_Implementation_Page(ApexPages.StandardController stdController)
	{
        this.originalSObject = (sObject) stdController.getRecord();
        curRecordID =  this.originalSObject.ID;

        init();
	}
	
	public void init()
	{
		pageTitle = 'New Implementation';
		objNewRecord = new SL_Mass_Implementation__c();
		curNewRecordVal = new SL_Mass_Implementation__c();
		if(curRecordID!=null)
		{
			objNewRecord = [Select targetObjectSearchFieldName__c, targetObjectParentFieldName__c, targetObjectName__c, searchObjectName__c, parentObjectName__c, Name, Row_Qty_Values__c,  
    			Show_Views_on_MassEdit_Page__c, Show_Views_on_MassAdd_Page__c, Search_Page_Title__c, Search_Object_Title__c, Id, Get_Element_from_List_Tab__c, Use_Step2_Multi_Add_Form__c, 
    			Lookup_Title_Get_List_Page__c   
    			From SL_Mass_Implementation__c where ID = :curRecordID limit 1];

    		pageTitle = objNewRecord.Name;
    		curNewRecordVal = objNewRecord.clone();
    		
    		this.strTargetObject = objNewRecord.targetObjectName__c;
    		this.strParentObject = objNewRecord.parentObjectName__c;
    		this.strSearchObject = objNewRecord.searchObjectName__c;
    		this.inTargetObject = objNewRecord.targetObjectName__c;
    		this.inParentObject = objNewRecord.parentObjectName__c;
    		this.inSearchObject = objNewRecord.searchObjectName__c;
    		
    		this.strTargetObjectParentFld = objNewRecord.targetObjectParentFieldName__c.toLowerCase();
    		this.strTargetObjectSearchFld = objNewRecord.targetObjectSearchFieldName__c.toLowerCase();
		}
		
		
	}
	
	public void chMainObject()
	{
		this.strTargetObject = inTargetObject;
		curNewRecordVal.targetObjectName__c = inTargetObject;
		this.strParentObject = inParentObject;
		curNewRecordVal.parentObjectName__c = inParentObject;
		this.strSearchObject = inSearchObject;
		curNewRecordVal.searchObjectName__c = inSearchObject;
		ID curRecID = objNewRecord.ID;
		objNewRecord = curNewRecordVal.clone();
		objNewRecord.ID = curRecID;
	}
	
	private boolean objSave()
	{
		objNewRecord.targetObjectName__c = this.strTargetObject;
		objNewRecord.parentObjectName__c = this.strParentObject;
		objNewRecord.searchObjectName__c = this.strSearchObject;
		
		objNewRecord.targetObjectParentFieldName__c = this.strTargetObjectParentFld;
		objNewRecord.targetObjectSearchFieldName__c = this.strTargetObjectSearchFld;
		
		if(this.strTargetObject==null || this.strTargetObject==''){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Target Object value is required'));}
		if(this.strParentObject==null || this.strParentObject==''){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Parent Object value is required'));}
		if(this.strSearchObject==null || this.strSearchObject==''){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Search Object value is required'));}

		if(this.strTargetObjectParentFld==null || this.strTargetObjectParentFld==''){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Target Object Parent Field is required'));}
		if(this.strTargetObjectSearchFld==null || this.strTargetObjectSearchFld==''){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Target Object Search Field is required'));}
		
		if(ApexPages.hasMessages()) return false;
		if(!Test.isRunningTest())
		{
			try
			{
				upsert objNewRecord;
			}
			catch(Exception ex)
			{
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage()));
				return false;
			}
		}
		
		return true;
	} 
	
	public PageReference btnSave()
	{
		if(!objSave()) return null;
		PageReference pageRef = new PageReference('/'+objNewRecord.ID);
		pageRef.setRedirect(true);
		return pageRef;
	}

	public PageReference btnSaveAndNew()
	{
		if(!objSave()) return null;
		
		PageReference pageRef = new PageReference('/apex/SL_LIB16_Implementation_Page');
		pageRef.setRedirect(true);
		return pageRef;
	}


	public PageReference btnCancel()
	{
    	PageReference pageRef = new PageReference('/home/home.jsp');
    	if(System.currentPageReference().getParameters().get('retURL')!=null && System.currentPageReference().getParameters().get('retURL')!='')
    	{
    		pageRef = new PageReference(System.currentPageReference().getParameters().get('retURL'));
    	}
        pageRef.setRedirect(true);
		return pageRef;
	}

	public PageReference goStForm()
    {
		PageReference pageRef = null;
		if(this.curRecordID==null)
		{
			String sObjPrefix = Schema.getGlobalDescribe().get('SL_Mass_Implementation__c').getDescribe().getKeyPrefix();
			pageRef = new PageReference('/'+sObjPrefix+'/e?retURL=%2F'+sObjPrefix+'%2Fo&nooverride=1');
			pageRef.setRedirect(true);
		}
		else
		{
			pageRef = new PageReference('/'+this.curRecordID+'/e?retURL=%2F'+this.curRecordID+'&nooverride=1');
			pageRef.setRedirect(true);
		}
		
		return pageRef;
    }	
	

}