@isTest
private class Test_HL_MassRelationshipCreation {
	@testSetup
	private static void SetupTestData() {
		Id hlRecordTypeId = [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'Houlihan_Employee'].Id;
		Id externalRecordTypeId = [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'External_Contact'].Id;

		Account accountRecord = (Account)HL_TestFactory.CreateSObject('Account', false);
		accountRecord.Name = 'Test Account -01';
		insert accountRecord;

		Contact contactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
		contactRecord.FirstName = 'Test Contact';
		contactRecord.LastName = 'Test Contact HL';
		contactRecord.AccountId = accountRecord.Id;
		insert contactRecord;

		List<Contact> externalContactList = new List<Contact>();
		for (Contact externalContact : HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.External_Contact, false, 8)) {
			externalContact.FirstName = 'Test Contact';
			externalContact.LastName = 'Test Contact External-' + externalContactList.size();
			externalContact.AccountId = accountRecord.Id;
			externalContactList.add(externalContact);
		}
		insert externalContactList;

		Engagement__c engagementRecord = HL_TestFactory.CreateEngagement(false);
		engagementRecord.Name = 'Test Engagement';
		engagementRecord.Client__c = accountRecord.Id;
		engagementRecord.Subject__c = accountRecord.Id;
		engagementRecord.Primary_Office__c = 'FF';
		engagementRecord.Line_of_Business__c = 'CF';
		engagementRecord.Stage__c = 'Closed / Won / Engaged';
		engagementRecord.Job_Type__c = 'Take Over Defense';
		engagementRecord.Industry_Group__c = 'ADG';
		insert engagementRecord;

		List<Engagement_External_Team__c> engagementExternalTeamList = new List<Engagement_External_Team__c>();

		for (Contact externalContactRecord : externalContactList) {
			engagementExternalTeamList.add(new Engagement_External_Team__c(Engagement__c = engagementRecord.Id, Contact__c = externalContactRecord.Id, Type__c = 'External'));
			engagementExternalTeamList.add(new Engagement_External_Team__c(Engagement__c = engagementRecord.Id, Contact__c = externalContactRecord.Id, Type__c = 'Client'));
		}

		insert engagementExternalTeamList;
	}

	@isTest
	private static void TestGetContactOptions() {
		Engagement__c engagementRecord = [SELECT Id FROM Engagement__c LIMIT 1];

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.standardController(engagementRecord);
		HL_MassRelationshipCreation massRelationshipCreation = new HL_MassRelationshipCreation();
		massRelationshipCreation.EntityId = engagementRecord.Id;
		String entityType = massRelationshipCreation.EntityType;
		String entityBase = massRelationshipCreation.EntityBase;
		List<SelectOption> getContactOptionsList = massRelationshipCreation.GetContactOptions();

		Test.stopTest();

		System.assertEquals('Engagement__c', entityType);
		System.assertEquals('Engagement', entityBase);
		System.assert(getContactOptionsList.size() > 0);
	}

	@isTest
	private static void TestCancel() {
		Engagement__c engagementRecord = [SELECT Id FROM Engagement__c LIMIT 1];

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.standardController(engagementRecord);
		HL_MassRelationshipCreation massRelationshipCreation = new HL_MassRelationshipCreation();
		massRelationshipCreation.EntityId = engagementRecord.Id;
		PageReference cancelResult = massRelationshipCreation.Cancel();

		Test.stopTest();

		System.assertEquals('/' + engagementRecord.Id, cancelResult.getUrl());
	}

	@isTest
	private static void TestControllerRelationshipRetrievals() {
		Contact hlContactRecord = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Houlihan_Employee' LIMIT 1];
		Engagement__c engagementRecord = [SELECT Id FROM Engagement__c LIMIT 1];

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.standardController(engagementRecord);
		HL_MassRelationshipCreation massRelationshipCreation = new HL_MassRelationshipCreation();

		List<HL_MassRelationshipCreation.RelationshipWrapper> getAllContactsResultList = HL_MassRelationshipCreation.GetRelationshipRecords(engagementRecord.Id, hlContactRecord.Id, 'All_Contacts');
		List<HL_MassRelationshipCreation.RelationshipWrapper> getExternalTeamResultList = HL_MassRelationshipCreation.GetRelationshipRecords(engagementRecord.Id, hlContactRecord.Id, 'External_Team');
		List<HL_MassRelationshipCreation.RelationshipWrapper> getClientTeamResultList = HL_MassRelationshipCreation.GetRelationshipRecords(engagementRecord.Id, hlContactRecord.Id, 'Client_Team');
		List<HL_MassRelationshipCreation.RelationshipWrapper> getCounterpartyContactResultList = HL_MassRelationshipCreation.GetRelationshipRecords(engagementRecord.Id, hlContactRecord.Id, 'Counterparty_Contacts');

		Test.stopTest();

		System.assertEquals(8, getAllContactsResultList.size());
		System.assertEquals(8, getExternalTeamResultList.size());
		System.assertEquals(8, getClientTeamResultList.size());
		System.assertEquals(0, getCounterpartyContactResultList.size());
	}

	@isTest
	private static void TestControllerUpsertOfRelationshipRecords() {
		Contact hlContactRecord = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Houlihan_Employee' LIMIT 1];
		Engagement__c engagementRecord = [SELECT Id FROM Engagement__c LIMIT 1];
		List<Contact> externalContactList = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'External_Contact'];

		Test.startTest();

		HL_MassRelationshipCreation.UpsertRelationshipRecord('', hlContactRecord.Id, externalContactList[0].Id, '2', true);

		Test.stopTest();

		List <Relationship__c> relationshipList = [SELECT Sync_to_Outlook__c,
		                       Strength_Rating__c
		                       FROM Relationship__c
		                       WHERE External_Contact__c = : externalContactList[0].Id AND HL_Contact__c = : hlContactRecord.Id];

		System.assertEquals(1, relationshipList.size());
		System.assertEquals(relationshipList[0].Sync_to_Outlook__c, true);
	}

	@isTest
	private static void TestUpsertOfMultipleRelationshipRecords() {
		Contact hlContactRecord = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Houlihan_Employee' LIMIT 1];
		Engagement__c engagementRecord = [SELECT Id FROM Engagement__c LIMIT 1];
		List<Contact> externalContactList = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'External_Contact'];
		List<Relationship__c> relationshipList = new List<Relationship__c>();
		for (Contact externalContactRecord : externalContactList) {
			relationshipList.add(new Relationship__c(HL_Contact__c = hlContactRecord.Id,
			                     External_Contact__c = externalContactRecord.Id,
			                     Strength_Rating__c = 'Medium',
			                     Sync_to_Outlook__c = true
			                                        ));
		}
		Test.startTest();

		HL_MassRelationshipCreation.UpsertRelationshipRecords(relationshipList);

		Test.stopTest();

		List <Relationship__c> relationshipResultList = [SELECT Sync_to_Outlook__c,
		                       Strength_Rating__c
		                       FROM Relationship__c
		                       WHERE HL_Contact__c = : hlContactRecord.Id];

		System.assertEquals(8, relationshipResultList.size());
		for (Relationship__c relationshipRecord : relationshipResultList) {
			System.assertEquals(relationshipRecord.Strength_Rating__c, 'Medium');
			System.assertEquals(relationshipRecord.Sync_to_Outlook__c, true);
		}
	}
}