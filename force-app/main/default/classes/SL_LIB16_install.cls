public with sharing virtual class SL_LIB16_install
{
	public String msgText {get; set;}
	public ID ME_CompanyList_ObjID {get; set;}
	public Filter_Tab__c tabContactObj {get; set;}
	
	public String strTargetObject {get; set;}
	public String strParentObject {get; set;}
	public String strSearchObject {get; set;}
	
	public String strTargetObjectParentFld {get; set;}
	public String strTargetObjectSearchFld {get; set;}
	
	public SL_Mass_Implementation__c objNewRecord {get; set;}
	public Boolean isShowStep2Fld {get; set;}

	public SL_LIB16_install()
    {
    	msgText = '';
    	isShowStep2Fld = false;
    	objNewRecord = new SL_Mass_Implementation__c();
    	objNewRecord.Row_Qty_Values__c = '10,20,30,50,100';
    }
    
    public List<SelectOption> getFieldList4Parent() {
    	List<SelectOption> retVals = new List<SelectOption>();
    	
    	List<SObjectType> aLinksTo;
		boolean isRefObjCorrect = false;
		Schema.DescribeFieldResult fldRes1;
    	
    	SL_LIB16_ME_DescribeObject_Core locDescribeObject = SL_LIB16_ME_DescribeObject_Core.getInstance();
    	Map<String, String> mapRefFlds = new Map<String, String>();
    	if(objNewRecord!=null && objNewRecord.targetObjectName__c!=null && objNewRecord.targetObjectName__c!='') mapRefFlds = locDescribeObject.getObjectFieldsByType(objNewRecord.targetObjectName__c,'REFERENCE');
    	
		if(mapRefFlds!=null && mapRefFlds.size()>0)
		{
			for(string item:mapRefFlds.keySet())
			{
				fldRes1 = locDescribeObject.getFieldDescriptionByName(objNewRecord.targetObjectName__c,item);
				aLinksTo = fldRes1.getReferenceTo();
				if (aLinksTo != null && aLinksTo.size() != 0)
               	{
					for (SObjectType oLinkObject : aLinksTo)
					{
						if(objNewRecord.parentObjectName__c!=null && oLinkObject.getDescribe().getName().toLowerCase() == objNewRecord.parentObjectName__c.toLowerCase())
						{
							retVals.add(new SelectOption(item,mapRefFlds.get(item)+' ('+item+')'));
						}
					}
							
               	}
			}
			 
		}
    	
    	return getSortListOptions(retVals,'-- Select Field --');
    }
    
    public List<SelectOption> getFieldList4Search() {
    	List<SelectOption> retVals = new List<SelectOption>();
    	List<SObjectType> aLinksTo;
		boolean isRefObjCorrect = false;
		Schema.DescribeFieldResult fldRes1;
    	
    	SL_LIB16_ME_DescribeObject_Core locDescribeObject = SL_LIB16_ME_DescribeObject_Core.getInstance();
    	Map<String, String> mapRefFlds = new Map<String, String>();
    	if(objNewRecord!=null && objNewRecord.targetObjectName__c!=null && objNewRecord.targetObjectName__c!='') mapRefFlds = locDescribeObject.getObjectFieldsByType(objNewRecord.targetObjectName__c,'REFERENCE');
    	
		if(mapRefFlds!=null && mapRefFlds.size()>0)
		{
			for(string item:mapRefFlds.keySet())
			{
				fldRes1 = locDescribeObject.getFieldDescriptionByName(objNewRecord.targetObjectName__c,item);
				aLinksTo = fldRes1.getReferenceTo();
				if (aLinksTo != null && aLinksTo.size() != 0)
               	{
					for (SObjectType oLinkObject : aLinksTo)
					{
						if(objNewRecord.searchObjectName__c!=null && oLinkObject.getDescribe().getName().toLowerCase() == objNewRecord.searchObjectName__c.toLowerCase())
						{
							retVals.add(new SelectOption(item,mapRefFlds.get(item)+' ('+item+')'));
						}
					}
							
               	}
			}
			 
		}
    	
    	return getSortListOptions(retVals,'-- Select Field --');
    }
	
	public List<SelectOption> getObjectListItems() {
 	 	List<SelectOption> retVals = new List<SelectOption>();

		SL_LIB16_ME_DescribeObject_Core locDescribeObject = SL_LIB16_ME_DescribeObject_Core.getInstance();
		Map<String, Schema.DescribeSObjectResult> mapObjectDescribe = locDescribeObject.getObjectsDescribe();
		
		for(Schema.DescribeSObjectResult item:mapObjectDescribe.values())
		{
			if(item.searchable && item.createable){ retVals.add(new SelectOption(item.name,item.label+' ('+item.name+')'));}
		}

 	 	return getSortListOptions(retVals,'-- Select Object --');
  	}
  	
  	public List<SelectOption> getSortListOptions(List<SelectOption> inVals, String inDefValue)
  	{
  		List<SelectOption> retVals = new List<SelectOption>();
  		retVals.add(new SelectOption('',inDefValue));
  		
  		if(inVals!=null && inVals.size()>0)
  		{
  			Map<String,SelectOption> mapListOptions = new Map<String,SelectOption>();
  			for(SelectOption item:inVals){ mapListOptions.put(item.getLabel(),item);}

  			List<string> lstMapKeys = new List<string>();
			lstMapKeys.addAll(mapListOptions.keySet());
			lstMapKeys.sort();
			
			for(String item:lstMapKeys){ retVals.add(mapListOptions.get(item));}
  		}
  		
  		return retVals;
  	}
  	
  	public PageReference runSaveImpl()
    {
    	PageReference pageRef = null;
    	
    	if(!this.isShowStep2Fld)
    	{
	    	this.msgText = '';
	    	this.strTargetObjectParentFld = '';
    		this.strTargetObjectSearchFld = '';

	    	this.isShowStep2Fld = true;
	    	objNewRecord.targetObjectName__c = this.strTargetObject;
	    	objNewRecord.parentObjectName__c = this.strParentObject;
	    	objNewRecord.searchObjectName__c = this.strSearchObject;
	    	
    	}
    	else
    	{
    		this.msgText = 'Implementation Record was created';
	    	this.isShowStep2Fld = false;
	    	
	    	this.objNewRecord.targetObjectParentFieldName__c = this.strTargetObjectParentFld;
	    	this.objNewRecord.targetObjectSearchFieldName__c = this.strTargetObjectSearchFld;
	    	
	    	if(!Test.isRunningTest()) insert this.objNewRecord;
	    	
	    	pageRef = new PageReference('/'+this.objNewRecord.ID);
        	pageRef.setRedirect(true);
    	}
    	
    	return pageRef;
    	
    }
    public void runCancelImpl()
    {
    	this.msgText = '';
    	this.isShowStep2Fld = false;
    	this.objNewRecord = new SL_Mass_Implementation__c();
    	this.strTargetObjectParentFld = '';
    	this.strTargetObjectSearchFld = '';
    	
    }

	public void runChecker()
    {
		runCancelImpl();
		msgText = 'Default Mass Implementation Record ("Company List") and relative records. have been created.';
		
		ME_CompanyList_ObjID = null;
		for(SL_Mass_Implementation__c item: [select ID,Name from SL_Mass_Implementation__c where ExtID__c=1 limit 1])
		{
			ME_CompanyList_ObjID = item.ID;
		}

		if(ME_CompanyList_ObjID==null)
		{
			SL_Mass_Implementation__c itemMEMain = new SL_Mass_Implementation__c();

			itemMEMain.Name = 'Company List';
			itemMEMain.targetObjectParentFieldName__c = 'company_list__c';
			itemMEMain.targetObjectSearchFieldName__c = 'company__c';
			itemMEMain.targetObjectName__c = 'Company_List_Member__c';
			itemMEMain.parentObjectName__c = 'Company_List__c';
			itemMEMain.searchObjectName__c = 'Account';
			itemMEMain.Show_Views_on_MassAdd_Page__c = true;
			itemMEMain.Show_Views_on_MassEdit_Page__c = true;
			itemMEMain.Use_Step2_Multi_Add_Form__c = false;
			itemMEMain.Search_Page_Title__c = 'Search for Company to add to the Company List';
			itemMEMain.Search_Object_Title__c = 'Company';
			itemMEMain.Get_Element_from_List_Tab__c = 'Get Companies from existing Company List';
			itemMEMain.Row_Qty_Values__c = '10,20,30,50,100';
			itemMEMain.ExtID__c = 1;

			Database.insert(itemMEMain, false);
			ME_CompanyList_ObjID = itemMEMain.ID;
			
		} 		
		
		
		//Select m.Sort_Field__c, m.Show__c, m.RecordTypeId, m.Number__c, m.Name, m.Label__c, m.Field__c From Mass_Edit_Settings__c m
		Set<String> setMESNames = new Set<String>();
		for(Mass_Edit_Settings__c item:[select Id,Name from Mass_Edit_Settings__c where Implementation__c=:ME_CompanyList_ObjID and Implementation_Type__c='Target' limit 300])
		{
			setMESNames.add(item.name);
		}
		
		Map<Integer, Map<String, String>> aMassEditSettingsData = new Map<Integer, Map<String, String>>();
		if(!setMESNames.contains('Name')){ aMassEditSettingsData.put(1, new Map<String, String> {'Label' => 'Name','Field' => 'name','APIType'=>'STRING'});}
		if(!setMESNames.contains('Company')){ aMassEditSettingsData.put(2, new Map<String, String> {'Label' => 'Company','Field' => 'company__c','APIType'=>'REFERENCE'});}
		if(!setMESNames.contains('Company Type')){ aMassEditSettingsData.put(3, new Map<String, String> {'Label' => 'Company Type','Field' => 'company__r.type','APIType'=>'PICKLIST'});}
		
		setMESNames = new Set<String>();
		for(Mass_Edit_Settings__c item:[select Id,Name from Mass_Edit_Settings__c where Implementation__c=:ME_CompanyList_ObjID and Implementation_Type__c='Search' limit 300])
		{
			setMESNames.add(item.name);
		}
		Map<Integer, Map<String, String>> aSearchColumnsData = new Map<Integer, Map<String, String>>();
		if(!setMESNames.contains('Company Name')){ aSearchColumnsData.put(1, new Map<String, String> {'Field'  => 'Name','Label' => 'Company Name','APIType'=>'STRING'});}
		if(!setMESNames.contains('Cust Type')){ aSearchColumnsData.put(2, new Map<String, String> {'Field'  => 'Type','Label' => 'Company Type','APIType'=>'PICKLIST'});}
		if(!setMESNames.contains('Industry')){ aSearchColumnsData.put(3, new Map<String, String> {'Field'  => 'Industry','Label' => 'Industry','APIType'=>'PICKLIST'});}
		
		if(aMassEditSettingsData.size()>0){ Database.insert(generateMassEditSettings( aMassEditSettingsData, 'Target', ME_CompanyList_ObjID), false);}
		if(aSearchColumnsData.size()>0){ Database.insert(generateMassEditSettings( aSearchColumnsData, 'Search', ME_CompanyList_ObjID), false);}
		
		ID SLViewAccountID = null;
		ID SLViewCompanyListID = null;
		for(SL_View__c item:[select id,Name,Implementation_Type__c from SL_View__c where Name='All' and Implementation__c=:ME_CompanyList_ObjID])
		{
			if(item.Implementation_Type__c == 'Search'){ SLViewAccountID = item.ID;}
			if(item.Implementation_Type__c == 'Target'){ SLViewCompanyListID = item.ID;}
		}
		
		/*
		Boolean isAddViewFilter = false;
		List<SL_View__c> lstViews = new List<SL_View__c>();
		if(SLViewCompanyListID==null)
		{
			lstViews.add(new SL_View__c(Implementation__c=ME_CompanyList_ObjID,Implementation_Type__c='Target', Name='All',RowsCount__c=50,Columns__c='Name,Company,Company Type', Advanced_Filter__c='1'));
			isAddViewFilter = true;
    	}
		if(SLViewAccountID==null){ lstViews.add(new SL_View__c(Implementation__c=ME_CompanyList_ObjID,Implementation_Type__c='Search', Name='All',RowsCount__c=50,Columns__c='Company Name,Company Type,Industry,Phone'));}
		if(lstViews.size()>0) Database.insert(lstViews, false);
		
		if(isAddViewFilter)
		{
			SL_View_Filter__c item2Add = new SL_View_Filter__c(SL_View__c=lstViews[0].ID,Type__c='DATETIME',Field__c='CreatedDate',Operator__c='greaterThan',Value__c='2011-09-11T00:00:00Z');
			Database.insert(item2Add, false);
		}
		*/
		
		tabContactObj = null;
		for(Filter_Tab__c item:[select Id,Mass_Implementation__c, Name, Field_Name__c, Object_Name__c from Filter_Tab__c where Mass_Implementation__c=:ME_CompanyList_ObjID and Object_Name__c='Contact' limit 1])
		{
			tabContactObj = item;
		}
		
		if(tabContactObj == null)
		{
			tabContactObj = new Filter_Tab__c(Name='Search by Contact', Mass_Implementation__c=ME_CompanyList_ObjID, Object_Name__c='Contact', Field_Name__c='AccountId');
			Database.insert(tabContactObj, false);
		}
		
		List<SL_Filter_Field__c> lstFFSearch = new List<SL_Filter_Field__c>();
		List<SL_Filter_Field__c> lstFFTarget = new List<SL_Filter_Field__c>();
		List<SL_Filter_Field__c> lstFFTab = new List<SL_Filter_Field__c>();
		
		for(SL_Filter_Field__c item:[select Id, Name, Mass_Implementation__c, API_Type__c, Filter_Tab__c from SL_Filter_Field__c where Mass_Implementation__c=:ME_CompanyList_ObjID])
		{
			if(item.Filter_Tab__c!=null){ lstFFTab.add(item);}
			else if(item.API_Type__c=='Search'){ lstFFSearch.add(item);}
			else if(item.API_Type__c=='Target'){ lstFFTarget.add(item);}
		}
		
		/*
		if(lstFFSearch.size()==0)
		{
			SL_Filter_Field__c iFFSObj = new SL_Filter_Field__c(Name='Account Name', Mass_Implementation__c=ME_CompanyList_ObjID, Type__c='Search');
			iFFSObj.API_Name__c = 'Name';
			iFFSObj.API_Lable__c = 'Account Name';
			iFFSObj.API_Type__c = 'STRING';
			iFFSObj.SF_Object__c = 'Account';
			iFFSObj.Order__c = 1;
			insert iFFSObj;
			lstFFSearch.add(iFFSObj);
			
			SL_Filter_Field__c iFFSObj2 = new SL_Filter_Field__c(Name='Owner ID', Mass_Implementation__c=ME_CompanyList_ObjID, Type__c='Search');
			iFFSObj2.API_Name__c = 'OwnerId';
			iFFSObj2.API_Lable__c = 'Owner ID';
			iFFSObj2.API_Type__c = 'REFERENCE';
			iFFSObj2.SF_Object__c = 'Account';
			iFFSObj2.Order__c = 2;
			insert iFFSObj2;
			lstFFSearch.add(iFFSObj2);
			
			SL_Filter_Field__c iFFSObj3 = new SL_Filter_Field__c(Name='Account : Industry', Mass_Implementation__c=ME_CompanyList_ObjID, Type__c='Search');
			iFFSObj3.API_Name__c = 'Industry';
			iFFSObj3.API_Lable__c = 'Industry';
			iFFSObj3.API_Type__c = 'PICKLIST';
			iFFSObj3.SF_Object__c = 'Account';
			iFFSObj3.Parent_Ref_Field__c = 'ParentId';
			iFFSObj3.Order__c = 3;
			insert iFFSObj3;
			lstFFSearch.add(iFFSObj3);


		}
		
		if(lstFFTarget.size()==0)
		{
			SL_Filter_Field__c iFFTarObj = new SL_Filter_Field__c(Name='Company', Mass_Implementation__c=ME_CompanyList_ObjID, Type__c='Target');
			iFFTarObj.API_Name__c = 'Company__c';
			iFFTarObj.API_Lable__c = 'Company';
			iFFTarObj.API_Type__c = 'REFERENCE';
			iFFTarObj.SF_Object__c = 'Company_List_Member__c';
			iFFTarObj.Order__c = 1;
			insert iFFTarObj;
			lstFFTarget.add(iFFTarObj);
		}
		*/
		
		if(lstFFTab.size()==0)
		{
			SL_Filter_Field__c iFFTabObj = new SL_Filter_Field__c(Name='Last Name', Mass_Implementation__c=ME_CompanyList_ObjID, Filter_Tab__c=tabContactObj.ID);
			iFFTabObj.API_Name__c = 'LastName';
			iFFTabObj.API_Lable__c = 'Last Name';
			iFFTabObj.API_Type__c = 'STRING';
			iFFTabObj.SF_Object__c = 'Contact';
			iFFTabObj.Order__c = 1;
			Database.insert(iFFTabObj, false);
			lstFFTab.add(iFFTabObj);
		}
		
    }
    
    
    
    private List<Mass_Edit_Settings__c> generateMassEditSettings( Map<Integer, Map<String, String>> aData, String inImplementationType, ID inImplementationID) {
		List<Mass_Edit_Settings__c> aResult = new List<Mass_Edit_Settings__c>();
		
		List<Integer> aOrder = new List<Integer>( aData.keySet() ); 
		aOrder.sort();
		
		Mass_Edit_Settings__c oSetting = null;
		for ( Integer nItem : aOrder ) {
			aResult.add(
				new Mass_Edit_Settings__c(
					Name = aData.get( nItem ).get( 'Label' ),
					Label__c = aData.get( nItem ).get( 'Label' ),
					Field__c = aData.get( nItem ).get( 'Field' ),
					Sort_Field__c = aData.get( nItem ).get( 'Field' ),
					API_Type__c = aData.get( nItem ).get( 'APIType' ),
					IsSortable__c = true,
					isEditable__c = true,
					Implementation_Type__c = inImplementationType,
					Implementation__c = inImplementationID
				)
			);
		}
		
		return aResult;
	}
	
}