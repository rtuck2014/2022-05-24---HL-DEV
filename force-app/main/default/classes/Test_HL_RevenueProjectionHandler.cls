@isTest
private class Test_HL_RevenueProjectionHandler {
	@isTest private static void TestRevenueProjectionCurrencyIso(){
		Engagement__c newEngagement = HL_TestFactory.CreateEngagement(false);
		newEngagement.CurrencyIsoCode = 'AUD';
		insert newEngagement;
		Revenue_Projection__c newRevenueProjection = new Revenue_Projection__c(Year__c = '2017', Month__c = '01', Engagement__c=newEngagement.Id);
		newRevenueProjection.Line_of_Business__c = 'FR';
		Test.startTest();
		insert newRevenueProjection;
		Test.stopTest();
        
        Revenue_Projection__c insertedRevenueProjection = [SELECT CurrencyIsoCode FROM Revenue_Projection__c];
        
		system.assertEquals('AUD', insertedRevenueProjection.CurrencyIsoCode);
	}
    
    @isTest private static void TestRevenueProjectionUpsert(){
		Engagement__c newEngagement = HL_TestFactory.CreateEngagement(false);
		newEngagement.CurrencyIsoCode = 'AUD';
		insert newEngagement;
		Revenue_Projection__c newRevenueProjection = new Revenue_Projection__c(Year__c = '2017', Month__c = '01', Engagement__c=newEngagement.Id);
		newRevenueProjection.Line_of_Business__c = 'FR';
		Test.startTest();
		upsert newRevenueProjection;
		Test.stopTest();
        
        Revenue_Projection__c insertedRevenueProjection = [SELECT Line_of_Business__c FROM Revenue_Projection__c];
        
		system.assertEquals('FR', insertedRevenueProjection.Line_of_Business__c);
	}
}