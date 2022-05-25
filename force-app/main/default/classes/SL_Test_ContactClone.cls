/**
* \arg ClassName      : SL_ContactClone
* \arg JIRATicket     : HL-22
* \arg CreatedOn      : 15/JULY/2014
* \arg LastModifiedOn : 15/JULY/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Test class for SL_ContactClone.
*/
@isTest()
public with sharing class SL_Test_ContactClone 
{
	@isTest()
	static void test_ContactClone()
    {
    	List<Contact> lstContactHL = SL_TestSetupUtils.CreateContact('Contact', 5, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE);
    	insert lstContactHL;
    	
    	List<Contact> lstContactEX = SL_TestSetupUtils.CreateContact('Contact', 5, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT);
        insert lstContactEX;
    	
    	List<Relationship__c> lstRelationship = SL_TestSetupUtils.CreateRelationship('Relationship__c', 5);
        for(integer i=0; i<5; i++)
        {
            lstRelationship[i].External_Contact__c = lstContactEX[i].Id;
            lstRelationship[i].HL_Contact__c = lstContactHL[i].Id;
        }

        insert lstRelationship;
        System.assertEquals(lstRelationship.size(), 5);
        
    	ApexPages.StandardController sc = new ApexPages.standardController(lstContactHL[0]);
    	SL_ContactClone objContactClone = new SL_ContactClone(sc); 
    	objContactClone.cloneContact();
    	
    	List<Contact> lstContact = [SELECT Id FROM Contact];
    	System.assertEquals(lstContact.size(), 11);
    }
}