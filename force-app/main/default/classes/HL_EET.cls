public with sharing class HL_EET {
    public static List<Engagement_External_Team__c> GetByRole(id engagementId, string role){
        return [SELECT Contact__c, Contact__r.Name, Contact__r.Account.Name, Primary__c FROM Engagement_External_Team__c WHERE Engagement__c =: engagementId AND Role__c =: role ORDER BY Contact__r.Name];
    }
    
    public static List<Engagement_External_Team__c> GetByRecordTypeId(id engagementId, id recordTypeId){
        return [SELECT Contact__r.Name, Role__c FROM Engagement_External_Team__c WHERE Engagement__c =: engagementId AND RecordTypeId =: recordTypeId ORDER BY Contact__r.Name];
    }
    
    public static List<Engagement_External_Team__c> GetByRecordTypeIdFRExt(id engagementId, id recordTypeId){
        return [SELECT Contact__r.Name, Role__c FROM Engagement_External_Team__c WHERE Engagement__c =: engagementId AND RecordTypeId =: recordTypeId AND Key_External_Contact__c = TRUE ORDER BY Contact__r.Name];
    }
    
}