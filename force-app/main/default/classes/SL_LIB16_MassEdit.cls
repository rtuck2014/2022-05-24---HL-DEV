public abstract class SL_LIB16_MassEdit
{
    public Boolean isDebug {get; set;}
    public SObject parentObject {get; set;}
    public String parentObjectName {get; set;}
    public List<MemberContainer> membersList {get; set;}
    public Map<Id, SObject> membersListBackup {get; set;}
    public String sortExpression {get; set;}
    public String sortDirection {get; set;}
    public Integer pageSize {get; set;}
    public Integer pageNumber {get; set;}
    public Integer pageCount {get; set;}
    public String tplRecordTypeName {get; set;}
    public SL_Mass_Implementation__c currMainCusSettings;
    public List<SelectOption> pageSizeValues {get; set;}
    public boolean inEditColumns {get; set;}
    public List<String> fieldNames {get; set;}
    public List<String> fieldNamesNotColumns {get; set;}
    public List<String> fieldNamesNotNulls {get; set;}
    public List<ColumnInfo> columns {get; set;}
    public String selectedColumnsCallback {get; set;}
    public String targetObjectName, targetObjectParentFieldName;
    public Set<String> shownColumnNames {get; set;}
    public boolean isViewState {get; set;}
    public String JSONResponse {get; set;}
    public Boolean hasQueryErrors {get; set;}
    public String cb_columns {get; set;}
    public String cb_filters {get; set;}
    public String cb_advFilters {get; set;}
    public List<QuickFilter> cb_quickFilters {get; set;}
    public SL_LIB16_ME_MassEdit_FilterSOQLCompiler  filterCompiler {get; set;}
    public Set<String> fieldsAsPicklists {get; set;}
    public Set<String> fieldsFilterIgnored {get; set;}
    public boolean isOnlyDefaultView {get; set;}
    public boolean isOpportunity {get;set;}
    //private transient Schema.Describesobjectresult sobjectDescribe {get; set;}
    private transient Map<String, Schema.DescribeFieldResult> fieldDescribes {get; set;}
    private transient Map<String, Schema.SObjectField> sobjectFields {get; set;}
    private transient Map<String, Map<String, Schema.SObjectField>> sobjectFieldsAll {get; set;}
    private transient Map<String, Schema.DescribeSObjectResult> sobjectDescribesAll {get; set;}
    public boolean isNewView {get; set;}
    
    // MassEdit Type field making as required for Counterparty's
    public Map<Id,String> checkTypeFieldModified = new Map<Id,String>();
    public Set<Id> typeFieldNotChangedInMembers = new Set<Id>();
    
    
    public boolean AllowNewView{get;set;}
    //Added by sandeep
    public String strColumnsAndFiltersTemplate
    {
        get
        {
            if((strColumnsAndFiltersTemplate==null || strColumnsAndFiltersTemplate=='') && strView!=null && strView!='' && isNewView!=true){
                return strView;
            }
            return strColumnsAndFiltersTemplate;
        }
        set{
            strColumnsAndFiltersTemplate = Value;
        }
    }
    public List<SelectOption> lstColumnsAndFiltersTemplate {get; set;}
    public Boolean isShowCancelButton {get;set;}
    public Boolean isShowCreateLinkCancelButton {get;set;}
    public Boolean isShowDeleteButton  {get;set;}
    public Boolean isShowSaveButton {get;set;}
    public String strView {get;set;}
    public Boolean isDisabled {get;set;}
    private List<ColumnInfo> lstColumnInfo;
    public Boolean isShowTemplateNameErrorMessage  {get;set;}

    public Boolean isUserSysAdmin {get; set;}

    public String fldViewVisibility { get; set; }

    public List<SelectOption> getFldViewVisibilityVals()
    {
        if(isUserSysAdmin == null) isUserSysAdmin = compareUserProfileWithSysAdmin();
        List<SelectOption> options = new List<SelectOption>();
        if(isUserSysAdmin) options.add(new SelectOption('Public','Public'));
        options.add(new SelectOption('Private','Private'));
        return options;
    }

    /************ MAIN param - you have to change it if you need to switch to other SF objects ************/
    protected String MainObjName = null;
    protected ID MainObjNameID = null;
    public Boolean hasNoError {get; set;}

    public SL_LIB16_MassEdit()
    {

        AllowNewView = false;
        isUserSysAdmin = compareUserProfileWithSysAdmin();
        isDebug = isShowTemplateNameErrorMessage = false;
        inEditColumns = isShowCreateLinkCancelButton = false;
        lstColumnInfo  = new List<ColumnInfo>();

        pageSizeValues = SL_LIB16_MassEdit.getRowQtySelectOptList(this.currMainCusSettings);

        lstColumnsAndFiltersTemplate = new List<SelectOption>();
        pageSize = 50;
        try
        {
            if(pageSizeValues.size()>0){ pageSize = Integer.valueOf(pageSizeValues.get(0).getValue());}
        }
        catch(Exception ex){}

        pageNumber = 0;
        sortExpression = 'Name';
        sortDirection = 'ASC';
        hasQueryErrors = false;
        inEditColumns = false;
        strView = '';
        isShowCancelButton = isShowDeleteButton = isShowSaveButton = isDisabled = true;
        filterCompiler = new SL_LIB16_ME_MassEdit_FilterSOQLCompiler ();
        membersList = new List<MemberContainer>();
        fieldNamesNotColumns = new List<String>();
        fieldNamesNotNulls = new List<String>();
        fieldsAsPicklists = new Set<String>();
        fieldsFilterIgnored = new Set<String>();
        cb_quickFilters = new List<QuickFilter>();


        String clId = ApexPages.currentPage().getParameters().get('clId');
        String implId = null;
        if(System.currentPageReference().getParameters().get('implId')!=null && System.currentPageReference().getParameters().get('implId')!='')
        {
            implId = System.currentPageReference().getParameters().get('implId');
        }
        else if(System.currentPageReference().getParameters().get('extId')!=null && System.currentPageReference().getParameters().get('extId')!='')
        {
            try
            {
                Decimal inExtID = Decimal.valueOf(System.currentPageReference().getParameters().get('extId'));
                for(SL_Mass_Implementation__c item:[select ID from SL_Mass_Implementation__c where ExtID__c=:inExtID limit 1])
                {
                    implId = ''+item.ID;
                }
            }
            catch(Exception ex){ system.debug(ex);}
        }

        hasNoError = true;
        try
        {
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
                                              Name,
                                              ID,
                                              Get_Element_from_List_Tab__c
                                              From SL_Mass_Implementation__c
                                              where Id = :implId limit 1];

            this.MainObjName = item.name;
            this.MainObjNameID = item.ID;
            this.currMainCusSettings = item;

            ResetViewJobType();
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Incorrect clID or problem with custom settings!'));
            hasNoError = false;
        }

    }

    public Boolean isManageTargets {get{
        if (isManageTargets==null){
            if(ApexPages.currentPage().getParameters().get('mt')=='1'){
                isManageTargets = true;
            } else {isManageTargets = false;}
        }
        return isManageTargets;
    } set;}


    public String implType {
        get{
            if(isManageTargets){
                return 'ManageTargets';
            }
            return 'Target';
        }
        set;
    }

    public void fillDescribe(){
        fillDescribe(targetObjectName);
        sobjectFields = sobjectFieldsAll.get(targetObjectName);
    }

    private Schema.DescribeSObjectResult fillDescribe(String objName){

        if (sobjectFieldsAll==null) sobjectFieldsAll = new Map<String, Map<String, Schema.SObjectField>>();
        if (sobjectDescribesAll==null) sobjectDescribesAll = new Map<String, Schema.DescribeSObjectResult>();
        if(!String.isBlank(objName))
        {
            sobjectDescribesAll.put(objName, Schema.getGlobalDescribe().get(objName).getDescribe());
            sobjectFieldsAll.put(objName, sobjectDescribesAll.get(objName).fields.getMap());
            return sobjectDescribesAll.get(objName);
        }
        else
            return null;
    }

    private boolean isEditable(String field){
        if (sobjectFields==null) fillDescribe();
        if (field==null || field.trim().length()==0) return false;
        if (field.indexOf('.')>=0) return false;
        Schema.Sobjectfield f = sobjectFields.get(field);
        if (f==null) return false;
        Schema.DescribeFieldResult fr = f.getDescribe();
        if (fr==null || !fr.isUpdateable()) return false;
        return true;
    }

    private Schema.Soaptype getSoapType(String field){
        if (field==null || field.trim().length()==0) return null;
        if (sobjectFields==null) fillDescribe();
        Schema.Sobjectfield f = sobjectFields.get(field);
        Schema.DescribeFieldResult fr = f.getDescribe();
        return fr.getSoapType();
    }

    private Schema.DescribeFieldResult getFieldDescribe(String field){
        if (fieldDescribes==null) fieldDescribes = new Map<String, Schema.DescribeFieldResult>();
        if (!fieldDescribes.containsKey(field)) fieldDescribes.put(field, getFieldDescribe(targetObjectName, field, ''));
        return fieldDescribes.get(field);
    }

    private Schema.DescribeFieldResult getFieldDescribe(String objName, String fieldName, String fullPath){
        Schema.DescribeSObjectResult objDescr;
        try { objDescr = sobjectDescribesAll.get(objName);}
        catch (exception e) {objDescr = null;}
        if (objDescr==null) objDescr = fillDescribe(objName);

        if (fieldName.indexOf('.')==-1)
        {
            if(sobjectFieldsAll!=null && fieldName!=null && sobjectFieldsAll.containsKey(objName) && sobjectFieldsAll.get(objName).containsKey(fieldName)) return sobjectFieldsAll.get(objName).get(fieldName).getDescribe();
            else return null;
        }

        String relName = fieldName.substring(0, fieldName.indexOf('.'));
        String relParentField = '';
        if(relName.length()>3 && relName.substring(relName.length()-3).toLowerCase()=='__r')
        {
            relParentField = relName.substring(0,relName.length()-1)+'c';
        }
        else{ relParentField = relName + 'Id';}


        for (Schema.SObjectField f : objDescr.fields.getMap().values()){
            String path = (fullPath.length()==0) ? ''+f : fullPath + '.' + f;

            if (fieldDescribes.containsKey(path))
            {
                if (fieldDescribes.get(path)!=null && fieldDescribes.get(path).getRelationshipName()!=null && fieldDescribes.get(path).getRelationshipName().toLowerCase().trim()==relName.toLowerCase().trim()) {
                    objName = '' + fieldDescribes.get(path).getReferenceTo().get(0);
                    break;
                }
            }
            else if(relParentField.toLowerCase()==(''+f).toLowerCase() && (''+f.getDescribe().getType())=='REFERENCE')
            {
                objName = '' + f.getDescribe().getReferenceTo().get(0);
                break;
            }
        }

        fieldName = fieldName.substring(fieldName.indexOf('.')+1);

        return getFieldDescribe(objName, fieldName, (fullPath.length()==0) ? relName : fullPath + '.' + relName);
    }

    public virtual String getParentName(){
        return ''+parentObject.get('Name');
    }

    /** Should be overridden and return new Target object WITH PARENT FIELD SET */
    public abstract SObject getNewTargetObject();


    /** Selects all target objects and creates back-up data structure */
    public void refetchMembers()
    {
        hasQueryErrors = false;
        if (sobjectFields==null) fillDescribe();

        List<SObject> fobjects;
        try{
            String query = getCompiledQuery();
            fobjects = Database.query(query);
        }
        catch (Exception e){
            hasQueryErrors = true;
            inEditColumns = true;
            return;
        }
        membersList = new List<MemberContainer>();
        for (SObject so : fobjects)
            membersList.add(new MemberContainer(so));
        pageCount = (membersList.size()-1)/pageSize;
        pageNumber = 0;
        membersListBackup = new Map<Id, SObject>();

        List<String> editableFields = new List<String>();
        for (String field : fieldNames){
            if (isEditable(field)){
                editableFields.add(field);
            }
        }
        for (MemberContainer member : membersList){
            SObject obj = member.obj;
            SObject obj2 = getNewTargetObject();
            for (String field : editableFields){
                Object fdata = obj.get(field);
                if (fdata!=null){
                    Schema.SoapType ft = getSoapType(field);
                    if (ft==Schema.SoapType.DATE) obj2.put(field, (Date)fdata);
                    else if (ft==Schema.SoapType.ID) obj2.put(field, (Id)fdata);
                    else if (ft==Schema.SoapType.STRING) obj2.put(field, ''+fdata);
                    else obj2.put(field, fdata);
                }
            }
            membersListBackup.put(obj.Id, obj2);
        }

    }

    public String getCompiledQuery()
    {
        if (fieldNames==null){
            Set<String> fn = new Set<String>();
            for (ColumnInfo col : columns){
                fn.add(col.name);
                fn.add(col.sortExpression);
            }
            fieldNames = new List<String>(fn);
        }

        List<String> lstTempString = new List<String>();
        for(String objString:fieldNames)
        {
            if(objString != '' && objString != null)
            {
                lstTempString.add(objString);
            }
        }
        fieldNames =  new List<String>();
        fieldNames.addAll(lstTempString);

        String res = 'SELECT ';
        Set<String> setFieldsForSelect = new Set<String>();
        setFieldsForSelect.add('id');
        for (String field : fieldNamesNotColumns)
            setFieldsForSelect.add(field.toLowerCase());

        for (String field : fieldNames)
            setFieldsForSelect.add(field.toLowerCase());

        for (String field : setFieldsForSelect)
            res += field + ',';

        res = res.substring(0, res.length()-1);

        res += ' FROM ' + targetObjectName;
        res += ' WHERE ' + targetObjectParentFieldName + '=\'' + parentObject.Id + '\' ';
        for (String field : fieldNamesNotNulls){
            res += ' AND ' + field + '!=null ';
        }

        cb_filters = '';
        cb_advFilters = '';
        if(currMainCusSettings!=null)
        {
            for(SL_View_Filter__c objFiltersTemplate:getViewFilters())
            {
                if(cb_filters == '' || cb_filters == null)
                {
                    cb_filters = objFiltersTemplate.Type__c +'___'+objFiltersTemplate.Field__c+'___'+objFiltersTemplate.Operator__c+'___'+(objFiltersTemplate.Value__c==null?'':objFiltersTemplate.Value__c)+'___';
                }
                else
                {
                    cb_filters = cb_filters+'##' + objFiltersTemplate.Type__c +'___'+objFiltersTemplate.Field__c+'___'+objFiltersTemplate.Operator__c+'___'+(objFiltersTemplate.Value__c==null?'':objFiltersTemplate.Value__c)+'___';
                }

                cb_advFilters = objFiltersTemplate.SL_View__r.Advanced_Filter__c;
            }

            if (cb_advFilters!=null && cb_advFilters.trim().length()!=0){
                filterCompiler.Initialize(cb_filters, cb_advFilters, targetObjectName);
                filterCompiler.targetObject = this.targetObjectName;
                filterCompiler.recordId = this.parentObject.Id;
                String soql = filterCompiler.SOQL;

                if (soql!=null && soql.trim().length()!=0)
                    res += ' AND (' + soql + ')';

            } else {
                filterCompiler = new SL_LIB16_ME_MassEdit_FilterSOQLCompiler ();
            }
            for (QuickFilter f : cb_quickFilters) {
                res += ' AND (' + f.soql + ') ';
            }
        }
        res += ' ORDER BY ' + sortExpression + ' ' + sortDirection + ' ';
        res = res.replace(' null,','');

        return res;
    }

    public virtual List<SL_View_Filter__c> getViewFilters(){
        return [Select Id,Type__c,Field__c,Operator__c,Value__c,SL_View__c,SL_View__r.Advanced_Filter__c from SL_View_Filter__c where SL_View__r.Name=:strColumnsAndFiltersTemplate and SL_View__r.Implementation__c=:currMainCusSettings.ID and SL_View__r.Implementation_Type__c='Target'];
    }

    public boolean compareField(String value1, String value2){
        //system.debug('---------------------------- compare: ' + value1 + ' ' + value2);
        if (sortDirection=='ASC') return (value1<value2);
        return (value1>value2);
    }

    public String getField(SObject so, String path){
        if (so==null) return '';
        integer p = path.indexOf('.');
        if (p==-1) return ''+so.get(path);
        return getField(so.getSObject(path.substring(0, p) ), path.substring(p+1));
    }

    public void changeSorting(){
        if (sortDirection=='ASC') sortDirection = 'DESC';
        else sortDirection = 'ASC';
        mems = new List<Pair>();
        for (integer i=0; i<membersList.size(); i++){
            Pair p = new Pair();
            p.member = membersList[i];
            p.value = getField(p.member.obj, sortExpression);
            mems.add(p);
        }

        sortMems(0, mems.size()-1);
        for (integer i=0; i<mems.size(); i++){
            membersList[i] = mems[i].member;
        }
    }

    private class Pair{
        public MemberContainer member {get; set;}
        public String value {get; set;}
    }

    private List<Pair> mems {get; set;}
    public void sortMems(integer l, integer r){
        integer i = l;
        integer j = r;
        if (mems.size()<= (i+j)/2+1) return;
        String p = mems[(i+j)/2+1].value;
        do {
            while (compareField(mems[i].value, p)) i++;
            while (compareField(p, mems[j].value)) j--;
            if (i<=j) {
                Pair pr = mems[i];
                mems[i] = mems[j];
                mems[j] = pr;
                i++;
                j--;
            }
        } while (i<=j);
        if (j>l) sortMems(l, j);
        if (i<r) sortMems(i, r);
    }

    public void voidAction()
    {
        pageCount = (membersList.size()-1)/pageSize;
        if (pageNumber >= pageCount) pageNumber = (integer)pageCount;
        if (pageNumber < 0) pageNumber = 0;
        isShowDeleteButton = isShowSaveButton = true;
    }

    public void fetchTemplateColumnAndFilterConditions()
    {
        cb_filters = '';
        cb_advFilters = '';
        strView = strColumnsAndFiltersTemplate;

        for(SL_View__c item:[Select Name, Id, Visibility__c From SL_View__c where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' and (User__c=:UserInfo.getUserId() or IsDefault__c=true or Visibility__c='Public') and Name=:strView])
        {
            fldViewVisibility = item.Visibility__c==null?'Public':item.Visibility__c;
        }

        if(currMainCusSettings!=null)
        {
            for(SL_View_Filter__c objFiltersTemplate:[Select Id,Type__c,Field__c,Operator__c,Value__c,SL_View__c,SL_View__r.Advanced_Filter__c from SL_View_Filter__c where SL_View__r.Name=:strColumnsAndFiltersTemplate and SL_View__r.Implementation__c=:currMainCusSettings.ID and SL_View__r.Implementation_Type__c='Target'])
            {
                if(cb_filters == '' || cb_filters == null)
                {
                    cb_filters = objFiltersTemplate.Type__c +'___'+objFiltersTemplate.Field__c+'___'+objFiltersTemplate.Operator__c+'___'+(objFiltersTemplate.Value__c==null?'':objFiltersTemplate.Value__c)+'___';
                }
                else
                {
                    cb_filters = cb_filters+'##' + objFiltersTemplate.Type__c +'___'+objFiltersTemplate.Field__c+'___'+objFiltersTemplate.Operator__c+'___'+(objFiltersTemplate.Value__c==null?'':objFiltersTemplate.Value__c)+'___';
                }

                cb_advFilters = objFiltersTemplate.SL_View__r.Advanced_Filter__c;
            }
        }
    }

    public void doSavePageSize()
    {
        if (pageSize>0 && pageSize<=200)
        {

            SL_View__c template = null;
            if(strColumnsAndFiltersTemplate!=null && strColumnsAndFiltersTemplate!='' && currMainCusSettings!=null)
            {
                for(SL_View__c item:[Select RowsCount__c, ID From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c=:implType and ((Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or IsDefault__c=true or Visibility__c='Public')) or Implementation_Type__c='ManageTargets') limit 1])
                {
                    template = item;
                }
            }
            if(template==null && currMainCusSettings!=null)
            {
                for(SL_View__c item:[Select RowsCount__c, ID, Name From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c=:implType and ((User__c=:UserInfo.getUserId() or IsDefault__c=true or Visibility__c='Public') or Implementation_Type__c='ManageTargets') Order by Name limit 1])
                {
                    template = item;
                }
            }

            if(template!=null)
            {
                template.RowsCount__c = pageSize;
                update template;
            }
            voidAction();
        }
    }

    public String getLimits(){
        String res = '';
        res += 'SOQL: ' + Limits.getDmlStatements();
        return res;
    }

    public void stopEdit(){
        isViewState = true;
    }

    public virtual PageReference startEdit(){
        isViewState = false;
        return null;
    }

    public void save(){
        doSave();
        return ;
    }
    
    public boolean saveCounterParty(){
       return doSave();
        
    }
    
    public PageReference saveClose(){
        if (doSave()){
            return close();
        }
        return null;
    }

    public virtual PageReference close(){
        PageReference res = new PageReference('/'+parentObject.Id);
        res.setRedirect(true);
        return res;
    }

    public boolean doSave(){
        checkTypeFieldModified = new Map<Id,String>();
        typeFieldNotChangedInMembers = new Set<Id>();
        List<String> editableFieldList = new List<String>();
        if(fieldNames != null){
            for (string field : fieldNames){
                if (isEditable(field)){
                    editableFieldList.add(field);
                }
            }
            List<sObject> updateMemberList = new List<SObject>();
            for (MemberContainer member : membersList){
                sObject obj = member.obj;
                boolean updated = false;
                if (obj.Id==null) {
                    updateMemberList.add(obj);
                } else{
                    sObject recordToUpdate = obj.getSObjectType().newSObject();
                    recordToUpdate.put('Id', obj.Id);
                    for (String field : editableFieldList){
                     //   if (obj.get(field)!=membersListBackup.get(obj.Id).get(field)){
                            recordToUpdate.put(field, obj.get(field));
                            updated = true;
                            if(field.equalsIgnoreCase('Type__c'))
                                checkTypeFieldModified.put(obj.Id,String.valueOf(obj.get(field)));
                       // }
                    }
                  //  if (updated)
                        updateMemberList.add(recordToUpdate);
                    if(!checkTypeFieldModified.containsKey(obj.Id))
                        typeFieldNotChangedInMembers.add(obj.Id);
                }
            }
            return castAndSave(updateMemberList);
        }
        else
            return false;
    }

  public SL_View_Filter__c GetDefaultViewByJobType(){
        isOpportunity =false;

        String clId = ApexPages.currentPage().getParameters().get('clId');
        list<Engagement__c> e = [Select Job_Type__c from Engagement__c where id =: clId];
        list<Opportunity__c>  oppt = [Select Job_Type__c from Opportunity__c  where id =: clId];
        String JobType = 'Capital Markets';

        if(e.size() > 0){
            JobType = e[0].Job_Type__c;
            isOpportunity=false;
        }
        if(oppt.size() > 0){
            JobType = oppt[0].Job_Type__c;
            isOpportunity=true;
        }
        if(JobType == 'DM&A Sellside') JobType='Sellside';
        if(JobType == 'DM&A Buyside') JobType='Buyside';
        JobType = '%' + JobType + '%';
        list<SL_View_Filter__c> FilterObj = [Select SL_View__r.ID, SL_View__r.Name from SL_View_Filter__c WHERE Value__c LIKE : JobType AND SL_View__r.Visibility__c = 'Public' ORDER BY SL_VIEW__C LIMIT 1];
        if(FilterObj.size() == 0){
            FilterObj = [Select SL_View__r.ID, SL_View__r.Name from SL_View_Filter__c WHERE  SL_View__r.Visibility__c = 'Public' order by SL_View__r.Name LIMIT 1];
        }
        list<SL_View_Filter__c> newEmptlyViewFilter = new list<SL_View_Filter__c>();
        return FilterObj[0] == null ?  newEmptlyViewFilter[0] : FilterObj[0] ;
    }

    public void ResetViewJobType(){
        SL_View_Filter__c CurrentViewSettingsObj =  GetDefaultViewByJobType();
        if(isOpportunity){
            strColumnsAndFiltersTemplate ='All';
        } else {
            strColumnsAndFiltersTemplate = CurrentViewSettingsObj.SL_View__r.Name;
        }

        SL_LIB16_UserChoise__c choiceObject = null;

        for(SL_LIB16_UserChoise__c itemUC :[SELECT Id, View__c, User__c FROM SL_LIB16_UserChoise__c WHERE View__c!=null AND (Type__c = 'Last') AND Implementation_Type__c = 'Target' AND
                                            (Mass_Implementation__c = :currMainCusSettings.Id) AND (User__c = :UserInfo.getUserId()) LIMIT 1])
        {
            choiceObject = itemUC;
            choiceObject.View__c =CurrentViewSettingsObj.SL_View__r.Id;
        }
        if(choiceObject == null)
        {
            choiceObject = new SL_LIB16_UserChoise__c(
                Filter_Tab__c = null,
                Type__c = 'Last',
                Mass_Implementation__c = currMainCusSettings.ID,
                Implementation_Type__c = 'Target',
                View__c = CurrentViewSettingsObj.SL_View__r.Id,
                User__c = UserInfo.getUserId()
            );
        }


    }

    public void btnGo()
    {

        AllowNewView = true;
        isNewView = false;
        isShowCreateLinkCancelButton = false;
        Map<String,String> mapFieldLabel_FieldName = new Map<String,String>();
        String strColumns ='';
        String res='';
        map<String,Integer> mapNameToShowOrder =  new map<String,Integer>();
        List<String> lstStringNew = new List<String>();
        List<ColumnInfo> lstColumnInfo = new List<ColumnInfo>();
        Set<String> setColumnInfoName = new Set<String>();
        List<String> lstString = new List<String>();
        map<String,Mass_Edit_Settings__c> mapFieldName_object =  new map<String,Mass_Edit_Settings__c>();

        if(currMainCusSettings!=null)
        {

            for(Mass_Edit_Settings__c item : [SELECT Field__c, Label__c, Sort_Field__c, IsSortable__c, isEditable__c FROM Mass_Edit_Settings__c WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target' ORDER BY Label__c])
            {
                mapFieldLabel_FieldName.put(item.Label__c,item.Field__c);
                mapFieldName_object.put(item.Field__c.toLowerCase(),item);
            }

            for(SL_View__c template:[SELECT RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c FROM SL_View__c  WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target' AND Name =:strColumnsAndFiltersTemplate AND (User__c=:UserInfo.getUserId() OR IsDefault__c=true OR Visibility__c='Public') LIMIT 1])
            {

                if(template.Columns__c != null && template.Columns__c !='')
                {

                    strColumns = template.Columns__c.replace('*',' ');
                    lstString.addAll(strColumns.split(','));

                    for(String objString:lstString)
                    {
                        if(res == ''){ res = mapFieldLabel_FieldName.get(objString);}
                        else{ res += ';' + mapFieldLabel_FieldName.get(objString);}
                    }
                }

                SL_LIB16_UserChoise__c choiceObject = null;

                for(SL_LIB16_UserChoise__c itemUC :[SELECT Id, View__c, User__c FROM SL_LIB16_UserChoise__c WHERE View__c!=null AND (Type__c = 'Last') AND Implementation_Type__c = 'Target' AND
                                                    (Mass_Implementation__c = :currMainCusSettings.Id) AND (User__c = :UserInfo.getUserId()) LIMIT 1])
                {
                    choiceObject = itemUC;
                    choiceObject.View__c =template.id;

                }

                if(choiceObject == null)
                {

                    choiceObject = new SL_LIB16_UserChoise__c(
                        Filter_Tab__c = null,
                        Type__c = 'Last',
                        Mass_Implementation__c = currMainCusSettings.ID,
                        Implementation_Type__c = 'Target',
                        View__c = template.id,
                        User__c = UserInfo.getUserId()
                    );
                }

                upsert choiceObject;

                cb_filters = '';
                cb_advFilters = '';

                for(SL_View_Filter__c objFiltersTemplate:[SELECT Value__c, Type__c, SL_View__c, Operator__c, Id, Field__c FROM SL_View_Filter__c WHERE SL_View__c =:template.ID])
                {
                    if(cb_filters != '') cb_filters += '##';
                    cb_filters = objFiltersTemplate.Type__c + '___' + objFiltersTemplate.Field__c + '___' + objFiltersTemplate.Operator__c + '___' + (objFiltersTemplate.Value__c==null?'':objFiltersTemplate.Value__c) + '___' ;
                    cb_advFilters = template.Advanced_Filter__c;
                }

                if(res!=null && res!=''){ lstStringNew.addAll(res.split(';')); }

                if(columns!=null && columns.size()>0){ lstColumnInfo.addAll(columns);}

                columns = new List<ColumnInfo>();

                Integer i = 0;
                for(String str:lstStringNew)
                {
                    if(str!=null && str!='' && mapFieldName_object!=null && mapFieldName_object.containsKey(str.toLowerCase()))
                    {
                        ColumnInfo objColumnInfo = new ColumnInfo(str,mapFieldName_object.get(str.toLowerCase()).Sort_Field__c,
                                                                  mapFieldName_object.get(str.toLowerCase()).Label__c,true,true,mapFieldName_object.get(str.toLowerCase()).IsSortable__c, mapFieldName_object.get(str.toLowerCase()).isEditable__c);
                        objColumnInfo.showOrder = i;
                        i++;
                        columns.add(objColumnInfo);
                        setColumnInfoName.add(str);
                    }
                }

                for(ColumnInfo objColumnInfo:lstColumnInfo)
                {
                    if(!setColumnInfoName.contains(objColumnInfo.name)){ columns.add(objColumnInfo);}
                }

                refetchMembers();
            }
        }

        isViewState = (ApexPages.currentPage().getParameters().get('justView')!=null) ? true : false;

        loadColumnOrder();
    }

    public void deleteTemplateByname()
    {

        SL_View__c item2Delete = null;
        if(currMainCusSettings!=null)
        {
            for(SL_View__c item:[SELECT ID FROM SL_View__c WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target' AND Name =:strColumnsAndFiltersTemplate AND IsDefault__c=false AND (User__c=:UserInfo.getUserId() OR Visibility__c='Public') LIMIT 1])
            {
                item2Delete = item;
            }
            if(item2Delete!=null)
            {
                SL_LIB16_UserChoise__c choiceObjectItem = null;

                for(SL_LIB16_UserChoise__c itemUC :[SELECT Id FROM SL_LIB16_UserChoise__c WHERE View__c=:item2Delete.ID AND (Type__c = 'Last')
                                                    AND Implementation_Type__c = 'Target' AND (Mass_Implementation__c = :currMainCusSettings.ID) AND (User__c = :UserInfo.getUserId()) LIMIT 1])
                {
                    choiceObjectItem = itemUC;
                }
                if(choiceObjectItem!=null) delete choiceObjectItem;

                delete item2Delete;
            }
        }

        lstColumnsAndFiltersTemplate = new List<SelectOption>();
        Boolean isPageLoad = true;
        String activColumnNames = '';
        isOnlyDefaultView = true;

        if(currMainCusSettings!=null)
        {

            List<SL_View__c> lstViews4 = [SELECT RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c,IsDefault__c FROM SL_View__c WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target' AND (User__c=:UserInfo.getUserId() OR IsDefault__c=true OR Visibility__c='Public') ORDER BY Name];
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
                            strColumnsAndFiltersTemplate = objColumnsAndFiltersTemplate.Name;
                            if(objColumnsAndFiltersTemplate.Columns__c!=null) activColumnNames += objColumnsAndFiltersTemplate.Columns__c;
                            isPageLoad = false;
                        }
                    }
                }
            }
        }
        Set<String> setSelectedColumn = new Set<String>();
        if(activColumnNames!='')
        {
            for(String item : activColumnNames.split(',')){ setSelectedColumn.add(item.toLowerCase());}
        }

        columns = new List<ColumnInfo>();
        if(currMainCusSettings!=null)
        {
            for(Mass_Edit_Settings__c item : [SELECT Field__c, Sort_Field__c, Label__c, IsSortable__c, isEditable__c FROM Mass_Edit_Settings__c WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target' ORDER BY Label__c])
            {
                columns.add(new ColumnInfo(item.Field__c.toLowerCase(), item.Sort_Field__c.toLowerCase(), item.Label__c, setSelectedColumn.contains(item.Label__c.toLowerCase()),true, item.IsSortable__c, item.isEditable__c));
            }
        }
        refetchMembers();

        btnGo();
    }

    public void lnkCreateNewView()
    {
        cb_filters = '';
        cb_advFilters = '';
        fldViewVisibility = 'Public';

        strView = strColumnsAndFiltersTemplate;
        isShowCancelButton = false;
        isShowCreateLinkCancelButton = true;
        isNewView = true;
        strColumnsAndFiltersTemplate = '';
        Map<ColumnInfo,String> mapColumnInfoToName = new Map<ColumnInfo,String>();
        Map<ColumnInfo,String> mapColumnInfoToLabel = new Map<ColumnInfo,String>();

        for(ColumnInfo objColumnInfo:columns)
        {
            mapColumnInfoToName.put(objColumnInfo,objColumnInfo.name);
            mapColumnInfoToLabel.put(objColumnInfo,objColumnInfo.label);
        }

        List<ColumnInfo> lstColumnInfo = new List<ColumnInfo>();

        for(ColumnInfo objColumnInfo:columns)
        {
            objColumnInfo.show = false;
            objColumnInfo.name = mapColumnInfoToName.get(objColumnInfo);
            objColumnInfo.label = mapColumnInfoToLabel.get(objColumnInfo);
            objColumnInfo.sortExpression = mapColumnInfoToName.get(objColumnInfo);

            lstColumnInfo.add(objColumnInfo);
        }
        columns = new List<ColumnInfo>();
        columns.addAll(lstColumnInfo);

        isShowDeleteButton = isShowSaveButton = false;
        pageCount = (membersList.size()-1)/pageSize;
        if (pageNumber >= pageCount) pageNumber = pageCount;
        if (pageNumber < 0) pageNumber = 0;
    }

    public void btnDelete()
    {

        SL_View__c item2Delete = null;
        if(currMainCusSettings!=null)
        {
            for(SL_View__c item:[SELECT ID FROM SL_View__c WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target' AND Name =:strColumnsAndFiltersTemplate AND IsDefault__c=false AND (User__c=:UserInfo.getUserId() OR Visibility__c='Public') LIMIT 1])
            {
                item2Delete = item;
            }
        }
        if(item2Delete!=null){ database.delete(item2Delete,false);}
    }

    public void btnCancel()
    {
        try
        {
            hasQueryErrors = false;
            inEditColumns = false;
            refetchMembers();
        }
        catch(Exception ex){ }
    }

    public abstract boolean castAndSave(List<SObject> lst);

    public virtual class MemberContainer{
        public Boolean isSelected {get; set;}
        public SObject obj {get; set;}
        public Integer index {get; set;}
        public MemberContainer(){}

        public MemberContainer(SObject obj){
            this.obj = obj;
            this.isSelected = false;
        }

        public MemberContainer(SObject obj, Boolean sel){
            this.obj = obj;
            this.isSelected = sel;
        }
    }

    public List<ColumnInfo> getColumnsShown(){

        List<ColumnInfo> res = new List<ColumnInfo>();
        Map<String,ColumnInfo> mapColumnsShown = new Map<String,ColumnInfo>();
        List<String> setLabel = new List<string>();
        for (ColumnInfo info : columns)
        {
            if (info.show){ mapColumnsShown.put(info.label,info);}
        }
        if(currMainCusSettings!=null)
        {
            SL_View__c curTpl = null;

            for(SL_View__c item:[SELECT Columns__c FROM SL_View__c WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c=:implType AND Name =:strColumnsAndFiltersTemplate AND IsDefault__c=false AND (User__c=:UserInfo.getUserId() OR Visibility__c='Public') LIMIT 1])
            {
                curTpl = item;
            }

            if(curTpl == null)
            {
                for(SL_View__c item:[SELECT Columns__c FROM SL_View__c  WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c=:implType AND Name =:strColumnsAndFiltersTemplate AND IsDefault__c=true LIMIT 1])
                {
                    curTpl = item;
                }
            }
            if(curTpl == null)
            {
                for(SL_View__c item:[SELECT Columns__c FROM SL_View__c  WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c=:implType AND Implementation_Type__c='ManageTargets' LIMIT 1])
                {
                    curTpl = item;
                }
            }

            if(curTpl != null && curTpl.Columns__c != null && curTpl.Columns__c !='')
            {
                setLabel.addAll(( curTpl.Columns__c.replace('*',' ')).split(','));
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



    public List<SelectOption> getUnselectedColumns()
    {
        List<SelectOption> res = new List<SelectOption>();
        set<String> setLabel = new set<string>();

        if(currMainCusSettings!=null)
        {
            SL_View__c template = null;
            for(SL_View__c item:[SELECT RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c FROM SL_View__c WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target' AND IsDefault__c=false AND Name =:strColumnsAndFiltersTemplate AND (User__c=:UserInfo.getUserId() OR Visibility__c='Public') LIMIT 1])
            {
                template = item;
            }
            if(template==null)
            {
                for(SL_View__c item:[SELECT RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c FROM SL_View__c WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target' AND IsDefault__c=true AND Name =:strColumnsAndFiltersTemplate LIMIT 1])
                {
                    template = item;
                }
            }

            if(template!=null)
            {
                if(template.Columns__c != null && template.Columns__c !='')
                {
                    setLabel.addAll(( template.Columns__c.replace('*',' ')).split(','));
                }
            }
        }

        Set<String> setAlreadyAdd = new Set<String>();
        for (ColumnInfo info : columns)
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
        for (ColumnInfo info : columns){
            if (info.show) res.add(new SelectOption(info.name, info.label));
        }
        return res;
    }

    public List<SelectOption> getSelectColumnsOrdered()
    {
        List<SelectOption> res = new List<SelectOption>();
        List<String> setLabel = new List<string>();
        map<String,String> mapMassEditLabel2Name = new map<String,String>();
        if(currMainCusSettings!=null)
        {
            SL_View__c template = null;
            for(SL_View__c item:[SELECT RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c FROM SL_View__c WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target' AND IsDefault__c=false AND Name =:strColumnsAndFiltersTemplate AND (User__c=:UserInfo.getUserId() OR Visibility__c='Public') LIMIT 1])
            {
                template = item;
            }
            if(template==null)
            {
                for(SL_View__c item:[SELECT RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c FROM SL_View__c WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target' AND IsDefault__c=true AND Name =:strColumnsAndFiltersTemplate LIMIT 1])
                {
                    template = item;
                }
            }

            if(template!=null)
            {
                if(template.Columns__c != null && template.Columns__c !='')
                {
                    setLabel.addAll(( template.Columns__c.replace('*',' ')).split(','));
                }
            }
        }

        for (ColumnInfo item : columns){ mapMassEditLabel2Name.put(item.label, item.name);}
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


    public void saveIntialColumns(String scolumns)
    {
        shownColumnNames = new Set<String>();
        //Change made by Bijal for Stephens-132.
        set<String> setTempList = new set<String>();
        List<String> colsLst = new List<String>();
        List<String> colsLstTemp = scolumns.split(';');
        for(String temp : colsLstTemp)
        {
            if(!setTempList.contains(temp))
            {
                colsLst.add(temp);
                setTempList.add(temp);
            }
        }

        Set<String> cols = new Set<String>(colsLst);
        for (ColumnInfo info : columns){
            if (cols.contains(info.name)) {
                info.show = true;
                shownColumnNames.add(info.name);
                for (integer i=0; i<colsLst.size(); i++){
                    if (info.name == colsLst[i]) info.showOrder = i;
                }
            }
            else info.show = false;
        }
    }

    public void saveColumns(String scolumns)
    {

        List<String> setSelectedFieldAPI = new List<String>();
        String strTempFields = '';

        isShowCancelButton = true;
        isShowCreateLinkCancelButton = false;
        if(scolumns != null && scolumns!=''){ setSelectedFieldAPI.addAll(scolumns.split(';'));}

        Map<String,String> mapColNameLabel = new Map<String,String>();
        for (SL_LIB16_MassEdit.ColumnInfo info : columns){ mapColNameLabel.put(info.name, info.label);}

        for(String item:setSelectedFieldAPI)
        {
            if (mapColNameLabel.containsKey(item)) strTempFields += ',' + mapColNameLabel.get(item);
        }
        if(strTempFields!='') strTempFields = strTempFields.substring(1);

        SL_View__c  template = null; ///create a object of SL_View__c to update selected columns
        List<SL_View_Filter__c> lstFiltersTemplateToInsert = new List<SL_View_Filter__c>();

        if(isDisabled)
        {
            if(currMainCusSettings!=null)
            {
                for(SL_View__c item:[SELECT RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c,Visibility__c FROM SL_View__c WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target' AND Name =:strColumnsAndFiltersTemplate AND IsDefault__c=false AND (User__c=:UserInfo.getUserId() OR Visibility__c='Public') LIMIT 1])
                {
                    template = item;
                }
            }
            if(template != null)
            {
                template.Columns__c = strTempFields;
                template.Advanced_Filter__c = cb_advFilters;
                template.Visibility__c = fldViewVisibility;
                update template;

                for(SL_View_Filter__c objFiltersTemplate : [SELECT Id FROM SL_View_Filter__c WHERE SL_View__c =:template.ID])
                {
                    lstFiltersTemplateToInsert.add(objFiltersTemplate);
                }
                if(!lstFiltersTemplateToInsert.isEmpty()){ delete lstFiltersTemplateToInsert;}

            }
        }
        else
        {
            SL_View__c item2Delete = null;
            template = new SL_View__c();
            if(currMainCusSettings!=null)
            {
                for(SL_View__c item:[SELECT Id, Name, Columns__c, Advanced_Filter__c, RowsCount__c, Implementation__c, Implementation_Type__c, User__c, Visibility__c FROM SL_View__c WHERE Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Target' AND Name =:strColumnsAndFiltersTemplate AND IsDefault__c=false AND (User__c=:UserInfo.getUserId() OR Visibility__c='Public') LIMIT 1])
                {
                    template = item;
                }
            }

            template.Name = strColumnsAndFiltersTemplate;

            template.Columns__c = strTempFields;
            template.Advanced_Filter__c = cb_advFilters;
            template.RowsCount__c = 50;
            if(template.ID==null)
            {
                template.Implementation__c = currMainCusSettings.ID;
                template.Implementation_Type__c = 'Target';
            }
            template.User__c = UserInfo.getUserId();
            template.Visibility__c = fldViewVisibility;

            upsert template;

            SL_LIB16_UserChoise__c choiceObject = null;

            for(SL_LIB16_UserChoise__c itemUC :[SELECT Id, View__c, User__c FROM SL_LIB16_UserChoise__c WHERE View__c!=null AND (Type__c = 'Last') AND Implementation_Type__c = 'Target' AND
                                                (Mass_Implementation__c = :currMainCusSettings.Id) AND (User__c = :UserInfo.getUserId()) LIMIT 1])
            {
                choiceObject = itemUC;
                choiceObject.View__c = template.id;
            }
            if(choiceObject == null)
            {
                choiceObject = new SL_LIB16_UserChoise__c(
                    Filter_Tab__c = null,
                    Type__c = 'Last',
                    Mass_Implementation__c = currMainCusSettings.ID,
                    Implementation_Type__c = 'Target',
                    View__c = template.id,
                    User__c = UserInfo.getUserId()
                );
            }
            upsert choiceObject;



            lstColumnsAndFiltersTemplate = new List<SelectOption>();
            isOnlyDefaultView = true;

            if(currMainCusSettings!=null)
            {
                List<SL_View__c> lstViews4 = [SELECT Name,IsDefault__c FROM SL_View__c WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target' AND IsDefault__c=false AND (User__c=:UserInfo.getUserId() OR Visibility__c='Public') ORDER BY Name];
                if(lstViews4!=null && lstViews4.size()>0)
                {
                    for(SL_View__c objColumnsAndFiltersTemplate:lstViews4)
                    {
                        if(lstViews4.size()==1 || !objColumnsAndFiltersTemplate.IsDefault__c)
                        {
                            lstColumnsAndFiltersTemplate.add(new selectOption(objColumnsAndFiltersTemplate.Name, objColumnsAndFiltersTemplate.Name));
                            if(!objColumnsAndFiltersTemplate.IsDefault__c){ isOnlyDefaultView = false;}
                        }
                    }
                }
            }
        }

        if(template!=null && template.ID!=null)
        {
            lstFiltersTemplateToInsert = new List<SL_View_Filter__c>();
            List<String> lstCbFilterRow = new List<String>();
            if(cb_filters != Null){ lstCbFilterRow.addAll(cb_filters.split('##'));}

            if(lstCbFilterRow != null && !lstCbFilterRow.isempty())
            {

                for(String objString:lstCbFilterRow)
                {
                    List<String> lstString = new List<String>();
                    lstString.addAll(objString.split('___'));

                    if(lstString != null && lstString.size() > 1)
                    {
                        SL_View_Filter__c objFiltersTemplate = new SL_View_Filter__c();
                        objFiltersTemplate.SL_View__c = template.ID;
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

            if(!lstFiltersTemplateToInsert.isempty()){ insert lstFiltersTemplateToInsert;}
        }
        shownColumnNames = new Set<String>();

        set<String> setTempList = new set<String>();
        List<String> colsLst = new List<String>();

        List<String> colsLstTemp = scolumns.split(';');
        for(String temp : colsLstTemp)
        {
            if(!setTempList.contains(temp))
            {
                colsLst.add(temp);
                setTempList.add(temp);
            }
        }
        Set<String> cols = new Set<String>(colsLst);
        for (ColumnInfo info : columns)
        {
            if (cols.contains(info.name))
            {
                info.show = true;
                shownColumnNames.add(info.name);
                for (integer i=0; i<colsLst.size(); i++)
                {
                    if (info.name == colsLst[i]) info.showOrder = i;
                }
            }
            else info.show = false;
        }

        loadColumnOrder();
    }

    public void saveSelectedColumns()
    {
        Map<String,String> mapFieldLabel_FieldName = new Map<String,String>();
        String strColumns ='';
        String res='';
        List<String> lstString = new List<String>();

        if(currMainCusSettings!=null)
        {
            for(Mass_Edit_Settings__c item : [SELECT Field__c, Label__c FROM Mass_Edit_Settings__c WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target' ORDER BY Label__c])
            {
                mapFieldLabel_FieldName.put(item.Label__c,item.Field__c);
            }

            for(SL_View__c template:[SELECT RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c FROM SL_View__c WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target' AND Name =:strColumnsAndFiltersTemplate AND (User__c=:UserInfo.getUserId() OR IsDefault__c=true OR Visibility__c='Public') LIMIT 1])
            {
                if(template.Columns__c != null && template.Columns__c !='')
                {
                    strColumns = template.Columns__c.replace('*',' ');
                    lstString.addAll(strColumns.split(','));

                    for(String objString:lstString)
                    {
                        if(res == ''){ res = mapFieldLabel_FieldName.get(objString);}
                        else{ res += ';' + mapFieldLabel_FieldName.get(objString);}
                    }
                }
            }
        }

        saveIntialColumns(res);
    }

    public void loadColumnOrder()
    {
        Double iRowCount = 50;
        SL_View__c template = null;
        if(strColumnsAndFiltersTemplate!=null && strColumnsAndFiltersTemplate!='' && currMainCusSettings!=null)
        {
            for(SL_View__c item:[SELECT RowsCount__c, Columns__c, IsDefault__c FROM SL_View__c WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target' AND Name =:strColumnsAndFiltersTemplate AND IsDefault__c=false AND (User__c=:UserInfo.getUserId() OR Visibility__c='Public') LIMIT 1])
            {
                template = item;
            }

            if(template==null)
            {
                for(SL_View__c item:[SELECT RowsCount__c, Columns__c, IsDefault__c FROM SL_View__c WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target' AND Name =:strColumnsAndFiltersTemplate AND IsDefault__c=true LIMIT 1])
                {
                    template = item;
                }
            }

        }
        if(template==null && currMainCusSettings!=null)
        {
            for(SL_View__c item:[SELECT RowsCount__c, Columns__c, Name, IsDefault__c FROM SL_View__c WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target' AND (User__c=:UserInfo.getUserId() OR IsDefault__c=true OR Visibility__c='Public') ORDER BY Name LIMIT 1])
            {
                template = item;
            }
        }
        String cols = '';
        if(template!=null)
        {
            if(template.RowsCount__c!=null && template.RowsCount__c>0){ iRowCount = template.RowsCount__c;}
            cols = template.Columns__c;

            pageSize = Math.round((Double)iRowCount);
            pageCount = (membersList.size()-1)/pageSize;
        }

        if(cols=='')
        {
            for (ColumnInfo info : columns) {
                if (info.show) cols += ';' + info.name;
            }
            if (cols.length()>0) cols = cols.substring(1);
        }

        selectedColumnsCallback = cols;
        saveSelectedColumns();
    }

    public class PermutationInfo{
        public Integer iFrom {get; set;}
        public integer iTo {get; set;}
        public PermutationInfo(integer i1, integer i2){
            this.iFrom = i1;
            this.iTO = i2;
        }
    }

    public void saveColumnsFilters()
    {
        List<String> lstString = new List<String>();
        map<String,Integer> mapNameToShowOrder = new map<String,Integer>();
        List<ColumnInfo> lstColumnInfo = new List<ColumnInfo>();
        String strColumns ='';
        String res='';
        set<String> setColumnInfoName = new set<String>();
        map<String,Mass_Edit_Settings__c> mapFieldName_object =  new map<String,Mass_Edit_Settings__c>();

        if(currMainCusSettings!=null)
        {
            for(Mass_Edit_Settings__c item : [SELECT Field__c, Label__c, Sort_Field__c, IsSortable__c, isEditable__c FROM Mass_Edit_Settings__c WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target' ORDER BY Label__c])
            {
                mapFieldName_object.put(item.Field__c.toLowerCase(),item);
            }
        }
        if(cb_columns!=null && cb_columns!='')
        {
            lstString.addAll(cb_columns.split(';'));
            lstColumnInfo.addAll(columns);
            Integer i = 0;

            for(String str:lstString)
            {
                mapNameToShowOrder.put(str,i);
                i++;
            }

            columns = new List<ColumnInfo>();

            for(String str:lstString)
            {
                if(str!=null && str!='' && mapFieldName_object.containsKey(str.toLowerCase()))
                {
                    ColumnInfo objColumnInfo = new ColumnInfo(str,mapFieldName_object.get(str.toLowerCase()).Sort_Field__c,
                                                              mapFieldName_object.get(str.toLowerCase()).Label__c,true,true,mapFieldName_object.get(str.toLowerCase()).IsSortable__c,mapFieldName_object.get(str.toLowerCase()).isEditable__c);
                    objColumnInfo.showOrder = mapNameToShowOrder.get(str);
                    columns.add(objColumnInfo);
                    setColumnInfoName.add(str);
                }
            }

            for(ColumnInfo objColumnInfo:lstColumnInfo)
            {
                if(!setColumnInfoName.contains(objColumnInfo.name) && objColumnInfo.name != null && objColumnInfo.label != null)
                {
                    columns.add(objColumnInfo);
                }
            }
        }

        saveColumns(cb_columns);
        refetchMembers();
        btnGo();
    }

    public String getFiltersJSON()
    {
        String res = '';
        if(currMainCusSettings!=null)
        {
            for(SL_View_Filter__c objFiltersTemplate:[SELECT Id,Type__c,Field__c,Operator__c,Value__c,SL_View__c,SL_View__r.Advanced_Filter__c FROM SL_View_Filter__c WHERE SL_View__r.Name=:strColumnsAndFiltersTemplate AND SL_View__r.Implementation__c=:currMainCusSettings.ID AND SL_View__r.Implementation_Type__c='Target'])
            {
                res += ', { name: "' + objFiltersTemplate.Field__c + '", operator: "' + objFiltersTemplate.Operator__c +
                    '", value: "' + (objFiltersTemplate.Value__c==null?'':objFiltersTemplate.Value__c) + '"}';
                cb_advFilters = objFiltersTemplate.SL_View__r.Advanced_Filter__c;
            }
        }
        if (res.length()>0) res = res.substring(1);
        return '[' + res + ']';
    }

    public static List<SelectOption> getRowQtySelectOptList(SL_Mass_Implementation__c inImplObj)
    {
        List<SelectOption> pageSizeValues = new List<SelectOption>();
        if(inImplObj!=null && inImplObj.Row_Qty_Values__c!=null && inImplObj.Row_Qty_Values__c!='')
        {
            for(String item: inImplObj.Row_Qty_Values__c.split(',',0))
            {
                pageSizeValues.add(new SelectOption(item, item));
            }
        }
        else
        {
            pageSizeValues.add(new SelectOption('10', '10'));
            pageSizeValues.add(new SelectOption('20', '20'));
            pageSizeValues.add(new SelectOption('30', '30'));
            pageSizeValues.add(new SelectOption('50', '50'));
            pageSizeValues.add(new SelectOption('100', '100'));
            pageSizeValues.add(new SelectOption('150', '150'));
            pageSizeValues.add(new SelectOption('200', '200'));
        }

        return pageSizeValues;
    }

    public static String getRelObject4Field(String inObjName, String inFldName)
    {
        String fldParts = inFldName;
        if(inFldName.indexOf('.')>0){ fldParts = inFldName.substring(0,inFldName.indexOf('.'));}
        else{ return null;}

        String sParentField = '';
        if(fldParts.right(3)=='__r'){ sParentField = fldParts.substring(0,fldParts.length()-3)+'__c';}
        else{ sParentField = fldParts+'Id';}

        Schema.SObjectType dType = Schema.getGlobalDescribe().get(inObjName).getDescribe().fields.getMap().get(sParentField).getDescribe().getReferenceTo().get(0);
        return String.valueOf(dType);
    }

    public static Map<String, String> operatorLabels = new Map<String, String>
    {
        'equal' => 'equals'
            , 'notEqual' => 'not equal'
            , 'lessThan' => 'less than'
            , 'lessOrEqual' => 'less or equal'
            , 'greaterThan' => 'greater than'
            , 'greaterOrEqual' => 'greater or equal'
            , 'startsWith' => 'starts with'
            , 'contains' => 'contains'
            , 'notContain' => 'not contain'
            , 'includes' => 'includes'
            , 'excludes' => 'excludes'
            };



                public String getFiltersString(){
                    String res = '';
                    Schema.DescribeFieldResult curFieldDescribe = null;
                    for (SL_LIB16_FilterSOQLCompiler.FilterSet filter : filterCompiler.m_filter_set)
                    {
                        curFieldDescribe = getFieldDescribe(filter.Field);
                        if(curFieldDescribe!=null)
                        {
                            res += ', ' + curFieldDescribe.getLabel() + ' ' + operatorLabels.get(filter.Operator) + ' ' + filter.Value;
                        }
                    }
                    for (QuickFilter f : cb_quickFilters) {
                        res += ', ' + f.text;
                    }
                    if (res.length()>0) {
                        res = res.substring(2);
                        res = 'Filters applied: ' + res;
                    }
                    return res;
                }



    public class FieldJSONObject {
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
                return '{' +  result + '}';
            }
        }

        public FieldJSONObject() {
            picklistValues = new List<String>();
        }

        public FieldJSONObject(String p_name, String p_value, String p_type) {
            picklistValues = new List<String>();
            Name = p_name; Value = p_value; FieldType = p_type;
        }

        public FieldJSONObject(String p_name, String p_value, String p_type, List<String> p_picklist_values) {
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



    public String target {
        get{
            return System.currentPageReference().getParameters().get('target');
        }
    }

    public String event {
        get{
            return System.currentPageReference().getParameters().get('event');
        }
    }

    public String picklistName {
        get{
            return System.currentPageReference().getParameters().get('picklist');
        }
    }

    public String recordId {
        get{
            return System.currentPageReference().getParameters().get('recordId');
        }
    }



    public Pagereference EventHandler()
    {
        if(event == 'load') {
            eventActionLoad();
        }
        return null;
    }

    protected void eventActionLoad()
    {
        Schema.DescribeSObjectResult objDescr = fillDescribe(target);
        Map<String, Schema.SObjectField> fieldsMap = sobjectFieldsAll.get(target);
        if (picklistName==null || picklistName.trim().length()==0){

            String retVal = '';
            JSONResponse =  '{"fields" : []}';

        } else {
            try {
                FieldJSONObject item = new FieldJSONObject();
                if (picklistName=='recordtypeid'){
                    String so = target;
                    List<RecordType> rtLst = [SELECT Id, Name FROM RecordType WHERE SobjectType=:so ORDER BY Name];
                    for (RecordType rt : rtLst){
                        item.picklistValues.add(String.escapeSingleQuotes(rt.Name));
                    }
                }
                else
                    if (item==null) {
                        List<Schema.PicklistEntry> picklist_list = fieldsMap.get(picklistName).getDescribe().getPicklistValues();
                        for( Schema.PicklistEntry picklist_value : picklist_list ) {
                            item.picklistValues.add(picklist_value.getValue());
                        }
                    }
                JSONResponse = '{' + item.jProperty(picklistName, item.picklistValues) + '}';
            }catch(Exception e) {
                JSONResponse = '{"error" : "' + e.getMessage() + '"}';
            }
        }
    }

    public String getNewJSONResponse()
    {
        String retVal = '';

        string mImplID = System.currentPageReference().getParameters().get('m_impl');

        SL_Mass_Implementation__c filterObject = [SELECT Id, (SELECT Id,Name,API_Name__c,API_Type__c,Parent_Ref_Field__c,SF_Object__c FROM Filter_Fields__r WHERE Type__c='Target' ORDER BY Order__c) FROM SL_Mass_Implementation__c WHERE Id=:mImplID LIMIT 1];

        List<SL_Filter_Field__c> filterFieldsList = filterObject.Filter_Fields__r;

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

    protected String getJsonFromFieldsList(List<FieldJSONObject> p_fields_list)
    {
        String result = '';
        for(Integer i = 0; i < p_fields_list.size(); i++)
        {
            if(p_fields_list[i].FieldType != 'TEXTAREA')
            {
                result += p_fields_list[i].Json;
                if(i != p_fields_list.size()-1) {result += ', ';}
            }
        }
        return '{"fields" : [' + result + ']}';
    }

    public class QuickFilter
    {
        public String soql {get; set;}
        public String text {get; set;}

        public QuickFilter(){}

        public QuickFilter(String soql, String text)
        {
            this.soql = soql;
            this.text = text;
        }
    }

    public class MethodNotDefinedException extends Exception{}

    public virtual class ColumnInfo
    {
        public String name {get; set;}
        public String styleName {get; set;}
        public String label {get; set;}
        public String sortExpression {get; set;}
        public Boolean show {get; set;}
        public Boolean isSortable {get; set;}
        public Boolean isEditable {get; set;}
        public Boolean allowMultiedit {get; set;}
        public Integer showOrder {get; set;}

        public ColumnInfo(String name, String sortE, String label, Boolean show){
            this.assignVals(name, sortE, label, show, true, true, true, '');
        }

        public ColumnInfo(String name, String sortE, String label, Boolean show, Boolean allowMulti, Boolean inIsSortable, Boolean inIsEditable, String inStyleName){
            this.assignVals(name, sortE, label, show, allowMulti, inIsSortable, inIsEditable, inStyleName);
        }

        public ColumnInfo(String name, String sortE, String label, Boolean show, Boolean allowMulti, Boolean inIsSortable, Boolean inIsEditable){
            this.assignVals(name, sortE, label, show, allowMulti, inIsSortable, inIsEditable, '');
        }

        public ColumnInfo(String name, String sortE, String label, Boolean show, Boolean allowMulti, Boolean inIsSortable){
            this.assignVals(name, sortE, label, show, allowMulti, inIsSortable, true, '');
        }

        public ColumnInfo(String name, String sortE, String label, Boolean show, Boolean allowMulti){
            this.assignVals(name, sortE, label, show, allowMulti, true, true, '');
        }

        public Boolean getIsEmpty(){
            return (label==null || label.trim().length()==0);
        }

        private void assignVals(String name, String sortE, String label, Boolean show, Boolean allowMulti, Boolean inIsSortable, Boolean inIsEditable, String inStyleName)
        {
            this.name = name;
            this.sortExpression = sortE;
            this.label = label;
            this.show = show;
            this.allowMultiedit = allowMulti;
            this.isSortable = inIsSortable;
            this.isEditable = inIsEditable;
            this.styleName = inStyleName;
        }
    }

    public boolean compareUserProfileWithSysAdmin() {
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String MyProflieName = PROFILE[0].Name;
        if(MyProflieName == 'System Administrator') return true;
        return false;
    }

}