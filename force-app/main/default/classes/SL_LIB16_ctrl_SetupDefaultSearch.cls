public with sharing class SL_LIB16_ctrl_SetupDefaultSearch {
	
	private ApexPages.StandardController thisController;
	
	public SL_Mass_Implementation__c getMassEditSettings(){return currMainCusSettings;}
    public String cb_target {get; set;}
    public String cb_advFilters {get; set;}
    public String SearchTarget {get; set;}
    
	public String SearchParam {get; set;}
	public String SearchQ {get; set;}
	public String SearchObj {get; set;}
	public String SearchSection {get; set;}
    
    public String dateFormat {get{return SL_LIB16_DateObject.dateFormat;}set;}
    
    
    public SL_LIB16_UserChoise__c currentSearchSettings = null;
    
    
    public SL_LIB16_UserChoise__c getCurrentSearchSettings()
    {
    	if(this.currentSearchSettings == null)
    	{
    		SL_LIB16_UserChoise__c retVal = (SL_LIB16_UserChoise__c)this.thisController.getRecord();
    		//system.debug('retVal: +++++++++++'+retVal);
    		if (retVal!=null && retVal.Id != null)
    		{
    			for(SL_LIB16_UserChoise__c item:[SELECT Id,Mass_Implementation__c,Serialized_Data__c,Filter_Tab__c,User__c,Type__c,View__c,Implementation_Type__c FROM SL_LIB16_UserChoise__c WHERE Id = : retVal.Id])
    			{
					currentSearchSettings = item;
					
					cb_target = item.Filter_Tab__c;
					if (cb_target == null){ cb_target = 'Main';}
				
    			}
    		}
    		else
    		{
    			currentSearchSettings = new SL_LIB16_UserChoise__c(Mass_Implementation__c=(retVal!=null?retVal.Mass_Implementation__c:null));
    			cb_target = 'Main';
    		}
    	}
    	return currentSearchSettings;
    }
    
    public void setCurrentSearchSettings(SL_LIB16_UserChoise__c inVal)
    {
    	this.currentSearchSettings = inVal;
    }
    
    public List<SelectOption> availableUsers {
    	get {
    		List<SelectOption> result = new List<SelectOption>();
    		return result;
    	}
    }
    
    public String target {
        get{
            String retVal = System.currentPageReference().getParameters().get('target');
            if(retVal==null) retVal = this.SearchTarget;
            return retVal;     
        }
    }
	
	public SL_LIB16_ctrl_SetupDefaultSearch(Apexpages.StandardController controller)
	{
		//system.debug('test: +++++++++++');
		Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=9');
		
        this.SearchTarget = 'Main';
		this.thisController = controller;
		getCurrentSearchSettings();
		
		//this.getFiltersJSON();
		
	}

    public String getFiltersJSON()
    {
    	
    	String result = '[]';
    	
        Id currentUserId = UserInfo.getUserId();
        Id selectedTabId = null;
        if (this.target != 'Main') {
        	selectedTabId = this.target;
        }
        
        try {
        	
        	SL_LIB16_UserChoise__c choiceObject = this.currentSearchSettings;
        	
			if (choiceObject.Serialized_Data__c != null) {
				Map<String, String> mappedData = (Map<String, String>)Json.deserialize(choiceObject.Serialized_Data__c, Map<String, String>.class);
				String SearchQ = mappedData.get('SearchQ');
				List<String> strArr = SearchQ.split('##');
				result = '';
				for (String item: strArr) {
					List<String> valArr = item.split('___');
					if(valArr.size()>1)
					{
						result += ', { name: "' + valArr[1] + '", operator: "' + valArr[2] + '", value: "' + ((valArr.size()>3 && valArr[3]!=null)?valArr[3]:'') + '"}';
					}
				}
				if (result.length()>0) result = result.substring(1);
				result = '[' + result + ']';
				cb_advFilters = mappedData.get('SearchParam');
				cb_target = choiceObject.Filter_Tab__c;
			}
			
			if (cb_target == null) {
				cb_target = 'Main';
			}
				
        } catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        	
    	return result;
    }
    
    private SL_Mass_Implementation__c currMainCusSettings {
    	get {
    		
    		SL_Mass_Implementation__c result;
    		
			if(currMainCusSettings==null) {
				if (!isNullOrEmpty(implementationId)) {
					
					try {
						
						SL_Mass_Implementation__c item = [Select
									targetObjectSearchFieldName__c,
									targetObjectParentFieldName__c,
									targetObjectName__c,
									searchObjectName__c,
									parentObjectName__c,
									Show_Views_on_MassEdit_Page__c,
									Show_Views_on_MassAdd_Page__c,
									Search_Page_Title__c,
									Search_Object_Title__c,
									Name,
									Id,
									Get_Element_from_List_Tab__c
								From SL_Mass_Implementation__c
								where Id=:implementationId
								limit 1];
								
						SL_LIB16_ctrl_CompanyListSearch.MainObjName = item.name;
						SL_LIB16_ctrl_CompanyListSearch.MainObjNameID = item.ID;
						
						result = item;
						
					} catch(Exception e) {
	                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Incorrect Implementation or problem with custom settings!'));
	                }
					
				} 
			}
			return result;
    	}
    }
	
    private Boolean isNullOrEmpty(String p_str) {
        return (p_str == null || p_str == ''); 
    }

    public String implementationId {
    	get {
    		return this.currentSearchSettings.Mass_Implementation__c;
    	}
    }

   
    // ###### tabs ######

    public List<SelectOption> tabs;
    
    public List<SelectOption> getTabs() {
        List<SelectOption> tabs = new List<SelectOption>{new SelectOption('Main', currMainCusSettings.Search_Object_Title__c)};
        List<Filter_Tab__c> tabObjects = [SELECT Id,Mass_Implementation__c,Object_Name__c,Name FROM Filter_Tab__c WHERE Mass_Implementation__c=:this.currMainCusSettings.Id];
        for (Filter_Tab__c item: tabObjects) {
            tabs.add(new SelectOption(''+item.Id, item.Name));
        }
        return tabs;
    }

	public List<SelectOption> getTabsObjName()
    {
    	List<SelectOption> retVal = new List<SelectOption>();
    	retVal.add(new selectOption('Search_'+currMainCusSettings.ID,currMainCusSettings.searchObjectName__c));
		for(Filter_Tab__c item : [SELECT Id,Object_Name__c FROM Filter_Tab__c WHERE Mass_Implementation__c=:this.currMainCusSettings.Id])
		{
			retVal.add(new selectOption('Tab_'+item.ID, item.Object_Name__c));
		}
    	
    	//lstColumnsAndFiltersTemplate.add(new selectOption(objColumnsAndFiltersTemplate.Name, objColumnsAndFiltersTemplate.Name));
    	return retVal;
    }    

    public void setTabs(List<SelectOption> inTabs) {
        this.tabs = inTabs;
    }

	
    public SL_LIB209_ctrl_SearchBlockParams getSearchCompParams()
    {
    	SL_LIB209_ctrl_SearchBlockParams retVal = new SL_LIB209_ctrl_SearchBlockParams();
    	retVal.tabs = this.getTabs();
    	retVal.tabsObjName = this.getTabsObjName();
    	
    	retVal.mainSelTarget = 'Search_'+implementationId;
    	retVal.locationBase = '/apex/SL_LIB16_CompanyListSearch_JSON?implId='+implementationId+'&event=';
    	retVal.searchBtnClick = '';
    	retVal.FiltersJSON = this.getFiltersJSON();
    	retVal.cb_target = this.cb_target;
    	retVal.cb_advFilters = this.cb_advFilters;
    	retVal.dateFormat = SL_LIB16_DateObject.dateFormat;
    	
    	
    	return retVal;
    }
    
        
    

    // ###### end of tabs ######
    
    public Pagereference doSave()
    {
    	Id selectedTabId = null;
    	if(this.SearchObj!=null && this.SearchObj!='')
        {
        	List<String> lstGetParams = this.SearchObj.split('_');
        	if(lstGetParams[0]=='Tab'){
        		try{selectedTabId = lstGetParams[1];}
            	catch(Exception e){}
        	}
        }
    	currentSearchSettings.Filter_Tab__c = selectedTabId;
    	Map<String, String> arrayData = new Map<String, String> {
				'SearchQ' => SearchQ,
				'SearchParam' => SearchParam,
				'TargetObject' => currMainCusSettings.searchObjectName__c
			};
			
		currentSearchSettings.Serialized_Data__c = JSON.serialize(arrayData);
    	
    	
    	upsert currentSearchSettings;
    	
    	
    	
    	PageReference pr = new PageReference('/' + this.implementationId);
		return pr;
    }
    
}