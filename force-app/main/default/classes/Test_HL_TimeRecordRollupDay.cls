@isTest
private class Test_HL_TimeRecordRollupDay {
    @isTest private static void TestRetrievalMethods(){
        final integer TEST_RECORDS_CREATED = 10;
        List<Time_Record__c> trList = SL_TestSetupUtils.CreateTimeRecordsWithRelated(TEST_RECORDS_CREATED, 'FR');
        Date startDate = Date.today();
        Date endDate = Date.today().addYears(1);
        List<Id> engagementIdList = new List<Id>();
        for(Time_Record__c tr : trList){
            engagementIdList.add(tr.Engagement__c);
        }
        
        Test.startTest();
        	HL_TimeRecordRollupDay trrd = new HL_TimeRecordRollupDay();
        	List<Time_Record_Rollup_Day__c> trrdGetByUserResult = HL_TimeRecordRollupDay.GetByUser(UserInfo.getUserId(), startDate, endDate);
        	List<Time_Record_Rollup_Day__c> trrdGetByKeysResult = HL_TimeRecordRollupDay.GetByKeys(new Set<String>{trList[0].Day_Rollup_Key__c});
        	List<AggregateResult> trrdGetGroupedByDayAndProject = HL_TimeRecordRollupDay.GetGroupedByDayAndProject(UserInfo.getUserId(), startDate, endDate);
			List<AggregateResult> trrdGetGroupedByEngagement = HL_TimeRecordRollupDay.GetGroupedByEngagement('FR', startDate, endDate);
        	List<AggregateResult> trrdGetGroupedByEngagement1 = HL_TimeRecordRollupDay.GetGroupedByEngagement('FR', startDate, endDate,engagementIdList);
        	List<AggregateResult> trrdGetGroupedByDay = HL_TimeRecordRollupDay.GetGroupedByDay(UserInfo.getUserId(), startDate, endDate);
        	List<Time_Record_Rollup_Day__c> trrdGetEngagementsLoggedForUser = HL_TimeRecordRollupDay.GetEngagementsLoggedForUser(UserInfo.getUserId(), startDate, endDate);

        Test.stopTest();
        
        //Validate the user results were retured
        System.assertEquals(1,trrdGetByUserResult.size());
    }
}