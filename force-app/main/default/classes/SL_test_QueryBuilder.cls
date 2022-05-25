/**
 * \author Vladimir Dobrelya
 * \date Nov 26, 2014
 * \brief The test class for SL_QueryBuilder
 */
@isTest
private class SL_test_QueryBuilder {
	static String objectName = 'Account', fieldName = 'Name', testValue = 'TestValue', whereClause = 'Id != null', orderBy = 'Name DESC';		 
	static SL_QueryBuilder qBuilder;
	static String resultQuery = 
		'SELECT ' + fieldName + 
		' FROM ' + objectName +
		' WHERE ' + fieldName + ' = \'' + testValue +
			'\' AND ' + whereClause + 
		' ORDER BY ' + orderBy +
		' LIMIT 10' + 
		' OFFSET 2';

	@isTest static void test_method() {
		qBuilder = new SL_QueryBuilder( fieldName, objectName );
		system.assertEquals( 'SELECT ' + fieldName + ' FROM ' + objectName, qBuilder.build() );

		qBuilder.getWhereDefault().add( fieldName + ' = \'' + testValue + '\'' );
		qBuilder.setWhere( new List<String>{ whereClause } );
		system.assertEquals( whereClause, qBuilder.getWhere().get( 0 ) );

		qBuilder.getOrderBy().add( orderBy );

		qBuilder.limitCount = 10;
		qBuilder.offsetCount = 2;
		system.assertEquals( resultQuery, qBuilder.build() );
	}
}