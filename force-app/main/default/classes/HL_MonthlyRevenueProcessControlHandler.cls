/**
* \arg ClassName      : HL_MonthlyRevenueProcessControlHandler
*   Description       : To avoid CPU Error limit and Updating list "engUpdateList" of engagements through Batch process( Batch apex Class Name :HL_UpdateEngagementBatch)
    Description       : To avoid DML rows limit 10001, Instead of insert DML operation, Using Enqueuejob to insert new records ( Class Name : HL_AsyncMonthlyProcessControl)
    Developer Name    : Vikas 

Modified: 11/04/2020
Author: Guru Sandhu
Change: Added new public method "onAfterUpdate" to trigger the Engagement LOB Splits in the new private method "engagementSplitLOB"
ServiceNow Reference: DMND0024695

*/ 

public with sharing class HL_MonthlyRevenueProcessControlHandler{
    public static boolean isTest = false;
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public HL_MonthlyRevenueProcessControlHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void onBeforeUpdate(List<Monthly_Revenue_Process_Control__c> mrpcList, Map<id,Monthly_Revenue_Process_Control__c> mrpcOldMap){
        List<Monthly_Revenue_Process_Control__c> mrpcUnlockList = new List<Monthly_Revenue_Process_Control__c>();
        boolean staffSummaryReportSent = false;
        for(Monthly_Revenue_Process_Control__c mrpc : mrpcList){
            Monthly_Revenue_Process_Control__c mrpcOld = mrpcOldMap.get(mrpc.id);
            System.debug('Month is: -->' + mrpc.Revenue_Date__c);
            System.debug('Old IsCurrent Flag: ' + mrpcOld.IsCurrent__c + ' ---- || New IsCurrent Flag: ' + mrpc.IsCurrent__c);
            System.debug('Old Staff Summary Sent Flag: ' + mrpcOld.Staff_Summary_Report_Sent__c + ' ---- || New Staff Summary Sent Flag: ' + mrpc.Staff_Summary_Report_Sent__c);
            System.debug('Old Revenue Accrual Flag: ' + mrpcOld.Revenue_Accruals_Locked__c + ' ---- || New Revenue Accrual Flag: ' + mrpc.Revenue_Accruals_Locked__c);

            //If the record is current and staff summary report sent is completed, we want to unlock 
            if(mrpc.IsCurrent__c && mrpc.Staff_Summary_Report_Sent__c && mrpc.Revenue_Accruals_Locked__c)
                mrpcUnlockList.add(mrpc);

            //We only want one record to have the isCurrent flag marked.
            if(mrpc.IsCurrent__c <> mrpcOld.IsCurrent__c && mrpc.IsCurrent__c == true && [SELECT ID FROM Monthly_Revenue_Process_Control__c WHERE IsCurrent__c = true LIMIT 1].size() > 0)
                mrpc.addError('There is already a record that has the "is Current" field checked, you can only indicated one record as current.  Please go back and uncheck the "is Current" flag on the existing record before marking another record as current.');
            
            if(mrpc.Staff_Summary_Report_Sent__c <> mrpcOld.Staff_Summary_Report_Sent__c && mrpc.Staff_Summary_Report_Sent__c == true) {
                staffSummaryReportSent = true;
            }
        }

        if (staffSummaryReportSent) { 
            EnterMonthlyOfficeSplit(mrpcList);
        }    

        if(mrpcUnlockList.size() > 0){
            //Unlock should happen first so that way we don't have a current record
            Unlock(mrpcUnlockList);
            ClearEngagementCurrentRevenueAccrual(mrpcList);
            SetEngagementCurrentRevenueProjection(mrpcList);
        } 
    }

    public void onAfterUpdate(List<Monthly_Revenue_Process_Control__c> mrpcList, Map<id,Monthly_Revenue_Process_Control__c> mrpcOldMap){
        Date previousMonthDate = System.Today().toStartOfMonth().addDays(-1);
     //   Date previousMonthDate =  Date.newInstance(2020, 12, 31);
     List<Monthly_Revenue_Process_Control__c> mrpcUnlockList = new List<Monthly_Revenue_Process_Control__c>();

        List<Id> mrpcRecs = new List<Id>();
        for(Monthly_Revenue_Process_Control__c mrpc : mrpcList){
            Monthly_Revenue_Process_Control__c mrpcOld = mrpcOldMap.get(mrpc.id);
            if(mrpc.Staff_Summary_Report_Sent__c && mrpcOld.Staff_Summary_Report_Sent__c == false && mrpc.Revenue_Date__c == previousMonthDate){
                mrpcRecs.add(mrpc.Id);
            }

        }
            if(!mrpcRecs.isEmpty()){
     //           engagementSplitLOB(mrpcList,previousMonthDate);
            }

   
}

    private void Unlock(List<Monthly_Revenue_Process_Control__c> mrpcList){
        //Unlock the General Setting
        HL_General__c hg = HL_General__c.getOrgDefaults();
        hg.Revenue_Accrual_Locked__c = false;
        update hg;

        for(Monthly_Revenue_Process_Control__c mrpc : mrpcList){
            mrpc.IsCurrent__c = false;
            mrpc.Revenue_Accruals_Locked__c = false;
        }
        CreateNextMonthlyRevenueProcessControl(mrpcList);
    }

    private void EnterMonthlyOfficeSplit(List<Monthly_Revenue_Process_Control__c> mrpcList) {
        List<Revenue_Accrual_Office_Split__c> revenueAccrualOfficeSplitToInsert = new List<Revenue_Accrual_Office_Split__c>();
        List<Engagement_Office_Split__c> officeSplit = new List<Engagement_Office_Split__c>();
        Map<Id, Id> engagementAccrualMap = new Map<Id, Id>();
        Set<Id> engagementSet = new Set<Id>();
        Set<Id> revenueAccrualSet = new Set<Id>();

        for(Revenue_Accrual__c ra : [SELECT Engagement__c, Engagement__r.Current_Revenue_Accrual__c 
                                    FROM Revenue_Accrual__c 
                                    WHERE Monthly_Revenue_Process_Control__c IN: mrpcList AND Engagement__r.Current_Revenue_Accrual__c <> null]) {
            if (ra.Engagement__c <> null && ra.Engagement__r.Current_Revenue_Accrual__c <> null) {
                engagementAccrualMap.put(ra.Engagement__c, ra.Engagement__r.Current_Revenue_Accrual__c);
                engagementSet.add(ra.Engagement__c);
                revenueAccrualSet.add(ra.Engagement__r.Current_Revenue_Accrual__c);
            }
        }

        List<Revenue_Accrual_Office_Split__c> revenueAccrualOfficeSplitToDelete = [SELECT Id 
                                                                                    FROM Revenue_Accrual_Office_Split__c 
                                                                                    WHERE Revenue_Accrual__c IN: revenueAccrualSet];
            
        for(Engagement_Office_Split__c os : [SELECT Engagement__c, Engagement_LOB__c, Office__c, Office_Split__c, Office_Split_Override_Percent__c, Office_Split_Percent__c FROM Engagement_Office_Split__c WHERE Engagement__c IN: engagementSet]) {
            revenueAccrualOfficeSplitToInsert.add(new Revenue_Accrual_Office_Split__c(Engagement_LOB__c = os.Engagement_LOB__c, 
                Office__c = os.Office__c, 
                Office_Split__c = os.Office_Split__c, 
                Office_Split_Override_Percent__c = os.Office_Split_Override_Percent__c, 
                Office_Split_Percent__c = os.Office_Split_Percent__c, 
                Revenue_Accrual__c = engagementAccrualMap.get(os.Engagement__c)));
        }

        if (revenueAccrualOfficeSplitToDelete.size() > 0) {
            delete revenueAccrualOfficeSplitToDelete;
        }

        if (revenueAccrualOfficeSplitToInsert.size() > 0) {
         //  insert revenueAccrualOfficeSplitToInsert;
            System.enqueueJob(new HL_AsyncMonthlyProcessControl(revenueAccrualOfficeSplitToInsert, true));
        }
    }

    private void ClearEngagementCurrentRevenueAccrual(List<Monthly_Revenue_Process_Control__c> mrpcList){

        Map<Id, Id> engAccrualMap = new Map<Id, Id>();
        List<Engagement__c> engUpdateList = new List<Engagement__c>();

        //Get Engagements to Clear
        for(Revenue_Accrual__c ra : [SELECT Engagement__c, Engagement__r.Current_Revenue_Accrual__c FROM Revenue_Accrual__c WHERE Monthly_Revenue_Process_Control__c IN: mrpcList AND Engagement__r.Current_Revenue_Accrual__c <> null])
            engAccrualMap.put(ra.Engagement__c, ra.Engagement__r.Current_Revenue_Accrual__c);

        for(Id id : engAccrualMap.keySet()){
            engUpdateList.add(new Engagement__c(Id = id, Latest_Revenue_Accrual__c = engAccrualMap.get(id), Current_Revenue_Accrual__c = null, Period_Accrued_Fees__c = null, Accrual_Adjustment__c = null, Actual_Monthly_Fee__c = null, Actual_Transaction_Fee__c = null));
        }

        if(engUpdateList.size() > 0){

            //Block the Engagement Trigger from Firing
            HL_TriggerContextUtility.ByPassOnMonthlyRevenueProcess = true;

            //Perform Updates
           //Commenting below line "update engUpdateList" to avoid CPU Error limit and Updating list "engUpdateList" of engagements to clear through Batch process
           //update engUpdateList;
            Database.Executebatch(new HL_UpdateEngagementBatch(engUpdateList), 200);

            //Unblock Engagement Trigger from Firing
            HL_TriggerContextUtility.ByPassOnMonthlyRevenueProcess = false;
        }
    }

    private void SetEngagementCurrentRevenueProjection(List<Monthly_Revenue_Process_Control__c> mrpcList){
        Map<Id, Revenue_Projection__c> engProjectionMap = new Map<Id, Revenue_Projection__c>();
        List<Engagement__c> engUpdateList = new List<Engagement__c>();

        String pYear = null;
        String pMonth = null;
        String cYear = null;
        String cMonth = null;

        for (Monthly_Revenue_Process_Control__c previousProcessControl : mrpcList){
            pMonth = previousProcessControl.Current_Month__c;
            pYear = previousProcessControl.Current_Year__c;
            Integer previousMonth = integer.valueof(previousProcessControl.Current_Month__c);
            Integer previousYear = integer.valueof(previousProcessControl.Current_Year__c);
            Integer currentMonth = previousMonth == 12 ? 1 : previousMonth + 1;
            Integer currentYear = previousMonth == 12 ? previousYear + 1 : previousYear;
            cMonth = string.valueof(currentMonth).leftPad(2).replace(' ', '0');
            cYear = string.valueof(currentYear);
        }

        //Get this month's revenue projection and engagements with a stale Current_Revenue_Projection__c
        for(Revenue_Projection__c rp : [SELECT Id, Month__c, Year__c, Engagement__c, Projected_Monthly_Fee__c, Projected_Transaction_Fee__c, Total__c, Engagement__r.Current_Revenue_Projection__c 
                                        FROM Revenue_Projection__c 
                                        WHERE (Month__c =: pMonth AND Year__c =: pYear) OR (Month__c =: cMonth AND Year__c =: cYear)]) {
            if (rp.Month__c == cMonth && rp.Year__c == cYear) {
                engProjectionMap.put(rp.Engagement__c, rp);
            }
            else {
                //Clear engagements that have a stale Current_Revenue_Projection__c
                engProjectionMap.put(rp.Engagement__c, null);
            }
        }       

        for(Id id : engProjectionMap.keySet()) {
            if (engProjectionMap.get(id) != null) {
                engUpdateList.add(new Engagement__c(Id = id, 
                    Current_Revenue_Projection__c = engProjectionMap.get(id).Id, 
                    Projected_Monthly_Fee__c = engProjectionMap.get(id).Projected_Monthly_Fee__c, 
                    Projected_Transaction_Fee__c = engProjectionMap.get(id).Projected_Transaction_Fee__c,
                    Projected_Total_Fee__c = engProjectionMap.get(id).Total__c
                ));
            }
            else {
                engUpdateList.add(new Engagement__c(Id = id, 
                    Current_Revenue_Projection__c = null, 
                    Projected_Monthly_Fee__c = null, 
                    Projected_Transaction_Fee__c = null,
                    Projected_Total_Fee__c = null
                ));
            }
        }
            

        if(engUpdateList.size() > 0){
            //Block the Engagement Trigger from Firing
            HL_TriggerContextUtility.ByPassOnMonthlyRevenueProcess = true;

            //Perform Updates
            update engUpdateList;

            //Unblock Engagement Trigger from Firing
            HL_TriggerContextUtility.ByPassOnMonthlyRevenueProcess = false;
        }
    }

     private void CreateNextMonthlyRevenueProcessControl(List<Monthly_Revenue_Process_Control__c> processControlList){
        List<Monthly_Revenue_Process_Control__c> nextProcessControlList = new List<Monthly_Revenue_Process_Control__c>();
        Set<Date> holidaySet = new Set<Date>();
        for(Holiday holidays : [SELECT ActivityDate FROM Holiday]){
            holidaySet.add(holidays.ActivityDate);
        }

        for (Monthly_Revenue_Process_Control__c previousProcessControl : processControlList){
            Monthly_Revenue_Process_Control__c nextProcessControl = new Monthly_Revenue_Process_Control__c();
            nextProcessControl.IsCurrent__c = true;
            nextProcessControl.Initial_Reversal_Submitted__c = true;
            Integer previousMonth = integer.valueof(previousProcessControl.Current_Month__c);
            Integer previousYear = integer.valueof(previousProcessControl.Current_Year__c);
            Integer currentMonth = previousMonth == 12 ? 1 : previousMonth + 1;
            Integer currentYear = previousMonth == 12 ? previousYear + 1 : previousYear;
            nextProcessControl.Current_Month__c = string.valueof(currentMonth).leftPad(2).replace(' ', '0');
            nextProcessControl.Current_Year__c = string.valueof(currentYear);
            DateTime monthBeginDate = DateTime.newInstance(currentYear, currentMonth, 1);
            nextProcessControl.Name = monthBeginDate.format('MMMMM') + ' ' + nextProcessControl.Current_Year__c;
            DateTime lastDayOfMonth = monthBeginDate.addDays(Date.daysInMonth(currentYear, currentMonth)-1);
            nextProcessControl.Revenue_Date__c = date.valueof(lastDayOfMonth);
            DateTime nextMonth = lastDayOfMonth.addDays(1);
            DateTime finalChanges;
            
            if([SELECT Id FROM Monthly_Revenue_Process_Control__c WHERE Current_Month__c =: nextProcessControl.Current_Month__c AND Current_Year__c =: nextProcessControl.Current_Year__c LIMIT 1].size() == 0){

                if(!(lastDayOfMonth.format('EEEE') == 'Saturday' || lastDayOfMonth.format('EEEE') == 'Sunday' || holidaySet.contains(lastDayOfMonth.date()))){
                    lastDayOfMonth = lastDayOfMonth.addDays(-1);
                }
                else {
                    while(lastDayOfMonth.format('EEEE') == 'Saturday' || lastDayOfMonth.format('EEEE') == 'Sunday' || holidaySet.contains(lastDayOfMonth.date())){
                    lastDayOfMonth = lastDayOfMonth.addDays(-1);
                }
            }

            finalChanges = lastDayOfMonth;

                while(finalChanges.format('EEEE') == 'Saturday' || finalChanges.format('EEEE') == 'Sunday' || holidaySet.contains(finalChanges.date())){
                    finalChanges = finalChanges.addDays(-1);
                }

                nextProcessControl.Final_Changes_Due__c = date.valueof(finalChanges);
                
                while(nextMonth.format('EEEE') == 'Saturday' || nextMonth.format('EEEE') == 'Sunday' || holidaySet.contains(nextMonth.date())){
                    nextMonth = nextMonth.addDays(1);
                }
                 
                nextProcessControl.Final_Report_Date__c = date.valueof(nextMonth);
                nextProcessControlList.add(nextProcessControl);
                insert nextProcessControlList;
            }
        }
    }

    private void engagementSplitLOB(List<Monthly_Revenue_Process_Control__c> mrpcList, Date previousMonthDate){
 /*
            Set<Id> engagementIds = new Set<Id>();

            List<Staffing_Details__c> lstStaffingDetail = [SELECT Engagement__c FROM Staffing_Details__c WHERE Revenue_Date__c =:previousMonthDate];
            if(!lstStaffingDetail.isEmpty()){
                for(Staffing_Details__c sd : lstStaffingDetail)
                engagementIds.add(sd.Engagement__c);
                }
        HL_PercentageSplitHandler handler = new HL_PercentageSplitHandler();
        handler.RecalculateLOBSplits(engagementIds);   */
        
        Integer countStaffDetails = [SELECT count() FROM Staffing_Details__c WHERE Revenue_Date__c =:previousMonthDate];
        if( countStaffDetails > 0){
            Id lobSplitBatchId =  Database.Executebatch(new HL_RecalculateLOBSplitBatch('SELECT Engagement__c FROM Staffing_Details__c WHERE Revenue_Date__c =:previousMonthDate'));
            System.debug('LOB Split Batch Job Id is: ' + lobSplitBatchId);
        }

    }
 }