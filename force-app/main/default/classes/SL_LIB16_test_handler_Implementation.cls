/**
 * Test for SL_handler_Implementation
 * @author Privlad
 */
@isTest
public with sharing class SL_LIB16_test_handler_Implementation
{
	/**
	 * @author Privlad
	 * @see 
	 */
	static testMethod void testTriggerProcess()
	{
		Test.startTest();
		
		SL_Mass_Implementation__c itemMEMain = new SL_Mass_Implementation__c();

			itemMEMain.Name = 'Company List';
			itemMEMain.targetObjectParentFieldName__c = 'Company_List__c';
			itemMEMain.targetObjectSearchFieldName__c = 'Company__c';
			itemMEMain.targetObjectName__c = 'Company_List_Member__c';
			itemMEMain.parentObjectName__c = 'Company_List__c';
			itemMEMain.searchObjectName__c = 'Account';
			itemMEMain.Show_Views_on_MassAdd_Page__c = true;
			itemMEMain.Show_Views_on_MassEdit_Page__c = true;
			itemMEMain.Search_Page_Title__c = 'Search for Company to add to the Company List';
			itemMEMain.Search_Object_Title__c = 'Company';
			itemMEMain.Get_Element_from_List_Tab__c = 'Get Companies from existing Company List';
			insert itemMEMain;
			
			itemMEMain.Search_Page_Title__c = 'Search for Company to add to the Company List222';
			update itemMEMain;
			
			delete itemMEMain;
			
			SL_Mass_Implementation__c c = null; 
			for(SL_Mass_Implementation__c item: [select id from SL_Mass_Implementation__c where isDeleted = true LIMIT 1 ALL ROWS])
			{
				c = item;
			}
			undelete c;
		
		Test.stopTest();
	}
}