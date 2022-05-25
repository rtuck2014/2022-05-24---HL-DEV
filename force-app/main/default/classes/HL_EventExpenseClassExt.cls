/********************************************************************************
* Apex Class Name: HL_EventExpenseClassExt
* Purpose: To display 2nd Table of requests pending for approval of logged in user
* Test Class : HL_Test_EventExpenseClass
*********************************************************************************/
public class HL_EventExpenseClassExt {
    
    // Public Properties
    public String sortDirectionAT {get;set;}
    public Integer CurPageSizeAT {get; set;}    
    public Integer CurPageNumberAT {get; set;}    
    public List<SelectOption> PageSizeValuesAT {get; set;}
    public List<Event_Expense__c> EventExpenseListAT {get; set;}
    public Integer pageCountAT {get; set;}
    public Integer totalpageNumberAT {get; set;}   
    public String sortQueryAT {get;set;}
    public Id useridAT{get;set;}
    public String sortFieldAT {get;set;}
    public String WhereClauseStrAT ;
    public Id EventExpIdAT ;
    public List<Event_Expense__c> EventExpenseRecordSizeAT;
    public Set<Id> allEventExpId;
    public ApexPages.StandardSetController Std_Set_controller_AT ; 
    private Event_Expense_Page_Size__mdt EventExpenseCustomMetaDataAT;
    public Integer actualRecordsAT {get;set;}
    
    //Filter Section Changes
    public Event_Expense__c eventExpAT{get;set;}
    public String submissionDateSelValAT{get;set;}
    public String createdDateSelValAT{get;set;}
    public list<SelectOption> dateSelectOptionsAT {get; set;}
    public String logicCriteriaSelValAT{get;set;}
    public list<SelectOption> logicCriteriaSelectOptionsAT {get; set;}
    public list<SelectOption> statusSelectOptionsAT {get; set;}
    public String evtExpNumberValAT{get;set;}
    
    // Constructor
    public HL_EventExpenseClassExt(ApexPages.StandardController controller) {
        
        EventExpenseRecordSizeAT = new List<Event_Expense__c>();
        allEventExpId = new Set<Id>();
        useridAT = UserInfo.getUserId();
        WhereClauseStrAT = '';
        sortDirectionAT = 'DESC';
        sortQueryAT = null;
        actualRecordsAT  = 0;
        
        EventExpenseListAT = new  List<Event_Expense__c>();       
        PageSizeValuesAT = new List<SelectOption>();
        list<String> listofPageSize = new list<String>(); 
        EventExpenseCustomMetaDataAT = new Event_Expense_Page_Size__mdt();
        EventExpenseCustomMetaDataAT = [SELECT id, Default_Event_Expense_Page_Size__c, Event_Expense_Page_Size_Options__c 
                                 FROM Event_Expense_Page_Size__mdt WHERE DeveloperName = 'EventExp'];
        
        if(EventExpenseCustomMetaDataAT != null && EventExpenseCustomMetaDataAT.Event_Expense_Page_Size_Options__c != null)
            listofPageSize = String.Valueof(EventExpenseCustomMetaDataAT.Event_Expense_Page_Size_Options__c).split(',');
        
        for(String pagesize : listofPageSize)
            PageSizeValuesAT.add(new SelectOption(pagesize, pagesize));       
        CurPageSizeAT = Integer.ValueOf(EventExpenseCustomMetaDataAT.Default_Event_Expense_Page_Size__c);
        
        //Filter Section Changes
        eventExpAT = new Event_Expense__c();
        dateSelectOptionsAT = new List<SelectOption>();
        for(String dateOption : HL_ConstantsUtil.DATE_PARAM_MAP.keySet()){
          dateSelectOptionsAT.add(new SelectOption(HL_ConstantsUtil.DATE_PARAM_MAP.get(dateOption), dateOption));
        }
        
        logicCriteriaSelectOptionsAT = new List<SelectOption>();
        logicCriteriaSelectOptionsAT.add(new SelectOption('AND', 'AND'));
        logicCriteriaSelectOptionsAT.add(new SelectOption('OR', 'OR'));
        
        statusSelectOptionsAT = new List<SelectOption>();
        for(Schema.PicklistEntry pickListVal : Event_Expense__c.Status__c.getDescribe().getPicklistValues()){
           statusSelectOptionsAT.add(new selectoption(pickListVal.getvalue(), pickListVal.getlabel()));
        }
        
        buildEventExpenseListAT(null);
        
    }
    
    //Filter Section Changes
    public list<SelectOption> getEvntFrmatValuesAT(){
      
      list<selectoption> options = new List<SelectOption>{new SelectOption('None', '--None--')};
        
        if(HL_ConstantsUtil.EVENTTYPE_TO_EVENTFORMAT_MAP.containsKey(eventExpAT.Event_Type_Format__c)){             
          for(String evtFormat : HL_ConstantsUtil.EVENTTYPE_TO_EVENTFORMAT_MAP.get(eventExpAT.Event_Type_Format__c)){
            options.add(new SelectOption(evtFormat, evtFormat));
          }
        }       
        return options;
    }
    
    /*********************************************************************
    Method to reset the filter in the search section
    **********************************************************************/
    public void resetEventTypeAndFormatAT(){
      eventExpAT.Event_Type_Format__c = eventExpAT.Event_Format__c = null;
    }
    
    /*********************************************************************
    Method to apply the filter in the search section
    **********************************************************************/
    public PageReference applyFilterAT(){
     
      system.debug('-1. submissionDateSelValAT-----' + submissionDateSelValAT);
      system.debug('-2. createdDateSelValAT-----' + createdDateSelValAT);
      system.debug('-3. eventExpAT.Product_Type__c-----' + eventExpAT.Product_Type__c);
      system.debug('-4. eventExpAT.Requestor_Name__c-----' + eventExpAT.Requestor_Name__c);
      system.debug('-5. eventExpAT.Event_Name__c-----' + eventExpAT.Event_Name__c);
      system.debug('-6. evtExpNumberValAT-----' + evtExpNumberValAT);
      system.debug('-7. eventExpAT.LOB__c-----' + eventExpAT.LOB__c);
      system.debug('-9. eventExpAT.Status__c-----' + eventExpAT.Status__c);
      system.debug('-10.eventExpAT.Event_Type_Format__c-----' + eventExpAT.Event_Type_Format__c);
      system.debug('-11.logicCriteriaSelValAT-----' + logicCriteriaSelValAT);  
      system.debug('-12.eventExpAT.Event_Format__c-----' + eventExpAT.Event_Format__c);
      
      String whereClsFilterLogicStrAT = HL_ConstantsUtil.buildEventExpenseWhereClause(eventExpAT, logicCriteriaSelValAT, submissionDateSelValAT, 
        createdDateSelValAT, evtExpNumberValAT);
      buildEventExpenseListAT(whereClsFilterLogicStrAT);
      return null;
    }
    
    /*********************************************************************
    Method to reset the filter in the search section
    **********************************************************************/
    public void resetFilterAT(){
      
      eventExpAT = new Event_Expense__c();
      evtExpNumberValAT = '';
      logicCriteriaSelValAT = 'AND';
      submissionDateSelValAT = createdDateSelValAT = 'None';
      //Clear out the search results
      EventExpenseListAT = new list<Event_Expense__c>();
      buildEventExpenseListAT(null);
    }
    //Filter Section Changes END
    
    /*********************************************************************
    Method to build main list of event Expenses to display
    **********************************************************************/
    public void buildEventExpenseListAT(String filteredWhereClause){
        
        sortFieldAT = null;
        string user_id = UserInfo.getUserId();
        for(Event_Expense_Approval_History__c eeah:[Select Id, Event_Expense__c from Event_Expense_Approval_History__c 
                                                    Where Approver__c =:user_id AND Is_Archive__c=:false AND Status__c =:'Pending'])
            allEventExpId.add(eeah.Event_Expense__c);
                
        if(allEventExpId.size() > 0){
            WhereClauseStrAT  = ' Where ID IN: allEventExpId ';
            
            if(filteredWhereClause != null && filteredWhereClause != '')
                WhereClauseStrAT  = WhereClauseStrAT  + ' AND ( '+filteredWhereClause +' )';
            
            String query = sortQueryAT = 'select id, Event_Name__c, Requestor_Name__c, Requestor_Name__r.Name, Start_Date__c, Total_Budget_Requested__c, Submitted_Date__c, Industry_Group__c, Status__c,  CreatedDate, Event_Format__c, Event_Type_Format__c, Product_Type__c, Name FROM Event_Expense__c '+WhereClauseStrAT  ;
            Std_Set_controller_AT  = new ApexPages.StandardSetController(Database.getQueryLocator(query+' ORDER BY CREATEDDATE DESC LIMIT 1000 '));
            EventExpenseListAT = (List<Event_Expense__c>)Std_Set_controller_AT.getRecords();
            
            EventExpenseRecordSizeAT = Database.query('select id from Event_Expense__c'+WhereClauseStrAT+' ORDER BY CREATEDDATE DESC LIMIT 1000');
            actualRecordsAT = EventExpenseRecordSizeAT.size();
            Std_Set_controller_AT.setPageSize(CurPageSizeAT);
            Std_Set_controller_AT.first();
            fetchRelatedDataAT();
            voidActionAT();
        }
    }
    /*********************************************************************
    Populating List from standard set controller
    **********************************************************************/
    Public void fetchRelatedDataAT(){              
        EventExpenseListAT = (List<Event_Expense__c>)Std_Set_controller_AT.getRecords();        
    }   
    
    //indicates whether there are more records after the current page set. 
    @TestVisible public Boolean hasNextAT {
        get {
            if(Std_Set_controller_AT == null) return false;
            return Std_Set_controller_AT.getHasNext();
        }
    }
     
    //indicates whether there are more records before the current page set.
    @TestVisible public Boolean hasPreviousAT {
        get {
            if(Std_Set_controller_AT == null) return false;
                return Std_Set_controller_AT.getHasPrevious();
            }
        }
     
    // returns the page number of the current page set 
    @TestVisible public Integer pageNumberAT {
        get {
            if(Std_Set_controller_AT == null) return null;
            return Std_Set_controller_AT.getPageNumber();
        }
        set{
            pageNumberAT = value;
        }
    }

    @TestVisible public Integer pageSizeAT {
        get {
            if(Std_Set_controller_AT == null) return 0;
            Integer prefix = (Math.mod((Long)Std_Set_controller_AT.getResultSize(),(Long)Std_Set_controller_AT.getPageSize()) != 0)? 1 : 0;
            return  (Std_Set_controller_AT.getResultSize() / Std_Set_controller_AT.getPageSize())+prefix;
        }
    }    

    // returns the first page of records 
    public void firstAT()
    {
        if(Std_Set_controller_AT != null)
        {            
            Std_Set_controller_AT.first();
            
            fetchRelatedDataAT();
        }
    }
     
    // returns the last page of records 
    public void lastAT()
    {
        if(Std_Set_controller_AT != null)
        {   
            Std_Set_controller_AT.last();           
            fetchRelatedDataAT();
        }
    }
     
    //returns the previous page of records 
    public void previousAT() {
        if(Std_Set_controller_AT != null)
        {            
            Std_Set_controller_AT.previous();            
            fetchRelatedDataAT();
        }
    }
     
    // returns the next page of records 
    public void nextAT() {
        if(Std_Set_controller_AT != null)
        {            
            Std_Set_controller_AT.next();            
            fetchRelatedDataAT();
        }
    }           
    
    // To save pagesize for manual change by User through page size drop down 
    public pageReference doSavePageSizeAT()
    {       
        if(Std_Set_controller_AT != null)
        {            
            voidActionAT();            
            Std_Set_controller_AT.setPageSize(CurPageSizeAT);
            Std_Set_controller_AT.first();                       
            fetchRelatedDataAT();                       
        }
        return null;
    }
        
    public void goCurPageNumberAT()
    {
        if(Std_Set_controller_AT != null)
        {
            if(this.CurPageNumberAT == null) 
                this.CurPageNumberAT = 0;                
            if(this.CurPageNumberAT<1) 
                this.CurPageNumberAT = 1;
            else if(this.CurPageNumberAT>pageSizeAT) 
                this.CurPageNumberAT = pageSizeAT;           
            Std_Set_controller_AT.setpageNumber(CurPageNumberAT);
            Std_Set_controller_AT.setPageSize(CurPageSizeAT);
            fetchRelatedDataAT();       
        }
    }
        
    // To toggle order of list
    public void toggleSortAT() {
        String NullPriority = ' NULLS LAST ';
        sortDirectionAT = sortDirectionAT.equals('ASC') ? 'DESC' : 'ASC';
        if(sortDirectionAT == 'ASC'){
                NullPriority = ' NULLS FIRST ';
        }
        else if(sortDirectionAT == 'DESC'){
            NullPriority = ' NULLS LAST ';
        }               
        string finalsortQueryAT = sortQueryAT+ ' AND ID IN:EventExpenseRecordSizeAT  order by '+sortFieldAT +' ' +sortDirectionAT +' '+NullPriority+' LIMIT 1000 ';
        system.debug('---'+finalsortQueryAT);        
        Std_Set_controller_AT  = new ApexPages.StandardSetController(Database.getQueryLocator(finalsortQueryAT));     
        Std_Set_controller_AT.first();
        Std_Set_controller_AT.setPageSize(CurPageSizeAT);
        fetchRelatedDataAT();
        voidActionAT();
    }
    
    // To maintain page Count
    public void voidActionAT(){
        pageCountAT = (EventExpenseRecordSizeAT.size()-1)/CurPageSizeAT;
        if (totalpageNumberAT >= pageCountAT) 
            totalpageNumberAT = (integer)pageCountAT;
        if (totalpageNumberAT < 0) totalpageNumberAT = 0;
    }
}