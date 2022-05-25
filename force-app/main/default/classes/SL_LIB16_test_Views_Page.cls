/*
Original Author: Privlad
Source: https://silverline.jira.com/browse/LIB-151
Jira Ticket: LIB-151
*/

@isTest(SeeAllData=true)
public with sharing class SL_LIB16_test_Views_Page
{
	public static testmethod void testFilterFieldSetup()
	{
		SL_LIB16_install controller_pre = new SL_LIB16_install();
		controller_pre.runChecker();

		String cid;
		Company_List__c compLst = new Company_List__c(Name='Test001');
		insert compLst;
		cid = compLst.Id;
        SL_View__c ViewRecord = [select ID, Name from SL_View__c where Implementation__c=:controller_pre.ME_CompanyList_ObjID limit 1];
		
		Test.startTest();

		System.currentPageReference().getParameters().put('id',''+ViewRecord.ID);
		SL_LIB16_Views_Page controller = new SL_LIB16_Views_Page();
		
        controller = new SL_LIB16_Views_Page(new ApexPages.standardController(ViewRecord));
        
        controller.getIsShowFilter();
        controller.getFiltersJSON();
        controller.getRowsQTYValues();
        controller.chMainObject();
        controller.getUnselectedColumns();
        controller.getSelectColumns();
        controller.getSelectColumnsOrdered();
        controller.btnSave();
        controller.btnCancel();
        controller.goStForm();
        
        SL_LIB209_ctrl_SearchBlockParams tmpVal = controller.getSearchCompParams();


		Test.stopTest();
	}
}