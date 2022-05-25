public with sharing class SL_LIB16_ctrl_MassEditSettingsEdit
{
    public Mass_Edit_Settings__c CurMESettings {get; set;}
    public String CurMESettingsId {get; set;}
    public String pageTitle {get; set;}
    
    public SL_LIB16_FieldLoader fieldLoader {get; set;}
    public SL_LIB16_FieldLoader sortedFieldLoader {get; set;}
    
	private String Impl_Type = 'Target';
	private Id Impl_ID = null;
    
    public SL_LIB16_ctrl_MassEditSettingsEdit(ApexPages.StandardController stdController)
    {
        Mass_Edit_Settings__c tmpObj = (Mass_Edit_Settings__c)stdController.getRecord();
        this.CurMESettingsId = tmpObj.Id;
        init();
    }

	public SL_LIB16_ctrl_MassEditSettingsEdit()
	{
		if(Apexpages.currentPage().getParameters().containsKey('id') && Apexpages.currentPage().getParameters().get('id')!=null && Apexpages.currentPage().getParameters().get('id')!='')
        {
        	this.CurMESettingsId = Apexpages.currentPage().getParameters().get('id');
        }
        init();
	}
    
    void init()
    {       
		pageTitle = 'New Column';
		if(Apexpages.currentPage().getParameters().containsKey('impl_id') && Apexpages.currentPage().getParameters().get('impl_id')!=null && Apexpages.currentPage().getParameters().get('impl_id')!='')
        {
        	Impl_ID = (ID)Apexpages.currentPage().getParameters().get('impl_id');
        }
		if(Apexpages.currentPage().getParameters().containsKey('impl_type') && Apexpages.currentPage().getParameters().get('impl_type')!=null && Apexpages.currentPage().getParameters().get('impl_type')!='')
        {
        	Impl_Type = Apexpages.currentPage().getParameters().get('impl_type');
        }
        
        if(Impl_Type!='search') Impl_Type = 'Target';
        else Impl_Type = 'Search';

		if(this.CurMESettingsId != null && this.CurMESettingsId != '')
        {
			//this.isEdit = true;
			for(Mass_Edit_Settings__c item: [SELECT ID, Name, Field__c, Sort_Field__c, Label__c, IsSortable__c, Implementation__c, Implementation_Type__c FROM Mass_Edit_Settings__c WHERE ID = : this.CurMESettingsId])
			{
				pageTitle = item.Name;
				this.CurMESettings = item;
				Impl_Type = item.Implementation_Type__c;
				Impl_ID = item.Implementation__c;
			}
		}
		else
		{
			//this.isEdit = false;
			this.CurMESettings = new Mass_Edit_Settings__c(Implementation_Type__c = Impl_Type, Implementation__c = Impl_ID);
        }
        
		if(Impl_ID!=null)
		{
			fieldLoader = new SL_LIB16_FieldLoader(Impl_ID,Impl_Type);
        	sortedFieldLoader = new SL_LIB16_FieldLoader(Impl_ID,Impl_Type);
		}
        
        if(fieldLoader==null || sortedFieldLoader==null)
        {
        	fieldLoader = new SL_LIB16_FieldLoader();
        	sortedFieldLoader = new SL_LIB16_FieldLoader();
        }       

		try{ fieldLoader.setSelectedValues(this.CurMESettings.Field__c);}
		catch(Exception e){}
		
		try{ sortedFieldLoader.setSelectedValues(this.CurMESettings.Sort_Field__c);}
		catch(Exception e){}
    }
    
    public void updateFieldLists()
    {
        fieldLoader.updateFieldLists();
    }
    
    public void updateSortedFieldLists()
    {
        sortedFieldLoader.updateFieldLists();
    }   
    
    private boolean saveObj()
    {
        if(CurMESettings!=null && CurMESettings.Implementation__c!=null)
        {
	        this.CurMESettings.Name = this.CurMESettings.Label__c;
	        this.CurMESettings.Field__c = fieldLoader.getValue();
	        if(fieldLoader.getIsSortable())
	        {
	        	this.CurMESettings.Sort_Field__c = fieldLoader.getValue();
	        	this.CurMESettings.IsSortable__c = true;
	        }
	        else
	        {
	        	this.CurMESettings.Sort_Field__c = 'ID';
	        	this.CurMESettings.IsSortable__c = false;
	        }

	        try{ upsert this.CurMESettings;}
	        catch(Exception e)
			{
	        	if(e.getMessage().indexOf('DUPLICATE_VALUE')!=-1)
	        	{
	        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You can\'t add this Field. This field has been already added!'));
	        	}
	        	else
	        	{
	        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: '+e.getMessage()));
	        	}
	        	return false;
			}
			this.CurMESettingsId = this.CurMESettings.Id;
        }
        
        return true;   
    }
    
	public PageReference cancelBtn()
    {
        PageReference pageRef = null;
       	if(Apexpages.currentPage().getParameters().containsKey('retURL') && Apexpages.currentPage().getParameters().get('retURL')!=null && Apexpages.currentPage().getParameters().get('retURL')!='')
        {
        	pageRef = new PageReference(Apexpages.currentPage().getParameters().get('retURL'));
        }
       	else if(this.CurMESettingsId!=null)
       	{
	       	pageRef = new PageReference('/'+this.CurMESettingsId );
       	}
       	else if(this.Impl_ID!=null)
       	{
	       	pageRef = new PageReference('/'+this.Impl_ID );
       	}
       	else
       	{
       		pageRef = new PageReference('/home/home.jsp' );
       	}
       	pageRef.setRedirect(true);

        return pageRef;
	}

    public PageReference saveBtn()
    {
        PageReference pageRef = null;
        if(this.saveObj())
        {
        	pageRef = new PageReference('/'+this.CurMESettingsId );
        	pageRef.setRedirect(true);
        }
        return pageRef;
	}
    
	public PageReference saveNewBtn()
	{
		PageReference pageRef = null;
		if(this.saveObj())
		{
			pageRef = new PageReference('/apex/SL_LIB16_MassEditSettingsEdit?impl_id='+(Impl_ID==null?'':Impl_ID)+'&impl_type='+Impl_Type);
			pageRef.setRedirect(true);
		}
		return pageRef;
	}
    
    
    public PageReference goStForm()
    {
		PageReference pageRef = null;
		if(this.CurMESettingsId==null)
		{
			String sObjPrefix = Schema.getGlobalDescribe().get('Mass_Edit_Settings__c').getDescribe().getKeyPrefix();
			pageRef = new PageReference('/'+sObjPrefix+'/e?retURL=%2F'+(Impl_ID==null?sObjPrefix+'':Impl_ID)+'&nooverride=1');
			pageRef.setRedirect(true);
		}
		else
		{
			pageRef = new PageReference('/'+this.CurMESettingsId+'/e?retURL=%2F'+this.CurMESettingsId+'&nooverride=1');
			pageRef.setRedirect(true);
		}
		
		return pageRef;
    }
}