/**  
* \arg ClassName      : SL_Test_PipelineManager
* \arg JIRATicket     : HL-16
* \arg CreatedOn      : 09/JUNE/2014
* \arg LastModifiedOn : 09/JUNE/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Test class for SL_Paginator class.
*/
@isTest
private class SL_Test_Paginator 
{
	// Create records for Test Coverage
	private static void createTestRecords()  
    {
		List<Account> lstAccount = SL_TestSetupUtils.CreateAccount('Account' , 3);
		insert lstAccount;
	}
	
	// How to pass values for Constructor
	private static testMethod void SL_Paginator() 
	{
		createTestRecords();
		String paramCSVFields = 'Id,Name';
		Integer paramPageSize = 1;
		String paramObjectName = 'Account';
		String paramWhereCondition = '';
        SL_Paginator objPaginatorClass = new SL_Paginator(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition, false, new Set<Id>(), false);
	}
	
	// How to fetch values when we pass for specific page
	private static testMethod void SL_Paginator_goToSpecificPage()
	{
		createTestRecords();
		String paramCSVFields = 'Id,Name'; 
		Integer paramPageSize = 1;
		String paramObjectName = 'Account';
		String paramWhereCondition = '';
		Integer paramPageNumber = 1;
		string fieldset = '';
		SL_Paginator objPaginatorClass = new SL_Paginator(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition ,false, new Set<Id>(), false);

		objPaginatorClass.goToSpecificPage(paramPageNumber);
		system.assert(objPaginatorClass.lstSObjectWrappers.size() == 1); // Page Size we have kept as 1
    }

    // How to fetch values for Next button
    private static testMethod void SL_Paginator_gotoNextPage()
    {
    	createTestRecords();
        String paramCSVFields = 'Id,Name';
        Integer paramPageSize = 1;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        Integer paramPageNumber = 1;
        string fieldset = '';
        SL_Paginator objPaginatorClass = new SL_Paginator(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition, false, new Set<Id>(), false);

        objPaginatorClass.intPageNumber = paramPageNumber;
        objPaginatorClass.gotoNextPage();
        system.assert(objPaginatorClass.lstSObjectWrappers.size() == 1); // Page Size we have kept as 1
    }
	
    // How to fetch values for previous button
    private static testMethod void SL_Paginator_gotoPrevPage()
    {
    	createTestRecords();
        String paramCSVFields = 'Id,Name';
        Integer paramPageSize = 1;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        Integer paramPageNumber = 1;
        string fieldset = '';
        SL_Paginator objPaginatorClass = new SL_Paginator(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition , false, new Set<Id>(), false);

        objPaginatorClass.intPageNumber = paramPageNumber;
        objPaginatorClass.gotoNextPage();
        objPaginatorClass.gotoPrevPage();
        system.assert(objPaginatorClass.lstSObjectWrappers.size() == 1); // Page Size we have kept as 1
    }

    // How to fetch values for first page
    private static testMethod void SL_Paginator_gotoFirstPage()
    {
    	createTestRecords();
        String paramCSVFields = 'Id,Name';
        Integer paramPageSize = 1;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        Integer paramPageNumber = 1;
        string fieldset = '';
        SL_Paginator objPaginatorClass = new SL_Paginator(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition , false, new Set<Id>(), false);

        objPaginatorClass.intPageNumber = paramPageNumber;
        objPaginatorClass.gotoFirstPage();
        system.assert(objPaginatorClass.lstSObjectWrappers.size() == 1); // Page Size we have kept as 1
    }

    // How to fetch values for Last Page
    private static testMethod void SL_Paginator_gotoLastPage()
    {
    	createTestRecords();
        String paramCSVFields = 'Id,Name';
        Integer paramPageSize = 2;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        Integer paramPageNumber = 1;
        string fieldset = '';
        SL_Paginator objPaginatorClass = new SL_Paginator(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition, false, new Set<Id>(), false);

        objPaginatorClass.intPageNumber = paramPageNumber;
        objPaginatorClass.goToSpecificPage(paramPageNumber);
        objPaginatorClass.gotoLastPage();
        system.assert(objPaginatorClass.lstSObjectWrappers.size() == 1); // Page Size we have kept as 1
    }
	
    // How to fetch values when we are dealing with sorting
    private static testMethod void SL_Paginator_getSortingRecords()
    {
    	createTestRecords();
        String paramCSVFields = 'Id,Name';
        Integer paramPageSize = 1;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        Integer paramPageNumber = 1;
        string fieldset = '';
        String paramFieldName = 'Name';
        String paramDirection = 'ASC';

        SL_Paginator objPaginatorClass = new SL_Paginator(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition, false, new Set<Id>(), false);

        objPaginatorClass.getSortingRecords( paramFieldName,1 );
        objPaginatorClass.getSortingRecords( paramFieldName,1 );
		system.assert(objPaginatorClass.lstSObjectWrappers.size() == 1); // Page Size we have kept as 1
    }
	
    // How to fetch values when we pass for specific page
    private static testMethod void SL_Paginator_getListSobjectWrappers()
    {
    	createTestRecords();
        String paramCSVFields = 'Id,Name';
        Integer paramPageSize = 1;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        Integer paramPageNumber = 1;
        String paramDirection = 'ASC';
        string fieldset = '';
        SL_Paginator objPaginatorClass = new SL_Paginator(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition, false, new Set<Id>(), false);

        objPaginatorClass.goToSpecificPage(paramPageNumber);
        objPaginatorClass.gotoPage();
        objPaginatorClass.setSortingQueryString('Name',paramDirection);
        objPaginatorClass.sortRecords();
        system.assert(objPaginatorClass.getListSobjectWrappers().size() == 1); // Page Size we have kept as 1
    }
	
    // How to clear any selected Ids
    private static testMethod void SL_Paginator_clearSelectedItems()
    {
    	createTestRecords();
        String paramCSVFields = 'Id,Name';
        Integer paramPageSize = 1;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        Integer paramPageNumber = 1;
        String paramDirection = 'ASC';
        string fieldset = '';
        SL_Paginator objPaginatorClass = new SL_Paginator(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition, false, new Set<Id>(), false);

        objPaginatorClass.clearSelectedItems();
    }

    // How to fetch selected Ids while going to and fro in pagination
    private static testMethod void SL_Paginator_getSelectedItems()
    {
    	createTestRecords();
        String paramCSVFields = 'Id,Name';
        Integer paramPageSize = 1;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        Integer paramPageNumber = 1;
        String paramDirection = 'ASC';
        string fieldset = '';
        SL_Paginator objPaginatorClass = new SL_Paginator(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition, false, new Set<Id>(), false);

        objPaginatorClass.goToSpecificPage(paramPageNumber);

        system.assert(objPaginatorClass.lstSObjectWrappers.size() == 1);

        objPaginatorClass.lstSObjectWrappers[0].isChecked = true;
        objPaginatorClass.gotoNextPage();

        objPaginatorClass.lstSObjectWrappers[0].isChecked = true;
        objPaginatorClass.gotoPrevPage();

        objPaginatorClass.lstSObjectWrappers[0].isChecked = false;
        objPaginatorClass.gotoNextPage();
	}
	
    // How to set List of SobjectWrapper to class local List
    private static testMethod void SL_Paginator_setListSobjectWrappers()  
    {
    	createTestRecords();
        String paramCSVFields = 'AccountFieldSet';
        Integer paramPageSize = 2;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        Integer paramPageNumber = 2;
        String paramDirection = 'ASC';
        string fieldset = '';
        SL_Paginator objPaginatorClass = new SL_Paginator(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition, true, new Set<Id>(), false);
        
        objPaginatorClass.setListSobjectWrappers(objPaginatorClass.lstSObjectWrappers);
        system.assert(objPaginatorClass.lstSObjectWrappers.size() == 0);
    }
}