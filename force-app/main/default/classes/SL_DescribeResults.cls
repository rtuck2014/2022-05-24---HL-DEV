/**
 * \author Vladimir Dobrelya
 * \date Dec 4, 2014
 * \see https://silverline.jira.com/browse/LIB-271
 * \brief The low-level class of the describe logic(Describes). Should NOT be modified. [ Lazy-loading pattern ]
 */
public class SL_DescribeResults {
	private static Map<Schema.SObjectType, Schema.DescribeSObjectResult> objectDescribes = new Map<Schema.SObjectType, Schema.DescribeSObjectResult>();
	private static Map<Schema.SObjectField, Schema.DescribeFieldResult> fieldDescribes = new Map<Schema.SObjectField, Schema.DescribeFieldResult>();

	// returns an object describe for object which name = sObjectName
	public static DescribeSObjectResult get( String sObjectName ) {
		return get( SL_DescribeTokens.get( sObjectName ) );
	}

	public static DescribeSObjectResult get( Schema.SObjectType objectToken ) {
		if ( objectToken == null ) {
			return null;
		}
		if ( !objectDescribes.containsKey( objectToken ) ) {
			objectDescribes.put( objectToken, objectToken.getDescribe() );
		}
		return objectDescribes.get( objectToken );
	}

	// returns a field describe for field which name = fieldName 
	public static DescribeFieldResult get( Schema.SObjectType objectToken, String fieldName ) {
		return get( SL_DescribeTokens.get( objectToken, fieldName ) );
	}
	
	public static DescribeFieldResult get( String sObjectName, String fieldName ) {
		return get( SL_DescribeTokens.get( sObjectName, fieldName ) );
	}

	public static DescribeFieldResult get( Schema.SObjectField fieldToken ) {
		if ( fieldToken == null ) {
			return null;
		}
		if ( !fieldDescribes.containsKey( fieldToken ) ) {
			fieldDescribes.put( fieldToken, fieldToken.getDescribe() );
		}
		return fieldDescribes.get( fieldToken );
	}
}