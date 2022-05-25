/**
* \arg ClassName      : SL_Test_DeepClone
* \arg JIRATicket     : HL-13
* \arg CreatedOn      : 21/MAY/2014
* \arg LastModifiedOn : 21/MAY/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Test class for SL_CreateRelationship class. 
*/

@isTest
private class SL_Test_CreateRelationship 
{
	@isTest 
    static void test_CreateRelationship()   
    {
    	Id HLRecordtypeId = [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'Houlihan_Employee'].Id;
        Id ExternalRTId = [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'External_Contact'].Id;
    	
    	Account objAccount = new Account(Name = 'Test Account -01');
    	insert objAccount;
    	
        Contact objContact = new Contact(FirstName='Test Contact', LastName = 'Test Contact External', AccountId = objAccount.Id, RecordTypeId = ExternalRTId);
        insert objContact;
        
        SL_CreateRelationship objCreateRelationship = new SL_CreateRelationship();
        SL_CreateRelationship.createRelationship('', '');
        
        SL_CreateRelationship.createRelationship(objContact.Id, Userinfo.getUserId());
        
        System.assertEquals([SELECT Id FROM Relationship__c].size(),0);
        
        objContact.User__c = Userinfo.getUserId();
        update objContact;
        SL_CreateRelationship.createRelationship(objContact.Id, Userinfo.getUserId());
        System.assertEquals([SELECT Id FROM Relationship__c].size(), 0);
        
        Contact objContact1 = new Contact(FirstName='Test Contact', LastName = 'Test Contact HL', AccountId = objAccount.Id, RecordTypeId = HLRecordtypeId, User__c = Userinfo.getUserId());
        insert objContact1;
        
        SL_CreateRelationship.createRelationship(objContact.Id, Userinfo.getUserId());
        System.assertEquals([SELECT Id FROM Relationship__c].size(), 1);
        SL_CreateRelationship.createRelationship(objContact.Id, Userinfo.getUserId());
        System.assertEquals([SELECT Id FROM Relationship__c].size(), 1);
        
    }
}