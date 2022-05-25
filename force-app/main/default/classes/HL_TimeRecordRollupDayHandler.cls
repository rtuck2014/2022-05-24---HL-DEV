/* Modified Date:  11/26/2020 - Sapient
* Description: Updated logic to rollup Billable Hours and Non Billable Hours separately.
*   a) validateRequiredFieldsOnStageChange()
*Modified Date:  12/15/2020 - Sapient
* Description: Updated logic to fix creation on duplicate 'Time Record Rollup Day' on mass update.
*   a) rollupRecords()
*/


public with sharing class HL_TimeRecordRollupDayHandler {
    private List<Time_Record__c> TimeRecords {get; set;}
    public HL_TimeRecordRollupDayHandler(List<Time_Record__c> timeRecords) {
        this.TimeRecords = timeRecords;
    }

    //Rolls up the time records by day and activity type for a project and user for the Litigation group
    public List<Time_Record_Rollup_Day__c> RollupRecords(){
        List<Time_Record_Rollup_Day__c> rollupInsertList = new List<Time_Record_Rollup_Day__c>();
        List<Time_Record_Rollup_Day__c> rollupUpdateList = new List<Time_Record_Rollup_Day__c>();
        List<Time_Record_Rollup_Day__c> rollupDeleteList = new List<Time_Record_Rollup_Day__c>();

        Map<String, Map<String, AggregateResult>> aggregateMap = new Map<String, Map<String, AggregateResult>>();
        Map<String, Time_Record_Rollup_Day__c> existingRecordMap = new Map<String, Time_Record_Rollup_Day__c>();
        Set<Id> smSet = new Set<Id>();
        Set<String> trKeySet = new Set<String>();
        Set<String> relatedObjectIdSet = new Set<String>();
        Set<Date> activityDateSet = new Set<Date>();
        for(Time_Record__c tr : TimeRecords){
            trKeySet.add(tr.Day_Rollup_Key__c); 
            activityDateSet.add(tr.Activity_Date__c);
            if(tr.Opportunity__c != null)
                relatedObjectIdSet.add(tr.Opportunity__c);
            else if(tr.Engagement__c != null)
                relatedObjectIdSet.add(tr.Engagement__c);
            else
                relatedObjectIdSet.add(tr.Special_Project__c);
            smSet.add(tr.Time_Record_Period_Staff_Member__c);
        }

        //Aggregate the Records
        List<AggregateResult> timeRecordAggregateList = HL_TimeRecord.GetAggregatedTimeRecordsByDate(activityDateSet, relatedObjectIdSet, smSet);

        for(AggregateResult ar : timeRecordAggregateList){
            String key = (String)ar.get('key');
            trKeySet.add(key); //added this line on 12/15/2020 to fix duplicate record creation issue
            String activity = (String)ar.get('activity');
            if(aggregateMap.get(key) == null)
                aggregateMap.put(key, new Map<String, AggregateResult>{activity=>ar});
            else{
                Map<String, AggregateResult> mapVal = aggregateMap.get(key);
                mapVal.put(activity, ar);
            }
        }

        //Retrieve any existing rollup records
        for(Time_Record_Rollup_Day__c trd : HL_TimeRecordRollupDay.GetByKeys(trKeySet)){
            existingRecordMap.put(trd.Key__c, trd);
        }
        for(String id : aggregateMap.keySet())
        {
            Time_Record_Rollup_Day__c r = GetRollupRecord(aggregateMap.get(id));
            Time_Record_Rollup_Day__c er = existingRecordMap.get(id);
            if(er == null){
                rollupInsertList.Add(r);
            }
            else if (r.Hours_Worked__c == 0) {
                rollupDeleteList.add(er);
            }
            else {
                er.Activity_Type__c = r.Activity_Type__c;
                er.Hourly_Rate__c = r.Hourly_Rate__c;
                er.Hours_Worked__c = r.Hours_Worked__c;
                er.CurrencyIsoCode = r.CurrencyIsoCode;
                er.SummaryBillableHours__c = r.SummaryBillableHours__c;
                er.SummaryNonBillableHours__c = r.SummaryNonBillableHours__c;
                rollupUpdateList.add(er);
            }
        }

        for(String trKey : trKeySet){
            if(!aggregateMap.keySet().contains(trKey)){
                Time_Record_Rollup_Day__c er = existingRecordMap.get(trKey);
                if(er != null){
                    er.Hours_Worked__c = 0.0;
                    rollupDeleteList.add(er);
                }
            }
        }
        if(rollupInsertList.size() > 0)
            insert rollupInsertList;
        if(rollupUpdateList.size() > 0)
            update rollupUpdateList;
        if(rollupDeleteList.size() > 0)
            delete rollupDeleteList;

        if(rollupInsertList.size() > 0 || rollupUpdateList.size() > 0){
            //Merge the two lists to one so that rollupInsertList now contains both
            rollupInsertList.addAll(rollupUpdateList);
            this.ConvertCurrencies(rollupInsertList);
            HL_TimeRecordTimeRecordRollupDayHandler junctionHandler = new HL_TimeRecordTimeRecordRollupDayHandler(rollupInsertList);
            junctionHandler.InsertJunctionRecords(smSet, relatedObjectIdSet, activityDateSet);
        }

        return rollupInsertList;
    }

    //Creates a mock rollup day record from the aggregate results
    private Time_Record_Rollup_Day__c GetRollupRecord(Map<String, AggregateResult> activityMap){
        AggregateResult current;
        AggregateResult max = activityMap.values()[0];
        Decimal totalHours = (Decimal)max.get('sum');
        Decimal billableHours = 0;
        Decimal nonBillableHours = 0;
        if((Boolean)max.get('Is_Billable__c')){
            billableHours = (Decimal)max.get('sum');
        }else{
            nonBillableHours = (Decimal)max.get('sum');
        }
        for(integer i=1; i<activityMap.keySet().size(); i++){
            current = activityMap.values()[i];
            if((Decimal)max.get('sum') < (Decimal)current.get('sum'))
                max = current;
            totalHours += (Decimal)current.get('sum');
            if((Boolean)current.get('Is_Billable__c')){
            billableHours += (Decimal)current.get('sum');
        }else{
            nonBillableHours += (Decimal)current.get('sum');
        }
        }

        return new Time_Record_Rollup_Day__c(Activity_Date__c = (Date)max.get('Activity_Date__c'),
                                             Activity_Type__c = (String)max.get('activity'),
                                             CurrencyIsoCode = (String)max.get('CurrencyIsoCode'),
                                             Engagement__c = (String)max.get('Engagement__c'),
                                             Hourly_Rate__c = (Decimal)max.get('rate'),
                                             Opportunity__c = (String)max.get('Opportunity__c'),
                                             Special_Project__c = (String)max.get('Special_Project__c'),
                                             Time_Record_Period_Staff_Member__c = (String)max.get('Time_Record_Period_Staff_Member__c'),
                                             Hours_Worked__c = totalHours,
                                             SummaryBillableHours__c = billableHours,
                                             SummaryNonBillableHours__c = nonBillableHours
                                            );
    }

    //Converts the hourly rate to the propery currency rate since SF will default to the org US currency
    private List<Time_Record_Rollup_Day__c> ConvertCurrencies(List<Time_Record_Rollup_Day__c> records){
        List<Time_Record_Rollup_Day__c> updatedCalculationList = new List<Time_Record_Rollup_Day__c>();
        Map<String, Decimal> conversionMap = HL_Utility.GetConversionMap();
        for(Time_Record_Rollup_Day__c tr : [SELECT CurrencyIsoCode, Hourly_Rate__c FROM Time_Record_Rollup_Day__c WHERE Id IN:records AND CurrencyIsoCode <> 'USD']){
                tr.Hourly_Rate__c = (tr.Hourly_Rate__c * conversionMap.get(tr.CurrencyIsoCode)).setScale(0,RoundingMode.HALF_UP);
                updatedCalculationList.add(tr);
        }
        update updatedCalculationList;
        return updatedCalculationList;
    }
}