/**
 * @author Sergey Karnyushin\
 * @see https://silverline.jira.com/browse/LIB-139
 */
 
@isTest
public with sharing class SL_LIB16_test_ctrl_FilterFieldSetup
{
	public static testmethod void testFilterFieldSetup()
	{
		SL_LIB16_install controller_pre = new SL_LIB16_install();
		controller_pre.runChecker();

		Company_List__c compLst = new Company_List__c(Name='Test001');
		insert compLst;

		
		Test.startTest();
		
		SL_LIB16_ctrl_FilterFieldSetup controller = new SL_LIB16_ctrl_FilterFieldSetup(new ApexPages.standardController(new SL_Mass_Implementation__c(ID=controller_pre.ME_CompanyList_ObjID)));
		SL_LIB16_ctrl_FilterFieldSetup controller2 = new SL_LIB16_ctrl_FilterFieldSetup(new ApexPages.standardController(new SL_Mass_Implementation__c(ID=controller_pre.ME_CompanyList_ObjID)));
		
		controller.onChangeMainObject();
		
		List<Selectoption> selectOptionsList = controller.getMainObjectOptions();
		controller.setMainObjectOptions(selectOptionsList);
		
		Pagereference ref = controller.doSave();
		
		// Test for referenced pages
		
		ApexPages.currentPage().getParameters().put('filterId', controller_pre.ME_CompanyList_ObjID);
		ApexPages.currentPage().getParameters().put('objectName', 'User');
		ApexPages.currentPage().getParameters().put('systemFieldName', 'OwnerId');
		try{ controller = new SL_LIB16_ctrl_FilterFieldSetup();}
		catch(Exception e){}
		
		controller2 = new SL_LIB16_ctrl_FilterFieldSetup(new ApexPages.standardController(new SL_Mass_Implementation__c(ID=controller_pre.ME_CompanyList_ObjID)));
		
		ApexPages.currentPage().getParameters().put('type','Tab');
		try{ controller = new SL_LIB16_ctrl_FilterFieldSetup();}
		catch(Exception e){}
		controller2 = new SL_LIB16_ctrl_FilterFieldSetup(new ApexPages.standardController(new SL_Mass_Implementation__c(ID=controller_pre.ME_CompanyList_ObjID)));
		
		ApexPages.currentPage().getParameters().put('SL_LIB16_FilterTab',controller_pre.tabContactObj.ID);
		ApexPages.currentPage().getParameters().put('Mass_Implementation__c',controller_pre.ME_CompanyList_ObjID);
		ApexPages.currentPage().getParameters().put('type','Search');
		controller = new SL_LIB16_ctrl_FilterFieldSetup();		
		
		ApexPages.currentPage().getParameters().put('type','Search');
		controller = new SL_LIB16_ctrl_FilterFieldSetup();
		

		
		
		controller2 = new SL_LIB16_ctrl_FilterFieldSetup(new ApexPages.standardController(new SL_Mass_Implementation__c(ID=controller_pre.ME_CompanyList_ObjID)));
		
		ref = controller.doReferencedCancel();
		ref = controller.doReferencedSave();
		
		ApexPages.currentPage().getParameters().put('tabId',controller_pre.tabContactObj.ID);
		controller = new SL_LIB16_ctrl_FilterFieldSetup();
		
		controller.tabRefresh();
		controller.loadTabInfo();
		controller.getIsTabObject();
		controller.doReferencedSave();
		
		controller2 = new SL_LIB16_ctrl_FilterFieldSetup(new ApexPages.standardController(new Filter_Tab__c(ID=controller_pre.tabContactObj.ID)));
		//controller2.setupTabsPage();
		controller2.onChangeMainObject();
		//controller2.refreshFilterFieldList();
		controller2.getFieldNames();
		List<SelectOption> lstOptNames = controller2.getFieldNames();
		controller2.setFieldNames(lstOptNames);
		
		lstOptNames = controller2.getMainObjectOptions();
		controller2.setMainObjectOptions(lstOptNames);
		controller2.doTabSave();
		controller2.doTabCancel();
		controller2.doSave();
		
		Test.stopTest();
		
	}

}