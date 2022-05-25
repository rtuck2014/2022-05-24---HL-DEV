public with sharing class HL_TimeRecordRollupDay {
  public static List<Time_Record_Rollup_Day__c> GetByUser(Id userId, Date startDate, Date endDate) {
    return [SELECT Activity_Date__c,
            Activity_Type__c,
            Amount__c,
            Comments__c,
            CurrencyIsoCode,
            Project_Name__c,
            Hourly_Rate__c,
            Hours_Worked__c,
            Staff_Member_Name__c,
            SummaryBillableHours__c,
            SummaryNonBillableHours__c
            FROM Time_Record_Rollup_Day__c
            WHERE Activity_Date__c >= : startDate AND Activity_Date__c <= : endDate
            AND Time_Record_Period_Staff_Member__r.User__c = : userId
                ORDER BY Activity_Date__c DESC, Project_Name__c];
  }

  //Gets the rollup day records by keys
  public static List<Time_Record_Rollup_Day__c> GetByKeys(Set<String> keySet) {
    return [SELECT Key__c,
            Activity_Type__c,
            CurrencyIsoCode,
            Hourly_Rate__c,
            Hours_Worked__c,
            SummaryBillableHours__c,
            SummaryNonBillableHours__c
            FROM Time_Record_Rollup_Day__c
            WHERE Key__c IN:keySet];
  }

  public static List<AggregateResult> GetGroupedByDayAndProject(Id userId, Date startDate, Date endDate) {
    return [SELECT Time_Record_Period_Staff_Member__r.User__c,
            Activity_Date__c,
            Engagement__c,
            Opportunity__c,
            Special_Project__c,
            Activity_Type__c,
            MAX(Time_Record_Period_Staff_Member__r.Contact__c) Contact__c,
            SUM(Hours_Worked__c) Hours,
            MAX(Staff_Member_Name__c) Name
            FROM Time_Record_Rollup_Day__c
            WHERE Activity_Date__c >= : startDate AND Activity_Date__c <= : endDate
            AND Time_Record_Period_Staff_Member__r.User__c = : userId
                GROUP BY Time_Record_Period_Staff_Member__r.User__c, Activity_Date__c, Engagement__c, Opportunity__c, Special_Project__c, Activity_Type__c
            ORDER BY Activity_Date__c ASC];
  }

  public static List<AggregateResult> GetGroupedByEngagement(String category, Date startDate, Date endDate) {
    return [SELECT
            Engagement__c,
            Engagement__r.Name,
            Engagement__r.Engagement_Number__c,
            SUM(Hours_Worked__c) Hours,
            SUM(Amount__c) Amount
            FROM Time_Record_Rollup_Day__c
            WHERE Activity_Date__c >= : startDate AND Activity_Date__c <= : endDate
            AND Engagement__c != null
            AND Time_Record_Period_Staff_Member__r.Time_Record_Period__r.Period_Category__c = : category
                GROUP BY Engagement__c, Engagement__r.Name, Engagement__r.Engagement_Number__c
            ORDER BY Engagement__r.Name];
  }

  public static List<AggregateResult> GetGroupedByEngagement(String category, Date startDate, Date endDate, List<Id> engagementIdList) {
    return [SELECT
            Engagement__c,
            Engagement__r.Name,
            Engagement__r.Engagement_Number__c,
            SUM(Hours_Worked__c) Hours,
            SUM(Amount__c) Amount
            FROM Time_Record_Rollup_Day__c
            WHERE Activity_Date__c >= : startDate AND Activity_Date__c <= : endDate
            AND Engagement__c IN: engagementIdList
            AND Time_Record_Period_Staff_Member__r.Time_Record_Period__r.Period_Category__c = : category
                GROUP BY Engagement__c, Engagement__r.Name, Engagement__r.Engagement_Number__c
            ORDER BY Engagement__r.Name];
  }

  public static List<AggregateResult> GetGroupedByDay(Id userId, Date startDate, Date endDate) {
    return [SELECT Time_Record_Period_Staff_Member__r.User__c,
            Activity_Date__c,
            MAX(Time_Record_Period_Staff_Member__r.Contact__c) Contact__c,
            SUM(Hours_Worked__c) Hours,
            SUM(SummaryBillableHours__c) BillableHours,
            SUM(SummaryNonBillableHours__c) NonBillableHours,
            //SUM(Hours_Worked_Billable__c) BillableHours,
            //SUM(Hours_Worked_Non_Billable__c) NonBillableHours,
            MAX(Staff_Member_Name__c) Name
            FROM Time_Record_Rollup_Day__c
            WHERE Activity_Date__c >= : startDate AND Activity_Date__c <= : endDate
            AND Time_Record_Period_Staff_Member__r.User__c = : userId
                GROUP BY Time_Record_Period_Staff_Member__r.User__c, Activity_Date__c
            ORDER BY Activity_Date__c ASC];
  }

  public static List<Time_Record_Rollup_Day__c> GetEngagementsLoggedForUser(Id userId, Date startDate, Date endDate) {
    return [SELECT Engagement__c
            , Engagement__r.Engagement_Number__c
            , Engagement__r.Name
            FROM Time_Record_Rollup_Day__c
            WHERE Activity_Date__c >= : startDate AND Activity_Date__c <= : endDate
            AND Time_Record_Period_Staff_Member__r.User__c = : userId];
  }

}