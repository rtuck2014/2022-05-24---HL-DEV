public with sharing class HL_TimeRecordRollupWeek {
	private Time_Record_Rollup_Week__c TimeRecordRollupWeek {get; set;}
	
	public HL_TimeRecordRollupWeek(Time_Record_Rollup_Week__c timeRecordRollupWeek) {
		this.TimeRecordRollupWeek = timeRecordRollupWeek;
	}

	public Time_Record_Rollup_Week__c InsertRecord(){
		if([SELECT Id FROM Time_Record_Rollup_Week__c WHERE Time_Record_Period_Staff_Member__c =: TimeRecordRollupWeek.Time_Record_Period_Staff_Member__c AND 
														    Engagement__c =: TimeRecordRollupWeek.Engagement__c AND
														    Opportunity__c =: TimeRecordRollupWeek.Opportunity__c AND
														    Special_Project__c =: TimeRecordRollupWeek.Special_Project__c].size() == 0)
		{
			insert TimeRecordRollupWeek;
		}
		else
			throw new DuplicateRecordException('Record Already Exists');
			//TimeRecordRollupWeek.addError('Record Already Exists');
		return TimeRecordRollupWeek;
	}

	public static List<Time_Record_Rollup_Week__c> GetByTimeRecordPeriodStaffMember(Id timeRecordPeriodStaffMemberId){
		return [SELECT Comments__c,CurrencyIsoCode,Project_Name__c,Hours_Worked_Weekday__c, Hours_Worked_Weekend__c,Staff_Member_Name__c FROM Time_Record_Rollup_Week__c WHERE Time_Record_Period_Staff_Member__c =: timeRecordPeriodStaffMemberId ORDER BY Project_Name__c];
	}

	public class DuplicateRecordException extends Exception{}
}