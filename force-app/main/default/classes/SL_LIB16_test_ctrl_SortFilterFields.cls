/**
 * @author Prishlyak Vladimir\
 * @see https://silverline.jira.com/browse/LIB-145
 */
 
@isTest
public with sharing class SL_LIB16_test_ctrl_SortFilterFields
{
	public static testmethod void testMethod1()
	{
		SL_LIB16_install controller_pre = new SL_LIB16_install();
		controller_pre.runChecker();

		Company_List__c compLst = new Company_List__c(Name='Test001');
		insert compLst;

		
		Test.startTest();
		SL_Filter_Field__c itemFF = [select Id, Name, Mass_Implementation__c, API_Type__c, Filter_Tab__c from SL_Filter_Field__c where Mass_Implementation__c=:controller_pre.ME_CompanyList_ObjID limit 1];
		ApexPages.currentPage().getParameters().put('impl', controller_pre.ME_CompanyList_ObjID);
		SL_LIB16_ctrl_SortFilterFields controller = new SL_LIB16_ctrl_SortFilterFields(new ApexPages.standardController(itemFF));
		List<Selectoption> lstOpt = controller.getTabs();
		controller.setTabs(lstOpt);
		controller.doCancel();
		controller.doSave();
		
		controller.currentTab = 'Search';
		controller.refreshFilterFields();
		controller.doAlphabet();
		
		controller.currentTab = 'Target';
		controller.refreshFilterFields();
		controller.doAlphabet();
		
		controller.currentTab = 'Tab';
		controller.refreshFilterFields();
		controller.doAlphabet();
		
		Test.stopTest();
	}

}