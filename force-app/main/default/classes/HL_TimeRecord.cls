global class HL_TimeRecord {
    public static List<Time_Record__c> GetByUser(Id userId, Date startDate, Date endDate){
        return [SELECT Activity_Date__c
                       ,Activity_Type__c
                       ,Amount__c
                       ,Comments__c
                       ,CurrencyIsoCode
                       ,Opportunity__c
                       ,Engagement__c
                       ,Special_Project__c
                       ,Project_Name__c
                       ,Hourly_Rate__c
                       ,Hours_Worked__c
                       ,Staff_Member_Name__c
                       ,Is_Locked__c
                       ,Day_Rollup_Key__c
                FROM Time_Record__c
                WHERE Time_Record_Period_Staff_Member__r.User__c =: userId
                      AND Activity_Date__c >=: startDate
                      AND Activity_Date__c <=: endDate
                      AND Recording_Status__c = 'Complete'
                ORDER BY Activity_Date__c DESC, Project_Name__c];
    }

    //Aggregates the time records to be stored in the rollup day object
    public static List<AggregateResult> GetAggregatedTimeRecordsByDate(Set<Date> activityDateSet, Set<String> relatedObjectIdSet, Set<Id> smSet){
        return  [SELECT
                 Activity_Date__c,
                 Is_Billable__c,
                 Activity_Type__c activity,
                 Engagement__c,
                 Opportunity__c,
                 Special_Project__c,
                 Time_Record_Period_Staff_Member__c,
                 CurrencyIsoCode,
                 MAX(Day_Rollup_Key__c) key,
                 MAX(Hourly_Rate__c) rate,
                 SUM(Hours_Worked__c) sum
                 FROM Time_Record__c
                 WHERE Time_Record_Period_Staff_Member__c IN:smSet AND Activity_Date__c IN:activityDateSet 
                       AND (Opportunity__c IN:relatedObjectIdSet OR Engagement__c IN:relatedObjectIdSet OR Special_Project__c IN:relatedObjectIdSet)
                       AND Recording_Status__c = 'Complete'
                 GROUP BY Activity_Date__c, Activity_Type__c, CurrencyIsoCode, Engagement__c, Opportunity__c, Special_Project__c, Time_Record_Period_Staff_Member__c, Is_Billable__c];
    }

    public static List<Time_Record__c> GetByEngagements(Id recordTypeId, Set<Id> engagementIdSet){
        return [SELECT Engagement__c,
                       Activity_Date__c,
                       Time_Record_Period_Staff_Member__r.Title__c,
                       Hourly_Rate__c
                FROM Time_Record__c
                WHERE RecordTypeId =: recordTypeId AND Engagement__c IN: engagementIdSet AND Recording_Status__c = 'Complete'];
    }
    
    public static List<Time_Record__c> GetByEngagementsOpportunities(Id recordTypeId, Set<Id> engagementIdSet){
        Set<Id> opportunityIdSet = new set<Id>();
        Map<String, String> opp_eng = new Map<String, String>();
        
        for (Engagement__c e : [SELECT Id, Opportunity__c FROM Engagement__c WHERE Id IN: engagementIdSet]) {
            opportunityIdSet.add(e.Opportunity__c);
            opp_eng.put(e.Opportunity__c, e.Id);
		}
        
        List<Time_Record__c> timeRecords = [SELECT Engagement__c,
                       Opportunity__c,
                       Activity_Date__c,
                       Time_Record_Period_Staff_Member__r.Title__c,
                       Hourly_Rate__c
                FROM Time_Record__c
                WHERE Recording_Status__c = 'Complete' AND RecordTypeId =: recordTypeId AND (Engagement__c IN: engagementIdSet OR Opportunity__c IN: opportunityIdSet)];

        for (Time_Record__c t : timeRecords) {
            if (t.Opportunity__c != null && !String.isBlank(t.Opportunity__c)) {
                String engagementId = opp_eng.get(t.Opportunity__c);
                if (engagementId != null && !String.isBlank(engagementId)) {
                    t.Engagement__c = engagementId;
                } 
            }
		}

        return timeRecords;
    }
}