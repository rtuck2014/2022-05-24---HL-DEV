/**
 * \author Vladimir Dobrelya
 * \date Nov 26, 2014
 * \brief The test class for SL_Pagination
 */
@isTest
private class SL_test_Pagination {
	static SL_Pagination pagination;

	@isTest static void test_method() {
		pagination = new SL_Pagination();
		system.assertEquals( 1, pagination.getPage() );
		system.assertEquals( 1, pagination.getRecordCount() );
		system.assertEquals( 1, pagination.getItemsPerPage() );

		// next() when there is 1 page
		system.assertEquals( false, pagination.hasNext );
		pagination.next();
		system.assertEquals( 1, pagination.getPage() );

		// previous() when there is 1 page
		system.assertEquals( false, pagination.hasPrevious );
		pagination.previous();
		system.assertEquals( 1, pagination.getPage() );

		// change record count and items per page
		pagination.setRecordCount( 5 );
		pagination.setItemsPerPage( 2 );
		system.assertEquals( 1, pagination.getPage() );
		system.assertEquals( 3, pagination.getLastPage() );

		// next() to the 2nd page
		system.assertEquals( true, pagination.hasNext );
		pagination.next();
		system.assertEquals( 2, pagination.getPage() );
		system.assertEquals( false, pagination.isLastPage );

		// previous() to the 1st page
		system.assertEquals( true, pagination.hasPrevious );
		pagination.previous();
		system.assertEquals( 1, pagination.getPage() );
		pagination.setPage( '1' );
	}	
}