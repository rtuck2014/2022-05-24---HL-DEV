@isTest
private class Test_HL_TimeRecordController {
    @isTest
    private static void TestGeneralStaticMethodsFR() {
        SL_TestSetupUtils.CreateTimeRecordRollupWeeksWithRelated(1, 'FR');
        String startDate = String.valueOf(Date.Today().Year()) + '-01-01';
        String endDate = String.valueOf(Date.Today().Year()) + '-12-31';

        Test.startTest();

        string category = HL_TimeRecordController.GetCategory();
        if (String.isBlank(category))
            category = 'FR';
        List<String> activityTypeRemoteResultList = HL_TimeRecordController.GetActivityTypesRemote();
        List<String> activityTypesList = HL_TimeRecordController.GetActivityTypes();
        List<String> currencyCodeList = HL_TimeRecordController.GetCurrencyCodes();
        Boolean isSupervisor = HL_TimeRecordController.IsSupervisor('FR');
        Id userId = HL_TimeRecordController.GetCurrentUserId();
        Time_Record_Period__c trp = HL_TimeRecordController.GetCurrentPeriod('FR');
        Time_Record_Period_Staff_Member__c trpsm = HL_TimeRecordController.GetCurrentTimeRecordPeriodStaffMemberRecord('FR');
        Time_Record_Period_Staff_Member__c trpsm1 = HL_TimeRecordController.GetTimeRecordPeriodStaffMemberRecord('FR',trp);
        List<Time_Record_Period__c> trpList = HL_TimeRecordController.GetPeriods('FR');
        Time_Record_Period__c trpById = HL_TimeRecordController.GetPeriod(trpList[0].Id);
        Id currentPeriodId = HL_TimeRecordController.GetCurrentPeriodRecordId('FR');

        Test.stopTest();

        //Validate the activity types were returned from the remote call
        System.assert(activityTypeRemoteResultList.size() > 0);
        //Validate the activity types were returned from the standard call
        System.assert(activityTypesList.size() > 0);
        //Validate the Time Record Period was Returned
        System.assert(trp != null);
        //Validate the Time Record Period Staff Member was Returned
        System.assert(trpsm != null);
        //Validate the Time Record Period was Returned
        System.assert(trpList.size() > 0);
        //Validate the Time Record Period by Id was Returned
        System.assert(trpById != null);
        //Validate the proper user Id was Returned
        System.assertEquals(UserInfo.getUserId(), userId);
        //Validate the current period Id was returned
        System.assert(!String.isBlank(currentPeriodId));
    }

    @isTest
    private static void TestGeneralStaticMethodsLitigation() {
        SL_TestSetupUtils.CreateTimeRecordsWithRelated(1, 'Litigation');
        String startDate = String.valueOf(Date.Today().Year()) + '-01-01';
        String endDate = String.valueOf(Date.Today().Year()) + '-12-31';

        Test.startTest();

        string category = HL_TimeRecordController.GetCategory();
        if (String.isBlank(category))
            category = 'Litigation';
        List<String> activityTypeRemoteResultList = HL_TimeRecordController.GetActivityTypesRemote();
        Time_Record_Period__c trp = HL_TimeRecordController.GetCurrentPeriod('Litigation');
        Time_Record_Period_Staff_Member__c trpsm = HL_TimeRecordController.GetCurrentTimeRecordPeriodStaffMemberRecord('Litigation');
         Time_Record_Period_Staff_Member__c trpsm1 = HL_TimeRecordController.GetTimeRecordPeriodStaffMemberRecord('Litigation',trp);
        List<Time_Record__c> trList = HL_TimeRecordController.GetTimeRecords(UserInfo.getUserId(), startDate, endDate);
        List<Time_Record__c> trListWithBlanks = HL_TimeRecordController.GetTimeRecords(null, '', '');
        List<Time_Record_Rollup_Day__c> trrdList = HL_TimeRecordController.GetTimeRecordDayRollups(UserInfo.getUserId(), startDate, endDate);
        List<Time_Record__c> trByUserList = HL_TimeRecordController.GetByUser(UserInfo.getUserId(), Date.Today(), Date.Today().addDays(7));
        Time_Record_Period__c trpGetPeriodRecordResult = HL_TimeRecordController.GetPeriodRecord('Litigation', Date.today());
		List<AggregateResult>Gagg = HL_TimeRecordController.GetRollupGroupedByEngagement('Litigation', string.valueOf(Date.Today()),string.valueOf(Date.Today().addDays(7)));
        List<AggregateResult> Gaggre= HL_TimeRecordController.GetRollupGroupedByDay(UserInfo.getUserId(), startDate, endDate);
        List<AggregateResult> Gaggrepro=HL_TimeRecordController.GetRollupGroupedByDayAndProject(UserInfo.getUserId(), startDate, endDate);
        List<Time_Record__c>timreclst= HL_TimeRecordController.GetPendingRecords(UserInfo.getUserId());
        Test.stopTest();

        //Validate the activity types were returned from the remote call
        System.assert(activityTypeRemoteResultList.size() > 0);
        //Validate the Time Record Period was Returned
        System.assert(trp != null);
        //Validate the Time Record Period Staff Member was Returned
        System.assert(trpsm != null);
        //Validate the user's time records are returned
        System.assert(trByUserList.size() > 0);
        //Validate the Period Record Result matches with the Current Period
        System.assertEquals(trp.Id, trpGetPeriodRecordResult.Id);
    }

    @isTest
    private static void TestDealListMethods() {
        List<Special_Project__c> spInsertList = SL_TestSetupUtils.CreateSpecialProject('', 10);
        string category = HL_TimeRecordController.GetCategory();
         String startDate = String.valueOf(Date.Today().Year()) + '-01-01';
        String endDate = String.valueOf(Date.Today().Year()) + '-12-31';

        if (String.isBlank(category))
            category = 'FR';
        Id spRecordTypeId = Schema.sObjectType.Special_Project__c.getRecordTypeInfosByName().get(category).getRecordTypeId();
        for (Special_Project__c sp : spInsertList)
            sp.RecordTypeId = spRecordTypeId;

        insert spInsertList;

        Test.startTest();

        List<Opportunity__c> oppList =  HL_TimeRecordController.GetOpportunities(category, UserInfo.getUserId());
        List<Special_Project__c> spList =  HL_TimeRecordController.GetSpecialProjects();
        List<Engagement__c> engList = HL_TimeRecordController.GetEngagements(category, UserInfo.getUserId());
         List<Engagement__c>englst = HL_TimeRecordController.GetEngagementsAtPointInTime(UserInfo.getUserId(),startDate,endDate);
       
        Test.stopTest();

        //Validate the Special Projects were Returned
        System.assertEquals(spInsertList.size(), spList.size());
    }

    @isTest
    private static void TestInsertMethods() {
        List<Time_Record__c> trList = SL_TestSetupUtils.CreateTimeRecordsWithRelated(1, 'Litigation');
        String startDate = String.valueOf(Date.Today().Year()) + '-01-01';
        Time_Record__c trToInsert = trList[0].clone();
        string category = HL_TimeRecordController.GetCategory();

        if (String.isBlank(category))
            category = 'Litigation';

        trToInsert.Hours_Worked__c = 1;
        
        Test.startTest();

        Time_Record__c result = HL_TimeRecordController.InsertRecord(trToInsert, startDate, UserInfo.getUserId(), category, 24);
		 Time_Record__c tr= HL_TimeRecordController.UpdateRecord(result);
         Time_Record__c tr1= HL_TimeRecordController.UpdateRecordStatus(result);
       Time_Record__c tr2= HL_TimeRecordController.fetchTime(result);
        List<Time_Record__c>trls =HL_TimeRecordController.UpdateRecords(trList,24);
        
        Test.stopTest();

        //Validate the Time Record was created
        System.assert(!String.isBlank(result.Id));
    }

    @isTest
    private static void TestUpdateMethods() {
        Time_Record__c tr = SL_TestSetupUtils.CreateTimeRecordsWithRelated(1, 'Litigation')[0];

        Test.startTest();

        Time_Record__c trUpdatedHoursWorked = HL_TimeRecordController.UpdateHoursWorked(tr.Id, 10, 24);
        Time_Record__c trUpdatedActivityType = HL_TimeRecordController.UpdateActivityType(tr.Id, 'Litigation');
        Time_Record__c trUpdatedComments = HL_TimeRecordController.UpdateComments(tr.Id, 'New Comments');
        Time_Record__c trUpdatedCurrency = HL_TimeRecordController.UpdateCurrencyIsoCode(tr.Id, 'GBP');
        Time_Record__c trUpdatedHourlyRate = HL_TimeRecordController.UpdateHourlyRate(tr.Id, 100);

        Test.stopTest();

        //Validate the Updates
        Time_Record__c trUpdated = [SELECT Activity_Type__c, Comments__c, Hours_Worked__c, Hourly_Rate__c, CurrencyIsoCode FROM Time_Record__c WHERE Id = : tr.Id];
        System.assertEquals(trUpdatedHoursWorked.Hours_Worked__c, trUpdated.Hours_Worked__c);
        System.assertEquals(trUpdatedHourlyRate.Hourly_Rate__c, trUpdated.Hourly_Rate__c);
        System.assertEquals(trUpdatedActivityType.Activity_Type__c, trUpdated.Activity_Type__c);
        System.assertEquals(trUpdatedComments.Comments__c, trUpdated.Comments__c);
        System.assertEquals(trUpdatedCurrency.CurrencyIsoCode, trUpdated.CurrencyIsoCode);
    }

    @isTest
    private static void TestTimeRecording() {
        Time_Record_Period__c trp = SL_TestSetupUtils.CreateTimeRecordPeriod('', 1)[0];
        List<Special_Project__c> spInsertList = SL_TestSetupUtils.CreateSpecialProject('', 1);
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        c.Office__c = 'LA';
        c.Title = 'Financial Analyst';
        c.User__c = UserInfo.getUserId();
        trp.Start_Date__c = Date.today();
        trp.End_Date__c = Date.today().addDays(6);
        insert c;
        insert spInsertList;
        insert trp;
        
        Title_Rate_Sheet__c trs = new Title_Rate_Sheet__c();
        trs.Name = 'Title Rate sheet';
        trs.Senior_Managing_Director_Rate__c = 10;
        trs.Managing_Director_Rate__c  = 10;
        trs.Director_Rate__c  = 10;
        trs.Senior_Vice_President_Rate__c  = 10;
        trs.Vice_President_Rate__c  = 10;
        trs.Senior_Managing_Director_Rate__c = 10;
        trs.Vice_President_Rate__c  = 10;
        trs.InternFinancialAnalyst1__c  = 10;
        trs.Financial_Analyst_Rate__c  = 10;
        
        insert trs;

        Test.startTest();

        String result = HL_TimeRecordController.RecordTime(trp.Id, UserInfo.getUserId(), 'Consult', 'Special_Project__c', spInsertList[0].Id, 100, 100 * 60, 'In Progress');
		HL_TitleRateSheet.ExtractTitleRate(trs,c);
        HL_TitleRateSheet.ExtractTitleRate(trs,c.title);
        Test.stopTest();

        //Validate the Time Record was Recorded
        System.assert(!String.isBlank(result));
    }

    @isTest
    private static void TestRemoteTimeRecording() {
        Time_Record_Period__c trp = SL_TestSetupUtils.CreateTimeRecordPeriod('', 1)[0];
        List<Special_Project__c> spInsertList = SL_TestSetupUtils.CreateSpecialProject('', 1);
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        c.Office__c = 'LA';
        c.Title = 'Financial Analyst';
        c.User__c = UserInfo.getUserId();
        trp.Start_Date__c = Date.today();
        trp.End_Date__c = Date.today().addDays(6);
        insert c;
        insert spInsertList;
        insert trp;

        Test.startTest();

        String result = HL_TimeRecordController.RecordTimeRemote('{Time_Record_Period_Id=' + trp.Id +
                        ',UserId=' + UserInfo.getUserId() +
                        ',ActivityType=Consult,ObjectType=Special_Project__c,ObjectId=' + spInsertList[0].Id +
                        ',Minutes=100}');

        Test.stopTest();

        //Validate the Time Record was Recorded
        System.assert(!String.isBlank(result));
    }

    @isTest
    private static void TestConstructors() {
        Time_Record__c tr = SL_TestSetupUtils.CreateTimeRecordsWithRelated(1, 'Litigation')[0];
        ApexPages.StandardController sc = new ApexPages.standardController(tr);

        Test.startTest();

        HL_TimeRecordController conEmpty = new HL_TimeRecordController();
        HL_TimeRecordController con = new HL_TimeRecordController(sc);

        Test.stopTest();

        //Validate the classes were instantiated
        System.assert(conEmpty != null);
        System.assert(con != null);
    }
}