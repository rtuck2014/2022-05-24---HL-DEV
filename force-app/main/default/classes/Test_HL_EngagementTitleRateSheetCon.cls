@isTest
private class Test_HL_EngagementTitleRateSheetCon {
    @testSetup
    static void SetupRateSheetData(){
        Time_Record_Period__c periodRecord = (Time_Record_Period__c)HL_TestFactory.CreateSObject('Time_Record_Period__c',false);
        Time_Record_Period_Staff_Member__c periodStaffMemberRecord = (Time_Record_Period_Staff_Member__c)HL_TestFactory.CreateSObject('Time_Record_Period_Staff_Member__c',false);
        List<Time_Record__c> timeRecordList = (List<Time_Record__c>)HL_TestFactory.CreateSObjectList('Time_Record__c',false, 10);
        Contact contactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        Engagement__c engagementRecord = HL_TestFactory.CreateEngagement(false);
        List<Staff_Role__c> staffRoleList = new List<Staff_Role__c> {new Staff_Role__c(Name = 'Initiator', Display_Order__c = 1, Opportunity__c = True, CF__c = True), new Staff_Role__c(Name = 'Analyst', Display_Order__c = 2, Opportunity__c = True, CF__c = True), new Staff_Role__c(Name = 'Associate', Display_Order__c = 3, Opportunity__c = True, CF__c = True)};
		
        Engagement_Internal_Team__c internalTeamRecord = (Engagement_Internal_Team__c)HL_TestFactory.CreateSObject('Engagement_Internal_Team__c',false);
        List<Title_Rate_Sheet__c> titleRateSheetList = (List<Title_Rate_Sheet__c>)HL_TestFactory.CreateSObjectList('Title_Rate_Sheet__c',false, 2);
		
        for(Title_Rate_Sheet__c rateSheetRecord : titleRateSheetList){
            rateSheetRecord.Active__c = true;
            rateSheetRecord.Financial_Analyst_Rate__c = 100.00;
            rateSheetRecord.Associate_Rate__c = 200.00;
            rateSheetRecord.Vice_President_Rate__c = 300.00;
            rateSheetRecord.Senior_Vice_President_Rate__c = 400.00;
            rateSheetRecord.Director_Rate__c = 500.00;
            rateSheetRecord.Managing_Director_Rate__c = 600.00;
            rateSheetRecord.Senior_Managing_Director_Rate__c = 700.00;
        }
        
        //Set Rates to Double on the Second Title Rate Sheet
        titleRateSheetList[1].Financial_Analyst_Rate__c = titleRateSheetList[1].Financial_Analyst_Rate__c * 2.0;
        titleRateSheetList[1].Associate_Rate__c = titleRateSheetList[1].Associate_Rate__c * 2.0;
        titleRateSheetList[1].Vice_President_Rate__c = titleRateSheetList[1].Vice_President_Rate__c * 2.0;
        titleRateSheetList[1].Senior_Vice_President_Rate__c = titleRateSheetList[1].Senior_Vice_President_Rate__c * 2.0;
        titleRateSheetList[1].Director_Rate__c = titleRateSheetList[1].Director_Rate__c * 2.0;
        titleRateSheetList[1].Managing_Director_Rate__c = titleRateSheetList[1].Managing_Director_Rate__c * 2.0;
        titleRateSheetList[1].Senior_Managing_Director_Rate__c = titleRateSheetList[1].Senior_Managing_Director_Rate__c * 2.0;

        insert titleRateSheetList;
        insert engagementRecord;
        insert staffRoleList;

        periodRecord.Start_Date__c = Date.today();
        periodRecord.End_Date__c = Date.today().addDays(7);
        periodRecord.Period_Category__c = 'Litigation';
        periodStaffMemberRecord.Title__c = 'Financial Analyst';
        periodStaffMemberRecord.Office__c = 'LA';
        contactRecord.Office__c = 'LA';
        contactRecord.Title = 'Financial Analyst';
        contactRecord.User__c = UserInfo.getUserId();
        insert periodRecord ;
        insert contactRecord;

        internalTeamRecord.Engagement__c = engagementRecord.Id;
        internalTeamRecord.Contact__c = contactRecord.Id;
        internalTeamRecord.Staff_Role__c = staffRoleList[0].Id;
        insert internalTeamRecord;

        periodStaffMemberRecord.Contact__c = contactRecord.Id;
        periodStaffMemberRecord.Contact__r = contactRecord;
        periodStaffMemberRecord.Time_Record_Period__c = periodRecord.Id;
        periodStaffMemberRecord.Time_Record_Period__r = periodRecord;
        periodStaffMemberRecord.User__c = UserInfo.getuserId();

        insert periodStaffMemberRecord;
        for(Time_Record__c timeRecord : timeRecordList){
            timeRecord.Activity_Type__c = 'Consult';
            timeRecord.Time_Record_Period_Staff_Member__c = periodStaffMemberRecord.Id;
            timeRecord.Time_Record_Period_Staff_Member__r = periodStaffMemberRecord;
            timeRecord.Hourly_Rate__c = 0;
            timeRecord.Hours_Worked__c = 0.0;
            timeRecord.Seconds_Worked_Actual__c = 0;
            timeRecord.Engagement__c = engagementRecord.Id;
        }
        insert timeRecordList;
    }

    @isTest
    private static void TestInsertRecord(){
        Engagement__c engagementRecord = [SELECT Id FROM Engagement__c];
        Title_Rate_Sheet__c titleRateSheetRecord = [SELECT Id FROM Title_Rate_Sheet__c LIMIT 1];
        Engagement_Title_Rate_Sheet__c engagementTitleRateSheetRecord = (Engagement_Title_Rate_Sheet__c)HL_TestFactory.CreateSObject('Engagement_Title_Rate_Sheet__c',false);

        engagementTitleRateSheetRecord.Engagement__c = engagementRecord.Id;
        engagementTitleRateSheetRecord.Title_Rate_Sheet__c = titleRateSheetRecord.Id;
        engagementTitleRateSheetRecord.Start_Date__c = Date.today();

        Test.startTest();

        HL_EngagementTitleRateSheetController.InsertRecord(engagementTitleRateSheetRecord);

        Test.stopTest();

        //Validate the Record was Inserted
        System.assert(!String.isBlank(engagementTitleRateSheetRecord.Id));
    }

    @isTest
    private static void TestUpdateRecord(){
        Engagement__c engagementRecord = [SELECT Id FROM Engagement__c];
        Title_Rate_Sheet__c titleRateSheetRecord = [SELECT Id FROM Title_Rate_Sheet__c LIMIT 1];
        Engagement_Title_Rate_Sheet__c engagementTitleRateSheetRecord = (Engagement_Title_Rate_Sheet__c)HL_TestFactory.CreateSObject('Engagement_Title_Rate_Sheet__c',false);

        engagementTitleRateSheetRecord.Engagement__c = engagementRecord.Id;
        engagementTitleRateSheetRecord.Title_Rate_Sheet__c = titleRateSheetRecord.Id;
        engagementTitleRateSheetRecord.Start_Date__c = Date.today();
        insert engagementTitleRateSheetRecord;

        Engagement_Title_Rate_Sheet__c engagementTitleRateSheetUpdate = [SELECT Start_Date__c FROM Engagement_Title_Rate_Sheet__c LIMIT 1];
        engagementTitleRateSheetUpdate.Start_Date__c = Date.today().addDays(1);

        Test.startTest();

        HL_EngagementTitleRateSheetController.UpdateRecord(engagementTitleRateSheetUpdate);

        Test.stopTest();

        Engagement_Title_Rate_Sheet__c engagementTitleRateSheetUpdated = [SELECT Start_Date__c FROM Engagement_Title_Rate_Sheet__c LIMIT 1];

        System.assertEquals(Date.today().addDays(1), engagementTitleRateSheetUpdated.Start_Date__c);
    }

    @isTest
    private static void TestDeleteRecord(){
        Engagement__c engagementRecord = [SELECT Id FROM Engagement__c];
        Title_Rate_Sheet__c titleRateSheetRecord = [SELECT Id FROM Title_Rate_Sheet__c LIMIT 1];
        Engagement_Title_Rate_Sheet__c engagementTitleRateSheetRecord = (Engagement_Title_Rate_Sheet__c)HL_TestFactory.CreateSObject('Engagement_Title_Rate_Sheet__c',false);

        engagementTitleRateSheetRecord.Engagement__c = engagementRecord.Id;
        engagementTitleRateSheetRecord.Title_Rate_Sheet__c = titleRateSheetRecord.Id;
        engagementTitleRateSheetRecord.Start_Date__c = Date.today();

        insert engagementTitleRateSheetRecord;

        Test.startTest();

        HL_EngagementTitleRateSheetController.DeleteRecord(engagementTitleRateSheetRecord.Id);

        Test.stopTest();

        //Validate the Record was Inserted
        System.assertEquals(0, ([SELECT Id FROM Engagement_Title_Rate_Sheet__c]).size());
    }

    @isTest
    private static void TestRetrievalOfEngagementTitleRateSheets(){
        Integer engagementRateSheetCount = 10;
        Engagement__c engagementRecord = [SELECT Id FROM Engagement__c];
        Title_Rate_Sheet__c titleRateSheet = [SELECT Id FROM Title_Rate_Sheet__c LIMIT 1];
        List<Engagement_Title_Rate_Sheet__c> engagementTitleRateSheetList = (List<Engagement_Title_Rate_Sheet__c>)HL_TestFactory.CreateSObjectList('Engagement_Title_Rate_Sheet__c',false, engagementRateSheetCount);

        for(Integer i = 0; i < engagementRateSheetCount; i++){
            engagementTitleRateSheetList[i].Engagement__c = engagementRecord.Id;
            engagementTitleRateSheetList[i].Title_Rate_Sheet__c = titleRateSheet.Id;
            engagementTitleRateSheetList[i].Start_Date__c = Date.today().addDays(i);
            engagementTitleRateSheetList[i].End_Date__c = Date.today().addDays(i);
        }

        insert engagementTitleRateSheetList;

        Test.startTest();

        List<Engagement_Title_Rate_Sheet__c> engagementTitleRateSheetResultList = HL_EngagementTitleRateSheetController.GetEngagementTitleRateSheets(engagementRecord.Id);

        Test.stopTest();

        //Validate the Engagement Title Rate Sheets were Returned
        System.assertEquals(engagementRateSheetCount, engagementTitleRateSheetResultList.size());
    }

    @isTest
    private static void TestRetrievalOfRateSheets(){
        Test.startTest();

        List<Title_Rate_Sheet__c> titleRateSheetList = HL_EngagementTitleRateSheetController.GetTitleRateSheets();

        Test.stopTest();

        //Validate the Rate Sheets were Returned
        System.assertEquals(2, titleRateSheetList.size());
    }

    @isTest
    private static void TestRetrievalOfEngagements(){
        Test.startTest();

        List<Engagement__c> engagementList = HL_EngagementTitleRateSheetController.GetEngagements('Litigation');

        Test.stopTest();

        //Validate a null list is not returned
        System.assert(engagementList != null);
    }
}