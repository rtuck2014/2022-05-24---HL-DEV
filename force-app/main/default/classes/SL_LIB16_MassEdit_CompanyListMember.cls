public without sharing class SL_LIB16_MassEdit_CompanyListMember extends SL_LIB16_MassEdit
{
    private String ExtId {get{return HL_PageUtility.GetParameter('extId');}}
    public Map<String, String> filterLabels{get; set;}
    public String dateFormat {get{return SL_LIB16_DateObject.dateFormat;}set;}
    public Boolean counterparties_permission{get;set;}
    
    public Boolean isNoExceptionThrown {get; set;} 

    public List<SL_View_Filter__c> filters {
        get {
            if(filters == null){
                filters = [SELECT Value__c, Type__c, SL_View__c, Operator__c, Id, Field__c, SL_View__r.Advanced_Filter__c
                           FROM SL_View_Filter__c
                           WHERE SL_View__c=:view.ID AND (Operator__c = 'equal' OR Operator__c = 'includes') AND (Type__c !='ID')];
                Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();
                Schema.sObjectType objType = globalDescription.get(targetObjectName);
                Schema.DescribeSObjectResult r1 = objType.getDescribe();
                Map<String , Schema.SObjectField> mapFieldList = r1.fields.getMap();
                Integer i = 0;
                List<SL_View_Filter__c> filtersNew = new List<SL_View_Filter__c>();
                try{
                    for(SL_View_Filter__c f: filters){
                        String obj = '';
                        String obj_r = '';
                        String field = f.Field__c;
                        Map<String , Schema.SObjectField> mfl = mapFieldList;
                        if(field.contains('.')){ // Handle nested filters
                            String[] strs = field.split('\\.');
                            obj_r = strs[0];
                            obj = obj_r.replace('__r', '__c');
                            field = strs[1];
                            if(filterObj.getSObject(obj_r)==null){
                                String o = SL_LIB16_ME_DescribeObject_Core.getInstance().getFieldReferenceByName(this.currMainCusSettings.targetObjectName__c, obj.replace('__r', '__c'));
                                Schema.sObjectType ot = globalDescription.get(o);
                                r1 = ot.getDescribe();
                                mfl = r1.fields.getMap();
                                filterObj.putSObject(obj_r, ot.newSObject());
                            }
                        }
                        filterLabels.put(f.Field__c, mfl.get(field).getDescribe().getLabel());
                        if(mfl.get(field).getDescribe().isUpdateable()){
                            if(f.Type__c=='REFERENCE'){
                                String value = f.Value__c;
                                try{ID n = (ID)f.Value__c;}
                                catch(Exception e){
                                    String so = '';
                                    if(obj!=''){
                                        so = SL_LIB16_ME_DescribeObject_Core.getInstance().getFieldReferenceByName(obj, field);
                                    } else {
                                        so = SL_LIB16_ME_DescribeObject_Core.getInstance().getFieldReferenceByName(this.currMainCusSettings.targetObjectName__c, field);
                                    }
                                    String query = 'SELECT Id, Name FROM ' + so + ' WHERE Name=\''+value+'\' LIMIT 1';
                                    try{
                                        SObject rt = Database.query(query).get(0);
                                        value = String.valueOf(rt.Id);
                                        putToSObject(filterObj, field, value, obj_r);
                                    } catch (Exception ex){
                                        System.Debug(ex.getMessage() + '<br/>' +query);
                                    }
                                }
                            } else if (f.Type__c=='DATE'){
                                putToSObject(filterObj, field, Date.valueOf(f.Value__c), obj_r);
                            } else if (f.Type__c=='DATETIME'){
                                String prepareDate = f.Value__c.replace('T', ' ').replace('Z','');
                                putToSObject(filterObj, field, Date.valueOf(prepareDate), obj_r);
                            } else if (f.Type__c=='ID'){
                                putToSObject(filterObj, field, (ID)f.Value__c, obj_r);
                            } else {
                                putToSObject(filterObj, field, f.Value__c, obj_r);
                            }
                            filtersNew.add(f);
                        }
                    }
                }
                catch(Exception ex){
                    System.Debug('ERROR preparing the filters: (line ' + ex.getLineNumber() + ') - ' + ex.getMessage() + ' STACK: ' + ex.getStackTraceString());
                }
                filters = filtersNew;
            }
            return filters;
        }
        set;
    }

    public SL_View__c view {
        get{
            if(view == null){
            
                for(SL_View__c v: [SELECT RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c
                                   FROM SL_View__c
                                   WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c=:implType AND IsDefault__c=false AND (User__c=:UserInfo.getUserId() OR Visibility__c='Public') LIMIT 1])
                {
                    view = v;
                }

            }
            if(view == null){
                for(SL_View__c v: [SELECT RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c
                                   FROM SL_View__c
                                   WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c=:implType AND IsDefault__c=true LIMIT 1])
                {
                    view = v;
                }

            }


            return view;
        }
        set;
    }

    public SObject filterObj {get; set;}

    public String shortUrl {
        get{
            if(shortUrl!=null && shortUrl!=''){
                return shortUrl;
            }
            shortUrl = Apexpages.currentPage().getUrl();
            if(shortUrl==null || shortUrl=='') return shortUrl;
            if(shortUrl.indexOf('?')!=-1){ shortUrl = shortUrl.substring(0,shortUrl.indexOf('?'));}
            return shortUrl;
        }
        set;
    }

    public SL_LIB16_MassEdit_CompanyListMember()
    {
        super();

        isNoExceptionThrown = true;

        ShowEditDeleteProfile();

        filterLabels = new Map<String, String>();
        String clId = HL_PageUtility.GetParameter('clId');
        if(hasNoError)
        {
            tplRecordTypeName = this.MainObjName;
            if(this.currMainCusSettings!=null)
            {
                if(this.currMainCusSettings.targetObjectName__c != null) targetObjectName = this.currMainCusSettings.targetObjectName__c.toLowerCase();
                if(this.currMainCusSettings.targetObjectParentFieldName__c != null) targetObjectParentFieldName = this.currMainCusSettings.targetObjectParentFieldName__c.toLowerCase();
                if(this.currMainCusSettings.parentObjectName__c != null)
                {
                    parentObjectName = this.currMainCusSettings.parentObjectName__c.toLowerCase();

                    if(parentObjectName != null)
                    {
                        String qTxt = 'SELECT Id, Name FROM '+parentObjectName+' WHERE Id = \''+clId+'\'';
                        for(SObject item: Database.query(qTxt)){ parentObject = item;}
                    }
                }
                List<String> lTemp = new List<String>();
                filterObj = Schema.getGlobalDescribe().get(this.currMainCusSettings.targetObjectName__c).newSObject();
            }

            Boolean isPageLoad = true;
            String activColumnNames = '';
            SL_LIB16_UserChoise__c curUserChoise = null;

            for(SL_LIB16_UserChoise__c item:[SELECT Id, View__c, View__r.Name, View__r.Columns__c, View__r.RowsCount__c, Implementation_Type__c
                                             FROM SL_LIB16_UserChoise__c
                                             WHERE View__c != null AND Mass_Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target' AND User__c=:UserInfo.getUserId() LIMIT 1])
            {
                item.View__c = GetDefaultViewByJobType().id;
                curUserChoise = item;
            }

            if(curUserChoise!=null)
            {
                isPageLoad = false;
                //strColumnsAndFiltersTemplate = curUserChoise.View__r.Name;

                if(curUserChoise.View__r.Columns__c!=null) activColumnNames += curUserChoise.View__r.Columns__c;
                pageSize = (integer)curUserChoise.View__r.RowsCount__c;
            }
            isOnlyDefaultView = true;

            List<SL_View__c> lstViews4 = [SELECT Name, Id, Columns__c, RowsCount__c, IsDefault__c
                                          FROM SL_View__c
                                          WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c=:implType AND (User__c=:UserInfo.getUserId() OR IsDefault__c=true OR Visibility__c='Public') ORDER BY Name];
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

                            //strColumnsAndFiltersTemplate = objColumnsAndFiltersTemplate.Name;
                            if(objColumnsAndFiltersTemplate.Columns__c!=null) activColumnNames += objColumnsAndFiltersTemplate.Columns__c;
                            isPageLoad = false;
                            pageSize = (integer)objColumnsAndFiltersTemplate.RowsCount__c;
                        }                   }
                }
            }
            Set<String> setSelectedColumn = new Set<String>();
            if(activColumnNames!='')
            {
                for(String item : activColumnNames.split(',')){ setSelectedColumn.add(item.toLowerCase());}
            }

            columns = new List<ColumnInfo>();
            for(Mass_Edit_Settings__c item : [SELECT Field__c, Sort_Field__c, Label__c, IsSortable__c, isEditable__c
                                              FROM Mass_Edit_Settings__c
                                              WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='Target'
                                              ORDER BY Label__c])
            {
              columns.add(new ColumnInfo(item.Field__c.toLowerCase(), item.Sort_Field__c.toLowerCase(), item.Label__c, setSelectedColumn.contains(item.Label__c.toLowerCase()), true, item.IsSortable__c, item.isEditable__c));
            }

         // refetchMembers();
        }
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=10');
        
         //Permission set logic
        List<PermissionSetAssignment> lstcurrentUserPerSet = [SELECT Id, PermissionSet.Name,AssigneeId,
                                                              Assignee.Profile.Name FROM PermissionSetAssignment
                                                                WHERE AssigneeId = :Userinfo.getUserId()];
        system.debug('##lstcurrentUserPerSet' + lstcurrentUserPerSet);
        counterparties_permission =false;
        //id profileId=[Select Id,Name from Profile where name='Standard User Template'].Id;
        for ( PermissionSetAssignment psa : lstcurrentUserPerSet ) {
            System.debug('##psa.PermissionSet.Name' + psa.PermissionSet.Name);//profileId==userinfo.getProfileId() && 
            if(psa.PermissionSet.Name.equals('Access_to_view_Counterparties_and_Bids')) {
                counterparties_permission = true;
                break;
            }
        }
    }

    public SL_LIB209_ctrl_SearchBlockParams getSearchCompParams()
    {
        SL_LIB209_ctrl_SearchBlockParams retVal = new SL_LIB209_ctrl_SearchBlockParams();
        retVal.tabs = new List<SelectOption>();
        retVal.tabsObjName = new List<SelectOption>{new selectOption('Target_'+currMainCusSettings.ID,this.currMainCusSettings.targetObjectName__c)};
        retVal.mainSelTarget = 'Target_'+currMainCusSettings.ID;
        retVal.locationBase = '/apex/SL_LIB16_MassEdit_JSON?m_impl='+currMainCusSettings.ID+'&evtmp=';
        retVal.searchBtnClick = '';
        retVal.FiltersJSON = this.getFiltersJSON();
        retVal.cb_target = 'Main';
        retVal.cb_advFilters = this.cb_advFilters;
        retVal.dateFormat = SL_LIB16_DateObject.dateFormat;

        return retVal;
    }

    public override List<SL_View_Filter__c> getViewFilters(){
        if(isManageTargets){
            List<SL_View_Filter__c> lst = new List<SL_View_Filter__c>();
            for(SL_View_Filter__c f : filters){
                String obj = '';
                String obj_r = '';
                String field = f.Field__c;
                if(field.contains('.')){ // Handle nested filters
                    String[] strs = field.split('\\.');
                    obj_r = strs[0];
                    obj = obj_r.replace('__r', '__c');
                    field = strs[1];
                    SObject so = filterObj.getSObject(obj_r);
                    if( so != null && so.get(field) != null && so.get(field) != ''){
                        SL_View_Filter__c ff = f.clone(false, true, false, false);
                        ff.put('Field__c', f.Field__c);
                        ff.put('Value__c', so.get(field));
                        lst.add(ff);
                    }
                } else {
                    if(filterObj.get(f.Field__c) != null && filterObj.get(f.Field__c) != ''){
                        SL_View_Filter__c ff = f.clone(false, true, false, false);
                        ff.put('Field__c', f.Field__c);
                        ff.put('Value__c', filterObj.get(f.Field__c));
                        lst.add(ff);
                    }
                }
            }
            if(!lst.isEmpty()){
                String filter = '1';
                for(Integer i=2; i<lst.size()+1; i++){
                    filter = '(' + filter + ')' + ' AND ' + i;
                }
                for(SL_View_Filter__c f: lst){
                    f.putSObject('SL_View__r', new SL_View__c(Advanced_Filter__c = filter));
                }
            }
            return lst;
        }else{
            return super.getViewFilters();
        }
    }

    private void refreshFilters(){
        cb_filters = '';
        cb_advFilters = '';
        for(SL_View_Filter__c objFiltersTemplate: filters)
        {
            if(cb_filters != '') {cb_filters += '##';}
            cb_filters = objFiltersTemplate.Type__c + '___' + objFiltersTemplate.Field__c + '___' + objFiltersTemplate.Operator__c + '___' + objFiltersTemplate.Value__c + '___' ;
        }
        cb_advFilters = view.Advanced_Filter__c;
    }

    public SL_Mass_Implementation__c getMassEditSettings(){return this.currMainCusSettings;}

    public void SetDefaultView(){
        SL_LIB16_UserChoise__c choiceObject = null;
        choiceObject = new SL_LIB16_UserChoise__c(
                        Filter_Tab__c = null,
                        Type__c = 'Last',
                        Mass_Implementation__c = currMainCusSettings.ID,
                        Implementation_Type__c = 'Target',
                        View__c = GetDefaultViewByJobType().SL_View__r.id,//template.id,
                        User__c = UserInfo.getUserId()
                    );
        upsert choiceObject;
    }

    public void loadDefaults()
    {
        ShowEditDeleteProfile();

        if(!hasNoError && !String.isBlank(parentObjectName))
        {
            String clId = HL_PageUtility.GetParameter('clId');
            String qTxt = 'SELECT Id, Name FROM '+parentObjectName+' WHERE Id = \''+clId+'\'';

            for(SObject item: Database.query(qTxt)){ parentObject = item;}
        }
        btnGo();
    }

    public void loadDefaultsTarget()
    {
        this.loadDefaults();
        for(SL_View__c item:[SELECT RowsCount__c, ID FROM SL_View__c WHERE Implementation__c=:currMainCusSettings.ID AND Implementation_Type__c='ManageTargets' LIMIT 1])
        {
            pageSize = (integer)item.RowsCount__c;
            pageCount = (membersList.size()-1)/pageSize;
        }

    }

    public String getCurrentUrlEncoded()
    {
        String urlVal = Apexpages.currentPage().getUrl();
        if(urlVal==null || urlVal=='') return urlVal;
        if(urlVal.indexOf('?')!=-1){ urlVal = urlVal.substring(0,urlVal.indexOf('?'));}
        return EncodingUtil.urlEncode(urlVal+'?clId=' + parentObject.Id + '&implId=' +this.currMainCusSettings.ID + '&mt=' + getMT(), 'UTF-8');

    }

    public List<MemberContainerCasted> getConvertedCallLogs()
    {
        List<MemberContainerCasted> res = new List<MemberContainerCasted>();
        Integer first = Math.min(pageNumber*pageSize, membersList.size());
        Integer last = Math.min(pageNumber*pageSize + pageSize, membersList.size());

        for (Integer i=first; i<last; i++)
        {
            MemberContainer member = membersList.get(i);
            member.index = res.size();
            res.add(new MemberContainerCasted(member));
        }
        return res;
    }

    public override SObject getNewTargetObject()
    {
        sObject sObj = null;
        if(targetObjectName!=null)
        {
            sObj = Schema.getGlobalDescribe().get(targetObjectName).newSObject();
            sObj.put(targetObjectParentFieldName, parentObject.Id);
        }
        return sObj;
    }

    public override boolean castAndSave(List<SObject> lst)
    {
        boolean retVal = true;
       // Counterpary for Opportunity and Engagement making field Type as required
        Schema.SObjectType engcounterPartyType = Schema.Engagement_Counterparty__c.getSObjectType();
        Schema.SObjectType oppCounterPartyType = Schema.Opportunity_Counterparty__c.getSObjectType();
        Map<Id,Engagement_Counterparty__c> mapExistingEngCounterParties;
        Map<Id,Opportunity_Counterparty__c> mapExistingOppCounterParties;
        Id BuysideRecordTypeId = Schema.SObjectType.Engagement_Counterparty__c.getRecordTypeInfosByName().get('Buyside').getRecordTypeId();
        Id FIGBuysideRecordTypeId = Schema.SObjectType.Engagement_Counterparty__c.getRecordTypeInfosByName().get('FIG - Buyside').getRecordTypeId();
        Set<Id> byPassRecordTypes = new Set<Id>{BuysideRecordTypeId, FIGBuysideRecordTypeId};
        System.debug( byPassRecordTypes);
        if(typeFieldNotChangedInMembers != null && typeFieldNotChangedInMembers.size() > 0){
            String recId = String.valueOf(new List<Id>(typeFieldNotChangedInMembers)[0]);
            String keyCode = recId.subString(0,3);
            if(engcounterPartyType.getDescribe().getKeyPrefix() == keyCode)
                mapExistingEngCounterParties = new Map<Id,Engagement_Counterparty__c>([SELECT Id, Type__c  FROM Engagement_Counterparty__c WHERE Id IN :typeFieldNotChangedInMembers AND RecordType.DeveloperName != 'Buy_Side']);
            else if(oppCounterPartyType.getDescribe().getKeyPrefix() == keyCode)
                mapExistingOppCounterParties = new Map<Id,Opportunity_Counterparty__c>([SELECT Id, Type__c  FROM Opportunity_Counterparty__c WHERE Id IN :typeFieldNotChangedInMembers]);
        } 
         
        List<String> lstErrorMessage = new List<String>();
        List<SObject> lst2Insert = new List<SObject>();
        List<SObject> lst2Update = new List<SObject>();
        for (SObject item : lst)
        {
            if(item.ID==null) lst2Insert.add(item);
            else{
                lst2Update.add(item);
                if(item.getSObjectType() == engcounterPartyType){
                    Engagement_Counterparty__c objCounterParty = (Engagement_Counterparty__c)item;  
                    if(checkTypeFieldModified.containsKey(objCounterParty.Id)){
                     System.debug( byPassRecordTypes + 'objCounterParty ' + objCounterParty.recordTypeId );
                      System.debug(objCounterParty);
                        if(string.isBlank(objCounterParty.Type__c) && !byPassRecordTypes.contains(objCounterParty.recordTypeId) )
                            lstErrorMessage.add('Missing');
                    }
                    else{
                        If(!byPassRecordTypes.contains(objCounterParty.recordTypeId) && mapExistingEngCounterParties != null && mapExistingEngCounterParties.size() > 0 && mapExistingEngCounterParties.get(objCounterParty.Id) != null && String.IsBlank(mapExistingEngCounterParties.get(objCounterParty.Id).Type__c)){
                            lstErrorMessage.add('Missing');
                        }
                    }
            
                }
                else if(item.getSObjectType() == oppCounterPartyType){
                    Opportunity_Counterparty__c objOppCounterParty = (Opportunity_Counterparty__c)item;  
                    if(checkTypeFieldModified.containsKey(objOppCounterParty.Id)){
                        if(string.isBlank(objOppCounterParty.Type__c))
                            lstErrorMessage.add('Missing');
                    }
                    else{
                        If(mapExistingOppCounterParties != null && mapExistingOppCounterParties.size() > 0 && mapExistingOppCounterParties.get(objOppCounterParty.Id) != null && String.IsBlank(mapExistingOppCounterParties.get(objOppCounterParty.Id).Type__c)){
                            lstErrorMessage.add('Missing');
                        }
                    }
            
                }
            }
        }
        if(lstErrorMessage.size() > 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Counterparty Field: Type is required. Please select "Type" to save records'));
            return false;
        }
   
        List<Database.SaveResult> uInsertResults = Database.insert(lst2Insert,false);
        for(Database.SaveResult result:uInsertResults)
        {
            if (!result.isSuccess()){ retVal = false;}
        }

        List<Database.SaveResult> uUpdateResults = Database.update(lst2Update,false);
        for(Database.SaveResult result:uUpdateResults)
        {
            if (!result.isSuccess()){ retVal = false;}
        }

        return retVal;
    }

    public class MemberContainerCasted {
        public MemberContainer member {get; set;}

        public MemberContainerCasted(MemberContainer member){
            this.member = member;
        }

        public SObject getCastedSObject(){
            return (SObject)member.obj;
        }
    }

    public void dummyFunction(){}

    public void doDelete()
    {

        List<SObject> delLogs = new List<SObject>();
        for (MemberContainer member : membersList){
            if (member.isSelected) delLogs.add(member.obj);
        }
        if (delLogs.size()>0){ Database.delete(delLogs, false);}

        refetchMembers();
    }

    public void doCusSave()
    {
      if(saveCounterParty())
      {
       // refetchMembers();
        }
    }

    public Boolean getIsItems(){
        return !getConvertedCallLogs().isEmpty();
    }

    public String getTargetObjName(){
        return this.currMainCusSettings.targetObjectName__c;
    }

    public String getExtId(){
        return this.ExtId;
    }

    public PageReference addSingleItem(){
         Pagereference curpage = new Pagereference(shortUrl);
        return curpage;
    }

    public Pagereference addMultipleItems(){
        Pagereference curpage = new Pagereference(shortUrl);
        Pagereference targetpage = new Pagereference('/apex/SL_LIB16_CompanyListSearch');
        targetpage.getParameters().put('clid', HL_PageUtility.GetParameter('clId'));
        if(!String.isBlank(HL_PageUtility.GetParameter('implId')))
        {
            targetpage.getParameters().put('implId', HL_PageUtility.GetParameter('implId'));
        }
        else if(!String.isBlank(ExtId))
        {
            targetpage.getParameters().put('extId', ExtId);
        }
        targetpage.getParameters().put('mt', getMT());
        targetpage.getParameters().put('retURL', curpage.getUrl());
        return targetpage;
    }

    private String getMT(){
        return (isManageTargets ? '1' : '0');
    }

    /**
    * Put a value to SObject by field, if there is an inner object, puts to the inner object.
    * It is assumed that if the innerObj is specified, then it has been already created on the obj.
     */
    private void putToSObject(sObject obj, String field, Object value, String innerObj){
        if(innerObj!=null && innerObj!=''){
            SObject so = obj.getSObject(innerObj);
            so.put(field, value);
            obj.putSObject(innerObj, so);
        } else {
            obj.put(field, value);
        }
    }

    public String getObjectLabel(SObject item){
        return '';
    }

    public boolean getIsShowReportBtn()
    {
        if(runReport()!=null) return true;
        return false;
    }

    public PageReference editBids()
    {
        if(this.currMainCusSettings.targetObjectName__c == 'Engagement_Counterparty__c' && parentObject.Id!=null)
        {
            Pagereference reportPage = new Pagereference('/apex/HL_Mass_Bid');
            reportPage.getParameters().put('id', parentObject.Id);
            return reportPage;
        }
        return null;
    }

    public PageReference runBidTracking()
    {
        if(this.currMainCusSettings.targetObjectName__c == 'Engagement_Counterparty__c' && parentObject.Id!=null)
        {
            string cognosProtocol = HL_General__c.getOrgDefaults().Cognos_Protocol__c;
            string cognosDomain = HL_General__c.getOrgDefaults().Cognos_Domain__c;
            Pagereference reportPage = new PageReference(cognosProtocol + cognosDomain + '/ibmcognos/bi/v1/disp?b_action=cognosViewer&run.outputFormat=PDF&run.prompt=false&ui.object=storeID%28%22i41C833F32B6D4D6BAB505762B4CAD49D%22%29&ui.action=run&cv.header=true&cv.toolbar=true&ui_appbar=true');
            reportPage.getParameters().put('p_p_Engagement_Id', parentObject.Id);
            reportPage.setRedirect(true);
            return reportPage;
        }
        return null;
    }

    public boolean ShowEditBids{
        get{
            if(showEditBids == null)
            {
                if(currMainCusSettings.targetObjectName__c == 'Engagement_Counterparty__c' && parentObject.Id!=null){
                    Engagement__c e = [SELECT Counterparty_Bids_Available__c FROM Engagement__c WHERE Id=:parentObject.Id];
                    showEditBids = e.Counterparty_Bids_Available__c;
                    if(showEditBids) //If true to this point, check to make sure there are Counterparties, otherwise hide the button if there are none
                    {
                        List<Engagement_Counterparty__c> ecList = [SELECT Id FROM Engagement_Counterparty__c WHERE Engagement__c = :parentObject.Id];
                        showEditBids = (ecList.size() > 0);
                    }
                }
                else
                    showEditBids = false;
            }

            return showEditBids;
        }
        set;
    }

    public PageReference runReport()
    {
        if(this.currMainCusSettings.targetObjectName__c == 'Engagement_Counterparty__c' && parentObject.Id!=null)
        {
            Pagereference reportPage = new Pagereference('/apex/SL_Racetrack_Filter');
            reportPage.getParameters().put('parentId', parentObject.Id);
            reportPage.getParameters().put('cs', 'default');
            return reportPage;
        }

        return null;
    }

    public boolean isShowEditDeleteProfile {get; set;}
    public PageReference ShowEditDeleteProfile() {
        isShowEditDeleteProfile = true;
        if(isUserSysAdmin == null) isUserSysAdmin = compareUserProfileWithSysAdmin();

        for(SL_View__c item:[SELECT Name, Id, Visibility__c
                             FROM SL_View__c
                             WHERE (User__c=:UserInfo.getUserId() OR IsDefault__c=true OR Visibility__c='Public') AND Name=:strColumnsAndFiltersTemplate])
        {

            String str_ViewVisibility = item.Visibility__c==null?'Public':item.Visibility__c;
            if(isUserSysAdmin || (!isUserSysAdmin && str_ViewVisibility != 'Public')) {
                isShowEditDeleteProfile = true;
                return null;
            }
        }
        isShowEditDeleteProfile = false;
        return null;
    }

    public Boolean OnEIT{get{
        if(onEIT == null)
        {
            if(currMainCusSettings.targetObjectName__c == 'Engagement_Counterparty__c' && parentObject.Id!=null){
                onEIT = HL_Utility.IsSysAdmin() || HL_Utility.IsCAO() || HL_EIT.IsActiveOnTeam(parentObject.Id,UserInfo.getUserId());
            }
            else
            onEIT = false;
        }
        return onEIT;
    }set;}

    public Boolean OnOIT{get{
        if(onOIT == null)
        {
            if(currMainCusSettings.targetObjectName__c == 'Opportunity_Counterparty__c' && parentObject.Id!=null){
                onOIT = HL_Utility.IsSysAdmin() || HL_Utility.IsCAO() || HL_OIT.IsActiveOnTeam(parentObject.Id,UserInfo.getUserId());
            }
            else
            onOIT = false;
        }
        return onOIT;
    }set;}


}