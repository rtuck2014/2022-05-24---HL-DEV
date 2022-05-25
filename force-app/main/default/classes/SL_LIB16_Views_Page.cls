public with sharing class SL_LIB16_Views_Page
{
	public sObject originalSObject;
	public SL_View__c curRecordVal {get; set;}
	public String pageTitle {get; set;}
	public String inRecordName {get; set;}
	public String inRecordType {get; set;}
	public String inRecordRowsQty {get; set;}
	public Boolean isTypeSelected {get; set;}
	public String cb_advFilters {get; set;}
	
	public String inRecordFiltersCols {get; set;}
	public String inRecordFiltersAdv {get; set;}
	public String inRecordSelCols {get; set;}
	
	public String dateFormat {get{return SL_LIB16_DateObject.dateFormat;}set;}
    
	public List<SL_LIB16_MassEdit.ColumnInfo> columns = new List<SL_LIB16_MassEdit.ColumnInfo>();
	
	private ID curRecordID = null;
	public SL_LIB16_Views_Page()
    {
		init();
		curRecordID = System.currentPageReference().getParameters().get('id');
		
    }
    
	public SL_LIB16_Views_Page(ApexPages.StandardController stdController)
	{
        this.originalSObject = (sObject) stdController.getRecord();
        curRecordID =  this.originalSObject.ID;

        init();
	}
	
    public SL_LIB209_ctrl_SearchBlockParams getSearchCompParams()
    {
    	SL_LIB209_ctrl_SearchBlockParams retVal = new SL_LIB209_ctrl_SearchBlockParams();
    	retVal.tabs = new List<SelectOption>();
    	retVal.tabsObjName = new List<SelectOption>{new selectOption('Target_'+curRecordVal.Implementation__c,curRecordVal.Implementation__r.targetObjectName__c)};
    	retVal.mainSelTarget = 'Target_'+curRecordVal.Implementation__c;
    	retVal.locationBase = '/apex/SL_LIB16_MassEdit_JSON?m_impl='+curRecordVal.Implementation__c+'&evtmp=';
    	retVal.searchBtnClick = '';
    	retVal.FiltersJSON = this.getFiltersJSON();
    	retVal.cb_target = 'Main';
    	retVal.cb_advFilters = curRecordVal.Advanced_Filter__c;
    	retVal.dateFormat = SL_LIB16_DateObject.dateFormat;
    	
    	return retVal;
    }	
	
	public void init()
	{
		Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=9');

		isTypeSelected = false;
		pageTitle = 'New View';
		cb_advFilters = '';
		if(curRecordID==null && originalSObject!=null){ curRecordVal = (SL_View__c)originalSObject;}
		
		if(curRecordID!=null)
		{
			curRecordVal = [Select RowsCount__c, Name, Implementation__c, Implementation_Type__c, Implementation__r.targetObjectName__c, Id, Columns__c, Advanced_Filter__c,User__c,IsDefault__c, (Select Id, Name, Field__c, Operator__c, Type__c, Value__c From View_Filters__r)  From SL_View__c where id = :curRecordID limit 1];
		}
		
		if(curRecordID!=null && curRecordVal.Implementation_Type__c!=null)
		{
			isTypeSelected = true;
			if(curRecordVal.Implementation_Type__c=='Search'){ this.loadColumnData('Search');}
			else {this.loadColumnData('Target');}
		}
	}
	
    public Boolean getIsManageTargets(){
        return curRecordVal.Implementation_Type__c=='ManageTargets';
    }
    
	public Boolean getIsShowFilter()
	{
		if(curRecordVal!=null && (curRecordVal.Implementation_Type__c=='Target' || getIsManageTargets())) return true;
		return false;
	}
	
	private void loadColumnData(String inType)
	{
		columns = new List<SL_LIB16_MassEdit.ColumnInfo>();
       
        if(curRecordVal.Implementation_Type__c=='AddPage')
        {
        	SL_LIB16_MassEdit.ColumnInfo curItem = null;
        	for(Mass_Edit_Settings__c item : [SELECT Field__c, Sort_Field__c, Label__c, IsSortable__c, isEditable__c FROM Mass_Edit_Settings__c where Implementation__c=:curRecordVal.Implementation__c and Implementation_Type__c=:inType ORDER BY Label__c])
	        {
	            curItem = new SL_LIB16_MassEdit.ColumnInfo(item.Field__c.toLowerCase(), item.Sort_Field__c.toLowerCase(), item.Label__c, true,true, item.IsSortable__c, item.isEditable__c);
	            if(curItem.isEditable && item.Field__c.indexOf('.')==-1){ columns.add(curItem);}
			}
        }
        else
        {
	        for(Mass_Edit_Settings__c item : [SELECT Field__c, Sort_Field__c, Label__c, IsSortable__c, isEditable__c FROM Mass_Edit_Settings__c where Implementation__c=:curRecordVal.Implementation__c and Implementation_Type__c=:inType ORDER BY Label__c])
	        {
	            columns.add(new SL_LIB16_MassEdit.ColumnInfo(item.Field__c.toLowerCase(), item.Sort_Field__c.toLowerCase(), item.Label__c, true,true, item.IsSortable__c, item.isEditable__c));
			}
		}
	}
	
	public String getFiltersJSON()
    {
        String res = '';
        
        if(curRecordVal!=null && curRecordVal.ID!=null)
        {
	        for(SL_View_Filter__c objFiltersTemplate:[Select Id,Type__c,Field__c,Operator__c,Value__c,SL_View__c,SL_View__r.Advanced_Filter__c from SL_View_Filter__c where SL_View__c = :curRecordVal.ID])
	        {
	            res += ', { name: "' + objFiltersTemplate.Field__c + '", operator: "' + objFiltersTemplate.Operator__c + 
	                                      '", value: "' + (objFiltersTemplate.Value__c==null?'':objFiltersTemplate.Value__c) + '"}';
	            cb_advFilters = objFiltersTemplate.SL_View__r.Advanced_Filter__c;
	        }
		}
		
        if (res.length()>0) res = res.substring(1);
        return '[' + res + ']';
    }
	
	public List<SelectOption> getRowsQTYValues()
	{
		return SL_LIB16_MassEdit.getRowQtySelectOptList(this.getImplRecord(curRecordVal.Implementation__c));
	}
	
	public String getTargetObjectName()
	{
		String retVal = '';
		if(curRecordVal!=null && curRecordVal.Implementation__c!=null)
		{
			SL_Mass_Implementation__c curImpl = this.getImplRecord(curRecordVal.Implementation__c);
			if(curImpl!=null) retVal = curImpl.targetObjectName__c;
		}
		
		return retVal;
	}
	
	private SL_Mass_Implementation__c getImplRecord(ID implId)
	{
		return [Select targetObjectSearchFieldName__c,targetObjectParentFieldName__c,targetObjectName__c,searchObjectName__c,parentObjectName__c,Show_Views_on_MassEdit_Page__c,
						Show_Views_on_MassAdd_Page__c,Search_Page_Title__c,Search_Object_Title__c,Row_Qty_Values__c,Name,ID,Get_Element_from_List_Tab__c
					From SL_Mass_Implementation__c where Id = :implId limit 1];
	}
	
	public void chMainObject()
	{
		curRecordVal.Name = inRecordName;
		curRecordVal.Implementation_Type__c = inRecordType;
		try{ curRecordVal.RowsCount__c = Integer.valueOf(inRecordRowsQty);}
		catch(Exception ex){}
		
		columns = new List<SL_LIB16_MassEdit.ColumnInfo>();
		if(curRecordVal.Implementation_Type__c!=null)
		{
			isTypeSelected = true;
			if(curRecordVal.Implementation_Type__c=='Search'){ this.loadColumnData('Search');}
			else {this.loadColumnData('Target');}
		}
		else{ isTypeSelected = false;}
	}


	public List<SelectOption> getUnselectedColumns()
    {
        List<SelectOption> res = new List<SelectOption>();
        set<String> setLabel = new set<string>();
        
		if(curRecordVal!=null && curRecordVal.Columns__c != null && curRecordVal.Columns__c !='')
	    {
	    	setLabel.addAll(( curRecordVal.Columns__c.replace('*',' ')).split(','));
		}
        
        Set<String> setAlreadyAdd = new Set<String>();
        for (SL_LIB16_MassEdit.ColumnInfo info : columns)
        {
            if (!setLabel.contains(info.label) && info.name!= null && info.label !=null && info.name!='' && !setAlreadyAdd.contains(info.name.toLowerCase())) 
            {
                res.add(new SelectOption(info.name, info.label));
                setAlreadyAdd.add(info.name.toLowerCase());
            }
        }
        if(res == Null){ res.add(new SelectOption('', ''));}
        return res;
    }
    
    public List<SelectOption> getSelectColumns()
    {
        List<SelectOption> res = new List<SelectOption>();
        for (SL_LIB16_MassEdit.ColumnInfo info : columns){
            if (info.show) res.add(new SelectOption(info.name, info.label));
        }
        return res;
    }
    
    public List<SelectOption> getSelectColumnsOrdered()
    {
        List<SelectOption> res = new List<SelectOption>();
        List<String> setLabel = new List<string>();
        map<String,String> mapMassEditLabel2Name = new map<String,String>();
		
		if(curRecordVal!=null && curRecordVal.Columns__c != null && curRecordVal.Columns__c !='')
	    {
	    	setLabel.addAll(( curRecordVal.Columns__c.replace('*',' ')).split(','));
		}
        
        for (SL_LIB16_MassEdit.ColumnInfo item : columns){ mapMassEditLabel2Name.put(item.label, item.name);}
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
        
        return res;
    }
	
	
	public PageReference btnSave()
	{
		List<String> setSelectedFieldAPI = new List<String>();
        String strTempFields = '';
        
        if(inRecordSelCols != null && inRecordSelCols!=''){ setSelectedFieldAPI.addAll(inRecordSelCols.split(','));}
        Map<String,String> mapColNameLabel = new Map<String,String>();
        for (SL_LIB16_MassEdit.ColumnInfo info : columns){ mapColNameLabel.put(info.name, info.label);}
        
        for(String item:setSelectedFieldAPI)
        {
        	if (mapColNameLabel.containsKey(item)) strTempFields += ',' + mapColNameLabel.get(item);
        }
        if(strTempFields!='') strTempFields = strTempFields.substring(1);
        
        /*
        for (SL_LIB16_MassEdit.ColumnInfo info : columns)
        {
            if (setSelectedFieldAPI.contains(info.name)) 
            {
                if(strTempFields == ''){ strTempFields = info.label;}  
                else{ strTempFields += ',' + info.label;}
            }
        }
        */
        
        List<SL_View_Filter__c> lstFiltersTemplateToInsert = new List<SL_View_Filter__c>();
        curRecordVal.Advanced_Filter__c =  inRecordFiltersAdv;
		curRecordVal.Columns__c = strTempFields;
		try
		{
			upsert curRecordVal;
		}
		catch(Exception ex)
		{
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage()));
			return null;
		}
        
		for(SL_View_Filter__c objFiltersTemplate : [Select Id from SL_View_Filter__c where SL_View__c =:curRecordVal.ID])
		{
			lstFiltersTemplateToInsert.add(objFiltersTemplate);
		}
		if(lstFiltersTemplateToInsert.size()>0){ delete lstFiltersTemplateToInsert;}
		
		lstFiltersTemplateToInsert = new List<SL_View_Filter__c>();
        List<String> lstCbFilterRow = new List<String>(); /// create a list to hold the filters in form of string
        if(inRecordFiltersCols != Null){ lstCbFilterRow.addAll(inRecordFiltersCols.split('##'));}
		//system.debug('lstCbFilterRow>>>>>>>>>>>>>>>>>>>>'+lstCbFilterRow);

		if(lstCbFilterRow != null && !lstCbFilterRow.isempty())
        {
        	/// create a list of Filters Template DCM__c records to insert
            for(String objString:lstCbFilterRow)
            {
            	List<String> lstString = new List<String>();
                lstString.addAll(objString.split('___'));
                        
                if(lstString != null && lstString.size() > 1)
                {   
                	SL_View_Filter__c objFiltersTemplate = new SL_View_Filter__c();
                    objFiltersTemplate.SL_View__c = curRecordVal.ID;
					objFiltersTemplate.Type__c = lstString[0];
                    if(lstString.size()>1)
                    objFiltersTemplate.Field__c = lstString[1];
                    if(lstString.size()>2)
                    objFiltersTemplate.Operator__c = lstString[2];
                    if(lstString.size()>3)
                    objFiltersTemplate.Value__c = lstString[3];

                    lstFiltersTemplateToInsert.add(objFiltersTemplate);
				}
			}
		}
                
        //system.debug('lstFiltersTemplateToInsert>>>>>>>>>>>>>>>>>>>>'+lstFiltersTemplateToInsert);
        if(!lstFiltersTemplateToInsert.isempty()){ insert lstFiltersTemplateToInsert;}

		PageReference pageRef = new PageReference('/'+curRecordVal.ID);
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
			String sObjPrefix = Schema.getGlobalDescribe().get('SL_View__c').getDescribe().getKeyPrefix();
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