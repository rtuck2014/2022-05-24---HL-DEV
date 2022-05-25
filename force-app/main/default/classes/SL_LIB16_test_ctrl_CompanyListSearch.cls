@isTest(SeeAllData=true)
private class SL_LIB16_test_ctrl_CompanyListSearch 
{
	public static testMethod void testMethod1() {

		SL_LIB16_install controller_pre = new SL_LIB16_install();
		controller_pre.runChecker();
		
		
		String cid;
		Company_List__c compLst = new Company_List__c(Name='Test001');
		insert compLst;
		cid = compLst.Id;
		SL_LIB16_ctrl_CompanyListSearch controller = new SL_LIB16_ctrl_CompanyListSearch();
		controller.getCurrMainCusSettings();
		
		
		System.currentPageReference().getParameters().put('clid',''+cid);
		System.currentPageReference().getParameters().put('target','Main');
		
		System.currentPageReference().getParameters().put('implId',''+controller_pre.ME_CompanyList_ObjID);

		controller = new SL_LIB16_ctrl_CompanyListSearch();
		controller.strColumnsAndFiltersTemplate = 'All';

		List<SelectOption> cutTabs = controller.getTabs();
		controller.setTabs(cutTabs);
		

		system.debug('======== hasNext ======== >>>> '+controller.hasNext);
		system.debug('======== hasPrevious ======== >>>> '+controller.hasPrevious);
		system.debug('======== pageNumber ======== >>>> '+controller.pageNumber);
		system.debug('======== pageSize ======== >>>> '+controller.pageSize);

		controller.doSearch();
		String str = controller.CompanyListID;
		
		system.debug('======== CompanyList ======== >>>> '+controller.CompanyList);
		controller.sortExpression = 'Name';
		controller.setSortDirection('ASC');
		system.debug('======== getSortDirection ======== >>>> '+controller.getSortDirection());
		List<Account> accs = new List<Account>();
		accs.add(new Account(Name = 'Test 1'));
		accs.add(new Account(Name = 'Test 2'));
		accs.add(new Account(Name = 'Test 3'));
		insert accs;
		controller.m_std_controller = new ApexPages.Standardsetcontroller([select Id,Name from Account limit 3]);
		//system.debug('======== getAccounts ======== >>>> '+controller.getAccounts());
		if(controller.getItems()!=null && controller.getItems().size()>0){ controller.getItems()[0].checked = true;}
		controller.process();
		system.debug('======== hasNext ======== >>>> '+controller.hasNext);
		system.debug('======== hasPrevious ======== >>>> '+controller.hasPrevious);
		system.debug('======== pageNumber ======== >>>> '+controller.pageNumber);
		system.debug('======== pageSize ======== >>>> '+controller.pageSize);
		controller.first();
		controller.last();
		controller.previous();
		controller.next();
		controller.cancel();
		controller.doSaveStep2();
		controller.doSaveAndMoreStep2();
		controller.doCancelStep2();
		
		controller.doAdd();
		controller.doAddContinue();
		controller.getColumnsShown();
		
		
		controller.getMassEditSettings();
		controller.btnGo();
		controller.fetchTemplateColumnAndFilterConditions();
		
		Account currComp = new Account(Name = 'Test Company 1');
		insert currComp;
		Account currComp2 = new Account(Name = 'Test Company 2');
		insert currComp2;
		Account currComp3 = new Account(Name = 'Test Company 3');
		insert currComp3;
		Company_List__c cmpList = new Company_List__c(Name='Test001');
		insert cmpList;
		Company_List_Member__c clm = new Company_List_Member__c(Company__c = currComp.Id, Company_List__c = cmpList.Id);
		insert clm;
		
		SL_LIB16_ctrl_CompanyListSearch.CompanyExtend CEItem = new SL_LIB16_ctrl_CompanyListSearch.CompanyExtend();
		CEItem = new SL_LIB16_ctrl_CompanyListSearch.CompanyExtend(currComp2);
		CEItem = new SL_LIB16_ctrl_CompanyListSearch.CompanyExtend(currComp2,true);
		SL_LIB16_ctrl_CompanyListSearch.CompanyExtend CEItem2 = new SL_LIB16_ctrl_CompanyListSearch.CompanyExtend(currComp3,false);
		
		List<SL_LIB16_ctrl_CompanyListSearch.CompanyExtend> lstMComps = new List<SL_LIB16_ctrl_CompanyListSearch.CompanyExtend>();
		lstMComps.add(CEItem);
		lstMComps.add(CEItem2);
		
		CEItem2.getCastedSObject();
		
		
		
		System.currentPageReference().getParameters().put('clid',''+cmpList.ID);
		System.currentPageReference().getParameters().put('target','2');
		
		controller = new SL_LIB16_ctrl_CompanyListSearch();
		
		controller.setMCompanies(lstMComps);

		SObject tmpCLItem = controller.addCLObj;
		controller.sortExpression = 'ASC';
		String tmnpVal2 =  controller.sortExpression;
		controller.sortExpression = 'ASC';
		controller.sortExpression = 'DESC';
		controller.sortExpression = 'DESC';
		controller.sortExpression = 'DESC';
		controller.getItems();
		controller.process();
		
		controller.clSearch();
		
		controller.setMCompanies(lstMComps);
		controller.doAdd();
		
		/********** List<S e archColumns__c> tmpSCList = controller.aSearchColumns;*/
		
		controller.addCLObj = clm;
		controller.doSearch();
		controller.addCLObj = null;
		
		controller.trace = 'Debug Start>>>>>>>>>';
		String logInfo = controller.trace;
		String  currTarget = controller.target;
		
		ApexPages.currentPage().getParameters().put('event', 'load');
		ApexPages.currentPage().getParameters().put('picklist', 'type');
		ApexPages.currentPage().getParameters().put('filters','REFERENCE___AccountId___equal___ABS Capital Partners___000000000000000##REFERENCE___AccountId___equal___ABS Capital Partners___001P0000003pJmH');
		ApexPages.currentPage().getParameters().put('target', '2');
		//controller.EventHandler();
		
		
		currTarget = controller.TargetObject;
		currTarget = controller.event;
		currTarget = controller.filterSet;
		currTarget = controller.picklistName;
		controller.JSONResponse = '';
		currTarget = controller.JSONResponse;
		
		/*
		ApexPages.currentPage().getParameters().put('target', 'Tab_'+controller_pre.tabContactObj.ID);
		ApexPages.currentPage().getParameters().put('picklist', 'recordtypeid');
		controller.getLCPickListValue();
		ApexPages.currentPage().getParameters().put('target', 'Tab_'+controller_pre.tabContactObj.ID);
		ApexPages.currentPage().getParameters().put('picklist', 'type');
		controller.getLCPickListValue();
		
		ApexPages.currentPage().getParameters().put('target', 'Search_'+controller_pre.ME_CompanyList_ObjID);
		ApexPages.currentPage().getParameters().put('picklist', 'recordtypeid');
		controller.getLCPickListValue();
		ApexPages.currentPage().getParameters().put('target', 'Search_'+controller_pre.ME_CompanyList_ObjID);
		ApexPages.currentPage().getParameters().put('picklist', 'type');
		controller.getLCPickListValue();		
		*/
		
		controller.addCLObj = clm;
		controller.SearchSection = 'CL';
		controller.doSearch();
		controller.addCLObj = null;
		
		
		controller.SearchQ = 'question';
		controller.SearchParam = 'param';
		controller.SearchSection = 'F';
		controller.doSearch();
		controller.SearchQ = null;
		
		controller.SearchQ = '';
		controller.SearchParam = '';
		controller.SearchObj = '3';
		controller.doSearch();
		
		controller.doCancel();
		system.debug('======== event ======== >>>> '+controller.event);
		system.debug('======== filterSet ======== >>>> '+controller.filterSet);
		system.debug('======== picklistName ======== >>>> '+controller.picklistName);
		
		//controller.EventHandler();
		
		SL_LIB16_ctrl_CompanyListSearch.JSONObject JSobj = new SL_LIB16_ctrl_CompanyListSearch.JSONObject();
		system.debug('======== JSobj.Json ======== >>>> '+JSobj.Json);
		JSobj = new SL_LIB16_ctrl_CompanyListSearch.JSONObject('Name','Name','STRING');
		List<String> lstPickListVals = new List<String>();
		lstPickListVals.add('Val1');
		lstPickListVals.add('Val2');
		lstPickListVals.add('Val3');
		JSobj = new SL_LIB16_ctrl_CompanyListSearch.JSONObject('Name','Name','STRING',lstPickListVals);
		JSobj.jQ('test 123');
		JSobj.jProperty('name','John');
		JSobj.jProperty('name',lstPickListVals);
		
		controller.doReset();
		
		controller.lnkCreateNewView();
		controller.saveSelectedColumns();
		
		controller.selectedColumnsCallback = 'Name';
		controller.saveSelectedColumns();
		controller.dummyFunction();
		controller.getUnselectedColumns();
		controller.getSelectColumnsOrdered();
		controller.getJSONResponseTemp();
		controller.getJSONResponse2();
		controller.getCurCompanyListName();
		controller.goCurPageNumber();
		controller.doSavePageSize();
		//List<SL_LIB16_ctrl_CompanyListSearch.JSONObject> lstJSON = new List<SL_LIB16_ctrl_CompanyListSearch.JSONObject>();
		//controller.getJsonFromFieldsList(lstJSON);
		

		try
		{
			controller.deleteTemplateByname();
		}
		catch(Exception ex)
		{
			
		}


		//controller2 controller2 = new controller2();
		
	} 
	
	/*
	class Controller2 extends SL_LIB16_ctrl_CompanyListSearch {
		public controller2() {
			SL_LIB16_ctrl_CompanyListSearch obj = new SL_LIB16_ctrl_CompanyListSearch();
			//obj.eventActionLoad();
			//obj.getPicklistJson();
			obj.m_sort_expresion = 'Name';
			obj.m_sort_direction = 'ASC';
			obj.sortExpression = 'Name';
			
			List<JSONObject> lst = new List<JSONObject>();
			lst.add(new JSONObject());
			lst.add(new JSONObject());
			lst[0].Value = 'Test Val 1';
			lst[1].Value = 'Test Val 2';
			
			system.Debug('==== getItemByNameFromList() ==== >>>> '+getItemByNameFromList(lst, 'Test Val 1'));
		}
	}
	*/
	
	static testMethod void wb_Search_Controller() {
		SL_LIB16_install controller_pre = new SL_LIB16_install();
		controller_pre.runChecker();
		
    	Company_List__c cl = new Company_List__c();
        cl.Name = 'Test Company List';
        insert cl;

    	System.currentPageReference().getParameters().put('clid', cl.Id);
    	System.currentPageReference().getParameters().put('target','Main');
    	System.currentPageReference().getParameters().put('implId',''+controller_pre.ME_CompanyList_ObjID);
        SL_LIB16_ctrl_CompanyListSearch cl_search_control = new SL_LIB16_ctrl_CompanyListSearch();
        test.startTest();
        
        String tmpCompanyListID = cl_search_control.CompanyListID;
        SObject tmpCompanyList = cl_search_control.addCLObj;
        String tmpsortDirection = cl_search_control.getSortDirection();
		cl_search_control.setSortDirection('ASC');
		String tmpsortExpression = cl_search_control.sortExpression;
		cl_search_control.sortExpression = 'Name';
		List<SL_LIB16_ctrl_CompanyListSearch.CompanyExtend> tmpgetAccounts = cl_search_control.getItems();
		cl_search_control.process();
		cl_search_control.doAdd();
		
		
		cl_search_control.SearchQ = 'SELECT Id, Name FROM Account';
		cl_search_control.SearchParam = 'EBITDA__c >0';
		cl_search_control.doSearch();
		
		cl_search_control.SearchObj = '1';
		cl_search_control.doSearch();
		
		cl_search_control.SearchObj = '3';
		cl_search_control.doSearch();
		
		Company_List__c CompList = new Company_List__c();
		CompList.Name = 'test comp 1';
		insert CompList;
		
		Account ac = new Account(Name='j@j.com');
        insert ac;
		
		Company_List_Member__c CompListMem = new Company_List_Member__c();
		CompListMem.Company_List__c = CompList.Id;
		CompListMem.Company__c = ac.Id;
		insert CompListMem;
		
		cl_search_control.addCLObj = CompListMem;
		cl_search_control.doSearch();
		
		ApexPages.StandardSetController tController = cl_search_control.m_std_controller;
		tController = new ApexPages.StandardSetController(Database.getQueryLocator('select ID,Name from Account limit 20'));
		cl_search_control.m_std_controller = tController;
		cl_search_control.getItems();
		cl_search_control.process();
		boolean isNext = cl_search_control.hasNext;
		boolean isPrevious = cl_search_control.hasPrevious;
		Integer pNumb = cl_search_control.pageNumber;
		pNumb = cl_search_control.pageSize;
		cl_search_control.goCurPageNumber();
		cl_search_control.doSavePageSize();
		cl_search_control.first();
		cl_search_control.last();
		//ApexPages.StandardSetController tController = cl_search_control.m_std_controller;
		//tController
		
		
		
		
		cl_search_control.doCancel();
		cl_search_control.doReset();
		
		SL_LIB209_ctrl_SearchBlockParams tmpVal = cl_search_control.getSearchCompParams();
		
        test.stopTest(); 
    }	
	
}