global with sharing class HL_Lookup {
    public HL_Lookup(HL_CompanyHomeController controller){}
    @RemoteAction
    public static List<Lookup__c> GetByGroup(String groupName){
        return [SELECT Text__c, Lookup_Group__c, Short_Text__c FROM Lookup__c WHERE Lookup_Group__c =: groupName ORDER BY Sort_Order__c];
    }
    
    @RemoteAction
    global static List<Lookup__c> LookupCountry(String country){
        country = '%' + country + '%';
        return [SELECT Text__c FROM Lookup__c WHERE Lookup_Group__c =: 'Country' AND Text__c LIKE : country ORDER BY Text__c];
    }
}