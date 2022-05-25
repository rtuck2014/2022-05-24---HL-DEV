@isTest
private class Test_HL_ExchangeRate {
    @isTest private static void TestGetCurrencyIsoCodeMap(){
        //Setup Test Data
        Exchange_Rate__c er = new Exchange_Rate__c(CurrencyIsoCode = 'USD');
        insert er;
        
        //Test Method
        Test.startTest();
        	Map<String,Id> mapResult = HL_ExchangeRate.GetCurrencyIsoCodeMap();
        	System.assertEquals(mapResult.size(),1);
        Test.stopTest();
    }
}