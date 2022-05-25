public with sharing class HL_TimeRecordRollupWeekHandler {
	private Time_Record_Period__c TimeRecordPeriod {get; set;}
    private List<Time_Record_Period_Staff_Member__c> StaffMembers {get{
        if(staffMembers == null)
            staffMembers = HL_TimeRecordPeriodStaffMember.GetByPeriod(TimeRecordPeriod.Id);
        
        return staffMembers;
    } set;}

	public HL_TimeRecordRollupWeekHandler(Time_Record_Period__c timeRecordPeriod, List<Time_Record_Period_Staff_Member__c> staffMembers) {
		this.TimeRecordPeriod = timeRecordPeriod;
		this.StaffMembers = staffMembers;
	}

	//Inserts the default Time_Record_Period_Staff_Member__c records based on the period category
    //FR - Inserts the Time_Record__c records for their deals
    public void InsertDefaultRecords(){
        if(TimeRecordPeriod.Period_Category__c == 'FR'){
            Map<Id,Id> contactToUserMap = new Map<Id, Id>();
            Map<Id,Time_Record_Period_Staff_Member__c> contactToStaffMemberMap = new Map<Id,Time_Record_Period_Staff_Member__c>();

            for(Time_Record_Period_Staff_Member__c sm : StaffMembers){
                contactToUserMap.put(sm.Contact__c, sm.User__c);
                contactToStaffMemberMap.put(sm.Contact__c, sm);
            }

            InsertDefaultFRRecords(contactToUserMap, contactToStaffMemberMap);
        }
    }

    //Inserts the default records for FR Staff members for the deals they are staffed on
    private List<Time_Record_Rollup_Week__c> InsertDefaultFRRecords(Map<Id,Id> contactToUserMap, Map<Id, Time_Record_Period_Staff_Member__c> contactToStaffMemberMap){
        Set<String> dealStatuses = new Set<String>{'Active','Hold'};  //Status of deals to insert records for
        Map<Id, Set<Id>> contactToOppMap = HL_Opportunity.GetOpportunityMapByContacts(contactToUserMap.keySet(), dealStatuses);
        Map<Id, Set<Id>> contactToEngMap = HL_Engagement.GetEngagementMapByContacts(contactToUserMap.keySet(), dealStatuses);
        List<Time_Record_Rollup_Week__c> trToInsert = new List<Time_Record_Rollup_Week__c>();
        
        for(Id c : contactToEngMap.keySet()){
            Set<Id> idSet = contactToOppMap.get(c);
            if(idSet != null)
            {
                for(Id o : idSet)
                    trToInsert.add(new Time_Record_Rollup_Week__c(Opportunity__c = o, Time_Record_Period_Staff_Member__c = contactToStaffMemberMap.get(c).Id));
            }
            
            idSet = contactToEngMap.get(c);
            if(idSet != null){
                for(Id e : idSet)
                    trToInsert.add(new Time_Record_Rollup_Week__c(Engagement__c = e, Time_Record_Period_Staff_Member__c = contactToStaffMemberMap.get(c).Id));
            }
           }

        if(trToInsert.size() > 0)
            insert trToInsert;

        return trToInsert;
    }
}