global with sharing class HL_TimeRecordController extends HL_TimeRecordControllerBase {
    public HL_TimeRecordController() {}
    public HL_TimeRecordController(ApexPages.StandardController con) {}

    @RemoteAction
    public static List<String> GetActivityTypesRemote() {
        Id recordTypeId = GetTimeRecordRecordType();
        return GetPicklistOptionsByRecordType('Time_Record__c', 'Activity_Type__c', recordTypeId);
    }

    @AuraEnabled
    webservice static Time_Record_Period__c GetCurrentPeriod(string category) {
        Time_Record_Period__c currentPeriod;

        if (HL_SecurityUtility.VerifyFieldAccess(new List<String> {'Id'}, Schema.sObjectType.Time_Record_Period__c.fields.getMap()))
            currentPeriod = HL_TimeRecordControllerBase.GetCurrentPeriod(category);

        return HL_TimeRecordControllerBase.GetCurrentPeriod(category);
    }

    @AuraEnabled
    public static Time_Record_Period_Staff_Member__c GetCurrentTimeRecordPeriodStaffMemberRecord(string category) {
        Time_Record_Period_Staff_Member__c trpsm;

        if (HL_SecurityUtility.VerifyFieldAccess(new List<String> {'Id'}, Schema.sObjectType.Time_Record_Period_Staff_Member__c.fields.getMap()))
            trpsm = HL_TimeRecordControllerBase.GetCurrentTimeRecordPeriodStaffMemberRecord(category);

        return trpsm;
    }

    @AuraEnabled
    public static Time_Record_Period_Staff_Member__c GetTimeRecordPeriodStaffMemberRecord(string category, Time_Record_Period__c timePeriod) {
        Time_Record_Period_Staff_Member__c trpsm;

        if (HL_SecurityUtility.VerifyFieldAccess(new List<String> {'Id'}, Schema.sObjectType.Time_Record_Period_Staff_Member__c.fields.getMap()))
            trpsm = HL_TimeRecordControllerBase.GetTimeRecordPeriodStaffMemberRecord(category, timePeriod);

        return trpsm;
    }

    //Gets the User's Category based on the group they are in
    @AuraEnabled
    public static String GetCategory() {
        return HL_Group.GetTimeTrackingGroup();
    }

    @AuraEnabled
    public static List<Time_Record_Period__c> GetPeriods(string category) {
        return HL_TimeRecordPeriod.GetPeriods(category);
    }

    @AuraEnabled
    public static Time_Record_Period__c GetPeriod(Id id) {
        return HL_TimeRecordPeriod.GetPeriod(id);
    }

    //Litigation wishes to be able to specify any date range so we use User here instead of Time Record Period Staff Member
    @AuraEnabled
    public static List<Time_Record__c> GetTimeRecords(Id userId, string startDate, string endDate) {
        Date formattedStart;
        Date formattedEnd;
        if (String.isBlank(startDate) || String.isBlank(endDate)) {
            Time_Record_Period__c trp = GetCurrentPeriod('');
            formattedStart = trp.Start_Date__c;
            formattedEnd = trp.End_Date__c;
        }
        else {
            formattedStart = Date.parse(HL_DateUtility.FormatJSDate(startDate));
            formattedEnd = Date.parse(HL_DateUtility.FormatJSDate(endDate));
        }
        if (String.isBlank(userId))
            userId = UserInfo.getUserId();
        return HL_TimeRecord.GetByUser(userId, formattedStart, formattedEnd);
    }

    @AuraEnabled
    public static List<Time_Record_Rollup_Day__c> GetTimeRecordDayRollups(Id userId, string startDate, string endDate) {
        Date formattedStart = Date.parse(HL_DateUtility.FormatJSDate(startDate));
        Date formattedEnd = Date.parse(HL_DateUtility.FormatJSDate(endDate));
        List<Time_Record_Rollup_Day__c> timeRecordRollupDayList;

        if (HL_SecurityUtility.VerifyFieldAccess(new List<String> {'Id', 'Time_Record_Period_Staff_Member__c', 'Activity_Date__c', 'Engagement__c', 'Activity_Type__c'}, Schema.sObjectType.Time_Record__c.fields.getMap()))
            timeRecordRollupDayList = HL_TimeRecordRollupDay.GetByUser(userId, formattedStart, formattedEnd);

        return timeRecordRollupDayList;
    }

    @AuraEnabled
    public static List<AggregateResult> GetRollupGroupedByEngagement(string category, string startDate, string endDate) {
        Date formattedStart = Date.parse(HL_DateUtility.FormatJSDate(startDate));
        Date formattedEnd = Date.parse(HL_DateUtility.FormatJSDate(endDate));
        List<AggregateResult> resultList;

        if (HL_SecurityUtility.VerifyFieldAccess(new List<String> {'Id', 'Time_Record_Period_Staff_Member__c', 'Activity_Date__c', 'Engagement__c', 'Activity_Type__c'}, Schema.sObjectType.Time_Record__c.fields.getMap()))
            resultList = HL_TimeRecordRollupDay.GetGroupedByEngagement(category, formattedStart, formattedEnd);

        return resultList;
    }

    @AuraEnabled
    public static List<AggregateResult> GetRollupGroupedByDay(Id userId, string startDate, string endDate) {
        Date formattedStart = Date.parse(HL_DateUtility.FormatJSDate(startDate));
        Date formattedEnd = Date.parse(HL_DateUtility.FormatJSDate(endDate));
        List<AggregateResult> resultList;

        if (HL_SecurityUtility.VerifyFieldAccess(new List<String> {'Id', 'Time_Record_Period_Staff_Member__c', 'Activity_Date__c', 'Opportunity__c', 'Engagement__c', 'Special_Project__c', 'Activity_Type__c'}, Schema.sObjectType.Time_Record__c.fields.getMap()))
            resultList = HL_TimeRecordRollupDay.GetGroupedByDay(userId, formattedStart, formattedEnd);

        return resultList;
    }

    @AuraEnabled
    public static List<AggregateResult> GetRollupGroupedByDayAndProject(Id userId, string startDate, string endDate) {
        Date formattedStart = Date.parse(HL_DateUtility.FormatJSDate(startDate));
        Date formattedEnd = Date.parse(HL_DateUtility.FormatJSDate(endDate));
        List<AggregateResult> resultList;

        if (HL_SecurityUtility.VerifyFieldAccess(new List<String> {'Id', 'Time_Record_Period_Staff_Member__c', 'Activity_Date__c', 'Opportunity__c', 'Engagement__c', 'Special_Project__c', 'Activity_Type__c'}, Schema.sObjectType.Time_Record__c.fields.getMap()))
            resultList = HL_TimeRecordRollupDay.GetGroupedByDayAndProject(userId, formattedStart, formattedEnd);

        return resultList;
    }

    @AuraEnabled
    public static Time_Record__c InsertRecord(Time_Record__c tr, string recordDate, string userId, string category,integer allowedHourEntry) {
        Date formattedDate = Date.parse(HL_DateUtility.FormatJSDate(recordDate));
        if (String.isBlank(userId))
            userId = UserInfo.getUserId();
        Contact c = HL_Contact.GetByUserId(userId);
        
        
        Title_Rate_Sheet__c trs;

        tr.Activity_Date__c = formattedDate;

        if (String.isBlank(tr.Recording_Status__c))
            tr.Recording_Status__c = 'Complete';

        //Propertly assign the correct Time Record Period Staff Member Link
        Time_Record_Period__c trp = HL_TimeRecordPeriod.GetByDate(category, formattedDate);
        Time_Record_Period_Staff_Member__c trpsm = new HL_TimeRecordPeriodStaffMember(trp, c).GetByPeriodAndStaffMember(true);
        tr.Time_Record_Period_Staff_Member__c = trpsm.Id;
        tr.Seconds_Worked_Actual__c = tr.Hours_Worked__c * 60;
        tr.Seconds_Worked__c=tr.Hours_Worked__c;
        //Assign the Rate
        if (!String.isBlank(tr.Engagement__c)) {
            Decimal rate = new HL_TitleRateSheet().GetRateByEngagementIdAndTitle(tr.Engagement__c, c.Title);
            tr.Hourly_Rate__c = rate;
        }
        else if (tr.Hourly_Rate__c == null)
            tr.Hourly_Rate__c = 0.0;

        //Assign the Record Type
        if (String.isBlank(tr.RecordTypeId) && !String.isBlank(category))
            tr.RecordTypeId = Schema.SObjectType.Time_Record__c.getRecordTypeInfosByName().get(category).getRecordTypeId();

        if (tr.Hours_Worked__c >= 0 && tr.Hours_Worked__c <= allowedHourEntry) {
            insert tr;
        }

        return tr;
    }

    @AuraEnabled
    public static Time_Record__c UpdateRecord(Time_Record__c tr) {
        if (tr.Hours_Worked__c > 0 && tr.Hours_Worked__c <= 24) {
            update tr;
        }
        
        return tr;
    }
   @AuraEnabled
    public static Time_Record__c UpdateRecordStatus(Time_Record__c tr) {
       // tr.Stop_Time__c=System.Now();
            update tr;
       
      Time_Record__c trm=[select Id,Time__c,Seconds_Worked__c,Hours_Worked__c From Time_Record__c where id=:tr.Id];
     system.debug('tr........'+trm);
   
     return trm;
    }
    @AuraEnabled
    public static Time_Record__c fetchTime(Time_Record__c tr) {
   
     system.debug('tr........'+tr.Id);
     Time_Record__c t=[select Id,Time__c,Seconds_Worked__c,Stop_Time__c,Minutes_Worked__c,Start_Time__c,Timer_Status__c,Hours_Worked__c From Time_Record__c where id=:tr.Id];
     system.debug('tr........'+t);
     if(t.Timer_Status__c=='Start' ){
      t.Stop_Time__c=System.Now();
                Long dt1Long = t.Start_Time__c.getTime();
                Long dt2Long = DateTime.now().getTime();
                Decimal milliseconds = dt2Long - dt1Long;
                Decimal seconds = milliseconds / 1000;
                Decimal minutes = seconds / 60;
                //t.Seconds_Worked__c=seconds;
                if(t.Minutes_Worked__c==null)t.Minutes_Worked__c=0;
                t.Minutes_Worked__c= t.Minutes_Worked__c+minutes.setScale(1);
                system.debug('min change'+minutes+'minutes...'+ t.Minutes_Worked__c);
           Decimal hours =  t.Minutes_Worked__c/ 60;
        //t.Hours_Worked__c=hours.setscale(1);
        t.Seconds_Worked__c=hours.setscale(2);
     }
    
     return t;
    }
    @AuraEnabled
    public static List<Time_Record__c> InsertRecords(List<Time_Record__c> timeRecords, string userId, string category,integer allowedHourEntry) {
        List<Time_Record__c> insertRecords = new List<Time_Record__c>();
        
        for (Time_Record__c t: timeRecords) {
            if (t.Hours_Worked__c > 0 && t.Hours_Worked__c <= allowedHourEntry) {
                if (String.isBlank(userId)) {
                    userId = UserInfo.getUserId();
                }    
                Contact c = HL_Contact.GetByUserId(userId);
                
                        
                //Assign the Rate
                if (!String.isBlank(t.Engagement__c)) {
                    Decimal rate = new HL_TitleRateSheet().GetRateByEngagementIdAndTitle(t.Engagement__c, c.Title);
                    t.Hourly_Rate__c = rate;
                }
                else if (t.Hourly_Rate__c == null) {
                    t.Hourly_Rate__c = 0.0;    
                }
                
                insertRecords.add(t);
            }
        }
        
        insert insertRecords;
        return timeRecords;
    }

    @AuraEnabled
    public static List<Time_Record__c> UpdateRecords(List<Time_Record__c> timeRecords,integer allowedHourEntry) {
        List<Time_Record__c> updateRecords = new List<Time_Record__c>();
        for (Time_Record__c u: timeRecords) {
            if (u.Hours_Worked__c > 0 && u.Hours_Worked__c <= allowedHourEntry) {
                updateRecords.add(u);
            }
        }
        update updateRecords;
        return timeRecords;
    }

    @AuraEnabled
    public static Time_Record__c UpdateHoursWorked(Id recordId, decimal value, integer allowedHourEntry) {
        Time_Record__c tr = new Time_Record__c(Id = recordId, Hours_Worked__c = value,Hours_Change__c=true);

        //Verify the User has access to the fields we want to update
        if ((value > 0 && value <= allowedHourEntry) && HL_SecurityUtility.VerifyFieldAccess(new List<String> {'Id', 'Hours_Worked__c','Hours_Change__c'}, Schema.sObjectType.Time_Record__c.fields.getMap()))
            update tr;
            system.debug(tr.Hours_Worked__c+'Hours_Change__c....'+tr.Hours_Change__c);
        return tr;
    }

    @AuraEnabled
    public static Time_Record__c UpdateHourlyRate(Id recordId, decimal value) {
        Time_Record__c tr = new Time_Record__c(Id = recordId, Hourly_Rate__c = value);

        if (HL_SecurityUtility.VerifyFieldAccess(new List<String> {'Id', 'Hourly_Rate__c'}, Schema.sObjectType.Time_Record__c.fields.getMap()))
            update tr;

        return tr;
    }

    @AuraEnabled
    public static Time_Record__c UpdateActivityType(Id recordId, string value) {
        Time_Record__c tr = new Time_Record__c(Id = recordId, Activity_Type__c = value);

        if (HL_SecurityUtility.VerifyFieldAccess(new List<String> {'Id', 'Activity_Type__c'}, Schema.sObjectType.Time_Record__c.fields.getMap()))
            update tr;

        return tr;
    }

    @AuraEnabled
    public static Time_Record__c UpdateComments(Id recordId, string value) {
        Time_Record__c tr = new Time_Record__c(Id = recordId, Comments__c = value);

        if (HL_SecurityUtility.VerifyFieldAccess(new List<String> {'Id', 'Comments__c'}, Schema.sObjectType.Time_Record__c.fields.getMap()))
            update tr;

        return tr;
    }

    @AuraEnabled
    public static Time_Record__c UpdateCurrencyIsoCode(Id recordId, string value) {
        Time_Record__c tr = new Time_Record__c(Id = recordId, CurrencyIsoCode = value);

        if (HL_SecurityUtility.VerifyFieldAccess(new List<String> {'Id', 'CurrencyIsoCode'}, Schema.sObjectType.Time_Record__c.fields.getMap()))
            update tr;

        return tr;
    }

    @AuraEnabled
    public static Time_Record__c DeleteRecord(Id recordId) {
        Time_Record__c tr = new Time_Record__c(Id = recordId);

        if (HL_SecurityUtility.VerifyFieldAccess(new List<String> {'Id'}, Schema.sObjectType.Time_Record__c.fields.getMap()))
            delete tr;

        return tr;
    }

    @AuraEnabled
    webservice static List<String> GetActivityTypes() {
        Id recordTypeId = GetTimeRecordRecordType();
        
        return GetPicklistOptionsByRecordType('Time_Record__c', 'Activity_Type__c', recordTypeId);
    }
    
    private static Id GetTimeRecordRecordType() {
        Id recordTypeId;
        string category = GetCategory();
        
        if (!String.isBlank(category))
            recordTypeId = Schema.sObjectType.Time_Record__c.getRecordTypeInfosByName().get(category).getRecordTypeId();
        
        return recordTypeId;
    }

    @AuraEnabled
    public static List<String> GetCurrencyCodes() {
        return HL_Utility.GetPicklistValues('Engagement__c', 'CurrencyIsoCode');
    }

    //Determines if the user is in the supervisor group
    @AuraEnabled
    public static Boolean IsSupervisor(string category) {
        return HL_TimeRecordControllerBase.IsSupervisor(category);
    }

    @AuraEnabled
    public static Id GetCurrentUserId() {
        return UserInfo.getUserId();
    }

    @AuraEnabled
    public static List<Opportunity__c> GetOpportunities(string category, string userId) {
        return HL_TimeRecordControllerBase.GetOpportunities(category, userId);
    }

    @AuraEnabled
    public static List<Special_Project__c> GetSpecialProjects() {
        string category = GetCategory();
        if (String.isBlank(category))
            category = 'FR';

        Id spRecordTypeId = Schema.sObjectType.Special_Project__c.getRecordTypeInfosByName().get(category).getRecordTypeId();

        return HL_TimeRecordControllerBase.GetSpecialProjects(spRecordTypeId);
    }

    @AuraEnabled
    public static List<Engagement__c> GetEngagements(string category, string userId) {
        return HL_TimeRecordControllerBase.GetEngagements(category, userId);
    }

    @AuraEnabled
    public static List<Engagement__c> GetEngagementsAtPointInTime(Id userId, string startDate, string endDate) {
        Date formattedStart = Date.parse(HL_DateUtility.FormatJSDate(startDate));
        Date formattedEnd = Date.parse(HL_DateUtility.FormatJSDate(endDate));
        Map<Id, Engagement__c> engagementMap = new Map<Id, Engagement__c>();

        for (Engagement__c e : HL_Engagement.GetByUserAtPointInTime(userId, formattedStart, formattedEnd, formattedStart.addMonths(-2)))
            engagementMap.put(e.Id, e);

        for (Time_Record_Rollup_Day__c tr : HL_TimeRecordRollupDay.GetEngagementsLoggedForUser(userId, formattedStart, formattedEnd)) {
            if (engagementMap.get(tr.Engagement__c) == null)
                engagementMap.put(tr.Engagement__c, tr.Engagement__r);
        }

        return engagementMap.values();
    }

    @AuraEnabled
    webservice static List<Time_Record__c> GetPendingRecords(string userId) {
        if (String.isBlank(userId))
            userId = UserInfo.getUserId();

        return [SELECT Activity_Date__c, Activity_Type__c, Opportunity__c, Engagement__c, Special_Project__c, Project_Name__c, Hours_Worked__c, Comments__c
                FROM Time_Record__c
                WHERE Time_Record_Period_Staff_Member__r.User__c = : userId AND Recording_Status__c = 'In Progress'];
    }

    @RemoteAction
    webservice static String CancelRecordingRecord(String timePeriodId, String userId, String activityType, String objectType, String objectId) {
        Time_Record__c tr = GetRecordingRecord(timePeriodId, userId, activityType, objectType, objectId);
        if (!String.isBlank(tr.Id))
            delete tr;
        return tr.Id;
    }

    @RemoteAction
    webservice static String RecordTime(String timePeriodId, String userId, String activityType, String objectType, String objectId, Integer minutes, Integer totalSeconds, String recordingStatus) {
        Time_Record__c tr = GetRecordingRecord(timePeriodId, userId, activityType, objectType, objectId);
        tr.Hours_Worked__c = (minutes / 60.0).setScale(1, RoundingMode.HALF_UP);
        tr.Seconds_Worked_Actual__c = totalSeconds;
        tr.Recording_Status__c = recordingStatus;
        upsert tr;
        return tr.Id;
    }

    @RemoteAction
    public static String RecordTimeRemote(String values) {
        List<String> valueList = values.replace('}', '').replace('{', '').split(',');
        String timePeriodId = valueList[0].split('=')[1];
        String userId = valueList[1].split('=')[1];
        String activityType = valueList[2].split('=')[1];
        String objectType = valueList[3].split('=')[1];
        String objectId = valueList[4].split('=')[1];
        Integer minutes = Integer.valueOf(valueList[5].split('=')[1]);
        Time_Record__c tr = GetRecordingRecord(timePeriodId, userId, activityType, objectType, objectId);
        tr.Hours_Worked__c = ((tr.Hours_Worked__c * 60.0 + minutes) / 60.0).setScale(1, RoundingMode.HALF_UP);
        upsert tr;
        return tr.Id;
    }

    @RemoteAction
    webservice static Id GetCurrentPeriodRecordId(string category) {
        Time_Record_Period__c trp = GetCurrentPeriod(category);
        return trp.Id;
    }

    @RemoteAction
    public static List<Time_Record__c> GetByUser(Id userId, Date startDate, Date endDate) {
        return HL_TimeRecord.GetByUser(userId, startDate, endDate);
    }

    //Gets the recording record by period, user, activity type and related deal/project
    private static Time_Record__c GetRecordingRecord(Id timePeriodId, Id userId, String activityType, String objectType, String objectId) {
        List<Time_Record__c> trList = [SELECT Activity_Type__c, Hourly_Rate__c, Hours_Worked__c FROM Time_Record__c WHERE Time_Record_Period_Staff_Member__r.Time_Record_Period__c = : timePeriodId AND Time_Record_Period_Staff_Member__r.User__c = : userId AND Activity_Type__c = : activityType AND Recording_Status__c = 'In Progress' AND (Opportunity__c = : objectId OR Engagement__c = : objectId OR Special_Project__c = : objectId)];
        if (trList.size() <= 0) {
            Contact c = HL_Contact.GetByUserId();
            
            
            HL_TimeRecordPeriodStaffMember trStaffMember = new HL_TimeRecordPeriodStaffMember(new Time_Record_Period__c(Id = timePeriodId), c);
            Decimal rate = new HL_TitleRateSheet().GetRateByEngagementIdAndTitle(objectId, c.Title);
            return new Time_Record__c(Activity_Date__c = Date.today(), Activity_Type__c = activityType, Hourly_Rate__c = rate, Hours_Worked__c = 0.0, Opportunity__c = (objectType == 'Opportunity__c' ? objectId : null), Engagement__c = (objectType == 'Engagement__c' ? objectId : null), Time_Record_Period_Staff_Member__c = trStaffMember.GetRecord(true).Id);
        }
        return trList[0];
    }

    public static Time_Record_Period__c GetPeriodRecord(string category, Date recordDate) {
        List<Time_Record_Period__c> trpList = [SELECT Start_Date__c, End_Date__c FROM Time_Record_Period__c WHERE Start_Date__c <= : recordDate AND End_Date__c >= : recordDate AND Period_Category__c = : category];
        if (trpList.size() == 0) {
            Date start = recordDate.toStartofWeek();
            trpList.add(new Time_Record_Period__c(Start_Date__c = start, End_Date__c = start.addDays(6), Period_Category__c = category));
            insert trpList;
        }
        return trpList[0];
    }

    @AuraEnabled
    public static Boolean SendInvoiceNotification(string category, string startDate, string endDate, List<Id> engagementIdList) {
        Date formattedStart = Date.parse(HL_DateUtility.FormatJSDate(startDate));
        Date formattedEnd = Date.parse(HL_DateUtility.FormatJSDate(endDate));
        HL_EmailMerge em = new HL_EmailMerge('Time_Tracking_Invoice_Prep', null);
        HL_Email email = new HL_Email();
        List<User> emailUserList = HL_Group.GetGroupMembers('Time_Tracking_' + category);
        List<AggregateResult> invoiceList = HL_TimeRecordRollupDay.GetGroupedByEngagement(category, formattedStart, formattedEnd, engagementIdList);
        List<String> emailList = new List<String>();
        em.MergeInvoiceFields(invoiceList);

        for (User u : emailUserList)
            emailList.add(u.Email);

        email.AddEmailToQueue(emailList, null, null, em.EmailTemplate.Email_Subject__c, em.EmailTemplate.Template_Body__c, true);

        if (email.QueuedMessages.size() > 0)
            email.SendQueuedMessages();

        return true;
    }

    private static List<String> GetPicklistOptionsByRecordType(string sobjectType, string picklistField, Id recordTypeId) {
        PageReference picklistFilterPage = Page.HL_PicklistFilterPage;
        Map<String, String> parameters = new Map<String, String> {
            'sobjectType' => sobjectType,
            'recordTypeId' => recordTypeId,
            'picklistFieldName' => picklistField
        };
            
        for (String key : parameters.keySet())
            picklistFilterPage.getParameters().put(key, parameters.get(key));   
       
        Pattern optionPattern = Pattern.compile('<option.+a?>(.+?)</option>');
        String pageContent = !Test.isRunningTest() ? picklistFilterPage.getContent().toString() : '<option value="">--None--</option><option value="Test">Test</option>';
        Matcher patternMatcher = optionPattern.matcher(pageContent);
        List<String> picklistOptionList = new List<String>();
        
        while (patternMatcher.find()) 
            picklistOptionList.add(patternMatcher.group(1));
    
        if (!picklistOptionList.isEmpty()) picklistOptionList.remove(0);
        
        return picklistOptionList;
    }
}