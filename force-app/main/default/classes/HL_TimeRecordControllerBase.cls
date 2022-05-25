public with sharing  virtual class HL_TimeRecordControllerBase {
    public HL_TimeRecordControllerBase() {}
 
    //Determines if the user is in the supervisor group
    public static Boolean IsSupervisor(string category){
        return HL_Group.IsInGroup('Time_Tracking_' + category + '_Supervisor');
    }

    //Determines if the user is in the non-supervisor group
    public static Boolean IsInEntryGroup(string category){
        return HL_Group.IsInGroup('Time_Tracking_' + category);
    }

    public static Time_Record_Period__c GetCurrentPeriod(string category){
        return HL_TimeRecordPeriod.GetCurrentPeriod(category);
    }

    public static Time_Record_Period_Staff_Member__c GetCurrentTimeRecordPeriodStaffMemberRecord(string category){
        Contact c = HL_Contact.GetByUserId();
        Time_Record_Period__c trp = GetCurrentPeriod(category);

        HL_TimeRecordPeriodStaffMember sm = new HL_TimeRecordPeriodStaffMember(trp, c);
        return category == 'FR' ? sm.GetRecord(false) : sm.GetRecord(IsInEntryGroup(category));
    }

    public static Time_Record_Period_Staff_Member__c GetTimeRecordPeriodStaffMemberRecord(string category, Time_Record_Period__c timePeriod){
        Contact c = HL_Contact.GetByUserId();

        HL_TimeRecordPeriodStaffMember sm = new HL_TimeRecordPeriodStaffMember(timePeriod, c);
        return category == 'FR' ? sm.GetRecord(false) : sm.GetRecord(IsInEntryGroup(category));
    }

    public static List<Opportunity__c> GetOpportunities(string category, string userId){
        List<Opportunity__c> results = HL_Opportunity.GetByUser(userId, new Set<String>{'Active', 'Engaged', 'Hold'});
        return results;
    }

    public static List<Engagement__c> GetEngagements(string category, string userId){
        List<Engagement__c> results = HL_Engagement.GetByUser(userId, new Set<String>{'Active','Closed','Hold'}, Date.today().addMonths(-12));
        return results;
    }

    public static List<Special_Project__c> GetSpecialProjects(Id recordTypeId){
        return HL_SpecialProject.GetByRecordTypeId(recordTypeId);
    }
}