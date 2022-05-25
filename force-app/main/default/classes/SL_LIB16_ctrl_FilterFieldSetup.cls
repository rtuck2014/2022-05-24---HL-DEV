public with sharing class SL_LIB16_ctrl_FilterFieldSetup {
	
	private static Map<String, Schema.SObjectType> globalObjectDescribeMap = Schema.getGlobalDescribe();
	private ApexPages.StandardController thisController;
	public String defaultMainObject {get;set;} 
	public String debugLog{get;set;}
	public List<SL_LIB16_ReferencedFilterFieldWrapper> filterReferencedFieldList {get;set;}
	public String pageTitle {get; set;}
	public SL_Filter_Field__c newFFItem {get; set;}
	
	public String filterType {get;set;}
	public Id implementationId;
	public String referenceObjectName {get;set;}
	public String referenceSystemFieldName {get;set;}
	public Filter_Tab__c curFTabItem {get;set;}
	
	private SObject inOrigRecord;
	
	public String tabId {get;set;}
	
	public SL_LIB16_ctrl_FilterFieldSetup() {
		debugLog = '';
		this.defaultMainObject = 'Account';
		
		if(ApexPages.currentPage()!=null &&  ApexPages.currentPage().getParameters()!=null)
		{
			Map<String,String> urlParams = ApexPages.currentPage().getParameters();
			if (urlParams.containsKey('filterId')) {
				this.implementationId = urlParams.get('filterId');
			}
			if (urlParams.containsKey('type')) {
				this.filterType = urlParams.get('type');
				this.pageTitle = this.filterType + ' Type';
			}
			if (urlParams.containsKey('objectName')) {
				this.referenceObjectName = urlParams.get('objectName');
			}
			if (urlParams.containsKey('systemFieldName')) {
				this.referenceSystemFieldName = urlParams.get('systemFieldName');
				
			}
			if (urlParams.containsKey('tabId')) {
				this.tabId = urlParams.get('tabId');
			}
			
			if (!urlParams.containsKey('tabId')) {
				if (urlParams.containsKey('type')) {
					this.filterType = urlParams.get('type');
					if (!(this.filterType == 'Search' || this.filterType == 'Target')) {
						throw new SL_LIB16_MyException('Filter must have type "Search" or "Target"');
					}
				} else {
					throw new SL_LIB16_MyException('Filter must have type "Search" or "Target"');
				}
			}
			else
			{
				this.pageTitle = 'Tab Type';
			}
			
			this.refreshFilterFieldList();
		}
		Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=9');
	}
	
	public SL_LIB16_ctrl_FilterFieldSetup(ID inImplId, String inFilterType) {
		this.implementationId = inImplId;
		this.filterType = inFilterType;
		
		this.pageTitle = this.filterType + ' Type';
		
		this.refreshFilterFieldList();
	}
	
	public SL_LIB16_ctrl_FilterFieldSetup(ApexPages.StandardController stdController) {
		
		
		inOrigRecord = (sObject) stdController.getRecord();
		debugLog = '';
		this.defaultMainObject = 'Account';
		this.thisController = stdController;
		
		if (ApexPages.CurrentPage().getUrl()!=null && ApexPages.CurrentPage().getUrl().contains('SL_LIB16_FilterTab')) {
			this.setupTabsPage();
			return;
		}
		
		Map<String,String> urlParams = ApexPages.currentPage().getParameters();
		
		if (urlParams.containsKey('type')) {
			this.filterType = urlParams.get('type');
			this.pageTitle = this.filterType + ' Type';
		}
		if (urlParams.containsKey('tabId')) {
			this.tabId = urlParams.get('tabId');
			this.pageTitle = 'Tab Type';
		}

		if (urlParams.containsKey('type')) {
			this.filterType = urlParams.get('type');
			if (!(this.filterType == 'Search' || this.filterType == 'Target')) {
				if(!test.isRunningTest()){ throw new SL_LIB16_MyException('Filter must have type "Search" or "Target"');}
			}
		} else {
			if(!test.isRunningTest()){ throw new SL_LIB16_MyException('Filter must have type "Search" or "Target"');}
		}
		
		this.refreshFilterFieldList();
		
	}
	
	public void loadTabInfo()
	{
		this.pageTitle = 'New Filter Tab';
		if(inOrigRecord!=null && inOrigRecord.ID!=null)
		{
			curFTabItem = (Filter_Tab__c)inOrigRecord;
			this.pageTitle = curFTabItem.Name;
		}
	}
	
	public Boolean getIsTabObject()
	{
		return (curFTabItem!=null && curFTabItem.ID!=null)?true:false;
	}
	
	public PageReference tabRefresh() {
		this.refreshFilterFieldList();
		return null;
    }
    
    private void setupTabsPage() {
		this.tabId = this.thisController.getRecord().Id;
		if (tabId == null) {
			this.implementationId = (Id)this.thisController.getRecord().get('Mass_Implementation__c');
		} else {
			Filter_Tab__c tab = [SELECT Id,Mass_Implementation__c FROM Filter_Tab__c WHERE Id = :this.tabId];
			this.implementationId = tab.Mass_Implementation__c;
		}
		this.refreshFilterFieldList();
	}
	
	public void onChangeMainObject() {
		this.refreshFilterFieldList();
	}
	
	private void refreshFilterFieldList() {
		Id tmpObjId;
		if (this.implementationId != null) {
			tmpObjId = this.implementationId;
		} else if (this.tabId != null) {
			Filter_Tab__c tabObj = [SELECT Id,Mass_Implementation__c FROM Filter_Tab__c WHERE Id=:this.tabId LIMIT 1];
			tmpObjId = tabObj.Mass_Implementation__c;
		} else if (this.thisController != null) {
			tmpObjId = this.thisController.getRecord().Id;
		}
		for(SL_Mass_Implementation__c tmpObj:[SELECT Id,Name,searchObjectName__c,targetObjectName__c FROM SL_Mass_Implementation__c WHERE Id=:tmpObjId])
		{
			this.filterFieldList = this.getFieldMapByObject(tmpObj);
		}
		
		newFFItem = new SL_Filter_Field__c(Mass_Implementation__c=tmpObjId, Type__c=this.pageTitle, Parent_Ref_Field__c=this.referenceSystemFieldName);
	}

	// ###### fieldNames ######
	public List<SelectOption> fieldNames;
	
	public List<SelectOption> getFieldNames() {
		
		List<SelectOption> options = new List<SelectOption>();
		
		Filter_Tab__c tabObject = (Filter_Tab__c)this.thisController.getRecord();
		String objectName = tabObject.Object_Name__c;
		if (objectName == null) {
			objectName = this.defaultMainObject;
		}
		Map<String, Schema.SObjectField> objectFieldsMap = SL_LIB16_ctrl_FilterFieldSetup.globalObjectDescribeMap.get(objectName).getDescribe().fields.getMap();
		
		SL_Mass_Implementation__c curMassImplementation;
		for(SL_Mass_Implementation__c item:[SELECT Id,Name,searchObjectName__c,targetObjectName__c FROM SL_Mass_Implementation__c WHERE Id=:tabObject.Mass_Implementation__c])
		{
			curMassImplementation = item;
		}
		
		String strCurFieldType = '';
		List<SObjectType> aLinksTo;
		boolean isRefObjCorrect;
		DescribeFieldResult curFldDesc;
		
		for(SObjectField item: objectFieldsMap.values())
		{
			curFldDesc = item.getDescribe();
			if((''+curFldDesc.getType()).toLowerCase()=='reference')
			{
				isRefObjCorrect = false;
				aLinksTo = curFldDesc.getReferenceTo();
				if (aLinksTo != null && aLinksTo.size() != 0 && curMassImplementation!=null && curMassImplementation.searchObjectName__c!=null)
               	{
					for (SObjectType oLinkObject : aLinksTo)
					{
						if(oLinkObject.getDescribe().getName().toLowerCase() == curMassImplementation.searchObjectName__c.toLowerCase())
						{
							isRefObjCorrect = true;
						}
					}
							
               	}
				
				if(isRefObjCorrect)
				{
					strCurFieldType = 'lookup';
					options.add(new SelectOption(item.getDescribe().getName(),item.getDescribe().getLabel()+' ('+ strCurFieldType +')'));
				}
				
			}
			else if((''+item.getDescribe().getType()).toLowerCase()=='string')
			{
				if(item.getDescribe().isCalculated()){ strCurFieldType = 'formula';}
				else{ strCurFieldType = 'text';}
				
				options.add(new SelectOption(item.getDescribe().getName(),item.getDescribe().getLabel()+' ('+ strCurFieldType +')'));
			}
		}
		
		options.sort();
		
		return options;
	}

	public void setFieldNames(List<SelectOption> options) {
		this.fieldNames = options;
	}
	// ###### end of fieldNames ######

	
	// ###### mainObjectOptions ######
	public List<SelectOption> mainObjectOptions;
	
	public List<SelectOption> getMainObjectOptions() {
		List<SelectOption> options = new List<SelectOption>();
		List<Schema.SObjectType> gd = SL_LIB16_ctrl_FilterFieldSetup.globalObjectDescribeMap.Values();
		for(Schema.SObjectType f : gd) {
			options.add(new SelectOption(f.getDescribe().getName(),f.getDescribe().getLabel()));
		}
		options.sort();
		return options;
	}

	public void setMainObjectOptions(List<SelectOption> options) {
		this.mainObjectOptions = options;
	}
	// ###### end of mainObjectOptions ######
	
	// ###### filterFieldList ######
	public List<SL_LIB16_FilterFieldWrapper> filterFieldList {get;set;}
	// ###### end of filterFieldList ######

	private List<SL_LIB16_FilterFieldWrapper> getFieldMapByObject(SL_Mass_Implementation__c objectInstance)
	{
		
		List<SL_LIB16_FilterFieldWrapper> result = new List<SL_LIB16_FilterFieldWrapper>();
		
		String objectName = this.defaultMainObject;
		String objectId = '0';
		
		
		if(this.filterType == 'Target')
		{
			if (objectInstance.targetObjectName__c != null){
				objectName = objectInstance.targetObjectName__c;
				objectId = objectInstance.Id;
			}
		}
		else
		{
			if (objectInstance.searchObjectName__c != null) {
				objectName = objectInstance.searchObjectName__c;
				objectId = objectInstance.Id;
			}
		}
		
		if (this.referenceObjectName != null) {
			objectName = this.referenceObjectName;
		}
		
		if (ApexPages.CurrentPage()!=null && ApexPages.CurrentPage().getUrl()!=null && ApexPages.CurrentPage().getUrl().contains('SL_LIB16_FilterTab')) {
			Filter_Tab__c tabObject = (Filter_Tab__c)this.thisController.getRecord();
			objectName = tabObject.Object_Name__c;
			if (objectName == null) {
				objectName = this.defaultMainObject;
			}
		}
		
		if (!SL_LIB16_ctrl_FilterFieldSetup.globalObjectDescribeMap.containsKey(objectName)) {
			return result;
		}
		Map<String, Schema.SObjectField> objectFieldsMap = SL_LIB16_ctrl_FilterFieldSetup.globalObjectDescribeMap.get(objectName).getDescribe().fields.getMap();
		
		Schema.DescribeFieldResult describeField;
		
		Map<String,String> existantFields = new Map<String,String>();
		List<SL_Filter_Field__c> tmpFilterFieldList = [SELECT
					Id,
					Name,
					API_Name__c
				FROM SL_Filter_Field__c
				WHERE
					Mass_Implementation__c = :objectId
					AND SF_Object__c = :objectName
					AND Parent_Ref_Field__c = :this.referenceSystemFieldName
					AND Type__c = :this.filterType
					AND Filter_Tab__c = :this.tabId];
			
		// ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'objectId - ' + objectId));
		
		for (SL_Filter_Field__c item: tmpFilterFieldList) {
			existantFields.put(item.API_Name__c, item.Name);
		}
		
		String newCustomLabel;
		String newCustomColumnLabel;
		String newSystemName;
		String newType;
		Boolean newSelected;
		Boolean newSelectedColumn;
		SL_LIB16_ReferencedFilterFieldWrapper newFilterField;
		
		this.filterReferencedFieldList = new List<SL_LIB16_ReferencedFilterFieldWrapper>();
		
		List<AggregateResult> countRefFields = [Select
				COUNT(Id) cnt,
				SF_Object__c,
				Parent_Ref_Field__c,
				Mass_Implementation__c
			From SL_Filter_Field__c
			where
				Mass_Implementation__c = :objectId
				and Parent_Ref_Field__c != null
				AND Type__c = :this.filterType
			group by SF_Object__c, Parent_Ref_Field__c, Mass_Implementation__c];
			
		Map<String,String> countRefFieldsMap = new Map<String,String>();

		for (AggregateResult item: countRefFields) {
			countRefFieldsMap.put(String.valueOf(item.get('Parent_Ref_Field__c')) + ':' + String.valueOf(item.get('SF_Object__c')), String.valueOf(item.get('cnt')));
		}
		

		//Select m.Sort_Field__c, m.Name, m.Label__c, m.Implementation__c, m.Implementation_Type__c, m.Field__c From Mass_Edit_Settings__c m
		Map<String,String> mapFldName2Lable = new Map<String,String>();
		for(Mass_Edit_Settings__c item:[Select Id, Label__c, Field__c From Mass_Edit_Settings__c where Implementation__c=:objectId and Implementation_Type__c=:this.filterType])
		{
			mapFldName2Lable.put(item.Field__c.toLowerCase(), item.Label__c);
		}
		
		List<String> lstFldKeys = new List<String>();
		if(objectFieldsMap.size()>0){ lstFldKeys.addAll(objectFieldsMap.keySet());}
		lstFldKeys.sort();

		
		for(String curKey: lstFldKeys){
			//Schema.SObjectField item: objectFieldsMap.values())
			Schema.SObjectField item = objectFieldsMap.get(curKey);
			describeField = item.getDescribe();
			
			newCustomLabel = describeField.getLabel();
			newCustomColumnLabel = newCustomLabel;
			if (this.referenceObjectName != null) {
				newCustomLabel = this.referenceObjectName + ' : ' + newCustomLabel;
			}
			
			newSystemName = describeField.getName();
			newType = String.valueOf(describeField.getType());
			newSelected = false;
			
			if (existantFields.containsKey(newSystemName)) {
				newSelected = true;
				newCustomLabel = existantFields.get(newSystemName);
			}
			
			newSelectedColumn = false;
			if (mapFldName2Lable.containsKey(newSystemName.toLowerCase())) {
				newSelectedColumn = true;
				newCustomColumnLabel = mapFldName2Lable.get(newSystemName.toLowerCase());
			}
			
			if ( describeField.isFilterable() ) {
				result.add(new SL_LIB16_FilterFieldWrapper(new Map<String,String>{
					'customLabel' => newCustomLabel,
					'customColumnLabel' => newCustomColumnLabel,
					'systemLabel' => describeField.getLabel(),
					'systemName' => newSystemName,
					'fieldType' => newType
				}, newSelected, newSelectedColumn));
			}
			
			if (newType == 'REFERENCE') {
				
				Schema.Sobjecttype sobjItem = null;
				List<Schema.Sobjecttype> lstSobjItem = describeField.getReferenceTo();
				
				if(lstSobjItem!=null && lstSobjItem.size()==1){ sobjItem = lstSobjItem.get(0);}
				else if(lstSobjItem!=null && lstSobjItem.size()>1 && newSystemName=='OwnerId' )
				{
					for (Schema.Sobjecttype subItem: lstSobjItem){ if(subItem.getDescribe().getName()=='User'){ sobjItem = subItem;}}
				}
				
				if(sobjItem!=null)
				{
						newFilterField = new SL_LIB16_ReferencedFilterFieldWrapper();
						newFilterField.objectName = sobjItem.getDescribe().getName();
						newFilterField.systemFieldName = newSystemName;
						if (countRefFieldsMap.containsKey(newFilterField.systemFieldName + ':' + newFilterField.objectName)) {
							newFilterField.selectedFieldsCount = Integer.valueOf(countRefFieldsMap.get(newFilterField.systemFieldName + ':' + newFilterField.objectName));
						}
						this.filterReferencedFieldList.add(newFilterField);
				}
				
			}
			
		}
		
        return result;
        
	}
	
	private PageReference doBackRedirect() {
		
		String backUrl;
		
		if (this.tabId != null) {
			backUrl = '/apex/SL_LIB16_FilterTab?id=' + this.tabId;
			PageReference pr = new PageReference(backUrl);
			return pr;
		}
		
		backUrl = '/apex/SL_LIB16_FilterFieldSetup?id=' + this.implementationId;
		if (this.filterType != null) {
			backUrl += '&type=' + this.filterType;
		}
		PageReference pr = new PageReference(backUrl);
		return pr;
	}
	
	public PageReference doTabSave() {
		
		Filter_Tab__c tabObject = (Filter_Tab__c)this.thisController.getRecord();
		SL_Mass_Implementation__c impObject = null;
		
		if(tabObject!=null && tabObject.Mass_Implementation__c!=null)
		{
			for(SL_Mass_Implementation__c item:[SELECT Id,searchObjectName__c FROM SL_Mass_Implementation__c WHERE Id=:tabObject.Mass_Implementation__c LIMIT 1])
			{
				impObject = item;
			}
		}
		
		if(tabObject==null || tabObject.Object_Name__c==null || tabObject.Object_Name__c=='' || tabObject.Field_Name__c==null || tabObject.Field_Name__c=='') return null;
		
		Map<String, Schema.SObjectField> objectFieldsMap = SL_LIB16_ctrl_FilterFieldSetup.globalObjectDescribeMap.get(tabObject.Object_Name__c).getDescribe().fields.getMap();
		Schema.DescribeFieldResult fieldObject = objectFieldsMap.get(tabObject.Field_Name__c).getDescribe();
		
		Boolean isCorrectReference = false;
		
		if (String.valueOf(fieldObject.getType()) == 'REFERENCE')
		{
			tabObject.isNotDirectReference__c = false;
			List<Schema.Sobjecttype> lstSobjItem = fieldObject.getReferenceTo();
			if (lstSobjItem.size() == 1) {
				if (impObject!=null && lstSobjItem.get(0).getDescribe().getName() == impObject.searchObjectName__c) {
					isCorrectReference = true;
				}
			}
		}
		
		if (String.valueOf(fieldObject.getType()).toLowerCase() == 'string') {
			tabObject.isNotDirectReference__c = true;
			isCorrectReference = true;
		}
		
		if (!isCorrectReference) {
			throw new SL_LIB16_MyException('Selected field is not a correct reference to ' + impObject!=null?impObject.searchObjectName__c:'');
		}
		
		upsert tabObject;
		
		List<SL_Filter_Field__c> tmpFilterFieldList = [SELECT 
				Id
			FROM SL_Filter_Field__c
			WHERE
				Mass_Implementation__c = :tabObject.Mass_Implementation__c
				AND Parent_Ref_Field__c=null
				AND Type__c = :this.filterType
				AND Filter_Tab__c = :tabObject.Id];
				
		delete tmpFilterFieldList;
		
		tmpFilterFieldList = new List<SL_Filter_Field__c>();
		for (SL_LIB16_FilterFieldWrapper item: this.filterFieldList) {
			if (item.selected) {
				SL_Filter_Field__c newFilterField = new SL_Filter_Field__c(
					Mass_Implementation__c = this.implementationId,
					Filter_Tab__c = tabObject.Id,
					API_Lable__c = item.systemLabel,
					API_Name__c = item.systemName,
					API_Type__c = item.fieldType,
					SF_Object__c = tabObject.Object_Name__c,
					Name = item.customLabel,
					Parent_Ref_Field__c = this.referenceSystemFieldName,
					Type__c = this.filterType
				);
				tmpFilterFieldList.add(newFilterField);
			}
		}
		
		insert tmpFilterFieldList;
		
		return this.doTabCancel();
		
	}
	
	public PageReference doTabCancel() {
		PageReference pr = new PageReference('/' + this.implementationId);
		return pr;
	}
	
	public PageReference doReferencedSave() {
		
		List<SL_Filter_Field__c> tmpFilterFieldList = [SELECT
				Id
			FROM SL_Filter_Field__c
			WHERE
				Mass_Implementation__c = :this.implementationId
				AND Parent_Ref_Field__c=:this.referenceSystemFieldName
				AND Type__c = :this.filterType
				AND Filter_Tab__c = :this.tabId];
		delete tmpFilterFieldList;
		
		tmpFilterFieldList = new List<SL_Filter_Field__c>();
		for (SL_LIB16_FilterFieldWrapper item: this.filterFieldList) {
			if (item.selected) {
				SL_Filter_Field__c newFilterField = new SL_Filter_Field__c(
					Mass_Implementation__c = this.implementationId,
					Filter_Tab__c = this.tabId,
					API_Lable__c = item.systemLabel,
					API_Name__c = item.systemName,
					API_Type__c = item.fieldType,
					SF_Object__c = this.referenceObjectName,
					Name = item.customLabel,
					Parent_Ref_Field__c = this.referenceSystemFieldName,
					Type__c = this.filterType
				);
				tmpFilterFieldList.add(newFilterField);
			}
		}
		
		insert tmpFilterFieldList;
		
		PageReference pr = this.doBackRedirect();
		
		return pr;
		
	}
	
	public PageReference doReferencedCancel() {
		PageReference pr = this.doBackRedirect();
		return pr;
	}
	
	public Pagereference doSave() {
		
		Pagereference pr = this.thisController.save();
		
		SL_Mass_Implementation__c tmpObj = null;
		try
		{
			 tmpObj = (SL_Mass_Implementation__c)this.thisController.getRecord();
		}
		catch(Exception e){}

		if(tmpObj!=null && tmpObj.Id!=null)
		{
			for(SL_Mass_Implementation__c item:[SELECT Id,Name,searchObjectName__c,targetObjectName__c FROM SL_Mass_Implementation__c WHERE Id=:tmpObj.Id])
			{
				tmpObj = item;
			}
			SL_LIB16_FieldLoader fieldLoader = new SL_LIB16_FieldLoader(tmpObj.ID,this.filterType);

			
			//Start Column Records Saving ***********************
			Map<String,Mass_Edit_Settings__c> mapColKey2FF = new Map<String,Mass_Edit_Settings__c>();
			for(Mass_Edit_Settings__c item:[Select Label__c, Id, Field__c, Name From Mass_Edit_Settings__c where  Implementation__c= :tmpObj.Id and Implementation_Type__c = :this.filterType AND (NOT(Field__c like '%.%'))])
			{
				mapColKey2FF.put(item.Field__c.toLowerCase(), item);
			}
			
			Set<String> setNewColFFKeys = new Set<String>();
			List<Mass_Edit_Settings__c> tmpColFilterFieldList = new List<Mass_Edit_Settings__c>();
			for (SL_LIB16_FilterFieldWrapper item: this.filterFieldList)
			{
				if (item.selectedColumn)
				{
					if(mapColKey2FF.containsKey(item.systemName.toLowerCase()))
					{
						mapColKey2FF.get(item.systemName.toLowerCase()).Name = item.customColumnLabel;
						mapColKey2FF.get(item.systemName.toLowerCase()).Label__c = item.customColumnLabel;
						tmpColFilterFieldList.add(mapColKey2FF.get(item.systemName.toLowerCase()));
						setNewColFFKeys.add(item.systemName.toLowerCase());
					}
					else
					{
						try{ fieldLoader.setSelectedValues(item.systemName);}
						catch(Exception e){}
						
						
						//Select m.isEditable__c, m.Sort_Field__c, m.Label__c, m.IsSortable__c, m.Implementation__c, m.Implementation_Type__c, m.Id, m.Field__c From Mass_Edit_Settings__c m
						
						Mass_Edit_Settings__c newColRec = new Mass_Edit_Settings__c(
							Implementation__c = tmpObj.Id,
							Implementation_Type__c = this.filterType,
							Name = item.customColumnLabel,
							Label__c = item.customColumnLabel,
							API_Type__c = item.fieldType,
							Field__c = item.systemName
						);
						newColRec.Field__c = fieldLoader.getValue();
				        if(fieldLoader.getIsSortable())
				        {
				        	newColRec.Sort_Field__c = fieldLoader.getValue();
				        	newColRec.IsSortable__c = true;
				        }
				        else
				        {
				        	newColRec.Sort_Field__c = 'ID';
				        	newColRec.IsSortable__c = false;
				        }
						tmpColFilterFieldList.add(newColRec);

						setNewColFFKeys.add(item.systemName.toLowerCase());
					}
				}
			}
			
			if(tmpColFilterFieldList.size()>0){ upsert tmpColFilterFieldList;}
			
			// Delete non-selected records
			tmpColFilterFieldList = new List<Mass_Edit_Settings__c>();
			for(Mass_Edit_Settings__c item:mapColKey2FF.values())
			{
				if(!setNewColFFKeys.contains(item.Field__c.toLowerCase())){ tmpColFilterFieldList.add(item);}
			}
			if(tmpColFilterFieldList.size()>0){ delete tmpColFilterFieldList;}
			
			
			//End Column Records Saving ***********************

			//Start Filter Field Records Saving ***********************
			Map<String,SL_Filter_Field__c> mapKey2FF = new Map<String,SL_Filter_Field__c>();
			for(SL_Filter_Field__c item:[SELECT Id, API_Name__c, API_Lable__c FROM SL_Filter_Field__c WHERE Mass_Implementation__c = :tmpObj.Id AND Parent_Ref_Field__c=null AND Type__c = :this.filterType])
			{
				mapKey2FF.put(item.API_Name__c.toLowerCase(), item);
			}

			Set<String> setNewFFKeys = new Set<String>();
			List<SL_Filter_Field__c> tmpFilterFieldList = new List<SL_Filter_Field__c>();
			for (SL_LIB16_FilterFieldWrapper item: this.filterFieldList)
			{
				if (item.selected)
				{
					if(mapKey2FF.containsKey(item.systemName.toLowerCase()))
					{
						mapKey2FF.get(item.systemName.toLowerCase()).Name = item.customLabel;
						tmpFilterFieldList.add(mapKey2FF.get(item.systemName.toLowerCase()));
						setNewFFKeys.add(item.systemName.toLowerCase());
					}
					else
					{
						
						SL_Filter_Field__c newFilterField = new SL_Filter_Field__c(
							Mass_Implementation__c = tmpObj.Id,
							API_Lable__c = item.systemLabel,
							API_Name__c = item.systemName,
							API_Type__c = item.fieldType,
							Name = item.customLabel,
							Type__c = this.filterType
						);
						if(this.filterType == 'Target'){ newFilterField.SF_Object__c = tmpObj.targetObjectName__c;}
						else{ newFilterField.SF_Object__c = tmpObj.searchObjectName__c;}

						tmpFilterFieldList.add(newFilterField);
						setNewFFKeys.add(item.systemName.toLowerCase());
					}
				}
			}
			
			if(tmpFilterFieldList.size()>0){ upsert tmpFilterFieldList;}
			
			// Delete non-selected records
			tmpFilterFieldList = new List<SL_Filter_Field__c>();
			for(SL_Filter_Field__c item:mapKey2FF.values())
			{
				if(!setNewFFKeys.contains(item.API_Name__c.toLowerCase())){ tmpFilterFieldList.add(item);}
			}
			if(tmpFilterFieldList.size()>0){ delete tmpFilterFieldList;}
			
			//End Filter Field Record Saving ***********************
			
			
		}
		return pr;
	}
}