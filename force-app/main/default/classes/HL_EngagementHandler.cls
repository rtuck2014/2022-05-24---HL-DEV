/*
* Name: HL_EngagementHandler
* Created Date: 4/14/2015
* Description: Handler class for Engagement records
* Modified Date: 10/31/2019
* Description:  Added the following methods for ERP Integration. The new methods are invoked from OnBeforeInsert, OnBeforeUpdate and OnAfterInsert methods.
*   a) cloneEngagementContracts()
*   b) setContractEndDate()
*   c) updateEngagementDuetoLegalEntityChange()
*   d) updateEngagementVATTreatment()
*   e) setLegalEntityFields()
*   f) clearERPUpdateFlags()
*   g) associateEngagementInternalTeamToNewProject()
*   h) createORMapOppContractOnEng()
*/

public class HL_EngagementHandler {
    public boolean isFirstExecution=true;
    
    private boolean IsExecuting = false;
    private integer BatchSize = 0;
    public boolean IsTriggerContext{get{ return IsExecuting;}}
    public static Boolean IsBeforeInsertFlag = false;
    public static Boolean IsBeforeUpdateFlag = false;
    
    public HL_EngagementHandler(boolean executing, integer size){
        IsExecuting = executing;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(List<Engagement__c> newEngagementList){
        SL_EngagementConversionHelper.PopulateRecordType(newEngagementList);
        
        if(!IsBeforeInsertFlag){
            IsBeforeInsertFlag = true;
            
            UpdateCurrencyRate(newEngagementList);
            UpdateRelatedJobType(newEngagementList);
        }
        OnBeforeUpdateFeeInsert(newEngagementList);
        //Update Legal Entity fields
        setLegalEntityFields(newEngagementList);
    }
    
    public void OnBeforeUpdate(List<Engagement__c> newEngagementList, Map<Id, Engagement__c> newEngagementListMap, List<Engagement__c> oldEngagementList, Map<Id, Engagement__c> oldEngagementListMap){
        
        if(!HL_ConstantsUtil.stopExecuteEstFeeUpdateTrigger) {
            HL_EngagementHandler.OnBeforeUpdateFee(newEngagementList, newEngagementListMap, oldEngagementList, oldEngagementListMap);   
        }   
        if(!IsBeforeUpdateFlag){
            IsBeforeUpdateFlag = true;
            
            List<Engagement__c> currencyRateUpdatengagementList = new List<Engagement__c>();
            List<Engagement__c> jobTypeUpdatengagementList = new List<Engagement__c>();
            map<id, Engagement__c> mapoffilteredEngWithChangedCurrency = new map<Id, Engagement__c>();
            
            for(Engagement__c old : oldEngagementList)
            {
                Engagement__c newEng = ((Engagement__c)newEngagementListMap.get(old.Id));
                
                if(old.CurrencyIsoCode <> newEng.CurrencyIsoCode){
                    currencyRateUpdatengagementList.add(newEng);
                    mapoffilteredEngWithChangedCurrency.put(old.Id,newEng);     
                }
                
                if(old.Job_Type__c <> newEng.Job_Type__c)
                    jobTypeUpdatengagementList.add(newEng);
            }
            
            if(currencyRateUpdatengagementList.size() > 0)
                UpdateCurrencyRate(currencyRateUpdatengagementList);
            UpdateRevenueProjectionCurrencyISO(newEngagementListMap, oldEngagementListMap);
            
            if(jobTypeUpdatengagementList.size() > 0)
                UpdateRelatedJobType(jobTypeUpdatengagementList);
            
            UpdateForComments(newEngagementList);
            if(mapoffilteredEngWithChangedCurrency.keySet() != null && mapoffilteredEngWithChangedCurrency.keySet().size() > 0)     
                UpdateCurrenyofPVfamily(mapoffilteredEngWithChangedCurrency);    
            
            dealTeamMemberWithExecutionRole(newEngagementList,oldEngagementListMap);
            
            //Check changes to fields that needs to be synced with Oracle
            setERPUpdateFlags(oldEngagementList, newEngagementListMap);
            
            //Assign a new engagement number suffix if 'Legal Entity' changes
            if(!HL_ConstantsUtil.stopEngagementLegalEntityChangeTrigger
               && HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Engagement_Legal_Entity_Change))
                updateEngagementDuetoLegalEntityChange();
                
            if(!HL_ConstantsUtil.stopEngagementCurrencyChangeTrigger)
                updateEngagementDuetoCurrencyChange();
            
            //Clear out ERP Status flags is sync is successful
            clearERPUpdateFlags(oldEngagementList, newEngagementListMap);
        }
    }
    
    private void UpdateCurrencyRate(List<Engagement__c> engagementList){
        Map<String,Id> currencyToRateMap = HL_ExchangeRate.GetCurrencyIsoCodeMap();
        
        for(Engagement__c e : engagementList){
            if(currencyToRateMap.get(e.CurrencyIsoCode) <> null)
                e.Exchange_Rate__c = currencyToRateMap.get(e.CurrencyIsoCode);
        }
    }
    
    private void UpdateRelatedJobType(List<Engagement__c> engagementList){
        Map<String, Job_Type__c> jobTypeMap = HL_JobType.GetJobTypeMap();
        
        for(Engagement__c e : engagementList){
            e.Related_Job_Type__c = null;
            e.Has_Multiple_Deliverables__c = false;
            if(!String.isBlank(e.Job_Type__c)){
                Job_Type__c jobType = jobTypeMap.get(e.Job_Type__c);
                if(jobType != null)
                {
                    e.Related_Job_Type__c = jobType.Id;
                    e.Has_Multiple_Deliverables__c = jobType.Has_Multiple_Deliverables__c; 
                    e.Product_Type__c = jobType.Product_Line__c;     
                    e.ERP_Product_Type_Code__c = jobType.Product_Type_Code__c;            
                }
            }
        }
    }
    
    public void OnAfterInsert(Map<Id, Engagement__c> newEngagementMap){
        SL_RelatedOppEgmtHelper.CreateInitialRelatedJoiners(newEngagementMap, 'Engagement_Client_Subject__c');
        //Relate existing opportunity contracts to new engagement  
        createORMapOppContractOnEng(newEngagementMap.Values());
        /*submitClientOnEngagement(newEngagementMap); // client update*/ 
        relatePitchRecords(newEngagementMap.values());
    }
    
    public void OnAfterUpdate(Map<Id, Engagement__c> newEngagementMap, Map<Id, Engagement__c> oldEngagementMap){
        Map<Id, Engagement__c> newToProcessMap = new Map<Id, Engagement__c>();
        Map<Id, Engagement__c> oldToProcessMap = new Map<Id, Engagement__c>();
        Map<Id, Engagement__c> newToProcessLOBMap = new Map<Id, Engagement__c>();
        Map<Id, Engagement__c> newToProcessRevAccRecords = new Map<Id, Engagement__c>();
        Map<Id, Engagement__c> oldToProcessLOBMap = new Map<Id, Engagement__c>();
        List<Id> stageChangeingEngagementId = new List<Id>();
        Set<String> excludedStageSet = new Set<String> {'Dead','Hold','Closed'};
            boolean hasRevenueRelatedChange;
        
        for(Id eID : newEngagementMap.keySet()){
            Engagement__c newE = newEngagementMap.get(eID);
            Engagement__c oldE = oldEngagementMap.get(eID);
            
            hasRevenueRelatedChange = (newE.Stage__c <> oldE.Stage__c && !excludedStageSet.contains(newE.Stage__c))
                || newE.Total_Estimated_Fee__c <> oldE.Total_Estimated_Fee__c || newE.Period_Accrued_Fees__c <> oldE.Period_Accrued_Fees__c
                || newE.Actual_Transaction_Fee__c <> oldE.Actual_Transaction_Fee__c || newE.Actual_Monthly_Fee__c <> oldE.Actual_Monthly_Fee__c
                || newE.Exclude_From_Reversal__c <> oldE.Exclude_From_Reversal__c || newE.Has_Multiple_Deliverables__c <> oldE.Has_Multiple_Deliverables__c || newE.Accrual_Adjustment__c <> oldE.Accrual_Adjustment__c;
            
            if(hasRevenueRelatedChange){
                newToProcessMap.put(eID, newE);
                oldToProcessMap.put(eID, oldE);
            }
            
            if(newE.Line_of_Business__c <> oldE.Line_of_Business__c){
                newToProcessLOBMap.put(eID, newE);
                oldToProcessLOBMap.put(eID, oldE);
            }
            
            if(newE.Job_Type__c != oldE.Job_Type__c || newE.Primary_Office__c != oldE.Primary_Office__c){
                newToProcessRevAccRecords.put(eID, newE);
            }
            
            
            if( newE.Stage__c !=oldE.Stage__c){
                stageChangeingEngagementId.add(newE.Id);
            }
        }
        
        if (SL_Statics.ByPassEngagementTrigger == false) {
            SL_Statics.ByPassEngagementTrigger = true;
            
            //recalculate the percent split - if LOBs changed
            if(newToProcessLOBMap.size() > 0){
                HL_PercentageSplitHandler handler = new HL_PercentageSplitHandler();
                handler.Recalculate(oldToProcessLOBMap, newToProcessLOBMap);
            }
            
            if(!SL_CheckRecursive.SkipOnConvert){
                //creates/deletes related engagement records based on the client and subject fields
                SL_RelatedOppEgmtHelper.UpdateRelatedJoiners(newEngagementMap, oldEngagementMap, 'Engagement_Client_Subject__c');
                UpdateRevenueAccrual(newToProcessMap,oldToProcessMap);
                ManageDNDSharingRule(newEngagementMap,oldEngagementMap);
            }
        }
        else
            SL_Statics.ByPassEngagementTrigger = false;
        
        if(!SL_CheckRecursive.SkipOnConvert)
            UpdateRevenueAccrualLocalCalcs(newToProcessMap,oldToProcessMap);
        
        if(newToProcessRevAccRecords != null && newToProcessRevAccRecords.size() > 0){
            UpdateRelatedRevenueAccruals(newToProcessRevAccRecords);
        }
        
        //Get Engagements whose Legal Entity changed
        if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Engagement_Legal_Entity_Change)){
            Set<Id> engagementIdSet = new Set<Id>();
            for(Engagement__c engagement : newEngagementMap.values()){
                if(engagement.Legal_Entity__c != OldEngagementMap.get(engagement.Id).Legal_Entity__c
                   && engagement.Legal_Entity__c != null){
                       engagementIdSet.add(engagement.Id);
                   }
            } 
            
            //When the Legal Entity of an engagement changes, perform the following:
            // a) Update related engagement VAT Treatments
            // b) Update the 'End Date' of related contracts
            // c) Clone related contracts with new 'Contract Suffix Number'
            if(engagementIdSet.size() > 0){
                updateEngagementVATTreatment(engagementIdSet);
                associateEngagementInternalTeamToNewProject(engagementIdSet);
                if(!HL_ConstantsUtil.stopEngagementContractChangeTrigger){
                    setContractEndDate(engagementIdSet);
                    cloneEngagementContracts(engagementIdSet);
                }
            }
        }
        
        
        
        if(!stageChangeingEngagementId.isEmpty()){
            list<Contract__c> updateStatus = new List<contract__c>();
            List<Contract__c> contractRec = new List< Contract__c > ([Select id, Status__c,Engagement__r.Status__c  from Contract__C where Engagement__c in:stageChangeingEngagementId]);
            for(Contract__c inx : contractRec){
                if(inx.Status__c!=inx.Engagement__r.Status__c){
                    inx.Status__c = inx.Engagement__r.Status__c;
                    updateStatus.add(inx);
                }
            }
            if(!updateStatus.isEmpty()){
                update updateStatus;
            }
        }
    }    
    
    //Update the Period_Accrued_Fees__c values (FVA jobs) Update the Total_Estimated_Fee__c values (non-FVA jobs)
    private void UpdateRevenueAccrualLocalCalcs(Map<Id, Engagement__c> engagementMap, Map<Id, Engagement__c> oldEngagementMap){
        List<Engagement__c> engagementUpdateList = new List<Engagement__c>();
        
        for(Engagement__c objEngagement : engagementMap.values()){
            Engagement__c engage = new Engagement__c(id=objEngagement.id);
            if (objEngagement.Line_of_Business__c == 'FVA') {
                // FVA - Calculate Period Accrual Fees based upon Total Estimated Fee
                engage.Total_Accrued_Fees__c = IfNull(objEngagement.Total_Estimated_Fee__c,0) * IfNull(objEngagement.Percentage_of_Completion__c,0) / 100;
                engage.Period_Accrued_Fees__c = IfNull(engage.Total_Accrued_Fees__c,0) - IfNull(objEngagement.Prior_Total_Accrued_Fees__c,0);
                engage.Line_of_Business__c = objEngagement.Line_of_Business__c;
                engagementUpdateList.add(engage);
            }
            else if (objEngagement.Line_of_Business__c == 'FR') {
                // FR - Sync Period Accrued Fees with the Sum of Actual Monthly and Actual Transaction
                engage.Line_of_Business__c = objEngagement.Line_of_Business__c;
                if (IfNull(objEngagement.Actual_Monthly_Fee__c, 0) != 0 || IfNull(objEngagement.Actual_Transaction_Fee__c, 0) != 0) {
                    engage.Period_Accrued_Fees__c = IfNull(objEngagement.Actual_Monthly_Fee__c, 0) + IfNull(objEngagement.Actual_Transaction_Fee__c, 0);
                }
                else {
                    engage.Period_Accrued_Fees__c  = 0;
                }
                engage.Total_Accrued_Fees__c = IfNull(objEngagement.Prior_Total_Accrued_Fees__c,0) + IfNull(objEngagement.Period_Accrued_Fees__c,0);
                engagementUpdateList.add(engage);
            }
            else {                
                // Non-FVA - Calculate Total Estimated Fee based upon Period Accrual Fees                
                engage.Total_Accrued_Fees__c = IfNull(objEngagement.Prior_Total_Accrued_Fees__c,0) + IfNull(objEngagement.Period_Accrued_Fees__c,0);
                if (IfNull(objEngagement.Percentage_of_Completion__c,0)>0) {
                    engage.Total_Estimated_Fee__c = (IfNull(engage.Total_Accrued_Fees__c,0) / IfNull(objEngagement.Percentage_of_Completion__c,0)) * 100;
                } else {
                    engage.Total_Estimated_Fee__c = 0;
                }
                engagementUpdateList.add(engage);
            }
        }
        
        if (engagementUpdateList.size() > 0) {
            SL_Statics.bypassEngagementTrigger = true;
            update engagementUpdateList;
        }
    }
    
    //This function will be called after update of the Engagement__c Records.
    private void ManageDNDSharingRule(Map<Id, Engagement__c> newEngagementMap, Map<Id, Engagement__c> oldEngagementMap)
    {
        Set<String> parentIdSet = new Set<String>();//set of engagement id
        
        //Iterating over Engagement__c to get only those engagement id whose name is updated.
        for(Engagement__c objEngagement : newEngagementMap.values())
        {
            if(objEngagement.Name != oldEngagementMap.get(objEngagement.Id).Name
               && (oldEngagementMap.get(objEngagement.Id).Name.startsWithIgnoreCase('DND')) || objEngagement.Name.startsWithIgnoreCase('DND'))
            {
                parentIdSet.add(objEngagement.Id);
            }
        }
        
        for(Engagement_Counterparty__c objEC : [SELECT Id FROM Engagement_Counterparty__c WHERE Engagement__c IN : parentIdSet])
            parentIdSet.add(objEC.Id);
        
        
        for(Revenue_Accrual__c objEC : [SELECT Id FROM Revenue_Accrual__c WHERE Engagement__c IN : parentIdSet])
            parentIdSet.add(objEC.Id);
        
        //Calling the method to create the sharing rule according to the Engagement__c names
        if(!parentIdSet.isEmpty())
            SL_ManageSharingRules.DeleteSharesOnChangeParentName(parentIdSet, 'Engagement__c');
    }
    
    private void UpdateRevenueAccrual(Map<Id, Engagement__c> newEngagementMap, Map<Id, Engagement__c> oldEngagementMap){
        Id revenueAccrualId;
        Revenue_Accrual__c ra;
        Boolean createRevenueAccrual = false;
        Boolean updateRevenueAccrual = false; 
        Boolean updatePercentComplete = false; 
        Boolean updateTotalEstimatedFee = false; 
        Boolean updateTouch = false;
        Boolean updateExcludeFromReversal = false;
        Boolean updateHasMutipleDeliverables = false;
        Boolean updateAccrualAdjustment = false;
        Boolean updatePeriodAccruedFees = false; 
        Set<Id> engagementIdSet = new Set<Id>();
        
        List<Revenue_Accrual__c> revenueAccrualUpdateList = new List<Revenue_Accrual__c>();
        Map<String, Revenue_Accrual__c> revenueAccrualListByExtIdMap = new Map<String, Revenue_Accrual__c>();
        
        String externalId;
        String currentMonth;
        String currentYear;
        String currentMonthAndYear;
        
        List<Monthly_Revenue_Process_Control__c> mrpcList = [SELECT Current_Month__c, Current_Year__c, Current_Month_and_Year__c
                                                             FROM Monthly_Revenue_Process_Control__c
                                                             WHERE IsCurrent__c = true];
        if (mrpcList.size() > 0 ) {
            currentMonth = mrpcList[0].Current_Month__c;
            currentYear = mrpcList[0].Current_Year__c;
            currentMonthAndYear = mrpcList[0].Current_Month_and_Year__c;
            
            for(Engagement__c objEngagement : newEngagementMap.values()) {
                engagementIdSet.add(objEngagement.Id);
            }
            
            List<Revenue_Accrual__c> revenueAccrualList = [SELECT External_Id__c, Percent_Complete__c, Total_Estimated_Fee__c, Period_Accrued_Fees__c, Touch__c, Exclude_From_Reversal__c, Has_Multiple_Deliverables__c, Accrual_Adjustment__c
                                                           FROM Revenue_Accrual__c
                                                           WHERE Month__c = :currentMonth AND Year__c = :currentYear
                                                           AND Engagement__c IN :engagementIdSet];
            
            for (Revenue_Accrual__c revAcc : revenueAccrualList) {
                revenueAccrualListByExtIdMap.put(revAcc.External_Id__c, revAcc);
            }
            
            for(Engagement__c objEngagement : newEngagementMap.values()){
                // Locate current Revenue_Accrual__c record for this Engagement
                externalId = objEngagement.Id;
                externalId = externalId.left(15)+'|'+currentMonthAndYear;
                
                if (revenueAccrualListByExtIdMap.get(externalId) == null && newEngagementMap.values().size() == 1) {
                    // Set flag to create Revenue_Accrual__c record
                    createRevenueAccrual = true;
                } else {
                    createRevenueAccrual = false;
                }
                
                if (objEngagement.Line_of_Business__c == 'FVA') {
                    // FVA line of business
                    // Check if Percentage of Completion or Stage changed
                    if ((objEngagement.Percentage_of_Completion__c != oldEngagementMap.get(objEngagement.Id).Percentage_of_Completion__c) || (objEngagement.Stage__c != oldEngagementMap.get(objEngagement.Id).Stage__c)) {
                        updateRevenueAccrual = true;
                        updatePercentComplete = true;
                    }
                    // Check if Total Estimated Fee changed
                    if (objEngagement.Total_Estimated_Fee__c != oldEngagementMap.get(objEngagement.Id).Total_Estimated_Fee__c) {
                        updateRevenueAccrual = true;
                        updateTotalEstimatedFee = true;
                    }
                }
                
                if (objEngagement.Line_of_Business__c != 'FVA' && objEngagement.Line_of_Business__c != 'FR' && objEngagement.Period_Accrued_Fees__c != oldEngagementMap.get(objEngagement.Id).Period_Accrued_Fees__c) {
                    // Non-FVA/FR line of business
                    // Check if Period Accrual Fees changed
                    updateRevenueAccrual = true;
                    updatePeriodAccruedFees = true;
                }
                
                if (objEngagement.Line_of_Business__c == 'FR' && (IfNull(objEngagement.Actual_Monthly_Fee__c, 0) != IfNull(oldEngagementMap.get(objEngagement.Id).Actual_Monthly_Fee__c, 0) ||
                                                                  IfNull(objEngagement.Actual_Transaction_Fee__c, 0) != IfNull(oldEngagementMap.get(objEngagement.Id).Actual_Transaction_Fee__c, 0))) {
                                                                      updateRevenueAccrual = true;
                                                                      updatePeriodAccruedFees = true;
                                                                      
                                                                  }
                
                // Check if Exclude From Reversal flag changed
                if (objEngagement.Exclude_From_Reversal__c != oldEngagementMap.get(objEngagement.Id).Exclude_From_Reversal__c) {
                    updateRevenueAccrual = true;
                    updateExcludeFromReversal = true;
                    updateTouch = true;
                }
                
                // Check if Has Multiple Deliverables flag changed
                if (objEngagement.Has_Multiple_Deliverables__c != oldEngagementMap.get(objEngagement.Id).Has_Multiple_Deliverables__c) {
                    updateRevenueAccrual = true;
                    updateHasMutipleDeliverables = true;
                    updateTouch = true;
                }
                
                // Check if Accrual Adjustment changed
                if (objEngagement.Accrual_Adjustment__c != oldEngagementMap.get(objEngagement.Id).Accrual_Adjustment__c) {
                    updateRevenueAccrual = true;
                    updateAccrualAdjustment = true;
                    updateTouch = true;
                }
                
                if (updateRevenueAccrual) {
                    if (createRevenueAccrual) {
                        SL_Statics.ByPassRevenueAccrualTrigger = true;
                        HL_RevenueAccrualHandler raHandler = new HL_RevenueAccrualHandler(false,1);
                        boolean created = false;
                        if (objEngagement.Line_of_Business__c == 'FR') {
                            //FR Period Accrued Fees must be calculated by Actual Transaction Fee + Actual Monthly Fee
                            created = raHandler.CreateFRRecord(objEngagement.Id, IfNull(objEngagement.Actual_Monthly_Fee__c, 0), IfNull(objEngagement.Actual_Transaction_Fee__c, 0));
                        }
                        else {
                            //Revenue Accrual must be created with Period Accrued Fees to avoid a race condition on the bi-directional trigger update
                            created = raHandler.CreatePeriodAccruedRecord(objEngagement.Id, objEngagement.Period_Accrued_Fees__c, objEngagement.Total_Estimated_Fee__c, objEngagement.Line_of_Business__c);                            
                        }
                        
                        if(created) {
                            List<Revenue_Accrual__c>  newrevenueAccrualList = [SELECT External_Id__c
                                                                               ,Percent_Complete__c
                                                                               ,Total_Estimated_Fee__c
                                                                               ,Period_Accrued_Fees__c
                                                                               ,Actual_Monthly_Fee__c
                                                                               ,Touch__c
                                                                               ,Exclude_From_Reversal__c 
                                                                               ,Has_Multiple_Deliverables__c
                                                                               ,Accrual_Adjustment__c
                                                                               FROM Revenue_Accrual__c 
                                                                               WHERE External_Id__c = :externalId];
                            if (newrevenueAccrualList.size() > 0) {
                                ra = newrevenueAccrualList[0];
                                revenueAccrualListByExtIdMap.put(ra.External_Id__c, ra);
                                
                            } else {
                                updatePercentComplete = false;
                                updateTotalEstimatedFee = false;
                                updatePeriodAccruedFees = false;
                                updateTouch = false;
                                updateExcludeFromReversal = false;
                                updateHasMutipleDeliverables = false;
                                updateAccrualAdjustment = false;
                            }
                        } else {
                            updatePercentComplete = false;
                            updateTotalEstimatedFee = false;
                            updatePeriodAccruedFees = false;
                            updateTouch = false;
                            updateExcludeFromReversal = false;
                            updateHasMutipleDeliverables = false;
                            updateAccrualAdjustment = false;
                        }
                    } else {
                        ra = revenueAccrualListByExtIdMap.get(externalId);
                        
                        if (ra == null) {
                            updatePercentComplete = false;
                            updateTotalEstimatedFee = false;
                            updatePeriodAccruedFees = false;
                            updateTouch = false;
                            updateExcludeFromReversal = false;
                            updateHasMutipleDeliverables = false;
                            updateAccrualAdjustment = false;
                        }
                    }
                    if (updatePercentComplete || updateTotalEstimatedFee || updatePeriodAccruedFees) {
                        ra.Percent_Complete__c = objEngagement.BACKEND_Percentage_of_Completion__c;
                    }
                    if (updateTotalEstimatedFee || updatePercentComplete) {
                        ra.Total_Estimated_Fee__c = objEngagement.Total_Estimated_Fee__c;
                    }
                    if (updateTouch) {
                        ra.Touch__c = DateTime.Now();
                    }
                    if (updateExcludeFromReversal) {
                        ra.Exclude_From_Reversal__c = objEngagement.Exclude_From_Reversal__c;
                    }
                    if (updateHasMutipleDeliverables) {
                        ra.Has_Multiple_Deliverables__c = objEngagement.Has_Multiple_Deliverables__c;
                    }
                    if (updateAccrualAdjustment) {
                        ra.Accrual_Adjustment__c = objEngagement.Accrual_Adjustment__c;
                    }
                    if (objEngagement.Line_of_Business__c != 'FR' && (updatePeriodAccruedFees || updateTotalEstimatedFee)) {
                        ra.Period_Accrued_Fees__c = objEngagement.Period_Accrued_Fees__c;
                    }   
                    if (objEngagement.Line_of_Business__c != 'FR' && (updatePercentComplete || updateTotalEstimatedFee || updateTouch || updatePeriodAccruedFees)) {
                        revenueAccrualUpdateList.add(ra);
                    }else if (objEngagement.Line_of_Business__c == 'FR' && (updatePeriodAccruedFees || updateTouch)) {
                        if (updatePeriodAccruedFees) { 
                            ra.Actual_Transaction_Fee__c = IfNull(objEngagement.Actual_Transaction_Fee__c, 0);
                            ra.Actual_Monthly_Fee__c = IfNull(objEngagement.Actual_Monthly_Fee__c, 0);
                            ra.Period_Accrued_Fees__c = IfNull(objEngagement.Actual_Monthly_Fee__c, 0) + IfNull(objEngagement.Actual_Transaction_Fee__c, 0);
                        }
                        revenueAccrualUpdateList.add(ra);
                    }
                }
            }
            
            if (revenueAccrualUpdateList.size() > 0) {
                SL_Statics.ByPassRevenueAccrualTrigger = true;
                update revenueAccrualUpdateList;
            }
        }
    }
    
    private void UpdateForComments(List<Engagement__c> newEngagementList){
        List<Engagement_Comment__c> commentList = new List<Engagement_Comment__c>();
        
        for(Engagement__c eng: newEngagementList){
            if(!String.isBlank(eng.Engagement_Comment__c)){
                //If a comment value is found, create a new Engagement_Comments Object
                Engagement_Comment__c engComment = new Engagement_Comment__c();
                engComment.Comment__c = eng.Engagement_Comment__c;
                engComment.Comment_Type__c = 'Internal';
                engComment.Line_of_Business__c = eng.Line_of_Business__c;
                engComment.Engagement__c = eng.Id;
                engComment.CurrencyIsoCode = eng.CurrencyIsoCode;
                commentList.add(engComment);
                FormatLastComment(eng, engComment, true);
                //Remove the value for the new comments field so it is never saved to the object and will be blank the next time Pipeline Manager is displayed
                eng.Engagement_Comment__c = null;
            }
        }
        
        if(commentList.size() > 0){
            HL_TriggerContextUtility.SetFirstRunFalse();
            insert commentList;
        }
    }
    
    public static void FormatLastComment(Engagement__c eng, Engagement_Comment__c ec, Boolean openToAll){
        integer newStartLocation,
            currCommentSize = ec.Comment__c.length(),
            newCommentStartSize;
        string newPartialComment, remainderComment,
            firstName = (ec.CreatedBy == null ? UserInfo.getFirstName() : ec.CreatedBy.FirstName),
            lastName = (ec.CreatedBy == null ? UserInfo.getLastName() : ec.CreatedBy.LastName),
            createdDate = (ec.Opp_Comment_Create_Date__c == null ? (ec.CreatedDate == null ? Date.today() : Date.valueOf(ec.CreatedDate)) : ec.Opp_Comment_Create_Date__c).format();
        
        //If comment was converted from Opp, we need the original creator (same above where we check date)
        if(!String.isBlank(ec.Opp_Comment_Creator__c)){
            string[] nameSplits = ec.Opp_Comment_Creator__c.split(' ');
            if(nameSplits.size() > 1){
                firstName = nameSplits[0];
                lastName = nameSplits[1];
            }
        }
        
        //Handle if first name is null
        String nameLog = (String.isBlank(firstName) ? '' : firstName.subString(0,1)) + lastName;
        
        //Update the last comments field as well (Split into 4 parts so the formula field can display the correct values)
        if(openToAll)
        {
            eng.Last_Engagement_Comment_Part_1__c = '';  //Init fields to make sure they are blank from last usage
            eng.Last_Engagement_Comment_Part_2__c = '';
            eng.Last_Engagement_Comment_Part_3__c = '';
            eng.Last_Engagement_Comment_Part_4__c = '';
            eng.Last_Engagement_Comment_Part_1__c = createdDate + ' - ' + nameLog + ': ';
            
            newCommentStartSize = eng.Last_Engagement_Comment_Part_1__c.length();
            if( currCommentSize + newCommentStartSize <= 255 )
                eng.Last_Engagement_Comment_Part_1__c += ec.Comment__c;
            else
            {
                newPartialComment = ec.Comment__c.substring(0, newCommentStartSize);
                newStartLocation = newPartialComment.length();
                eng.Last_Engagement_Comment_Part_1__c += newPartialComment;
                remainderComment = ec.Comment__c.substring(newStartLocation);
                if( remainderComment.length() <= 255)
                    eng.Last_Engagement_Comment_Part_2__c = remainderComment;
                else
                {
                    newPartialComment = remainderComment.substring(0, 255);
                    eng.Last_Engagement_Comment_Part_2__c = newPartialComment;
                    remainderComment = remainderComment.substring(255);
                    if(remainderComment.length() <= 255)
                        eng.Last_Engagement_Comment_Part_3__c = remainderComment;
                    else
                    {
                        newPartialComment = remainderComment.substring(0, 255);
                        eng.Last_Engagement_Comment_Part_3__c = newPartialComment;
                        remainderComment = remainderComment.substring(255);
                        if(remainderComment.length() <= 255)
                            eng.Last_Engagement_Comment_Part_4__c = remainderComment;
                        else
                            eng.Last_Engagement_Comment_Part_4__c = remainderComment.substring(0, 252) + '...'; //Truncate the reaminder of the comment
                    }
                }
            }
        }
        
        eng.Last_Engagement_Comment_Any_Part_1__c = '';  //Init fields to make sure they are blank from last usage
        eng.Last_Engagement_Comment_Any_Part_2__c = '';
        eng.Last_Engagement_Comment_Any_Part_3__c = '';
        eng.Last_Engagement_Comment_Any_Part_4__c = '';
        eng.Last_Engagement_Comment_Any_Part_1__c = createdDate + ' - ' + nameLog + ': ';
        
        newCommentStartSize = eng.Last_Engagement_Comment_Any_Part_1__c.length();
        if( currCommentSize + newCommentStartSize <= 255 )
            eng.Last_Engagement_Comment_Any_Part_1__c += ec.Comment__c;
        else
        {
            newPartialComment = ec.Comment__c.substring(0, newCommentStartSize);
            newStartLocation = newPartialComment.length();
            eng.Last_Engagement_Comment_Any_Part_1__c += newPartialComment;
            remainderComment = ec.Comment__c.substring(newStartLocation);
            if( remainderComment.length() <= 255)
                eng.Last_Engagement_Comment_Any_Part_2__c = remainderComment;
            else
            {
                newPartialComment = remainderComment.substring(0, 255);
                eng.Last_Engagement_Comment_Any_Part_2__c = newPartialComment;
                remainderComment = remainderComment.substring(255);
                if(remainderComment.length() <= 255)
                    eng.Last_Engagement_Comment_Any_Part_3__c = remainderComment;
                else
                {
                    newPartialComment = remainderComment.substring(0, 255);
                    eng.Last_Engagement_Comment_Any_Part_3__c = newPartialComment;
                    remainderComment = remainderComment.substring(255);
                    if(remainderComment.length() <= 255)
                        eng.Last_Engagement_Comment_Any_Part_4__c = remainderComment;
                    else
                        eng.Last_Engagement_Comment_Any_Part_4__c = remainderComment.substring(0, 252) + '...'; //Truncate the reaminder of the comment
                }
            }
        }
    }
    
    private static decimal IfNull(decimal s1,decimal s2) {
        decimal result = s1;
        if (s1 == null) { result = s2; }
        return result;
    }
    
    // To Update Currency of VP and position to follow currency of parent Engagement     
    private void UpdateCurrenyofPVfamily(map<Id, Engagement__c> mapoffilteredEngWithChangedCurrency) {      
        list<Eng_VP__c> listofVPsToUpdate = new list<Eng_VP__c>();      
        list<Eng_VP_Position__c> listofPositionsToUpdate = new list<Eng_VP_Position__c>();      
        for(Eng_VP__c EngVP : [SELECT CurrencyIsoCode,Fee_Total__c, Engagement__c, (SELECT CurrencyIsoCode,Report_Fee__c, Engagement_VP__r.Engagement__c From Eng_VP_Positions__r ) FROM Eng_VP__c WHERE Engagement__c IN: mapoffilteredEngWithChangedCurrency.keySet()])       
        {       
            if(mapoffilteredEngWithChangedCurrency.containsKey(EngVP.Engagement__c)){       
                EngVP.CurrencyIsoCode = mapoffilteredEngWithChangedCurrency.get(EngVP.Engagement__c).CurrencyIsoCode;       
                EngVP.Fee_Total__c = (EngVP.Fee_Total__c != null)? EngVP.Fee_Total__c*1.00: null;       
            }               
            for(Eng_VP_Position__c position : EngVP.Eng_VP_Positions__r)        
            {       
                if(mapoffilteredEngWithChangedCurrency.containsKey(position.Engagement_VP__r.Engagement__c)){       
                    position.CurrencyIsoCode = mapoffilteredEngWithChangedCurrency.get(position.Engagement_VP__r.Engagement__c).CurrencyIsoCode;        
                    position.Report_Fee__c = (position.Report_Fee__c!= null)? position.Report_Fee__c*1.00: null;        
                }       
            }       
            listofVPsToUpdate.add(EngVP);       
            listofPositionsToUpdate.addAll(EngVP.Eng_VP_Positions__r);      
        }       
        HL_ConstantsUtil.ToStopChangesCurrency = false;       
        if(listofVPsToUpdate != null && listofVPsToUpdate.size() > 0)       
            update listofVPsToUpdate;       
        
        if(listofPositionsToUpdate != null && listofPositionsToUpdate.size() > 0)       
            update listofPositionsToUpdate; 
    }
    
    /* Added By SF-832 */    
    public static void OnBeforeUpdateFee(List<Engagement__c> newEngagementList, Map<Id, Engagement__c> newEngagementListMap, List<Engagement__c> oldEngagementList, Map<Id, Engagement__c> oldEngagementListMap){
        List<Id> EngToProcess = new List <Id>();
        for(Engagement__c newVPengVPNewObj : newEngagementList) {
            //if(newVPengVPNewObj.Line_of_Business__c == 'FVA' && newVPengVPNewObj.Total_Estimated_Fee__c != oldEngagementListMap.get(newVPengVPNewObj.id).Total_Estimated_Fee__c){
            if((newVPengVPNewObj.RecordTypeId  != null && newVPengVPNewObj.RecordTypeId == Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Portfolio Valuation').getRecordTypeId()) && newVPengVPNewObj.Total_Estimated_Fee__c != oldEngagementListMap.get(newVPengVPNewObj.id).Total_Estimated_Fee__c){            
                EngToProcess.add(newVPengVPNewObj.Id);                  
            }
        }
        Map<String, String>strMap = new Map<String, String>();        
        for(Engagement__c engObj : [SELECT id, Total_Estimated_Fee__c, (select id, Total_Fee_Completed__c from Engagement_Portfolio_Valuations__r) 
                                    FROM Engagement__c 
                                    WHERE ID IN : EngToProcess]){
                                        if(engObj.Engagement_Portfolio_Valuations__r.size() == 0) {
                                            newEngagementListMap.get(engObj.id).Total_Estimated_Fee__c = 0.0;               
                                        }
                                        else {
                                            decimal tempTotal = 0.0;
                                            for(Eng_VP__c engVPObj : engObj.Engagement_Portfolio_Valuations__r) {  
                                                if(engVPObj!= null && engVPObj.Total_Fee_Completed__c != null){
                                                    tempTotal += engVPObj.Total_Fee_Completed__c;  
                                                }                   
                                            }    
                                            newEngagementListMap.get(engObj.id).Total_Estimated_Fee__c = tempTotal;                     
                                        }  
                                    }
        
    }
    
    // SF-832 - Populating Estimated fee to 0 because there is no vp created under Engagement.
    public static void OnBeforeUpdateFeeInsert(List<Engagement__c> newEngagementList){     
        for (Engagement__c obj :newEngagementList){
            if (obj.RecordTypeId  != null && obj.RecordTypeId == Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Portfolio Valuation').getRecordTypeId())
                obj.Total_Estimated_Fee__c = 0.0;
        }
    }
    
    public void UpdateRevenueProjectionCurrencyISO(Map<Id,Engagement__c> newEngagementMap, Map<Id,Engagement__c> oldEngagementMap){
        List<Revenue_Projection__c> updateRevenueProjectionList = new List<Revenue_Projection__c>();
        
        List<Revenue_Projection__c> revenueProjectionList = [SELECT CurrencyIsoCode, Projected_Monthly_Fee__c, Projected_Transaction_Fee__c, Total__c, Month__c, Year__c, Engagement__c,
                                                             Engagement__r.Projected_Total_Fee__c, Engagement__r.Projected_Transaction_Fee__c, Engagement__r.Current_Revenue_Projection__c, Engagement__r.Projected_Monthly_Fee__c 
                                                             FROM Revenue_Projection__c WHERE Engagement__c IN : newEngagementMap.keySet() AND Engagement__r.Line_of_Business__c = 'FR'];
        for(Revenue_Projection__c rp : revenueProjectionList){
            if (newEngagementMap.get(rp.Engagement__c).currencyIsoCode != oldEngagementMap.get(rp.Engagement__c).currencyIsoCode) {
                rp.CurrencyIsoCode = newEngagementMap.get(rp.Engagement__c).currencyIsoCode;
                updateRevenueProjectionList.add(rp);
            }   
        }
        
        if (updateRevenueProjectionList.size() > 0) {
            update updateRevenueProjectionList;
        }
    }
    
    // Deactivated Process builder Revenue_Accrual_Engagement_Attributes
    public void UpdateRelatedRevenueAccruals(Map<Id,Engagement__c> newEngagementMap){
        
        List<Revenue_Accrual__c> lstRevenueAccralToUpdate = new List<Revenue_Accrual__c>();
        
        for(Revenue_Accrual__c objRevAcc : [SELECT Id, Job_Type__c, Office__c, Engagement__c FROM Revenue_Accrual__c WHERE Engagement__c in :newEngagementMap.keySet() ]){
            objRevAcc.Job_Type__c = newEngagementMap.get(objRevAcc.Engagement__c).Job_Type__c;
            objRevAcc.Office__c = newEngagementMap.get(objRevAcc.Engagement__c).Primary_Office__c;
            
            lstRevenueAccralToUpdate.add(objRevAcc);
        }
        
        if(lstRevenueAccralToUpdate != null && lstRevenueAccralToUpdate.size() > 0)
            update lstRevenueAccralToUpdate;
    }
    
    // Ticket:- DMND0020667 - Allow Non-CF People staffed on CF Engagements to change the Stage
    private void dealTeamMemberWithExecutionRole(List<Engagement__c> newEngagementList,Map<Id,Engagement__c> oldEngagementMap){
        
        
        map<Id, Engagement__c> engMap = new map<Id,Engagement__c>([Select id,Line_of_Business__c, (SELECT Id,Contact__r.User__c,LOB__c,Role__c FROM Engagement_Teams__r where End_Date__c = null) From Engagement__c Where Id IN : newEngagementList AND Line_of_Business__c != 'FVA']);
        
        Set<Delegate_Public_Group_Member__c> DelegatePublicGroupMemberSet = new Set<Delegate_Public_Group_Member__c>();
        
        List<string> lstFieldstoUpdate = new List<String>();        
        List<Schema.FieldSetMember> fields = Schema.SObjectType.Engagement__c.fieldSets.getMap().get('StageAndRevenueFields').getFields();
        for(Schema.FieldSetMember fieldSetMemberObj : fields){
            lstFieldstoUpdate.add(fieldSetMemberObj.getFieldPath());
        }
        
        
        for(Delegate_Public_Group_Member__c dpgm : [select Delegate__c, Delegate_Public_Group__r.Banker__c  from Delegate_Public_Group_Member__c WHERE  Delegate__c =: userinfo.getUserId()]){
            
            DelegatePublicGroupMemberSet.add(dpgm);
        }
        
        for(Engagement__c newEng : newEngagementList){
            string EngLOB = newEng.Line_of_Business__c;
            
            boolean ExecutionRoleFieldsetBoolean = checkExecutionRoleFieldset(newEng, oldEngagementMap, lstFieldstoUpdate);
            boolean ExecutionRoleBoolean = engMap.containsKey(newEng.Id) ? checkExecutionRole(engMap.get(newEng.Id).Engagement_Teams__r,DelegatePublicGroupMemberSet) : true;
            
            if(ExecutionRoleFieldsetBoolean && !ExecutionRoleBoolean){
                newEng.addError(system.label.HL_ExecutionRoleErrorMsg);
            }
        }
    }
    
    //To check if Stage and Revenue field is updated.
    public static Boolean checkExecutionRoleFieldset(Engagement__c newEngagement,Map<Id,Engagement__c> oldEngagementMap, List<string> lstFieldstoUpdate){
        
        boolean IsRevenueStageFieldUpdated = false;
        
        for(String eachField : lstFieldstoUpdate){
            if(newEngagement.get(eachField) != (oldEngagementMap.get(newEngagement.Id)).get(eachField))
                IsRevenueStageFieldUpdated = true;
        }
        return IsRevenueStageFieldUpdated;
    }
    
    
    // Method to identify if logged in user's role with respect to deal team on Engagement
    public static Boolean checkExecutionRole(List<Engagement_Internal_Team__c> EITList, Set<Delegate_Public_Group_Member__c> DelegatePublicGroupMemberSet){
        
        boolean isHavingExecutionRole = false;
        Set<Id> SetofValidDealTeamMembers = new Set<Id>();
        for (Engagement_Internal_Team__c eit : EITList){
            SetofValidDealTeamMembers.add(eit.Contact__r.User__c);
        }
        
        if(SetofValidDealTeamMembers.contains(userinfo.getUserId())){
            isHavingExecutionRole = true;
        }
        
        //To check for valid Delegate 
        if(!isHavingExecutionRole){
            for(Delegate_Public_Group_Member__c dpgm : DelegatePublicGroupMemberSet){
                if(SetofValidDealTeamMembers.contains(dpgm.Delegate_Public_Group__r.Banker__c)){
                    isHavingExecutionRole = true;
                    break;
                }
            }
        }
        
        if(!isHavingExecutionRole){
            if(UserInfo.getProfileId().substring(0, 15) == system.label.HL_Sys_Admin_ProfId || UserInfo.getProfileId().substring(0, 15) == system.label.HL_CAO_ProfileID){
                isHavingExecutionRole = true;
            }
        }
        return isHavingExecutionRole;
    }
    
    // If 'Legal Entity' changes, update related VAT Treatment records
    public static void updateEngagementVATTreatment(Set<Id> engagementIdSet){
        if(!HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Engagement_Update_VAT_Treatments)){
            return;
        }   
        
        Map<Id,Engagement_VAT_Treatment__c> engagementVATTreatmentMap = new Map<Id,Engagement_VAT_Treatment__c>([SELECT Id, Engagement__c FROM Engagement_VAT_Treatment__c WHERE Engagement__c IN: engagementIdSet]);
        Set<Id> vatTreatmentIdSet = engagementVATTreatmentMap.keySet();
        
        if(vatTreatmentIdSet.size() > 0){
            HL_EngagementVATTreatmentHandler.updateTaxClassificationCode(vatTreatmentIdSet, null, true);
        }
    }
    
    //When the currency of an engagement changes, assign a new engagement suffix number and update Legal Entity fields
    public static void updateEngagementDuetoCurrencyChange(){
        Set<Id> engagementIdSet = new Set<Id>();
        Set<Id> legalEntityIdSet = new Set<Id>();
        Set<Id> contractIdToUpdateSet = new Set<Id>();
        Map<Id, Engagement__c> opportunitySuffixMap = new Map<Id, Engagement__c>();
        Map<Id,Legal_Entity__c> legalEntityMap = New Map<Id,Legal_Entity__c>();
        Map<Id,Engagement__c> OldEngagementMap = (Map<Id,Engagement__c>)Trigger.oldMap;
        
        for(Engagement__c eng : (List<Engagement__c>)trigger.new){
            if(eng.CurrencyIsoCode != OldEngagementMap.get(eng.Id).CurrencyIsoCode){
                //Assign a new engagement number suffix
                //if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Engagement_Assign_Number_Suffix)){
                    if(OldEngagementMap.get(eng.Id).CurrencyIsoCode != null){
                        engagementIdSet.add(eng.Id);
                        String oldChar = eng.Engagement_Number_Suffix__c;
                        if(oldChar == null || oldChar.trim() == ''){
                            eng.Engagement_Number_Suffix__c = 'A';
                        }
                        else{
                            Integer charCode = oldChar.charAt(0);
                            List<Integer> chars = new List<Integer>{charCode+1};
                                eng.Engagement_Number_Suffix__c = String.fromCharArray(chars);
                        }
                        opportunitySuffixMap.put(eng.opportunity__c, eng);
                    }
                //}
            }
        }
        HL_ConstantsUtil.stopEngagementCurrencyChangeTrigger = true;
        
        //Call method to update related Opportunity with new number suffix
        if(opportunitySuffixMap.size() > 0)
            setOpportunityNumberSuffix(opportunitySuffixMap);          
    }
    
    //When the 'Legal Entity' of an engagement changes, assign a new engagement suffix number and update Legal Entity fields
    public static void updateEngagementDuetoLegalEntityChange(){
        Set<Id> engagementIdSet = new Set<Id>();
        Set<Id> legalEntityIdSet = new Set<Id>();
        Set<Id> contractIdToUpdateSet = new Set<Id>();
        Map<Id, Engagement__c> opportunitySuffixMap = new Map<Id, Engagement__c>();
        Map<Id,Legal_Entity__c> legalEntityMap = New Map<Id,Legal_Entity__c>();
        Map<Id,Engagement__c> OldEngagementMap = (Map<Id,Engagement__c>)Trigger.oldMap;
        
        //Retrieve new Legal Entity information
        for(Engagement__c eng : (List<Engagement__c>)trigger.new){
            system.debug('>>>'+eng.Legal_Entity__c+'>>>'+OldEngagementMap.get(eng.Id).Legal_Entity__c);
            if(eng.Legal_Entity__c != OldEngagementMap.get(eng.Id).Legal_Entity__c && eng.Legal_Entity__c != null)
                legalEntityIdSet.add(eng.Legal_Entity__c );
        }
        
        /*
        List<Legal_Entity__c> legalEntityList = [SELECT Id, Name, ERP_Business_Unit__c, ERP_Business_Unit_Id__c, ERP_Entity_Code__c, ERP_Legislation_Code__c, ERP_VAT_Legal_Entity__c,
                                                 ERP_Legal_Entity_Id__c , ERP_Opportunity_Type_Template_number__c, ERP_Event_Type_Template_Number__c, ERP_Ledger_Name__c
                                                 FROM Legal_Entity__c
                                                 WHERE Id IN :legalEntityIdSet];
        */
        List<Legal_Entity__c> legalEntityList = HL_LegalEntity.getLegalEntitiesByIdSet(legalEntityIdSet);

        for(Legal_Entity__c le : legalEntityList){
            legalEntityMap.put(le.Id, le);
        }
        
        for(Engagement__c eng : (List<Engagement__c>)trigger.new){
            if(eng.Legal_Entity__c != OldEngagementMap.get(eng.Id).Legal_Entity__c){
                //Update engagement with new Legal Entity information
                Legal_Entity__c le = legalEntityMap.get(eng.Legal_Entity__c);
                if(le!= null){
                    eng.HL_Entity__c = le.Name;
                    eng.ERP_Template__c =  le.ERP_Opportunity_Type_Template_number__c;
                    eng.ERP_Legal_Entity_Id__c =  le.ERP_Legal_Entity_Id__c;
                    eng.ERP_Business_Unit__c =  le.ERP_Business_Unit__c;
                    eng.ERP_Business_Unit_Id__c =  le.ERP_Business_Unit_Id__c;
                    eng.ERP_Entity_Code__c = le.ERP_Entity_Code__c;
                    eng.ERP_Legislation_Code__c = le.ERP_Legislation_Code__c;
                }
                
                //Assign a new engagement number suffix
                if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Engagement_Assign_Number_Suffix)){
                    if(OldEngagementMap.get(eng.Id).Legal_Entity__c != null){
                        engagementIdSet.add(eng.Id);
                        String oldChar = eng.Engagement_Number_Suffix__c;
                        if(oldChar == null || oldChar.trim() == ''){
                            eng.Engagement_Number_Suffix__c = 'A';
                        }
                        else{
                            Integer charCode = oldChar.charAt(0);
                            List<Integer> chars = new List<Integer>{charCode+1};
                                eng.Engagement_Number_Suffix__c = String.fromCharArray(chars);
                        }
                        opportunitySuffixMap.put(eng.opportunity__c, eng);
                    }
                }
            }
        }
        HL_ConstantsUtil.stopEngagementLegalEntityChangeTrigger = true;
        
        //Call method to update related Opportunity with new number suffix
        if(opportunitySuffixMap.size() > 0)
            setOpportunityNumberSuffix(opportunitySuffixMap);          
    }
    
    //Set Contract End Dates for related Engagements whose Legal Entity changed
    public static void setContractEndDate(Set<Id> engagementIdSet){
        if(!HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Engagement_Clone_Contracts)){
            return;
        }
        
        List<Contract__c> contractList = Database.query('SELECT Id, End_Date__c FROM Contract__c WHERE Engagement__c IN :engagementIdSet AND End_Date__c = NULL');
        if(contractList.size() > 0){
            for(Contract__c contract :contractList){
                contract.End_Date__c = System.today();
            }
            Database.SaveResult[] saveResults =   Database.update(contractList, true);
        }
    }
    
    //Update Opportunity Number Suffix
    public static void setOpportunityNumberSuffix(Map<Id, Engagement__c> opportunitySuffixMap){
        Set<Id> oppIdSet = opportunitySuffixMap.keySet();
        List<Opportunity__c> opportunityList = Database.query('SELECT Id, Legal_Entity__c, Opportunity_Number_Suffix__c FROM Opportunity__c WHERE Id IN :oppIdSet');
        if(opportunityList.size() > 0){
            for(Opportunity__c opp :opportunityList){
                Engagement__c oppEng = opportunitySuffixMap.get(opp.Id);
                if(oppEng != null){
                    opp.Legal_Entity__c = oppEng.Legal_Entity__c;
                    opp.HL_Entity__c = oppEng.HL_Entity__c;
                    opp.ERP_Template__c = oppEng.ERP_Template__c;
                    opp.ERP_Legal_Entity_Id__c = oppEng.ERP_Legal_Entity_Id__c;
                    opp.ERP_Business_Unit__c = oppEng.ERP_Business_Unit__c;
                    opp.ERP_Business_Unit_Id__c = oppEng.ERP_Business_Unit_Id__c;
                    opp.ERP_Entity_Code__c = oppEng.ERP_Entity_Code__c;
                    opp.ERP_Legislation_Code__c = oppEng.ERP_Legislation_Code__c;
                    opp.ERP_ID__c = '';
                    opp.Opportunity_Number_Suffix__c = oppEng.Engagement_Number_Suffix__c;
                    opp.ERP_Submitted_To_Sync__c = System.now();
                }
            }
            HL_ConstantsUtil.stopOpportunityLegalEntityChangeTrigger = true;
            Database.SaveResult[] saveResults = Database.update(opportunityList, true);
            HL_ConstantsUtil.stopOpportunityLegalEntityChangeTrigger = false;
        }
    }
    
    //Relate existing opportunity contracts to new engagement
    public void createORMapOppContractOnEng(List<Engagement__c> newEngagementList){
        Set<Id> oppIds = new Set<Id>();
        List<Contract__c> contToUpdate = new List<Contract__c>();
        for(Engagement__c objEng : newEngagementList){
            if(objEng.Opportunity__c != null && String.isNotBlank(objEng.Opportunity__c)){
                oppIds.add(objEng.Opportunity__c);
            }
        }
        
        if(oppIds !=null && oppIds.size() > 0){
            Map<Id,Opportunity__c> mapOfOpp = new Map<Id,Opportunity__c>([SELECT Id, Name, (SELECT Id,Engagement__c, Bill_To__c, End_Date__c FROM Contract__r  ) FROM Opportunity__c WHERE Id in :oppIds]); 
            
            // check Engagement's Opportunity Contract(Contract type = Engagement) and update the Engagement Id on Contract
            for(Engagement__c objEng : newEngagementList){
                if(mapOfOpp.containsKey(objEng.Opportunity__c)){
                    if(!mapOfOpp.get(objEng.Opportunity__c).Contract__r.isEmpty()){
                        for(Contract__c objCont : mapOfOpp.get(objEng.Opportunity__c).Contract__r){
                            Contract__c objConToUpdate = new Contract__c(Id = objCont.Id);
                            objConToUpdate.Engagement__c = objEng.Id;
                            contToUpdate.add(objConToUpdate);
                        }
                    }
                }
            }
            
            if(contToUpdate.size() > 0)
                update contToUpdate;
        }
    }
    
    //Clone Contracts for related Engagements whose Legal Entity changed
    public static void cloneEngagementContracts(Set<Id> engagementIdSet){
        if(!HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Engagement_Clone_Contracts)){
            return;
        }
        
        Map<Id,Engagement__c> updatedEngagementSuffixMap = New Map<Id,Engagement__c>();        
        String queryFields = '';
        List<Schema.FieldSetMember> fieldSetList = SObjectType.Contract__c.FieldSets.Clone_Fields.getFields();
        List<String> stringList = new List<String>();
        Map<String, Contract__c> uniqueBillToContracts =  New Map<String, Contract__c>();
        
        for(Schema.FieldSetMember fieldSetMember : fieldSetList){
            stringList.add(String.valueOf(fieldSetMember.getSObjectField()));
        }
        queryFields = String.join(stringList,',');
        
        List<Engagement__c> engagementList = [SELECT Id, Engagement_Number_Suffix__c, Legal_Entity__c, ERP_HL_Entity__c,
                                              ERP_Business_Unit_Id__c, ERP_Business_Unit__c, ERP_Entity_Code__c
                                              FROM Engagement__c 
                                              WHERE Id IN:engagementIdSet];
        for(Engagement__c eng : engagementList){
            updatedEngagementSuffixMap.put(eng.Id, eng);
        }
        
        List<Contract__c> contractCloneList = Database.query('SELECT Is_Main_Contract__c,' + queryFields + ' FROM Contract__c WHERE Engagement__c IN : engagementIdSet AND ERP_Contract_Type__c = \'Engagement\' ORDER BY CreatedDate DESC');
        List<Contract__c> contractInsertList = new List<Contract__c>();
        List<Contract__c> contractUpdateList = new List<Contract__c>();
        String contractKey = '';
        
        //Identity unique contracts based on 'Bill TOs'
        for(Contract__c contract :contractCloneList){
            contractKey = contract.Engagement__c + '-' + contract.Bill_To__c;
            if(uniqueBillToContracts.get(contractKey) == null){
                uniqueBillToContracts.put(contractKey, contract);
                if(contract.Is_Main_Contract__c){
                    contract.Is_Main_Contract__c=false;
                    contractUpdateList.add(contract);
                }
            }
        }
        
        for(Contract__c contract :uniqueBillToContracts.values()){
            Contract__c clonedContract = new Contract__c();
            clonedContract = contract.clone(false, true, false, false);
            Engagement__c conEngagement = updatedEngagementSuffixMap.get(contract.Engagement__c);
            if(conEngagement != null){
                clonedContract.Contract_Number_Suffix__c = conEngagement.Engagement_Number_Suffix__c;
                if(conEngagement.Legal_Entity__c != null){
                    clonedContract.ERP_Legal_Entity__c = conEngagement.ERP_HL_Entity__c;
                    clonedContract.ERP_Legal_Entity_Lookup__c = conEngagement.Legal_Entity__c;
                    clonedContract.ERP_Business_Unit_Id__c = conEngagement.ERP_Business_Unit_Id__c;
                    clonedContract.ERP_Business_Unit__c = conEngagement.ERP_Business_Unit__c;
                    clonedContract.HL_Entity__c = conEngagement.ERP_Entity_Code__c;
                    clonedContract.Is_Main_Contract__c=true; 
                }
                contractInsertList.add(clonedContract);
            }
            system.debug('contractInsertList: ' + contractInsertList);
        }        
        
        if(contractInsertList.size() > 0){
            Database.SaveResult[] saveResults = Database.insert(contractInsertList, true);
            ErrorHandlingUtility.handleDatabaseSaveResults(saveResults,'HL_EngagementHandler');
        }
        if(contractUpdateList.size() > 0){
            Database.SaveResult[] saveResults = Database.update(contractUpdateList, true);
            ErrorHandlingUtility.handleDatabaseSaveResults(saveResults,'HL_EngagementHandler');
        }
        HL_ConstantsUtil.stopEngagementContractChangeTrigger = true;
    }            
    
    //After the Engagement Legal Entity changes, assign existing Internal Team members to new Project
    public static void associateEngagementInternalTeamToNewProject(Set<Id> engagementIdSet){
        if(!HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Engagement_Move_Internal_Team_To_Project)){
            return;
        }
        
        List<Engagement_Internal_Team__c> engagementInternalTeamList = [SELECT Id, ERP_ID__c, ERP_Last_Integration_Error_Code__c,
                                                                        ERP_Last_Integration_Error_Description__c, ERP_Last_Integration_Response_Date__c, 
                                                                        ERP_Last_Integration_Status__c, ERP_Project_Id__c, Engagement__r.ERP_Project_Number__c,
                                                                        ERP_Submitted_To_Sync__c
                                                                        FROM Engagement_Internal_Team__c 
                                                                        WHERE ERP_Submitted_To_Sync__c != null 
                                                                        AND End_Date__c = null 
                                                                        AND Engagement__c IN :engagementIdSet];
        List<Engagement_Internal_Team__c> engagementInternalTeamUpdateList = new List<Engagement_Internal_Team__c>();
        
        for(Engagement_Internal_Team__c eit :engagementInternalTeamList){
            eit.ERP_ID__c = null;
            eit.ERP_Last_Integration_Error_Code__c  = null;
            eit.ERP_Last_Integration_Error_Description__c = null;
            eit.ERP_Last_Integration_Response_Date__c = null;
            eit.ERP_Last_Integration_Status__c = null;
            eit.ERP_Submitted_To_Sync__c = system.now();
            engagementInternalTeamUpdateList.add(eit);
        }
        if(engagementInternalTeamUpdateList.size() > 0)
            update engagementInternalTeamUpdateList;
    }
    
    //Set ERP Flags needed to sync records to Oracle
    public static void setERPUpdateFlags(List<Engagement__c> oldEngagementList, Map<Id, Engagement__c> newEngagementMap){
        for(Engagement__c eng : oldEngagementList){
            Engagement__c newEng = newEngagementMap.get(eng.Id);
            if(newEng != null){
                if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Engagement_Set_DFF_Flags)){
                    //Set Update DFF Flag
                    if(eng.Primary_Office__c != newEng.Primary_Office__c
                       || eng.Industry_Group__c != newEng.Industry_Group__c
                       || eng.Sector__c != newEng.Sector__c
                       || eng.Line_of_Business__c != newEng.Line_of_Business__c
                       || eng.Job_Type__c != newEng.Job_Type__c
                       || eng.Client_Ownership__c != newEng.Client_Ownership__c
                       || eng.Product_Type__c != newEng.Product_Type__c
                       || eng.CurrencyIsoCode!=newEng.CurrencyIsoCode
                       || eng.Legal_Entity__c !=newEng.Legal_Entity__c){
                          newEng.ERP_Update_DFF__c = true;
                       }
                }
            }
        }
    }
    
    //Set Legal Entity Fields for new records
    public static void setLegalEntityFields (List<Engagement__c> newEngagementList){
        Set<Id> legalEntityIdSet = new Set<Id>();
        Map<Id,Legal_Entity__c> legalEntityMap = New Map<Id,Legal_Entity__c>();
        
        //Retrieve new Legal Entity Id
        for(Engagement__c eng : newEngagementList){
            if(eng.Legal_Entity__c != null)
                legalEntityIdSet.add(eng.Legal_Entity__c);
        }
        
        /*
        List<Legal_Entity__c> legalEntityList = [SELECT Id, Name, ERP_Business_Unit__c, ERP_Business_Unit_Id__c, ERP_Entity_Code__c, ERP_Legislation_Code__c, ERP_VAT_Legal_Entity__c,
                                                 ERP_Legal_Entity_Id__c , ERP_Opportunity_Type_Template_number__c, ERP_Event_Type_Template_Number__c, ERP_Ledger_Name__c
                                                 FROM Legal_Entity__c
                                                 WHERE Id IN :legalEntityIdSet];
        */
        List<Legal_Entity__c> legalEntityList = HL_LegalEntity.getLegalEntitiesByIdSet(legalEntityIdSet);

        for(Legal_Entity__c le : legalEntityList){
            legalEntityMap.put(le.Id, le);
        }        
        
        for(Engagement__c eng : newEngagementList){
            if(eng.Legal_Entity__c != null){
                Legal_Entity__c le = legalEntityMap.get(eng.Legal_Entity__c);
                if(le != null){
                    eng.HL_Entity__c = le.Name;
                    eng.ERP_Template__c =  le.ERP_Opportunity_Type_Template_number__c;
                    eng.ERP_Legal_Entity_Id__c =  le.ERP_Legal_Entity_Id__c;
                    eng.ERP_Business_Unit__c =  le.ERP_Business_Unit__c;
                    eng.ERP_Business_Unit_Id__c =  le.ERP_Business_Unit_Id__c;
                    eng.ERP_Entity_Code__c = le.ERP_Entity_Code__c;
                    eng.ERP_Legislation_Code__c = le.ERP_Legislation_Code__c;
                }
            }
        }
    }
    
    //Clear out ERP Update flags if ERP Status is set to 'Success'
    public static void clearERPUpdateFlags(List<Engagement__c> oldEngagementList, Map<Id, Engagement__c> newEngagementMap){
        for(Engagement__c eng : oldEngagementList){
            Engagement__c newEng = newEngagementMap.get(eng.Id);
            if(newEng != null){
                if(newEng.ERP_Last_Integration_Response_Date__c != null
                   && newEng.ERP_Last_Integration_Response_Date__c != eng.ERP_Last_Integration_Response_Date__c){            
                       if(newEng.ERP_Last_Integration_Status__c != null 
                          && newEng.ERP_Last_Integration_Status__c.toUpperCase() == 'SUCCESS'){
                              newEng.ERP_Update_Attributes__c = false;
                              newEng.ERP_Update_DFF__c = false;
                              newEng.ERP_Update_Manager__c = false;
                              newEng.ERP_Update_New_Task__c = false;
                              newEng.ERP_Update_Status__c = false;
                          }
                   }
            }
        }
    }
        
    private void relatePitchRecords(List<Engagement__c> engList){
        Set<Id> oppIdSet = new Set<Id>();
        Map<Id,List<Pitch__c>> oppIdToPitchMap = new Map<Id,List<Pitch__c>>();
        for(Engagement__c eng : engList){
            if(eng.Opportunity__c!=null){
                oppIdSet.add(eng.Opportunity__c);
            }
        }
        for(Pitch__c pitch : [SELECT Id,Opportunity__c FROM Pitch__c WHERE Opportunity__c in :oppIdSet]){
            if(!oppIdToPitchMap.containsKey(pitch.Opportunity__c)){
                oppIdToPitchMap.put(pitch.Opportunity__c,new List<Pitch__c>());
            }
            oppIdToPitchMap.get(pitch.Opportunity__c).add(pitch);
        }
        List<Pitch__c> pitchUpdateList = new List<Pitch__c>();
        for(Engagement__c eng : engList){
            if(oppIdToPitchMap.containsKey(eng.Opportunity__c)){
                for(Pitch__c pitch : oppIdToPitchMap.get(eng.Opportunity__c)){
                    pitchUpdateList.add(new Pitch__c(Id=pitch.Id,Engagement__c=eng.Id));                    
                }
            }
        }
        if(!pitchUpdateList.isEmpty()){
            update pitchUpdateList;
        }
    }
}