public with sharing class HL_TimeRecordRollupWeekController extends HL_TimeRecordControllerBase {
    @AuraEnabled
    public static List<Time_Record_Rollup_Week__c> GetTimeRecordWeekRollups(Id timeRecordPeriodStaffMemberId){
        return HL_TimeRecordRollupWeek.GetByTimeRecordPeriodStaffMember(timeRecordPeriodStaffMemberId);
    }

    @AuraEnabled
    public static List<Time_Record_Period_Staff_Member__c> GetTimeRecordPeriodStaffMemberByPeriodAndUser(Id timeRecordPeriodId, Id userId){
        return HL_TimeRecordPeriodStaffMember.GetByPeriodAndUser(timeRecordPeriodId, userId);
    }

    @AuraEnabled
    public static Time_Record_Period__c GetCurrentPeriod(string category){
        return HL_TimeRecordControllerBase.GetCurrentPeriod(category);
    }

    @AuraEnabled
    public static Time_Record_Period_Staff_Member__c GetCurrentTimeRecordPeriodStaffMemberRecord(string category){
        return HL_TimeRecordControllerBase.GetCurrentTimeRecordPeriodStaffMemberRecord(category);
    }

    @AuraEnabled
    public static String GetCategory(){
        return HL_Group.GetTimeTrackingGroup();
    }

    @AuraEnabled
    public static Time_Record_Rollup_Week__c UpdateHoursWorkedWeekday(Id recordId, decimal value){
        Time_Record_Rollup_Week__c tr = new Time_Record_Rollup_Week__c(Id = recordId, Hours_Worked_Weekday__c = value);
        update tr;
        return tr;
    }

    @AuraEnabled
    public static Time_Record_Rollup_Week__c UpdateHoursWorkedWeekend(Id recordId, decimal value){
        Time_Record_Rollup_Week__c tr = new Time_Record_Rollup_Week__c(Id = recordId, Hours_Worked_Weekend__c = value);
        update tr;
        return tr;
    }

    @AuraEnabled
    public static Time_Record_Rollup_Week__c UpdateComments(Id recordId, string value){
        Time_Record_Rollup_Week__c tr = new Time_Record_Rollup_Week__c(Id = recordId, Comments__c = value);
        update tr;
        return tr;
    }

    @AuraEnabled
    public static Time_Record_Rollup_Week__c InsertRollupWeekRecord(Time_Record_Rollup_Week__c tr){
        //Insert the time record rollup week
        HL_TimeRecordRollupWeek rollupWeek = new HL_TimeRecordRollupWeek(tr);
        return rollupWeek.InsertRecord();
    }

    @AuraEnabled
    public static Time_Record_Rollup_Week__c DeleteRecord(Id recordId){
        Time_Record_Rollup_Week__c tr = new Time_Record_Rollup_Week__c(Id = recordId);
        delete tr;
        return tr;
    }

    //Determines if the user is in the supervisor group
    @AuraEnabled
    public static Boolean IsSupervisor(string category){
        return HL_TimeRecordControllerBase.IsSupervisor(category);
    }

    @AuraEnabled
    public static List<Opportunity__c> GetOpportunities(string category, string userId){
        return HL_TimeRecordControllerBase.GetOpportunities(category, userId);
    }

    @AuraEnabled
    public static List<Special_Project__c> GetSpecialProjects(){
        string category = GetCategory();
        if(String.isBlank(category))
            category = 'FR';
        Id spRecordTypeId = Schema.sObjectType.Special_Project__c.getRecordTypeInfosByName().get(category).getRecordTypeId();
        return HL_TimeRecordControllerBase.GetSpecialProjects(spRecordTypeId);
    }

    @AuraEnabled
    public static List<Engagement__c> GetEngagements(string category, string userId){
        return HL_TimeRecordControllerBase.GetEngagements(category, userId);
    }

}