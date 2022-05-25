global with sharing class HL_PostalCode {
    public HL_PostalCode(ApexPages.StandardController controller) {} // empty constructor
    public HL_PostalCode(HL_LookupAccountController controller){}
    @RemoteAction
    global static List<Postal_Code__c> GetByPostalCode(String postalCode){
        if(!String.isBlank(postalCode) && postalCode.length() > 5){
            postalCode = postalCode.substring(0,5);
        }
        return [SELECT CITY__c, COUNTY__c, STATE__c FROM Postal_Code__c WHERE ZIPCODE__c =: postalCode];
    }
}