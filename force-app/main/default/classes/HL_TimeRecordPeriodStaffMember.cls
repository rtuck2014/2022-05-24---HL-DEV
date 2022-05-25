public with sharing class HL_TimeRecordPeriodStaffMember {
  private Contact Contact {get; set;}
  private Time_Record_Period__c TimeRecordPeriod {get; set;}
  public HL_TimeRecordPeriodStaffMember(Time_Record_Period__c timeRecordPeriod, Contact contact) {
    this.TimeRecordPeriod = timeRecordPeriod;
    this.Contact = contact;
  }

  //Gets the time record period record
  //autoCreate: Indicates if the record should be auto-created if none is found
  public Time_Record_Period_Staff_Member__c GetRecord(boolean autoCreate){
    List<Time_Record_Period_Staff_Member__c> records = [SELECT User__c, Time_Record_Period__c, Time_Record_Period__r.Id, Time_Record_Period__r.Public_Group__c, Contact__r.Name, Title__c FROM Time_Record_Period_Staff_Member__c WHERE Contact__c =: Contact.Id AND Time_Record_Period__c =: TimeRecordPeriod.Id];

    if(records.size() <= 0){
      records.add(new Time_Record_Period_Staff_Member__c(Contact__c = Contact.Id, Time_Record_Period__c = TimeRecordPeriod.Id, User__c = Contact.User__c, Office__c = Contact.Office__c, Title__c = Contact.Title));
      if(autoCreate)
        insert records;
    }

    return records[0]; 
  }
    
    //Gets the time record period record
  //autoCreate: Indicates if the record should be auto-created if none is found
  public Time_Record_Period_Staff_Member__c GetByPeriodAndStaffMember(boolean autoCreate){
    List<Time_Record_Period_Staff_Member__c> records = [SELECT User__c, Time_Record_Period__c FROM Time_Record_Period_Staff_Member__c WHERE Contact__c =: Contact.Id AND Time_Record_Period__c =: TimeRecordPeriod.Id];
    
    if(records.size() <= 0){
      records.add(new Time_Record_Period_Staff_Member__c(Contact__c = Contact.Id, Time_Record_Period__c = TimeRecordPeriod.Id, User__c = Contact.User__c, Office__c = Contact.Office__c, Title__c = Contact.Title));
      if(autoCreate)
        insert records;
    }

    return records[0]; 
  }

    public static List<Time_Record_Period_Staff_Member__c> GetByPeriod(Id timeRecordPeriodId){
        return [SELECT Time_Record_Period__c, Contact__c, User__c, Contact__r.Name, Email__c, Office__c, Phone__c, Title__c
                FROM Time_Record_Period_Staff_Member__c
                WHERE Time_Record_Period__c =:timeRecordPeriodId
                ORDER BY Contact__r.Name];
    }

    public static List<Time_Record_Period_Staff_Member__c> GetByPeriodGroup(Time_Record_Period__c timeRecordPeriod){
        Set<Id> uniqueTimeRecordPeriodStaffMembers = new Set<Id>();
        
        List<Time_Record_Period_Staff_Member__c> members = [SELECT Contact__c FROM Time_Record_Period_Staff_Member__c
                                                			WHERE Time_Record_Period__c =:timeRecordPeriod.Id
                                                			ORDER BY Contact__r.Name];
        
        for (Time_Record_Period_Staff_Member__c trpsm : members) {
            uniqueTimeRecordPeriodStaffMembers.add(trpsm.Contact__c);
        }
        
        if (uniqueTimeRecordPeriodStaffMembers.size() > 0) {
            HL_TimeRecordPeriodStaffMemberHandler smHandler = new HL_TimeRecordPeriodStaffMemberHandler(timeRecordPeriod);
			smHandler.updateTimePeriod(members, timeRecordPeriod);
            List<Time_Record_Period_Staff_Member__c> staffMembers = smHandler.InsertNewStaffMemberRecords(uniqueTimeRecordPeriodStaffMembers);
        }

        return [SELECT Time_Record_Period__c, Contact__c, User__c, Contact__r.Name, Email__c, Office__c, Phone__c, Title__c
                FROM Time_Record_Period_Staff_Member__c
                WHERE Time_Record_Period__c =:timeRecordPeriod.Id
                ORDER BY Contact__r.Name];
    }

    public static List<Time_Record_Period_Staff_Member__c> GetByPeriodAndUser(Id timeRecordPeriodId, Id userId){
        return [SELECT Time_Record_Period__c, Contact__c, User__c, Contact__r.Name, Email__c, Office__c, Phone__c, Title__c
                FROM Time_Record_Period_Staff_Member__c
                WHERE Time_Record_Period__c =:timeRecordPeriodId
                AND User__c =:userId];
    }
}