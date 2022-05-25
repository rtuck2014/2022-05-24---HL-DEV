/**
 * @author Prishlyak Vladimir\
 * @see https://silverline.jira.com/browse/LIB-195
 */
 
@isTest
public with sharing class SL_LIB16_test_SetupGetLists
{
	public static testmethod void testMethod1()
	{
		SL_LIB16_install controller_pre = new SL_LIB16_install();
		controller_pre.runChecker();

		Company_List__c compLst = new Company_List__c(Name='Test001');
		insert compLst;

		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('impl', controller_pre.ME_CompanyList_ObjID);

		SL_Mass_Implementation__c DefaultSettings = null;
        for(SL_Mass_Implementation__c item:[Select targetObjectSearchFieldName__c, targetObjectParentFieldName__c, targetObjectName__c, searchObjectName__c, 
							parentObjectName__c, Show_Views_on_MassEdit_Page__c, Show_Views_on_MassAdd_Page__c, Search_Page_Title__c, Search_Object_Title__c, Name, 
							Id, Get_Element_from_List_Tab__c From SL_Mass_Implementation__c where id=:controller_pre.ME_CompanyList_ObjID limit 1])
		{
			DefaultSettings = item;
		}

		SL_LIB16_SetupGetLists controller = new SL_LIB16_SetupGetLists(new ApexPages.standardController(DefaultSettings));

		controller.goSave();
		controller.goCancel();
		controller.getUnselectedColumns();
		controller.getSelectColumnsOrdered();

		
		Test.stopTest();
	}
}