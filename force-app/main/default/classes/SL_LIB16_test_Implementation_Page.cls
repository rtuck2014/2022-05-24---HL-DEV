/*
Original Author: Privlad
Source: https://silverline.jira.com/browse/LIB-151
Jira Ticket: LIB-151
*/

@isTest(SeeAllData=true)
public with sharing class SL_LIB16_test_Implementation_Page
{
	public static testmethod void testFilterFieldSetup()
	{
		SL_LIB16_install controller_pre = new SL_LIB16_install();
		controller_pre.runChecker();

		String cid;
		Company_List__c compLst = new Company_List__c(Name='Test001IP');
		insert compLst;
		cid = compLst.Id;

		
		Test.startTest();
		
		System.currentPageReference().getParameters().put('id',''+controller_pre.ME_CompanyList_ObjID);
		SL_LIB16_Implementation_Page controller = new SL_LIB16_Implementation_Page();
		
        controller = new SL_LIB16_Implementation_Page(new ApexPages.standardController(new SL_Mass_Implementation__c(ID=controller_pre.ME_CompanyList_ObjID)));
		
		controller.chMainObject();
		controller.btnSave();
		controller.btnSaveAndNew();
		controller.btnCancel();
		controller.goStForm();
	
		Test.stopTest();
	}
}