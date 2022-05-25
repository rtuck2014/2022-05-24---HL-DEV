/********************************************************************************
* Apex Class Name: HL_EventExpenseClassExt2
* Purpose: To display 3rd Table for all requests to CAO and  System Admins
* Test Class : HL_EventExpenseClassExt
*********************************************************************************/
public class HL_EventExpenseClassExt2 {
    
    // Public Properties
    public String sortDirectionAT2 {get;set;}
    public Integer CurPageSizeAT2 {get; set;}    
    public Integer CurPageNumberAT2 {get; set;}    
    public List<SelectOption> PageSizeValuesAT2 {get; set;}
    public List<Event_Expense__c> EventExpenseListAT2 {get; set;}
    public Integer pageCountAT2 {get; set;}
    public Integer totalpageNumberAT2 {get; set;}   
    public String sortQueryAT2 {get;set;}
    public Id useridAT2{get;set;}
    public String sortFieldAT2 {get;set;}
    public String WhereClauseStrAT2 ;
    public Id EventExpIdAT2 ;
    public List<Event_Expense__c> EveExpRecordListAT2{get;set;}    
    public List<Event_Expense__c> EventExpenseRecordSizeAT2;
    public Set<Id> allEventExpId2;
    public ApexPages.StandardSetController Std_Set_controller_AT2 ; 
    private Event_Expense_Page_Size__mdt EventExpenseCustomMetaDataAT2;
    public Integer actualRecordsAT2 {get;set;}
    public Boolean IsMemberofEventExpenseCAOVisibility{get;set;}
    
    //Filter Section Changes
    public Event_Expense__c eventExpAT2{get;set;}
    public String submissionDateSelValAT2{get;set;}
    public String createdDateSelValAT2{get;set;}
    public list<SelectOption> dateSelectOptionsAT2 {get; set;}
    public String logicCriteriaSelValAT2{get;set;}
    public list<SelectOption> logicCriteriaSelectOptionsAT2 {get; set;}
    public list<SelectOption> statusSelectOptionsAT2 {get; set;}
    public String evtExpNumberValAT2{get;set;}
    
    // Constructor
    public HL_EventExpenseClassExt2(ApexPages.StandardController controller) {
        
        EventExpenseRecordSizeAT2 = new List<Event_Expense__c>();
        allEventExpId2 = new Set<Id>();
        useridAT2 = UserInfo.getUserId();
        WhereClauseStrAT2 = '';
        sortDirectionAT2 = 'DESC';
        sortQueryAT2 = null;
        actualRecordsAT2  = 0;
        
        EventExpenseListAT2 = new  List<Event_Expense__c>();       
        PageSizeValuesAT2 = new List<SelectOption>();
        list<String> listofPageSize = new list<String>(); 
        EventExpenseCustomMetaDataAT2 = new Event_Expense_Page_Size__mdt();
        EventExpenseCustomMetaDataAT2 = [SELECT id, Default_Event_Expense_Page_Size__c, Event_Expense_Page_Size_Options__c 
                                         FROM Event_Expense_Page_Size__mdt WHERE DeveloperName = 'EventExp'];
        
        if(EventExpenseCustomMetaDataAT2 != null && EventExpenseCustomMetaDataAT2.Event_Expense_Page_Size_Options__c != null)
            listofPageSize = String.Valueof(EventExpenseCustomMetaDataAT2.Event_Expense_Page_Size_Options__c).split(',');
        
        for(String pagesize : listofPageSize)
            PageSizeValuesAT2.add(new SelectOption(pagesize, pagesize));       
        CurPageSizeAT2 = Integer.ValueOf(EventExpenseCustomMetaDataAT2.Default_Event_Expense_Page_Size__c);
        
        //Filter Section Changes
        eventExpAT2 = new Event_Expense__c();
        dateSelectOptionsAT2 = new List<SelectOption>();
        for(String dateOption : HL_ConstantsUtil.DATE_PARAM_MAP.keySet()){
            dateSelectOptionsAT2.add(new SelectOption(HL_ConstantsUtil.DATE_PARAM_MAP.get(dateOption), dateOption));
        }
        
        logicCriteriaSelectOptionsAT2 = new List<SelectOption>();
        logicCriteriaSelectOptionsAT2.add(new SelectOption('AND', 'AND'));
        logicCriteriaSelectOptionsAT2.add(new SelectOption('OR', 'OR'));
        
        statusSelectOptionsAT2 = new List<SelectOption>();
        for(Schema.PicklistEntry pickListVal : Event_Expense__c.Status__c.getDescribe().getPicklistValues()){
            statusSelectOptionsAT2.add(new selectoption(pickListVal.getvalue(), pickListVal.getlabel()));
        }
        
        IsMemberofEventExpenseCAOVisibility = HL_ConstantsUtil.EventExpenseNonCAOPrivilegedUsers();
        
        buildEventExpenseListAT2(null);
        
    }
    
    //Filter Section Changes
    public list<SelectOption> getEvntFrmatValuesAT2(){
        
        list<selectoption> options = new List<SelectOption>{new SelectOption('None', '--None--')};
            
            if(HL_ConstantsUtil.EVENTTYPE_TO_EVENTFORMAT_MAP.containsKey(eventExpAT2.Event_Type_Format__c)){             
                for(String evtFormat : HL_ConstantsUtil.EVENTTYPE_TO_EVENTFORMAT_MAP.get(eventExpAT2.Event_Type_Format__c)){
                    options.add(new SelectOption(evtFormat, evtFormat));
                }
            }       
        return options;
    }
    
    /*********************************************************************
        Method to reset the filter in the search section
        **********************************************************************/
    public void resetEventTypeAndFormatAT2(){
        eventExpAT2.Event_Type_Format__c = eventExpAT2.Event_Format__c = null;
    }
    
    /*********************************************************************
        Method to apply the filter in the search section
        **********************************************************************/
    public PageReference applyFilterAT2(){
        
        system.debug('-1. submissionDateSelValAT2-----' + submissionDateSelValAT2);
        system.debug('-2. createdDateSelValAT2-----' + createdDateSelValAT2);
        system.debug('-3. eventExpAT2.Product_Type__c-----' + eventExpAT2.Product_Type__c);
        system.debug('-4. eventExpAT2.Requestor_Name__c-----' + eventExpAT2.Requestor_Name__c);
        system.debug('-5. eventExpAT2.Event_Name__c-----' + eventExpAT2.Event_Name__c);
        system.debug('-6. evtExpNumberValAT2-----' + evtExpNumberValAT2);
        system.debug('-7. eventExpAT2.LOB__c-----' + eventExpAT2.LOB__c);
        system.debug('-9. eventExpAT2.Status__c-----' + eventExpAT2.Status__c);
        system.debug('-10.eventExpAT2.Event_Type_Format__c-----' + eventExpAT2.Event_Type_Format__c);
        system.debug('-11.logicCriteriaSelValAT2-----' + logicCriteriaSelValAT2);  
        system.debug('-12.eventExpAT2.Event_Format__c-----' + eventExpAT2.Event_Format__c);
        
        String whereClsFilterLogicStrAT2 = HL_ConstantsUtil.buildEventExpenseWhereClause(eventExpAT2, logicCriteriaSelValAT2, submissionDateSelValAT2, 
        createdDateSelValAT2, evtExpNumberValAT2);
        system.debug('whereClsFilterLogicStrAT2::>>   '+whereClsFilterLogicStrAT2);
          buildEventExpenseListAT2(whereClsFilterLogicStrAT2);
          return null; 
        
    }
    
    /*********************************************************************
Method to reset the filter in the search section
**********************************************************************/
    public void resetFilterAT2(){
        
        eventExpAT2 = new Event_Expense__c();
        evtExpNumberValAT2 = '';
        logicCriteriaSelValAT2 = 'AND';
        submissionDateSelValAT2 = createdDateSelValAT2 = '--None--';
        //Clear out the search results
        EventExpenseListAT2 = new list<Event_Expense__c>();
        buildEventExpenseListAT2(null);
    }
    //Filter Section Changes END
    
    /*********************************************************************
Method to build main list of event Expenses to display
**********************************************************************/
    public void buildEventExpenseListAT2(String filteredWhereClause){
        
        sortFieldAT2 = null;
        string user_id = UserInfo.getUserId();
        
        Boolean  isSystemAdmin  = false;
        Boolean  isCAO  = false;
        Boolean  isOthers = false;
        
        for(Profile P : [Select Name From Profile Where Id =: UserInfo.getProfileId()])
        {
            If(P.Name == 'System Administrator')
                WhereClauseStrAT2  = ' Where Id != null  ';
            else if(P.Name == 'CAO' || IsMemberofEventExpenseCAOVisibility)
                isCAO  = true;
            else
                WhereClauseStrAT2  = ' Where Id != null  ';
        }
        if(isCAO)
            for(Contact c : [Select Line_of_Business__c  From Contact Where User__c =: UserInfo.getUserId() Limit 1])
            WhereClauseStrAT2  = ' Where LOB__c = \''+c.Line_of_Business__c+'\'  ';
        
        if(filteredWhereClause != null && filteredWhereClause != '')
            WhereClauseStrAT2  = WhereClauseStrAT2  + ' AND ( '+filteredWhereClause +' )';
        
        String query = sortQueryAT2 = 'select id, Event_Name__c, Requestor_Name__c, Requestor_Name__r.Name, Start_Date__c, Total_Budget_Requested__c, Submitted_Date__c, Industry_Group__c, Status__c, Event_Type_Format__c, CreatedDate,Event_Format__c, Product_Type__c, Name FROM Event_Expense__c '+WhereClauseStrAT2  ;
        system.debug('=='+query+'************');
        Std_Set_controller_AT2  = new ApexPages.StandardSetController(Database.getQueryLocator(query+' ORDER BY CREATEDDATE DESC LIMIT 1000 '));
        EventExpenseListAT2 = (List<Event_Expense__c>)Std_Set_controller_AT2.getRecords();
        
        EventExpenseRecordSizeAT2 = Database.query('select id from Event_Expense__c'+WhereClauseStrAT2+' ORDER BY CREATEDDATE DESC LIMIT 1000');
        actualRecordsAT2 = EventExpenseRecordSizeAT2.size();
        Std_Set_controller_AT2.setPageSize(CurPageSizeAT2);
        Std_Set_controller_AT2.first();
        fetchRelatedDataAT();
        voidActionAT2();
        
    }
    /*********************************************************************
Populating List from standard set controller
**********************************************************************/
    Public void fetchRelatedDataAT(){              
        EventExpenseListAT2 = (List<Event_Expense__c>)Std_Set_controller_AT2.getRecords();        
    }   
    
    //indicates whether there are more records after the current page set. 
    @TestVisible public Boolean hasNextAT2 {
        get {
            if(Std_Set_controller_AT2 == null) return false;
            return Std_Set_controller_AT2.getHasNext();
        }
    }
    
    //indicates whether there are more records before the current page set.
    @TestVisible public Boolean hasPreviousAT2 {
        get {
            if(Std_Set_controller_AT2 == null) return false;
            return Std_Set_controller_AT2.getHasPrevious();
        }
    }
    
    // returns the page number of the current page set 
    @TestVisible public Integer pageNumberAT2 {
        get {
            if(Std_Set_controller_AT2 == null) return null;
            return Std_Set_controller_AT2.getPageNumber();
        }
        set{
            pageNumberAT2 = value;
        }
    }
    
    @TestVisible public Integer pageSizeAT2 {
        get {
            if(Std_Set_controller_AT2 == null) return 0;
            Integer prefix = (Math.mod((Long)Std_Set_controller_AT2.getResultSize(),(Long)Std_Set_controller_AT2.getPageSize()) != 0)? 1 : 0;
            return  (Std_Set_controller_AT2.getResultSize() / Std_Set_controller_AT2.getPageSize())+prefix;
        }
    }    
    
    // returns the first page of records 
    public void firstAT2()
    {
        if(Std_Set_controller_AT2 != null)
        {            
            Std_Set_controller_AT2.first();
            
            fetchRelatedDataAT();
        }
    }
    
    // returns the last page of records 
    public void lastAT2()
    {
        if(Std_Set_controller_AT2 != null)
        {   
            Std_Set_controller_AT2.last();           
            fetchRelatedDataAT();
        }
    }
    
    //returns the previous page of records 
    public void previousAT2() {
        if(Std_Set_controller_AT2 != null)
        {            
            Std_Set_controller_AT2.previous();            
            fetchRelatedDataAT();
        }
    }
    
    // returns the next page of records 
    public void nextAT2() {
        if(Std_Set_controller_AT2 != null)
        {            
            Std_Set_controller_AT2.next();            
            fetchRelatedDataAT();
        }
    }           
    
    // To save pagesize for manual change by User through page size drop down 
    public pageReference doSavePageSizeAT2()
    {       
        if(Std_Set_controller_AT2 != null)
        {            
            voidActionAT2();            
            Std_Set_controller_AT2.setPageSize(CurPageSizeAT2);
            Std_Set_controller_AT2.first();                       
            fetchRelatedDataAT();                       
        }
        return null;
    }
    
    public void goCurPageNumberAT2()
    {
        if(Std_Set_controller_AT2 != null)
        {
            if(this.CurPageNumberAT2 == null) 
                this.CurPageNumberAT2 = 0;                
            if(this.CurPageNumberAT2<1) 
                this.CurPageNumberAT2 = 1;
            else if(this.CurPageNumberAT2>pageSizeAT2) 
                this.CurPageNumberAT2 = pageSizeAT2;           
            Std_Set_controller_AT2.setpageNumber(CurPageNumberAT2);
            Std_Set_controller_AT2.setPageSize(CurPageSizeAT2);
            fetchRelatedDataAT();       
        }
    }
    
    // To toggle order of list
    public void toggleSortAT2() {
        String NullPriority = ' NULLS LAST ';
        sortDirectionAT2 = sortDirectionAT2.equals('ASC') ? 'DESC' : 'ASC';
        if(sortDirectionAT2 == 'ASC'){
            NullPriority = ' NULLS FIRST ';
        }
        else if(sortDirectionAT2 == 'DESC'){
            NullPriority = ' NULLS LAST ';
        }               
        string finalsortQueryAT2 = sortQueryAT2+ ' AND ID IN:EventExpenseRecordSizeAT2  order by '+sortFieldAT2 +' ' +sortDirectionAT2 +' '+NullPriority+' LIMIT 1000 ';
        
        Std_Set_controller_AT2  = new ApexPages.StandardSetController(Database.getQueryLocator(finalsortQueryAT2));     
        Std_Set_controller_AT2.first();
        Std_Set_controller_AT2.setPageSize(CurPageSizeAT2);
        fetchRelatedDataAT();
        voidActionAT2();
    }
    
    // To maintain page Count
    public void voidActionAT2(){
        pageCountAT2 = (EventExpenseRecordSizeAT2.size()-1)/CurPageSizeAT2;
        if (totalpageNumberAT2 >= pageCountAT2) 
            totalpageNumberAT2 = (integer)pageCountAT2;
        if (totalpageNumberAT2 < 0) totalpageNumberAT2 = 0;
    }
}