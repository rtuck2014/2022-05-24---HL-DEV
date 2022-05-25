/**
 * \author Vladimir Dobrelya
 * \date Nov 26, 2014
 * \brief The test class for SL_Describe
 */
@isTest
private class SL_test_Describe {

	static String objectName = 'Account', fieldName = 'Name', incorrectName = '&^%!@SAD';
	static Schema.SObjectType objectToken;
	static Schema.SObjectField fieldToken;

	@isTest static void test_getObjectFieldsDescribes() {
		system.assert( SL_Describe.isExisting( objectName ) ); // assertion of object existing
		system.assertEquals( false, SL_Describe.isExisting( objectToken ) );

		system.assert( SL_Describe.isExisting( objectName, fieldName ) ); // assertion of field existing
		system.assertEquals( false, SL_Describe.isExisting( objectToken, fieldName ) );
		system.assertEquals( false, SL_Describe.isExisting( fieldToken ) );

		// --- INCORRECT --- //
		// object describe
		system.assertEquals( null, SL_Describe.getDescribe( objectToken ) );
		system.assertEquals( null, SL_Describe.getDescribe( fieldToken ) );

		system.assertEquals( null, SL_Describe.getToken( incorrectName ) );
		system.assertEquals( null, SL_Describe.getDescribe( incorrectName ) );

		// field describe
		system.assertEquals( null, SL_Describe.getToken( '', '' ) );
		system.assertEquals( null, SL_Describe.getToken( objectToken, '' ) );
		system.assertEquals( null, SL_Describe.getDescribe( '', '' ) );
		system.assertEquals( null, SL_Describe.getDescribe( objectToken, '' ) );

		system.assertEquals( null, SL_Describe.getToken( objectName, incorrectName ) );
		system.assertEquals( null, SL_Describe.getToken( incorrectName, incorrectName ) );

		system.assertEquals( null, SL_Describe.getDescribe( objectName, incorrectName ) );
		system.assertEquals( null, SL_Describe.getDescribe( incorrectName, incorrectName ) );

		// --- CORRECT --- //
		objectToken = Account.SObjectType;
		fieldToken = Account.Name;

		// object describe
		system.assertEquals( objectToken, SL_Describe.getToken( objectName ) );
		system.assertEquals( objectToken.getDescribe(), SL_Describe.getDescribe( objectName ) );

		// field describe
		system.assertEquals( fieldToken, SL_Describe.getToken( objectName, fieldName ) );
		system.assertEquals( fieldToken.getDescribe(), SL_Describe.getDescribe( objectName, fieldName ) );
	}

	@isTest static void test_other() {
		objectToken = Account.SObjectType;

		system.assertEquals( SL_Describe.getDescribe( objectName ).isAccessible(), SL_Describe.isAccessible( objectName ) );
		system.assertEquals( SL_Describe.getDescribe( objectName, fieldName ).isAccessible(), SL_Describe.isAccessible( objectName, fieldName ) );
		system.assertEquals( SL_Describe.getDescribe( objectToken, fieldName ).isAccessible(), SL_Describe.isAccessible( objectToken, fieldName ) );

		system.assertEquals( SL_Describe.getDescribe( objectName ).isUpdateable(), SL_Describe.isUpdateable( objectName ) );
		system.assertEquals( SL_Describe.getDescribe( objectName, fieldName ).isUpdateable(), SL_Describe.isUpdateable( objectName, fieldName ) );
		system.assertEquals( SL_Describe.getDescribe( objectToken, fieldName ).isUpdateable(), SL_Describe.isUpdateable( objectToken, fieldName ) );

		system.assertEquals( SL_Describe.getDescribe( objectName ).isDeletable(), SL_Describe.isDeletable( objectName ) );

		system.assertEquals( SL_Describe.getDescribe( objectName, fieldName ).isSortable(), SL_Describe.isSortable( objectName, fieldName ) );
		system.assertEquals( SL_Describe.getDescribe( objectToken, fieldName ).isSortable(), SL_Describe.isSortable( objectToken, fieldName ) );

		system.assertEquals( SL_Describe.getDescribe( objectName, fieldName ).isFilterable(), SL_Describe.isFilterable( objectName, fieldName ) );
		system.assertEquals( SL_Describe.getDescribe( objectToken, fieldName ).isFilterable(), SL_Describe.isFilterable( objectToken, fieldName ) );

		system.assertEquals( SL_Describe.getDescribe( objectName, fieldName ).getType(), SL_Describe.getType( objectName, fieldName ) );
		system.assertEquals( SL_Describe.getDescribe( objectToken, fieldName ).getType(), SL_Describe.getType( objectToken, fieldName ) );

		system.assertEquals( true, SL_Describe.isReference( 'Contact', 'AccountId' ) );
		system.assertEquals( true, SL_Describe.isReference( SL_Describe.getToken( 'Contact' ), 'AccountId' ) );
		system.assertEquals( false, SL_Describe.isReference( 'Contact', 'Id' ) );

		system.assertEquals( SL_Describe.getDescribe( 'Contact' ).getLabel(), SL_Describe.getLabel( 'Contact' ) );
		system.assertEquals( SL_Describe.getDescribe( 'Contact', 'AccountId' ).getLabel(), SL_Describe.getLabel( SL_Describe.getToken( 'Contact' ), 'AccountId' ) );
		system.assertEquals( SL_Describe.getDescribe( 'Contact', 'AccountId' ).getLabel(), SL_Describe.getLabel( 'Contact', 'AccountId' ) );

		system.assertEquals( null, SL_Describe.getRelationshipName( 'Contact', 'Id' ) );
		system.assertEquals( null, SL_Describe.getRelationshipName( SL_Describe.getToken( 'Contact' ), 'Id' ) );
		system.assertEquals( SL_Describe.getDescribe( 'Contact', 'AccountId' ).getRelationshipName(), SL_Describe.getRelationshipName( 'Contact', 'AccountId' ) );

		system.assertEquals( Account.SObjectType, SL_Describe.getReferenceTo( 'Contact', 'AccountId' ) );
		system.assertEquals( Account.SObjectType, SL_Describe.getReferenceTo( SL_Describe.getToken( 'Contact' ), 'AccountId' ) );
		system.assertEquals( null, SL_Describe.getReferenceTo( 'Contact', 'Id' ) );

		system.assertEquals( isRequired( SL_Describe.getDescribe( objectName, fieldName ) ), SL_Describe.isRequired( objectName, fieldName ) );
		system.assertEquals( isRequired( SL_Describe.getDescribe( objectToken, fieldName ) ), SL_Describe.isRequired( objectToken, fieldName ) );
		system.assertEquals( false, SL_Describe.isRequired( incorrectName, incorrectName ) );

		system.assert( SL_DescribeTokens.getObjectMap().containsKey( objectName ) );
		system.assert( !SL_DescribeTokens.getObjectMap().containsKey( incorrectName ) );

		system.assert( SL_DescribeTokens.getFieldMap( objectName ).containsKey( fieldName ) );
		system.assert( !SL_DescribeTokens.getFieldMap( objectName ).containsKey( incorrectName ) );
	}

	static Boolean isRequired( Schema.DescribeFieldResult fieldDescribe ) {
		return fieldDescribe.isCreateable() && !fieldDescribe.isNillable() && !fieldDescribe.isDefaultedOnCreate();
	}
}