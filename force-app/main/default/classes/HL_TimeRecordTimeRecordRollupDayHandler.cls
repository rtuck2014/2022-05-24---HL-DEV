public with sharing class HL_TimeRecordTimeRecordRollupDayHandler {
    List<Time_Record_Rollup_Day__c> TimeRecordRollupDays {get; set;}
    public HL_TimeRecordTimeRecordRollupDayHandler(List<Time_Record_Rollup_Day__c> timeRecordRollupDays) {
        this.TimeRecordRollupDays = timeRecordRollupDays;
    }

    public void InsertJunctionRecords(Set<Id> smSet, Set<String> relatedObjectIdSet, Set<Date> activityDateSet){
        List<Time_Record_Rollup_Day__c> rollupList = TimeRecordRollupDays;
        List<Time_Record_Time_Record_Rollup_Day__c> junctionInsertList = new List<Time_Record_Time_Record_Rollup_Day__c>();
        Map<String,Id> rollupDayMap = new Map<String, Id>();
        Map<Id, Id> existingJunctionsMap = new Map<Id, Id>();
        //Populate rollup day map of key with Id
        for(Time_Record_Rollup_Day__c trrd : [SELECT Key__c FROM Time_Record_Rollup_Day__c WHERE Id IN: rollupList])
            rollupDayMap.put(trrd.Key__c, trrd.Id);

        //Get the existing junction records
        for(Time_Record_Time_Record_Rollup_Day__c j : [SELECT Time_Record__c, Time_Record_Rollup_Day__c FROM Time_Record_Time_Record_Rollup_Day__c WHERE Time_Record_Rollup_Day__c IN: rollupDayMap.values()])
            existingJunctionsMap.put(j.Time_Record__c, j.Time_Record_Rollup_Day__c);

        for(Time_Record__c tr : [SELECT Activity_Date__c, Day_Rollup_Key__c
                                 FROM Time_Record__c
                                 WHERE Time_Record_Period_Staff_Member__c IN:smSet AND Activity_Date__c IN:activityDateSet
                                       AND (Opportunity__c IN:relatedObjectIdSet OR Engagement__c IN:relatedObjectIdSet OR Special_Project__c IN:relatedObjectIdSet)])
        {
            if(!existingJunctionsMap.containsKey(tr.Id))
                junctionInsertList.add(new Time_Record_Time_Record_Rollup_Day__c(Time_Record__c = tr.Id, Time_Record_Rollup_Day__c = rollupDayMap.get(tr.Day_Rollup_Key__c)));
        }

        if(junctionInsertList.size() > 0)
            insert junctionInsertList;

    }
}