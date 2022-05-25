public with sharing class EventRedirectLightningCon {
    @AuraEnabled
    public static String getEventParentId(String recordId){
        Event e = [SELECT Id,ParentId__c FROM Event WHERE Id=:recordId];
        if(String.isNotBlank(e.ParentId__c)){
            return e.ParentId__c;            
        }else{
            return e.Id;
        }
        
    }
}