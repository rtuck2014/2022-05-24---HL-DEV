/**
 * @author Prishlyak Vladimir\
 * @see https://silverline.jira.com/browse/LIB-154
 */
 
@isTest
public with sharing class SL_LIB16_test_ctrl_SetupDefaultSearch
{
	public static testmethod void testSetupDefaultSearch()
	{
		SL_LIB16_install controller_pre = new SL_LIB16_install();
		controller_pre.runChecker();

		Company_List__c compLst = new Company_List__c(Name='Test001');
		insert compLst;

		//SELECT Id,Mass_Implementation__c,Serialized_Data__c,Filter_Tab__c,User__c,Type__c FROM SL_LIB16_UserChoise__c
		SL_LIB16_UserChoise__c ucrecord = new SL_LIB16_UserChoise__c(Mass_Implementation__c=controller_pre.ME_CompanyList_ObjID, Type__c='Last', User__c=UserInfo.getUserId());
		ucrecord.Serialized_Data__c = '{"SearchParam":"1 OR 2","SearchQ":"STRING___LastName___notEqual___11___##STRING___LastName___equal______","TargetObject":"Account"}';
		insert ucrecord;
		
		
		Test.startTest();
		
		SL_LIB16_ctrl_SetupDefaultSearch controller = new SL_LIB16_ctrl_SetupDefaultSearch(new ApexPages.standardController(new SL_LIB16_UserChoise__c(ID=ucrecord.ID)));
		SL_LIB16_UserChoise__c curRecord = controller.currentSearchSettings;
		List<SelectOption> lstUsers = controller.availableUsers;
		SL_Mass_Implementation__c curImpl = controller.getMassEditSettings();
		
		String tmpStr = null;
		controller.cb_target = tmpStr;
		controller.cb_advFilters = tmpStr;
		controller.SearchTarget = tmpStr;
		
		tmpStr = controller.cb_target;
		tmpStr = controller.cb_advFilters;
		tmpStr = controller.SearchTarget;
		tmpStr = controller.target;
		
		Id implID = controller.implementationId;
		
		List<SelectOption> lstCurTabs = controller.getTabs();
		controller.setTabs(lstCurTabs);
		
		controller.doSave();
		
		SL_LIB209_ctrl_SearchBlockParams tmpVal = controller.getSearchCompParams();
		
		Test.stopTest();
		
	}

}