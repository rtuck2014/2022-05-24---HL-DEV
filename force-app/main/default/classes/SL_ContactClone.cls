/**
* \arg ClassName      : SL_ContactClone
* \arg JIRATicket     : HL-22
* \arg CreatedOn      : 15/JULY/2014
* \arg LastModifiedOn : 15/JULY/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Handler class for SL_ContactClone page.
*/

public with sharing class SL_ContactClone 
{
	/* Start - Variables */
	private Contact objContact;
	private Map<String, Schema.SObjectType> mapGlobalDescribe = Schema.getGlobalDescribe();
	/* End - Variables */
	
	/* Start - Constructor */
	public SL_ContactClone(ApexPages.StandardController stdController)
	{
		objContact = (Contact)stdController.getRecord();
	}
	/* Start - Constructor */
	
	/*
		@MethodName : intialization 
		@param 	    : NA
		@Description: to intializa all global variables. 
	*/
	public Pagereference cloneContact()
	{
		List<String> lstRequiredFieldAPI = new List<String>();//!< list to hold the api name of the required field
		List<Relationship__c> lstRelationshipToInsert = new List<Relationship__c>();//!< lst of relationship records to insert.
		
		String strQuery = 'SELECT Id, RecordTypeId, RecordType.DeveloperName, FirstName';
		lstRequiredFieldAPI.add('FirstName');
		for(Schema.SObjectField field  :  mapGlobalDescribe.get('Contact').getDescribe().fields.getMap().values())//!< prepare the query for the required field.
		{
			if(field.getDescribe().isUpdateable() && !field.getDescribe().isNillable())//!< checking field is updateable and required.
			{
				strQuery += ', ' + field.getDescribe().getName();
				lstRequiredFieldAPI.add(field.getDescribe().getName());
			}
		}
		
		strQuery += ' FROM Contact WHERE Id=\'' + objContact.Id +'\'';
		
		List<Contact> lstContact = Database.query(strQuery);//!< getting the contact
		if(!lstContact.isEmpty())//!<checking if record is available.
		{
			objContact = lstContact[0];
			Contact objCloneContact = new Contact();
			for(String strFieldAPI : lstRequiredFieldAPI)//!< mapping all required fields.
			{
				objCloneContact.put(strFieldAPI, objContact.get(strFieldAPI));
			}
			objCloneContact.Status__c = 'Active';
			objCloneContact.RecordTypeId = objContact.RecordTypeId;
			objCloneContact.HL_Alumni__c = (objContact.RecordType.DeveloperName == 'Houlihan_Employee') ? true : false;
			insert objCloneContact;
			
			objContact.Status__c = 'Inactive';
			update objContact;
			  
			//!< Query on relationship to get create the relationship records.
			for(Relationship__c objRelationship : [SELECT Id,
														  Willing_to_Make_Introduction__c, 
														  Type__c, 
														  System_Created__c, 
														  Sync_to_Outlook__c,
														  Strength_Rating__c, 
														  Status__c, 
														  Related_Relationship__c, 
														  Number_of_Deals_on_Client_External_Team__c, 
														  HL_Contact__c, 
														  External_Contact__c, 
														  Personal_Note__c, 
														  Created_From__c 
												     FROM Relationship__c
												    WHERE (HL_Contact__c =: objContact.Id OR External_Contact__c =: objContact.Id)])
			{
				//!< mapping all the relationship fields..
				Relationship__c objRelatioshipClone = new Relationship__c(Willing_to_Make_Introduction__c = objRelationship.Willing_to_Make_Introduction__c,
																	  	  Type__c = objRelationship.Type__c,
																	  	  System_Created__c = objRelationship.System_Created__c,
																	  	  Sync_to_Outlook__c = objRelationship.Sync_to_Outlook__c,
																	  	  Strength_Rating__c = objRelationship.Strength_Rating__c,
																	  	  Status__c = objRelationship.Status__c,
																	      Related_Relationship__c = objRelationship.Related_Relationship__c,
																	      Number_of_Deals_on_Client_External_Team__c = objRelationship.Number_of_Deals_on_Client_External_Team__c,
																	      Personal_Note__c = objRelationship.Personal_Note__c,
																	      Created_From__c = objRelationship.Created_From__c);
																	  
				objRelatioshipClone.HL_Contact__c = (objRelationship.HL_Contact__c == objContact.Id) ? objCloneContact.Id : objRelationship.HL_Contact__c;
				objRelatioshipClone.External_Contact__c = (objRelationship.External_Contact__c == objContact.Id) ? objCloneContact.Id : objRelationship.External_Contact__c;
				lstRelationshipToInsert.add(objRelatioshipClone);
			}
			
			if(!lstRelationshipToInsert.isEmpty())//!< dml operation
				insert lstRelationshipToInsert;
			
			//!< page reference to redirect on edit page
			return new Pagereference('/'+objCloneContact.Id+'/e?retURL='+objCloneContact.Id);
		}
		return null;
	}
	/* End */
}