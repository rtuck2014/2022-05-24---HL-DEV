/**  
* \arg ClassName      : SL_CreateRelationship
* \arg JIRATicket     : HL-13
* \arg CreatedOn      : 21/MAY/2014
* \arg LastModifiedOn : 21/MAY/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : This class is used to create the relationship record from contact detail page button.
*/
global with sharing class SL_CreateRelationship 
{
	/* Start - Variables */
	/* End - Variables */
	
	/* Start - Constructor */
	global SL_CreateRelationship()
	{
		//do nothing.  
	}
	/* End - Constructor */
	
	/*
		@MethodName : createRelationship 
		@param 	    : contactId and UserId.
		@Description: This method with called from the contact detail page to create relationship record. 
	*/
	@AuraEnabled	
	WebService static String createRelationship(String strContactId, String strUserId)
	{
    	if(!String.isEmpty(strContactId) && !String.isEmpty(strUserId) )
    	{
    		try
    		{
    			List<Contact> lstContact = [SELECT Id FROM Contact WHERE User__c =:strUserId AND RecordType.DeveloperName = 'Houlihan_Employee'];
    			if(!lstContact.isEmpty())
    			{
    				List<Relationship__c> lstRelationship = [SELECT Id FROM Relationship__c WHERE HL_Contact__c =: lstContact[0].Id AND External_Contact__c =: strContactId];
    				if(lstRelationship.isEmpty())
    				{
	    				Relationship__c objRelationship = new Relationship__c(HL_Contact__c = lstContact[0].Id, External_Contact__c = strContactId);
	    				insert objRelationship;
	    				
	    				return 'Relationship created successfully';
    				}
    				else
    				{
    					return System.Label.SL_Relationship_Already_Exist;
    				}
    			}
    			else
    			{
    				return System.Label.SL_No_Related_Houlihan_Employee;
    			}
    			
    		}
    		catch(Exception ex)
    		{
    			return ex.getMessage();
    		}
    	}
    	return 'User field of Contact is blank.';
	}
	/* End */
}