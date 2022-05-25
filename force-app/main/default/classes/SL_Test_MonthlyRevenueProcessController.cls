@isTest
private class SL_Test_MonthlyRevenueProcessController 
{
    @isTest static void test_MonthlyRevenueProcessController() 
    {
        Monthly_Revenue_Process_Control__c mrpcNew = new Monthly_Revenue_Process_Control__c(IsCurrent__c = TRUE, 
                                                              Current_Month__c = '02', Current_Year__c = '2015'
                                                              );
        insert mrpcNew;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(mrpcNew);
        SL_MonthlyRevenueProcessController controller = new SL_MonthlyRevenueProcessController(sc);
        controller.initialReversal();
        //controller.unlockAll();
        //controller.lockAll();
        controller.finalReversal();
        controller.exportRevenue();
        controller.earlyLook();
        controller.currencyConversion();
        controller.finalReport();
        controller.staffSummary();
       controller.generateRevenue();
    }
}