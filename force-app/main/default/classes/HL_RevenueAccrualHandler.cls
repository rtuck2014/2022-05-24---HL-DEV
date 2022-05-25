public without sharing class HL_RevenueAccrualHandler {
    private boolean IsExecuting = false;
    private integer BatchSize = 0;

    public HL_RevenueAccrualHandler(boolean executing, integer size){
        IsExecuting = executing;
        BatchSize = size;
    }


    //When creating a new Revenue Accrual record, copy in the prior month's figures
    public void OnBeforeInsert(List<Revenue_Accrual__c> newRevenueAccrualList){
        SetPriorMonthValues(newRevenueAccrualList);
        SetCalculatedValues(newRevenueAccrualList);
        UpdateFRPeriodAccruedFees(newRevenueAccrualList);
    }

    //Manage Revenue Accrual Sharing Rules
    public void OnAfterInsert(Map<Id, Revenue_Accrual__c> newRevenueAccrualMap){
        SL_ManageSharingRules.manageRevAccrualsCounterpartySharingRules(newRevenueAccrualMap.values(), 'Revenue_Accrual__c');
        UpdateCurrentRevAccrual(newRevenueAccrualMap);
        if (SL_Statics.bypassRevenueAccrualTrigger == false) {
            SL_Statics.bypassRevenueAccrualTrigger = true;
            this.UpdateEngagementValues(newRevenueAccrualMap);
        }
    }


    //Update the Total_Accrued_Fees__c value when the Percent_Complete__c value changes
    public void OnBeforeUpdate(Map<Id, Revenue_Accrual__c> newRevenueAccrualMap , Map<Id, Revenue_Accrual__c> oldRevenueAccrualMap){
        this.UpdateRevenueAccrualRecords(newRevenueAccrualMap, oldRevenueAccrualMap);
        this.CallSetCalculatedValues(newRevenueAccrualMap, oldRevenueAccrualMap);
        UpdateFRPeriodAccruedFees(newRevenueAccrualMap);
    }

    //Update Engagement Record Values from Revenue Accrual changes
    public void OnAfterUpdate(Map<Id, Revenue_Accrual__c> newRevenueAccrualMap , Map<Id, Revenue_Accrual__c> oldRevenueAccrualMap){
        if (SL_Statics.bypassRevenueAccrualTrigger == false) {
            SL_Statics.bypassRevenueAccrualTrigger = true;
            this.UpdateEngagementValues(newRevenueAccrualMap);
        }
    }

    //Keep values for matching fields in the Engagement record in sync with the values in the Revenue Accrual record
    private void UpdateEngagementValues(Map<Id, Revenue_Accrual__c> newRevenueAccrualMap){
        List<Engagement__c> engagementUpdateList = new List<Engagement__c>{};
        Set<Id> engagementIdSet = new Set<Id>{};
        Set<Id> engagementIdUpdateSet = new Set<Id>{};
        Map<Id, Engagement__c> engagementMap = new Map<Id, Engagement__c>{};

        for (Revenue_Accrual__c revenueAccrual : newRevenueAccrualMap.values())
            engagementIdSet.add(revenueAccrual.Engagement__c);

        List<Engagement__c> engagementList = [SELECT Current_Revenue_Accrual__c, Line_of_Business__c, Period_Accrued_Fees__c, Total_Estimated_Fee__c
                                              FROM Engagement__c
                                              WHERE Id IN :engagementIdSet];
        if (engagementList.size() > 0) {
            for (Engagement__c engagement : engagementList) {
                engagementMap.put(engagement.Id, engagement);
            }
            for (Revenue_Accrual__c revenueAccrual : newRevenueAccrualMap.values()) {
                Engagement__c engage = engagementMap.get(revenueAccrual.Engagement__c);
                if (engage != null && engage.Current_Revenue_Accrual__c == revenueAccrual.Id) {
                    if(!engagementIdUpdateSet.contains(engage.Id))
                    {
                        if (engage.Line_of_Business__c == 'FVA') {
                            engage.Total_Estimated_Fee__c = revenueAccrual.Total_Estimated_Fee__c;
                        } else if (engage.Line_of_Business__c == 'FR') {
                            engage.Period_Accrued_Fees__c = IfNull(revenueAccrual.Actual_Transaction_Fee__c, 0) + IfNull(revenueAccrual.Actual_Monthly_Fee__c, 0);
                            engage.Actual_Transaction_Fee__c = IfNull(revenueAccrual.Actual_Transaction_Fee__c, 0);
                            engage.Actual_Monthly_Fee__c = IfNull(revenueAccrual.Actual_Monthly_Fee__c, 0);
                        } else {
                            engage.Period_Accrued_Fees__c = revenueAccrual.Period_Accrued_Fees__c;
                        }
                        engagementUpdateList.add(engage);
                        engagementIdUpdateSet.add(engage.Id);
                    }
                }
            }
            if (engagementUpdateList.size() > 0) {
                SL_Statics.bypassEngagementTrigger = true;
                update engagementUpdateList;
            }
        }
    }

    private void UpdateFRPeriodAccruedFees(List<Revenue_Accrual__c> newRevenueAccrualList) {
        for(Revenue_Accrual__c objRevenueAccrual : newRevenueAccrualList){
            CalculateFRRevenueAccruedFeed(objRevenueAccrual);
        }
    }

    private void UpdateFRPeriodAccruedFees(Map<Id, Revenue_Accrual__c> newRevenueAccrualMap) {
        for(Revenue_Accrual__c objRevenueAccrual : newRevenueAccrualMap.values()){
            CalculateFRRevenueAccruedFeed(objRevenueAccrual);
        }
    }

    private void CalculateFRRevenueAccruedFeed(Revenue_Accrual__c ra) {
        if (ra.Line_of_Business__c == 'FR') {
            ra.Period_Accrued_Fees__c = IfNull(ra.Actual_Transaction_Fee__c, 0) + IfNull(ra.Actual_Monthly_Fee__c, 0);
        }
    }

    //Update the Total_Accrued_Fees__c and Period_Accrued_Fees__c values (FVA jobs)
    //Update the Total_Accrued_Fees__c and Total_Estimated_Fee__c values (non-FVA jobs)
    private void UpdateRevenueAccrualRecords(Map<Id, Revenue_Accrual__c> newRevenueAccrualMap, Map<Id, Revenue_Accrual__c> oldRevenueAccrualMap){
        // Get RecordType Ids for Revenue_Accrual__c records
        Id FVARecordTypeId;
        List<RecordType> recordTypeList = [SELECT DeveloperName
                                           FROM RecordType
                                           WHERE SobjectType = 'Revenue_Accrual__c' AND DeveloperName = 'FAS_Revenue_Accrual'];
        if (recordTypeList.size() > 0) {
            FVARecordTypeId = recordTypeList[0].Id;
        }
        for(Revenue_Accrual__c objRevenueAccrual : newRevenueAccrualMap.values()){
            if (objRevenueAccrual.RecordTypeId == FVARecordTypeId) {
                // FVA jobs - Calculate Period Accrual Fees based upon Total Estimated Fee
                objRevenueAccrual.Total_Accrued_Fees__c = IfNull(objRevenueAccrual.Total_Estimated_Fee__c,0) * IfNull(objRevenueAccrual.Percent_Complete__c,0) / 100;
                objRevenueAccrual.Period_Accrued_Fees__c = IfNull(objRevenueAccrual.Total_Accrued_Fees__c,0) - IfNull(objRevenueAccrual.Prior_Total_Accrued_Fees__c,0);
            } else {
                // Non-FVA jobs - Calculate Total Estimated Fee based upon Period Accrual Fees
                objRevenueAccrual.Total_Accrued_Fees__c = IfNull(objRevenueAccrual.Prior_Total_Accrued_Fees__c,0) + IfNull(objRevenueAccrual.Period_Accrued_Fees__c,0);
                if (IfNull(objRevenueAccrual.Percent_Complete__c,0)>0) {
                    objRevenueAccrual.Total_Estimated_Fee__c = (IfNull(objRevenueAccrual.Total_Accrued_Fees__c,0) / IfNull(objRevenueAccrual.Percent_Complete__c,0)) * 100;
                } else {
                    objRevenueAccrual.Total_Estimated_Fee__c = 0;
                }
            }
        }
    }

    /*Updates the current revenue accrual field on Engagement__c*/
    private static List<Engagement__c> UpdateCurrentRevAccrual(Map<Id, Revenue_Accrual__c> revenueAccrualMap){
        List<Engagement__c> engagementUpdateList = new List<Engagement__c>();

        for(Revenue_Accrual__c ra : revenueAccrualMap.values()){
            Engagement__c e = new Engagement__c(Id = ra.Engagement__c, Current_Revenue_Accrual__c = ra.Id);

            if (ra.Line_of_Business__c != 'FVA') {
                // Calculate Total Estimated Fee based upon Period Accrual Fees
                e.Total_Accrued_Fees__c = IfNull(ra.Prior_Total_Accrued_Fees__c,0) + IfNull(ra.Period_Accrued_Fees__c,0);
                if (IfNull(ra.Percent_Complete__c,0)>0)
                    e.Total_Estimated_Fee__c = (IfNull(e.Total_Accrued_Fees__c,0) / IfNull(ra.Percent_Complete__c,0)) * 100;
                else
                    e.Total_Estimated_Fee__c = 0;
            }
            engagementUpdateList.add(e);
        }

        if(!engagementUpdateList.isEmpty())
        {
            SL_Statics.bypassEngagementTrigger = true;
            update engagementUpdateList;
        }

        return engagementUpdateList;
    }

    /*Calculate fields in the Current Revenue Accrual record*/
    private void CallSetCalculatedValues(Map<Id, Revenue_Accrual__c> newRevenueAccrualMap , Map<Id, Revenue_Accrual__c> oldRevenueAccrualMap){
        SetCalculatedValues(newRevenueAccrualMap.values());
    }

    /*Calculate fields in the Current Revenue Accrual record*/
    private void SetCalculatedValues(List<Revenue_Accrual__c> newRevenueAccrualList){
        Set<Id> engagementIdSet = new Set<Id>{};
        Engagement__c currEngagement;

        for (Revenue_Accrual__c revenueAccrual : newRevenueAccrualList)
            engagementIdSet.add(revenueAccrual.Engagement__c);

        List<Engagement__c> engagementList = [SELECT Name, Exclude_From_Reversal__c
                                              FROM Engagement__c
                                              WHERE Id IN :engagementIdSet];
        if (engagementList.size() > 0) {
            Map<Id, Engagement__c> engagementMap = new Map<Id, Engagement__c>{};
                for (Engagement__c engagement : engagementList) {
                    engagementMap.put(engagement.Id, engagement);
                }
            if (engagementList.size() > 0) {
                for (Revenue_Accrual__c revenueAccrual : newRevenueAccrualList) {
                    // Get Engagement record
                    currEngagement = engagementMap.get(revenueAccrual.Engagement__c);
                    if (currEngagement != null) {
                        //TBD: Delete - Not sure why this is needed
                        try {
                            if(IsCurrentFY(Integer.valueOf(revenueAccrual.Month__c), Integer.valueOf(revenueAccrual.Year__c)))
                                revenueAccrual.Current_YTD_Accrued_Fees_USD__c = revenueAccrual.YTD_Accrued_Fees_USD__c;
                        }
                        catch(Exception ex){}

                    }
                }
            }
        }
    }

    /*Get the Prior Month figures and copy to the appropriate fields on the new records*/
    private void SetPriorMonthValues(List<Revenue_Accrual__c> newRevenueAccrualList){
        Boolean firstEngagementRecordSet;
        Integer i, k;
        String engagementId, month, year;
        Set<Id> engagementIdSet = getEngagementIds(newRevenueAccrualList);
        Map<Id, Revenue_Accrual__c> revenueAccrualsByEngagementIdMap = new Map<Id, Revenue_Accrual__c>();
        Revenue_Accrual__c ra, priorRevenueAccrual;
        List<Revenue_Accrual__c> revenueAccrualsList = [SELECT Engagement__c
                                                        ,External_Id__c
                                                        ,Percent_Complete__c
                                                        ,Month__c, Year__c
                                                        ,Period_Accrued_Fees__c
                                                        ,Total_Accrued_Fees__c
                                                        ,Total_Estimated_Fee__c
                                                        ,LTD_Accrued_Fees_USD__c
                                                        ,YTD_Accrued_Fees_USD__c
                                                        ,Prior_LTD_Accrued_Fees_USD__c
                                                        ,Prior_YTD_Accrued_Fees_USD__c
                                                        ,Period_JE_Net_Old_Method__c
                                                        ,Period_Subsequent_Accruals__c
                                                        ,Carried_Over_Accrual__c                                                        
                                                        ,Prior_Carried_Over_Accrual__c
                                                        FROM Revenue_Accrual__c
                                                        WHERE Engagement__c IN :engagementIdSet
                                                        ORDER BY Year__c DESC, Month__c DESC];

        //Populate the values coming from the Engagement Record
        setDefaultValues(newRevenueAccrualList);

        if (revenueAccrualsList.size() > 0) {
            engagementId = revenueAccrualsList[0].Engagement__c;
            for (i=0; i<revenueAccrualsList.size(); i++) {
                firstEngagementRecordSet = false;
                for (k=i; k<revenueAccrualsList.size(); k++) {
                    ra = revenueAccrualsList[k];
                    engagementId = ra.Engagement__c;
                    if (ra.Engagement__c == engagementId) {
                        if (firstEngagementRecordSet == false) {
                            revenueAccrualsByEngagementIdMap.put(ra.Engagement__c, ra);
                            firstEngagementRecordSet = true;
                        }
                    } else {
                        break;
                    }
                }
                i=k;
            }
        }

        for(Revenue_Accrual__c objRevenueAccrual : newRevenueAccrualList){
            priorRevenueAccrual = revenueAccrualsByEngagementIdMap.get(objRevenueAccrual.Engagement__c);

            if (priorRevenueAccrual != null) {
                objRevenueAccrual.Prior_Accrued_Fees__c = priorRevenueAccrual.Period_Accrued_Fees__c;
                objRevenueAccrual.Prior_Month__c = priorRevenueAccrual.Month__c;
                objRevenueAccrual.Prior_Percent_Complete__c = priorRevenueAccrual.Percent_Complete__c;
                objRevenueAccrual.Prior_Total_Accrued_Fees__c = priorRevenueAccrual.Total_Accrued_Fees__c;
                objRevenueAccrual.Prior_Total_Estimated_Fees__c = priorRevenueAccrual.Total_Estimated_Fee__c;
                objRevenueAccrual.Percent_Complete__c = priorRevenueAccrual.Percent_Complete__c;
                objRevenueAccrual.Prior_Year__c = priorRevenueAccrual.Year__c;
                objRevenueAccrual.Total_Accrued_Fees__c = priorRevenueAccrual.Total_Accrued_Fees__c;
                objRevenueAccrual.Prior_YTD_Accrued_Fees_USD__c = objRevenueAccrual.Month__c == '04' ? 0 : priorRevenueAccrual.YTD_Accrued_Fees_USD__c;
                objRevenueAccrual.Prior_LTD_Accrued_Fees_USD__c = priorRevenueAccrual.LTD_Accrued_Fees_USD__c;
                objRevenueAccrual.Prior_Carried_Over_Accrual__c = IfNull(priorRevenueAccrual.Percent_Complete__c,0) == 100 ? 0 : IfNull(priorRevenueAccrual.Carried_Over_Accrual__c,0) + IfNull(priorRevenueAccrual.Prior_Carried_Over_Accrual__c,0);
            }
        }
    }

    private Set<Id> GetEngagementIds(List<Revenue_Accrual__c> raList){
        Set<Id> revenueAccrualIdSet = new Set<Id>{};
        for (Revenue_Accrual__c ra : raList)
            revenueAccrualIdSet.add(ra.Engagement__c);
        return revenueAccrualIdSet;
    }

    //Sets the default values from Monthly Revenue Process Control and Related Engagement Records
    //Record Type is also kept here in case records are created apart from the screen
    private void SetDefaultValues(List<Revenue_Accrual__c> revenueAccrualsList){
        Set<Id> engagementIdSet = getEngagementIds(revenueAccrualsList);
        Map<Id, Engagement__c> engagementMap = new Map<Id, Engagement__c>([SELECT Name, Current_Revenue_Accrual__c
                                                                           ,CurrencyIsoCode
                                                                           ,Job_Type__c
                                                                           ,Line_of_Business__c
                                                                           ,Percentage_of_Completion__c
                                                                           ,Primary_Office__c
                                                                           ,Total_Estimated_Fee__c
                                                                           ,Exclude_From_Reversal__c
                                                                           FROM Engagement__c
                                                                           WHERE Id IN :engagementIdSet]);
        Engagement__c e;
        String lob,FVARecordTypeId, CFRecordTypeId, FRRecordTypeId, SCRecordTypeId;
        List<RecordType> recordTypeList = [SELECT DeveloperName
                                           FROM RecordType
                                           WHERE SobjectType = 'Revenue_Accrual__c'];
        List<Monthly_Revenue_Process_Control__c> mrpcList = [SELECT Current_Month__c, Current_Year__c
                                                             FROM Monthly_Revenue_Process_Control__c
                                                             WHERE IsCurrent__c = true];
        Monthly_Revenue_Process_Control__c mrpc;

        if(mrpcList.size() == 0)
            throw new applicationException('No Current Monthly Revenue Process Control');

        mrpc = mrpcList[0];

        if (recordTypeList.size() > 0) {
            for (RecordType rtype : recordTypeList) {
                if (rtype.DeveloperName == 'FAS_Revenue_Accrual')
                    FVARecordTypeId = rtype.Id;
                else if (rtype.DeveloperName == 'CF_Revenue_Accrual')
                    CFRecordTypeId = rtype.Id;
                else if (rtype.DeveloperName == 'FR_Revenue_Accrual')
                    FRRecordTypeId = rtype.Id;
                else if (rtype.DeveloperName == 'SC_Revenue_Accrual')
                    SCRecordTypeId = rtype.Id;
            }
        }

        for(Revenue_Accrual__c ra : revenueAccrualsList){
            e = engagementMap.get(ra.Engagement__c);

            ra.Monthly_Revenue_Process_Control__c = mrpc.Id;
            ra.Month__c = mrpc.Current_Month__c;
            ra.Year__c = mrpc.Current_Year__c;
            string externalid = ra.Engagement__c;
            ra.External_Id__c = externalid.left(15) + '|'+ mrpc.Current_Month__c + '|' + mrpc.Current_Year__c;
            ra.Total_Estimated_Fee__c = e.Total_Estimated_Fee__c;
            ra.Engagement__c = e.Id;
            ra.Percent_Complete__c = e.Percentage_of_Completion__c;
            ra.CurrencyIsoCode = e.CurrencyIsoCode;
            ra.Office__c = e.Primary_Office__c;
            ra.Job_Type__c = e.Job_Type__c;
            ra.Exclude_From_Reversal__c = e.Exclude_From_Reversal__c;

            //Assign the appropriate record type
            lob = e.Line_of_Business__c;
            if (lob == 'FVA')
                ra.RecordTypeId = FVARecordTypeId;
            else if (lob == 'CF')
                ra.RecordTypeId = CFRecordTypeId;
            else if (lob == 'FR')
                ra.RecordTypeId = FRRecordTypeId;
            else if (lob == 'SC')
                ra.RecordTypeId = SCRecordTypeId;
        }
    }
    
    public Boolean CreatePeriodAccruedRecord(Id engagementId, decimal periodAccruedFees, decimal totalEsitmatedFees, string lob) {
        Revenue_Accrual__c revenueAccrual = new Revenue_Accrual__c(Engagement__c = engagementId);
        
        //Set the default values
        SetDefaultValues(new List<Revenue_Accrual__c>{revenueAccrual});
        
        revenueAccrual.Period_Accrued_Fees__c = periodAccruedFees;
        revenueAccrual.Total_Estimated_Fee__c = totalEsitmatedFees;
        revenueAccrual.Line_of_Business__c = lob;
        
        try {
            insert revenueAccrual;
            return true;
        } catch(DmlException e) {
            String errorMsg = e.getMessage();
            
            if(ApexPages.currentPage() != null) {
                if (errorMsg.contains('duplicate value found'))
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The Revenue Accrual record for the current month and year already exists.'));
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Error Creating New Revenue Accrual Record = ' + e.getMessage()));
            }
        }

        return false;
    }
    
    public Boolean CreateFRRecord(Id engagementId, decimal actualMonthlyFees, decimal actualTransactionFees) {
        Revenue_Accrual__c revenueAccrual = new Revenue_Accrual__c(Engagement__c = engagementId);
        
        //Set the default values
        SetDefaultValues(new List<Revenue_Accrual__c>{revenueAccrual});
        
        revenueAccrual.Actual_Monthly_Fee__c = IfNull(actualMonthlyFees, 0);
        revenueAccrual.Actual_Transaction_Fee__c = IfNull(actualTransactionFees, 0);
        revenueAccrual.Period_Accrued_Fees__c = IfNull(actualMonthlyFees, 0) + IfNull(actualTransactionFees, 0);


        try {
            insert revenueAccrual;
            return true;
        } catch(DmlException e) {
            String errorMsg = e.getMessage();

            if(ApexPages.currentPage() != null) {
                if (errorMsg.contains('duplicate value found'))
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The Revenue Accrual record for the current month and year already exists.'));
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Error Creating New Revenue Accrual Record = ' + e.getMessage())); 
            }
        }

        return false;
    }

    private static boolean IsCurrentFY(integer month, integer year){
        return (month < 4 && year == Date.Today().Year() + 1) || (month >= 4 && year == Date.Today().Year());
    }

    private static decimal IfNull(decimal s1,decimal s2) {
        decimal result = s1;
        if (s1 == null) { result = s2; }
        return result;
    }

    public class ApplicationException extends Exception {}
}