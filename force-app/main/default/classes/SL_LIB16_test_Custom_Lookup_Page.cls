/*
Original Author: Privlad
Source: https://silverline.jira.com/browse/LIB-151
Jira Ticket: LIB-151
*/

@isTest(SeeAllData=true)
public with sharing class SL_LIB16_test_Custom_Lookup_Page
{

	public static testmethod void testFilterFieldSetup()
	{
		SL_LIB16_install controller_pre = new SL_LIB16_install();
		controller_pre.runChecker();

		String cid;
		Company_List__c compLst = new Company_List__c(Name='Test001');
		insert compLst;
		cid = compLst.Id;

		
		Test.startTest();


		System.currentPageReference().getParameters().put('clid',''+cid);
		System.currentPageReference().getParameters().put('lksrch','Test');
		
		System.currentPageReference().getParameters().put('implId',''+controller_pre.ME_CompanyList_ObjID);
		
		SL_LIB16_Custom_Lookup_Page controller = new SL_LIB16_Custom_Lookup_Page();	
		controller.search();
		controller.SaveBtn();
		controller.saveStep1Btn();
		controller.doSaveStep3();
		controller.doCancelStep3();
		
		Test.stopTest();
	}
}