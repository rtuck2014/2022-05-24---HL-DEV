@isTest
private class SL_Test_MonthlyRevenueProcessControlExt 
{
	@isTest static void test_MonthlyRevenueProcessControllerExt() 
	{
        Monthly_Revenue_Process_Control__c mrpcNew = new Monthly_Revenue_Process_Control__c(IsCurrent__c = TRUE, 
		                                                      Current_Month__c = '01', Current_Year__c = '2015',
														      Staff_Summary_Report_Sent__c = TRUE
															  );
		insert mrpcNew;
		
		ApexPages.StandardController sc = new ApexPages.StandardController(mrpcNew);
        SL_MonthlyRevenueProcessControllerExt controller = new SL_MonthlyRevenueProcessControllerExt(sc);
       	controller.createRecord();

		// Confirm that new Monthly Revenue Process Control record was created successfully
		system.assertEquals([Select Id From Monthly_Revenue_Process_Control__c WHERE Current_Month__c = '02' AND Current_Year__c = '2015' AND IsCurrent__c = TRUE].Size(), 1);
	}
}