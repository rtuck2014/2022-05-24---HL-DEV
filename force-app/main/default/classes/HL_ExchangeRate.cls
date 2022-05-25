public with sharing class HL_ExchangeRate {
    private static Map<String, Id> currencyToRate;

    static {
        currencyToRate = new Map<String, Id>();

        for (Exchange_Rate__c er : [
            SELECT CurrencyIsoCode 
            FROM Exchange_Rate__c]) {

            currencyToRate.put(er.CurrencyIsoCode, er.Id);
        }
    }

    public static Map<String, Id> GetCurrencyIsoCodeMap() {
        return currencyToRate;
    }

// GM Jan 6, 2022 - this implementation causes too many SOQL queries
/*    
    public static Map<String,Id> GetCurrencyIsoCodeMap(){
        Map<String,Id> currencyToRate = new Map<String, Id>();
        for(Exchange_Rate__c er : [SELECT CurrencyIsoCode FROM Exchange_Rate__c])
            currencyToRate.put(er.CurrencyIsoCode, er.Id);
        return currencyToRate;
    }
*/    
}