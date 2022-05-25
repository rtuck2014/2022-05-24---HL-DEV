public class HL_TimeRecordPeriodStaffMemberController extends HL_TimeRecordControllerBase {
    @AuraEnabled
    public static List<Time_Record_Period_Staff_Member__c> GetByPeriod(string category, Id timeRecordPeriodId){
        if(timeRecordPeriodId == null)
            timeRecordPeriodId = HL_TimeRecordPeriod.GetCurrentPeriod(category).Id;

        return HL_TimeRecordPeriodStaffMember.GetByPeriod(timeRecordPeriodId);
    }
    
    @AuraEnabled
    public static List<Time_Record_Period_Staff_Member__c> GetByPeriodGroup(string category, Time_Record_Period__c timeRecordPeriod) {
        Time_Record_Period__c trp = [Select Id, Public_Group__c FROM Time_Record_Period__c WHERE Id =: timeRecordPeriod.Id];
        if(trp == null) {
            trp = HL_TimeRecordPeriod.GetCurrentPeriod(category);
        }

        return HL_TimeRecordPeriodStaffMember.GetByPeriodGroup(trp);
    }
    
    @AuraEnabled
    public static Time_Record_Period_Staff_Member__c GetCurrentRecord(string category){
        return HL_TimeRecordControllerBase.GetCurrentTimeRecordPeriodStaffMemberRecord(category);
    }

    //Gets the User's Category based on the group they are in
    @AuraEnabled
    public static String GetCategory(){
        return HL_Group.GetTimeTrackingGroup();
    }
}