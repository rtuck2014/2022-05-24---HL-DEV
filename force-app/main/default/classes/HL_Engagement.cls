public with sharing class HL_Engagement {
    public static final string STANDARD_SELECT = 'SELECT Name, Client__r.Name, Subject__r.Name, Job_Type__c, Line_of_Business__c, Industry_Group__c, Is_Foreign_Office__c, Primary_Office__c, Stage__c ';

    public static List<Engagement__c> GetByUser(Id userId, Set<String> statusSet){
        if(String.isBlank(userId))
            userId = UserInfo.getUserId();
        return [SELECT Name, Engagement_Number__c, Line_of_Business__c, Opportunity_Number__c
                FROM Engagement__c
                WHERE Id IN (SELECT Engagement__c 
                             FROM Engagement_Internal_Team__c 
                             WHERE Contact__r.User__c =: userId AND End_Date__c = null)
                AND Status__c IN: statusSet
                ORDER BY Name];
    }

    public static List<Engagement__c> GetByUser(Id userId, Set<String> statusSet, Date minCloseDate){
        if(String.isBlank(userId))
            userId = UserInfo.getUserId();
        return [SELECT Name, Engagement_Number__c, Line_of_Business__c, Opportunity_Number__c, Close_Date__c
                FROM Engagement__c
                WHERE Id IN (SELECT Engagement__c 
                             FROM Engagement_Internal_Team__c 
                             WHERE Contact__r.User__c =: userId AND End_Date__c = null)
                AND Status__c IN: statusSet
                AND (Close_Date__c = null OR Close_Date__c >=: minCloseDate)
                ORDER BY Name];
    }

    public static List<Engagement__c> GetByPublicGroup(String publicGroup, Set<String> statusSet, Date minCloseDate){
        List<Engagement__c> engagementList = new List<Engagement__c>();

        if(!String.isBlank(publicGroup) && statusSet != null && statusSet.size() > 0 && minCloseDate != null){
            //Retrieve the User List from the Group Members
            List<User> userList = HL_Group.GetGroupMembers(publicGroup);

            if(userList.size() > 0){
                return [SELECT Name, Engagement_Number__c, Line_of_Business__c, Opportunity_Number__c
                        FROM Engagement__c
                        WHERE Id IN (SELECT Engagement__c 
                                     FROM Engagement_Internal_Team__c 
                                     WHERE Contact__r.User__c IN: userList AND End_Date__c = null)
                        AND Status__c IN: statusSet
                        AND (Close_Date__c = null OR Close_Date__c >=: minCloseDate)
                        ORDER BY Name];
            }
        }

        return engagementList;
    }

    public static Map<Id, Set<Id>> GetEngagementMapByContacts(Set<Id> contacts, Set<String> statusSet){
        Map<Id, Set<Id>> engMap = new Map<Id, Set<Id>>();
        for(Engagement_Internal_Team__c e : [SELECT Contact__c, Engagement__c 
                                             FROM Engagement_Internal_Team__c 
                                             WHERE Contact__c IN: contacts AND Engagement__r.Status__c IN: statusSet])
        {
            if(engMap.get(e.Contact__c) == null)
                engMap.put(e.Contact__c, new Set<Id>{e.Engagement__c});
            else
            {
                Set<Id> engSet = engMap.get(e.Contact__c);
                engSet.add(e.Engagement__c);
            }
        }
        return engMap;
    }

    public static List<Engagement__c> GetByUserAtPointInTime(Id userId, Date startDate, Date endDate, Date minStatusDate){
        if(String.isBlank(userId))
            userId = UserInfo.getUserId();
        
        return [SELECT Name, Engagement_Number__c, Line_of_Business__c
                FROM Engagement__c
                WHERE Id IN (SELECT Engagement__c 
                             FROM Engagement_Internal_Team__c 
                             WHERE Contact__r.User__c =: userId 
                                   AND Start_Date__c <=:endDate AND (End_Date__c = null OR End_Date__c <=: startDate))
                AND (
                        Close_Date__c = null OR Close_Date__c >=: minStatusDate
                        OR ((Status__c = 'Hold' OR Status__c = 'Dead') AND Latest_Stage_Change__c >=: minStatusDate)
                    )
                ORDER BY Name];
    }

    @AuraEnabled
    public static Engagement__c GetMailMerge(Id engId){
        string query = 'SELECT ';
        for(Schema.FieldSetMember fsm : HL_Utility.GetFieldSet('Engagement__c', 'Mail_Merge_Fields').getFields())
            query += fsm.getFieldPath() + ', ';
        query += 'Client__r.Name, Primary_External_Contact__r.Name, Subject__r.Name, Retainer__c FROM Engagement__c WHERE Id = \'' + engId + '\'';
        List<Engagement__c> engList = Database.Query(query);
        return engList.size() > 0 ? engList[0] : null;
    }

    @AuraEnabled
    public static Engagement__c GetByEId(Id engId){
        List<Engagement__c> engList = Database.Query(STANDARD_SELECT + 'FROM Engagement__c WHERE Id =: engId');
        return engList.size() > 0 ? engList[0] : null;
    }

    @AuraEnabled
    public static Engagement__c GetById(Id engId){
        List<Engagement__c> engagementList = [SELECT Engagement_Number__c, Name, Client__c, Subject__c, 
                                                     Client_Billing_Address__c, Client_Number__c, Client__r.Name, 
                                                     Subject__r.Name, Job_Type__c, Line_of_Business__c, Industry_Group__c, 
                                                     Is_Foreign_Office__c, One_Pager_Completed__c, One_Pager_Completed_By__c, 
                                                     One_Pager_Completed_Date__c, Primary_Contact_Email__c, Primary_External_Contact__c, 
                                                     Primary_External_Contact__r.Name, Primary_Office__c, Stage__c 
                                              FROM Engagement__c 
                                              WHERE Id =: engId];
        return engagementList.size() > 0 ? engagementList[0] : null;
    }
}