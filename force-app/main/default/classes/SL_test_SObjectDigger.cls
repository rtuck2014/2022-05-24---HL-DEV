/**
 * \author Vladimir Dobrelya
 * \date Nov 27, 2014
 * \see https://silverline.jira.com/browse/HL-61
 */
@isTest
private class SL_test_SObjectDigger {
	
	private static final String objectName = 'Contact', fieldName = 'Account.CreatedBy.Id';

	@isTest static void unit_test() {
		system.assertEquals( null, SL_SObjectDigger.get( null, fieldName ) );
		system.assertEquals( UserInfo.getUserId(), SL_SObjectDigger.get( getContact( pContact.Id ), fieldName ) );
	}

	private static Contact getContact( ID contactId ) {
		return Database.query( 'SELECT ' + fieldName + ' FROM ' + objectName + ' WHERE Id = :contactId' );
	}

	private static Account pAccount {
		get {
			if ( pAccount == null ) {
				pAccount = new Account(
					Name = 'TestAccount'
				);
				insert pAccount;
			}
			return pAccount;
		} private set;
	}	

	private static Contact pContact {
		get {
			if ( pContact == null ) {
				pContact = new Contact(
					OwnerId = UserInfo.getUserId(),
					FirstName = 'Test',
					LastName = 'TestContact',
					Email = 'TestContact@email.test',
					AccountId = pAccount.Id
				);
				insert pContact;
			}
			return pContact;
		} private set;
	}	
}