public class HL_ActivityRelatedListController {
/*
    @auraEnabled(cacheable=true)
    public static List<Event> getRecords(Id recordId){   
    String sObjectName = recordId.getSObjectType().getDescribe().getName();
        String whereclause;
        
        String querystring = 'SELECT Id,AccountId, WhatId, WhoId, StartDateTime, EndDateTime, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c,'+ 
                             'Sync_To_Outlook__c, Notify_Coverage_Team__c, Subject, Description, Type, ParentId__c, Private__c,'+ 
                             'Primary_Attendee__c, Primary_External_Contact__c, CreatedById, CreatedBy.Name FROM EVENT WHERE ';
        
        String andClause = ' AND Type <> \'Internal\' AND Type <> \'Follow-up Internal\' AND ParentId__c <> null'+
                             ' AND (EndDateTime > TODAY OR EndDateTime = LAST_N_DAYS:730) ORDER BY EndDateTime DESC';
            
        if(sObjectName == 'Account'){
          whereClause =' AccountId =:recordId ';
        }
        else if(sObjectName == 'Contact') {
           whereClause =' WhoId =:recordId ';
        }
        
        String query = queryString  + whereClause + andClause; 
        system.debug('query>>>'+query);
        List<Event> eventList = Database.query(query);
        system.debug('eventList>>>'+eventList.size());
        return eventList;
    }
*/
}