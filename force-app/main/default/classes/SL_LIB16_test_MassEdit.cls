@isTest(SeeAllData=true)
private class SL_LIB16_test_MassEdit {
    public class Controller extends SL_LIB16_MassEdit {
        public override Boolean castAndSave(List<SObject> lst) {
            return true;
        }
        public override SObject getNewTargetObject() {
            return new Contact();
        }

        public Controller() {
            super();
            sortExpression = 'Name'; 
            targetObjectName = 'Contact';
            targetObjectParentFieldName = 'AccountId';
            String pId = ApexPages.currentPage().getParameters().get('accId');
            
            parentObject = [SELECT Id, Name FROM Account WHERE Id = :pId];
            parentObjectName = 'Account';
            fieldNamesNotColumns = new List<String> {'AccountId', 'Account.RecordTypeId'};
            fieldNamesNotNulls = new List<String> {'AccountId'};
            columns = new List<ColumnInfo>{
                 new ColumnInfo('Name','Name','Name',true,true)
                ,new ColumnInfo('FirstName','FirstName','FirstName',true,true)
                ,new ColumnInfo('Account.Name','Account.Name','Account.Name',true,true)
            };
            refetchMembers();
        }
    }

    public static testMethod void testMethod1() {
    	
    	
    	
    	SL_LIB16_install controller_pre = new SL_LIB16_install();
		controller_pre.runChecker();
    	
        Account acc = new Account(Name = 'TestAcc1');
        insert acc;
        Contact contact = new Contact(AccountId=acc.Id, FirstName='Test', LastName='Test');
        insert contact;
        Contact contact2 = new Contact(AccountId=acc.Id, FirstName='Test2', LastName='Test2');
        insert contact2;
        Contact contact3 = new Contact(AccountId=acc.Id, FirstName='Test0', LastName='Test0');
        insert contact3;
        
        
		Company_List__c CompList = new Company_List__c();
		CompList.Name = 'test comp 1';
		insert CompList;
		
		Account ac = new Account(Name='j@j.com');
        insert ac;
		
		Company_List_Member__c CompListMem = new Company_List_Member__c();
		CompListMem.Company_List__c = CompList.Id;
		CompListMem.Company__c = ac.Id;
		insert CompListMem;        
        
        
        Test.startTest();

 		ApexPages.currentPage().getParameters().put('accId', ''+acc.Id);
		Controller controller = new Controller();
        
        System.currentPageReference().getParameters().put('clid', CompListMem.Id);
    	System.currentPageReference().getParameters().put('target','Main');
    	System.currentPageReference().getParameters().put('implId',''+controller_pre.ME_CompanyList_ObjID);
        
       
        controller = new Controller();
        controller.strColumnsAndFiltersTemplate = 'All';
        
        system.debug('==== compareField(1,2) ==== >>>> '+controller.compareField('1','2'));
        system.debug('==== getField ==== >>>> '+controller.getField(contact, 'Account.Name'));
        
        controller.sortDirection = 'DESC';
        controller.sortExpression = 'FirstName';
        controller.changeSorting();
        controller.voidAction();
        controller.getLimits();
        
        
        controller.getParentName();
        controller.fetchTemplateColumnAndFilterConditions();
        controller.doSavePageSize();
        
        controller.startEdit();
        controller.stopEdit();
        //controller.save();
        controller.saveClose();
        
        controller.getColumnsShown();
        controller.getUnselectedColumns();
        controller.getSelectColumns();
        controller.isDisabled = true;
        controller.saveColumns('Name;FirstName;Account.Name');
        
        controller.isDisabled = false;
        controller.saveColumns('Name;FirstName;Account.Name');
        controller.getSelectColumnsOrdered();
        //controller.loadColumnOrder();
        
        
        controller.cb_columns = 'Name;FirstName;Account.Name';
        controller.cb_filters = 'REFERENCE___AccountId___equal___ABS Capital Partners___000000000000000##REFERENCE___AccountId___equal___ABS Capital Partners___001P0000003pJmH';
        controller.cb_advfilters = '1 AND 2';
        controller.saveColumnsFilters();
        controller.getFiltersJSON();
        controller.getFiltersString();
        String s;
        s = controller.target;
        s = controller.event;
        s = controller.picklistName;
        ApexPages.currentPage().getParameters().put('event', 'load');
        ApexPages.currentPage().getParameters().put('target', 'Contact');
        controller.EventHandler();
        
        ApexPages.currentPage().getParameters().put('picklist', 'leadsource');
        controller.EventHandler();
        
        //controller.isEqual(new List<Integer>{1, 2, 3}, new List<Integer>{1, 2, 3});
        
        system.debug('============================= membersCount: ' + controller.membersList.size());
        controller.sortDirection = 'DESC';
        controller.sortExpression = 'FirstName';
        controller.changeSorting();
        
        controller.getCompiledQuery();
        controller.selectedColumnsCallback = 'Id;Name;FirstName';
        controller.refetchMembers();
        
        controller.fillDescribe();
        //controller.saveSelectedColumns();
        system.debug('==== compareField(1,2) ==== >>>> '+controller.compareField('1','2'));
        
        controller.changeSorting();
        controller.changeSorting();
        controller.voidAction();
        controller.getLimits();
        controller.selectedColumnsCallback = 'Name';
        
        controller.refetchMembers();
        controller.save();
        controller.saveClose();
        SL_LIB16_MassEdit.PermutationInfo pInfo = new SL_LIB16_MassEdit.PermutationInfo(1,2);
        
        controller.startEdit();
        controller.getSelectColumns();
        controller.stopEdit();
        
        controller.lnkCreateNewView();
        
        
		controller.deleteTemplateByname();
        
        SL_LIB16_MassEdit.QuickFilter tmpObj1 = new SL_LIB16_MassEdit.QuickFilter();
        tmpObj1 = new SL_LIB16_MassEdit.QuickFilter('select id from Account limit 1', 'test!');
        
        
        
        
        Test.stopTest();
    }

    public static testMethod void testMethod2() { //With invalid data
    	
    	SL_LIB16_install controller_pre = new SL_LIB16_install();
		controller_pre.runChecker();
    	
        Account acc = new Account(Name = 'TestAcc1');
        insert acc;
        Contact contact = new Contact(AccountId=acc.Id, FirstName='Test', LastName='Test');
        insert contact;
        Contact contact2 = new Contact(AccountId=acc.Id, FirstName='Test2', LastName='Test2');
        insert contact2;
        Contact contact3 = new Contact(AccountId=acc.Id, FirstName='Test0', LastName='Test0');
        insert contact3;
        
        Company_List__c CompList = new Company_List__c();
		CompList.Name = 'test comp 1';
		insert CompList;
		
		Account ac = new Account(Name='j@j.com');
        insert ac;
		
		Company_List_Member__c CompListMem = new Company_List_Member__c();
		CompListMem.Company_List__c = CompList.Id;
		CompListMem.Company__c = ac.Id;
		insert CompListMem;    
        
        Test.startTest();
        
        System.currentPageReference().getParameters().put('clid', CompListMem.Id);
    	System.currentPageReference().getParameters().put('target','Main');
    	System.currentPageReference().getParameters().put('implId',''+controller_pre.ME_CompanyList_ObjID);
        ApexPages.currentPage().getParameters().put('accId', ''+acc.Id);
        Controller controller = new Controller();
        controller.strColumnsAndFiltersTemplate = 'All';
        
        controller.getSelectColumns();
        //controller.getSelectColumnsOrdered();
        controller.isDisabled = true;
        controller.saveColumns('Name');
        //controller.loadColumnOrder();
        controller.isDisabled = false;
        controller.saveColumns('Name');
        
        controller.btnCancel();
        
        controller.btnDelete();     
        
        SL_LIB16_MassEdit.MemberContainer tmpSubObj = new SL_LIB16_MassEdit.MemberContainer();
        tmpSubObj = new SL_LIB16_MassEdit.MemberContainer(acc);
        tmpSubObj = new SL_LIB16_MassEdit.MemberContainer(acc, true);
        
        SL_LIB16_MassEdit.getRelObject4Field('Account', 'Name');
        SL_LIB16_MassEdit.getRelObject4Field('Account', 'Owner.Name');
        
        Test.stopTest();
    }
    
    public static testMethod void testMethod3() {
    	
    	SL_LIB16_install controller_pre = new SL_LIB16_install();
		controller_pre.runChecker();

        Account acc = new Account(Name = 'TestAcc1');
        insert acc;
        Contact contact = new Contact(AccountId=acc.Id, FirstName='Test', LastName='Test');
        insert contact;
        Contact contact2 = new Contact(AccountId=acc.Id, FirstName='Test2', LastName='Test2');
        insert contact2;
        Contact contact3 = new Contact(AccountId=acc.Id, FirstName='Test0', LastName='Test0');
        insert contact3;
        
        Company_List__c CompList = new Company_List__c();
		CompList.Name = 'test comp 1';
		insert CompList;
		
		Account ac = new Account(Name='j@j.com');
        insert ac;
		
		Company_List_Member__c CompListMem = new Company_List_Member__c();
		CompListMem.Company_List__c = CompList.Id;
		CompListMem.Company__c = ac.Id;
		insert CompListMem;    
        
        Test.startTest();
        
        System.currentPageReference().getParameters().put('clid', CompListMem.Id);
    	System.currentPageReference().getParameters().put('target','Main');
    	System.currentPageReference().getParameters().put('implId',''+controller_pre.ME_CompanyList_ObjID);

        ApexPages.currentPage().getParameters().put('accId', ''+acc.Id);
    	Controller testController = new Controller();
    	testController.strColumnsAndFiltersTemplate = 'All';
    	
    	String res;
    	res = testController.getCompiledQuery();
    	res = testController.getFiltersString();
    	
    	Mass_Edit_Settings__c MEObj = [Select Label__c, Id From Mass_Edit_Settings__c where Implementation__c = :controller_pre.ME_CompanyList_ObjID limit 1];
    	MEObj.Label__c = 'test label!';
    	update MEObj;
    	
    	ID curRecID = MEObj.ID;
    	delete MEObj;
    	
    	undelete MEObj;

		
		List<Mass_Edit_Settings__c> lstMEObjs = [Select Label__c, Id, Implementation__c, Implementation_Type__c, Field__c From Mass_Edit_Settings__c where Implementation__c = :controller_pre.ME_CompanyList_ObjID limit 10];
		Map<ID,Mass_Edit_Settings__c> mapMEobj = new Map<ID,Mass_Edit_Settings__c>([Select Id, Label__c, Implementation__c, Implementation_Type__c, Field__c From Mass_Edit_Settings__c where Implementation__c = :controller_pre.ME_CompanyList_ObjID limit 10]);
		SL_LIB16_handler_Mass_Edit_Settings testControllerTrigHand = new SL_LIB16_handler_Mass_Edit_Settings(true, lstMEObjs==null?0:lstMEObjs.size());
		
		testControllerTrigHand.OnBeforeInsert(lstMEObjs);
		testControllerTrigHand.OnAfterInsert(mapMEobj);
		SL_LIB16_handler_Mass_Edit_Settings.OnAfterInsertAsync(mapMEobj.keySet());
		
		testControllerTrigHand.OnBeforeUpdate(mapMEobj,mapMEobj);
		testControllerTrigHand.OnAfterUpdate(mapMEobj,mapMEobj);
		SL_LIB16_handler_Mass_Edit_Settings.OnAfterUpdateAsync(mapMEobj.keySet());


		testControllerTrigHand.OnBeforeDelete(mapMEobj);
		testControllerTrigHand.OnAfterDelete(mapMEobj);
		SL_LIB16_handler_Mass_Edit_Settings.OnAfterUpdateAsync(mapMEobj.keySet());


		testControllerTrigHand.OnBeforeUndelete(lstMEObjs);
		testControllerTrigHand.OnAfterUndelete(lstMEObjs);

		boolean isResult = testControllerTrigHand.IsTriggerContext;
		isResult = testControllerTrigHand.IsVisualforcePageContext;
		isResult = testControllerTrigHand.IsWebServiceContext;
		isResult = testControllerTrigHand.IsExecuteAnonymousContext;

    	Test.stopTest();
    	
    }
    
}