/**************************************************************
* Name : HL_EngCounterpartyContactCls
* Purpose : 
* Test Class : HL_Test_CounterpartyContactCls
***************************************************************/

Public Class HL_EngCounterpartyContactCls{
        
    // Public Properties 
    Public List<RelatedContactClass> RelatedContactList{get;set;}
    public Integer CurPageSize {get; set;}    
    public Integer CurPageNumber {get; set;}    
    public List<SelectOption> PageSizeValues {get; set;}        
    public string searchString{get;set;}        
    public String SelectedOption{get;set;}
    public Integer pageCount {get; set;}
    public Integer totalpageNumber {get; set;}
    public Engagement_Counterparty__c engCounterparty = new Engagement_Counterparty__c();
    public Set<Id> existingContactIdSet = new Set<Id>();
    public String sortField {get;set;}
    public String sortDirection {get;set;}
    public String sortQuery {get;set;}
    public String engCPCompany {get;set;}
    public String TableTitle {get;set;}
    public String conLastName {get;set;}
    public String conFirstName {get;set;}
    public String conTitle {get;set;}
    public String conCompanyName {get;set;}
    public String conDepartment {get;set;}
    public String conIndustryName {get;set;}
    public String filterString {get;set;}
    public boolean SearchSection {get;set;}
    //public Integer TotalNoOfRecords {get;set;}
    public List<Contact> TotalContactRecordList {get;set;}
    public Integer actualRecords {get;set;}
        
    //private Properties
    private Valuation_Period__mdt EngVPCustomMetaData;
    private ApexPages.StandardSetController Std_Set_controller ; 
    private Id EngagementCounterpartyId;    
    private Set<ID> CurSelIDsSet = new Set<ID>();
    private String queryName;
    private Id externalContactRT;
    private set<Id> IndstrycontactIdSet ;
    private List<Contact> ContactList;
    private String WhereClauseStr ;
    private String DELIMITER_COMMA  = '...';
    
    // Constructor
    Public HL_EngCounterpartyContactCls(){        
        init();
    }
    
    Public void init(){
        searchString = '';
		vacantFilters();
        sortDirection = 'DESC';
        SelectedOption = 'Name';
        sortField = null;
        sortQuery = null;
        WhereClauseStr = '';
        filterString = '';
		SearchSection  = false;
        TableTitle = '';
        //TotalNoOfRecords  = 0;
        actualRecords  = 0;
        RelatedContactList = new List<RelatedContactClass>();
        EngagementCounterpartyId = ApexPages.currentPage().getParameters().get('clid'); 
        PageSizeValues = new List<SelectOption>();
        list<String> listofPageSize = new list<String>(); 
        EngVPCustomMetaData = new Valuation_Period__mdt();
        EngVPCustomMetaData = [SELECT id, Default_Eng_CC_Page_Size__c, Eng_CC_Page_size_Option__c 
                                 FROM Valuation_Period__mdt
                               WHERE DeveloperName = 'EngVP'];
        if(EngVPCustomMetaData != null && EngVPCustomMetaData.Eng_CC_Page_size_Option__c != null)
            listofPageSize = String.Valueof(EngVPCustomMetaData.Eng_CC_Page_size_Option__c).split(',');
        for(String pagesize : listofPageSize)
            PageSizeValues.add(new SelectOption(pagesize, pagesize));        
        CurPageSize = Integer.ValueOf(EngVPCustomMetaData.Default_Eng_CC_Page_Size__c);        
        ContactList = new List<Contact>();
        externalContactRT = HL_Utility.GetRecordTypeId('External Contact');
        buildContactList();
    }
    
    List<Contact> CurrentContactsonPage ;
    // building Wrapper list of Contact
    Public void fetchRelatedData(){      
        CurrentContactsonPage = new List<Contact>();
         RelatedContactList = new List<RelatedContactClass>(); 
         if(Std_Set_controller != null){
            for(Contact cont: (List<Contact>)Std_Set_controller.getRecords()){
                CurrentContactsonPage.add(cont);
            }
            if(CurrentContactsonPage.size() > 0 )
                attachIndustryList(CurrentContactsonPage);
            for(Contact cont: (List<Contact>)Std_Set_controller.getRecords()){
                     RelatedContactList.add(new RelatedContactClass(CurSelIDsSet.contains(cont.ID), cont,cntrctSubsClsMap.get(cont.ID)[0],cntrctSubsClsMap.get(cont.ID)[1]));
             }
         }
    }
    private map<Id, List<String>> cntrctSubsClsMap ;
    //Init Action Method
    public void attachIndustryList( list <Contact> CurrentContactsonPage){    
        cntrctSubsClsMap = new map<Id, list<String>>();
        List<Contact> currentContacts = [Select id, (Select Industry__r.Name From Contact_Industries__r ) From Contact where Id IN :CurrentContactsonPage]; 
        for(contact cntrct : currentContacts){      
            list<String> subsLst = new list<String>();
            for(Industry_Focus__c indus : cntrct.Contact_Industries__r){
                subsLst.add(indus.Industry__r.Name);
            }         
            String subsFullLst = String.join(subsLst, ', '); 
            String subsFirst5Lst = '';
            if(subsLst.size() > 3){
                subsFirst5Lst = String.join(new List<String>{subsLst.get(0), subsLst.get(1), subsLst.get(2)}, ', ') + '...';
            }else{
                subsFirst5Lst = subsFullLst ;
            }
            cntrctSubsClsMap.put(cntrct.Id, new list<String>{subsFirst5Lst,subsFullLst});
        }
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
            refreshSelIDs();
            Std_Set_controller.first();
            
            fetchRelatedData();
        }
    }
     
    // returns the last page of records 
    public void last()
    {
        if(Std_Set_controller != null)
        {   
            refreshSelIDs();
            Std_Set_controller.last();
           
            fetchRelatedData();
        }
    }
     
    //returns the previous page of records 
    public void previous() {
        if(Std_Set_controller != null)
        {            
            refreshSelIDs();
            Std_Set_controller.previous();
            
            fetchRelatedData();
        }
    }
     
    // returns the next page of records 
    public void next() {
        if(Std_Set_controller != null)
        {            
            refreshSelIDs();
            Std_Set_controller.next();
            
            fetchRelatedData();
        }
    }       
    
    // To save pagesize for manual change by User through page size drop down 
    public void doSavePageSize()
    {        
        if(Std_Set_controller != null)
        {
            voidAction();
            CurSelIDsSet = new Set<Id>();
            //refreshSelIDs();
            Std_Set_controller.setPageSize(this.CurPageSize);
            Std_Set_controller.first();           
            fetchRelatedData();                       
        }
    }
    
    public void ClearSearchResults(){
        init();        
    }
    // To maintain Record Selection of different pages
    private void refreshSelIDs()
    {               
        if(RelatedContactList != null && RelatedContactList.size()>0)
        {                
            for(RelatedContactClass rlContdata :RelatedContactList)
            {
                if(rlContdata.contactRecord != null)
                {
                    if(rlContdata.isSelected){                            
                        CurSelIDsSet.add(rlContdata.contactRecord.ID);
                    }
                    else 
                        CurSelIDsSet.remove(rlContdata.contactRecord.ID);
                }
            }                
        }        
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
           
            refreshSelIDs();
            Std_Set_controller.setpageNumber(CurPageNumber);
            Std_Set_controller.setPageSize(CurPageSize);
            fetchRelatedData();       
        }
    }
    
    public PageReference SaveData() {
        Savepoint sp = Database.setSavepoint();                
        try{            
            refreshSelIDs();
            if(CurSelIDsSet.size() == 0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_NoContactSelected));
                return null;  
            }
            SaveChanges(); 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.confirm,Label.HL_ContactRecordAdded));
                   
        }
        catch(Exception e) {
            Database.rollback( sp );
            Apexpages.addMessages(e); 
        }        
        return null;
    } 
    
    // Core logic to save selected record(s)
    public void SaveChanges()
    {
        List<Engagement_Counterparty_Contact__c> ListOfengCounterContactsToInset = new List<Engagement_Counterparty_Contact__c>();
        if(CurSelIDsSet.size() > 0){
            for(Id contID : CurSelIDsSet){
                ListOfengCounterContactsToInset.add(new Engagement_Counterparty_Contact__c (Counterparty__c = EngagementCounterpartyId, Contact__c = contID, Type__c = 'Primary'));
            }
        }
                
        if(ListOfengCounterContactsToInset.size() > 0){
            insert ListOfengCounterContactsToInset;
            buildContactList();
			vacantFilters();
        }
    }   
    
    // Moving back to source engagement counter party record
    public PageReference BackToEngCounterParty()
    {
        return new pageReference('/'+EngagementCounterpartyId );
    }
    
		
    	
    public void vacantFilters() {
        conLastName = '';
        conFirstName = ''; 
        conTitle = '';
        conCompanyName = ''; 
        conDepartment = '';
        conIndustryName = '';
		filterString = '';
	}
            
    // Search Records based on provided search option and input by user
    public PageReference validateData() {
        vacantFilters();
        if(String.isBlank(searchString)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,Label.HL_EnterValue));
            return null;
        }
        
        String trimmedSearchString = searchString.trim();
        if(trimmedSearchString.length() < 2){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,Label.HL_StringLength));
            return null;
        }
        
        if(SelectedOption == '' || SelectedOption == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,Label.HL_SearchOption));
            return null;
        } 
        sortDirection = 'DESC';
        sortField = null;
        buildContactList();        
        return null;
    }
        
    // Core logic to search records based on given seatch filter option by user
    public void buildContactList(){
        SearchSection = false;
        if(EngagementCounterpartyId != null)
        {
            //contacts which are existing currently as Engagement counter party contact records
            existingContactIdSet = new Set<Id>();
            for(Engagement_Counterparty__c engCounterparty: [Select Id, Company__c,Company__r.Name,(Select Id, Contact__c, Counterparty__c
                                                             FROM Engagement_Counterparty_Contacts__r) 
                                                             FROM Engagement_Counterparty__c 
                                                             WHERE ID =: EngagementCounterpartyId])
            {
                for(Engagement_Counterparty_Contact__c ecc: engCounterparty.Engagement_Counterparty_Contacts__r){
                    existingContactIdSet.add(ecc.Contact__c);
                }
                engCPCompany = engCounterparty.Company__r.Name;
            }       
            
            if(searchString != null && searchString != ''){
                String trimmedSearchString = searchString.trim();
                queryName = trimmedSearchString + '%';                
                if(SelectedOption == 'Name'){
                    contactListBasedOnName();
                    TableTitle = 'Search Results';        
                }
                else if(SelectedOption == 'Company'){
                    contactListBasedOnCompany();
                    TableTitle = 'Search Results';
                }
                else if(SelectedOption == 'IndustryName'){
                    contactListBasedOnIndustryName();
                    TableTitle = 'Search Results';
                }                
                
            }else{
                /* This is a default option where we need to list those contacts which are associated with 
                   linkted company of Engagement Couterparty */
                WhereClauseStr  = ' Where RecordTypeId =: externalContactRT AND ID NOT IN:existingContactIdSet AND Account.Name =:engCPCompany ';
                String query = sortQuery = 'select id,Lastname,Firstname,Department,Title,AccountId,Account.Name,Status__c,Name from Contact '+WhereClauseStr  ;
                
                ContactList = Database.query('select id from Contact'+WhereClauseStr+' ORDER BY CREATEDDATE DESC LIMIT 1000');
                //TotalNoOfRecords = database.countquery('SELECT COUNT() from Contact'+WhereClauseStr+' ');
                actualRecords = ContactList.size();
                Std_Set_controller  = new ApexPages.StandardSetController(Database.getQueryLocator(query+' ORDER BY CREATEDDATE DESC LIMIT 1000 '));
                TableTitle = 'Contacts of '+engCPCompany;                  
            }
        }        
        //Std_Set_controller = new ApexPages.StandardSetController(ContactList); 
        Std_Set_controller.first();
        Std_Set_controller.setPageSize(CurPageSize);
        CurSelIDsSet = new Set<ID>();
        fetchRelatedData();
        voidAction();
    }
    
    // if "Name" radio Button is selected
    private void contactListBasedOnName(){
        WhereClauseStr  =  ' Where RecordTypeId =: externalContactRT AND ID NOT IN:existingContactIdSet AND (FirstName LIKE :queryName OR MiddleName LIKE :queryName OR LastName LIKE :queryName OR Name LIKE :queryName) ';
        String query = sortQuery = 'select id,Lastname,Firstname,Department,Title,AccountId,Account.Name,Status__c,Name from Contact '+WhereClauseStr;
        ContactList = Database.query('select id from Contact '+WhereClauseStr+' ORDER BY CREATEDDATE DESC LIMIT 1000  ');
        //TotalNoOfRecords = database.countquery('SELECT COUNT() from Contact'+WhereClauseStr+' ');
        actualRecords = ContactList.size();
        Std_Set_controller  = new ApexPages.StandardSetController(Database.getQueryLocator(query+' ORDER BY CREATEDDATE DESC LIMIT 1000 '));
    }
    
    // if "Company" radio Button is selected
    private void contactListBasedOnCompany(){
        WhereClauseStr = ' Where RecordTypeId =: externalContactRT AND ID NOT IN:existingContactIdSet AND Account.Name LIKE:queryName ';
        String query = sortQuery = 'select id,Lastname,Firstname,Department,Title,AccountId,Account.Name,Status__c,Name from Contact '+WhereClauseStr ;
        ContactList = Database.query('select id from Contact '+WhereClauseStr +' ORDER BY CREATEDDATE DESC LIMIT 1000 ');
        //TotalNoOfRecords = database.countquery('SELECT COUNT() from Contact'+WhereClauseStr+' LIMIT 50000 ');
        actualRecords = ContactList.size();
        Std_Set_controller  = new ApexPages.StandardSetController(Database.getQueryLocator(query+' ORDER BY CREATEDDATE DESC LIMIT 1000 '));
    }
    
    // if "Industry Name" radio Button is selected
    private void contactListBasedOnIndustryName(){
        IndstrycontactIdSet = new set<Id>();        
        for(Industry_Focus__c iFocus : [SELECT Id,Contact__c,Industry_Group__c,Industry__r.Name,Industry__c
                                        FROM Industry_Focus__c 
                                        WHERE Contact__c NOT IN : existingContactIdSet AND Industry__r.Name LIKE : queryName ORDER BY  Contact__r.CREATEDDATE DESC ])
        {            
            IndstrycontactIdSet.add(iFocus.Contact__c);
        }
        if(IndstrycontactIdSet.size() > 0)
        {
            WhereClauseStr = '  Where RecordTypeId =: externalContactRT AND Id IN : IndstrycontactIdSet ';
            String query = sortQuery = 'select id,Lastname,Firstname,Department,Title,AccountId,Account.Name,Status__c,Industry_Group__c,Name from Contact '+WhereClauseStr ;
            ContactList = Database.query('select id from Contact '+WhereClauseStr +' ORDER BY CREATEDDATE DESC  LIMIT 1000 ');
            //TotalNoOfRecords = database.countquery('SELECT COUNT() from Contact'+WhereClauseStr+' ');
            actualRecords = ContactList.size();
            Std_Set_controller  = new ApexPages.StandardSetController(Database.getQueryLocator(query+' ORDER BY CREATEDDATE DESC  LIMIT 1000 '));
        }
    }

    // To create radio button
    public List<SelectOption> getOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Name','Name')); 
        options.add(new SelectOption('Company','Company'));
        options.add(new SelectOption('IndustryName','Industry/Product Focus'));
        // options.add(new SelectOption('allFields','All Fields'));   //---"All Fields" Logic--- 
        return options; 
    }
    
    // To maintain page Count
    public void voidAction(){        
        pageCount = (ContactList.size()-1)/CurPageSize;
        if (totalpageNumber >= pageCount) 
            totalpageNumber = (integer)pageCount;
        if (totalpageNumber < 0) totalpageNumber = 0;
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
        string finalsortQuery = sortQuery+ ' AND ID IN:ContactList  order by '+sortField +' ' +sortDirection +' '+NullPriority+' LIMIT 1000 ';
        
        //ContactList = Database.query('Select id From Contact '+WhereClauseStr + ' AND ID IN:ContactList  order by '+sortField +' '+sortDirection +' '+NullPriority+' LIMIT 1000 ');
        //Std_Set_controller = new ApexPages.StandardSetController(ContactList);
        Std_Set_controller  = new ApexPages.StandardSetController(Database.getQueryLocator(finalsortQuery));     
        Std_Set_controller.first();
        Std_Set_controller.setPageSize(CurPageSize);
        CurSelIDsSet = new Set<ID>();
        fetchRelatedData();
        voidAction();
    }
        
    // Wrapper Class for Contact records
    Public Class RelatedContactClass{
        public boolean isSelected {get; set;}
        public Contact contactRecord {get; set;}
        public String subsFirst5Lst {get;set;}
        public String subsFullLst {get;set;}
        
        public RelatedContactClass(Boolean isChecked, Contact contactData, String first5IndustryRecords, String AllIndustryRecords)
        {
            contactRecord = contactData;
            isSelected = isChecked;
            subsFirst5Lst = first5IndustryRecords;
            subsFullLst = AllIndustryRecords;
        }
    }
          
    // To get record based on advance Filter
    public PageReference filteredRecords(){
		filterString = '';
        set<Id> IndstrycontactIdSet = new set<Id>();
        String LastNameString;
        String FirstNameString;
        String TitleString;
        String CompanyNameString;
        String DepartmentString;
        String conIndustryNameString;
        string filterDataWhereClause;
                
		if(String.isBlank(conLastName) && String.isBlank(conFirstName) && String.isBlank(conTitle) && String.isBlank(conCompanyName) && String.isBlank(conDepartment) && String.isBlank(conIndustryName)){
			buildContactList();
			return null;
		}
		
		filterDataWhereClause = ' WHERE Id IN : ContactList  ';
		
		if(!String.isBlank(conLastName)){
			String trimmedSearchString = conLastName.trim();
			LastNameString = '%'+ trimmedSearchString + '%';
			filterDataWhereClause = filterDataWhereClause +  ' AND LastName LIKE :LastNameString ';
			filterString = filterString + 'Last Name ('+trimmedSearchString+'), ';
		}
		
		if(!String.isBlank(conFirstName)){
			String trimmedSearchString = conFirstName.trim();
			FirstNameString = '%'+ trimmedSearchString + '%';
			filterDataWhereClause = filterDataWhereClause +  ' AND FirstName LIKE :FirstNameString ';
			filterString = filterString + 'First Name ('+trimmedSearchString+'), ';
		}
		
		if(!String.isBlank(conTitle)){
			String trimmedSearchString = conTitle.trim();
			TitleString = '%'+ trimmedSearchString + '%';
			filterDataWhereClause = filterDataWhereClause +  ' AND Title LIKE :TitleString ';
			filterString = filterString + 'Title ('+trimmedSearchString+'), ';
		}
		
		if(!String.isBlank(conCompanyName)){
			String trimmedSearchString = conCompanyName.trim();
			CompanyNameString = '%'+ trimmedSearchString + '%';
			filterDataWhereClause = filterDataWhereClause +  ' AND Account.Name LIKE :CompanyNameString ';
			filterString = filterString + 'Company Name ('+trimmedSearchString+'), ';
		}
		
		if(!String.isBlank(conDepartment)){
			String trimmedSearchString = conDepartment.trim();
			DepartmentString = '%'+ trimmedSearchString + '%';
			filterDataWhereClause = filterDataWhereClause +  ' AND Department LIKE :DepartmentString ';
			filterString = filterString + 'Department Name ('+trimmedSearchString+'), ';
		}
		
		if(!String.isBlank(conIndustryName)){
			String trimmedSearchString = conIndustryName.trim();
			conIndustryNameString = '%'+ trimmedSearchString + '%';
			for(Industry_Focus__c iFocus : [Select id, Contact__c from Industry_Focus__c WHERE Industry__r.Name LIKE : conIndustryNameString AND Contact__c IN :ContactList]){
				IndstrycontactIdSet.add(iFocus.Contact__c);
			}
			filterDataWhereClause = filterDataWhereClause +  ' AND ID IN : IndstrycontactIdSet ';
			filterString = filterString + 'Industry/Product Focus ('+trimmedSearchString+'), ';
		}
		
		if(!String.isBlank(filterString)){
			filterString = filterString.removeEnd(', ');
			SearchSection = true;
		}
		
		String query = 'select id,Lastname,Firstname,Department,Title,AccountId,Account.Name,Status__c,Name from Contact '+filterDataWhereClause ;
		system.debug(query);
		ContactList = Database.query('select id from Contact '+filterDataWhereClause +' ORDER BY CREATEDDATE DESC LIMIT 1000');
		system.debug(ContactList);
		Std_Set_controller  = new ApexPages.StandardSetController(Database.getQueryLocator(query+' ORDER BY CREATEDDATE DESC  LIMIT 1000'));
		Std_Set_controller.first();
		Std_Set_controller.setPageSize(CurPageSize);
		CurSelIDsSet = new Set<ID>();
		fetchRelatedData();
		voidAction();
		return null;
    }
}