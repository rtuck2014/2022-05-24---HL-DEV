public with sharing class HL_Event {
    public static final string STANDARD_SELECT = 'SELECT WhatId,CreatedDate, ActivityDate,WhoId, StartDateTime, PFG_Notification__c, Client_Participation__c, No_External_Contact__c, PFG__c, EndDateTime, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c, Sync_To_Outlook__c, Notify_Coverage_Team__c, Followup_Start_Date__c, Followup_Start_Time__c, Followup_End_Date__c, Followup_End_Time__c, Subject, Description, Type, ParentId__c, Private__c, Primary_Attendee_Id__c, Primary_Attendee__c, Primary_External_Contact_Id__c, Primary_External_Contact__c, Primary_External_Contact_Company_Id__c, Primary_External_Contact_Company__c, Is_Complete__c, Mask_As_External__c, Activity_Detail_Report__c, Riva_Activity_Id__c, Riva_Activity_Link_Id__c,  Contact__c, CreatedById, CreatedBy.Name ';

    public static Event GetById(Id eventId){
        List<Event> e = Database.Query(STANDARD_SELECT +  
                                 'FROM Event ' +
                                 'WHERE Id =: eventId ' +
                                 'LIMIT 1');
        return e.size() > 0 ? e[0] : new Event();
    }
}