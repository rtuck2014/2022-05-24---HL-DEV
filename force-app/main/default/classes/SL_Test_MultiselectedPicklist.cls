/**  
* \arg ClassName      : SL_Test_MultiselectedPicklist
* \arg JIRATicket     : HL-16
* \arg CreatedOn      : 10/JUNE/2014
* \arg LastModifiedOn : 10/JUNE/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Test class for SL_MultiselectedPicklist .
*/
@isTest
private class SL_Test_MultiselectedPicklist 
{
	static testMethod void Test_MultiselectedPicklist() 
    {
     	SL_MultiselectedPicklist objMP = new SL_MultiselectedPicklist();
        
        SL_MultiselectedPicklist.validateDependentPicklist('Opportunity__c', 'Line_of_Business__c', 'Job_Type__c', true);
        SL_MultiselectedPicklist.validateDependentPicklist('Opportunity__c', 'Line_of_Business__c', 'Job_Type__c', false);
		SL_MultiselectedPicklist.validateDependentPicklist('Engagement__c', 'Line_of_Business__c', 'Job_Type__c', true);
		SL_MultiselectedPicklist.validateDependentPicklist('Engagement__c', 'Line_of_Business__c', 'Job_Type__c', false);
        
        objMP.leftOptions = new List<SelectOption>();
        objMP.rightOptions = new List<SelectOption>();
		objMP.leftOptionsHidden = 'A&a&b&b&C&c';
        objMP.rightOptionsHidden = '';
        
        System.assertEquals(objMP.leftOptions.size(), 3);
        System.assertEquals(objMP.rightOptions.size(), 0);  
    }
}