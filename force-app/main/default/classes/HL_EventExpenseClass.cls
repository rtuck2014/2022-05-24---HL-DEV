/**************************************************************
* Name : HL_EventExpenseClass
* Purpose : As Controller of Main Landing and Edit/New event expense 
* Test Class : HL_Test_EventExpenseViewClass and HL_Test_EventExpenseClass
*************************************************************************/
public class HL_EventExpenseClass {
    
    // Public Properties
    public String sortDirection {get;set;}
    public Integer CurPageSize {get; set;}    
    public Integer CurPageNumber {get; set;}    
    public List<SelectOption> PageSizeValues {get; set;}
    public List<Event_Expense__c> EventExpenseList {get; set;}
    public Integer pageCount {get; set;}
    public Integer totalpageNumber {get; set;}
    public String TableTitle {get;set;}
    public String sortQuery {get;set;}
    public Id userid{get;set;}
    public Set<Id> RelatedBankerIdSet;
    public String sortField {get;set;}
    public String currentSelectedTab {get;set;}
    public boolean requiredForCF {get;set;}
    public boolean requiredForFVA {get;set;} // Flag variable for LOB - FVA
    public boolean requiredForCS {get;set;}
    public boolean requiredForSE {get;set;}
    public boolean requiredForCE {get;set;}
    public boolean requiredForADMA {get;set;}
    public boolean requiredForMKTGMT {get;set;}
    public boolean requiredForMKTGMM {get;set;}
    public boolean validUser {get;set;}
    public String WhereClauseStr ;
    public Id EventExpId ;
    public Id EventExpRetURLId ;
    public List<Event_Expense__c> EveExpRecordList{get;set;}
    public Event_Expense__c EveExpRecord{get;set;}
    public Event_Expense__c initialEventExpense{get;set;}
    public List<Event_Expense__c> EventExpenseRecordSize;
    public ApexPages.StandardSetController Std_Set_controller ; 
    private Event_Expense_Page_Size__mdt EventExpenseCustomMetaData;
    public Integer actualRecords {get;set;}
    public Contact Contactselected;
    public List<Contact> requesterContactList;
    public string DelId {get; set;}
    public string selectedEventFormat {get; set;}
    
    public String SelectedContactNameLOTM {get; set;}
    public String SelectedContactIdLOTM {get; set;}
    public List<List_of_team_member__c> RelatedContactsLoTM{get; set;}
    public list<List_of_team_member__c> newListOfTeamMemberList;
    public list<List_of_team_member__c> LoTMtoBeDeleted;
    public List_of_team_member__c newListOfTeamMember;
    public list<SelectedContactLoTM> LoTMWrapperList{get; set;}
    
    public String SelectedContactNamePCEG {get; set;}
    public String SelectedContactIdPCEG {get; set;}
    public List<Potential_confirmed_external_guests__c> RelatedContactsPCEG{get; set;}
    public list<Potential_confirmed_external_guests__c> newPotentialConfirmedEGList;
    public list<Potential_confirmed_external_guests__c> PCEGtoBeDeleted;
    public Potential_confirmed_external_guests__c newPotentialConfirmedEG;
    public list<SelectedContactPCEG> PCEGWrapperList{get; set;}
        
    public String SelectedContactNamePresenter {get; set;}
    public String SelectedContactIdPresenter {get; set;}
    public List<Presenter__c> RelatedContactsPresenter{get; set;}
    public list<Presenter__c> newPresenterList;
    public list<Presenter__c> PresentertoBeDeleted;
    public Presenter__c newPresenter;
    public list<SelectedContactPresenter> PresenterWrapperList{get; set;}
    public Boolean IsMemberofAPTeam{get;set;}
    public static Boolean IsPrivilegedUserOnly{get;set;}
    public String SelectedTargetAudience {get; set;}
    
    //Filter Section Changes
    public Event_Expense__c eventExp{get;set;}
    public String submissionDateSelVal{get;set;}
    public String createdDateSelVal{get;set;}
    public list<SelectOption> dateSelectOptions {get; set;}
    public String logicCriteriaSelVal{get;set;}
    public list<SelectOption> logicCriteriaSelectOptions {get; set;}
    public list<SelectOption> statusSelectOptions {get; set;}
    public String evtExpNumberVal{get;set;}
    public final static String EVT_EXP_LOB_CF  = 'CF';
    public final static String EVT_EXP_LOB_FVA = 'FVA';    // Static String variable for LOB - FVA
    
    // Constructor
    public HL_EventExpenseClass(ApexPages.StandardController controller) {
        
        requiredForCF = requiredForCS = requiredForSE = requiredForCE = requiredForADMA = requiredForMKTGMT = requiredForMKTGMM = IsPrivilegedUserOnly = requiredForFVA = false;
        validUser = true;
        Contactselected = new contact();
        requesterContactList = new List<contact>();
        
        
        RelatedContactsLoTM = new List<List_of_team_member__c>();
        newListOfTeamMemberList = new List<List_of_team_member__c>();
        LoTMtoBeDeleted = new List<List_of_team_member__c>();
        LoTMWrapperList = new list<SelectedContactLoTM>();
                
        RelatedContactsPCEG = new List<Potential_confirmed_external_guests__c>();
        newPotentialConfirmedEGList = new List<Potential_confirmed_external_guests__c>();
        PCEGtoBeDeleted = new List<Potential_confirmed_external_guests__c>();
        PCEGWrapperList = new list<SelectedContactPCEG>();
                
        RelatedContactsPresenter = new List<Presenter__c>();
        newPresenterList = new List<Presenter__c>();
        PresentertoBeDeleted = new List<Presenter__c>();
        PresenterWrapperList = new list<SelectedContactPresenter>();
        
        EventExpenseRecordSize = new List<Event_Expense__c>();
        initialEventExpense = new Event_Expense__c();
        currentSelectedTab = 'MainTab';
        userid = UserInfo.getUserId();
        RelatedBankerIdSet = new Set<Id>();
        WhereClauseStr = '';
        sortDirection = 'DESC';
        TableTitle = '';
        sortQuery = null;
        actualRecords  = 0;
        
        // To check whether to create new record or edit record
        EventExpId = ApexPages.currentPage().getParameters().get('id');
        EventExpRetURLId = ApexPages.currentPage().getParameters().get('retUrl');
        if(EventExpId != null ){
            EveExpRecordList = [select id, Requestor_Name__c, Start_Date__c, Submitter__c,Specify__c, Name, CreatedDate, 
                                Industry_Group__c, Status__c, Title__c, Primary_Email__c, Event_Format__c, 
                                Primary_phone_number__c,LOB__c, Event_Contact__c, Product_Type__c, Event_Name__c, Event_location__c,
                                City__c, End_Date__c, Event_Type_Format__c, Event_Type_Format_Other__c, Event_Purpose__c,
                                What_is_desired_outcome_of_this_event__c, Target_Audience__c, Audience_Industry_if_applicable__c,
                                Number_of_guests__c, Who_is_evaluating_the_event__c, When_this_event_will_be_evaluated__c, What_are_KPIs__c,
                                Marketing_support__c, Marketing_support_Other__c, Related_campaign_if_30_guests__c,
                                Potential_Revenue__c, Expected_Travel_cost__c, Expected_F_B_cost__c,HL_Internal_Opportunity_Number__c,
                                Any_additional_cost_Specify__c, Total_Budget_Requested__c, SubLedger_Number__c, Any_additional_requests__c,
                                Notes__c, Submitted_Date__c, Requestor_s_User__c, Is_Clone__c, Expected_Airfare_Cost__c, Expected_Lodging_Cost__c, Expected_Registration_Fee__c,
                                Classification__c, Asked_to_Present__c, Onsite_Support_Needed__c, Event__c,Is_Actual_Date__c FROM Event_Expense__c WHERE Id=:EventExpId];
            EveExpRecord = EveExpRecordList[0];
            SelectedTargetAudience = EveExpRecordList[0].Target_Audience__c;
            if(!String.isEmpty(EveExpRecord.Event_Format__c)) 
                selectedEventFormat = EveExpRecord.Event_Format__c;      
                           
            RelatedContactsLoTM = [SELECT id, Contact__c, Event_Expense__c, Contact__r.Name, Contact__r.id, Contact__r.Title, Contact__r.Industry_Group__c 
                                   FROM List_of_team_member__c 
                                   WHERE Event_Expense__c=:EventExpId];
            if(RelatedContactsLoTM.size() > 0){
                for(List_of_team_member__c a:RelatedContactsLoTM){
                    LoTMWrapperList.add(new SelectedContactLoTM(a, a.Contact__r.id, a.Contact__r.Name, a.Contact__r.Title, a.Contact__r.Industry_Group__c));
                }
            }
            
            RelatedContactsPCEG = [ SELECT id, Contact__c, Event_Expense__c, Contact__r.Name, Contact__r.id, Contact__r.Title, Contact__r.Industry_Group__c 
                                    FROM Potential_confirmed_external_guests__c 
                                    WHERE Event_Expense__c=:EventExpId];
            if(RelatedContactsPCEG.size() > 0){
                for(Potential_confirmed_external_guests__c a:RelatedContactsPCEG){
                    PCEGWrapperList.add(new SelectedContactPCEG(a, a.Contact__r.id, a.Contact__r.Name, a.Contact__r.Title, a.Contact__r.Industry_Group__c));
                }
            }
            
            RelatedContactsPresenter = [SELECT id, Contact__c, Event_Expense__c, Contact__r.Name, Contact__r.id, Contact__r.Title, Contact__r.Industry_Group__c 
                                        FROM Presenter__c 
                                        WHERE Event_Expense__c=:EventExpId];
            if(RelatedContactsPresenter.size() > 0){
                for(Presenter__c a:RelatedContactsPresenter){
                    PresenterWrapperList.add(new SelectedContactPresenter(a, a.Contact__r.id, a.Contact__r.Name, a.Contact__r.Title, a.Contact__r.Industry_Group__c));
                }
            }            
            requiredOnPage();
        } else {
            EveExpRecord = new Event_Expense__c();
        }
        
        PageSizeValues = new List<SelectOption>();
        list<String> listofPageSize = new list<String>(); 
        EventExpenseCustomMetaData = new Event_Expense_Page_Size__mdt();
        EventExpenseCustomMetaData = [SELECT id, Default_Event_Expense_Page_Size__c, Event_Expense_Page_Size_Options__c 
                                      FROM Event_Expense_Page_Size__mdt 
                                      WHERE DeveloperName = 'EventExp'];
        
        if(EventExpenseCustomMetaData != null && EventExpenseCustomMetaData.Event_Expense_Page_Size_Options__c != null)
            listofPageSize = String.Valueof(EventExpenseCustomMetaData.Event_Expense_Page_Size_Options__c).split(',');
        
        for(String pagesize : listofPageSize)
            PageSizeValues.add(new SelectOption(pagesize, pagesize));        
        CurPageSize = Integer.ValueOf(EventExpenseCustomMetaData.Default_Event_Expense_Page_Size__c);
        
        //Filter Section Changes
        eventExp = new Event_Expense__c();
        dateSelectOptions = new List<SelectOption>();
        for(String dateOption : HL_ConstantsUtil.DATE_PARAM_MAP.keySet()){
          dateSelectOptions.add(new SelectOption(HL_ConstantsUtil.DATE_PARAM_MAP.get(dateOption), dateOption));
        }
        
        logicCriteriaSelectOptions = new List<SelectOption>();
        logicCriteriaSelectOptions.add(new SelectOption('AND', 'AND'));
        logicCriteriaSelectOptions.add(new SelectOption('OR', 'OR'));
        
        statusSelectOptions = new List<SelectOption>();
        for(Schema.PicklistEntry pickListVal : Event_Expense__c.Status__c.getDescribe().getPicklistValues()){
           statusSelectOptions.add(new selectoption(pickListVal.getvalue(), pickListVal.getlabel()));
        }
        
        buildEventExpenseList(null);

        if(!checkValidUser()){
            validUser = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.HL_EventExpenseRequiredPermission));
        }
        
        for(All_Event_Expense_User_VisibilitySetting__mdt EESetting : [Select User_Id__c From All_Event_Expense_User_VisibilitySetting__mdt])
        {
           if(EESetting.User_Id__c.length()>= 15 && EESetting.User_Id__c.substring(0,15) == userInfo.getUserId().substring(0,15))
            {   
                IsMemberofAPTeam = true;
                break;
            }
        }
        
        IsPrivilegedUserOnly = checkPrivilegedUserOnly();
    }
    
    //Filter Section Changes
    public list<SelectOption> getEvntFrmatValues(){
      
      list<selectoption> options = new List<SelectOption>{new SelectOption('None', '--None--')};
        
        if(HL_ConstantsUtil.EVENTTYPE_TO_EVENTFORMAT_MAP.containsKey(eventExp.Event_Type_Format__c)){             
          for(String evtFormat : HL_ConstantsUtil.EVENTTYPE_TO_EVENTFORMAT_MAP.get(eventExp.Event_Type_Format__c)){
            options.add(new SelectOption(evtFormat, evtFormat));
          }
        }       
        return options;
    }
    
    /*********************************************************************
    Method to reset the filter in the search section
    **********************************************************************/
    public void resetEventTypeAndFormat(){
      eventExp.Event_Type_Format__c = eventExp.Event_Format__c = null;
    }
    
    /*********************************************************************
    Method to apply the filter in the search section
    **********************************************************************/
    public PageReference applyFilter(){
     
      system.debug('-1. submissionDateSelVal-----' + submissionDateSelVal);
      system.debug('-2. createdDateSelVal-----' + createdDateSelVal);
      system.debug('-3. eventExp.Product_Type__c-----' + eventExp.Product_Type__c);
      system.debug('-4. eventExp.Requestor_Name__c-----' + eventExp.Requestor_Name__c);
      system.debug('-5. eventExp.Event_Name__c-----' + eventExp.Event_Name__c);
      system.debug('-6. evtExpNumberVal-----' + evtExpNumberVal);
      system.debug('-7. eventExp.LOB__c-----' + eventExp.LOB__c);
      system.debug('-9. eventExp.Status__c-----' + eventExp.Status__c);
      system.debug('-10.eventExp.Event_Type_Format__c-----' + eventExp.Event_Type_Format__c);
      system.debug('-11.logicCriteriaSelVal-----' + logicCriteriaSelVal);  
      system.debug('-12.eventExp.Event_Format__c-----' + eventExp.Event_Format__c);
      
      String whereClsFilterLogicStr = HL_ConstantsUtil.buildEventExpenseWhereClause(eventExp, logicCriteriaSelVal, submissionDateSelVal, createdDateSelVal, evtExpNumberVal);
      buildEventExpenseList(whereClsFilterLogicStr);
      return null;
    }
    
    /*********************************************************************
    Method to reset the filter in the search section
    **********************************************************************/
    public void resetFilter(){
      
      eventExp = new Event_Expense__c();
      evtExpNumberVal = '';
      logicCriteriaSelVal = 'AND';
      submissionDateSelVal = createdDateSelVal = 'None';
      //Clear out the search results
      EventExpenseList = new list<Event_Expense__c>();
      buildEventExpenseList(null);
    }
    //Filter Section Changes END
    
    //To check if user is allowed to view the page
    public static boolean checkValidUser(){
        
        boolean validUserBoolean = false;
        Profile loggedinUserProfile = [Select Name from Profile where Id =: userinfo.getProfileid() limit 1];
        
        Id currentRecordId = ApexPages.currentPage().getParameters().get('id');

        if(!validUserBoolean){
            Id internalContactRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Houlihan Employee').getRecordTypeId();
            Contact loggedinUserContact = new Contact();
            for(Contact c : [Select Id, RecordTypeId from Contact WHERE User__c =: UserInfo.getUserId() limit 1])
                loggedinUserContact = c;
            if(loggedinUserContact.RecordTypeId == internalContactRTId)
                validUserBoolean = true;
            if(validUserBoolean && currentRecordId != null)
                for(UserRecordAccess URA : [SELECT HasEditAccess,HasReadAccess, RecordID FROM UserRecordAccess WHERE RecordId =: currentRecordId AND  UserId =: UserInfo.getUserId() ])
                {
                        if(!URA.HasEditAccess && !URA.HasReadAccess)
                            validUserBoolean = false;
                }
        } 

        if(!validUserBoolean){
            
            if(currentRecordId != null){
                List<Event_Expense__Share> eventExpanseShareList = new List<Event_Expense__Share>();
                eventExpanseShareList = [SELECT Id FROM Event_Expense__Share WHERE ParentId=:currentRecordId AND UserOrGroupId=:UserInfo.getUserId()];
                if(eventExpanseShareList.size() > 0)
                    validUserBoolean = true;
                
            }
        }

        if(!validUserBoolean){
            if(loggedinUserProfile.Name == 'System Administrator')
                validUserBoolean = true;
        }

        if(!validUserBoolean){
            validUserBoolean = HL_Event_Expense_TriggerHandler.checkPrivilegedUser();
        }

        return validUserBoolean;
    }
    
    
    //To check if user Privileged User Only
    public boolean checkPrivilegedUserOnly(){
        
        boolean PrivilegedUserOnly = false;
        
        if(EveExpRecord.Status__c != 'Deleted' && EveExpRecord.Status__c != 'Saved' && !HL_Event_Expense_TriggerHandler.checkPrivilegedUser()){
            if(EveExpRecord.Requestor_s_User__c != UserInfo.getUserId()){
                list<Delegate_Public_Group_Member__c> dpgmList = [SELECT id from Delegate_Public_Group_Member__c WHERE Delegate_ID__c =: UserInfo.getUserId() AND Delegate_Public_Group__r.Banker__c =: EveExpRecord.Requestor_Name__c];
                if(dpgmList.size() == 0){
                    PrivilegedUserOnly = true;
                }
            }
        }
        return PrivilegedUserOnly;
    }
    
    public void buildEventExpenseList(String filteredWhereClause){
        
        sortField = null;
        for(Delegate_Public_Group_Member__c dpgm:[Select Delegate_Public_Group__r.Banker__c from Delegate_Public_Group_Member__c WHERE Delegate_ID__c =:UserInfo.getUserId()]){
            RelatedBankerIdSet.add(dpgm.Delegate_Public_Group__r.Banker__c);
        }
        WhereClauseStr  = ' Where ( Requestor_Name__r.User__c=: userid  OR Submitter__c=: userid OR Requestor_Name__r.User__c IN : RelatedBankerIdSet )  ';
        
        if(filteredWhereClause != null && filteredWhereClause != '')
          WhereClauseStr = WhereClauseStr + ' AND ( '+filteredWhereClause +' )';
        
        String query = sortQuery = ' select id, Event_Name__c, Requestor_Name__c, Requestor_Name__r.Name, Start_Date__c, Submitted_Date__c, Total_Budget_Requested__c, Industry_Group__c, Status__c, Event_Type_Format__c,  CreatedDate, Event_Format__c, Product_Type__c, Name FROM Event_Expense__c '+WhereClauseStr  ;
        
        Std_Set_controller  = new ApexPages.StandardSetController(Database.getQueryLocator(query+' ORDER BY CREATEDDATE DESC LIMIT 1000 '));
        TableTitle = 'Existing Expense Request ';  
        
        EventExpenseList = (List<Event_Expense__c>)Std_Set_controller.getRecords();
        EventExpenseRecordSize = Database.query(' select id from Event_Expense__c '+WhereClauseStr+' ORDER BY CREATEDDATE DESC LIMIT 1000');
        actualRecords = EventExpenseRecordSize.size();
        Std_Set_controller.setPageSize(CurPageSize);
        Std_Set_controller.first();
        fetchRelatedData();
        voidAction();
    }
    
    Public void fetchRelatedData(){ 
        EventExpenseList = (List<Event_Expense__c>)Std_Set_controller.getRecords();
    }
    
    
    //indicates whether there are more records after the current page set. 
    @TestVisible public Boolean hasNext {
        get {
            if(Std_Set_controller == null) return false;
            return Std_Set_controller.getHasNext();
        }
    }
     
    //indicates whether there are more records before the current page set.
    @TestVisible public Boolean hasPrevious {
        get {
            if(Std_Set_controller == null) return false;
                return Std_Set_controller.getHasPrevious();
            }
        }
     
    // returns the page number of the current page set 
    @TestVisible public Integer pageNumber {
        get {
            if(Std_Set_controller == null) return null;
            return Std_Set_controller.getPageNumber();
        }
        set{
            pageNumber = value;
        }
    }

    @TestVisible public Integer pageSize {
        get {
            if(Std_Set_controller == null) return 0;
            Integer prefix = (Math.mod((Long)Std_Set_controller.getResultSize(),(Long)Std_Set_controller.getPageSize()) != 0)? 1 : 0;
            return  (Std_Set_controller.getResultSize() / Std_Set_controller.getPageSize())+prefix;
        }
    }    

    // returns the first page of records 
    public void first()
    {
        if(Std_Set_controller != null)
        {            
            Std_Set_controller.first();
            
            fetchRelatedData();
        }
    }
     
    // returns the last page of records 
    public void last()
    {
        if(Std_Set_controller != null)
        {   
            Std_Set_controller.last();
           
            fetchRelatedData();
        }
    }
     
    //returns the previous page of records 
    public void previous() {
        if(Std_Set_controller != null)
        {            
            Std_Set_controller.previous();
            
            fetchRelatedData();
        }
    }
     
    // returns the next page of records 
    public void next() {
        if(Std_Set_controller != null)
        {            
            Std_Set_controller.next();
            
            fetchRelatedData();
        }
    }           
    
    // To save pagesize for manual change by User through page size drop down 
    public pageReference doSavePageSize()
    {       
        if(Std_Set_controller != null)
        {            
            voidAction();            
            Std_Set_controller.setPageSize(CurPageSize);
            //Std_Set_controller.Next();
            Std_Set_controller.first();                       
            fetchRelatedData();                       
        }
        return null;
    }
    
    
    public void goCurPageNumber()
    {
        if(Std_Set_controller != null)
        {
            if(this.CurPageNumber == null) 
                this.CurPageNumber = 0;                
            if(this.CurPageNumber<1) 
                this.CurPageNumber = 1;
            else if(this.CurPageNumber>pageSize) 
                this.CurPageNumber = pageSize;
           
            Std_Set_controller.setpageNumber(CurPageNumber);
            Std_Set_controller.setPageSize(CurPageSize);
            fetchRelatedData();       
        }
    }
    
    
    // To toggle order of list
    public void toggleSort() {
        String NullPriority = ' NULLS LAST ';
        sortDirection = sortDirection.equals('ASC') ? 'DESC' : 'ASC';
        if(sortDirection == 'ASC'){
                NullPriority = ' NULLS FIRST ';
        }
        else if(sortDirection == 'DESC'){
            NullPriority = ' NULLS LAST ';
        }               
        string finalsortQuery = sortQuery+ ' AND ID IN:EventExpenseRecordSize order by '+sortField +' ' +sortDirection +' '+NullPriority+' LIMIT 1000 ';
        list<Event_Expense__c > EEList = new List<Event_Expense__c>();
        EEList  = database.Query(finalsortQuery);
        Std_Set_controller  = new ApexPages.StandardSetController(Database.getQueryLocator(finalsortQuery));    
        Std_Set_controller.first();
        Std_Set_controller.setPageSize(CurPageSize);
        fetchRelatedData();
        voidAction();
    }
    
    // To maintain page Count
    public void voidAction(){ 
        pageCount = (EventExpenseRecordSize.size()-1)/CurPageSize;
        if (totalpageNumber >= pageCount) 
            totalpageNumber = (integer)pageCount;
        if (totalpageNumber < 0) totalpageNumber = 0;
    }
    
    
    
    // To Create new record
    public PageReference newEventExpenseRecord(){ 
    
        if(String.isEmpty(initialEventExpense.LOB__c)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.HL_LOB_Required));
            return null;
        }
        // Added condition initialEventExpense.LOB__c != EVT_EXP_LOB_FVA to disable error msg
        if(String.isEmpty(initialEventExpense.Event_Type_Format__c) && (initialEventExpense.LOB__c != EVT_EXP_LOB_CF)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.HL_Event_Type_Required));
            return null;
        }
        EveExpRecord.LOB__c = initialEventExpense.LOB__c;
        EveExpRecord.Event_Type_Format__c = initialEventExpense.Event_Type_Format__c;
        EveExpRecord.Status__c = 'Saved';
        requiredOnPage();
        PageReference reference=new PageReference('/apex/HL_EventExpenseEditPage');
        reference.setRedirect(false);
        return reference;
    }
    
        
    // To Save record
    public PageReference Save(){
        IsPrivilegedUserOnly = checkPrivilegedUserOnly();
            if(EveExpRecord.Marketing_support__c != 'Yes'){
                EveExpRecord.Marketing_support_Other__c = '';
            }
            EveExpRecord.Event_Format__c = selectedEventFormat;
            
            try{
                if(IsPrivilegedUserOnly)
                    EveExpRecord.Target_Audience__c = SelectedTargetAudience;
                upsert EveExpRecord;
            } catch (Exception e){
                ApexPages.addmessages(e);
                return null;
            }
            
            
            
          if(LoTMWrapperList.size() > 0){
                for(SelectedContactLoTM ar: LoTMWrapperList){
                    if(ar.ListOfTeamMember.id == null){
                        ar.ListOfTeamMember.Event_Expense__c = EveExpRecord.id;
                        newListOfTeamMemberList.add(ar.ListOfTeamMember);
                    }
                    
                }
                if(newListOfTeamMemberList.size() > 0){
                    upsert newListOfTeamMemberList;
                } 
            }           
            if(LoTMtoBeDeleted.size() > 0) delete LoTMtoBeDeleted;
            
            
            if(PCEGWrapperList.size() > 0){
                for(SelectedContactPCEG ar: PCEGWrapperList){
                    if(ar.PotentialConfirmedEG.id == null){
                        ar.PotentialConfirmedEG.Event_Expense__c = EveExpRecord.id;
                        newPotentialConfirmedEGList.add(ar.PotentialConfirmedEG);
                    }
                    
                }
                if(newPotentialConfirmedEGList.size() > 0){
                    upsert newPotentialConfirmedEGList;
                } 
            }           
            if(PCEGtoBeDeleted.size() > 0) delete PCEGtoBeDeleted;
            
            
            if(PresenterWrapperList.size() > 0){
                for(SelectedContactPresenter ar: PresenterWrapperList){
                    if(ar.Presenter.id == null){
                        ar.Presenter.Event_Expense__c = EveExpRecord.id;
                        newPresenterList.add(ar.Presenter);
                    }
                    
                }
                if(newPresenterList.size() > 0){
                    upsert newPresenterList;
                } 
            }           
            if(PresentertoBeDeleted.size() > 0) delete PresentertoBeDeleted;
            
            PageReference reference=new PageReference('/apex/HL_EventExpenseViewPage?id='+EveExpRecord.id);
            reference.setRedirect(false);
            return reference;
    }
    
    
    // Add contact record for List Of Team Member
    public PageReference AddContactForLoTM() {
        if (SelectedContactIdLOTM <> '') {
            for(SelectedContactLoTM LoTMContactID:LoTMWrapperList){
                if(LoTMContactID.ContactId == SelectedContactIdLOTM){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseDuplicateContactError));
                    SelectedContactIdLOTM = null;
                    SelectedContactNameLOTM = null;
                    return null;
                }
            }
            Contact Contactselected  = new Contact();
            for(Contact cont : [Select id, Name, Title, Industry_Group__c from Contact WHERE Id=:SelectedContactIdLOTM])
            {
                Contactselected = cont;
            }
            newListOfTeamMember = new List_of_team_member__c();
            newListOfTeamMember.Contact__c = Contactselected.id;
            LoTMWrapperList.add(new SelectedContactLoTM(newListOfTeamMember, Contactselected.id, Contactselected.Name, Contactselected.Title, Contactselected.Industry_Group__c));
                
            SelectedContactIdLOTM = null;
            SelectedContactNameLOTM = null;                    
        }
        return null;
    }
    
    //Removes Contact for List Of Team Member
    public void RemoveContactLoTM() {
        if (!String.isBlank(DelId)) {
            for (Integer i = 0; i < LoTMWrapperList.size(); i++) {
                if (LoTMWrapperList[i].ContactId == DelId) {
                    if(LoTMWrapperList[i].ListOfTeamMember.Id != null){
                        LoTMtoBeDeleted.add(LoTMWrapperList[i].ListOfTeamMember);
                    }
                    LoTMWrapperList.remove(i);
                    break;
                }
            }
        }
    }
    
    
    //Wrapper class for List Of Team Member
    public class SelectedContactLoTM {
        public List_of_team_member__c ListOfTeamMember {get; set;}
        Public string ContactId {get;set;}
        Public string ContactName {get;set;}
        Public string ContactTitle {get;set;}
        Public string ContactIndustry {get;set;}
        
        public SelectedContactLoTM(List_of_team_member__c lotm , String ConId, String s1, String s2, String s3) {
            ListOfTeamMember = lotm;
            ContactId = ConId;
            ContactName = s1;
            ContactTitle = s2;
            ContactIndustry = s3;
        }
    }
    
    
    
    // Add contact record for Potential Confirmed External Guest
    public PageReference AddContactForPCEG() {
        if (SelectedContactIdPCEG <> '') {
            for(SelectedContactPCEG PCEGContactID:PCEGWrapperList){
                if(PCEGContactID.ContactId == SelectedContactIdPCEG){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseDuplicateContactError));
                    SelectedContactIdPCEG = null;
                    SelectedContactNamePCEG = null;
                    return null;
                }
            }
            Contact Contactselected = new Contact();
            for(Contact c :  [Select id, Name, Title, Industry_Group__c from Contact WHERE Id=:SelectedContactIdPCEG])
                Contactselected = c;
            newPotentialConfirmedEG = new Potential_confirmed_external_guests__c();
            newPotentialConfirmedEG.Contact__c = Contactselected.id;
            PCEGWrapperList.add(new SelectedContactPCEG(newPotentialConfirmedEG, Contactselected.id, Contactselected.Name, Contactselected.Title, Contactselected.Industry_Group__c));
                
            SelectedContactIdPCEG = null;
            SelectedContactNamePCEG = null;                    
        }
        return null;
    }
    
    
    
    //Removes Contact for Potential Confirmed External Guest
    public void RemoveContactPCEG() {
        if (!String.isBlank(DelId)) {
            for (Integer i = 0; i < PCEGWrapperList.size(); i++) {
                if (PCEGWrapperList[i].ContactId == DelId) {
                    if(PCEGWrapperList[i].PotentialConfirmedEG.Id != null){
                        PCEGtoBeDeleted.add(PCEGWrapperList[i].PotentialConfirmedEG);
                    }
                    PCEGWrapperList.remove(i);
                    break;
                }
            }
        }
    }
    
    
    
    
    //Wrapper class for Potential Confirmed External Guest
    public class SelectedContactPCEG {
        public Potential_confirmed_external_guests__c PotentialConfirmedEG {get; set;}
        Public string ContactId {get;set;}
        Public string ContactName {get;set;}
        Public string ContactTitle {get;set;}
        Public string ContactIndustry {get;set;}
        
        public SelectedContactPCEG(Potential_confirmed_external_guests__c pceg , String ConId, String s1, String s2, String s3) {
            PotentialConfirmedEG = pceg;
            ContactId = ConId;
            ContactName = s1;
            ContactTitle = s2;
            ContactIndustry = s3;
        }
    }
    
    
    
    // Add contact record for Presenter
    public PageReference AddContactForPresenter() {
        if (SelectedContactIdPresenter <> '') {
            for(SelectedContactPresenter PresenterContactID:PresenterWrapperList){
                if(PresenterContactID.ContactId == SelectedContactIdPresenter){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseDuplicateContactError));
                    SelectedContactIdPresenter = null;
                    SelectedContactNamePresenter = null;
                    return null;
                }
            }
            contact Contactselected = new Contact();
            for(Contact c:  [Select id, Name, Title, Industry_Group__c from Contact WHERE Id=:SelectedContactIdPresenter])
                Contactselected = c;
            newPresenter = new Presenter__c();
            newPresenter.Contact__c = Contactselected.id;
            PresenterWrapperList.add(new SelectedContactPresenter(newPresenter, Contactselected.id, Contactselected.Name, Contactselected.Title, Contactselected.Industry_Group__c));
                
            SelectedContactIdPresenter = null;
            SelectedContactNamePresenter = null;                    
        }
        return null;
    }
    
    
    
    //Removes Contact for Presenter
    public void RemoveContactPresenter() {
        if (!String.isBlank(DelId)) {
            for (Integer i = 0; i < PresenterWrapperList.size(); i++) {
                if (PresenterWrapperList[i].ContactId == DelId) {
                    if(PresenterWrapperList[i].Presenter.Id != null){
                        PresentertoBeDeleted.add(PresenterWrapperList[i].Presenter);                        
                    }
                    PresenterWrapperList.remove(i);
                    break;
                }
            }
        }
    }
    
    
    
    
    //Wrapper class for Presenter
    public class SelectedContactPresenter {
        public Presenter__c Presenter {get; set;}
        Public string ContactId {get;set;}
        Public string ContactName {get;set;}
        Public string ContactTitle {get;set;}
        Public string ContactIndustry {get;set;}
        
        public SelectedContactPresenter(Presenter__c pre , String ConId, String s1, String s2, String s3) {
            Presenter = pre;
            ContactId = ConId;
            ContactName = s1;
            ContactTitle = s2;
            ContactIndustry = s3;
        }
    }
    
    // To click of Cancel
    public PageReference Cancel(){
        EventExpRetURLId = ApexPages.currentPage().getParameters().get('retUrl');
        if(EventExpRetURLId == null ){
            PageReference reference=new PageReference('/apex/HL_EventExpenseLandingPage');
            reference.setRedirect(false);
            return reference;
        }
        
            PageReference reference=new PageReference('/'+EventExpRetURLId);
            reference.setRedirect(false);
            return reference;
    }
    
    // To make different fields required
    public void requiredOnPage(){
        if(EveExpRecord.Event_Type_Format__c == 'MKTG – Conference/ Seminar' || EveExpRecord.Event_Type_Format__c == 'MKTG - Conference/ Seminar'){
            requiredForCS = true;
        }
        if(EveExpRecord.Event_Type_Format__c == 'ADM – Staff Entertainment' || EveExpRecord.Event_Type_Format__c == 'ADM - Staff Entertainment'){
            requiredForSE = true;
        }
        if(EveExpRecord.Event_Type_Format__c == 'MKTG – Client Entertainment' || EveExpRecord.Event_Type_Format__c == 'MKTG - Client Entertainment'){
            requiredForCE = true;
        }
        if(EveExpRecord.Event_Type_Format__c == 'ADM – Administrative' || EveExpRecord.Event_Type_Format__c == 'ADM - Administrative'){
            requiredForADMA = true;
        }
        if(EveExpRecord.Event_Type_Format__c == 'MKTG – Marketing Trip' || EveExpRecord.Event_Type_Format__c == 'MKTG - Marketing Trip'){
            requiredForMKTGMT = true;
        }
        if(EveExpRecord.Event_Type_Format__c == 'MKTG – Marketing Membership' || EveExpRecord.Event_Type_Format__c == 'MKTG - Marketing Membership'){
            requiredForMKTGMM = true;
        }
        if(EveExpRecord.LOB__c == EVT_EXP_LOB_CF){
            requiredForCF = true;
        }
        
        // Setting Flag true for LOB= FVA
         if(EveExpRecord.LOB__c == EVT_EXP_LOB_FVA){
            requiredForFVA = true;
        }
        
    }
    
    // Dependent picklist on the Visualforce page
    public PageReference getEventFormatValue()
    {
        getEventFormatOptions();
        return null;
    }
  
    
    // Options for Event Format Picklist
    public List<SelectOption> getEventFormatOptions()
    {
      
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None --'));

        if(EveExpRecord.Event_Type_Format__c == 'MKTG – Conference/ Seminar' || EveExpRecord.Event_Type_Format__c == 'MKTG - Conference/ Seminar'){
            options.add(new SelectOption('Branding and Leadership (IP)','Branding and Leadership (IP)'));
            options.add(new SelectOption('Conference/Seminar','Conference/Seminar'));
            options.add(new SelectOption('Networking Events','Networking Events'));
            options.add(new SelectOption('Professional Memberships','Professional Memberships'));
            options.add(new SelectOption('Sponsorship / Charity Events','Sponsorship / Charity Events'));
            options.add(new SelectOption('Talent Development','Talent Development'));
            options.add(new SelectOption('Other Professional Event','Other Professional Event'));
        }
        if(EveExpRecord.Event_Type_Format__c == 'MKTG – Client Entertainment' || EveExpRecord.Event_Type_Format__c == 'MKTG - Client Entertainment'){
            options.add(new SelectOption('Client Entertainment','Client Entertainment'));
            options.add(new SelectOption('Client Gifts','Client Gifts'));
            options.add(new SelectOption('Closing Party','Closing Party'));
            options.add(new SelectOption('External Client Meeting','External Client Meeting'));
            options.add(new SelectOption('Sporting Events','Sporting Events'));
            options.add(new SelectOption('Other Client Entertainment','Other Client Entertainment'));
        }
        if(EveExpRecord.Event_Type_Format__c == 'ADM – Staff Entertainment' || EveExpRecord.Event_Type_Format__c == 'ADM - Staff Entertainment'){
           options.add(new SelectOption('Staff Entertainment','Staff Entertainment'));
        } 
        if(EveExpRecord.Event_Type_Format__c == 'MKTG – Marketing Membership' || EveExpRecord.Event_Type_Format__c == 'MKTG - Marketing Membership'){
            options.add(new SelectOption('Marketing Membership','Marketing Membership'));
        } 
        if(EveExpRecord.Event_Type_Format__c == 'MKTG – Marketing Trip' || EveExpRecord.Event_Type_Format__c == 'MKTG - Marketing Trip'){
            options.add(new SelectOption('Local Marketing','Local Marketing'));
            options.add(new SelectOption('Regional Marketing','Regional Marketing'));
        }  
        if(EveExpRecord.Event_Type_Format__c == 'ADM – Administrative' || EveExpRecord.Event_Type_Format__c == 'ADM - Administrative'){
            options.add(new SelectOption('FVA Management Request','FVA Management Request'));
            options.add(new SelectOption('FY Annual Meeting','FY Annual Meeting'));
            options.add(new SelectOption('Service Line Request','Service Line Request'));
        }
        if(EveExpRecord.Event_Type_Format__c == 'Staff Entertainment'){
            options.add(new SelectOption('Staff Entertainment','Staff Entertainment'));
        }     
        if(EveExpRecord.Event_Type_Format__c == 'Client Entertainment'){
            options.add(new SelectOption('Client Entertainment','Client Entertainment'));
            options.add(new SelectOption('Client Gifts','Client Gifts'));
            options.add(new SelectOption('Closing Party','Closing Party'));
            options.add(new SelectOption('External Client Meeting','External Client Meeting'));
            options.add(new SelectOption('Other Client Entertainment','Other Client Entertainment'));
            options.add(new SelectOption('Sporting Events','Sporting Events'));
        }     
        if(EveExpRecord.Event_Type_Format__c == 'Conference/Seminar'){
            options.add(new SelectOption('Branding and Leadership (IP)','Branding and Leadership (IP)'));
            options.add(new SelectOption('Conference/Seminar','Conference/Seminar'));
            options.add(new SelectOption('Networking Events','Networking Events'));
            options.add(new SelectOption('Other Professional Event','Other Professional Event'));
            options.add(new SelectOption('Professional Memberships','Professional Memberships'));
            options.add(new SelectOption('Sponsorship / Charity Events','Sponsorship / Charity Events'));
            options.add(new SelectOption('Talent Development','Talent Development'));
        }    
        if(EveExpRecord.Event_Type_Format__c == 'Administrative'){
            options.add(new SelectOption('FY Annual Meeting','FY Annual Meeting'));
            options.add(new SelectOption('CF Management Request','CF Management Request'));
            options.add(new SelectOption('Service Line Request','Service Line Request'));
        } 
        if(EveExpRecord.Event_Type_Format__c == 'Marketing Trip'){
            options.add(new SelectOption('Local Marketing','Local Marketing'));
            options.add(new SelectOption('Regional Marketing','Regional Marketing'));
        } 
        if(EveExpRecord.Event_Type_Format__c == 'Marketing Membership'){
            options.add(new SelectOption('Marketing Membership','Marketing Membership'));
        }     
        if(EveExpRecord.Event_Type_Format__c == 'Charitable Donation Match'){
            options.add(new SelectOption('Sponsorship / Charity Events','Sponsorship / Charity Events'));
        }     
        return options;
    }
}