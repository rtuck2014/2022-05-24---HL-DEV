@isTest
private class Test_HL_TimeRecordRollupWeekController {
    @isTest
    private static void TestDataRetrievalMethods(){
        SL_TestSetupUtils.CreateTimeRecordRollupWeeksWithRelated(1, 'FR');
        String startDate = String.valueOf(Date.Today().Year()) + '-01-01';
        String endDate = String.valueOf(Date.Today().Year()) + '-12-31';

        Test.startTest();

        string category = HL_TimeRecordRollupWeekController.GetCategory();
        Boolean isSupervisor = HL_TimeRecordRollupWeekController.IsSupervisor('FR');
        Time_Record_Period__c trp = HL_TimeRecordRollupWeekController.GetCurrentPeriod('FR');
        Time_Record_Period_Staff_Member__c trpsm = HL_TimeRecordRollupWeekController.GetCurrentTimeRecordPeriodStaffMemberRecord('FR');
        List<Time_Record_Rollup_Week__c> trrwList = HL_TimeRecordRollupWeekController.GetTimeRecordWeekRollups(trpsm.Id);
        List<Time_Record_Period_Staff_Member__c> trpsmList = HL_TimeRecordRollupWeekController.GetTimeRecordPeriodStaffMemberByPeriodAndUser(trp.Id, UserInfo.GetUserId());

        Test.stopTest();

        //Validate the Time Record Period was returned
        System.assert(trp != null);
        //Validate the Time Record Period Staff Member was returned
        System.assert(trpsm != null);
        //Validate the Rollup Week record was returned
        System.assert(trrwList.size() > 0);
        //Validate the Time Record Period Staff Member record was returned
        System.assert(trpsmList.size() > 0);
    }

    @isTest
    private static void TestDealListMethods(){
        List<Special_Project__c> spInsertList = SL_TestSetupUtils.CreateSpecialProject('',10);
        String category = HL_TimeRecordRollupWeekController.GetCategory();
        if(String.isBlank(category))
            category = 'FR';
        Id spRecordTypeId = Schema.sObjectType.Special_Project__c.getRecordTypeInfosByName().get(category).getRecordTypeId();
        for(Special_Project__c sp : spInsertList)
            sp.RecordTypeId = spRecordTypeId;
        insert spInsertList;

        Test.startTest();

        List<Opportunity__c> oppList =  HL_TimeRecordRollupWeekController.GetOpportunities(category, UserInfo.getUserId());
        List<Special_Project__c> spList =  HL_TimeRecordRollupWeekController.GetSpecialProjects();
        List<Engagement__c> engList = HL_TimeRecordRollupWeekController.GetEngagements(category, UserInfo.getUserId());

        Test.stopTest();

        //Validate the Special Projects were Returned
        System.assertEquals(spInsertList.size(), spList.size());
    }

     @isTest
     private static void TestInsertMethods(){
        List<Time_Record_Rollup_Week__c> trList = SL_TestSetupUtils.CreateTimeRecordRollupWeeksWithRelated(1, 'FR');
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('', 1)[0];
         o.Beneficial_Owner_Control_Person_form__c = 'No';
        insert o;
        Time_Record_Rollup_Week__c trToInsert = new Time_Record_Rollup_Week__c(Time_Record_Period_Staff_Member__c = trList[0].Time_Record_Period_Staff_Member__c, Hours_Worked_Weekday__c=10,Opportunity__c = o.Id);

        Test.startTest();

        Time_Record_Rollup_Week__c result = HL_TimeRecordRollupWeekController.InsertRollupWeekRecord(trToInsert);

        Test.stopTest();

        //Validate the Time Record was created
        System.assert(!String.isBlank(result.Id));
    }

    @isTest private static void TestUpdateMethods(){
        Time_Record_Rollup_Week__c tr = SL_TestSetupUtils.CreateTimeRecordRollupWeeksWithRelated(1, 'FR')[0];

        Test.startTest();

        Time_Record_Rollup_Week__c trUpdatedHoursWorkedWeekday = HL_TimeRecordRollupWeekController.UpdateHoursWorkedWeekday(tr.Id, 10);
        Time_Record_Rollup_Week__c trUpdatedHoursWorkedWeekend = HL_TimeRecordRollupWeekController.UpdateHoursWorkedWeekend(tr.Id, 10);
        Time_Record_Rollup_Week__c trUpdatedComments = HL_TimeRecordRollupWeekController.UpdateComments(tr.Id, 'New Comments');

        Test.stopTest();

        //Validate the Updates
        Time_Record_Rollup_Week__c trUpdated = [SELECT Comments__c, Hours_Worked_Weekday__c, Hours_Worked_Weekend__c FROM Time_Record_Rollup_Week__c WHERE Id =: tr.Id];
        System.assertEquals(trUpdatedHoursWorkedWeekday.Hours_Worked_Weekday__c, trUpdated.Hours_Worked_Weekday__c);
        System.assertEquals(trUpdatedHoursWorkedWeekend.Hours_Worked_Weekend__c, trUpdated.Hours_Worked_Weekend__c);
        System.assertEquals(trUpdatedComments.Comments__c, trUpdated.Comments__c);
    }

    @isTest private static void TestDeleteMethods(){
        List<Time_Record_Rollup_Week__c> trList = SL_TestSetupUtils.CreateTimeRecordRollupWeeksWithRelated(1, 'FR');

        Test.startTest();

        Time_Record_Rollup_Week__c result = HL_TimeRecordRollupWeekController.DeleteRecord(trList[0].Id);

        Test.stopTest();

        //Validate the Time Record was deleted
        System.assert(!String.isBlank(result.Id));
    }
}