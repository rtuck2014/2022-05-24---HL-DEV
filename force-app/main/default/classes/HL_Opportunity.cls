public with sharing class HL_Opportunity {
    public static final string STANDARD_SELECT = 'SELECT Name, Client__r.Name, Subject__r.Name, Job_Type__c, Line_of_Business__c, Industry_Group__c, Internal_Team_Prompt__c, Primary_Office__c, Stage__c, Is_Foreign_Office__c ';
    
    public static List<Opportunity__c> GetByUser(Id userId, Set<String> statusSet){
        if(String.isBlank(userId))
            userId = UserInfo.getUserId();
        return [SELECT Name, Opportunity_Number__c, Line_of_Business__c, Status__c
                FROM Opportunity__c 
                WHERE Id IN (SELECT Opportunity__c 
                             FROM Opportunity_Internal_Team__c 
                             WHERE Contact__r.User__c =: userId AND End_Date__c = null) 
                AND Status__c IN: statusSet
                ORDER BY Name];
    }

    public static List<Opportunity__c> GetByUser(Id userId, Set<String> statusSet, Date minEngagedDate){
        if(String.isBlank(userId))
            userId = UserInfo.getUserId();
        return [SELECT Name, Opportunity_Number__c, Line_of_Business__c
                FROM Opportunity__c 
                WHERE Id IN (SELECT Opportunity__c 
                             FROM Opportunity_Internal_Team__c 
                             WHERE Contact__r.User__c =: userId AND End_Date__c = null) 
                AND Status__c IN: statusSet
                AND (Date_Engaged__c = null OR Date_Engaged__c >=: minEngagedDate)
                ORDER BY Name];
    }

    @AuraEnabled
    public static Opportunity__c GetById(Id oppId){
        List<Opportunity__c> oppList = Database.Query(STANDARD_SELECT + 'FROM Opportunity__c WHERE Id =: oppId');
        return oppList.size() > 0 ? oppList[0] : null;
    }
    
    public static Map<Id, Set<Id>> GetOpportunityMapByContacts(Set<Id> contacts, Set<String> statusSet){
        Map<Id, Set<Id>> oppMap = new Map<Id, Set<Id>>();
        for(Opportunity_Internal_Team__c o : [SELECT Contact__c, Opportunity__c 
                                              FROM Opportunity_Internal_Team__c 
                                              WHERE Contact__c IN: contacts AND Opportunity__r.Status__c IN: statusSet])
        {
            if(oppMap.get(o.Contact__c) == null)
                oppMap.put(o.Contact__c, new Set<Id>{o.Opportunity__c});
            else
            {
                Set<Id> oppSet = oppMap.get(o.Contact__c);
                oppSet.add(o.Opportunity__c);
            }
        }
        return oppMap;
    }
}