/**
 * @author Prishlyak Vladimir\
 * @see https://silverline.jira.com/browse/LIB-145
 */
 
@isTest
public without sharing class SL_LIB16_test_SetupButtons
{
	public static testmethod void testMethod1()
	{
		SL_LIB16_install controller_pre = new SL_LIB16_install();
		controller_pre.runChecker();

		Company_List__c compLst = new Company_List__c(Name='Test001');
		insert compLst;

		
		Test.startTest();

		SL_Mass_Implementation__c implObj = [SELECT Id,Search_Object_Title__c FROM SL_Mass_Implementation__c WHERE Id=:controller_pre.ME_CompanyList_ObjID limit 1];
		
		SL_LIB16_SetupButtons controller = new SL_LIB16_SetupButtons(new ApexPages.standardController(implObj));
		String tmpStr = controller.searchObjectPlural;
		tmpStr = controller.addUrl;
		tmpStr = controller.editUrl;
		tmpStr = controller.deleteUrl;
		
		Test.stopTest();
	}

}