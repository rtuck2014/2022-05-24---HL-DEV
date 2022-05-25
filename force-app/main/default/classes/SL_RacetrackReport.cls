/** 
* \arg ClassName      : SL_RacetrackReport
* \arg JIRATicket     : HL-8
* \arg CreatedOn      : 8/MAY/2014
* \arg LastModifiedOn : 27/MAR/2015
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : AYU - added PreviousPage class
* \arg Description    : Controller class for filter and reports pages.
*/
public without sharing class SL_RacetrackReport  
{
    /* Start - Variables for Filter page */
    public SObject engagementCounterparty       {   get;set;    }//!< This object is going to use to select Engagement record for generate report.
    public String strGroupBy                                        {   get;set;    }//!< This string is used to get the field api name to group the data.
    public String strSortBy                                         {   get;set;    }//!< This string is used to hold the field api name for sorting.
    public String strOrderBy                                        {   get;set;    }//!< This string is used to get order ASC or DESC.
    public String strReportType                                     {   get;set;    }//!< This variable is used to select the Report type date or checkbox.
    public String strFileType                                       {   get;set;    }//!< This variable is use to select the file type pdf/excel
    public List<String> lstSelectedStage                            {   get;set;    }//!< This list is used to select the fields to show on report.
    public Map<String, boolean> mapShowTotalVals                    {   get;set;    }//!< This map is used to check fields on Date type
    
    public String strParentID                                       {   get;set;    }
    public boolean isShowFilter                                     {   get;set;    }
    public boolean isShowExtraGroupOption                           {   get;set;    }
    
    
    private String strParentObject;//!< Used to store Parent Object API name from custom settings.
    private String strFieldSetName;//!< Used to store Fields API name from custom settings.
    private String strFieldSetNameSort;//!< Used to store Fields API name from custom settings.
    private String strFieldSetNameGroup;//!< Used to store Fields API name from custom settings.
    private String strChildObject;//!< Used to store Child Object API name from custom settings.
    private Map<String, Schema.SObjectType> mapGlobalDescribe;//!< Describe map to get the fields, fieldset and picklist values etc...
    
    /* NEW Filter visual component  Start */
    private static Map<String, Schema.SObjectType> oDescribe = Schema.getGlobalDescribe();
    public SL_RTR_LIB209_ctrl_SearchBlockParams curSearchBlockParams;
    public SL_RTR_LIB16_FilterSOQLCompiler m_filters = new SL_RTR_LIB16_FilterSOQLCompiler();
    public String oWhereClause { get; set; }
    public String sDebugInfo { get; set; }
    
    public List<SelectOption> aObjectsOptions { get; set; }
    public List<String> aSearchColumns { get; set; }
    public Map<String, String> aSearchColumnLabels { get; set; }
    public boolean isNoError{ get; set; }
    
    public String inRecordFiltersCols {get; set;}
    public String inRecordFiltersAdv {get; set;}
    
    
    /* NEW Filter visual component  End */
    /* End - Variables for Filter page */
    
    
    /* Start - Variables for Report page */
    public String strParentObjectName                               {   get;set;    }//!< This is to display the Engagement name.   
    public List<GroupWrapper> lstGroupWrapper                       {   get;set;    }//!< This is main list to populate the data on report.
    public List<String> lstColumnHeader                             {   get;set;    }//!< This variable is used to show the header of the columns
    public List<String> lstColumns                                  {   get;set;    }//!< This variable is used to access the value from the object for each column.
    public Map<String, Integer> mapGrandTotal                       {   get;set;    }//!< This is map which is used to get the GTotal of each column.
    public Map<String, String> mapFieldNameToType                   {   get;set;    }//!< This is used to store Data type of selected Fields 
    public String strCheckMark                                      {   get;set;    }//!< This is used to show the cross sign on the report if the report format is chekbox.
    public String strLogoURL                                        {   get;set;    }//!< Store the URL of logo from cutom setting.
    public String strParentObjectRelation {   get;set;    }//!< This will store API name of Parent object of child object from custom settings
    
    
    private List<String> lstHeaderOrder;//!< This will store header value in order need to show on report.
    private Map<String, String> mapFieldAPIToLabel;//!< This will contains the fields api to label name
    private String strCompanyObject;//!< This will store API name of Grouping object from custom setting
    private String strCompanyObjectRelation;//!< This will store API name of Grouping object of child object from custom settings
    
    
    /* End - Variables for Report page */
    
    /* Start - Contructor */
    public SL_RacetrackReport()
    {
        strParentObjectName = '';
        strParentID = '';
        isNoError = false;
        strParentID = Apexpages.currentPage().getParameters().get('parentId');
         
        initializeReportVariable();//!< calling method to intializing all report variables.
        
        getSobjectAPINameFromCustomSetting();//!< getting sobject api name from custom setting.
        
        initialize();//!< intializing all global variables.
        if(Apexpages.currentPage().getParameters().get('viewId') != null && Apexpages.currentPage().getParameters().get('viewId') != '')
        {
            //prepareRecordToReport(prepareQueryFromView());
        }

        this.aSearchColumns = new List<String>();
        this.aSearchColumnLabels = new Map<String, String>();
        this.sSelectedOption = this.strChildObject;
        

    }
    /* End - Constructor */
    
    /* Start - Wrapper Class for Picklist */
    /*
    public class PicklistWrapper
    {
        public String strLabel                      {   get;set;    }
        public String strAPIName                    {   get;set;    }
        public List<SelectOption> allValues         {   get;set;    }
        public List<String> selectedValues          {   get;set;    }
        
        public PicklistWrapper(String strLabel, String strAPIName, List<SelectOption> allValues)
        {
            this.strLabel = strLabel;
            this.strAPIName = strAPIName;
            this.allValues = allValues;
            this.selectedValues = new List<String>();
        }
    }
    */
    /* End - Wrapper Class for Picklist */

    public String sSelectedOption {
        get;
        set {
            sSelectedOption = value;

            this.aSearchColumnLabels.clear();
            this.aSearchColumns.clear();
            
            if ( oDescribe.containsKey( sSelectedOption ) ) {
                for ( Schema.SObjectField oItem : oDescribe.get( sSelectedOption ).getDescribe().fields.getMap().values() ) {
                    
                    if(''+oItem.getDescribe().getType()!= 'address' && ''+oItem.getDescribe().getType() != 'location')
                    {
                        this.aSearchColumns.add( oItem.getDescribe().getName() );
                        this.aSearchColumnLabels.put( oItem.getDescribe().getName(), oItem.getDescribe().getLabel() );
                    }
                }
                this.aSearchColumns.sort();
            }
        }
    }
    
    /* Start - Wrapper Class to show each records on the report */
    public class RecordWrapper 
    {
        public Sobject sObj         {   get;set;   }
        public String strRT         {   get;set;   }
        public String companyName   {   get;set;   }
        
        public RecordWrapper(String strRT, Sobject sObj, String companyName)
        {
            this.strRT = strRT;
            this.sObj = sObj;
            this.companyName =  companyName;  
        }
    }
    /* End - Wrapper Class to show each records on the report */ 
    
    /* Start - Wrapper Class to grouping the record on the basis of fields */
    public class GroupWrapper
    {
        public List<RecordWrapper> lstRecordWrapper {   get;set;   }
        public Map<String, Integer> mapSubTotal     {   get;set;   }
        public String strRT                         {   get;set;   }
        
        public GroupWrapper(String strRT, List<RecordWrapper> lstRecordWrapper, Map<String, Integer> mapSubTotal)
        {
            this.strRT = strRT;
            this.lstRecordWrapper = lstRecordWrapper;
            this.mapSubTotal = mapSubTotal;
        }
    }
    /* End - Wrapper Class to grouping the record on the basis of fields  */ 
    
    /*
        @MethodName : initialize 
        @param      : NA
        @Description: method to intialize all global variables. 
    */
    private void initialize()
    {
        mapGlobalDescribe = Schema.getGlobalDescribe();

        engagementCounterparty = mapGlobalDescribe.get(strChildObject).newSObject();

       
        if(strParentID!=null && strParentID!='')
        {
            engagementCounterparty.put(strParentObjectRelation, (ID)strParentID);
        }
        System.debug('engagementCounterparty.get(strParentObjectRelation) get >>>>>>> '+engagementCounterparty.get(strParentObjectRelation));
        
        strGroupBy = strSortBy = strOrderBy = strReportType = '';
        //strParentObject = strFieldSetName = strChildObject = '';
        lstSelectedStage = new List<String>{'All'};
        
        if(engagementCounterparty.get(strParentObjectRelation)!=null)
        {
            List<Sobject> lstSobject = Database.query('SELECT Id, Name FROM '+strParentObject+' WHERE Id=\''+engagementCounterparty.get(strParentObjectRelation)+'\' limit 1');
            if(lstSobject!=null && lstSobject.size()==1){ strParentObjectName = ''+lstSobject[0].get('Name');}
        } 
        
    }
    /* End */
    
    /*
        @MethodName : initializeReportVariable 
        @param      : NA
        @Description: method to intialize all global variables. 
    */
     private void initializeReportVariable()
     {
        lstGroupWrapper = new List<GroupWrapper>();
        lstColumns = new List<String>();
        lstColumnHeader = new List<String>();
        lstHeaderOrder = new List<String>();
        mapGrandTotal = new Map<String, Integer>();
        mapShowTotalVals = new Map<String, boolean>();
        mapFieldNameToType = new Map<String, String>();
        mapFieldAPIToLabel = new Map<String, String>();
        strParentObjectName = strParentObject = strCompanyObject = strParentObjectRelation = strCompanyObjectRelation = strLogoURL = '';
        
        strCheckMark = 'X';
     }
    /* End */
    
    public SL_RTR_LIB209_ctrl_SearchBlockParams getSearchCompParams()
    {
        if(curSearchBlockParams==null)
        {
            curSearchBlockParams = new SL_RTR_LIB209_ctrl_SearchBlockParams();
            curSearchBlockParams.tabs = new List<SelectOption>();
            curSearchBlockParams.mainSelTarget = 'Target_000';
            curSearchBlockParams.searchBtnClick = '';
            curSearchBlockParams.FiltersJSON = '[]';
            curSearchBlockParams.cb_target = 'Main';
            curSearchBlockParams.cb_advFilters = '';
            curSearchBlockParams.dateFormat = SL_RTR_LIB16_DateObject.dateFormat;
        }
        curSearchBlockParams.tabsObjName = new List<SelectOption>{new selectOption('Target_000',this.sSelectedOption)};
        curSearchBlockParams.locationBase = '/apex/SL_RTR_LIB209_SearchBox_JSON?targetobj='+this.sSelectedOption+'&evtmp=';
        
        return curSearchBlockParams;
    }


    /*
        @MethodName : getSobjectAPINameFromCustomSetting 
        @param      : NA
        @Description: method to get object api names from custom setting. 
    */
    private void getSobjectAPINameFromCustomSetting()
    {
        //strParentObjectName
        
        //SL_RTR_LIB16_ME_DescribeObject_Core oDescribeObjectCore = SL_RTR_LIB16_ME_DescribeObject_Core.getInstance();
        //String inParentObjectname = oDescribeObjectCore.getObjectNameByID(strParentID);
        
        
        String strCSName = '';
        String strCSNameAny = '';
        String strCSNameByDevName = '';
        String strCSNameByVals = '';
        ApexPages.Message errMsgNoCS;

        String strCSDevName = '';
        String strCSVals = '';
        if(Apexpages.currentPage().getParameters().get('cs')!=null && Apexpages.currentPage().getParameters().get('cs')!='')
        {
            strCSDevName = Apexpages.currentPage().getParameters().get('cs');
        }
        else
        {
        	errMsgNoCS = new ApexPages.Message(ApexPages.Severity.ERROR,'No cs parameter passed in: Missing Required Parameter: A Racetrack custom setting must be selected via the \'cs\' url parameter.');//Same old drama 
			ApexPages.addMessage(errMsgNoCS);
        }
        
        if(Apexpages.currentPage().getParameters().get('vals')!=null && Apexpages.currentPage().getParameters().get('vals')!='')
        {
            strCSVals = Apexpages.currentPage().getParameters().get('vals');
        }
        
        set<String> setFilterVals;
        for(SL_RacetrackReport__c item:[Select Name, Layout_Filter_Field_Values__c, Id, Developer_Name__c From SL_RacetrackReport__c /*where ParentObjectAPIName__c=:inParentObjectname*/])
        {
            setFilterVals = new set<String>();
            if(item.Layout_Filter_Field_Values__c!=null && item.Layout_Filter_Field_Values__c!=''){ setFilterVals.addAll(item.Layout_Filter_Field_Values__c.split(',',0));}
            if(strCSNameAny==''){ strCSNameAny = item.Name;}
            
            if(strCSDevName!='' && strCSVals!='')
            {
                if(item.Developer_Name__c == strCSDevName && item.Layout_Filter_Field_Values__c.indexOf(strCSVals)!=-1){ strCSName = item.Name;}
                else if(item.Developer_Name__c == strCSDevName){ strCSNameByDevName = item.Name;}
                else if(item.Layout_Filter_Field_Values__c!=null && item.Layout_Filter_Field_Values__c!='' && item.Layout_Filter_Field_Values__c.indexOf(strCSVals)!=-1){ strCSNameByVals = item.Name;}
            }
            else if(strCSVals!='' && item.Layout_Filter_Field_Values__c!=null && item.Layout_Filter_Field_Values__c!='' && item.Layout_Filter_Field_Values__c.indexOf(strCSVals)!=-1){ strCSName = item.Name;}
            else if(strCSDevName!='' && item.Developer_Name__c == strCSDevName){ strCSName = item.Name;}
        }
        if(strCSName==''){ strCSName = strCSNameByDevName;}
        if(strCSName==''){ strCSName = strCSNameByVals;}
        if(strCSName==''){ strCSName = strCSNameAny;}
        
        SL_RacetrackReport__c objCS = null;
        
        if(strCSName!=''){ objCS = SL_RacetrackReport__c.getValues(strCSName);}

        if(objCS != null) //!<checking condition if No custom setting record found with name 'default'.
        {
            strChildObject = objCS.ChildObjectAPIName__c;
            strParentObject = objCS.ParentObjectAPIName__c;
            strFieldSetName = objCS.FieldSetAPIName__c;
            strFieldSetNameSort = objCS.SortByFieldSetAPIName__c;
            strFieldSetNameGroup = objCS.GroupByFieldSetAPIName__c;
            strParentObject = objCS.ParentObjectAPIName__c;
            strCompanyObject = objCS.GroupingObjectAPIName__c;
            strParentObjectRelation = objCS.ParentObjectRelationshipAPIName__c;
            strCompanyObjectRelation = objCS.GroupingObjectRelationshipAPIName__c;
            isShowFilter = objCS.Show_Filter__c;
            isShowExtraGroupOption = objCS.ShowExtraGroupOption__c;
            if(objCS.Logo_URL__c != null){ strLogoURL = objCS.Logo_URL__c;}

            isNoError = true;
        }
        else
        {
            if(errMsgNoCS==null)
            {
            	ApexPages.Message errMsgNoCS2 = new ApexPages.Message(ApexPages.Severity.ERROR,'no custom setting found when passing in parameter: No Racetrack custom setting with a name of \''+strCSDevName+'\' was found.');//Same old drama 
				ApexPages.addMessage(errMsgNoCS2);
            }
            
            strChildObject = 'Opportunity';
            strParentObject = 'Account';
            strFieldSetName = 'SL_OppRacetrackReport';
            strFieldSetNameSort = null;
            strFieldSetNameGroup = null;
            strParentObjectRelation = 'AccountId';
            strCompanyObject = 'User';
            strCompanyObjectRelation = 'OwnerId';
            strLogoURL = '';
            isShowFilter = true;
            isShowExtraGroupOption = true;
        }
        
    }
    /* End */
    
    /*
        @MethodName : getStageOptions 
        @param      : NA
        @Description: to get fields from the field set and show on the pages.
    */
    public List<SelectOption> getStageOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));
        options.addAll(getFieldSetFields(strChildObject, strFieldSetName)) ;    
        return options;
    }
    /* End */
    
    /*
        @MethodName : getSortingOption 
        @param      : NA
        @Description: method is to get fields for sorting.
    */
    public List<SelectOption> getSortingOption()
    {
        List<SelectOption> options = new List<SelectOption>();
        if(strFieldSetNameSort!=null && strFieldSetNameSort!=''){ options.addAll(getFieldSetFields(strChildObject, strFieldSetNameSort));}
        else{ options.addAll(getFieldSetFields(strChildObject, strFieldSetName));} 
        
        return options;
    }
    /* End */
    
    public List<Selectoption> getGroupByOptions()
    {
        if(strFieldSetNameGroup!=null && strFieldSetNameGroup!='')
        {
            return getFieldSetFields4Group(strChildObject, strFieldSetNameGroup);
        }
        
        List<SelectOption> options = new List<SelectOption>();
        map<String,String> mapOpt2Sort = new map<String,String>();
        List<String> lstOpt2Sort = new List<String>();
        
        for(Schema.Sobjectfield objSobjectField : getSobjectFields(strChildObject))
        {
            mapOpt2Sort.put(objSobjectField.getDescribe().getLabel(), objSobjectField.getDescribe().getname() +':'+ objSobjectField.getDescribe().getType());
            lstOpt2Sort.add(objSobjectField.getDescribe().getLabel());
            /*
            options.add(new Selectoption(objSobjectField.getDescribe().getname() +':'+ objSobjectField.getDescribe().getType(), 
                                objSobjectField.getDescribe().getLabel()));
            */
        }
        if(lstOpt2Sort.size()>0)
        {
            lstOpt2Sort.sort();
            for(String item:lstOpt2Sort)
            {
                options.add(new Selectoption(mapOpt2Sort.get(item),item));
            }
        }
        
        if(this.isShowExtraGroupOption==true)
        {
            mapOpt2Sort = new map<String,String>();
            lstOpt2Sort = new List<String>();
            
            for(Schema.Sobjectfield objSobjectField : getSobjectFields(strCompanyObject))
            {
                mapOpt2Sort.put(strCompanyObject+' : '+ objSobjectField.getDescribe().getLabel(), getRelationFldRef(strCompanyObjectRelation)+'.'+ objSobjectField.getDescribe().getname()+':'+ objSobjectField.getDescribe().getType());
                lstOpt2Sort.add(strCompanyObject+' : '+ objSobjectField.getDescribe().getLabel());
                /*
                options.add(new Selectoption(getRelationFldRef(strCompanyObjectRelation)+'.'+ objSobjectField.getDescribe().getname()+':'+ objSobjectField.getDescribe().getType(), 
                                             strCompanyObject+' : '+ objSobjectField.getDescribe().getLabel() ));
                */
            }
            if(lstOpt2Sort.size()>0)
            {
                lstOpt2Sort.sort();
                for(String item:lstOpt2Sort)
                {
                    options.add(new Selectoption(mapOpt2Sort.get(item),item));
                }
            }
        }
        
        return options;
    }
    
    
    private List<SelectOption> getFieldSetFields4Group(String strObjectName, String strFieldSetName)
    {
        List<SelectOption> options = new List<SelectOption>();
        lstHeaderOrder = new List<String>();
        try
        {
            if(!String.isEmpty(strObjectName) && mapGlobalDescribe.containsKey(strObjectName))
            {
                Schema.FieldSet fieldSetObj = mapGlobalDescribe.get(strObjectName).getDescribe().FieldSets.getMap().get(strFieldSetName);
                for(Schema.FieldSetMember fieldSet : fieldSetObj.getFields())
                {
                    
                    
                    String strFieldPath = fieldSet.getFieldPath();
                    if(fieldSet.getType() == Schema.Displaytype.REFERENCE)
                    {
                        strFieldPath = (fieldSet.getFieldPath().contains('__c')) ? fieldSet.getFieldPath().replace('__c','__r.Name') : 
                                                                                          fieldSet.getFieldPath().replace('Id','.Name');
                    }

                    if(fieldSet.getType() == Schema.Displaytype.DATE){mapShowTotalVals.put(strFieldPath, true);}
                    else{ mapShowTotalVals.put(strFieldPath, false);}

                    mapFieldNameToType.put(strFieldPath,string.valueOf(fieldSet.getType()));
                    mapFieldAPIToLabel.put(strFieldPath, fieldSet.getLabel());
                    lstHeaderOrder.add(strFieldPath);//!< list is used to order the column of the report columns
                    options.add(new SelectOption(strFieldPath+':'+fieldSet.getType(), fieldSet.getLabel()));
                    
                    
                }
            }
        }
        catch(Exception e)
        {
            System.debug('=======Exception==='+e.getMessage()+'==== @ Line Number===='+e.getLineNumber());
        }          

        return options;
    }
    
    
    /*
        @MethodName : getFieldSetFields 
        @param      : Sobject name and field set name.
        @Description: method to get fields from fieldset.
    */
    private List<SelectOption> getFieldSetFields(String strObjectName, String strFieldSetName)
    {
        List<SelectOption> options = new List<SelectOption>();
        lstHeaderOrder = new List<String>();
        try
        {
            if(!String.isEmpty(strObjectName) && mapGlobalDescribe.containsKey(strObjectName))
            {
                Schema.FieldSet fieldSetObj = mapGlobalDescribe.get(strObjectName).getDescribe().FieldSets.getMap().get(strFieldSetName);
                for(Schema.FieldSetMember fieldSet : fieldSetObj.getFields())
                {
                    
                    
                    String strFieldPath = fieldSet.getFieldPath();
                    if(fieldSet.getType() == Schema.Displaytype.REFERENCE)
                    {
                        strFieldPath = (fieldSet.getFieldPath().contains('__c')) ? fieldSet.getFieldPath().replace('__c','__r.Name') : 
                                                                                          fieldSet.getFieldPath().replace('Id','.Name');
                    }

                    if(fieldSet.getType() == Schema.Displaytype.DATE){mapShowTotalVals.put(strFieldPath, true);}
                    else{ mapShowTotalVals.put(strFieldPath, false);}

                    mapFieldNameToType.put(strFieldPath,string.valueOf(fieldSet.getType()));
                    mapFieldAPIToLabel.put(strFieldPath, fieldSet.getLabel());
                    lstHeaderOrder.add(strFieldPath);//!< list is used to order the column of the report columns
                    options.add(new SelectOption(strFieldPath, fieldSet.getLabel()));
                    
                    
                }
            }
        }
        catch(Exception e)
        {
            System.debug('=======Exception==='+e.getMessage()+'==== @ Line Number===='+e.getLineNumber());
        }          

        return options;
    }
    /* End */
    
    /*
        @MethodName : getPicklistValue 
        @param      : Sobject name and filed api name.
        @Description: method to get picklist value from field.
    */
    /*
    private List<Selectoption> getPicklistValue(String strSobjectName, String strFieldName)
    {
        List<SelectOption> options = new List<SelectOption>();
        if(!String.isEmpty(strSobjectName) && !String.isEmpty(strFieldName) && mapGlobalDescribe.containsKey(strSobjectName))
        {
            Schema.SObjectType targetType = mapGlobalDescribe.get(strSobjectName);//!< From the Object Api name retrieving the SObject
            Sobject Object_name = targetType.newSObject();
            Schema.sObjectType sobject_type = Object_name.getSObjectType(); //!< grab the sobject that was passed
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //!< describe the sobject
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //!< get a map of fields for the passed sobject
            if(field_map.containsKey(strFieldName))
            {
                List<Schema.PicklistEntry> pick_list_values = field_map.get(strFieldName).getDescribe().getPickListValues(); 
                for (Schema.PicklistEntry a : pick_list_values) 
                { 
                    options.add(new SelectOption(a.getValue(),a.getValue()));
                }
            }
        }
        return options;
    }
    */
    /* End */
    
    /*
        @MethodName : getSobjectFields 
        @param      : Sobject name.
        @Description: method to get sobject fields.
    */
    private List<Schema.Sobjectfield> getSobjectFields(String strSobjectName)
    {
        List<Schema.Sobjectfield> lstSobjectfield = new List<Schema.Sobjectfield>();
        if(!String.isEmpty(strSobjectName) && mapGlobalDescribe.containsKey(strSobjectName))
        {
            Map<String,Schema.Sobjectfield> mapFields = mapGlobalDescribe.get(strSobjectName).getDescribe().fields.getMap();    
            for(Schema.Sobjectfield objSobjectField : mapFields.values())
            {
                if(objSobjectField.getDescribe().isAccessible() && objSobjectField.getDescribe().isSortable())
                    lstSobjectfield.add(objSobjectField);
            }
        }
        
        return lstSobjectfield;
    }
    /* End */
    
    /*  
        @MethodName   : generateReport
        @param        : None
        @Description  : This method will call from page to generate the report.
    */
    public Pagereference generateReport()
    {
        
        //system.debug('Point1 >>>> ');
        try
        {
            if(strParentID==null || strParentID=='')
            {
            	strParentID = ''+engagementCounterparty.get(strParentObjectRelation);
            	strParentObjectName = [SELECT Id, Name FROM Engagement__c WHERE Id =: strParentID LIMIT 1].Name;
            }
            
            
            String addSQLWhere = '';
            //system.debug('Point2 >>>> '+isShowFilter);
            if(isShowFilter==true)
            {
                //strParentObjectName = [SELECT Id, Name FROM Engagement__c WHERE Id =: engagementCounterparty.get(strParentObjectRelation) LIMIT 1].Name;
                m_filters.Initialize(inRecordFiltersCols, inRecordFiltersAdv, strChildObject);
                //inStrWhere = m_filters.SOQL;
                //system.debug('m_filters.SOQL>>>>>>>>>>>>>> '+m_filters.SOQL);
                addSQLWhere = m_filters.SOQL;
            }
            
            
            String strQuery = prepareQuery(addSQLWhere);
            //system.debug('strQuery >>>> '+strQuery);
            prepareRecordToReport(strQuery);
            PageReference reportPage;
            if(strFileType == 'pdf')
                reportPage = new PageReference('/apex/SL_Racetrack_Report_Pdf');
            else
                reportPage = new PageReference('/apex/SL_Racetrack_Report_Excel');
                
            reportPage.setRedirect(false);
            return reportPage;
        }
        catch(Exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,''+ ex.getMessage()));
            return null;
        }
    }
    /* End */
    
    /*  
        @MethodName   : PreviousPage
        @param        : None
        @Description  : This method will take user to previous page.
    */
    
    public Pagereference PreviousPage()
    {
        PageReference pf = ApexPages.currentPage(); 
        pf = new PageReference('/' + strParentID);
        return pf;
    }
    
    /* End */
    
    public string getRelationFldRef(String inRelationFld)
    {
        if(inRelationFld==null || inRelationFld=='') return null;
        return (inRelationFld.subString(inRelationFld.length()-2, inRelationFld.length()) == 'Id') 
                                                                ? inRelationFld.subString(0,inRelationFld.length()-2)+'' 
                                                                : inRelationFld.replace('__c','__r');
    }
    
    
    /*-------------------------------------------------------------------------- Start - Report Methods ---------------------------------------------------------------*/
    
    /*  
        @MethodName   : prepareQuery
        @param        : None
        @Description  : method to generate Query.
    */
    public String prepareQuery(String inStrWhereClause)
    {
        try
        {
            List<String> lstSelectedField = new List<String>();
            String strFieldCSV = '';
            String strWhereClause = inStrWhereClause;
            String strOrderBy = ' ORDER BY ' + strSortBy + ' ' + strOrderBy;
            
            for(String strField : lstSelectedStage)
            {
                if(strField == 'All')
                {
                    lstSelectedField = new List<String>();
                    lstSelectedField.addAll(lstHeaderOrder);
                    break;
                }
                else
                {
                    lstSelectedField.add(strField);
                }
            }
            
            for(String strFieldAPIName : lstSelectedField)
            {
                if(strFieldAPIName != getRelationFldRef(strCompanyObjectRelation)+'.Name')
                {
                    lstColumnHeader.add(mapFieldAPIToLabel.get(strFieldAPIName));
                    lstColumns.add(strFieldAPIName);
                }
                strFieldCSV += (strFieldCSV == '') ? strFieldAPIName : ', ' + strFieldAPIName;
            }
            
            strFieldCSV += (!strFieldCSV.contains(strParentObjectRelation)) ? ', ' + strParentObjectRelation : '';
            strFieldCSV += (!strFieldCSV.contains(strCompanyObjectRelation)) ? ', ' + strCompanyObjectRelation : '';
            
            if(strGroupBy.split(':')[1] == 'REFERENCE')
            {
                strFieldCSV += (!strFieldCSV.contains(strGroupBy.split(':')[0])) ? ', ' + strGroupBy.split(':')[0] : '';
                if(getRelationFldRef(strGroupBy.split(':')[0])!=strGroupBy.split(':')[0])
                {
                    String strAPI = getRelationFldRef(strGroupBy.split(':')[0])+'.Name';
                    strFieldCSV += (!strFieldCSV.contains(strAPI)) ? ', ' + strAPI : '';
                }
            }
            else if(!strFieldCSV.contains(strGroupBy.split(':')[0]))
            {
                strFieldCSV += ', ' + strGroupBy.split(':')[0];
            }
            
            strFieldCSV += (strGroupBy.split(':')[1] == 'REFERENCE' && !strFieldCSV.contains(strGroupBy.split(':')[0]) 
                                                                    && !strFieldCSV.contains(strGroupBy.split(':')[0].replace('__c','__r.Name'))) 
                            ? ', ' + strGroupBy.split(':')[0] + ', ' + strGroupBy.split(':')[0].replace('__c','__r.Name') 
                            : (strGroupBy.split(':')[1] == 'REFERENCE' && strFieldCSV.contains(strGroupBy.split(':')[0]) 
                                                                       && !strFieldCSV.contains(strGroupBy.split(':')[0].replace('__c','__r.Name'))) 
                            ? ', ' + strGroupBy.split(':')[0].replace('__c','__r.Name') 
                            : (!strFieldCSV.contains(strGroupBy.split(':')[0])) ? ', ' + strGroupBy.split(':')[0] : '';
                            
            strFieldCSV += (!strFieldCSV.contains(getRelationFldRef(strCompanyObjectRelation)+'.Name')) ? (', '+getRelationFldRef(strCompanyObjectRelation)+'.Name') : '';               
            strFieldCSV = (strFieldCSV.contains('Id')) ? strFieldCSV : 'Id, ' + strFieldCSV;
                            
            strWhereClause += (strWhereClause == '') ? '' : ' AND '; 
            strWhereClause += ' '+strParentObjectRelation +' = \'' + engagementCounterparty.get(strParentObjectRelation) +'\''; 
            
            String strQuery = 'SELECT ' + strFieldCSV + ' FROM ' + strChildObject + ' WHERE ' + strWhereClause + strOrderBy;
            
            System.debug('============strQuery========='+strQuery);
            
            return strQuery;
        }
        catch(Exception e)
        {
            System.debug('=======Exception==='+e.getMessage()+'==== @ Line Number===='+e.getLineNumber());
            return '';
        }
    }
    /* End */

    /*  
        @MethodName   : getCSVString
        @param        : List of String
        @Description  : This method is used to prepare the records to show on report.
    */
    private void prepareRecordToReport(String strQuery) 
    {
        try
        {    
            List<Sobject> lstSobject = Database.query(strQuery);    
            List<String> lstGroupingOrder = new List<String>();   
            List<RecordWrapper> lstRecordWrapper = new List<RecordWrapper>();
            lstGroupWrapper = new List<GroupWrapper>();
            Map<String, Map<String, Integer>> mapSubTotal = new Map<String, Map<String, Integer>>();
            Map<String, Integer> mapTemp = new Map<String, Integer>();
            Map<String, String> mapRTNameToGroupName = new Map<String, String>(); 
            
            for(Sobject sObj : lstSobject)
            {
                String groupId = '';
                String fldName = strGroupBy.split(':')[0];


                system.debug('strGroupBy.split >>>>>>>>>>>>> '+strGroupBy.split(':')[0]);
                system.debug('fldName >>>>>>>>>>>>> '+fldName);
                system.debug('fldName.contains >>>>>>>>>>>>> '+fldName.contains('.'));
                system.debug('fldName.split >>>>>>>>>>>>> '+fldName.split('\\.')[0]);


                String fldNameFirstRelation = (fldName.contains('.'))?getRelationFldRef(fldName.split('\\.')[0]):null;
                String fldNameSecondRelation = (fldNameFirstRelation!=null && fldName.replace(fldNameFirstRelation+'.','').contains('.'))?getRelationFldRef(fldName.replace(fldNameFirstRelation+'.','').split('\\.')[0]):null;
                if(fldNameFirstRelation!=null && strGroupBy.contains(fldNameFirstRelation))
                {
                    if(fldNameSecondRelation!=null && strGroupBy.contains(fldNameSecondRelation))
                    {
                        if(sObj.getSobject(fldNameFirstRelation)==null || sObj.getSobject(fldNameFirstRelation).getSobject(fldNameSecondRelation)==null){ groupId = 'Empty';}
                        else{ groupId = String.valueOf( sObj.getSobject(fldNameFirstRelation).getSobject(fldNameSecondRelation).get(fldName.replace(fldNameFirstRelation+'.','').replace(fldNameSecondRelation+'.','')));}
                    }
                    else
                    {
                        if(sObj.getSobject(fldNameFirstRelation)==null){ groupId = 'Empty';}
                        else{ groupId = String.valueOf(sObj.getSobject(fldNameFirstRelation).get(fldName.replace(fldNameFirstRelation+'.','')));}
                    }
                        
                } 
                else{ groupId = String.valueOf(sObj.get(fldName));}
                groupId = (strGroupBy.split(':')[1] == 'DATE' && groupId != null) ?  formatDate(groupId) : groupId;
                
                if(!mapRTNameToGroupName.containsKey(groupId))
                {
                    
                    String strGroupValue = groupId;
                    
                    /*
                    String strGroupValue = '';
                    if(strGroupBy.split(':')[1] == 'REFERENCE')
                    {
                        String strAPI = (strGroupBy.split(':')[0].subString(strGroupBy.split(':')[0].length() -2, strGroupBy.split(':')[0].length()) == 'Id') 
                                                                        ? strGroupBy.split(':')[0].replace('Id',':Name') 
                                                                        : strGroupBy.split(':')[0].replace('__c','__r:Name');
                        
                        if(getRelationFldRef(strGroupBy.split(':')[0])==strGroupBy.split(':')[0])
                        {
                            strAPI = strGroupBy.split(':')[0].replace('Id.Name','Id:Name');
                            strAPI = strGroupBy.split(':')[0].replace('__r.Name','__r:Name');
                        }
                        strGroupValue = (strGroupBy.contains(getRelationFldRef(strCompanyObjectRelation)) && strAPI.split(':')[0].contains('.')) 
                                        ? String.valueOf(sObj.getSobject(getRelationFldRef(strCompanyObjectRelation)).getSobject(strAPI.split(':')[0].replace(getRelationFldRef(strCompanyObjectRelation)+'.','')).get(strAPI.split(':')[1])) 
                                        : String.valueOf(sObj.getSobject(strAPI.split(':')[0]).get(strAPI.split(':')[1]));
                    }
                    else 
                    {
                        strGroupValue = groupId;
                    }
                    */  
                    
                    strGroupValue = (strGroupBy.split(':')[1] == 'DATE' && strGroupValue != null) ? formatDate(strGroupValue) :strGroupValue;
                    mapRTNameToGroupName.put(groupId, strGroupValue);
                    lstGroupingOrder.add(groupId);
                }
                lstRecordWrapper.add(new RecordWrapper(groupId, sObj, String.valueOf(sObj.getSobject(getRelationFldRef(strCompanyObjectRelation)).get('Name'))));//!<Creating the lst of the Record wrapper.
                mapTemp = new Map<String, Integer>();
                
                //getting the subtotal for each group
                for(String strObj : lstColumns)
                {
                    if(strObj.contains('__r.Name'))
                    {
                        strObj = strObj.removeEnd('__r.Name') + String.valueOf('__c');
                    }
                    
                    if(!mapSubTotal.containsKey(groupId))
                    {
                        if(strObj.contains('__r.') && sObj.getSobject(strObj.substring(0, strObj.indexOf('.'))).get(strObj.substring(strObj.indexOf('.') + 1, strObj.length())) != null)
                            mapTemp.put(strObj, 1);
                        else if(!strObj.contains('__r.') && sObj.get(strObj) != null && sObj.get(strObj) != '')
                            mapTemp.put(strObj, 1);
                        else
                            mapTemp.put(strObj, 0);
                        mapSubTotal.put(groupId, mapTemp);
                    }
                    else
                    {
                        if(!mapSubTotal.get(groupId).containsKey(strObj))
                        {
                            if(strObj.contains('__r.') && sObj.getSobject(strObj.substring(0, strObj.indexOf('.'))).get(strObj.substring(strObj.indexOf('.') + 1, strObj.length())) != null)
                                mapTemp.put(strObj, 1);
                            else if(!strObj.contains('__r.') && sObj.get(strObj) != null && sObj.get(strObj) != '')
                                mapTemp.put(strObj, 1);
                            else
                                mapTemp.put(strObj, 0);
                            mapSubTotal.put(groupId, mapTemp);
                        }
                        else
                        {
                            Integer i = mapSubTotal.get(groupId).get(strObj);
                            if(strObj.contains('__r.') && sObj.getSobject(strObj.substring(0, strObj.indexOf('.'))).get(strObj.substring(strObj.indexOf('.') + 1, strObj.length())) != null)
                                i++;
                            else if(!strObj.contains('__r.') && sObj.get(strObj) != null && sObj.get(strObj) != '')
                                i++;
                            mapSubTotal.get(groupId).put(strObj, i);
                        }
                    }   
                }
            }
            
            Map<String, List<RecordWrapper>> mapGroupNameToLstRecordWrapper = new Map<String,List<RecordWrapper>>();
            
            //Creating the group
            for(RecordWrapper objRW : lstRecordWrapper)
            {
                if(mapGroupNameToLstRecordWrapper.containsKey(objRW.strRT))
                    mapGroupNameToLstRecordWrapper.get(objRW.strRT).add(objRW);
                else
                    mapGroupNameToLstRecordWrapper.put(objRW.strRT,new List<RecordWrapper>{objRW});
            }
            //Creating main list. 
            for(String strGN : lstGroupingOrder)
            {
                if(mapGroupNameToLstRecordWrapper.containsKey(strGN))
                    lstGroupWrapper.add(new GroupWrapper(mapRTNameToGroupName.get(strGN), mapGroupNameToLstRecordWrapper.get(strGN), mapSubTotal.get(strGN)));
            }
            //Grand total.
            for(String strObj : lstColumns)
            {
                Integer i = 0;
                if(strObj.contains('__r.Name'))
                {
                    strObj = strObj.removeEnd('__r.Name') + String.valueOf('__c');
                }
                
                for(String strGN : lstGroupingOrder)
                {
                    if(mapSubTotal.containsKey(strGN))
                        i += mapSubTotal.get(strGN).get(strObj);
                }           
                mapGrandTotal.put(strObj, i);
            } 
        }
        catch(Exception e)
        {
            System.debug('=======Exception==='+e.getMessage()+'==== @ Line Number===='+e.getLineNumber());
        }
    }
    /* End */
    
    /*  
        @MethodName   : getCSVString
        @param        : List of String
        @Description  : To create the picklist value for query 
    */
    /*
    private String getCSVString(List<String> lstPicklistValues)
    {
        String strCSV = '';
        for(String strValue : lstPicklistValues)
        {
            strCSV += (strCSV == '') ? '\''+ strValue +'\'' : ',' + '\''+ strValue +'\'';
        }
        return strCSV;
    }
    */
    /* End */
    
    /*  
        @MethodName   : prepareQuery
        @param        : None
        @Description  : This method to set the Date of the report
    */
    public String getCurrentDateTime()
    {
        DateTime res = DateTime.now();
        return res.format('M/dd/yyyy');
    }
    /* End */
    
    public String formatDate(String strDate)
    {
        strDate = strDate.replaceAll('/','-');
        if(strDate.split('-')[0].length() == 4)
        {
            List<String> lstDate = new List<String>();
            strDate = strDate.split(' ')[0];
            /*lstDate.addAll(strDate.split('-'));
            strDate = lstDate[2] + '-' + lstDate[0] + '-' + lstDate[1];*/
        }
        return strDate;
    }

/*
    private String prepareQueryFromView()
    {
        String strVIewId = Apexpages.currentPage().getParameters().get('viewId');
        String strImpId = Apexpages.currentPage().getParameters().get('ImpId');
        String strParentId = Apexpages.currentPage().getParameters().get('parentId');
        String targetObjectName = '';
        String parentObjectName = String.valueOf(Id.valueOf(strParentId).getSObjectType());
        String strQuery = 'SELECT Id, Company__r.Name, Company__r.RecordType.Name';
        String filter = '';
        strReportType = 'dates';
        strGroupBy = 'Company__r.RecordTypeId:REFERENCE';
        Map<String,String> mapFieldNameToFieldAPI = new Map<String,String>();
        SL_LIB16_ME_MassEdit_FilterSOQLCompiler filterCompiler = new SL_LIB16_ME_MassEdit_FilterSOQLCompiler ();
        
        List<Sobject> lstSobject = Database.query('SELECT Id, Name FROM '+ parentObjectName +' WHERE Id =\''+strParentId+'\' LIMIT 1');
        if(!lstSobject.isEmpty())
            strParentObjectName = String.valueOf(lstSobject[0].get('Name'));
        
        
        for(Mass_Edit_Settings__c objMassEditSetting : [SELECT Id,
                                                               Label__c, 
                                                               Field__c, 
                                                               API_Type__c 
                                                          FROM Mass_Edit_Settings__c 
                                                         WHERE Implementation__c =:strImpId 
                                                           AND Implementation_Type__c = 'Target'])
        {
            mapFieldNameToFieldAPI.put(objMassEditSetting.Label__c,objMassEditSetting.Field__c);
            mapFieldNameToType.put(objMassEditSetting.Field__c, objMassEditSetting.API_Type__c);
        }
        
        List<SL_View__c> lstView = [SELECT Columns__c, 
                                           Implementation__r.targetObjectName__c 
                                      FROM SL_View__c 
                                     WHERE Id=:strVIewId];
        
        if(!lstView.isEmpty() && String.isNotEmpty(lstView[0].Columns__c))
        {
            for(String strValue : lstView[0].Columns__c.split(','))
            {
                if(mapFieldNameToFieldAPI.get(strValue) != 'Company__c' && mapFieldNameToFieldAPI.containskey(strValue) && mapFieldNameToFieldAPI.get(strValue)!=null)
                {
                    strQuery += ', '+ mapFieldNameToFieldAPI.get(strValue);
                    lstColumnHeader.add(strValue);
                    lstColumns.add(mapFieldNameToFieldAPI.get(strValue));
                }
            }
        }
        
        
        if(!lstView.isEmpty() && String.isNotEmpty(lstView[0].Implementation__r.targetObjectName__c))
            targetObjectName = lstView[0].Implementation__r.targetObjectName__c;
        
        strQuery += ' FROM '+ targetObjectName +' WHERE ' + parentObjectName + '=\'' + strParentId + '\''; 
        
        
        String cb_filters = ''; /// initialise filter string and assign it with refetched string
        String cb_advFilters = ''; /// initialise advanced filter string and assign it with refetched string
        
        /// recreate cb_filters and cb_advFilters based on the filter template whose name template name is strColumnsAndFiltersTemplate
        for(SL_View_Filter__c objFiltersTemplate:[SELECT Id,
                                                         Type__c,
                                                         Field__c,
                                                         Operator__c,
                                                         Value__c,
                                                         SL_View__c,
                                                         SL_View__r.Advanced_Filter__c 
                                                    FROM SL_View_Filter__c 
                                                   WHERE SL_View__c =:strVIewId 
                                                     AND SL_View__r.Implementation__c =:strImpId 
                                                     AND SL_View__r.Implementation_Type__c = 'Target'])
        {
            if(cb_filters == '' || cb_filters == null)
            {
                cb_filters =  objFiltersTemplate.Type__c +'___'
                            + objFiltersTemplate.Field__c+'___'
                            + objFiltersTemplate.Operator__c+'___'
                            + (objFiltersTemplate.Value__c==null ? '' : objFiltersTemplate.Value__c) + '___';
            }
            else
            {
                cb_filters =  cb_filters+'##' + 
                              objFiltersTemplate.Type__c + '___'
                            + objFiltersTemplate.Field__c + '___'
                            + objFiltersTemplate.Operator__c+'___'
                            + (objFiltersTemplate.Value__c == null ? '' : objFiltersTemplate.Value__c) + '___';
            }
            
            cb_advFilters = objFiltersTemplate.SL_View__r.Advanced_Filter__c;
        }
            
        if (cb_advFilters!=null && cb_advFilters.trim().length()!=0)
        {
            filterCompiler.Initialize(cb_filters, cb_advFilters, targetObjectName);
            filterCompiler.targetObject = targetObjectName;
            filterCompiler.recordId = strParentId;
            String soql = filterCompiler.SOQL;
            
            if (soql!=null && soql.trim().length()!=0)
            {
                filter += ' AND ' + soql;
            }
        }
        
        strQuery += ' ' + filter;
        return strQuery;
        
    }
    */
    
    /*-------------------------------------------------------------------------- End - Report Methods -----------------------------------------------------------------*/
    
}