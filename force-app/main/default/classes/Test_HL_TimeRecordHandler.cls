@isTest private class Test_HL_TimeRecordHandler {
    @isTest
    private static void TestAfterInsertRecordCreation() {
        final integer RECORDS_TO_INSERT = 10;
        
        Test.startTest();
        
        List<Time_Record__c> timeRecordList = SL_TestSetupUtils.CreateTimeRecordsWithRelated(RECORDS_TO_INSERT, 'Litigation');
        
        Test.stopTest();
        
        //Validate the time records were created
        System.assert([SELECT Id FROM Time_Record__c].size() == RECORDS_TO_INSERT);
        //Validate the the Time Record Rollup Day records were created
        System.assert([SELECT Id FROM Time_Record_Rollup_Day__c].size() > 0);
    }
    
    @isTest
    private static void TestAfterRecordUpdate() {
        final integer RECORDS_TO_INSERT = 10;
        final integer HOURS_WORKED = 2;
        
        List<Time_Record__c> timeRecordList = SL_TestSetupUtils.CreateTimeRecordsWithRelated(RECORDS_TO_INSERT, 'Litigation');
        timeRecordList[0].Timer_Status__c='Start';
        update timeRecordList[0];
        for (Time_Record__c tr : timeRecordList){
            tr.Hours_Worked__c = HOURS_WORKED;
            tr.Timer_Status__c='Pause';
        }
        Test.startTest();
        
        update timeRecordList;
        
        Test.stopTest();
        
        //Validate the rollup record was adjusted
        AggregateResult ar = [SELECT SUM(Hours_Worked__c) hours FROM Time_Record_Rollup_Day__c];
        //System.assertEquals(RECORDS_TO_INSERT * HOURS_WORKED, ar.get('hours'));
    }
    
    @isTest
    private static void TestAfterProjectUpdate() {
        final integer RECORDS_TO_INSERT = 10;
        List<Time_Record__c> timeRecordList = SL_TestSetupUtils.CreateTimeRecordsWithRelated(RECORDS_TO_INSERT, 'Litigation');
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('', 1)[0];
        opp.Beneficial_Owner_Control_Person_form__c = 'No';
        insert opp;
        
        for (Time_Record__c tr : timeRecordList) {
            tr.Activity_Date__c = Date.today();
            tr.Opportunity__c = opp.Id;
            tr.Hours_Worked__c = 1;
        }
        
        Test.startTest();
        
        update timeRecordList;
        
        Test.stopTest();
        
        //Validate there is only one rollup record
        System.assertEquals(1, [SELECT Id FROM Time_Record_Rollup_Day__c].size());
    }
    
    @isTest
    private static void TestAfterRecordDelete() {
        final integer RECORDS_TO_INSERT = 10;
        final integer HOURS_WORKED = 2;
        
        List<Time_Record__c> timeRecordList = SL_TestSetupUtils.CreateTimeRecordsWithRelated(RECORDS_TO_INSERT, 'Litigation');
        for (Time_Record__c tr : timeRecordList) 
            tr.Hours_Worked__c = HOURS_WORKED;
        update timeRecordList;
        
        Test.startTest();
        
        delete timeRecordList;
        
        Test.stopTest();
        
        //Validate the rollup record was adjusted
        AggregateResult ar = [SELECT SUM(Hours_Worked__c) hours FROM Time_Record_Rollup_Day__c];
        System.assertEquals(NULL, ar.get('hours'));
    }
    
    @isTest
    public static void testTimeRecordUpdate(){
        Integer recordCount = 2;
        List<Time_Record__c> timeRecordList = SL_TestSetupUtils.CreateTimeRecordsWithRelated(recordCount, 'Beta');
        Integer  count = 1;
        for(Time_Record__c tr : timeRecordList){
            if(count == 1){
                tr.Activity_Type__c = 'FieldWork';
                tr.Hourly_Rate__c = 100;
                tr.Hours_Worked__c = 5;
            }else{
                tr.Activity_Type__c = 'Marketing';  
                tr.Hourly_Rate__c = 100;
                tr.Hours_Worked__c = 5;
            }
            count++;
        }
        update timeRecordList;
    }
    
    @isTest
    public static void testTimeRecord(){
        Date startDate = Date.today();
        Date endDate = Date.today().addYears(1);
        Id userId = UserInfo.getUserId();
        Id recordTypeId = Schema.SObjectType.Time_Record__c.getRecordTypeInfosByName().get('Beta').getRecordTypeId();
        Set<Date> activityDateSet = new Set<Date>();
        activityDateSet.add(startDate);
        Set<String> relatedObjectIdSet = new Set<String>();
        relatedObjectIdSet.add('Opportunity__c');
        relatedObjectIdSet.add('Engagement__c');
        List<Time_Record__c> timeRecordList = SL_TestSetupUtils.CreateTimeRecordsWithRelated(2, 'Beta');
        List<Time_Record__c> listToUpdate = new List<Time_Record__c>();
        List<Opportunity__c> oppList = SL_TestSetupUtils.CreateOpp('Test',1);
        Set<Id> engagementIdSet = new Set<Id>();
        for(Time_Record__c tr : timeRecordList){
            engagementIdSet.add(tr.Engagement__c);
            tr.Opportunity__c = oppList[0].Id;
            listToUpdate.add(tr);
        }
        update listToUpdate;
        Set<Id> smIdSet = new Set<Id>();
        for(Time_Record__c tr : timeRecordList){
            smIdSet.add(tr.Time_Record_Period_Staff_Member__c);
        }
        Test.startTest();
        HL_TimeRecord.GetByUser(userId, startDate, endDate);
        HL_TimeRecord.GetByEngagements(recordTypeId, engagementIdSet);
        HL_TimeRecord.GetByEngagementsOpportunities(recordTypeId, engagementIdSet);
        HL_TimeRecord.GetAggregatedTimeRecordsByDate(activityDateSet, relatedObjectIdSet, smIdSet);
        Test.stopTest();
        
    }
    
}