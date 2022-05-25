/*
  created: Vladidmir Prishlyak 
*/
public virtual without sharing class SL_LIB16_ctrl_CompanyListSearch
{
    /************ MAIN param - you have to change it if you need to switch to other SF objects ************/
    public static String MainObjName = null;
    public static ID MainObjNameID = null;
    public static String dateFormat {get{return SL_LIB16_DateObject.dateFormat;}set;}
    public Boolean isNoExceptionThrown {get; set;} //= true;
    public Boolean isUserSysAdmin {get; set;}
    
    /******************************* for Views *******************************/
    public String strView {get;set;}//Added by sandeep
    public List<SelectOption> lstColumnsAndFiltersTemplate {get; set;}//Added by sandeep
    public Boolean isShowDeleteButton  {get;set;}//Added by sandeep
    public String strColumnsAndFiltersTemplate
    {
        get 
        {
            if((strColumnsAndFiltersTemplate==null || strColumnsAndFiltersTemplate=='') && strView!=null && strView!='' && !isNewView) return strView;
            return strColumnsAndFiltersTemplate;
        }
        set;
    }
    public boolean inEditColumns {get; set;}
    public String selectedColumnsCallback {get; set;}
   
    public List<SL_LIB16_MassEdit.ColumnInfo> columns {get; set;}
    
    private SL_Mass_Implementation__c currMainCusSettings = null;
    private String currTplColumns = '';
    private ID curViewID = null; 
    public boolean isNewView {get; set;}

    public boolean isShowStep2 {get; set;}
    
    public Boolean hasNoError {get; set;}
    public Boolean hasSearched {get; set;}
    public Integer curPageNumber {get; set;}
    public Integer curPageSize {get; set;}
    public String Query {get; set;}
    public Set<ID> curSelIDsSet = new Set<ID>();
    public List<SelectOption> pageSizeValues {get; set;}
    public SL_LIB209_ctrl_SearchBlockParams curSearchBlockParams;

    public String SearchParam {get; set;}
    public String SearchTarget {get; set;}
    public String SearchQ {get; set;}
    public String SearchObj {get; set;}
    public String SearchSection {get; set;}
    public List<LineGetListWrapper> lstLineGetLists {get; set;}
    
    /*Main*/
    public List<JSONObject> m_target_object_fields_list_company;
    public SL_LIB16_FilterSOQLCompiler m_filters = new SL_LIB16_FilterSOQLCompiler();
    protected SL_LIB16_ME_DescribeObject_Core m_describe_object_core = null;
    protected List<CompanyExtend> m_companies {get; set;}
    public SObject addCLObj { get; set; }
    public Blob csvContentFile { get; set; }
	public String csvNameFile { get; set; }
	
	public boolean isOnlyDefaultView {get; set;}
	public String fldViewVisibility { get; set; }
	public List<SelectOption> getFldViewVisibilityVals()
	{
		List<SelectOption> options = new List<SelectOption>();
		if(isUserSysAdmin) options.add(new SelectOption('Public','Public'));
		options.add(new SelectOption('Private','Private'));
		return options;
	}
	

    public String cb_advFilters {get; set;}
    public String cb_target {get; set;}
    
    public List<SObject> lstMemberItems{ get; set; }
    
    // ###### tabs ######
    public List<SelectOption> tabs;
    
    public List<SelectOption> getTabs() {
        List<SelectOption> tabs = new List<SelectOption>{new SelectOption('Main', (this.currMainCusSettings!=null&&currMainCusSettings.Search_Object_Title__c!=null)?currMainCusSettings.Search_Object_Title__c:'')};
        if(this.currMainCusSettings!=null)
        {
	        List<Filter_Tab__c> tabObjects = [SELECT Id,Mass_Implementation__c,Object_Name__c,Name FROM Filter_Tab__c WHERE Mass_Implementation__c=:this.currMainCusSettings.Id];
	        for (Filter_Tab__c item: tabObjects) {
	            tabs.add(new SelectOption(''+item.Id, item.Name));
	        }
        }
        return tabs;
    }
    
    public List<SelectOption> getTabsObjName()
    {
    	List<SelectOption> retVal = new List<SelectOption>();
		if(this.currMainCusSettings!=null)
        {
        	retVal.add(new selectOption('Search_'+currMainCusSettings.ID,(currMainCusSettings.searchObjectName__c!=null)?currMainCusSettings.searchObjectName__c:''));
			for(Filter_Tab__c item : [SELECT Id,Object_Name__c FROM Filter_Tab__c WHERE Mass_Implementation__c=:this.currMainCusSettings.Id])
			{
				retVal.add(new selectOption('Tab_'+item.ID, item.Object_Name__c));
			}
        }
    	
    	//lstColumnsAndFiltersTemplate.add(new selectOption(objColumnsAndFiltersTemplate.Name, objColumnsAndFiltersTemplate.Name));
    	return retVal;
    }
    
    public void setTabs(List<SelectOption> inTabs) {
        this.tabs = inTabs;
    }
    // ###### end of tabs ######
    
      
    public SL_LIB16_ctrl_CompanyListSearch()
    {
        isNoExceptionThrown = true;
        isUserSysAdmin = compareUserProfileWithSysAdmin();
        ShowEditDeleteProfile();

        this.SearchTarget = 'Main';
        this.isShowStep2 = false;
        
        if (cb_target == null){ cb_target = 'Main';}
        
        ///* OLD
        if(this.getCurrMainCusSettings()==null || TargetObject==null)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Problem with Mass Edit Settings!'));
            hasNoError = false;
        }
        else
        {
            hasNoError = true;
            isNewView = false;
            //m_describe_object_core = SL_LIB16_ME_DescribeObject_Core.getInstance(TargetObject.toLowerCase());
            m_describe_object_core = SL_LIB16_ME_DescribeObject_Core.getInstance();
            m_target_object_fields_list_company = new List<JSONObject>();

            pageSizeValues = SL_LIB16_MassEdit.getRowQtySelectOptList(this.getCurrMainCusSettings());

            addCLObj = Schema.getGlobalDescribe().get(currMainCusSettings.targetObjectName__c).newSObject();
            curPageSize = 20;
            try
            {
                if(pageSizeValues.size()>0){ curPageSize = Integer.valueOf(pageSizeValues.get(0).getValue());}
            }
            catch(Exception ex){}
            Query = '';
            hasSearched = false;
            SearchSection='F';
            curSelIDsSet = new Set<ID>();
            loadViews(strColumnsAndFiltersTemplate, true);
            
            Set<String> setSelectedColumn = new Set<String>();
            if(currTplColumns!=null && currTplColumns!='')
            {
                for(String item : currTplColumns.split(',')){ setSelectedColumn.add(item.toLowerCase());}
            }
            
            columns = new List<SL_LIB16_MassEdit.ColumnInfo>();
            for(Mass_Edit_Settings__c item : [SELECT Field__c, Sort_Field__c, Label__c, IsSortable__c,Field_Style__c FROM Mass_Edit_Settings__c where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Search' ORDER BY Label__c])
            {
                if(item.Field__c!=null && item.Sort_Field__c!=null && item.Label__c!=null)
                {
                    columns.add(new SL_LIB16_MassEdit.ColumnInfo(item.Field__c.toLowerCase(), item.Sort_Field__c.toLowerCase(), item.Label__c, setSelectedColumn.contains(item.Label__c.toLowerCase()), item.IsSortable__c));
                }
            }
            
            List<Mass_Edit_Settings__c> tmp4Test = aSearchColumns;
        }
        this.initSearchBlockParams();
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=10');
		
	}

    public SL_Mass_Implementation__c getMassEditSettings(){return currMainCusSettings;}
    
    public void initSearchBlockParams()
    {
    	curSearchBlockParams = new SL_LIB209_ctrl_SearchBlockParams();
    	curSearchBlockParams.FiltersJSON = this.getFiltersJSON();
    	curSearchBlockParams.tabs = this.getTabs();
    	curSearchBlockParams.tabsObjName = this.getTabsObjName();
    	curSearchBlockParams.mainSelTarget = 'Search_'+implementationId;
    	curSearchBlockParams.locationBase = '/apex/SL_LIB16_CompanyListSearch_JSON?implId='+implementationId+'&clid='+CompanyListID+'&event=';
    	curSearchBlockParams.searchBtnClick = 'doClSearchFun()';
    	curSearchBlockParams.cb_target = this.cb_target;
    	curSearchBlockParams.cb_advFilters = this.cb_advFilters;
    	curSearchBlockParams.dateFormat = SL_LIB16_DateObject.dateFormat;

	    curSearchBlockParams.SearchParam = this.SearchParam;
	    curSearchBlockParams.SearchQ = this.SearchQ;
    	curSearchBlockParams.SearchObj = this.SearchObj;
    	curSearchBlockParams.SearchTarget = this.SearchTarget;
    }
    
    
    public SL_LIB209_ctrl_SearchBlockParams getSearchCompParams()
    {
    	return curSearchBlockParams;
    }
    
    public List<CompanyExtend> getLstMemberItemsAdd()
    {
    	List<CompanyExtend> retVal = new List<CompanyExtend>();
    	
    	Integer ind = 1;
    	if(lstMemberItems!=null && lstMemberItems.size()>0)
    	{
    		for(SObject item:lstMemberItems){ retVal.add( new CompanyExtend(item,true,ind++));}
    	}
    	
    	return retVal;
    }

    public void loadViews(String inVal, boolean isPrePageLoad)
    {
        String firstViewName = '';
        String firstViewColumns = '';
        lstColumnsAndFiltersTemplate = new List<SelectOption>();
        Boolean isPageLoad = isPrePageLoad;
        Boolean isViewExists = false;
        
        
        
        
        if(currMainCusSettings!=null && currMainCusSettings.searchObjectName__c!=null)
        {
        	if(inVal==null)
        	{
        		SL_LIB16_UserChoise__c curUserChoise = null;
				for(SL_LIB16_UserChoise__c item:[SELECT Id, View__c, View__r.Name, View__r.Columns__c, View__r.RowsCount__c, Implementation_Type__c FROM SL_LIB16_UserChoise__c 
								WHERE View__c != null and Mass_Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Search' and User__c=:UserInfo.getUserId() limit 1])
	    		{
	    			curUserChoise = item;
	    		}
				
				if(curUserChoise!=null)
				{
					inVal = curUserChoise.View__r.Name;
					this.curPageSize = (Integer)curUserChoise.View__r.RowsCount__c;
				}
        	
        	}
        	
        	isOnlyDefaultView = true;
			List<SL_View__c> lstViews4 = [Select Name, Id, Columns__c, IsDefault__c From SL_View__c where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Search' and (User__c=:UserInfo.getUserId() or IsDefault__c=true or Visibility__c='Public') ORDER BY Name];
        	if(lstViews4!=null && lstViews4.size()>0)
			{
            for(SL_View__c objColumnsAndFiltersTemplate:lstViews4)
            {
                if(lstViews4.size()==1 || !objColumnsAndFiltersTemplate.IsDefault__c)
				{
	                lstColumnsAndFiltersTemplate.add(new selectOption(objColumnsAndFiltersTemplate.Name, objColumnsAndFiltersTemplate.Name));
	                if(!objColumnsAndFiltersTemplate.IsDefault__c){ isOnlyDefaultView = false;}

	                if(isPageLoad)
	                {
	                    firstViewName = objColumnsAndFiltersTemplate.Name;
	                    //currTplColumns = objColumnsAndFiltersTemplate.Columns__c;
	                    firstViewColumns = objColumnsAndFiltersTemplate.Columns__c;
	                    isPageLoad = false;
	                    
	                    this.curViewID = objColumnsAndFiltersTemplate.Id;
	                }
	                if(objColumnsAndFiltersTemplate.Name == inVal)
	                {
	                    isViewExists = true;
	                    currTplColumns = objColumnsAndFiltersTemplate.Columns__c;
	                    strColumnsAndFiltersTemplate = objColumnsAndFiltersTemplate.Name;
	                    this.curViewID = objColumnsAndFiltersTemplate.Id;
	                }
				}
            }
			}
        }
        
        if(inVal==null || inVal=='' || !isViewExists)
        {
            strColumnsAndFiltersTemplate = firstViewName;
            currTplColumns = firstViewColumns;
        }
        
    }
    
    public List<LineGetListWrapper> getLineGetLists()
    {
		if(this.lstLineGetLists==null)
		{
		
			this.lstLineGetLists = new List<LineGetListWrapper>();
	
			//currMainCusSettings.Using_Exists_Impl__c
			List<ID> lstSelIDs = new List<ID>();
	        
			if(currMainCusSettings.Using_Exists_Impl__c!=null && currMainCusSettings.Using_Exists_Impl__c!='')
	        {
	        	for(String item:currMainCusSettings.Using_Exists_Impl__c.split(',')){ lstSelIDs.add((ID)item);}
	        	Map<id,SL_Mass_Implementation__c> mapGetListImpl = new Map<id,SL_Mass_Implementation__c>([Select targetObjectParentFieldName__c, targetObjectName__c, Id, Name, Get_Element_from_List_Tab__c, Lookup_Title_Get_List_Page__c From SL_Mass_Implementation__c where id in :lstSelIDs]);
	        	
	        	
	        	for(ID item:lstSelIDs)
	        	{
                    System.Debug('ID: ' + item);
	        		SObject addCurCLObj = Schema.getGlobalDescribe().get(mapGetListImpl.get(item).targetObjectName__c).newSObject();
	        		this.lstLineGetLists.add(new LineGetListWrapper(item,mapGetListImpl.get(item).Get_Element_from_List_Tab__c,mapGetListImpl.get(item).targetObjectParentFieldName__c,addCurCLObj,mapGetListImpl.get(item).Lookup_Title_Get_List_Page__c));
	        	}
	        	//LineGetListWrapper(ID inImplID, String inLTitle, String inTargetObjectParentFieldName, SObject inAddCLObj)
	        }
		}
		return this.lstLineGetLists;
    }
    
    
    public String getFiltersJSON()
    {
    	String result = '[]';
    	
        Id currentUserId = UserInfo.getUserId();
        Id selectedTabId = null;
		if ((this.target != null) && (this.target != 'Main'))
        {
            try{selectedTabId = this.target;}
            catch(Exception e){}
        }
        if(selectedTabId==null)
        {
        	List<String> lstGetParams = this.target.split('_');
        	if(lstGetParams[0]=='Tab'){
        		try{selectedTabId = lstGetParams[1];}
            	catch(Exception e){}
        	}
        }
        
        try
        {
        	SL_LIB16_UserChoise__c choiceObject = null;
        	
	        for(SL_LIB16_UserChoise__c item:[SELECT Id,Serialized_Data__c,Filter_Tab__c FROM SL_LIB16_UserChoise__c WHERE View__c=null AND (Type__c = 'Last') AND (Mass_Implementation__c = :currMainCusSettings.Id) AND Implementation_Type__c='Search' AND (User__c = :currentUserId) LIMIT 1])
	        {
				choiceObject = item;
	        }
	        	
			if (choiceObject==null)
			{
				for(SL_LIB16_UserChoise__c item:[SELECT Id,Serialized_Data__c,Filter_Tab__c FROM SL_LIB16_UserChoise__c WHERE View__c=null AND (Type__c = 'Default') AND (Mass_Implementation__c = :currMainCusSettings.Id) AND Implementation_Type__c='Search' AND (User__c = :currentUserId) LIMIT 1])
				{
	        		choiceObject = item;
	        	}
			}
			
			if (choiceObject!=null)
			{
				system.debug('choiceObject >>>>>>>>>>>>>>>>>>>>>'+choiceObject);
				Map<String, String> mappedData = (Map<String, String>)Json.deserialize(choiceObject.Serialized_Data__c, Map<String, String>.class);
				this.SearchQ = mappedData.get('SearchQ');

				List<String> strArr = SearchQ.split('##');
				result = '';
				for (String item: strArr) {
					List<String> valArr = item.split('___');
					if(valArr.size()>1)
					{
                        String str = ', { name: "' + valArr[1] + '", operator: "' + valArr[2] +'", value: "' + ((valArr.size()>3 && valArr[3]!=null)?valArr[3]:'') +'"';
                        if(valArr.size()>4 && valArr[4]!=null){
                            str += ', intvalue: "' + valArr[4] + '"';
                        }
                        str+=+ '}';
						result += str;
					}
				}
				if (result.length()>0) result = result.substring(1);
				result = '[' + result + ']';
				this.cb_advFilters = mappedData.get('SearchParam');
				this.cb_target = choiceObject.Filter_Tab__c;
				if (this.cb_target == null) {
					this.cb_target = 'Main';
					this.SearchObj = 'Search_'+currMainCusSettings.Id;
				}
				else
				{
					this.SearchObj = 'Tab_'+cb_target;
				}
				
			}
			
        } catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        	
    	return result;
    }
    
    
    public SL_Mass_Implementation__c getCurrMainCusSettings() {
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
                                Row_Qty_Values__c,
                                Use_Step2_Multi_Add_Form__c,
                                Using_Exists_Impl__c, 
                                Name,
                                Id,
                                Get_Element_from_List_Tab__c
                            From SL_Mass_Implementation__c
                            where Id=:implementationId
                            limit 1];
                            
                    SL_LIB16_ctrl_CompanyListSearch.MainObjName = item.name;
                    SL_LIB16_ctrl_CompanyListSearch.MainObjNameID = item.ID;
                    
                    currMainCusSettings = item;
                    
                } catch(Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Incorrect Implementation or problem with custom settings!'));
                }
                
            } 
        }
        return currMainCusSettings;
    }
    

    /******************************* for Views *******************************/
    public void btnGo()
    {
        isNewView = false;
        loadViews(strColumnsAndFiltersTemplate, true);
        
        SL_LIB16_UserChoise__c choiceObject = null;
			
		for(SL_LIB16_UserChoise__c itemUC :[SELECT Id, View__c, User__c FROM SL_LIB16_UserChoise__c WHERE View__c!=null AND (Type__c = 'Last') AND Implementation_Type__c = 'Search' AND 
	        												(Mass_Implementation__c = :currMainCusSettings.ID) AND (User__c = :UserInfo.getUserId()) LIMIT 1])
		{
			choiceObject = itemUC;
	       	choiceObject.View__c = this.curViewID;
	    }
			
		if(choiceObject == null)
		{
			choiceObject = new SL_LIB16_UserChoise__c(
					Filter_Tab__c = null,
					Type__c = 'Last',
					Mass_Implementation__c = currMainCusSettings.ID,
					Implementation_Type__c = 'Search',
					View__c = this.curViewID,
					User__c = UserInfo.getUserId()
				);
		}
		if(this.curViewID!=null){ upsert choiceObject;}
		else if(choiceObject.Id!=null){ delete choiceObject;}


		doSearch();
    }
    public void fetchTemplateColumnAndFilterConditions()
    {
        strView = strColumnsAndFiltersTemplate;
        
        for(SL_View__c item:[Select Name, Id, Visibility__c From SL_View__c where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Search' and IsDefault__c=false and (User__c=:UserInfo.getUserId() or Visibility__c='Public') and Name=:strView])
        {
        	fldViewVisibility = item.Visibility__c==null?'Public':item.Visibility__c;
        }
        
    }
    public void deleteTemplateByname()
    {
        SL_View__c item2Delete = null;
        if(currMainCusSettings!=null)
        {
            for(SL_View__c item:[Select ID From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Search' and Name =:strColumnsAndFiltersTemplate and IsDefault__c=false and (User__c=:UserInfo.getUserId() or Visibility__c='Public') limit 1])
            {
                item2Delete = item;
            }
        }
        if(item2Delete!=null)
        {
			SL_LIB16_UserChoise__c choiceObjectItem = null;

			for(SL_LIB16_UserChoise__c itemUC :[SELECT Id FROM SL_LIB16_UserChoise__c WHERE View__c=:item2Delete.ID AND (Type__c = 'Last') AND Implementation_Type__c = 'Search' AND 
	        												(Mass_Implementation__c = :currMainCusSettings.ID) AND (User__c = :UserInfo.getUserId()) LIMIT 1])
			{
				choiceObjectItem = itemUC;
	    	}
        	if(choiceObjectItem!=null) delete choiceObjectItem;
        	
        	delete item2Delete;
        }
        this.curViewID = null;
        btnGo();
    }
    public void lnkCreateNewView()
    {
        strView = strColumnsAndFiltersTemplate;
        isNewView = true;
        strColumnsAndFiltersTemplate = '';
        fldViewVisibility = 'Public';
    }
    public void saveSelectedColumns()
    {
        
        String colSaveVal = '';
        strView = '';
        if(selectedColumnsCallback!=null && selectedColumnsCallback!='')
        {
            map<string,string> mapFldName2FldLabel = new map<string,string>();
            for(SL_LIB16_MassEdit.ColumnInfo item:columns){ mapFldName2FldLabel.put(item.name.toLowerCase(),item.label);}
            
            for(String item:selectedColumnsCallback.split(';'))
            {
                if(item!='' && mapFldName2FldLabel.containsKey(item)){ colSaveVal += ','+mapFldName2FldLabel.get(item);}
            }
        }
        if(colSaveVal!=''){ colSaveVal = colSaveVal.substring(1);}

        //Boolean isNoExceptionThrown = false;
        Boolean isNoExceptionThrown = true;
        if(currMainCusSettings!=null)
        {
            SL_View__c viewItem2Insert = new SL_View__c(Name=strColumnsAndFiltersTemplate, RowsCount__c=20, Implementation__c=currMainCusSettings.ID, Implementation_Type__c='Search', User__c=UserInfo.getUserId(), IsDefault__c=false);
            for(SL_View__c item:[Select RowsCount__c, Name, ID, Columns__c From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Search' and Name =:strColumnsAndFiltersTemplate and IsDefault__c=false and (User__c=:UserInfo.getUserId() or Visibility__c='Public') limit 1])
            {
                viewItem2Insert = item;
            }
            viewItem2Insert.Columns__c = colSaveVal;
            viewItem2Insert.Visibility__c = fldViewVisibility;
            try {
                upsert viewItem2Insert;

                this.curViewID = viewItem2Insert.ID;
            } catch(Exception ex) {
                //isExceptionThrown = true;
                isNoExceptionThrown = false;

//                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,ex.getMessage());
//                ApexPages.addMessage(myMsg);
                ApexPages.addMessages(ex);
            }
        }

        //if(!isExceptionThrown)
        if(isNoExceptionThrown){ btnGo();}
        //strColumnsAndFiltersTemplate
    }
    public void dummyFunction(){}
    public List<SelectOption> getUnselectedColumns()
    {
        List<SelectOption> res = new List<SelectOption>();
        set<String> setLabel = new set<string>();
        
        if(currMainCusSettings!=null)
        {
            for(SL_View__c template:[Select RowsCount__c, Name, ID, Columns__c From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Search' and IsDefault__c=false and Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or Visibility__c='Public') limit 1])
            {
                if(template.Columns__c != null && template.Columns__c !='')
                {
                    setLabel.addAll(( template.Columns__c.replace('*',' ')).split(','));
                }
            }
        }
        //system.debug('UnselectedColumnsOrdered setLabel >>>>>>>>>>>>>> '+setLabel);
        //system.debug('columns >>>>>>>>>>>>>> '+columns);

        Set<String> setAlredyAdd = new Set<String>();
        if(columns!=null)
        {
            for (SL_LIB16_MassEdit.ColumnInfo info : columns)
            {
                //system.debug('columns item: >>>>>>>>>>>>>> '+info);
                if (!setLabel.contains(info.label) && info.name!= null && info.label !=null && info.name!='' && !setAlredyAdd.contains(info.name.toLowerCase())) 
                {
                    res.add(new SelectOption(info.name, info.label));
                    setAlredyAdd.add(info.name.toLowerCase());
                }
            }
        }
        if(res == Null){ res.add(new SelectOption('', ''));}
        return res;
    }
    
    public List<SelectOption> getSelectColumnsOrdered()
    {
        List<SelectOption> res = new List<SelectOption>();
        List<String> setLabel = new List<string>();
        map<String,String> mapMassEditLabel2Name = new map<String,String>();
        if(currMainCusSettings!=null)
        {
        for(SL_View__c template:[Select RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Search' and IsDefault__c=false and Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or Visibility__c='Public') limit 1])
        {
            if(template.Columns__c != null && template.Columns__c !='')
            {
                setLabel.addAll(( template.Columns__c.replace('*',' ')).split(','));
            }
        }
        }
        //system.debug('SelectColumnsOrdered setLabel >>>>>>>>>>>>>> '+setLabel);
        if(columns!=null)
        {
            for (SL_LIB16_MassEdit.ColumnInfo item : columns){ mapMassEditLabel2Name.put(item.label, item.name);}
        }
        Set<String> setAlredyAdd = new Set<String>();
        for (String item : setLabel)
        {
            if(item!=null && item!='' && mapMassEditLabel2Name.containsKey(item) && mapMassEditLabel2Name.get(item)!=null 
                    && mapMassEditLabel2Name.get(item)!='' && !setAlredyAdd.contains(mapMassEditLabel2Name.get(item).toLowerCase()))
            {
                res.add(new SelectOption(mapMassEditLabel2Name.get(item), item)); //if (info.show)
                setAlredyAdd.add(mapMassEditLabel2Name.get(item).toLowerCase());
            }
        }
        
        
        /*
        Set<String> setAlredyAdd = new Set<String>();
        for (SL_LIB16_MassEdit.ColumnInfo info : columns)
        {
            if(setLabel.contains(info.label) && info.name!= null && info.label !=null && info.name!='' && !setAlredyAdd.contains(info.name.toLowerCase())) 
            {
                res.add(new SelectOption(info.name, info.label)); //if (info.show)
                setAlredyAdd.add(info.name.toLowerCase());
            }
        }
        */
        
        return res;
    }
    
    public String getJSONResponseTemp() {
        
        String retVal = '';
        
        Id tabId = null;
        if ((this.target != null) && (this.target != 'Main'))
        {
            try{tabId = this.target;}
            catch(Exception e){}
        }
        
        List<SL_Filter_Field__c> filterFieldsList = new List<SL_Filter_Field__c>();
        
        if(this.currMainCusSettings!=null)
        {
            SL_Mass_Implementation__c filterObject = [SELECT Id, (SELECT Id,Name,API_Name__c,API_Type__c,Parent_Ref_Field__c,SF_Object__c FROM Filter_Fields__r WHERE (Filter_Tab__c=:tabId and ((Filter_Tab__c!=null or Type__c='Search'))) ORDER BY Order__c) FROM SL_Mass_Implementation__c WHERE Id=:this.currMainCusSettings.Id LIMIT 1];
            if(filterObject!=null && filterObject.Filter_Fields__r!=null){ filterFieldsList = filterObject.Filter_Fields__r;}
        }
        
        String fieldName;
        for (SL_Filter_Field__c item: filterFieldsList) {
            fieldName = item.API_Name__c;
            if (item.Parent_Ref_Field__c != null) {
                
                String patentObjName = item.Parent_Ref_Field__c;
                
                if (patentObjName.substring(patentObjName.length() - 3, patentObjName.length()) == '__c') {
                    patentObjName = patentObjName.substring(0, patentObjName.length() - 1) + 'r';
                } else if (patentObjName.substring(patentObjName.length() - 2, patentObjName.length()) == 'Id') {
                    patentObjName = patentObjName.substring(0, patentObjName.length() - 2);
                }
                
                fieldName = patentObjName + '.' + fieldName;
            }
            
            if(item.API_Name__c.toLowerCase()=='recordtypeid'){ item.API_Type__c = 'PICKLIST';}
            
            retVal += ', '+ '{"name" : "' + item.Name + '", "value" : "' + fieldName + '", "type" : "' + item.API_Type__c;
            
            if (item.API_Type__c == 'REFERENCE') {
                
                Schema.Sobjecttype refType = Schema.getGlobalDescribe().get(item.SF_Object__c);
                Map<String, Schema.SObjectField> fieldMap = refType.getDescribe().fields.getMap();
                List<Schema.SObjectType> typesList = fieldMap.get(item.API_Name__c).getDescribe().getReferenceTo();
                if (typesList.size() > 1) {
                    refType = Schema.getGlobalDescribe().get('User');
                } else {
                    refType = Schema.getGlobalDescribe().get(String.valueOf(typesList.get(0)));
                }
                String keyPref = refType.getDescribe().getKeyPrefix();
                retVal += '", "prefix" : "' + keyPref;
            }
            
            retVal += '"}';
            
        }
        
        return '{"fields" : ['+(retVal!=''?retVal.substring(2):'')+']}';
        
    }
    
    public String getJSONResponse2()
    {
        String retVal = '';
        
        //SL_LIB16_ME_DescribeObject_Core m_describe_object_core_user = new SL_LIB16_ME_DescribeObject_Core('user');
        SL_LIB16_ME_DescribeObject_Core m_describe_object_core_user = new SL_LIB16_ME_DescribeObject_Core();
        Map<String, Schema.DescribeFieldResult> describe_result_Sub = m_describe_object_core_user.getDecribedFieldsByObject('user');
        //System.debug('m_describe_object_core_user>>>>>>>>>>>>>> '+m_describe_object_core_user);
        
        if(TargetObject!=null)
        {
            Map<String, Schema.DescribeFieldResult> describe_result = m_describe_object_core.getDecribedFieldsByObject(TargetObject.toLowerCase());
            
            List<String> lstsortVals = new List<String>();
            lstsortVals.addAll(describe_result.keySet());
            lstsortVals.sort();
            for(String item:lstsortVals)
            {
                retVal += ', '+ '{"name" : "'+describe_result.get(item).getLabel().escapeHtml3()+'", "value" : "'+item+'", "type" : "'+describe_result.get(item).getType().name()+'"}';
                if(item == 'ownerid')
                {
                    
                    List<String> lstsortValsSub = new List<String>();
                    lstsortValsSub.addAll(describe_result_Sub.keySet());
                    lstsortValsSub.sort();
                    for(String itemSub:lstsortValsSub)
                    {
                        retVal += ', '+ '{"name" : "Owner: '+describe_result_Sub.get(itemSub).getLabel().escapeHtml3()+'", "value" : "Owner.'+itemSub+'", "type" : "'+describe_result_Sub.get(itemSub).getType().name()+'"}';
                    }
                }
            }
        }
        return '{"fields" : ['+(retVal!=''?retVal.substring(2):'')+']}';
        
    }

    public void setMCompanies(List<CompanyExtend> inList){ this.m_companies = inList;}
    public String CompanyListID{ get { return System.currentPageReference().getParameters().get('clid');}}
    
    public String implementationId {
        get
        {
			//extId
    		String retVal = null;
    		if(System.currentPageReference().getParameters().get('implId')!=null && System.currentPageReference().getParameters().get('implId')!='')
    		{
    			retVal = System.currentPageReference().getParameters().get('implId');
    		}
    		else if(System.currentPageReference().getParameters().get('extId')!=null && System.currentPageReference().getParameters().get('extId')!='')
    		{
    			try
    			{
    				Decimal inExtID = Decimal.valueOf(System.currentPageReference().getParameters().get('extId'));
    				for(SL_Mass_Implementation__c item:[select ID from SL_Mass_Implementation__c where ExtID__c=:inExtID limit 1])
    				{
    					retVal = item.ID;
    				}
    			}
    			catch(Exception ex){}
    		}
    		
    		return retVal;
    	}
    }

    private void refreshSelIDs()
    {
        if(m_companies!=null && m_companies.size()>0)
        {
            for(CompanyExtend awObj:m_companies)
            {
                if(awObj.Item!=null)
                {
                    if(awObj.checked){curSelIDsSet.add(awObj.Item.ID);}
                    else curSelIDsSet.remove(awObj.Item.ID);
                }
            }
        }
    }
    

    SObject m_company_list = null;
    public SObject CompanyList {
        get {
            if(!isNullOrEmpty(CompanyListID) && currMainCusSettings!=null && currMainCusSettings.parentObjectName__c!=null) {
                if(m_company_list == null || CompanyListID != m_company_list.Id)
                {
                    String qTxt = 'SELECT Id, Name FROM '+currMainCusSettings.parentObjectName__c+' WHERE Id = \''+CompanyListID+'\''; 
                    for(SObject item: Database.query(qTxt)){ m_company_list = item;}
                }
            }
            return m_company_list;
        }
    }
    
    public String getCurCompanyListName(){ return CompanyList==null?null:''+CompanyList.get('Name');}


    /* Sorting */
    protected String m_sort_direction = 'ASC'; 
    protected String m_sort_expresion = 'Name';
    public String sortExpression {
        get { 
            return m_sort_expresion;
        }
        set {
            /*if the column is clicked on then switch between Ascending and Descending modes*/
            if (value == m_sort_expresion) {
                m_sort_direction = (m_sort_direction == 'ASC')? 'DESC' : 'ASC';
            } else { 
                m_sort_direction = 'ASC';
            }
            m_sort_expresion = value;
        }
    }
    
    
    public String getSortDirection()
    {
        /*if not column is selected */
        if (m_sort_expresion == null || m_sort_expresion == '') return 'ASC';
        else return m_sort_direction;
    }

    public void setSortDirection(String value)
    {  
        m_sort_expresion = value;
    }
    
    
    /* instantiate the StandardSetController from a query locator*/
    public ApexPages.StandardSetController m_std_controller {get; set;}
     
   /* returns a list of wrapper objects for the sObjects in the current page set*/
    public List<CompanyExtend> getItems() {
        m_companies = new List<CompanyExtend>();
        if(m_std_controller!=null) {
            for (SObject company : (List<SObject>)m_std_controller.getRecords())
            {
                m_companies.add(new CompanyExtend(company, curSelIDsSet.contains(company.ID)));
            }
        }
        return m_companies;
    }
     
    /* displays the selected items */
    public PageReference process() {
        for (CompanyExtend company : m_companies) {
            if (company.checked)
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, ''+company.Item.get('Name')));
        }
        return null;
    }
    
    /*Pager*/ 
    /* indicates whether there are more records after the current page set. */
    public Boolean hasNext {
        get {
            if(m_std_controller==null) return false;
            return m_std_controller.getHasNext();
        }
    }
     
    /* indicates whether there are more records before the current page set. */
    public Boolean hasPrevious {
        get {
            if(m_std_controller==null) return false;
                return m_std_controller.getHasPrevious();
            }
        }
     
    /* returns the page number of the current page set */
    public Integer pageNumber {
        get {
            if(m_std_controller==null) return null;
            return m_std_controller.getPageNumber();
        }
    }

    public Integer pageSize {
        get {
            if(m_std_controller==null) return 0;
            Integer prefix =  (Math.mod((Long)m_std_controller.getResultSize(),(Long)m_std_controller.getPageSize()) != 0)? 1 : 0;
            return  (m_std_controller.getResultSize() / m_std_controller.getPageSize())+prefix;
        }
    }

    public void goCurPageNumber()
    {
        if(m_std_controller!=null)
        {
            if(this.curPageNumber == null) this.curPageNumber = 0;
            refreshSelIDs();
            if(this.curPageNumber<1) this.curPageNumber=1;
            else if(this.curPageNumber>pageSize) this.curPageNumber=pageSize;

            m_std_controller.setpageNumber(this.curPageNumber);
        }
    }

    public void doSavePageSize()
    {
        if(m_std_controller!=null)
        {
            refreshSelIDs();
            m_std_controller.setPageSize(this.curPageSize);
            m_std_controller.first();
            
            SL_View__c curViewItem = null;
            for(SL_View__c item:[Select RowsCount__c, ID From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Search' and Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or IsDefault__c=true or Visibility__c='Public') limit 1])
            {
                curViewItem = item;
            }
            if(curViewItem!=null)
            {
                curViewItem.RowsCount__c = this.curPageSize;
                update curViewItem;
            }
        }
    }

    /* returns the first page of records */
    public void first()
    {
        if(m_std_controller!=null)
        {
            refreshSelIDs();
            m_std_controller.first();
        }
    }
     
    /* returns the last page of records */
    public void last()
    {
        if(m_std_controller!=null)
        {
            refreshSelIDs();
            m_std_controller.last();
        }
    }
     
    /* returns the previous page of records */
    public void previous() {
        if(m_std_controller!=null)
        {
            refreshSelIDs();
            m_std_controller.previous();
        }
    }
     
    /* returns the next page of records */
    public void next() {
        if(m_std_controller!=null)
        {
            refreshSelIDs();
            m_std_controller.next();
        }
    }
     
    /* returns the PageReference of the original page, if known, or the home page. */
    public void cancel() {
            if(m_std_controller!=null)
            {
                if(curSelIDsSet!=null) curSelIDsSet.clear();
                m_std_controller.cancel();
            }
    }   
    
    /* add to this Company List */
    public PageReference doAdd()
    {
        refreshSelIDs();
        if(currMainCusSettings!=null && curSelIDsSet!=null && curSelIDsSet.size()>0)
        {
            List<SObject> list2Insert = new List<SObject>();
            SObject tmpSObj = null;
            for(ID itemID:curSelIDsSet)
            {
                tmpSObj = Schema.getGlobalDescribe().get(currMainCusSettings.targetObjectName__c).newSObject();
                tmpSObj.put(currMainCusSettings.targetObjectSearchFieldName__c, itemID);
                tmpSObj.put(currMainCusSettings.targetObjectParentFieldName__c, CompanyList.ID);
                list2Insert.add(tmpSObj);
            }
            if(list2Insert.size()>0)
            {
            	HL_ConstantsUtil.AllowExecutionForManualInsertEngCounterparty = false ;
            	Database.insert(list2Insert,false);
            	HL_ConstantsUtil.AllowExecutionForManualInsertEngCounterparty = true;
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,'Selected records were added successfully'));
            }
            curSelIDsSet.clear();
        }

        PageReference pageRef = new PageReference('/' + CompanyListID);   
        pageRef.setRedirect(true);   
        return pageRef;         
    }
    
    public PageReference doAddContinue() {
        csvContentFile = null;
        
        system.debug('doAddContinue>>>>>>>>>>');
        if(currMainCusSettings.Use_Step2_Multi_Add_Form__c)
        {
            isShowStep2 = true;
        	system.debug('currMainCusSettings.Use_Step2_Multi_Add_Form__c >>>>>>>>>>'+ currMainCusSettings.Use_Step2_Multi_Add_Form__c);    
            
            
            refreshSelIDs();
        	if(currMainCusSettings!=null && curSelIDsSet!=null && curSelIDsSet.size()>0)
        	{
            	lstMemberItems = new List<SObject>();
            	SObject tmpSObj = null;
	            for(ID itemID:curSelIDsSet)
	            {
	                tmpSObj = Schema.getGlobalDescribe().get(currMainCusSettings.targetObjectName__c).newSObject();
	                tmpSObj.put(currMainCusSettings.targetObjectSearchFieldName__c, itemID);
	                tmpSObj.put(currMainCusSettings.targetObjectParentFieldName__c, CompanyList.ID);
	                lstMemberItems.add(tmpSObj);
	            }
        	}
            
        }
        else
        {
            doAdd();
            doSearch();
        }
        
        return null;
    }
    
    public List<SL_LIB16_MassEdit.ColumnInfo> getColumnsShown()
    {
        List<SL_LIB16_MassEdit.ColumnInfo> columnsStep2 = new List<SL_LIB16_MassEdit.ColumnInfo>();
        SL_LIB16_MassEdit.ColumnInfo curItem = null;
		for(Mass_Edit_Settings__c item : [SELECT Field__c, Sort_Field__c, Label__c, IsSortable__c, isEditable__c, Field_Style__c FROM Mass_Edit_Settings__c where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' ORDER BY Label__c])
		{
	    	curItem = new SL_LIB16_MassEdit.ColumnInfo(item.Field__c.toLowerCase(), item.Sort_Field__c.toLowerCase(), item.Label__c, true, true, item.IsSortable__c, item.isEditable__c, item.Field_Style__c);
	    	if(curItem.isEditable && item.Field__c.indexOf('.')==-1){ columnsStep2.add(curItem);}
		}
        
        List<SL_LIB16_MassEdit.ColumnInfo> res = new List<SL_LIB16_MassEdit.ColumnInfo>();
        Map<String,SL_LIB16_MassEdit.ColumnInfo> mapColumnsShown = new Map<String,SL_LIB16_MassEdit.ColumnInfo>();
        List<String> setLabel = new List<string>();
        for (SL_LIB16_MassEdit.ColumnInfo info : columnsStep2)
        {
            if (info.show){ mapColumnsShown.put(info.label,info);}
        }
        for(SL_View__c template:[Select Columns__c From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='AddPage' limit 1])
        {
            if(template.Columns__c != null && template.Columns__c !='')
            {
                setLabel.addAll(( template.Columns__c.replace('*',' ')).split(','));
            }
        }

        for (String item : setLabel)
        {
            if (item!=null && item!='' && mapColumnsShown.containsKey(item)) 
            {
                res.add(mapColumnsShown.get(item));
            }
        }
        
        return res;
    }
    
    public PageReference doSaveStep2()
    {
		if(lstMemberItems!=null && lstMemberItems.size()>0){ Database.insert(lstMemberItems,false);}
         
		PageReference pageRef = new PageReference('/' + CompanyListID);   
        pageRef.setRedirect(true);   
        return pageRef;
    }


    public PageReference doSaveAndMoreStep2()
    {
        if(lstMemberItems!=null && lstMemberItems.size()>0)
        {
        	Database.insert(lstMemberItems,false);
	        curSelIDsSet.clear();
	        lstMemberItems.clear();
        }

        isShowStep2 = false;
        doSearch();
        return null;
    }


    public PageReference doCancelStep2()
    {
		/*
		PageReference pageRef = new PageReference('/' + CompanyListID);   
        pageRef.setRedirect(true);   
        return pageRef;
        */
        if(lstMemberItems!=null && lstMemberItems.size()>0)
        {
	        curSelIDsSet.clear();
	        lstMemberItems.clear();
        }

		isShowStep2 = false;
        doSearch();
        return null;
    }
    
    
    public PageReference clSearch()
    {
        hasSearched = true;
        m_companies = new List<CompanyExtend>();
        m_std_controller = null;
        
        csvContentFile = null;
        return null;
    }
    
    public List<Mass_Edit_Settings__c> aSearchColumns
    {
        get
        {
            Map<String, Mass_Edit_Settings__c> aColumns = new Map<String, Mass_Edit_Settings__c>();
            List<Mass_Edit_Settings__c> aResult = new List<Mass_Edit_Settings__c>();
            
            //System.debug('currMainCusSettings.searchObjectName__c >>>>>>>>>>>>>>>>>>>>>>>>> '+currMainCusSettings.searchObjectName__c);
            
            if(currMainCusSettings!=null)
            {
                for(Mass_Edit_Settings__c item : [SELECT Field__c, Label__c, Name, ID, IsSortable__c, Field_Style__c FROM Mass_Edit_Settings__c where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Search'])
                {
                    aColumns.put(item.Label__c, item);
                }
            }
            /*
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, objName + '( ' + relName + ' ) -> ' + fieldName));
            */
            
            if(currTplColumns!=null && currTplColumns!='')
            {
                //System.debug('currTplColumns >>>>>>>>>>>>>>>>>>>>>>>>> '+currTplColumns);
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ''+currTplColumns));
                List<String> lstString = new List<String>();
                lstString.addAll(currTplColumns.split(','));
                for(String objString:lstString)
                {
                    if(aColumns.containsKey(objString) && aColumns.get(objString)!=null) aResult.add(aColumns.get(objString));
                }
            }
            return aResult;
        }
    }

    private void saveUserChoice(String SearchQ, String SearchParam, String TargetObject)
    {
        Id currentUserId = UserInfo.getUserId();
        Id selectedTabId = null;

 		if(this.SearchObj!=null && this.SearchObj!='')
        {
        	List<String> lstGetParams = this.SearchObj.split('_');
        	if(lstGetParams[0]=='Tab'){
        		try{selectedTabId = lstGetParams[1];}
            	catch(Exception e){}
        	}
        }

        try
        {
        	SL_LIB16_UserChoise__c choiceObject = null;

	        for(SL_LIB16_UserChoise__c item :[SELECT Id, Filter_Tab__c FROM SL_LIB16_UserChoise__c WHERE View__c=null AND (Type__c = 'Last') AND Implementation_Type__c = 'Search' AND 
	        												(Mass_Implementation__c = :currMainCusSettings.Id) AND (User__c = :currentUserId) LIMIT 1])
			{
				choiceObject = item;
	       		choiceObject.Filter_Tab__c = selectedTabId;
			}

			if (choiceObject==null)
			{
				choiceObject = new SL_LIB16_UserChoise__c(
					Filter_Tab__c = selectedTabId,
					Type__c = 'Last',
					Implementation_Type__c = 'Search',
					Mass_Implementation__c = currMainCusSettings.Id,
					View__c = null,
					User__c = currentUserId
				);
			}
			
			Map<String, String> arrayData = new Map<String, String> {
				'SearchQ' => SearchQ,
				'SearchParam' => SearchParam,
				'TargetObject' => TargetObject
			};
			
			choiceObject.Serialized_Data__c = JSON.serialize(arrayData);
			
			upsert choiceObject;
	        
        } catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        	
    }
    
    public PageReference doSearch() {
            /*  Search block for Selected Deal in the bottom Lookup */
            /*  Search from Company List */
            m_companies = new List<CompanyExtend>();
            m_std_controller = null;
            
            /* System.debug('!!!!!!!!!!!!!!!!SearchSection: '+SearchSection); */
            /* System.debug('!!!!!!!!!!!!!!!!addCLObj: '+addCLObj); */
            //System.debug('currTplColumns >>>>>>>>>>>>>>>>>>>>>>>>> '+currTplColumns);
            //System.debug('strColumnsAndFiltersTemplate >>>>>>>>>>>>>>>>>>>>>>>>> '+strColumnsAndFiltersTemplate);
            String sNames = '';
            for ( Mass_Edit_Settings__c oItem : aSearchColumns ) {
                sNames += oItem.Field__c + ', ';
            }
            if ( sNames.length() > 0 ) {
                sNames = sNames.substring( 0, sNames.length() - 2 );
            } else {
                sNames = 'Name';
            }

			if(SearchSection!='F' && currMainCusSettings.searchObjectName__c!=null)
			{
				Map<id,SL_Mass_Implementation__c> mapGetListImpl = new Map<id,SL_Mass_Implementation__c>([Select targetObjectParentFieldName__c, targetObjectName__c, Id, Name, Get_Element_from_List_Tab__c,
																					searchObjectName__c,targetObjectSearchFieldName__c  From SL_Mass_Implementation__c where searchObjectName__c = :currMainCusSettings.searchObjectName__c]);
				
				addCLObj = null;
				hasSearched = true;
                string sortFullExp = m_sort_expresion  + ' ' + m_sort_direction;
                
				for(LineGetListWrapper item:getLineGetLists())
                {
                	if(''+item.ImplID == SearchSection){ addCLObj = item.addCLObj;}
                }
                
                if(addCLObj!=null)
                {
	                String SQLTxt;
	                
	                SQLTxt = 'Select ' + sNames + ' From '+mapGetListImpl.get(SearchSection).searchObjectName__c+' '
	                + 'where id in (Select c.'+mapGetListImpl.get(SearchSection).targetObjectSearchFieldName__c+' From '+mapGetListImpl.get(SearchSection).targetObjectName__c+' c where c.'+mapGetListImpl.get(SearchSection).targetObjectParentFieldName__c+'=\''+addCLObj.get(mapGetListImpl.get(SearchSection).targetObjectParentFieldName__c)+'\') '
	                + 'AND Id NOT IN (select '+currMainCusSettings.targetObjectSearchFieldName__c+' from '+currMainCusSettings.targetObjectName__c+' where '+currMainCusSettings.targetObjectParentFieldName__c+'=\''+CompanyList.ID+'\') '
	                + 'Order BY '+sortFullExp+' limit 9000';
	                
	                try {
						m_std_controller = new ApexPages.StandardSetController(Database.getQueryLocator(SQLTxt));
	                } catch(Exception e) {
	                    m_std_controller = null;
	                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Incorrect existing List!'));
	                }
                }
                else{ m_std_controller = null;}
			}
            /*  Search with Filter */
            else if(curSearchBlockParams.SearchQ!=null && curSearchBlockParams.SearchParam!=null && SearchSection == 'F')
            {
				this.SearchObj = curSearchBlockParams.SearchTarget;
				ID selectedTabId = null;
				
				List<String> lstGetParams = curSearchBlockParams.SearchTarget.split('_');
				Filter_Tab__c tabObject = null;
	        	
	        	
	        	if(lstGetParams[0]=='Tab'){
	        		
	        		try{selectedTabId = lstGetParams[1];}
	            	catch(Exception e){}

	            	if(selectedTabId!=null)
	            	{
	            		for(Filter_Tab__c item:[SELECT Id,Object_Name__c,Field_Name__c,isNotDirectReference__c FROM Filter_Tab__c WHERE Id=:selectedTabId]){ tabObject = item;}
	            	}
	        	}
				
				this.saveUserChoice(curSearchBlockParams.SearchQ, curSearchBlockParams.SearchParam, curSearchBlockParams.SearchObj);
				hasSearched = true;
                m_filters.Initialize(curSearchBlockParams.SearchQ, curSearchBlockParams.SearchParam, tabObject==null?currMainCusSettings.searchObjectName__c:tabObject.Object_Name__c);
                String MFilters_SOQL_VALUE = m_filters.SOQL;
                string sortFullExp = m_sort_expresion  + ' ' + m_sort_direction;
                String addWhere = '';
                
                //trace = '{"SearchQ": "' + curSearchBlockParams.SearchQ + '", "TargetObject": "' + curSearchBlockParams.SearchTarget + '", \n "SearchParam" :"' + curSearchBlockParams.SearchParam + '", \n"filter": "( ' + MFilters_SOQL_VALUE + ')"}';
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'trace: '+trace));
                /* trace = m_filters.trace; */
                //***** system.debug('-----------------------------------{"SearchQ": "' + SearchQ + '", \n "SearchParam" :"' + SearchParam + '", \n"filter": "( ' + MFilters_SOQL_VALUE + ')"}');
                if(MFilters_SOQL_VALUE!=null && MFilters_SOQL_VALUE!='') addWhere = ' '+MFilters_SOQL_VALUE;
                
                /****** START Search BLOCK-1: When user choosed Deal Object  */ 
                /****** END Search BLOCK-1: When user choosed Deal Object  */

                String SQLTxt;
                ////system.debug('-----------------------------------SQLTxt: ' + SQLTxt);
                
                try {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'this.target'+this.target));
                    if (this.target == 'Main' && selectedTabId==null) {
                        
                        if (addWhere==''){ addWhere = ' WHERE Id NOT IN (select '+currMainCusSettings.targetObjectSearchFieldName__c+' from '+currMainCusSettings.targetObjectName__c+' where '+currMainCusSettings.targetObjectParentFieldName__c+'=\''+CompanyList.ID+'\')'; }
                        else
                        {
                            addWhere = ' WHERE (Id NOT IN (select '+currMainCusSettings.targetObjectSearchFieldName__c+' from '+currMainCusSettings.targetObjectName__c+' where '+currMainCusSettings.targetObjectParentFieldName__c+'=\''+CompanyList.ID+'\'))'
                                     + ' AND ('+addWhere+')';
                        }
                        SQLTxt = 'Select ' + sNames + ' From ' + currMainCusSettings.searchObjectName__c + ' ' + addWhere + ' Order BY ' + sortFullExp + ' limit 9000';
                        
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'query:: ' + SQLTxt));
                        m_std_controller = new ApexPages.StandardSetController(Database.getQueryLocator(SQLTxt));
                    } else {
                        m_std_controller = null;
                        
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'tabObject:: ' + tabObject));
                        if(tabObject!=null)
                        {
                            if (addWhere=='')
                            {
                                addWhere = ' WHERE Id NOT IN (select '+currMainCusSettings.targetObjectSearchFieldName__c+' from '+currMainCusSettings.targetObjectName__c+' where '+currMainCusSettings.targetObjectParentFieldName__c+'=\''+CompanyList.ID+'\')';
                                SQLTxt = 'Select ' + sNames + ' From ' + currMainCusSettings.searchObjectName__c + ' ' + addWhere + ' Order BY ' + sortFullExp + ' limit 9000'; 
                            }
                            else
                            {
                                if(tabObject.isNotDirectReference__c)
                                {
	                                Set<ID> setSOIDs = new Set<ID>();
	                                ID curID;
	                                for(SObject item:Database.query('Select ' + tabObject.Field_Name__c + ' From ' + tabObject.Object_Name__c + ' where ' + addWhere + ' limit 9000'))
	                                {
	                                	curID = null;
	                                	try{curID = (ID)item.get(tabObject.Field_Name__c);}
	                                	catch(Exception ex){}
	                                	if(curID!=null){ setSOIDs.add(curID);}
	                                }
	                                if(setSOIDs.size()>0){ addWhere = ' WHERE Id IN :setSOIDs';}
	                                else{ addWhere = ' WHERE Id=null';}
									addWhere += ' AND Id NOT IN (select '+currMainCusSettings.targetObjectSearchFieldName__c+' from '+currMainCusSettings.targetObjectName__c+' where '+currMainCusSettings.targetObjectParentFieldName__c+'=\''+CompanyList.ID+'\')';
									SQLTxt = 'Select ' + sNames + ' From ' + currMainCusSettings.searchObjectName__c + ' ' + addWhere + ' Order BY ' + sortFullExp + ' limit 9000'; 
	                                
								}
								else
								{
									//addWhere = ' WHERE Id NOT IN (select '+currMainCusSettings.targetObjectSearchFieldName__c+' from '+currMainCusSettings.targetObjectName__c+' where '+currMainCusSettings.targetObjectParentFieldName__c+'=\''+CompanyList.ID+'\')';
									addWhere = ' WHERE Id IN (Select ' + tabObject.Field_Name__c + ' From ' + tabObject.Object_Name__c + ' where ' + addWhere + ')';
									addWhere += ' AND Id NOT IN (select '+currMainCusSettings.targetObjectSearchFieldName__c+' from '+currMainCusSettings.targetObjectName__c+' where '+currMainCusSettings.targetObjectParentFieldName__c+'=\''+CompanyList.ID+'\')';
									SQLTxt = 'Select ' + sNames + ' From ' + currMainCusSettings.searchObjectName__c + ' ' + addWhere + ' Order BY ' + sortFullExp + ' limit 9000'; 
								}
                            }
                            
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'query:: ' + SQLTxt));
                            m_std_controller = new ApexPages.StandardSetController(Database.getQueryLocator(SQLTxt));
                        }
                    }

                } catch(Exception e) {
                    m_std_controller = null;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: invalid search filter values or invalid Advanced filter.'+e));
                }
            }
			
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'strColumnsAndFiltersTemplate:: ' + strColumnsAndFiltersTemplate));
			
			/*  sets the number of records in each page set */
			if(m_std_controller!=null)
			{
				for(SL_View__c item:[Select ID,RowsCount__c From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Search' and Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or IsDefault__c=true or Visibility__c='Public') limit 1])
				{
					this.curPageSize = (Integer)item.RowsCount__c;
				}

				m_std_controller.setPageSize(this.curPageSize);
				m_std_controller.first();
			}

			return null;
        }   
    
        public PageReference doCancel()
        {
            PageReference pageRef; 
			String retUrl;			
            if(System.currentPageReference().getParameters().get('mt')=='1'){
                pageRef = new PageReference('/apex/SL_LIB16_MassEdit_ManageTargets?mt=1&clid='+CompanyListID+'&implId='+implementationId);
            } else {
                //For Counterparties Lists, we want to return back to the Mass Edit
                retUrl = HL_PageUtility.GetParameter('retURL');
                if(!String.isBlank(retUrl) && retUrl.contains('MassEdit_CompanyList'))
                    pageRef = new PageReference('/apex/SL_LIB16_MassEdit_CompanyListMember?clid=' + CompanyListID + '&extId=' + HL_PageUtility.GetParameter('extId'));
                else  			
					pageRef = new PageReference('/' + CompanyListID);   
            }
            pageRef.setRedirect(true);   
            return pageRef;
        }
    
        public PageReference doReset()
        {
            String urlVal = Apexpages.currentPage().getUrl();
            if(urlVal==null || urlVal==''){ return null;}
            if(urlVal.indexOf('?')!=-1){ urlVal = urlVal.substring(0,urlVal.indexOf('?'));}

            PageReference pageRef = new PageReference(urlVal+'?clid=' + CompanyListID);   
            pageRef.setRedirect(true);   
            return pageRef;
        }   
    
    /*  Sergey CODE */
    String m_trace = 'trace:: ';
    public String trace {
        get {
            return m_trace; 
        }
        set {
            m_trace += value + ' | \n' ;
        }
    }
    
    public String target {
        get{
            String retVal = System.currentPageReference().getParameters().get('target');
            if(retVal==null) retVal = this.SearchTarget;
            return retVal;     
        }
    }
    
    public String event {
        get{
            return System.currentPageReference().getParameters().get('event');      
        }
    }

    public String filterSet {
        get{
            return System.currentPageReference().getParameters().get('filters');        
        }
    }

    public String picklistName {
        get{
            return System.currentPageReference().getParameters().get('picklist');       
        }
    }
    
    public String JSONResponse {
        get;
        set; 
    } 
    
    public String TargetObject {
        get {return currMainCusSettings==null?null:currMainCusSettings.searchObjectName__c;}
    } 
    
    protected Boolean isNullOrEmpty(String p_str) {
        return (p_str == null || p_str == ''); 
    }

    public class LineGetListWrapper
    {
		public ID ImplID {get;set;}
		public String lTitle {get;set;}
		public String targetObjectParentFieldName {get;set;}
		public String Lookup_Title {get;set;}
		public SObject addCLObj { get; set; }
		
		public LineGetListWrapper(ID inImplID, String inLTitle, String inTargetObjectParentFieldName, SObject inAddCLObj, String inLookup_Title) {
            this.ImplID = inImplID;
            this.lTitle = inLTitle;
            this.addCLObj = inAddCLObj;
            this.Lookup_Title = inLookup_Title;
            this.targetObjectParentFieldName = inTargetObjectParentFieldName;
        }
		
    }	

    /* JSONObject class */
    public class JSONObject {
        public String  Name                 {get;set;}
        public String  Value                {get;set;}
        public String  FieldType            {get;set;} 
        public List<String> picklistValues  {get;set;}
        public String Prefix                {get;set;}
        
        public String Json {
            get{
                String result = '';
                result += jProperty('name', Value) + ', ';
                result += jProperty('value', Name) + ', ' ;
                result += jProperty('type', FieldType) ;
                if(Prefix != null && Prefix != '') {
                    result += ', ' + jProperty('prefix', Prefix) ;  
                }
                /*(if (FieldType == 'PICKLIST') {
                    result += ', ';
                    result += jProperty('picklistValues', picklistValues);
                }*/
                return '{' +  result + '}';             
            }
        }
         
        public JSONObject() {
            picklistValues = new List<String>();
        }
        
        public JSONObject(String p_name, String p_value, String p_type) {
            picklistValues = new List<String>();
            Name = p_name; Value = p_value; FieldType = p_type;
        }
        
        public JSONObject(String p_name, String p_value, String p_type, List<String> p_picklist_values) {
            Name = p_name; Value = p_value; FieldType = p_type;
            picklistValues = p_picklist_values;
        }
    
        public String jQ(String p_str) {
            return '"' + p_str + '"';
        }
        
        public String jProperty(String p_name, String p_value) {
            return jQ(p_name) + ' : ' + jQ(p_value);
        }

        public String jProperty(String p_name, List<String> p_value) {
            String result = '';
            for(Integer i = 0; i < p_value.size(); i++) {
                result += '{' + jProperty('value', p_value[i]) + '}';
                if(i != p_value.size()-1) {
                    result += ', ';
                }
            }
            return jQ(p_name) + ' : ' + '['+ result +']';
        }
    }
    
    public class CompanyExtend {
        public Boolean Checked{ get; set; }
        public SObject Item { get; set;}
        public Integer Index { get; set;}
        
 
        public CompanyExtend() {
            String sObjName4Create = null;
            if(SL_LIB16_ctrl_CompanyListSearch.MainObjNameID!=null)
            {
                for(SL_Mass_Implementation__c item:[select Id,searchObjectName__c from SL_Mass_Implementation__c where ID=:SL_LIB16_ctrl_CompanyListSearch.MainObjNameID limit 1])
                {
                    sObjName4Create = item.searchObjectName__c;
                }
            }
            if(sObjName4Create!=null)
            {
                Item = Schema.getGlobalDescribe().get(sObjName4Create).newSObject();
            }
            
            
            Checked = false;
        }
 
        public CompanyExtend(SObject p_company) {
            Item = p_company;
            Checked = false;
        }
        
        public CompanyExtend(SObject p_company, boolean inCheck) {
            Item = p_company;
            Checked = inCheck;
        }
        
        public CompanyExtend(SObject p_company, boolean inCheck, Integer inIndex) {
            Item = p_company;
            Checked = inCheck;
            Index = inIndex;
        }

        public SObject getCastedSObject(){
            return (SObject)Item;
        }
    }


    private boolean compareUserProfileWithSysAdmin() {
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String MyProflieName = PROFILE[0].Name;
        if(MyProflieName == 'System Administrator') return true;
        return false;
    }

    public boolean isShowEditDeleteProfile {get; set;}
    public PageReference ShowEditDeleteProfile() {
        isShowEditDeleteProfile = true;
        if(isUserSysAdmin == null) isUserSysAdmin = compareUserProfileWithSysAdmin();
        //strColumnsAndFiltersTemplate
        //strView = strColumnsAndFiltersTemplate;

        system.debug('#### strColumnsAndFiltersTemplate = '+strColumnsAndFiltersTemplate);

        if(strColumnsAndFiltersTemplate != null && strColumnsAndFiltersTemplate.length()>0)
        for(SL_View__c item:[Select Name, Id, Visibility__c From SL_View__c where (User__c=:UserInfo.getUserId() or IsDefault__c=true or Visibility__c='Public') and Name=:strColumnsAndFiltersTemplate])
        {
            String str_ViewVisibility = item.Visibility__c==null?'Public':item.Visibility__c;
            if(isUserSysAdmin || (!isUserSysAdmin && str_ViewVisibility != 'Public')) { 
                isShowEditDeleteProfile = true; 
                system.debug('#### isShowEditDeleteProfile new = '+isShowEditDeleteProfile);
                return null; 
            }
        }
        isShowEditDeleteProfile = false;
        system.debug('#### isShowEditDeleteProfile = '+isShowEditDeleteProfile);
        return null;
    }
    
}