/**
* \arg ClassName      : SL_PipelineManager
* \arg JIRATicket     : HL-16
* \arg CreatedOn      : 4/JUNE/2014
* \arg LastModifiedOn : 4/JUNE/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : This is controller class for SL_PipelineManager page.
*/
public with sharing class SL_PipelineManager {
    /* Start Variables */
    public String strOpportunityOption                      {   get; set;    } //!< variable for opportunity option.
    public String strEngagementOption                       {   get; set;    } //!< variable for engagement option.
    public String strOpportunityOpenOrClosed                {   get; set;    } //!< variable for Opportunity Open Or Closed option.
    public String strEngagementOpenOrClosed                 {   get; set;    } //!< variable for Engagement Open Or Closed option.
    public String dtOpportunityFromDate                     {   get; set;    } //!< variable for Opportunity From date.
    public String dtOpportunityToDate                       {   get; set;    } //!< variable for Opportunity To date.
    public String dtEngagementFromDate                      {   get; set;    } //!< variable for Enagagement From date.
    public String dtEngagementToDate                        {   get; set;    } //!< variable for Enagagement To date.
    public List<String> strOpportunityOffice                {   get; set;    } //!< variable for Opportunity Office option.
    public List<String> strEngagementOffice                 {   get; set;    } //!< variable for Enagagement Office option.
    public String strOpportunityIndustryGroup               {   get; set;    } //!< variable for Opportunity Industry Group option
    public String strEngagementIndustryGroup                {   get; set;    } //!< variable for Enagagement Industry Group option
    public String strOpportunityStage                       {   get; set;    } //!< variable for Opportunity Stage option
    public String strEngagementStage                        {   get; set;    } //!< variable for Engagement Stage Option
    public String strEngagementRecordType                   {   get; set;    } //!< variable for Engagement Record Type Option
    public String strOpportunityStaffRole                   {   get; set;    }
    public String strEngagementStaffRole                    {   get; set;    }
    public String strOpportunityStaffIndustry               {   get; set;    }
    public String strOpportunityStaffProduct                {   get; set;    }
    public String strEngagementStaffIndustry                {   get; set;    }
    public String strEngagementStaffProduct                 {   get; set;    }
    public String dtStartDate                               {   get; set;    }
    public String dtEndDate                                 {   get; set;    }
    
    public SL_Paginator opportunityRecords                  {   get; set;    } //!< to display the opportunity records.
    public SL_Paginator engagementRecords                   {   get; set;    } //!< to display the engagement records.
    public List<ColumnWrapper> lstColumnWrapperOpportunity  {   get; set;    } //!< fields api name and lable for opportunity.
    public List<ColumnWrapper> lstColumnWrapperEngagement   {   get; set;    } //!< fields api name and lable for engagement.
    public String OpportunityColumnsJSON {get{return JSON.serialize(lstColumnWrapperOpportunity);}}
    public String EngagementColumnsJSON {get{return JSON.serialize(lstColumnWrapperEngagement);}}
    public Boolean enableOpportunity                        {   get; set;    }
    public Boolean enableEngagement                         {   get; set;    }
    
    private String strCSVOpportunityFields = '';
    private String strCSVEngagementFields = '';
    private Set<Id> setSobjectIdOpportunity;
    private Set<Id> setSobjectIdEngagement;
    private static final Integer PAGE_SIZE = 50;
    private static Map<String, Schema.SObjectType> mapGlobalDescribe = Schema.getGlobalDescribe();
    private static Map<String, Map<String, Schema.SObjectField>> mapSobjectNameToFieldsDescription;
    private Pipeline_Column_Selection__c objPCS;
    
    public String CustomFilter              {get {return 'AND RecordTypeId = \'' + HL_Utility.GetRecordTypeId('Contact', 'Houlihan Employee') + '\' AND Status__c = \'Active\'';} set;}
    public String SelectedStaffIdOpps       {   get; set;    }
    public String SelectedStaffNameOpps     {   get; set;    }
    public String SelectedStaffIdEng        {   get; set;    }
    public String SelectedStaffNameEng      {   get; set;    }
    public String SelectedEngagementNumber  {   get; set;    }
    public Boolean IsAcct                   {   get; set;    }
    public Boolean IsCAO                    {   get; set;    }
    public Boolean IsSysAdmin               {   get; set;    }
    public Boolean IsAdmin                  {   get; set;    }
    public Boolean IsIndHead                {   get; set;    }
    public Boolean isDisabled               {   get; set;    }
    public Boolean IncludeReviewerRoles     {   get; set;    }
    public string PageTitle                 {   get; set;    }
    public string PageOppStyle              {   get; set;    }
    public string PageEngStyle              {   get; set;    }
    public string DropDownStyle             {   get; set;    }
    public string strLOB                    {   get; set;    }
    public String IndustryGroup         {   get{if (!String.isBlank(strEngagementIndustryGroup)) return strEngagementIndustryGroup; else if (!String.isBlank(strOpportunityIndustryGroup)) return strOpportunityIndustryGroup; return 'All';}}
    public String StaffId               {   get{if (!String.isBlank(SelectedStaffIdEng)) return SelectedStaffIdEng; else if (!String.isBlank(SelectedStaffIdOpps)) return SelectedStaffIdOpps; return staffId;} set;}
    public String StaffIndustry         {   get{if (!String.isBlank(strEngagementStaffIndustry)) return strEngagementStaffIndustry; else if (!String.isBlank(strOpportunityStaffIndustry)) return strOpportunityStaffIndustry; return 'All';}}
    public String StaffProduct          {   get{if (!String.isBlank(strEngagementStaffProduct)) return strEngagementStaffProduct; else if (!String.isBlank(strOpportunityStaffProduct)) return strOpportunityStaffProduct; return 'All';}}
    private string PageType {get{return HL_PageUtility.GetParameter('pagetype');}}
    public String BacklogReport         {   get{
        if (String.isBlank(backlogReport)) {
            List<HL_Report_Link__c> reportList = [SELECT Report_Link_URL__c FROM HL_Report_Link__c WHERE Display_Name__c = 'Backlog Report'];
            if (reportList.size() > 0)
                backlogReport = reportList[0].Report_Link_URL__c;
        }
        return backlogReport;
    } set;
                                        }
    /* End Variables */
    static {
        mapSobjectNameToFieldsDescription =  new Map<String, Map<String, Schema.SObjectField>>();
        mapSobjectNameToFieldsDescription.put('Opportunity__c', Schema.getGlobalDescribe().get('Opportunity__c').getDescribe().fields.getMap());
        mapSobjectNameToFieldsDescription.put('Engagement__c', Schema.getGlobalDescribe().get('Engagement__c').getDescribe().fields.getMap());
    }
    
    /* Start - Constructor */
    public SL_PipelineManager() {
        try {
            String direction = 'ASC';
            Boolean isPDF = HL_PageUtility.GetParameter('pdf') == 'true';
            IncludeReviewerRoles = false;
            objPCS = getPCS();
            initialization();
            
            if (objPCS.Opportunity_Columns__c != null)
                lstColumnWrapperOpportunity = getColumnWrapper(objPCS.Opportunity_Columns__c.split(','), 'Opportunity__c');
            if (objPCS.Engagement_Columns__c != null)
                lstColumnWrapperEngagement = getColumnWrapper(objPCS.Engagement_Columns__c.split(','), 'Engagement__c');
            
            if (PageType == 'opp') {
                enableOpportunity = true;
                String strOppField = (lstColumnWrapperOpportunity[0].isSortable) ? lstColumnWrapperOpportunity[0].strFieldAPI : 'Id';
                if (!String.isBlank(objPCS.Opportunity_Sort_Field__c)) {
                    strOppField = objPCS.Opportunity_Sort_Field__c;
                    direction = objPCS.Opportunity_Sort_Direction__c;
                }
            }
            else {
                enableEngagement = true;
                String strEngField = (lstColumnWrapperEngagement[0].isSortable) ? lstColumnWrapperEngagement[0].strFieldAPI : 'Id';
                if (!String.isBlank(objPCS.Engagement_Sort_Field__c)) {
                    strEngField =  objPCS.Engagement_Sort_Field__c;
                    direction = objPCS.Engagement_Sort_Direction__c;
                }
            }
            searchRecords(false);
        }
        catch (Exception e) {
            system.debug('======Exception======' + e.getMessage() + '======Linenumber======' + e.getlineNumber());
        }
    }
    /* End - Constructor */
    
    
    
    /* Start - Wrapper class for columns*/
    public class ColumnWrapper {
        public String strFieldAPI               {   get; set;    }
        public String strFieldLabel             {   get; set;    }
        public Boolean isSortable               {   get; set;    }
        public String strFieldType              {   get; set;    }
        public Boolean isFrozen                 {   get; set;   }
        public integer width                    {   get; set;   }
        public string align                     {   get; set;   }
        
        public ColumnWrapper(String fieldAPI, String fieldLabel, Boolean isSortable, String fieldType, Boolean isFrozen, Integer width, String align) {
            
            this.strFieldAPI = fieldAPI;
            this.strFieldLabel = fieldLabel;
            this.isSortable = isSortable;
            this.strFieldType = fieldType;
            this.isFrozen = isFrozen;
            this.width = width;
            this.align = align;
        }
    }
    /* End - Wrapper class for columns*/
    
    /*
@MethodName : intilization.
@param      : NA.
@Description: initialize all global variables of the class.
*/
    private void initialization() {
        enableOpportunity = enableEngagement = false;
        
        SetFilters();
        
        if (PageType == 'opp') {
            PageTitle = 'Opportunity Manager';
            PageOppStyle = 'display:initial;';
            PageEngStyle = 'display:none;';
        }
        else {
            PageTitle = 'Engagement Manager';
            PageOppStyle = 'display:none;';
            PageEngStyle = 'display:initial;';
        }
        
        Date dtStart = Date.today().addDays(-30);
        Date dtEnd = Date.today();
        dtOpportunityFromDate = dtEngagementFromDate = dtStart.month() + '/' + dtStart.day() + '/' + dtStart.year();
        dtOpportunityToDate = dtEngagementToDate = dtEnd.month() + '/' + dtEnd.day() + '/' + dtEnd.year();
        
        setSobjectIdOpportunity = new Set<Id>();
        setSobjectIdEngagement = new Set<Id>();
        lstColumnWrapperOpportunity = new List<ColumnWrapper>();
        lstColumnWrapperEngagement = new List<ColumnWrapper>();
        isDisabled = true;
        
        //Access Role
        IsCAO = HL_Utility.HasProfile('CAO');
        IsAcct = HL_Utility.HasProfile('Accounting User');
        IsSysAdmin = HL_Utility.HasProfile('System Administrator');
        
        Contact[] ContactInfo = [Select Line_Of_Business__c, Pipeline_Filter_Set__c, User__c FROM Contact WHERE User__c = : UserInfo.getUserId() LIMIT 1];
        //Contact[] StaffTypeAdmin = [Select Pipeline_Filter_Set__c, User__c FROM Contact WHERE User__c = : UserInfo.getUserId() LIMIT 1];
        IsAdmin = (ContactInfo != null && ContactInfo.size() > 0 && ContactInfo[0].Pipeline_Filter_Set__c == 'ADMIN');
        IsIndHead = (ContactInfo != null && ContactInfo.size() > 0 && ContactInfo[0].Pipeline_Filter_Set__c == 'INDUSTRY HEAD');
        strLOB = ContactInfo[0].Line_Of_Business__c;
        StaffId = ContactInfo[0].Id;
        
        //Hide Controls if NOT a CAO user or Sys Admin or LOB Admin
        if ( IsCAO || IsSysAdmin || IsAdmin )
            DropDownStyle = '';
        else
            DropDownStyle = 'display:none;';
    }
    /* End */
    
    private void SetFilters() {
        setShowRecordsSelection(PageType);
        setIndustryGroupSelection(PageType);
        setStageSelection(PageType);
        setStatusSelection(PageType);
        setOfficeSelection(PageType);
        setRecordTypeSelection(PageType);
        setStaffNameSelection(PageType);
        setStaffRoleSelection(PageType);
        setStaffIndustrySelection(PageType);
        setStaffProductSelection(PageType);
        IncludeReviewerRoles = objPCS.Include_Reviewer_Roles__c;
    }
    
    /*
@MethodName : getPCS.
@param      : NA.
@Description: to insert fields of selected from the picklist in the Pipeline_Column_Selection__c.
*/
    private Pipeline_Column_Selection__c getPCS() {
        List<Pipeline_Column_Selection__c> lstPCS = [SELECT Id,
                                                     Engagement_Columns__c,
                                                     Opportunity_Columns__c,
                                                     Include_Reviewer_Roles__c,
                                                     Engagement_Industry_Filter__c,
                                                     Engagement_Office_Filter__c,
                                                     Engagement_Record_Type_Filter__c,
                                                     Engagement_Show_Records_Filter__c,
                                                     Engagement_Sort_Field__c,
                                                     Engagement_Sort_Direction__c,
                                                     Engagement_Staff_Id_Filter__c,
                                                     Engagement_Staff_Industry_Filter__c,
                                                     Engagement_Staff_Product_Filter__c,
                                                     Engagement_Staff_Name_Filter__c,
                                                     Engagement_Staff_Role_Filter__c,
                                                     Engagement_Stage_Filter__c,
                                                     Engagement_Status_Filter__c,
                                                     Opportunity_Industry_Filter__c,
                                                     Opportunity_Office_Filter__c,
                                                     Opportunity_Show_Records_Filter__c,
                                                     Opportunity_Sort_Field__c,
                                                     Opportunity_Sort_Direction__c,
                                                     Opportunity_Staff_Industry_Filter__c,
                                                     Opportunity_Staff_Product_Filter__c,
                                                     Opportunity_Staff_Id_Filter__c,
                                                     Opportunity_Staff_Name_Filter__c,
                                                     Opportunity_Staff_Role_Filter__c,
                                                     Opportunity_Stage_Filter__c,
                                                     Opportunity_Status_Filter__c
                                                     FROM Pipeline_Column_Selection__c
                                                     WHERE User__c = : Userinfo.getUserId() LIMIT 1];
        if (lstPCS.isEmpty()) {
            objPCS = GetDefaultPCS(mapGlobalDescribe, strLOB);
            objPCS.Opportunity_Office_Filter__c = 'All';
            objPCS.Engagement_Office_Filter__c = 'All';
            return objPCS;
        }
        else
            return lstPCS[0];
    }
    /* End */
    
    /*
@MethodName : getOpportunityOptions.
@param      : NA.
@Description: to get the options to display the opportunities records.
*/
    public List<SelectOption> getOpportunityOptions() {
        return getDealOptions('Opportunities', 'Opportunity__c');
    }
    /* End */
    
    /*
@MethodName : getEngagementOptions.
@param      : NA.
@Description: to get the options to display the engagements records.
*/
    public List<SelectOption> getEngagementOptions() {
        return getDealOptions('Engagements', 'Engagement__c');
    }
    /* End */
    
    private List<SelectOption> getDealOptions(String dealType, String keyField) {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Team' + dealType, 'My ' + dealType));
        options.add(new SelectOption('Industry' + dealType, 'My Industry ' + dealType));
        if (IsIndHead)
            options.add(new SelectOption('AllIndustry' + dealType, 'All Industry ' + dealType));
        If(IsCAO || IsSysAdmin || IsAdmin) {
            options.add(new SelectOption('All' + dealType, 'All ' + dealType));
            for (SelectOption objOptions : getPicklistValues(keyField, 'Line_of_Business__c'))
                options.add(new SelectOption(objOptions.getValue(), objOptions.getLabel() + ' ' + dealType));
        }
        return options;
    }
    public List<SelectOption> getStaffRoleOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));
        for (Staff_Role__c sr : [SELECT Display_Name__c FROM Staff_Role__c ORDER BY Display_Name__c])
            options.add(new SelectOption(sr.Id, sr.Display_Name__c));
        return options;
    }
    
    /*
@MethodName : getOpenOrClosed.
@param      : NA.
@Description: to get the options to display the Open Or Close options.
*/
    public List<SelectOption> getOpenOrClosed() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));
        options.add(new SelectOption('Active', 'Active'));
        options.add(new SelectOption('Hold', 'Hold'));
        options.add(new SelectOption('ActiveHold', 'Active & On Hold'));
        return options;
    }
    
    public List<SelectOption> getOpenOrClosedEng() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));
        options.add(new SelectOption('Active', 'Active'));
        options.add(new SelectOption('Hold', 'Hold'));
        options.add(new SelectOption('ActiveHold', 'Active & On Hold'));
        options.add(new SelectOption('Closed', 'Closed'));
        options.add(new SelectOption('Dead', 'Dead'));
        return options;
    }
    /* End */
    
    /*
@MethodName : getOfficeList.
@param      : NA.
@Description: to get the options to display the Office options.
*/
    public List<SelectOption> getOfficeList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));
        for (SelectOption objOptions : getPicklistValues('Opportunity__c', 'Primary_Office__c'))  //Buidling the list off of the Opportunity object...should the be same list used for Engagement.  If they end up being different we will have to create sperate lists for opportunity and engagement.
            options.add(new SelectOption(objOptions.getValue(), objOptions.getLabel()));
        return options;
    }
    /* End */
    
    /*
@MethodName : getOpportunityIndustryGroupList.
@param      : NA.
@Description: to get the options to display the Industry Group options.
*/
    public List<SelectOption> getOpportunityIndustryGroupList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));
        for (SelectOption objOptions : getPicklistValues('Opportunity__c', 'Industry_Group__c'))
            options.add(new SelectOption(objOptions.getValue(), objOptions.getLabel()));
        return options;
    }
    /* End */
    
    /*
@MethodName : getEngagementIndustryGroupList.
@param      : NA.
@Description: to get the options to display the Industry Group options.
*/
    public List<SelectOption> getEngagementIndustryGroupList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));
        for (SelectOption objOptions : getPicklistValues('Engagement__c', 'Industry_Group__c'))
            options.add(new SelectOption(objOptions.getValue(), objOptions.getLabel()));
        return options;
    }
    /* End */
    
    
    /*
@MethodName : getOpportunityStageList.
@param      : NA.
@Description: to get the options to display the Stage options for Opportunities.
*/
    public List<SelectOption> getOpportunityStageList() {
        integer indexEngagedValue = 0;
        integer indexCount = 0;
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));
        for (SelectOption objOptions : getPicklistValues('Opportunity__c', 'Stage__c')) {
            string itemValue = objOptions.getValue();
            if (itemValue != 'Dead' ) { //Do not add the value for Dead.  The would be already filtered out based on the status selected
                options.add(new SelectOption(itemValue, objOptions.getLabel()));
                indexCount++;
                if (objOptions.getLabel() == 'Engaged')
                    indexEngagedValue = indexCount;
            }
            
        }
        options.remove(indexEngagedValue);  //Remove 'Engaged' from the filter list.  Engaged opportunities will be found in the Engagement Object
        return options;
    }
    /* End */
    
    /*
@MethodName : getEngagementStageList.
@param      : NA.
@Description: to get the options to display the Stage options for Engagements.
*/
    public List<SelectOption> getEngagementStageList() {
        List<SelectOption> options = new List<SelectOption>();
        for (SelectOption objOptions : getPicklistValues('Engagement__c', 'Stage__c')) {
            string itemValue = objOptions.getValue();
            if (itemValue != 'Closed' && itemValue != 'Dead' ) //Do not add the values for Closed or Dead.  The would be already filtered out based on the status selected
                options.add(new SelectOption(itemValue, objOptions.getLabel()));
        }
        options.sort();
        options.add(0, new SelectOption('All', 'All'));
        
        return options;
    }
    /* End */
    
    /*
@MethodName : getEngagementRecordTypeList.
@param      : NA.
@Description: to get the options to display the Record Type options for Engagements.
*/
    public List<SelectOption> getEngagementRecordTypeList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));
        
        for (Schema.RecordTypeInfo rt : Engagement__c.SObjectType.getDescribe().getRecordTypeInfos()) {
            if (rt.GetName() <> 'Master')
                options.add(new SelectOption(rt.getName(), rt.getName()));
        }
        
        return options;
    }
    
    /*
@MethodName : getContactIndustryGroupList.
@param      : NA.
@Description: to get the options to display the Staff Industry Group options.
*/
    public List<SelectOption> getStaffIndustryList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));
        for (SelectOption objOptions : getPicklistValues('Contact', 'Industry_Group__c'))
            options.add(new SelectOption(objOptions.getValue(), objOptions.getLabel()));
        return options;
    }
    /* End */
    
    /*
@MethodName : getStaffProductGroupList.
@param      : NA.
@Description: to get the options to display the Staff Product Speciality Group options.
*/
    public List<SelectOption> getStaffProductList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));
        for (SelectOption objOptions : getPicklistValues('Contact', 'Product_Specialty__c'))
            options.add(new SelectOption(objOptions.getValue(), objOptions.getLabel()));
        return options;
    }
    /* End */
    
    
    /* End */
    
    /*
@MethodName : getColumnWrapper.
@param      : List<SelectOption> optionsSelected and sobject name.
@Description: to get the slected field to display on page.
*/
    private List<ColumnWrapper> getColumnWrapper(List<String> lstSelectedFields, String SobjectName) {
        Map<String, Pipeline_Column_Setting__c> pipelineSettings = Pipeline_Column_Setting__c.getAll();
        List<ColumnWrapper> lstColumnWrapper = new List<ColumnWrapper>();
        Set<String> frozenSet = new Set<String>();
        Set<String> oppFields = new Set<String>();
        Set<String> engFields = new Set<String>();
        integer colIndex = 0;
        Schema.FieldSet availFieldSet = GetPipelineFS(mapGlobalDescribe, sObjectName, 'Available_Pipeline_Columns_', strLOB);
        Schema.FieldSet frozenFieldSet = GetPipelineFS(mapGlobalDescribe, sObjectName, 'Frozen_Pipeline_Columns_', strLOB);
        Map<String, String> mapAPINamesToLabel = new Map<String, String>();
        String fieldAPI, fieldName, fieldLabel, align;
        Boolean isSortable;
        Integer fieldWidth;
        Pipeline_Column_Setting__c colSetting;
        Set<String> noSortFields = new Set<String> {'z_Pipeline_Manager__c', 'z_Pipeline_Principal__c'};
            for (Schema.FieldSetMember fsm : availFieldSet.getFields()) {
                fieldAPI = fsm.getFieldPath();
                colSetting = pipelineSettings.get(fieldAPI);
                if (colSetting != null)
                    mapAPINamesToLabel.put(fieldAPI, colSetting.Label__c);
                else
                    mapAPINamesToLabel.put(fieldAPI, 'Missing Setting');
            }
        //Handle the Frozen Columns
        for (Schema.FieldSetMember fc : frozenFieldSet.getFields()) {
            fieldAPI = fc.getFieldPath();
            frozenSet.add(fieldAPI);
            lstSelectedFields.add(colIndex++, fieldAPI);
            colSetting = pipelineSettings.get(fieldAPI);
            if (colSetting != null)
                mapAPINamesToLabel.put(fieldAPI, colSetting.Label__c);
            else
                mapAPINamesToLabel.put(fieldAPI, 'Missing Setting');
        }
        
        for (String strFieldAPI : lstSelectedFields) {
            colSetting = pipelineSettings.get(strFieldAPI.trim());
            if (colSetting != null) {
                fieldWidth = (Integer)colSetting.Width__c;
                align = colSetting.Alignment__c;
                fieldLabel = colSetting.Label__c;
            }
            else {
                fieldWidth = 420;
                align = 'center';
                fieldLabel = 'Missing';
            }
            if (mapAPINamesToLabel.containsKey(strFieldAPI)) {
                if (mapSobjectNameToFieldsDescription.get(SobjectName).containsKey(strFieldAPI.trim())) {
                    Schema.SObjectField field = mapSobjectNameToFieldsDescription.get(SobjectName).get(strFieldAPI.trim());
                    fieldName = field.getDescribe().getName();
                    
                    isSortable = field.getDescribe().isSortable() && !noSortFields.contains(fieldName);
                    if (field.getDescribe().isAccessible() && mapAPINamesToLabel.containsKey(strFieldAPI)) {
                        if (mapGlobalDescribe.get(SobjectName).getDescribe().fields.getMap().get(strFieldAPI).getDescribe().getType() == Schema.DisplayType.REFERENCE)
                            lstColumnWrapper.add(new ColumnWrapper(fieldName, fieldLabel, isSortable, 'reference', frozenSet.contains(fieldName), fieldWidth, align));
                        else if (fieldName == 'Name')
                            lstColumnWrapper.add(new ColumnWrapper(fieldName, fieldLabel, isSortable, 'name', frozenSet.contains(fieldName), fieldWidth, align));
                        else
                            lstColumnWrapper.add(new ColumnWrapper(fieldName, fieldLabel, isSortable, 'other', frozenSet.contains(fieldName), fieldWidth, align));
                        
                        if (SobjectName == 'Opportunity__c') {
                            if (!oppFields.contains(fieldName)) {
                                strCSVOpportunityFields += (strCSVOpportunityFields == '') ? fieldName : ', ' + fieldName;
                                oppFields.add(fieldName);
                            }
                        }
                        else {
                            if (!engFields.contains(fieldName)) {
                                strCSVEngagementFields += (strCSVEngagementFields == '') ? fieldName : ', ' + fieldName;
                                engFields.add(fieldName);
                            }
                        }
                    }
                    
                }
                else if (strFieldAPI.contains('__r.')) {
                    String strChildFieldAPIName = strFieldAPI.split('r.')[0].replace('__', '__c');
                    String strParentFieldAPIName = strFieldAPI.split('r.')[1];
                    
                    if (strParentFieldAPIName != '' && mapGlobalDescribe.get(SobjectName).getDescribe().fields.getMap().containsKey(strChildFieldAPIName.trim())) {
                        Schema.SObjectField childField = mapGlobalDescribe.get(SobjectName).getDescribe().fields.getMap().get(strChildFieldAPIName.trim());
                        String parentObjectName = (!childField.getDescribe().getReferenceTo().isEmpty()) ? String.valueOf(childField.getDescribe().getReferenceTo()[0]) : '';
                        if (mapGlobalDescribe.containsKey(parentObjectName) && mapGlobalDescribe.get(parentObjectName).getDescribe().fields.getMap().containsKey(strParentFieldAPIName.trim())) {
                            Schema.SObjectField parentField = mapGlobalDescribe.get(parentObjectName).getDescribe().fields.getMap().get(strParentFieldAPIName.trim());
                            if (mapAPINamesToLabel.containsKey(strFieldAPI) && childField.getDescribe().isAccessible() && parentField.getDescribe().isAccessible()) {
                                
                                lstColumnWrapper.add(new ColumnWrapper(strFieldAPI, mapAPINamesToLabel.get(strFieldAPI), true, 'reference', frozenSet.contains(fieldName), fieldWidth, align));
                                
                                if (SobjectName == 'Opportunity__c') {
                                    if (!oppFields.contains(strFieldAPI)) {
                                        strCSVOpportunityFields += (strCSVOpportunityFields == '') ? strFieldAPI : ', ' + strFieldAPI;
                                        oppFields.add(strFieldAPI);
                                    }
                                }
                                else {
                                    if (!engFields.contains(strFieldAPI)) {
                                        strCSVEngagementFields += (strCSVEngagementFields == '') ? strFieldAPI : ', ' + strFieldAPI;
                                        engFields.add(strFieldAPI);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        //Additional Fields for Security and Related Data Pulls
        if (SobjectName == 'Opportunity__c')
            strCSVOpportunityFields += ', Line_of_Business__c, Last_Opportunity_Comment_Any__c, (SELECT Role__c, Contact__r.Name FROM Opportunity_Internal_Teams__r WHERE Staff_Role__r.Name IN (\'Manager\', \'Principal\') AND End_Date__c = null)';
        else
            strCSVEngagementFields += ', Line_of_Business__c, Last_Engagement_Comment_Any__c, (SELECT Role__c, Contact__r.Name FROM Engagement_Teams__r WHERE Staff_Role__r.Name IN (\'Manager\', \'Principal\') AND End_Date__c = null)';
        
        return lstColumnWrapper;
    }
    /* End */
    
    /*
@MethodName : prepareWhereClause.
@param      : Sobject Name.
@Description: to prepare the where clause as per the filters.
*/
    private String prepareWhereClause(String sObjectName) {
        String strWhereClause = '';
        Boolean allOffices = false;
        String officeClause = '';
        Id opp_DelId = Schema.SObjectType.Opportunity__c.getRecordTypeInfosByName().get('OPP DEL').getRecordTypeId();
        system.debug(LoggingLevel.INFO, '++++opp_DelId' + opp_DelId);
        
        if (sObjectName == 'Opportunity__c') {
            for (string o : strOpportunityOffice) {
                if (o == 'All')
                    allOffices = true;
                else
                    officeClause += '\'' + o + '\',';
            }
            officeClause = officeClause.removeEnd(',');
            strWhereClause += (strOpportunityOption != 'TeamOpportunities' && strOpportunityOption != 'AllOpportunities' && strOpportunityOption != 'IndustryOpportunities' && strOpportunityOption != 'AllIndustryOpportunities' ) ? ' Line_of_Business__c = \'' + strOpportunityOption + '\' AND ' : '';
            strWhereClause += (strOpportunityOption == 'AllOpportunities' || strOpportunityOption == 'IndustryOpportunities') ? ' Id != null AND ' : '';
            if (strOpportunityOption == 'IndustryOpportunities' || strOpportunityOption == 'AllIndustryOpportunities') { //determine the current user's industry groups based on their public groups.
                if (strLOB == 'CF') {
                    string searchTerms = findIndustryGroups();
                    if (String.isBlank(searchTerms))
                        searchTerms = 'N/A';
                    strWhereClause += 'Industry_Group_REPORTING__c in (' + searchTerms + ') AND ';
                }
                
            }
            else   //filter by the selected industry group filter
                strWhereClause += (strOpportunityIndustryGroup != 'All') ? ' Industry_Group__c = \'' + strOpportunityIndustryGroup  + '\' AND ' : '';
            strWhereClause += (!allOffices) ? ' Primary_Office__c IN (' + officeClause + ') AND ' : '';
            strWhereClause += (strOpportunityStage != 'All') ? ' Stage__c = \'' + strOpportunityStage  + '\' AND ' : '';
            strWhereClause += ' Stage__c != \'Engaged\' AND Converted_to_Engagement__c = false AND RecordTypeId != \''+ opp_DelId + '\' AND '; //Don't show any opps with a stage of Engaged/Converted to an Engagement...those will show up in the Engagement section
            strWhereClause += (strOpportunityOpenOrClosed == 'Active') ? ' Status__c = \'Active\' '
                : (strOpportunityOpenOrClosed == 'Hold') ? ' Status__c = \'Hold\' '
                    : (strOpportunityOpenOrClosed == 'ActiveHold') ? ' Status__c in (\'Active\',\'Hold\') '
                        : (strOpportunityOpenOrClosed == 'Closed') ? ' Status__c = \'Closed\'' : '';
            if (strWhereClause.endsWith('AND '))
                strWhereClause = strWhereClause.removeEnd('AND ');
        }
        else {   //If Engagement Record
            for (string o : strEngagementOffice) {
                if (o == 'All')
                    allOffices = true;
                else
                    officeClause += '\'' + o + '\',';
            }
            officeClause = officeClause.removeEnd(',');
            strWhereClause += (strEngagementOption != 'TeamEngagements' && strEngagementOption != 'AllEngagements' && strEngagementOption != 'IndustryEngagements' && strEngagementOption != 'AllIndustryEngagements' ) ? ' Line_of_Business__c = \'' + strEngagementOption + '\' AND ' : '';
            strWhereClause += (strEngagementOption == 'AllEngagements' || strEngagementOption == 'IndustryEngagements' ) ? ' Id != null AND ' : '';
            if (strEngagementOption == 'IndustryEngagements' || strEngagementOption == 'AllIndustryEngagements') {
                if (strLOB == 'CF') {
                    string searchTerms = findIndustryGroups();
                    if (String.isBlank(searchTerms))
                        searchTerms = 'N/A';
                    strWhereClause += 'Industry_Group_REPORTING__c in (' + searchTerms + ') AND ';
                }
            }
            else   //filter by the selected industry group filter
                strWhereClause += (strEngagementIndustryGroup != 'All') ? ' Industry_Group__c = \'' + strEngagementIndustryGroup  + '\' AND ' : '';
            strWhereClause += (!allOffices) ? ' Primary_Office__c IN (' + officeClause + ') AND ' : '';
            strWhereClause += (strEngagementStage != 'All') ? ' Stage__c = \'' + strEngagementStage  + '\' AND ' : '';
            strWhereClause += (strEngagementRecordType != 'All') ? ' RecordType.Name = \'' + strEngagementRecordType  + '\' AND ' : '';
            strWhereClause += (strEngagementOpenOrClosed == 'All') ? ' (Status__c in (\'Active\',\'Hold\') OR (Status__c in (\'Dead\',\'Closed\') AND Accounting_Status__c = \'Open\'))'
                : (strEngagementOpenOrClosed == 'Active') ? ' Status__c = \'Active\''
                    : (strEngagementOpenOrClosed == 'Hold') ? ' Status__c = \'Hold\''
                        : (strEngagementOpenOrClosed == 'ActiveHold') ? ' Status__c in (\'Active\',\'Hold\')'
                            : (strEngagementOpenOrClosed == 'Closed') ? ' Status__c = \'Closed\' AND Accounting_Status__c = \'Open\'' 
                                : (strEngagementOpenOrClosed == 'Dead') ? ' Status__c = \'Dead\' AND Accounting_Status__c = \'Open\'' : '';
            
            
            if (!String.isBlank(SelectedEngagementNumber)) {
                strWhereClause += ' AND Engagement_Number__c = \'' + SelectedEngagementNumber + '\'';
            }
            
        }
        
        if (strWhereClause.endsWith('AND '))
            strWhereClause = strWhereClause.removeEnd('AND ');
        
        return strWhereClause;
    }
    /* End */
    
    /*
@MethodName : findIndustryGroups.
@param      : NA
@Description: build a list of industry groups the current user belongs to for use in the Where Clause of the search
*/
    private String findIndustryGroups() {
        string srch = '';
        List<Group> grpList = [SELECT Name
                               FROM Group
                               WHERE Name like '%Industry%' AND
                               id in (SELECT GroupId FROM GroupMember WHERE UserOrGroupId = :Userinfo.getUserId())];
        if (grpList.size() > 0) {
            
            for (Group grp : grpList) {
                string currName = grp.Name;
                currName = currName.substring(9);
                if (currName == 'EP')
                    currName = 'E&P';
                if (currName == 'MT')
                    currName = 'M&T';
                srch += '\'' + currName + '\',';
            }
            
            srch = srch.substring(0, srch.length() - 1); //Remove the closing comma from the industry list
        }
        
        return srch;
    }
    /* End */
    
    /*
@MethodName : getSobjectRecordIdToQuery.
@param      : String sObjectName and String relationshipName
@Description: to get the sobject ids for query.
*/
    private Set<Id> getSobjectRecordIdToQuery(String sObjectName, String relationshipName, String staffRole, String staffIndustry, String staffProduct) {
        String query;
        
        Set<Id> setSobjectIds = new Set<Id>();
        
        if (!String.isBlank(SelectedStaffIdEng) && relationshipName == 'Engagement__c' && strEngagementOption != 'TeamEngagements' && strEngagementOption != 'IndustryEngagements' ) //Check to see if we are querying Engagements for a specific user and not the current user
            query = 'SELECT Id, ' + relationshipName + ' FROM ' + sObjectName + ' WHERE Contact__r.Id =\'' + SelectedStaffIdEng + '\' AND End_Date__c = null';
        else if (!String.isBlank(SelectedStaffIdOpps) && relationshipName == 'Opportunity__c' && strOpportunityOption != 'TeamOpportunities' && strOpportunityOption != 'IndustryOpportunities' ) //If not, check to see if we are looking for Opportunties for a specific user and not the current user
            query = 'SELECT Id, ' + relationshipName + ' FROM ' + sObjectName + ' WHERE Contact__r.Id =\'' + SelectedStaffIdOpps + '\' AND End_Date__c = null';
        else {
            if (((!String.isBlank(staffIndustry) && staffIndustry != 'All') || (!String.isBlank(staffProduct) && staffProduct != 'All')) && ((relationshipName == 'Opportunity__c' && strOpportunityOption != 'TeamOpportunities' && strOpportunityOption != 'IndustryOpportunities') || (relationshipName == 'Engagement__c' && strEngagementOption != 'TeamEngagements' && strEngagementOption != 'IndustryEngagements')))
                query = 'SELECT Id, ' + relationshipName + ' FROM ' + sObjectName + ' WHERE End_Date__c = null';
            else {
                if (strLOB == 'FVA' && IsIndHead && !IsAdmin && (strOpportunityOption == 'AllIndustryOpportunities' || strEngagementOption == 'AllIndustryEngagements'))
                    query = 'SELECT Id, ' + relationshipName + ' FROM ' + sObjectName + ' WHERE End_Date__c = null';
                else
                    query = 'SELECT Id, ' + relationshipName + ' FROM ' + sObjectName + ' WHERE Contact__r.User__c =\'' + Userinfo.getUserId() + '\' AND End_Date__c = null';
            }
        }
        
        if (!String.isBlank(staffRole) && staffRole != 'All')
            query += ' AND Staff_Role__c = \'' + staffRole + '\'';
        else if(!IncludeReviewerRoles)
            query += ' AND Staff_Role__r.Name <> \'Prelim Reviewer\' AND Staff_Role__r.Name <> \'Reviewer\' AND Staff_Role__r.Name <> \'Final Reviewer\'';
        
        if (!String.isBlank(staffIndustry) && staffIndustry != 'All' )
            query += ' AND ' + relationshipName.replace('__c', '__r') + '.Active__c = true AND Contact__r.Industry_Group__c = \'' + staffIndustry + '\'';
        
        if ((!String.isBlank(staffProduct) && staffProduct != 'All'))
            query += ' AND ' + relationshipName.replace('__c', '__r') + '.Active__c = true AND Contact__r.Product_Specialty__c = \'' + staffProduct + '\'';
        else if (strLOB == 'FVA' && IsIndHead && !IsAdmin) {
            List<Contact> contactList = [SELECT Product_Specialty__c FROM Contact WHERE User__c = : UserInfo.getUserId()];
            if (contactList.size() > 0 && !String.isBlank(contactList[0].Product_Specialty__c))
                query += ' AND ' + relationshipName.replace('__c', '__r') + '.Active__c = true AND Contact__r.Product_Specialty__c = \'' + contactList[0].Product_Specialty__c + '\'';
        }
        
        for (Sobject sobj : Database.query(query))
            setSobjectIds.add((Id)sobj.get(relationshipName));
        
        return setSobjectIds;
    }
    /* End */
    
    /*
@MethodName : initializePagination.
@param      :
@Description: to get the paginator class instance to intilize opportunity and engagement pagination variables.
*/
    private SL_Paginator initializePagination(String fieldDef, Integer paramPageSize, String paramObjectName,
                                              String paramWhereCondition , boolean isFieldSet, Set<Id> setSobjectIdToQuery,
                                              Boolean isIdFilter, String strSortBy, String strSortDirection) {
                                                  SL_Paginator objPaginator = new SL_Paginator(fieldDef, paramPageSize, paramObjectName, paramWhereCondition, isFieldSet, setSobjectIdToQuery, isIdFilter, true);
                                                  if (objPaginator.isValidParameters) {
                                                      objPaginator.setSortingQueryString(strSortBy, strSortDirection);
                                                      objPaginator.gotoFirstPage();
                                                  }
                                                  
                                                  return objPaginator;
                                              }
    /* End */
    
    /*
@MethodName : searchRecords.
@param      : NA
@Description: to filter the records on the basis of the filter section on vf page
*/
    public void searchRecords() {
        searchRecords(true);
    }
    public void searchRecords(boolean updatePCS) {
        String sortField;
        String direction = 'ASC';
        Integer pageSize = PAGE_SIZE;
        
        if (HL_PageUtility.GetParameter('pdf') == 'true')
            pageSize = 10000;
        
        if (PageType == 'opp') {
            setSobjectIdOpportunity = getSobjectRecordIdToQuery('Opportunity_Internal_Team__c', 'Opportunity__c', strOpportunityStaffRole, strOpportunityStaffIndustry, strOpportunityStaffProduct);
            if (lstColumnWrapperOpportunity.size() > 0)
                sortField = (lstColumnWrapperOpportunity[0].isSortable) ? lstColumnWrapperOpportunity[0].strFieldAPI : 'Id';
            else
                sortField = 'Id';
            if (opportunityRecords != null && !String.isBlank(opportunityRecords.strOrderByFieldName)) {
                sortField = opportunityRecords.strOrderByFieldName;
                direction = opportunityRecords.strOrderByDirection;
            }
            
            if (strOpportunityOption == 'TeamOpportunities' || strOpportunityOption == 'IndustryOpportunities'  || String.isBlank(strOpportunityOption))
                opportunityRecords = initializePagination(strCSVOpportunityFields, pageSize, 'Opportunity__c', prepareWhereClause('Opportunity__c'), false, setSobjectIdOpportunity, true, sortField, direction);
            else if (!String.IsBlank(SelectedStaffNameOpps)
                     || (!String.IsBlank(strOpportunityStaffIndustry) && strOpportunityStaffIndustry != 'All')
                     || (!String.IsBlank(strOpportunityStaffProduct) && strOpportunityStaffProduct != 'All')
                     || (strLOB == 'FVA' && IsIndHead && !IsAdmin && strOpportunityOption == 'AllIndustryOpportunities'))
                opportunityRecords = initializePagination(strCSVOpportunityFields, pageSize, 'Opportunity__c', prepareWhereClause('Opportunity__c'), false, setSobjectIdOpportunity, true, sortField, direction);
            else
                opportunityRecords = initializePagination(strCSVOpportunityFields, pageSize, 'Opportunity__c', prepareWhereClause('Opportunity__c'), false, new Set<Id>(), false, sortField, direction);
        }
        else {
            setSobjectIdEngagement = getSobjectRecordIdToQuery('Engagement_Internal_Team__c', 'Engagement__c', strEngagementStaffRole, strEngagementStaffIndustry, strEngagementStaffProduct);
            if (lstColumnWrapperEngagement.size() > 0)
                sortField = (lstColumnWrapperEngagement[0].isSortable) ? lstColumnWrapperEngagement[0].strFieldAPI : 'Id';
            else
                sortField = 'Id';
            
            if (engagementRecords != null && !String.isBlank(engagementRecords.strOrderByFieldName)) {
                sortField = engagementRecords.strOrderByFieldName;
                direction = engagementRecords.strOrderByDirection;
            }
            
            if (strEngagementOption == 'TeamEngagements' || strEngagementOption == 'IndustryEngagements' || String.isBlank(strEngagementOption))
                engagementRecords = initializePagination(strCSVEngagementFields, pageSize, 'Engagement__c', prepareWhereClause('Engagement__c'), false, setSobjectIdEngagement, true, sortField, direction);
            else if (!String.isBlank(SelectedStaffNameEng)
                     || (!String.isBlank(strEngagementStaffIndustry) && strEngagementStaffIndustry != 'All')
                     || (!String.isBlank(strEngagementStaffProduct) && strEngagementStaffProduct != 'All')
                     || (strLOB == 'FVA' && IsIndHead && !IsAdmin && strEngagementOption == 'AllIndustryEngagements'))
                engagementRecords = initializePagination(strCSVEngagementFields, pageSize, 'Engagement__c', prepareWhereClause('Engagement__c'), false, setSobjectIdEngagement, true, sortField, direction);
            else
                engagementRecords = initializePagination(strCSVEngagementFields, pageSize, 'Engagement__c', prepareWhereClause('Engagement__c'), false, new Set<Id>(), false, sortField, direction);
            
            //THIS IS WHERE ENGAGEMENT NUMBER GOES
        }
        
        if (updatePCS)
            UpdatePCS();
    }
    /* End */
    
    /*
@MethodName : changeColumns.
@param      : NA
@Description: to change the columns of the opportunity and engagement tables.
*/
    public Pagereference changeColumns() {
        Pagereference pageref = new Pagereference('/apex/SL_ChangeColumns?pagetype=' + PageType);
        return pageref;
    }
    /* End */
    
    
    /*
@MethodName : updateSobjectRecord
@param      :
@Description: method to update Opportunity or Engagement record.
*/
    @RemoteAction
    public static String updateSobjectRecord(String sObjectName, String strSobjectId, String strFieldAPIName, String strValue) {
        Schema.SobjectType sobjectType = mapGlobalDescribe.get(sObjectName);
        Sobject sobj = sobjectType.newSObject(strSobjectId);
        sobj = fieldTypeCasting(sobj, mapSobjectNameToFieldsDescription.get(sObjectName), strValue, strFieldAPIName);
        Database.SaveResult[] srList = Database.update(new List<Sobject> {sobj}, false);
        Database.SaveResult sr = srList[0];
        return sr.isSuccess() ? '' : sr.getErrors()[0].getMessage();
    }
    /* End */
    
    /*
         @MethodName : updateSobjectRecordOnValidation
         @param      :
         @Description: method to update Opportunity or Engagement record based on Stage change and Validation rule trigger.
     */
    @RemoteAction
    public static String updateSobjectRecordOnValidation(String sObjectName, String strSobjectId, String strFieldAPIName1, String strFieldAPIName2, String strValue1, String strValue2) {
        Schema.SobjectType sobjectType = mapGlobalDescribe.get(sObjectName);
        Sobject sobj = sobjectType.newSObject(strSobjectId);
        sobj = fieldTypeCasting(sobj, mapSobjectNameToFieldsDescription.get(sObjectName), strValue1, strFieldAPIName1);
        if(strFieldAPIName2 != '' ){
            sobj = fieldTypeCasting(sobj, mapSobjectNameToFieldsDescription.get(sObjectName), strValue2, strFieldAPIName2); 
        }
        Database.SaveResult[] srList = Database.update(new List<Sobject> {sobj}, false);
        Database.SaveResult sr = srList[0];
        return sr.isSuccess() ? '' : sr.getErrors()[0].getMessage();
    }
    /* End */
    
    /*
@MethodName : fieldTypeCasting
@param      :
@Description: This method is called to do the type casting.
*/
    private static Sobject fieldTypeCasting(Sobject sObjTarget, Map<String, Schema.SObjectField> mapFieldDef, String fieldValue, String TargetFieldAPIName) {
        try {
            if (!String.isBlank(TargetFieldAPIName) && mapFieldDef.containsKey(TargetFieldAPIName) && mapFieldDef.get(TargetFieldAPIName) != null) {
                Schema.SObjectField field = mapFieldDef.get(TargetFieldAPIName);
                Schema.DisplayType fieldType = field.getDescribe().getType();
                
                if (!String.isBlank(fieldValue) && field.getDescribe().isAccessible()) {
                    if ((fieldType == Schema.DisplayType.DOUBLE) || (fieldType == Schema.DisplayType.CURRENCY)) {
                        // Validating field is double or not else giving custom exception
                        if (fieldValue.remove('.').remove(',').remove('-').isNumeric()) {
                            sObjTarget.put(TargetFieldAPIName, double.valueOf(fieldValue.remove(',')));
                        }
                        else
                            sObjTarget.addError('Incorrect value for decimal field');
                    }
                    else if (fieldType == Schema.DisplayType.BOOLEAN)
                        sObjTarget.put(TargetFieldAPIName, Boolean.valueOf(fieldValue));
                    else if (fieldType == Schema.DisplayType.INTEGER)
                        sObjTarget.put(TargetFieldAPIName, Integer.valueOf(fieldValue));
                    else if (fieldType == Schema.DisplayType.Date) {
                        
                        Date convertedDate = HL_DateUtility.GetDateFromJavascript(fieldValue);
                        sObjTarget.put(TargetFieldAPIName, convertedDate);
                    }
                    else if (fieldType == Schema.DisplayType.Id)
                        sObjTarget.put(TargetFieldAPIName, Id.valueOf(fieldValue));
                    else if (fieldType == Schema.DisplayType.DateTime) {
                        fieldValue = fieldValue.replaceAll('/', '-');
                        if (fieldValue.split('/')[0].length() == 4) {
                            List<String> lstDate = new List<String>();
                            String strDate = fieldValue.split(' ')[0];
                            String strTime = (fieldValue.split(' ').size() > 1) ? fieldValue.split(' ')[1] : '00:00:00';
                            lstDate.addAll(strDate.split('-'));
                            fieldValue = lstDate[2] + '-' + lstDate[0] + '-' + lstDate[1] + ' ' + strTime;
                        }
                        
                        sObjTarget.put(TargetFieldAPIName, DateTime.valueOf(fieldValue));
                    }
                    else {   // Checking with field length and populating string with accommodate size
                        sObjTarget.put(TargetFieldAPIName, String.valueOf(fieldValue).length() > field.getDescribe().getLength()
                                       ? String.valueOf(fieldValue).substring(0, field.getDescribe().getLength())
                                       : String.valueOf(fieldValue));
                    }
                }
                else if (fieldValue == '')
                    sObjTarget.put(TargetFieldAPIName, null);
            }
        }
        catch (Exception ex) {
            sObjTarget.addError('' + ex.getMessage());
        }
        
        return sObjTarget;
    }
    /* End */
    
    /*
@MethodName : getPicklistValue
@param      : Sobject name and filed api name.
@Description: method to get picklist value from field.
*/
    private List<SelectOption> getPicklistValues(String sObjectName, String strFieldName) {
        List<SelectOption> options = new List<SelectOption>();
        Schema.SObjectType targetType = mapGlobalDescribe.get(sObjectName);//!< From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //!< grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //!< describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //!< get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(strFieldName).getDescribe().getPickListValues();
        //!< grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values)
            options.add(new SelectOption(a.getLabel(), a.getValue()));
        
        return options;
    }
    /* End */
    
    private void UpdatePCS() {
        objPCS = getPCS();
        string listValues = '';
        if (PageType == 'opp') {
            objPCS.Opportunity_Industry_Filter__c = strOpportunityIndustryGroup;
            objPCS.Opportunity_Show_Records_Filter__c = strOpportunityOption;
            objPCS.Opportunity_Staff_Id_Filter__c = SelectedStaffIdOpps;
            objPCS.Opportunity_Staff_Name_Filter__c = SelectedStaffNameOpps;
            objPCS.Opportunity_Staff_Industry_Filter__c = strOpportunityStaffIndustry;
            objPCS.Opportunity_Staff_Product_Filter__c = strOpportunityStaffProduct;
            objPCS.Opportunity_Staff_Role_Filter__c = strOpportunityStaffRole;
            objPCS.Opportunity_Stage_Filter__c = strOpportunityStage;
            objPCS.Opportunity_Status_Filter__c = strOpportunityOpenOrClosed;
            for (string s : strOpportunityOffice)
                listValues += s + ',';
            objPCS.Opportunity_Office_Filter__c = listValues;
            if (opportunityRecords != null && !String.isBlank(opportunityRecords.strOrderByFieldName)) {
                objPCS.Opportunity_Sort_Field__c = opportunityRecords.strOrderByFieldName;
                objPCS.Opportunity_Sort_Direction__c = opportunityRecords.strOrderByDirection;
            }
        }
        else {
            objPCS.Include_Reviewer_Roles__c = IncludeReviewerRoles;
            objPCS.Engagement_Industry_Filter__c = strEngagementIndustryGroup;
            objPCS.Engagement_Record_Type_Filter__c = strEngagementRecordType;
            objPCS.Engagement_Show_Records_Filter__c = strEngagementOption;
            objPCS.Engagement_Staff_Id_Filter__c = SelectedStaffIdEng;
            objPCS.Engagement_Staff_Name_Filter__c = SelectedStaffNameEng;
            objPCS.Engagement_Staff_Industry_Filter__c = strEngagementStaffIndustry;
            objPCS.Engagement_Staff_Product_Filter__c = strEngagementStaffProduct;
            objPCS.Engagement_Staff_Role_Filter__c = strEngagementStaffRole;
            objPCS.Engagement_Stage_Filter__c = strEngagementStage;
            objPCS.Engagement_Status_Filter__c = strEngagementOpenOrClosed;
            for (string s : strEngagementOffice)
                listValues += s + ',';
            objPCS.Engagement_Office_Filter__c = listValues;
            if (engagementRecords != null && !String.isBlank(engagementRecords.strOrderByFieldName)) {
                objPCS.Engagement_Sort_Field__c = engagementRecords.strOrderByFieldName;
                objPCS.Engagement_Sort_Direction__c = engagementRecords.strOrderByDirection;
            }
        }
        
        upsert objPCS;
    }
    /*
@MethodName : clearFilters.
@param      : NA
@Description: reset all the page filters to their default values
*/
    public Pagereference clearFilters() {
        SelectedStaffIdOpps = null;
        SelectedStaffNameOpps = null;
        SelectedStaffIdEng = null;
        SelectedStaffNameEng = null;
        SelectedEngagementNumber = null;
        if (PageType == 'opp') {
            strOpportunityOption = 'TeamOpportunities';
            strOpportunityIndustryGroup = strOpportunityStage = strOpportunityStaffRole = strOpportunityStaffIndustry = strOpportunityStaffProduct = 'All';
            strOpportunityOpenOrClosed = 'Active';
            strOpportunityOffice = new List<String> {'All'};
                }
        else {
            IncludeReviewerRoles = false;
            strEngagementOption = 'TeamEngagements';
            strEngagementIndustryGroup = strEngagementStage = strEngagementStaffRole = strEngagementRecordType = strEngagementStaffIndustry = strEngagementStaffProduct = 'All';
            strEngagementOpenOrClosed = 'Active';
            strEngagementOffice = new List<String> {'All'};
                }
        UpdatePCS();
        Pagereference pageref = new Pagereference('/apex/SL_PipelineManager?pagetype=' + PageType);
        pageref.setRedirect(true);
        return pageref;
    }
    /* End */
    
    public void saveChanges() {
        UpdatePCS();
        searchRecords();
    }
    
    public void setShowRecordsSelection(string dealType) {
        string show = HL_PageUtility.GetParameter('show');
        
        //Set Engagement Filters
        if (dealType == 'eng') {
            if (!String.isBlank(show))
                strEngagementOption = show;
            else
                strEngagementOption = objPCS.Engagement_Show_Records_Filter__c;
        }
        else {   //Set Opportunity Filters
            if (!String.isBlank(show))
                strOpportunityOption = show;
            else
                strOpportunityOption = objPCS.Opportunity_Show_Records_Filter__c;
        }
    }
    
    public void setIndustryGroupSelection(string dealType) {
        if (dealType == 'opp')
            strOpportunityIndustryGroup = getSelection('ig', objPCS.Opportunity_Industry_Filter__c);
        else
            strEngagementIndustryGroup = getSelection('ig', objPCS.Engagement_Industry_Filter__c);
    }
    
    public void setStaffIndustrySelection(string dealType) {
        if (dealType == 'opp')
            strOpportunityStaffIndustry = getSelection('si', objPCS.Opportunity_Staff_Industry_Filter__c);
        else
            strEngagementStaffIndustry = getSelection('si', objPCS.Engagement_Staff_Industry_Filter__c);
    }
    
    public void setStaffProductSelection(string dealType) {
        if (dealType == 'opp')
            strOpportunityStaffProduct = getSelection('sp', objPCS.Opportunity_Staff_Product_Filter__c);
        else
            strEngagementStaffProduct = getSelection('sp', objPCS.Engagement_Staff_Product_Filter__c);
    }
    
    private string getSelection(string param, string filter) {
        //Query String Parameter (if it was passed)
        string qs = HL_PageUtility.GetParameter(param);
        return !String.isBlank(qs) ? qs : filter;
    }
    
    public void setStageSelection(string dealType) {
        if (dealType == 'opp')
            strOpportunityStage = getSelection('st', objPCS.Opportunity_Stage_Filter__c);
        else
            strEngagementStage = getSelection('st', objPCS.Engagement_Stage_Filter__c);
    }
    
    public void setStatusSelection(string dealType) {
        if (dealType == 'opp')
            strOpportunityOpenOrClosed = getSelection('sta', objPCS.Opportunity_Status_Filter__c);
        else
            strEngagementOpenOrClosed = getSelection('sta', objPCS.Engagement_Status_Filter__c);
    }
    
    public void setOfficeSelection(string dealType) {
        string off = HL_PageUtility.GetParameter('off');
        
        if (dealType == 'opp') {
            if (!String.isBlank(off))
                strOpportunityOffice = off.split(',');
            else
                strOpportunityOffice = objPCS.Opportunity_Office_Filter__c.split(',');
        }
        else {
            if (!String.isBlank(off))
                strEngagementOffice = off.split(',');
            else
                strEngagementOffice = objPCS.Engagement_Office_Filter__c.split(',');
        }
    }
    
    public void setRecordTypeSelection(string dealType) {
        if (dealType == 'eng')
            strEngagementRecordType = getSelection('rt', objPCS.Engagement_Record_Type_Filter__c);
    }
    
    public void setStaffNameSelection(string dealType) {
        string sm = ApexPages.currentPage().getParameters().get('sm');
        string smid = ApexPages.currentPage().getParameters().get('smid');
        
        if (dealType == 'opp') {
            if (!String.isBlank(sm)) {
                SelectedStaffIdOpps = smid;
                SelectedStaffNameOpps = sm;
            }
            else {
                SelectedStaffIdOpps = objPCS.Opportunity_Staff_Id_Filter__c;
                SelectedStaffNameOpps = objPCS.Opportunity_Staff_Name_Filter__c;
            }
        }
        else {
            if (!String.isBlank(sm)) {
                SelectedStaffIdEng = smid;
                SelectedStaffNameEng = sm;
            }
            else {
                SelectedStaffIdEng = objPCS.Engagement_Staff_Id_Filter__c;
                SelectedStaffNameEng = objPCS.Engagement_Staff_Name_Filter__c;
            }
        }
    }
    
    public void setStaffRoleSelection(string dealType) {
        if (dealType == 'opp')
            strOpportunityStaffRole = getSelection('sr', objPCS.Opportunity_Staff_Role_Filter__c);
        else
            strEngagementStaffRole = getSelection('sr', objPCS.Engagement_Staff_Role_Filter__c);
    }
    
    public PageReference GenerateReport() {
        PageReference reportPage = new PageReference('/apex/HL_PipelineManager_PDF?pdf=true&pagetype=' + PageType);
        reportPage.setRedirect(true);
        return reportPage;
    }
    
    public static Schema.FieldSet GetPipelineFS(Map<String, Schema.SObjectType> globalDescribe, string sObjectName, string fsStub, string lob) {
        Schema.FieldSet result = HL_Utility.getFieldSet(globalDescribe, sObjectName, fsStub + lob);
        //Use CF As Default if no FieldSet found for the LOB
        if (result == null)
            result = HL_Utility.getFieldSet(globalDescribe, sObjectName, fsStub + 'CF');
        return result;
    }
    
    public static Pipeline_Column_Selection__c GetDefaultPCS(Map<String, Schema.SObjectType> globalDescribe, string lob) {
        Pipeline_Column_Selection__c pcs;
        if (globalDescribe == null)
            globalDescribe = Schema.getGlobalDescribe();
        Schema.FieldSet oppFS = GetPipelineFS(globalDescribe, 'Opportunity__c', 'Default_Pipeline_Columns_', lob);
        Schema.FieldSet engFS = GetPipelineFS(globalDescribe, 'Engagement__c', 'Default_Pipeline_Columns_', lob);
        string oppFields = '';
        string engFields = '';
        for (Schema.FieldSetMember fsm : oppFS.getFields())
            oppFields = oppFields == '' ? fsm.getFieldPath() : oppFields + ',' + fsm.getFieldPath();
        for (Schema.FieldSetMember fsm : engFS.getFields())
            engFields = engFields == '' ? fsm.getFieldPath() : engFields + ',' + fsm.getFieldPath();
        pcs = new Pipeline_Column_Selection__c(Opportunity_Columns__c = oppFields,
                                               Engagement_Columns__c = engFields,
                                               User__c = Userinfo.getUserId());
        return pcs;
    }
}