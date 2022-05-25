/**
* \arg ClassName      : SL_Test_DeepClone
* \arg JIRATicket     : HL-7
* \arg CreatedOn      : 24/APR/2014
* \arg LastModifiedOn : 24/APR/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : 
*/


@isTest
private class SL_Test_DeepClone 
{
	@isTest  
	static void test_Convert_Engagement() 
	{
		Account objAccount = new Account(Name = 'Test Account');
		insert objAccount;
		
		SL_Convert__Custom_Mapping__c objCCM = new SL_Convert__Custom_Mapping__c(Name = 'Test -01',
																				 SL_Convert__Sobject_API_Name__c = 'Opportunity__c'); 
		insert objCCM;
		
		SL_Convert__Object_Relationship__c objCOR = new SL_Convert__Object_Relationship__c(SL_Convert__Custom_Mapping__c = objCCM.Id,
																						   SL_Convert__Context_Object_API__c = 'Opportunity__c');
		insert objCOR;
		
		SL_Convert__Field_Mapping__c objCFM = new SL_Convert__Field_Mapping__c(SL_Convert__Active__c = true,
																			   SL_Convert__Context_Field_Name__c = 'Name',
                                                                               SL_Convert__Target_Field_Name__c = 'Name',
																			   SL_Convert__Object_Relationship__c = objCOR.Id);
		insert objCFM;	
		
		Opportunity__c objOpportunity = new Opportunity__c(Name = 'Test Opportunity', Client__c = objAccount.Id, 
														   Line_of_Business__c = 'CF', Job_Type__c = 'Financing', 
														   Primary_Office__c = 'FF', Stage__c = 'Closed / Won / Engaged',Beneficial_Owner_Control_Person_form__c = 'No');
		insert objOpportunity;
		
		//ApexPages.StandardController sc = new ApexPages.standardController(objOpportunity);
		//SL_Convert_Engagement objCE = new SL_Convert_Engagement();
		SL_Convert_Engagement.convertEngagement(objOpportunity.Id);
	}
	
	
	@isTest 
	static void test_Clone_Engagement() 
	{
		Account objAccount = new Account(Name = 'Test Account');
		insert objAccount;
		
		SL_Convert__Custom_Mapping__c objCCM = new SL_Convert__Custom_Mapping__c(Name = 'Test -01',
																				 SL_Convert__Sobject_API_Name__c = 'Engagement__c'); 
		insert objCCM;
		
		SL_Convert__Object_Relationship__c objCOR = new SL_Convert__Object_Relationship__c(SL_Convert__Custom_Mapping__c = objCCM.Id,
																						   SL_Convert__Context_Object_API__c = 'Engagement__c');
		insert objCOR;
		
		SL_Convert__Field_Mapping__c objCFM = new SL_Convert__Field_Mapping__c(SL_Convert__Active__c = true,
																			   SL_Convert__Context_Field_Name__c = 'Name',
                                                                               SL_Convert__Target_Field_Name__c = 'Name',
																			   SL_Convert__Object_Relationship__c = objCOR.Id);
		insert objCFM;																	   
		
		Engagement__c objEngagement = new Engagement__c(Name='Test Engagement', Client__c = objAccount.Id, Subject__c = objAccount.Id,
														Primary_Office__c = 'FF', Line_of_Business__c = 'CF', Stage__c = 'Closed / Won / Engaged', 
														Job_Type__c = 'Take Over Defense', Industry_Group__c = 'ADG');
		insert objEngagement;
		
		SL_Clone_Engagement.cloneEngagement(objEngagement.Id);
	}
}