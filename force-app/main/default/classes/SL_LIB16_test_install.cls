@isTest
private class SL_LIB16_test_install
{
	private static testMethod void testPostInstallClass()
	{
		Test.startTest();
		SL_LIB16_install controller = new SL_LIB16_install();
		controller.getFieldList4Parent();
		controller.getFieldList4Search();
		controller.getObjectListItems();
		controller.isShowStep2Fld = false;
		controller.runSaveImpl();
		controller.isShowStep2Fld = true;
		controller.runSaveImpl();
		
		controller.runCancelImpl();
		
		controller.runChecker();
		
		Test.stopTest();
	}
}