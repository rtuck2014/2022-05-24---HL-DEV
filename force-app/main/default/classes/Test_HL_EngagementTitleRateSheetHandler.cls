@isTest
private class Test_HL_EngagementTitleRateSheetHandler {
    @testSetup
    private static void SetupRateSheetData(){
        Time_Record_Period__c periodRecord = (Time_Record_Period__c)HL_TestFactory.CreateSObject('Time_Record_Period__c',false);
        Time_Record_Period_Staff_Member__c periodStaffMemberRecord = (Time_Record_Period_Staff_Member__c)HL_TestFactory.CreateSObject('Time_Record_Period_Staff_Member__c',false);
        List<Time_Record__c> timeRecordList = (List<Time_Record__c>)HL_TestFactory.CreateSObjectList('Time_Record__c',false, 10);
        Contact contactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee,false);
        Engagement__c engagementRecord = HL_TestFactory.CreateEngagement(false);
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
        
        //Set the Names to be sure order is Maintained
        titleRateSheetList[0].Name = 'Rate Sheet 01';
        titleRateSheetList[1].Name = 'Rate Sheet 02';
        
        insert titleRateSheetList;
        insert engagementRecord;
        
        periodRecord.Start_Date__c = Date.today();
        periodRecord.End_Date__c = Date.today().addDays(7);
        periodRecord.Period_Category__c = 'Litigation';
        periodStaffMemberRecord.Title__c = 'Financial Analyst';
        periodStaffMemberRecord.Office__c = 'LA';
        contactRecord.Office__c = 'LA';
        contactRecord.Title = 'Financial Analyst';
        contactRecord.User__c = UserInfo.getUserId();
        insert periodRecord;
        insert contactRecord;
        
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
    private static void TestRecordInsert(){
        Engagement__c engagementRecord = [SELECT Id FROM Engagement__c LIMIT 1];
        List<Title_Rate_Sheet__c> titleRateSheetList = HL_TitleRateSheet.GetActive();
        Engagement_Title_Rate_Sheet__c titleRateSheet = (Engagement_Title_Rate_Sheet__c)HL_TestFactory.CreateSObject('Engagement_Title_Rate_Sheet__c',false);
        
        Test.startTest();
        
        titleRateSheet.Engagement__c = engagementRecord.Id;
        titleRateSheet.Title_Rate_Sheet__c = titleRateSheetList[0].Id;
        titleRateSheet.Start_Date__c = Date.today();
        
        insert titleRateSheet;
        
        Test.stopTest();
        
        //Validate the Insert was Successful
        System.assert(!String.isBlank(titleRateSheet.Id));
        
        //Validate the Rate was Assigned
        for(Time_Record__c timeRecord : [SELECT Hourly_Rate__c FROM Time_Record__c WHERE Recording_Status__c = 'Complete'])
            System.assert(timeRecord.Hourly_Rate__c != 0.0);
    }
    
    @isTest
    private static void TestInsertOverlapFailure_SameStartDate(){
        Engagement__c engagementRecord = [SELECT Id FROM Engagement__c LIMIT 1];
        List<Title_Rate_Sheet__c> titleRateSheetList = HL_TitleRateSheet.GetActive();
        List<Engagement_Title_Rate_Sheet__c> engagementTitleRateSheetList = (List<Engagement_Title_Rate_Sheet__c>)HL_TestFactory.CreateSObjectList('Engagement_Title_Rate_Sheet__c', false,2);
        
        engagementTitleRateSheetList[0].Engagement__c = engagementRecord.Id;
        engagementTitleRateSheetList[1].Engagement__c = engagementRecord.Id;
        engagementTitleRateSheetList[0].Title_Rate_Sheet__c = titleRateSheetList[0].Id;
        engagementTitleRateSheetList[1].Title_Rate_Sheet__c = titleRateSheetList[0].Id;
        //Setting both with the same Start Date to verify failure
        engagementTitleRateSheetList[0].Start_Date__c = Date.today();
        engagementTitleRateSheetList[1].Start_Date__c = Date.today();
        
        insert engagementTitleRateSheetList[0];
        
        Test.startTest();
        
        Database.SaveResult result = Database.insert(engagementTitleRateSheetList[1], false);
        
        Test.stopTest();
        
        //Validate the Insert was Unsuccessful
        System.assertEquals(false, result.isSuccess());
    }
    
    @isTest
    private static void TestInsertOverlapFailure_DateOverlaps(){
        Engagement__c engagementRecord = [SELECT Id FROM Engagement__c LIMIT 1];
        List<Title_Rate_Sheet__c> titleRateSheetList = HL_TitleRateSheet.GetActive();
        List<Engagement_Title_Rate_Sheet__c> engagementTitleRateSheetList = (List<Engagement_Title_Rate_Sheet__c>)HL_TestFactory.CreateSObjectList('Engagement_Title_Rate_Sheet__c', false,2);
        
        engagementTitleRateSheetList[0].Engagement__c = engagementRecord.Id;
        engagementTitleRateSheetList[1].Engagement__c = engagementRecord.Id;
        engagementTitleRateSheetList[0].Title_Rate_Sheet__c = titleRateSheetList[0].Id;
        engagementTitleRateSheetList[1].Title_Rate_Sheet__c = titleRateSheetList[0].Id;
        //Setting date range overlap
        engagementTitleRateSheetList[0].Start_Date__c = Date.today();
        engagementTitleRateSheetList[0].End_Date__c = Date.today().addDays(100);
        engagementTitleRateSheetList[1].Start_Date__c = Date.today().addDays(75);
        
        insert engagementTitleRateSheetList[0];
        
        Test.startTest();
        
        Database.SaveResult result = Database.insert(engagementTitleRateSheetList[1], false);
        
        Test.stopTest();
        
        //Validate the Insert was Unsuccessful
        System.assertEquals(false, result.isSuccess());
    }
    
    @isTest
    private static void TestUpdate(){
        Engagement__c engagementRecord = [SELECT Id FROM Engagement__c LIMIT 1];
        List<Title_Rate_Sheet__c> titleRateSheetList = HL_TitleRateSheet.GetActive();
        List<Engagement_Title_Rate_Sheet__c> engagementTitleRateSheetList = (List<Engagement_Title_Rate_Sheet__c>)HL_TestFactory.CreateSObjectList('Engagement_Title_Rate_Sheet__c', false,2);
        Date today = Date.today();
        Date tomorrow = Date.today().addDays(1);
        Date yesterday = Date.today().addDays(-1);
        
        engagementTitleRateSheetList[0].Engagement__c = engagementRecord.Id;
        engagementTitleRateSheetList[1].Engagement__c = engagementRecord.Id;
        engagementTitleRateSheetList[0].Title_Rate_Sheet__c = titleRateSheetList[0].Id;
        engagementTitleRateSheetList[1].Title_Rate_Sheet__c = titleRateSheetList[1].Id;
        engagementTitleRateSheetList[0].Start_Date__c = today;
        engagementTitleRateSheetList[0].End_Date__c = today;
        engagementTitleRateSheetList[1].Start_Date__c = tomorrow;
        
        
        insert engagementTitleRateSheetList;
        
        //Store off the Time Records to Validate Later
        Map<Id, Time_Record__c> originalTimeRecordMap = new Map<Id, Time_Record__c>([SELECT Hourly_Rate__c FROM Time_Record__c]);
        
        //Update the Initial Rate Sheet
        Engagement_Title_Rate_Sheet__c engagementTitleRateSheetUpdateList = [SELECT Start_Date__c, End_Date__c, Engagement__c FROM Engagement_Title_Rate_Sheet__c WHERE Start_Date__c =: today LIMIT 1];
        engagementTitleRateSheetUpdateList.Start_Date__c = yesterday;
        engagementTitleRateSheetUpdateList.End_Date__c = yesterday;
        update engagementTitleRateSheetUpdateList;
        
        Engagement_Title_Rate_Sheet__c engagementTitleRateSheetNewUpdate = [SELECT Start_Date__c, End_Date__c, Engagement__c FROM Engagement_Title_Rate_Sheet__c WHERE Start_Date__c =: tomorrow LIMIT 1];
        engagementTitleRateSheetNewUpdate.Start_Date__c = today;
        
        Test.startTest();
        
        update engagementTitleRateSheetNewUpdate;
        
        Test.stopTest();
        
        //Validate the New Rate was Assigned - Should be Double the Original based on our Setup Data
        for(Time_Record__c timeRecord : [SELECT Hourly_Rate__c FROM Time_Record__c]){
            Decimal originalRate = originalTimeRecordMap.get(timeRecord.Id).Hourly_Rate__c;
            System.assertEquals(originalRate * 2.0, timeRecord.Hourly_Rate__c);
        }
    }
    
}