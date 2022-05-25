public with sharing class HL_TimeRecordPeriodStaffMemberHandler {
	public Time_Record_Period__c TimeRecordPeriod {get; set;}
	public List<Contact> StaffMembers {get{
			if(staffMembers == null){
				HL_Group hlGroup = new HL_Group(TimeRecordPeriod.Public_Group__c);
				staffMembers = hlGroup.GetContacts();
			}
			return staffMembers;
		} set;}

	public HL_TimeRecordPeriodStaffMemberHandler(Time_Record_Period__c timeRecordPeriod) {
		this(timeRecordPeriod, null);
	}

	public HL_TimeRecordPeriodStaffMemberHandler(Time_Record_Period__c timeRecordPeriod, List<Contact> staffMembers){
		this.TimeRecordPeriod = timeRecordPeriod;
		this.StaffMembers = staffMembers;
	}

	//Inserts the related time record period staff member records
	public List<Time_Record_Period_Staff_Member__c> InsertRecords(){
		List<Time_Record_Period_Staff_Member__c> recordsToInsert = new List<Time_Record_Period_Staff_Member__c>();
		//Iterate over the Staff Members to create the related records
		for(Contact c : StaffMembers){
			recordsToInsert.add(new Time_Record_Period_Staff_Member__c(Contact__c = c.Id, User__c = c.User__c, Time_Record_Period__c = TimeRecordPeriod.Id, Office__c = c.Office__c, Title__c = c.Title));
		}

		//Insert the records
		if(recordsToInsert.size() > 0)
			insert recordsToInsert;

		return recordsToInsert;
	}

	//Inserts the related time record period staff member records
	public List<Time_Record_Period_Staff_Member__c> InsertNewStaffMemberRecords(Set<Id> timeRecordPeriodStaffMembers){

		List<Time_Record_Period_Staff_Member__c> recordsToInsert = new List<Time_Record_Period_Staff_Member__c>();
		//Iterate over the Staff Members to create the related records
		for(Contact c : StaffMembers){
			if (!timeRecordPeriodStaffMembers.Contains(c.Id)) {
				recordsToInsert.add(new Time_Record_Period_Staff_Member__c(Contact__c = c.Id, User__c = c.User__c, Time_Record_Period__c = TimeRecordPeriod.Id, Office__c = c.Office__c, Title__c = c.Title));
			}	
		}

		//Insert the records
		if(recordsToInsert.size() > 0)
			insert recordsToInsert;

		return recordsToInsert;
	}

	public void updateTimePeriod(List<Time_Record_Period_Staff_Member__c> trpsm, Time_Record_Period__c timePeriod) {
		for (Time_Record_Period_Staff_Member__c trm : trpsm) {
			trm.Time_Record_Period__c = timePeriod.Id;
		}
		update trpsm;
	}
}