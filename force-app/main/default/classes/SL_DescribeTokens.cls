/**
 * \author Vladimir Dobrelya
 * \date Dec 4, 2014
 * \see https://silverline.jira.com/browse/LIB-271
 * \brief The low-level class of the describe logic(Tokens). Should NOT be modified. [ Lazy-loading pattern ]
 */
public class SL_DescribeTokens {
	private static Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
	private static Map<Schema.SObjectType, Map<String, Schema.SObjectField>> objectFields = new Map<Schema.SObjectType, Map<String, Schema.SObjectField>>();

	// returns an object token for object which name = sObjectName
	public static Schema.SObjectType get( String sObjectName ) {
		return globalDescribe.get( sObjectName );
	}

	// returns a field token for field which name = fieldName 
	public static Schema.SObjectField get( Schema.SObjectType objectToken, String fieldName ) {
		if ( objectToken == null || String.isBlank( fieldName ) ) {
			return null;
		}
		return getFieldMap( objectToken ).get( fieldName );
	}

	public static Schema.SObjectField get( String sObjectName, String fieldName ) {
		return get( get( sObjectName ), fieldName );
	}

	public static Boolean isExisting( String sObjectName ) {
		return globalDescribe.containsKey( sObjectName );
	}

	public static Boolean isExisting( String sObjectName, String fieldName ) {
		return getFieldMap( sObjectName ).containsKey( fieldName );
	}

	public static Boolean isExisting( Schema.SObjectType objectToken, String fieldName ) {
		return getFieldMap( objectToken ).containsKey( fieldName );
	}

	public static Map<String, Schema.SObjectType> getObjectMap() {
		return globalDescribe;
	}

	public static Map<String, Schema.SObjectField> getFieldMap( Schema.SObjectType objectToken ) {
		if ( objectToken == null ) {
			return new Map<String, Schema.SObjectField>();
		}
		if ( !objectFields.containsKey( objectToken ) ) {
			objectFields.put( objectToken, SL_DescribeResults.get( objectToken ).fields.getMap() ); // must be exactly describe.fields.getMap(), because it is a "magical" stangard and case insensetive map
		}
		return objectFields.get( objectToken );
	}

	public static Map<String, Schema.SObjectField> getFieldMap( String sObjectName ) {
		return getFieldMap( get( sObjectName ) );
	}
}