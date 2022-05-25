/**
 * 
 * @author Privlad
 */
public without sharing class SL_LIB16_handler_Implementation
{
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public SL_LIB16_handler_Implementation(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(list<SL_Mass_Implementation__c> newRecord)
    {
    	this.processExtIDs(newRecord);
    }
    
    public void OnAfterInsert(map<ID,SL_Mass_Implementation__c> newRecordMap){
    	this.checkValidData(this.loadFullData(newRecordMap.values()), newRecordMap);
    	this.createFFRecords(newRecordMap);
    	this.createDefaultViews(newRecordMap);
    	
    }
    
    @future public static void OnAfterInsertAsync(Set<ID> newRecordIDs){ }
    
    public void OnBeforeUpdate(map<ID,SL_Mass_Implementation__c> oldRecordMap, map<ID,SL_Mass_Implementation__c> newRecordMap){ }
    
    public void OnAfterUpdate(map<ID,SL_Mass_Implementation__c> oldRecordMap, map<ID,SL_Mass_Implementation__c> newRecordMap){
    	this.checkValidData(this.loadFullData(newRecordMap.values()), newRecordMap);
    	this.checkValidDataOnUpdate(oldRecordMap, newRecordMap);
    	this.checkValidDataOnUpdate2(oldRecordMap, newRecordMap);
    	
    	checkAddPageViews(oldRecordMap,newRecordMap);
    }
    
    @future public static void OnAfterUpdateAsync(Set<ID> updatedRecordIDs){ }
    
    public void OnBeforeDelete(map<ID,SL_Mass_Implementation__c> oldRecordMap){ }
    
    public void OnAfterDelete(map<ID,SL_Mass_Implementation__c> oldRecordMap){
    }
    
    @future public static void OnAfterDeleteAsync(Set<ID> deletedRecordIDs){ }
    
    public void OnBeforeUndelete(list<SL_Mass_Implementation__c> restoredRecords){ }
    
    public void OnAfterUndelete(list<SL_Mass_Implementation__c> restoredRecords){ }
    
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
    
    public boolean IsVisualforcePageContext{
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsWebServiceContext{
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsExecuteAnonymousContext{
        get{ return !IsTriggerContext;}
    }
    
	private void checkValidDataOnUpdate2(map<ID,SL_Mass_Implementation__c> oldRecordMap, map<ID,SL_Mass_Implementation__c> newRecordMap)
    {
    	Set<ID> setImplIds = new Set<ID>();
    	for(SL_Mass_Implementation__c item:newRecordMap.values())
    	{
    		if(item.targetObjectName__c!=oldRecordMap.get(item.ID).targetObjectName__c || item.parentObjectName__c!=oldRecordMap.get(item.ID).parentObjectName__c 
    			|| item.searchObjectName__c!=oldRecordMap.get(item.ID).searchObjectName__c)
    		{
    			setImplIds.add(item.ID);
    		}
    	}
    	
    	if(setImplIds.size()>0)
    	{
    		Set<ID> setImplIdsCanNotChange = new Set<ID>();
    		for(SL_Filter_Field__c item:[select ID,Mass_Implementation__c from SL_Filter_Field__c where Mass_Implementation__c in :setImplIds])
    		{
    			setImplIdsCanNotChange.add(item.Mass_Implementation__c);
    		}
    		
    		if(setImplIdsCanNotChange.size()>0)
    		{
    			for(ID idKey:setImplIdsCanNotChange){ newRecordMap.get(idKey).addError('You are not able to save these changes, because this implementation has Filter Field Records');}
    		}
    		setImplIdsCanNotChange = new Set<ID>();
    		
    		for(Mass_Edit_Settings__c item:[select ID,Implementation__c from Mass_Edit_Settings__c where Implementation__c in :setImplIds])
    		{
    			setImplIdsCanNotChange.add(item.Implementation__c);
    		}
    		
    		if(setImplIdsCanNotChange.size()>0)
    		{
    			for(ID idKey:setImplIdsCanNotChange){ newRecordMap.get(idKey).addError('You are not able to save these changes, because this implementation has Column Records');}
    		}
    		
    	}
    	
    }    
    
    private void checkValidDataOnUpdate(map<ID,SL_Mass_Implementation__c> oldRecordMap, map<ID,SL_Mass_Implementation__c> newRecordMap)
    {
    	for(SL_Mass_Implementation__c item:newRecordMap.values())
    	{
    		if(item.ExtID__c==null || item.ExtID__c!=oldRecordMap.get(item.ID).ExtID__c)
    		{
    			item.ExtID__c.addError('You are not able to change this value.');
    		}
    	}
    }
    
	private void processExtIDs(list<SL_Mass_Implementation__c> newRecord)
	{
		SL_Mass_Implementation__c maxImplExtID = null;
		Decimal cutInd = 0;
		for(SL_Mass_Implementation__c item:[select ExtID__c from SL_Mass_Implementation__c order by ExtID__c desc limit 1]){ maxImplExtID = item;}
		if(maxImplExtID!=null && maxImplExtID.ExtID__c!=null){ cutInd = maxImplExtID.ExtID__c;}
		for(SL_Mass_Implementation__c item:newRecord)
		{
			cutInd++;
			item.ExtID__c = cutInd;
		}
	}
	
	private void proccessFFWrapper(List<SL_Filter_Field__c> inLstFF, List<SL_LIB16_FilterFieldWrapper> lstFFWrapper, ID implID, String inFilterType, String inObjectName)
    {
    	if(lstFFWrapper!=null && lstFFWrapper.size()>0)
		{
			for (SL_LIB16_FilterFieldWrapper item: lstFFWrapper)
			{
				SL_Filter_Field__c newFilterField = new SL_Filter_Field__c(
						Mass_Implementation__c = implID,
						/*Filter_Tab__c = null,*/
						API_Lable__c = item.systemLabel,
						API_Name__c = item.systemName,
						API_Type__c = item.fieldType,
						SF_Object__c = inObjectName,
						Name = item.customLabel,
						/*Parent_Ref_Field__c = null,*/
						Type__c = inFilterType
					);
					inLstFF.add(newFilterField);
			}
		}
    }
    
    private void checkAddPageViews(map<ID,SL_Mass_Implementation__c> oldRecordMap, map<ID,SL_Mass_Implementation__c> newRecordMap)
    {
    	Set<ID> setImplAddPage = new Set<ID>();
    	
    	for(SL_Mass_Implementation__c item:newRecordMap.values())
    	{
    		if(item.Use_Step2_Multi_Add_Form__c!=oldRecordMap.get(item.Id).Use_Step2_Multi_Add_Form__c && item.Use_Step2_Multi_Add_Form__c==true)
    		{
    			setImplAddPage.add(item.Id);
    		}
    	}
    	
    	if(setImplAddPage.size()>0)
    	{
    		Set<ID> setImplAddPageWithView = new Set<ID>();
    		for(SL_View__c item:[select Implementation__c, ID from SL_View__c where Implementation__c in :setImplAddPage and Implementation_Type__c='AddPage'])
    		{
    			setImplAddPageWithView.add(item.Implementation__c);
    		}
    		
    		for(ID itemKey:setImplAddPage)
    		{
    			if(!setImplAddPageWithView.contains(itemKey))
    			{
    				newRecordMap.get(itemKey).Use_Step2_Multi_Add_Form__c.addError('You are not able to use this option without  \'AddPage\' View.');
    			}
    		}
    	}
    	
    }
    
    private void createDefaultViews(map<ID,SL_Mass_Implementation__c> mapInTriggers)
    {
    	List<SL_View__c> lstViews = new List<SL_View__c>();
		
		for(SL_Mass_Implementation__c item:mapInTriggers.values())
		{
			lstViews.add(new SL_View__c(Implementation__c=item.ID,Implementation_Type__c='Target', Name='All',RowsCount__c=50,Columns__c='',IsDefault__c=true));
			lstViews.add(new SL_View__c(Implementation__c=item.ID,Implementation_Type__c='Search', Name='All',RowsCount__c=50,Columns__c='',IsDefault__c=true));
			lstViews.add(new SL_View__c(Implementation__c=item.ID,Implementation_Type__c='ManageTargets', Name='All',RowsCount__c=50,Columns__c='',IsDefault__c=false));
			if(item.Use_Step2_Multi_Add_Form__c==true) lstViews.add(new SL_View__c(Implementation__c=item.ID,Implementation_Type__c='AddPage', Name='Multi Add: Second Page',RowsCount__c=100,Columns__c='',IsDefault__c=false));
    	}
		if(lstViews.size()>0) Database.insert(lstViews, false);
    }
    
	private void createFFRecords(map<ID,SL_Mass_Implementation__c> mapInTriggers)
	{
		List<SL_Filter_Field__c> tmpFilterFieldList2Add = new List<SL_Filter_Field__c>();
		
		List<SL_Filter_Field__c> tmpFilterFieldList = new List<SL_Filter_Field__c>();
		SL_LIB16_ctrl_FilterFieldSetup FFSetupObject = null;
	
		for(ID item:mapInTriggers.keySet())
		{
			FFSetupObject = new SL_LIB16_ctrl_FilterFieldSetup(item, 'Search');
			FFSetupObject.onChangeMainObject();
			this.proccessFFWrapper(tmpFilterFieldList, FFSetupObject.filterFieldList, item, 'Search', mapInTriggers.get(item).searchObjectName__c);
			
			FFSetupObject = new SL_LIB16_ctrl_FilterFieldSetup(item, 'Target');
			FFSetupObject.onChangeMainObject();
			this.proccessFFWrapper(tmpFilterFieldList, FFSetupObject.filterFieldList, item, 'Target', mapInTriggers.get(item).targetObjectName__c);
		}
		
		if(tmpFilterFieldList.size()>0 && tmpFilterFieldList.size()<20000)
		{
			for(SL_Filter_Field__c item:tmpFilterFieldList)
			{
				tmpFilterFieldList2Add.add(item);
				if(tmpFilterFieldList2Add.size()==200)
				{
					insert tmpFilterFieldList2Add;
					tmpFilterFieldList2Add = new List<SL_Filter_Field__c>();
				}
			}
			if(tmpFilterFieldList2Add.size()>0){ insert tmpFilterFieldList2Add;}
		}
	}
    
    
    private List<SL_Mass_Implementation__c> loadFullData(List<SL_Mass_Implementation__c> inListVal)
    {
    	Set<ID> inIDs = new Set<ID>();
    	for(SL_Mass_Implementation__c item: inListVal){ inIDs.add(item.ID);}
    	return [Select targetObjectSearchFieldName__c, targetObjectParentFieldName__c, targetObjectName__c, searchObjectName__c, parentObjectName__c, Name, 
    			Show_Views_on_MassEdit_Page__c, Show_Views_on_MassAdd_Page__c, Search_Page_Title__c, Search_Object_Title__c, Id, Get_Element_from_List_Tab__c 
    			From SL_Mass_Implementation__c where ID in :inIDs];
    }
    
    private void checkValidData(List<SL_Mass_Implementation__c> inListVal, map<ID,SL_Mass_Implementation__c> mapInTriggers)
	{
		SL_LIB16_ME_DescribeObject_Core locDescribeObject = new SL_LIB16_ME_DescribeObject_Core();
		Map<String,String> mapName2Label = locDescribeObject.getObjects('All Objects');
		List<SObjectType> aLinksTo;
		boolean isRefObjCorrect = false;
		
		//set<String> setObjectNames = Schema.getGlobalDescribe().keySet();
		
		
		for(SL_Mass_Implementation__c item:inListVal)
		{
			if(item.targetObjectName__c==null || item.targetObjectName__c=='' || !mapName2Label.containsKey(item.targetObjectName__c.toLowerCase()))
			{
				mapInTriggers.get(item.ID).targetObjectName__c.addError('Target object with this API name does not exist.');
			}
			else
			{
				if(item.targetObjectParentFieldName__c==null || item.targetObjectParentFieldName__c=='')
				{
					mapInTriggers.get(item.ID).targetObjectParentFieldName__c.addError('Target Object\'s Field with this API name does not exist.');
				}
				else
				{
					Schema.DescribeFieldResult fldRes1 = locDescribeObject.getFieldDescriptionByName(item.targetObjectName__c,item.targetObjectParentFieldName__c);
					if(fldRes1==null || (''+fldRes1.getType()).toUpperCase()!='REFERENCE')
					{
						mapInTriggers.get(item.ID).targetObjectParentFieldName__c.addError('Target Object\'s Field with this API name doesn\'t exist or doesn\'t have REFERENCE type');
					}
					else
					{
						aLinksTo = fldRes1.getReferenceTo();
						isRefObjCorrect = false;
						
               			if (aLinksTo != null && aLinksTo.size() != 0 && item.parentObjectName__c!=null && item.parentObjectName__c!='')
               			{
							for (SObjectType oLinkObject : aLinksTo)
							{
								if(oLinkObject.getDescribe().getName().toLowerCase() == item.parentObjectName__c.toLowerCase()){ isRefObjCorrect = true;}
							}
							
						}
						if(!isRefObjCorrect) mapInTriggers.get(item.ID).targetObjectParentFieldName__c.addError('Target Object\'s Field doesn\'t reference to Parent Object');
					}
				}

				if(item.targetObjectSearchFieldName__c==null || item.targetObjectSearchFieldName__c=='')
				{
					mapInTriggers.get(item.ID).targetObjectSearchFieldName__c.addError('Target Object\'s Field with this API name does not exist.');
				}
				else
				{
					Schema.DescribeFieldResult fldRes2 = locDescribeObject.getFieldDescriptionByName(item.targetObjectName__c,item.targetObjectSearchFieldName__c);
					if(fldRes2==null || (''+fldRes2.getType()).toUpperCase()!='REFERENCE')
					{
						mapInTriggers.get(item.ID).targetObjectSearchFieldName__c.addError('Target Object\'s Field with this API name does not exist or doesn\'t have REFERENCE type');
					}
					else
					{
						aLinksTo = fldRes2.getReferenceTo();
						isRefObjCorrect = false;
						
               			if (aLinksTo != null && aLinksTo.size() != 0 && item.searchObjectName__c!=null && item.searchObjectName__c!='')
               			{
							for (SObjectType oLinkObject : aLinksTo)
							{
								if(oLinkObject.getDescribe().getName().toLowerCase() == item.searchObjectName__c.toLowerCase()){ isRefObjCorrect = true;}
							}
							
						}
						if(!isRefObjCorrect) mapInTriggers.get(item.ID).targetObjectSearchFieldName__c.addError('Target Object\'s Field does not reference to Search Object');
					}
				}

			}

			if(item.searchObjectName__c==null || item.searchObjectName__c=='' || !mapName2Label.containsKey(item.searchObjectName__c.toLowerCase()))
			{
				mapInTriggers.get(item.ID).searchObjectName__c.addError('Search object with this API name does not exist.');
			}

			if(item.parentObjectName__c==null || item.parentObjectName__c=='' || !mapName2Label.containsKey(item.parentObjectName__c.toLowerCase()))
			{
				mapInTriggers.get(item.ID).parentObjectName__c.addError('Parent object with this API name does not exist.');
			}

			

		}
	}
}